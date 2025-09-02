from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from bson.objectid import ObjectId
from bson.errors import InvalidId
import os
import time

app = Flask(__name__)
CORS(app)

MONGO_URI = os.getenv("MONGO_URI", "mongodb://notes-db:27017/")
DB_NAME = "notes_db"

def init_db():
    """Initializes the MongoDB client and verifies connection."""
    retries = 10
    while retries > 0:
        try:
            client = MongoClient(MONGO_URI)
            # The ping command is a lightweight way to check the connection.
            client.admin.command('ping')
            print("✅ Connected to MongoDB.")
            return client
        except Exception as e:
            print(f"⚠️ DB not ready yet: {e}")
            retries -= 1
            time.sleep(5)
    raise Exception("❌ Could not connect to database after several retries.")

try:
    client = init_db()
    db = client[DB_NAME]
    notes_collection = db["notes"]
    print(f"✅ Connected to MongoDB database '{DB_NAME}' successfully.")
except Exception as e:
    print(f"❌ Error connecting to MongoDB: {e}")

@app.route("/notes", methods=["POST"])
def create_note():
    data = request.json
    if not data or "title" not in data or "content" not in data:
        return jsonify({"error": "Missing title or content"}), 400
    new_note = {"title": data["title"], "content": data["content"]}
    result = notes_collection.insert_one(new_note)
    return jsonify({
        "message": "Note created successfully",
        "id": str(result.inserted_id),
        "title": new_note["title"],
        "content": new_note["content"]
    }), 201


@app.route("/notes", methods=["GET"])
def get_all_notes():
    notes = list(notes_collection.find({}))
    for note in notes:
        note["_id"] = str(note["_id"])
    return jsonify(notes)


@app.route("/notes/<note_id>", methods=["GET"])
def get_note(note_id):
    try:
        obj_id = ObjectId(note_id)
    except InvalidId:
        return jsonify({"error": "Invalid note ID format"}), 400
    note = notes_collection.find_one({"_id": obj_id})
    if note:
        note["_id"] = str(note["_id"])
        return jsonify(note)
    return jsonify({"error": "Note not found"}), 404


@app.route("/notes/<note_id>", methods=["PUT"])
def update_note(note_id):
    try:
        obj_id = ObjectId(note_id)
    except InvalidId:
        return jsonify({"error": "Invalid note ID format"}), 400
    data = request.json
    if not data:
        return jsonify({"error": "No data provided for update"}), 400
    update_fields = {}
    if "title" in data:
        update_fields["title"] = data["title"]
    if "content" in data:
        update_fields["content"] = data["content"]
    result = notes_collection.update_one({"_id": obj_id}, {"$set": update_fields})
    if result.matched_count == 0:
        return jsonify({"error": "Note not found"}), 404
    return jsonify({"message": "Note updated successfully"})


@app.route("/notes/<note_id>", methods=["DELETE"])
def delete_note(note_id):
    try:
        obj_id = ObjectId(note_id)
    except InvalidId:
        return jsonify({"error": "Invalid note ID format"}), 400
    result = notes_collection.delete_one({"_id": obj_id})
    if result.deleted_count == 0:
        return jsonify({"error": "Note not found"}), 404
    return jsonify({"message": "Note deleted successfully"})


@app.route("/healthz", methods=["GET"])
def health_check():
    return jsonify({"status": "ok"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=True)

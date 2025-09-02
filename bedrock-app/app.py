from flask import Flask, request, jsonify
from flask_cors import CORS
import boto3
import os
import json
from dotenv import load_dotenv

# Load environment variables from the .env file
load_dotenv()

app = Flask(__name__)
CORS(app)

# Bedrock API Client
bedrock_client = boto3.client(
    'bedrock-runtime',
    region_name=os.getenv("AWS_DEFAULT_REGION"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
)

@app.route('/cheatsheet', methods=['POST'])
def generate_cheatsheet():
    data = request.get_json()
    topic = data.get("topic", "")
    if not topic:
        return jsonify({"error": "Topic is required"}), 400

    messages = [
        {"role": "user", "content": f"Create a cheat sheet of 10 commands/tips about {topic}."}
    ]

    body = json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 1000,
        "messages": messages
    })

    try:
        response = bedrock_client.invoke_model(
            modelId="anthropic.claude-3-sonnet-20240229-v1:0",
            body=body,
            contentType="application/json",
            accept="application/json"
        )
        
        result_body = json.loads(response['body'].read())
        
        if 'content' in result_body and len(result_body['content']) > 0 and 'text' in result_body['content'][0]:
            generated_text = result_body['content'][0]['text']
            return jsonify({"cheatsheet": generated_text})
        else:
            return jsonify({"error": "Unexpected response format from Bedrock API"}), 500

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Health check endpoint for Kubernetes probes
@app.route('/healthz', methods=['GET'])
def health_check():
    # You can add a check for the Bedrock client connection here for a more robust health check
    return jsonify({"status": "ok"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5005, debug=True)

#!/bin/bash

set -e

kubectl apply -f  k8s/ --recursive

#!/bin/bash
set -euo pipefail

eval $(minikube docker-env)
docker build -t nodeapp:1.0 .

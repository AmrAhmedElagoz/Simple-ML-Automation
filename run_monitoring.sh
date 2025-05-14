#!/bin/bash

# Start the model monitoring service
echo "Starting model monitoring service..."
python -m src.simpleML.monitoring.model_monitor_service --model-name "mnist_classifier_model" --port 8000 &
MODEL_MONITOR_PID=$!

# Start Prometheus and Grafana using Docker Compose
echo "Starting Prometheus and Grafana..."
cd monitoring && docker-compose up -d

echo "Monitoring stack started!"
echo "- Model metrics available at: http://localhost:8000"
echo "- Prometheus available at: http://localhost:9090"
echo "- Grafana available at: http://localhost:3000 (admin/admin)"

# Function to handle script termination
function cleanup {
    echo "Shutting down monitoring stack..."
    cd monitoring && docker-compose down
    
    echo "Stopping model monitoring service..."
    kill $MODEL_MONITOR_PID
    
    echo "Monitoring stack stopped"
}

# Register the cleanup function for SIGINT and SIGTERM
trap cleanup SIGINT SIGTERM

# Keep the script running
echo "Press Ctrl+C to stop the monitoring stack"
wait
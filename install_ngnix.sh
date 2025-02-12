#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt install -y python3-pip python3-venv git

# Define project directory
PROJECT_DIR="/var/www/fastapi-book-project"
REPO_URL="https://github.com/dammycute/fastapi-book-project.git"

#nothing to create project directory if it doesn't exist

# Clone repository if it doesn't exist
if [ ! -d "$PROJECT_DIR" ]; then
    echo "Cloning repository..."
    sudo git clone $REPO_URL $PROJECT_DIR
fi

# Navigate to project directory
cd $PROJECT_DIR

# Pull the latest changes
echo "Pulling latest changes from repository..."
sudo git pull origin main

# Set up virtual environment and install dependencies
echo "Setting up virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Create Supervisor configuration for FastAPI (if not exists)
SUPERVISOR_CONF="/etc/supervisor/conf.d/fastapi.conf"
if [ ! -f "$SUPERVISOR_CONF" ]; then
    echo "Creating Supervisor configuration..."
    sudo bash -c "cat > $SUPERVISOR_CONF" <<EOF
[program:fastapi]
command=$PROJECT_DIR/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000
directory=$PROJECT_DIR
user=root
autostart=true
autorestart=true
stdout_logfile=/var/log/fastapi.log
stderr_logfile=/var/log/fastapi.err.log
EOF
fi

# Reload Supervisor and start FastAPI
echo "Restarting Supervisor..."
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart fastapi

# Print success message
echo "🚀 FastAPI application deployed successfully!"

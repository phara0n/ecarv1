#!/bin/bash

# Startup script for eCar Garage app
# This script starts both the Rails backend and Flutter web app

echo "Starting eCar Garage Application..."
echo "====================================="

# Function to check if a process is running on a port
check_port() {
  lsof -i:$1 > /dev/null 2>&1
  return $?
}

# Fix permissions for Rails logs
echo "Fixing permissions for Rails logs..."
sudo mkdir -p /home/ecar/ecar-garage-app/backend/log
sudo mkdir -p /home/ecar/ecar-garage-app/backend/tmp/pids
sudo chmod -R 0777 /home/ecar/ecar-garage-app/backend/log
sudo chmod -R 0777 /home/ecar/ecar-garage-app/backend/tmp

# Kill any existing processes
echo "Cleaning up any existing processes..."
if [ -f /home/ecar/ecar-garage-app/backend/tmp/pids/server.pid ]; then
  echo "Found Rails PID file, stopping server..."
  sudo kill -9 $(cat /home/ecar/ecar-garage-app/backend/tmp/pids/server.pid) 2>/dev/null
  sudo rm /home/ecar/ecar-garage-app/backend/tmp/pids/server.pid
fi

# Kill any existing server on port 3000
echo "Checking for processes on port 3000..."
SERVER_PID=$(sudo lsof -t -i:3000 2>/dev/null)
if [ ! -z "$SERVER_PID" ]; then
  echo "Killing process on port 3000 (PID: $SERVER_PID)..."
  sudo kill -9 $SERVER_PID 2>/dev/null
fi

# Kill any existing server on port 8090
echo "Checking for processes on port 8090..."
WEB_PID=$(sudo lsof -t -i:8090 2>/dev/null)
if [ ! -z "$WEB_PID" ]; then
  echo "Killing process on port 8090 (PID: $WEB_PID)..."
  sudo kill -9 $WEB_PID 2>/dev/null
fi

# Start the Rails backend
echo "Starting Rails backend on port 3000..."
cd /home/ecar/ecar-garage-app/backend
echo "Installing gems..."
bundle install
echo "Starting Rails server..."
RAILS_ENV=development bundle exec rails s -p 3000 -b 0.0.0.0 &
RAILS_PID=$!
echo "Rails server started with PID: $RAILS_PID"

# Wait for Rails to fully start
echo "Waiting for Rails server to start..."
sleep 10
echo "Testing Rails server health check..."
curl -s http://localhost:3000/health_check

# Start the Flutter web app
echo -e "\nStarting Flutter web app on port 8090..."
cd /home/ecar/ecar-garage-app/frontend/web/admin_interface
echo "Building Flutter web app..."
flutter build web

# Serve using simple Python HTTP server
echo "Serving Flutter web app using Python HTTP server..."
cd build/web
python3 -m http.server 8090 &
FLUTTER_PID=$!
echo "Flutter web app started with PID: $FLUTTER_PID"

echo -e "\nBoth applications are now running!"
echo "Rails backend: http://localhost:3000"
echo "Flutter admin interface: http://localhost:8090"
echo "Login with: admin@ecar.tn / password123"
echo -e "\nTo stop the servers:"
echo "1. Kill Python HTTP server: kill -9 $FLUTTER_PID"
echo "2. Stop Rails server: kill -9 $RAILS_PID"

# Save the PIDs for later
echo $RAILS_PID > /tmp/ecar_rails.pid
echo $FLUTTER_PID > /tmp/ecar_flutter.pid 
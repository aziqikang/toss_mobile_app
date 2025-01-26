
# Default target
.DEFAULT_GOAL := help

# Backend directory
BACKEND_DIR := backend

# Frontend setup
setup-frontend:
	@echo "Setting up Flutter frontend..."
	flutter pub get
	@echo "Frontend setup complete."

# Backend setup
setup-backend:
	@echo "Setting up Python backend..."
	cd $(BACKEND_DIR) && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt
	@echo "Backend setup complete."

# Export environment variable for GCP credentials
export-gcp-credentials:
	@echo "Exporting GCP credentials..."
	cd $(BACKEND_DIR) && export GOOGLE_APPLICATION_CREDENTIALS="./google-cloud-credentials.json"
	@echo "GCP credentials exported."

# Start the backend server
run-backend:
	@echo "Starting backend server..."
	cd $(BACKEND_DIR) && source venv/bin/activate && python3 app.py

# Run the frontend on a connected device or emulator
run-frontend:
	@echo "Running Flutter app..."
	flutter run

# Setup project
setup: setup-frontend setup-backend
	@echo "Project setup complete!"

# Run both frontend and backend
run: export-gcp-credentials run-backend run-frontend

# Show help
help:
	@echo "Makefile targets:"
	@echo "  make setup            - Set up frontend and backend"
	@echo "  make run              - Start backend and run Flutter app"
	@echo "  make setup-frontend   - Set up only the Flutter frontend"
	@echo "  make setup-backend    - Set up only the Python backend"
	@echo "  make run-backend      - Run the backend server"
	@echo "  make run-frontend     - Run the Flutter frontend"

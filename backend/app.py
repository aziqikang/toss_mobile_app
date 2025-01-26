import os
import json
from flask import Flask, request, jsonify
from google.cloud import vision
from geopy.geocoders import Nominatim

# Initialize Flask app
app = Flask(__name__)

# Load categories from JSON
with open("categories.json", "r") as f:
    CATEGORIES = json.load(f)

# Initialize Google Cloud Vision client
vision_client = vision.ImageAnnotatorClient()

# Geolocator for reverse geocoding
geolocator = Nominatim(user_agent="recycling-app")


def classify_object(description):
    """
    Classifies an object based on its description.
    Args:
        description (str): The description from the Vision API or Gemini.
    Returns:
        dict: A dictionary containing the category, subcategory, and disposal instructions.
    """
    for category_id, category_data in CATEGORIES["categories"].items():
        for subcategory_id, subcategory_data in category_data["subcategories"].items():
            if description.lower() in subcategory_data["name"].lower():
                return {
                    "category": category_data["name"],
                    "subcategory": subcategory_data["name"],
                    "disposal_instruction": subcategory_data["disposal_instruction"],
                    "url": subcategory_data.get("url"),
                }
    return {
        "category": "Uncertain",
        "subcategory": "Unknown Material",
        "disposal_instruction": "Consult your local waste management authority.",
        "url": "https://example.com/recycling/help"
    }


@app.route("/analyze-image", methods=["POST"])
def analyze_image():
    """
    Handles image upload and returns classification details.
    """
    try:
        # Check if the request contains an image file
        if "image" not in request.files:
            return jsonify({"error": "No image file provided"}), 400

        image = request.files["image"]

        # Read the image for Vision API
        content = image.read()

        # Call Google Vision API
        response = vision_client.label_detection(image={"content": content})
        labels = response.label_annotations

        # Extract descriptions from the labels
        descriptions = [label.description for label in labels]

        # Attempt to classify the object
        classifications = [
            classify_object(description) for description in descriptions
        ]

        # Remove duplicates (unique by subcategory name)
        seen = set()
        unique_classifications = []
        for classification in classifications:
            if classification["subcategory"] not in seen:
                unique_classifications.append(classification)
                seen.add(classification["subcategory"])

        # Reverse geocode location (if provided)
        location = None
        if "latitude" in request.form and "longitude" in request.form:
            latitude = request.form["latitude"]
            longitude = request.form["longitude"]
            location = geolocator.reverse(f"{latitude}, {longitude}").address

        # Prepare the response
        response = {
            "location": location,
            "classifications": unique_classifications,
            "raw_labels": descriptions,
        }

        return jsonify(response)

    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

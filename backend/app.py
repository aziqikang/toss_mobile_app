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


def classify_object(description, score, location=None, score_threshold=0.7):
    """
    Classifies an object based on its description and confidence score.
    Args:
        description (str): The description from the Vision API or Gemini.
        score (float): Confidence score of the label.
        location (str): Location context for classification.
        score_threshold (float): Minimum confidence score to consider.
    Returns:
        dict: A dictionary containing the category, subcategory, disposal instructions, and URL.
    """
    if score < score_threshold:
        return None  # Skip low-confidence labels

    for category_id, category_data in CATEGORIES["categories"].items():
        for subcategory_id, subcategory_data in category_data["subcategories"].items():
            if description.lower() in subcategory_data["name"].lower():
                # Adjust disposal instructions based on location if provided
                disposal_instruction = subcategory_data["disposal_instruction"]
                if location:
                    disposal_instruction += f" Please check local guidelines for {location}."

                return {
                    "category": category_data["name"],
                    "subcategory": subcategory_data["name"],
                    "disposal_instruction": disposal_instruction,
                    "url": subcategory_data.get("url"),
                }

    # Return a default classification for unrecognized items
    return {
        "category": "Uncertain",
        "subcategory": "Unknown Material",
        "disposal_instruction": "Consult your local waste management authority.",
        "url": "https://example.com/recycling/help",
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

        # Extract descriptions and confidence scores from the labels
        descriptions = [
            {"description": label.description, "score": label.score} for label in labels
        ]

        # Reverse geocode location (if provided)
        location = None
        if "latitude" in request.form and "longitude" in request.form:
            latitude = request.form["latitude"]
            longitude = request.form["longitude"]
            location = geolocator.reverse(f"{latitude}, {longitude}").address

        # Attempt to classify the objects
        classifications = [
            classify_object(desc["description"], desc["score"], location=location)
            for desc in descriptions
        ]

        # Remove None entries (e.g., low-confidence labels)
        classifications = [c for c in classifications if c is not None]

        # Remove duplicates (unique by subcategory name)
        seen = set()
        unique_classifications = []
        for classification in classifications:
            if classification["subcategory"] not in seen:
                unique_classifications.append(classification)
                seen.add(classification["subcategory"])

        # Prepare the response
        response = {
            "location": location,
            "classifications": unique_classifications,
            "gemini_output": [
                {
                    "object": classification["subcategory"],
                    "category": classification["category"],
                    "instruction": classification["disposal_instruction"],
                    "url": classification.get("url"),
                }
                for classification in unique_classifications
            ],
            "raw_labels": [desc["description"] for desc in descriptions],
        }

        app.logger.info(f"Classifications: {unique_classifications}")
        app.logger.info(f"Location: {location}")

        return jsonify(response)

    except Exception as e:
        app.logger.error(f"An error occurred: {str(e)}")
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

# backend/models/photo_description.py

class PhotoDescription:
    def __init__(self, description):
        self.description = description

    def to_dict(self):
        return {
            'description': self.description
        }

# Toss Mobile

## Getting Started

Follow these steps to set up and run the `toss_mobile_app` project.

### Prerequisites
- Flutter SDK (latest stable)
- Python 3.7+
- Git

### Setup & Run
Clone the repository and run the following for setup:
```bash
git clone https://github.com/aziqikang/toss_mobile_app.git
cd toss_mobile_app
make setup
```

To run the app on an emulator or device:
```
make run
```
----

## Inspiration 🌱
Recycling is tough. Despite throwing things away all the time, every day, we've all stalled extra moments between a trash can and its neighboring recycling bin, because where the hell do you put your empty shipping packages?? And then there are batteries, paints and harmful waste, glass bottles, and... oh, compost. I guess that's waste too.
Waste disposal procedures should be elementary yet, in practice, are so overcomplicated that we often resort to pure guesswork, since "it doesn't matter _that_ much; it all ends up in the same place, anyways" (_you know it matters_).

## What it does 🤳
**Toss** is an easy access mobile app that helps you _throw it away, the right way._ We are essentially an integrated camera, with backend APIs that scan your trash and match it to where it belongs, depending on your local recycling rules.

Some cool features:
-  a built-in camera with and object scanner _and_ barcode/ufc scanner
- location-dependent trash disposal instructions
- (coming) weekly environmental news, Toss history, and more...

## How we built it 🛠️
We built **Toss** using Flutter for Dart, Google Cloud Console for data storage, and the Gemini API for fast image recognition (though we would love to train our own waste-labeling model someday 👀). The backend for this project was built using the Flask Python framework.

## What's next for Toss Mobile 💡
(Ooh, wouldn't you like to know...)
- Creating fun user profiles with points, a friend system (and maybeee a way to earn credits off of recycling properly)
- Improving our backend. Gemini gave us a quick-fix for the 24 hours we were given, but training our own model could allow for more accurate, tailored predictions. 
- Bringing more resources into **Toss**---maybe a newsletter, achievements, or fun challenges and incentives!


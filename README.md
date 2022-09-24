# Tiny Dermatologist
An Android app that uses AI to classify Skin Lesions

### Technologies Used: 

- Pytorch
- Flutter
- Google Firebase

## Homepage

The application is built using Flutter, a Dart framework created by google. It compiles to native code. 

The authentication is implemented using Firebase email auth. The user enters an email. If the email exists in the system, user is prompted to log in or register if the email is not found.

We can proceed to take an image to classify a lesion here, or log out of our account.

<img src="https://github.com/coddiw0mple/skin_lesions_classifier_app/blob/main/assets/screens/1.jpg?raw=true" width="300">

## Camera

The camera module is activated and auto-focuses to the primary object of interest. Upon clicking it, the image is passed through the model to predict the type of lesion.

<img src="https://github.com/coddiw0mple/skin_lesions_classifier_app/blob/main/assets/screens/2.jpg?raw=true" width="300">

## Processing the image

A CV model is built using pytorch. The photo taken on the camera page is set to process asynchronously as the user waits for the results on a loading screen. Within a few seconds, an answer is returned and the screen displays the image the user clicked recently with the results. Some helpful information about the predicted lesion is provided too.

<img src="https://github.com/coddiw0mple/skin_lesions_classifier_app/blob/main/assets/screens/3.jpg?raw=true" width="300">
<img src="https://github.com/coddiw0mple/skin_lesions_classifier_app/blob/main/assets/screens/4.jpg?raw=true" width="300">

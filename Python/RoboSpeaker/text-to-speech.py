from gtts import gTTS
import os

def speak(text, lang='en', slow=False):
    """
    Function to convert text to speech and play it.
    :param text: The text to be spoken.
    :param lang: Language code (e.g., 'en' for English, 'es' for Spanish).
    :param slow: If True, the speech will be slow; if False, normal speed.
    """
    tts = gTTS(text=text, lang=lang, slow=slow)
    tts.save("I am your robo")
    os.system("I am your robo")  # You can use another audio player if mpg321 is not available.

if __name__ == "__main__":
    text_to_speak = "Hello, I am your robo speaker. How can I assist you?"
    speak(text_to_speak)

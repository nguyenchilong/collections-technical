"""
install the following packages:
pip install SpeechRecognition
pip install pyaudio

Transform Any Audio File into Text Format Using PYTHON code
"""


import speech_recognition as sr
from pydub import AudioSegment

# Convert your audio MP3
AudioSegment.from mp3("your_audio here.mp3").export ("audio.wav", format="wav")

# Recognize speech and Convert it to text
recog = sr.Recognizer()
with sr.AudioFile("audio.wav") as src:
	audio = recog. record (sc)

try:
	print ("Text:", recog.recognize_google(audio))
except sr.UnknownValueError:
	print ("Unable to recognize speech.")
except sr.RequestError as err:
	print ("API Error:", err)

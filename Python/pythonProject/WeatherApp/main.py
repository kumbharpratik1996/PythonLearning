import requests
import json
import win32com.client as wincom

if __name__ == '__main__':

    location = input("Please Enter a City Name:\n")
    url = f"https://api.weatherapi.com/v1/current.json?key=48878c7b3d87420bb54130740232707&q={location}"

    r = requests.get(url)
    # print(r.text)
    loc_dic = json.loads(r.text)
    speak = wincom.Dispatch("SAPI.SpVoice")
    print(f"Current Temperature of {location} is : ", loc_dic["current"]["temp_c"],"degrees")
    text_to_speech = f"Current Temperature of {location} is: ", loc_dic["current"]["temp_c"],"degrees"
    speak.Speak(text_to_speech)

import requests

url = 'http://localhost:4567/ptest'
x = requests.post(url, data="HELLO WORLD")
print("Response from server:", x.text)
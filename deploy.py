import requests

payload = {
    'username': 'MyUsername',
    'password': 'MyPassword'
}

with requests.Session() as s:
    p = s.post("http://www.fileright.com", data=payload)
    print (p.text)

    r = s.get("A_protected_URL")
    print (r.text)
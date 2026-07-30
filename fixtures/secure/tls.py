# FIXTURE — disabled certificate verification in requests
import requests
r = requests.get("https://example.com", verify=False)

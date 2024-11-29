import requests

SERVER_BROWSER_BASE_URL = 'https://dev3.gasstationsoftware.net'

result = requests.get(f'{SERVER_BROWSER_BASE_URL}/api/debug/state/WS', verify=False)

with open('debug_data_dump.json', 'w') as f: f.write(result.text)

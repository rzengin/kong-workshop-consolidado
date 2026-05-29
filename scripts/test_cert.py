import os
os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import requests
import json
token = os.environ.get('KONNECT_TOKEN')
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
res = requests.post("https://us.api.konghq.com/v2/control-planes/f75082ae-c211-4b31-8e2e-509290c1e838/dp-client-certificates", headers=headers)
print(json.dumps(res.json(), indent=2))

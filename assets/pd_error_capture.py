import json
import pprint
import sseclient
import urllib3
import sys

concourse_hostname = sys.argv[1]
concourse_username = sys.argv[2]
concourse_password = sys.argv[3]
build_number = sys.argv[4]

def search_ids_names(current_id, accum_dict, plan):
    if plan.has_key('id'):
        current_id = plan['id']
    if plan.has_key('name'):
        accum_dict[current_id] = plan['name']


    for v in plan.values():
        if type(v) == dict:
            search_ids_names(current_id, accum_dict, v)
        if type(v) == list:
            for v2 in v:
                search_ids_names(current_id, accum_dict, v2)

    return accum_dict

# Login
url = '{0}/api/v1/teams/main/auth/token'.format(concourse_hostname)
http = urllib3.PoolManager(timeout=urllib3.Timeout(connect=1.0, read=20.0))
headers = urllib3.util.make_headers(basic_auth='{0}:{1}'.format(concourse_username, concourse_password))
response = http.request('GET', url, preload_content=False, headers=headers)

if response.status != 200:
    print "Login failed (status: {0}). Exiting.".format(response.status)
    sys.exit(1)

token = json.loads(response.read())['value']

# Resolve taskid's to names
url = '{0}/api/v1/builds/{1}/plan'.format(concourse_hostname, build_number)
http.headers['Cookie'] = 'ATC-Authorization="Bearer {0}"'.format(token)
response = http.request('GET', url, preload_content=False)

if response.status != 200:
    print "Login failed (status: {0}). Exiting.".format(response.status)
    sys.exit(1)

plan = json.loads(response.read())
task_map = search_ids_names(None, {}, plan)

# Job event stream
url = '{0}/api/v1/builds/{1}/events'.format(concourse_hostname, build_number)
http.headers['Cookie'] = 'ATC-Authorization="Bearer {0}"'.format(token)
http.headers['Accept'] = 'text/event-stream'

response = http.request('GET', url, preload_content=False)

if response.status != 200:
    print "Event stream failed (status: {0}). Exiting.".format(response.status)
    sys.exit(1)

client = sseclient.SSEClient(response)

logs = {}

output = ""
for event in client.events():
    if event.event == 'end':
      break

    edata = json.loads(event.data)

    if edata['event'] == "finish-task" and edata['data']['exit_status'] == 0:
      taskId = edata['data']['origin']['id']
      logs.pop(taskId, None)

    if edata['event'] == "log":
      taskId = edata['data']['origin']['id']
      logs[taskId] = logs.get(taskId, "") + edata['data']['payload']

print "\n".join("\n--------------\n".join([task_map[k], v]) for k,v in logs.items())

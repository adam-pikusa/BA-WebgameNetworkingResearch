import json

with open('debug_data_dump.json', 'r') as f:
    data = json.load(f)

ticks = {}

for object_string in data:
    object = json.loads(object_string)

    if not 'state' in object: 
        continue

    if not object['tick'] in ticks:
        ticks[object['tick']] = []
        
    ticks[object['tick']].append((object['state'], object['client']))


for tick in ticks:
    print(tick)
    for state in ticks[tick]:
        print(f'\t{state[0]}:{state[1]}')
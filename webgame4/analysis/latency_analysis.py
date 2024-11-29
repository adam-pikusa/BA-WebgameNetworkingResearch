import os, json, numpy, base64
import matplotlib.pyplot as plt

def decode_latency_data(data: str):
    array_bytes = base64.b64decode(data.encode('ascii'))
    nparray = numpy.frombuffer(array_bytes, dtype=numpy.float32)
    return nparray

with open('debug_data_dump.json', 'r') as f:
    data = json.load(f)

latency_by_client = {}

for object_string in data:
    object = json.loads(object_string)

    if not 'latency_data' in object: 
        continue

    if not object['client'] in latency_by_client:
        latency_by_client[object['client']] = []
        
    latency_by_client[object['client']].append(decode_latency_data(object['latency_data']))


for client in latency_by_client:
    x = []
    y = []
    for interleaved_array in latency_by_client[client]:
        for i in range(len(interleaved_array)):
            if i % 2 == 0:
                x.append(interleaved_array[i])
            else:
                y.append(interleaved_array[i])
    plt.hist(y, bins=20)

plt.show()
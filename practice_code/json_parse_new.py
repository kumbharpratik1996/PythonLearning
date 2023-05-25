import json

file = open("billing.json", "r")
example = file.read()
file.close()

parsedJson = json.loads(example)
#print(parsedJson)

tblDetail = parsedJson['sre_sla_check']
print(tblDetail[0]['table_name'])
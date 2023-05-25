import ast
parsed_input = []
ft = open("billods.json", 'r')
data = ft.read().replace('\n', '')
parsed_entry = ast.literal_eval(data)
parsed_input.append(parsed_entry)
print(parsed_input)

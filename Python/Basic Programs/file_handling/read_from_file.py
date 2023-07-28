# reading a file

with open("sample.txt", "r", encoding="utf8") as file:
    f = file.read()
    print(f)

new_file = open('sample1.txt', 'r', encoding="utf8")
f1=new_file.read()
print(f1)
new_file.close()

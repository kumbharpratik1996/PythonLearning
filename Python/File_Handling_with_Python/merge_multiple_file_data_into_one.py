import os

files = [] # will take files from user
merged_data=""
file_found = True

while True:
    f_name = input("Please enter a file name:\n")
    files.append(f_name)
    ans = input("want to add another file? (y/n):").lower()
    if ans != 'y':
        break

for file in files:
    file_name = f"{file}.txt"
    if os.path.isfile(file_name):
        open_file = open(file_name,mode='r')
        merged_data = merged_data+open_file.read()+'\n'
        open_file.close()
    else:
        file_found = False
        print(f"{file_name} not found!")


#print(merged_data)
if file_found == True:
    with open(input('Please Enter Output File Name:\n')+'.txt', mode='x') as merged_file:
        merged_file.write(merged_data)
        merged_file.close()
        print("content merged")
else:
    print("one of the file is missing, exiting the merge!")

print("Program has been successfully executed!")
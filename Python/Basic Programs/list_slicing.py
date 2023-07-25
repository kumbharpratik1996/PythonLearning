import os

pwd = os.getcwd()
print(pwd)

all_files = os.listdir()
print(all_files[:])

unsorted_numbers = [12,5,20,21,4]
unsorted_numbers.sort(reverse=True)
print(unsorted_numbers)


#print(all_files)
# for file in all_files:
#     print(file)

# for file in os.listdir(pwd):
#     all_files = [file]
#     print(all_files)


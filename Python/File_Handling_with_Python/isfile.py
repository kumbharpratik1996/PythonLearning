import os

if os.path.isfile("age.txt"):
    print(os.path.isfile("age.txt"))
else:
    print("file not found!")
import os

#writing into the file

with open("sample.txt","w",encoding="utf8") as file:
    file.write("Hello World!\n"
               "Hello World!")
new_file = open('sample1.txt','w',encoding="utf8")
new_file.write("Hello world 1 !")
new_file.close()



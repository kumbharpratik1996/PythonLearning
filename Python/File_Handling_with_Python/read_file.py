file = open("age.txt","r")
readfile=file.read(1)
print(readfile)
file.tell()
file.seek(0)
print(","+ file.read(2))
file.close()
age = input("Please Enter your Age:\n")
file = open("age.txt","w")
print(age)
if file.writable() == True:
    file.write(age)
file.close()


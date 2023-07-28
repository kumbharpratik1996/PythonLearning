try:
    number = int(input("Please enter a number: \n"))
    print(number + 3)
except Exception as error:
    print("Invalid Number or Integer value: ", error)
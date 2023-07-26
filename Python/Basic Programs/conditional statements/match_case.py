# choice = int(input("Please Enter a number:\n"))
# match choice:
#     case 1:
#         print("number is 1")
#     case 2:
#         print("number is 2")
#     case _:
#         print("no match found")

a = int (input("Enter a number between 1 to 10:\n"))

def table (n):
    for i in range(1,11):
        print (f"{n}*{i}= {i*n}")

match a:
    case 1:
        table (1)
    case 2:
        table (2)
    case 3:
        table (3)
    case 4:
        table (4)
    case 5:
        table (5)
    case 6:
        table (6)
    case 7:
        table (7)
    case 8:
        table (8)
    case 9:
        table (9)
    case 10:
        table (10)
    case _:
        print ("The number does not lie between 1 to 10.")

def table(num):
    for number in range(1,11):
        print(f"{num} * {number} =",number * num)

num = int(input("Please enter a integer number between 1 and 5:\n"))

match num:
    case 1:
        table(1)
    case 2:
        table(2)
    case 3:
        table(3)
    case 4:
        table(4)
    case 5:
        table(5)
    case _:
        print("number is out of range")
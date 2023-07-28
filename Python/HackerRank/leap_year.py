def is_leap(year):
    ignore_list = [1800, 1900, 2100, 2200, 2300, 2500]
    if year not in ignore_list:
        if len(str(year)) == 4:
            leap = False
            # Write your logic here
            if year % 400 == 0:
                leap = True
            elif year % 4 == 0:
                leap = True
            elif year % 100 == 0:
                leap = False
            else:
                print("Invalid")
            return leap
        else:
            print("Error, Please Enter a correct 4 digit year!")
    else:
        print(f"Year: {ignore_list} are not leap years!")

try:
    year = int(input("Please Enter 4 digit Year:\n"))
    is_leap(year)

except Exception as error:
    print("Invalid Input:", error)

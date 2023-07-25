input_string= input("Please Enter a string to reverse:\n")

#Method 1 using for loop
def reverse_string(input_string):
    result=""
    for character in input_string:
        result = character + result
    return result

print(f"Reverse string using for loop: {reverse_string(input_string)}")

#2 using method: reversed()

reverse_string = "".join(reversed(input_string))
print(f"Reverse string using reversed() method:", reverse_string)

#3 Using Extened Slice

print("Reverse string using exteneded slice:",input_string[::-1])

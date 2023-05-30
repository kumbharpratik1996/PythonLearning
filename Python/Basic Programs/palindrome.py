#reversing the string

input_word = input("Please enter a word:\n")

if input_word == input_word[::-1]:
    print("this is palindrome ")
else:
    print("the word is not palindrome")
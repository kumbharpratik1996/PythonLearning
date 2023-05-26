import random

number = random.randint(1,6)
guess = int(input("Please guess a number: "))

if guess == number:
    print("Congrats! You guessed correct number")
elif guess < number:
    print("You guessed too low, the number was", number)
else:
    print("You guessed too high, the number was", number)
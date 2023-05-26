num_terms = int(input("Enter the number of terms: "))
first_term, second_term = 0, 1

if num_terms <= 0:
    print("Please enter a positive integer.")
elif num_terms == 1:
    print("Fibonacci sequence up to", num_terms, "term:")
    print(first_term)
else:
    print("Fibonacci sequence up to", num_terms, "terms:")
    print(first_term)
    print(second_term)
    for _ in range(2, num_terms):
        next_term = first_term + second_term
        print(next_term)
        first_term, second_term = second_term, next_term

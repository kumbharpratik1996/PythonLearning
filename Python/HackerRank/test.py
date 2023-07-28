def execute_if_number_not_in_list(number, some_list):
    if number not in some_list:
        # Execute your desired instructions here
        print(f"The number {number} is not in the list.")
        print("Executing specific instructions...")
        # Add your code to execute here
    else:
        print(f"The number {number} is already in the list.")

# Example usage:
my_list = [1, 2, 3, 4, 5]
user_input = 12

execute_if_number_not_in_list(user_input, my_list)

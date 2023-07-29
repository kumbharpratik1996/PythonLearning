from datetime import datetime

def calculate_age(birth_date):
    current_date = datetime.now()
    age = current_date.year - birth_date.year - ((current_date.month, current_date.day) < (birth_date.month, birth_date.day))
    return age

# Example usage:
# Replace '1990-05-15' with the person's actual birth date in 'YYYY-MM-DD' format.
birth_date_str = '1996-09-06'
birth_date = datetime.strptime(birth_date_str, '%Y-%m-%d')
age = calculate_age(birth_date)
print("Age:", age)

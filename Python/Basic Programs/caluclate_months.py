# import calendar
# joined_month = calendar.month(2021,8)
# current_month = joined_month
# print(joined_month)

import calendar
def calculate_month_difference(start_month, end_month):
    start_year, start_month = map(int, start_month.split('-'))
    end_year, end_month = map(int, end_month.split('-'))

    start_date = calendar.monthrange(start_year, start_month)[1]
    end_date = calendar.monthrange(end_year, end_month)[1]

    month_difference = (end_year - start_year) * 12 + (end_month - start_month)

    if end_date < start_date:
        month_difference -= 1

    return month_difference

# Example usage:
start_month = '2021-08'
end_month = '2023-05'
difference = calculate_month_difference(start_month, end_month)
print("Month difference:", difference)

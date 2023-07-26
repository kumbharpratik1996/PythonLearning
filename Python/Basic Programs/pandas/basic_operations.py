import pandas

df = pandas.read_excel("employee_sample_data.xlsx")
df1 = df[0:2]
print(df1)


count = 0
for element in df1:
    print(element)
    count += 1
print(count)
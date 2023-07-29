# Python program to demonstrate
# Creation of Array

# importing "array" for array creations
import array as arr

# creating an array with integer type
a = arr.array('i', [1, 2, 3,4,5,6])
a.append(7)
# printing original array
print("The new created array is : ", end=" ")
for i in range(0,len(a)):
	print(a[i], end=" ")
print()

# creating an array with double type
b = arr.array('d', [2.5, 3.2, 3.3])

# printing original array
print("\nThe new created array is : ", end=" ")
for i in range(0, len(b)):
	print(b[i], end=" ")
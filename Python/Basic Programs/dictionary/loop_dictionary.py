thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}

print("\nAll Keys:")
for element in thisdict:
        print(element) # only print keys from dictionary

print("\nAll Values:")
for element in thisdict:
    print(thisdict[element])  # only print values from dictionary


# different way
print("\nkeys:")
for element in thisdict.keys():
    print(element) #keys() method to return values of a dictionary:

print("\nvalues: ")
for element in thisdict.values():
    print(element) #values() method to return values of a dictionary:

#Loop through both keys and values, by using the items() method:

for x, y in thisdict.items():
  print(x, y)


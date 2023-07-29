file1 = open("age.txt",mode='r')
file2 = open("age_copy.txt",mode='w')

#method 1
# read_file=file1.read()
# file2.write(read_file)

#method 2
for line in file1:
    file2.write(line)

file1.close()
file2.close()


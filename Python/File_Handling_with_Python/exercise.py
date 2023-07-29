file = open("age.txt",'r')
number_of_lines=0
number_of_words=0
number_of_char=0

for line in file:
    number_of_lines +=1
    line = line.strip('\n')
    number_of_char+= len(line)
    split_word = line.split(" ")
    number_of_words += len(split_word)
file.close()
print(number_of_lines)
print(number_of_char)
print(number_of_words)
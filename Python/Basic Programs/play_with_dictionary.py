import os
import csv

path = os.getcwd()


with open(f'{path}\sample.csv','r') as f:
    read_file = csv.reader(f)
    #next(read_file)
    for line in read_file:
        if line[0] == 'Pratik':
            print("found")
        else:
            pass

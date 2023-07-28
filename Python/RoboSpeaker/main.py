

import os

def print_hi(name):
    print(f'Hi, {name}')

if __name__ == '__main__':
    input_text= input("Please enter a text you want to pronounce by Robot:\n")
    cmd = f"say {input_text}"
    os.system(cmd)
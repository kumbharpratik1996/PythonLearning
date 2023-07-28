# #prints 1 to 10 using while loops
# i = 1
# while i <= 10:
#     print(i)
#     i += 1 #assignment operator increments count of i

if __name__ == '__main__':
    n = int(input())
    i = 0

    while i <= n:
        print(i * i)
        i += 1

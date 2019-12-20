"""
    Author:         CaptCorpMURICA
    Project:        Ranges
    File:           ranges.py
    Creation Date:  12/4/2017, 2:20 PM
    Description:    Tutorial on Ranges in Python
"""
# Start value defaults to 0
print(range(100))

my_list = list(range(10))
print(my_list)

print("=============")

# range(start, stop, step)
even = list(range(0, 10, 2))
odd = list(range(1, 10, 2))
print(even)
print(odd)

print("=============")

# All ranges use the same amount of memory.
# However, if building a list off the range, longer range based lists use more memory.

my_string = "abcdefghijklmnopqrstuvwxyz"
print(my_string.index("e"))
print(my_string[4])

print("=============")

small_decimals = range(0, 10)
print(small_decimals)
print(small_decimals.index(3))

print("=============")

odd = range(1,10000,2)
print(odd)
print(odd[985]) # Prints 985th odd number

print("=============")

sevens = range(7, 1000000, 7)
x = int(input("Please enter a positive number less than one million: "))
if x in sevens:
    print("{} is divisible by seven.".format(x))
else:
    print("{} is not divisible by seven.".format(x))

print("=============")

print(small_decimals)
my_range = small_decimals[::2]
print(my_range)
print(my_range.index(4))

print("=============")

decimals = range(0, 100)
print(decimals)

my_range = decimals[3:40:3]
for i in my_range:
    print(i)

print("=" * 40)

for i in range(3, 40, 3):
    print(i)

print(my_range == range(3, 40, 3))
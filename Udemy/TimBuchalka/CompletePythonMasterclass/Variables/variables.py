"""
    Author:         CaptCorpMURICA
    Project:        Variables
    File:           variables.py
    Creation Date:  11/29/2017, 4:21 PM
    Description:    Storing items in variables
"""
# Variable needs to start with letter or underscore

__author__ = 'dev'

greeting = "Kevin"
_myName = "Steve"
Tim45 = "Good"
Tim_Was_57 = "Hello"
Greeting = "There"

print(Tim_Was_57 + ' ' + Greeting + ' ' + greeting)

age = 24
print(age)

# Cannot concatenate string and integer in this manner
# print(greeting + age)
print(greeting + ' ' + str(age))

# Integer - Limit to the size of an int (~9 Trillion)
a = 12
b = 3
# Float - Has 52 digits of precision, much larger limit than int
c = 4.2

print(a + b)
print(a - b)
print(a * b)
print(a / b) # Returns as float
print(a // b) # Returns as integer
print(a % b) # Remainder

# Range not inclusive
for i in range(1,4):
    print(i)

# Error: cannot use float in range
# for i in range(1,a/b):
#     print(i)

# Use double slash to return as integer for calculation
for i in range(1,a//b):
    print(i)

# Operator Precedence: PEMDAS
print(a + b / 3 - 4 * 12)

print(8 / 2 * 3)
print(8 * 3 / 2)

print((((a + b) / 3) - 4) * 12)

# Use variables to hold intermediate values
c = a + b
d = c / 3
e = d - 4
print(e * 12)


# Strings
parrot = "Norwegian Blue"
print(parrot)

print(parrot[3]) # Index starts at 0
print(parrot[0])
# print(parrot[14]) -- Index out of range
print(parrot[-1])

# Slicing - Not inclusive end cap
print(parrot[0:6])
print(parrot[:6])
print(parrot[6:])
print(parrot[-4:-2])
print(parrot[0:6:2])
print(parrot[0:6:3])
print(parrot[::-1])

# Only pull commas
number = "9,223,372,036,854,775,807"
print(number[1::4])

# Skip commas and spaces
numbers = "1, 2, 3, 4, 5, 6, 7, 8, 9"
print(numbers[::3])

# String operators
string1 = "he's "
string2 = "probably "
print(string1 + string2)

print("he's " "probably")

print("Hello\n"*5)

print("Hello " * (5 + 4))
print("Hello " * 5 + "4")

today = "Friday"

print("day" in today)
print("fri" in today) # Case sensitive
print("Thurs" in today)
print("parrot" in "Fjord")
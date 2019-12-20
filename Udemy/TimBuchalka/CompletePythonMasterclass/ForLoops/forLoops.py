"""
    Author:         CaptCorpMURICA
    Project:        ForLoops
    File:           forLoops.py
    Creation Date:  11/30/2017, 2:13 PM
    Description:    Understand syntax and use of For Loops in Python
"""

# # Last value specified in range in non-inclusive
# # Task: Print values 1 to 20
# # i is short for index
# for i in range(1,21):
#     print("i is now {}".format(i))

number = "9,223,372,036,854,775,807"
cleanedNumber = ''
# print(len(number))
# for i in range(0, len(number)):
#     print(number[i])

# # Skips any non numeric character
# for i in range(0, len(number)):
#     if number[i] in '0123456789':
#         print(number[i],end='')

# # Another option to clean the number into a single line
# for i in range(0, len(number)):
#     if number[i] in '0123456789':
#         cleanedNumber = cleanedNumber + number[i]

# newNumber = int(cleanedNumber)
# print("The number is {}.".format(newNumber))

# # Can remove iterator and iterate over a string.
# for char in number:
#     if char in '0123456789':
#         cleanedNumber = cleanedNumber + char
#
# newNumber = int(cleanedNumber)
# print("The number is {}.".format(newNumber))
#
# # Can loop through a list of strings
# for state in ["not pinin'", "no more", "a stiff", "bereft of life"]:
#     print("This parrot is " + state)
#
# # Can add a step value to range.
# for i in range(0, 100, 5):
#     print("i is {}.".format(i))

# Use a for loop to create the multiplication table
for i in range(1, 13):
    for j in range(1, 13):
        print("{1:2} times {0:2} is {2:3}".format(i, j, i * j))
    print("===================")

# Change the output to single line per j
for i in range(1, 13):
    for j in range(1, 13):
        print("| {1:2} times {0:2} is {2:3} |".format(i, j, i * j), end='')
    print('')
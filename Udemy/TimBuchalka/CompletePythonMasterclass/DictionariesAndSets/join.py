"""
    Author:         CaptCorpMURICA
    File:           join.py
    Creation Date:  1/8/2018, 11:01 AM
    Description:    Overview of string joins in Python
"""

myList = ["a", "b", "c", "d"]

newString = ''

# Not a good way to concatenate strings because new string is created each run through the loop.
# This becomes computationally heavy.
for c in myList:
    newString += c + ", "

print(newString)

print("=" * 50)

# Efficient way to concatenate strings. A loop is not required.
newString = ", ".join(myList)

print(newString)

print("=" * 50)

letters = "abcdefghijklmnopqrstuvwxyz"
newString = ", ".join(letters)
print(newString)

print("=" * 50)

numbers = "123456789"
newString = " Mississippi ".join(numbers)
print(newString)

print("=" * 50)

# Dictionary of locations
locations = {0: "You are sitting in front of a computer learning Python",
             1: "You are standing at the end of a road before a small brick building",
             2: "You are at the top of a hill",
             3: "You are inside a building, a well house for a small stream",
             4: "You are in a valley beside a stream",
             5: "You are in the forest"}

# List of dictionary objects for exits
exits = [{"Q": 0},
         {"W": 2, "E": 3, "N": 5, "S": 4, "Q": 0},
         {"N": 5, "Q": 0},
         {"W": 1, "Q": 0},
         {"N": 1, "W": 2, "Q": 0},
         {"W": 2, "S": 1, "Q": 0}]

loc = 1
while True:
    availableExits = ", ".join(exits[loc].keys())

    print(locations[loc])

    if loc == 0:
        break

    direction = input("Available exits are " + availableExits + ": ").upper()
    print()
    if direction in exits[loc]:
        loc = exits[loc][direction]
    else:
        print("You cannot go in that direction.")
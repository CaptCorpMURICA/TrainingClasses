"""
    Author:         CaptCorpMURICA
    Project:        DictionariesAndSets
    File:           dictionaries.py
    Creation Date:  12/5/2017, 3:38 PM
    Description:    Overview of dictionaries in Python
"""

# Dictionaries are accessed by using a key.
fruit = {"orange": "a sweet, orange, citrus fruit",
         "apple": "good for making cider",
         "lemon": "a sour, yellow citrus fruit",
         "grape": "a small, sweet fruit growing in bunches",
         "lime": "a sour, green citrus fruit"}

print(fruit)
print(fruit["lemon"])

# Add additional entries to the dictionary
fruit["pear"] = "an odd shaped apple"
print(fruit)

# If assign a value to existing key, replaces existing entry.
fruit["lime"] = "great with tequila"
print(fruit)

# Remove item from dictionary
del fruit["lemon"]
print(fruit)

# # Removes entire dictionary
# del fruit
# print(fruit)

# # Clears contents of entire dictionary
# fruit.clear()
# print(fruit)

# # Receive error if key is not in directory
# print(fruit["tomato"])

while True:
    dict_key = input("Please enter a fruit: ")
    if dict_key == "quit":
        print("Game over quitter.")
        break
    if dict_key == '':
        print("You did not enter a value. Try again.")
    elif dict_key in fruit:
        description = fruit.get(dict_key.lower())
        print("{}: {}.".format(dict_key, description))
    else:
        print("You did not enter a known or valid fruit.")

print("=" * 50)

while True:
    dict_key = input("Please enter a fruit: ")
    if dict_key == "quit":
        print("Game over quitter.")
        break
    if dict_key == "":
        print("You did not enter anything.")
    else:
        description = fruit.get(dict_key.lower(), "We don't have " + dict_key)
        print("{}: {}.".format(dict_key, description))

print("=" * 50)

# Can iterate over the terms in a dictionary
# No guarantee dictionary will appear in the same order
for snack in fruit:
    print(fruit[snack])

print("=" * 50)

for i in range(10):
    for snack in fruit:
        print(snack + " is " + fruit[snack])
    print("-" * 50)

print("=" * 50)

fruit["lemon"] = "a sour, yellow citrus fruit"

for i in range(10):
    for snack in fruit:
        print(snack + " is " + fruit[snack])
    print("-" * 50)

print("=" * 50)

# ordered_keys = list(fruit.keys())
# ordered_keys.sort()

# ordered_keys = sorted(list(fruit.keys()))
# for f in ordered_keys:
#     print(f + " - " + fruit[f])

for f in sorted(fruit.keys()):
    print(f + " = " + fruit[f])

print("=" * 50)

# Less efficient, but possible to iterate over the values only
for val in fruit.values():
    print(val)

print("-" * 50)

# Much more efficient
for key in fruit:
    print(fruit[key])

print("=" * 50)

print(fruit.keys())
print(fruit.values())

print("=" * 50)

fruit_keys = fruit.keys()
print(fruit_keys)

fruit["tomato"] = "not nice with ice cream"
print(fruit_keys)

print("=" * 50)

print(fruit)
print(fruit.items())

print("-" * 10)

# Create a tuple from a dictionary
f_tuple = tuple(fruit.items())
print(f_tuple)

print("-" * 10)

for snack in f_tuple:
    item, description = snack
    print(item + " is " + description)

print("=" * 50)

# Create a dictionary from a tuple
print(dict(f_tuple))

print("=" * 50)

"""
    Author:         CaptCorpMURICA
    File:           shelveExample.py
    Creation Date:  11/2/2018, 1:11 PM
    Description:    Learn about the shelve module for storing large amounts of data with key/value pairs.
"""

# URGENT: Loading a shelve file can execute code just like pickles.

# Shelve object requires a string for a key. A dictionary can accept any immutable object as a key.

import shelve

with shelve.open('ShelfTest') as fruit:
    fruit['orange'] = 'a sweet, orange, citrus fruit'
    fruit['apple'] = 'good for making cider'
    fruit['lemon'] = 'a sour, yellow citrus fruit'
    fruit['grape'] = 'a small, sweet fruit growing in bunches'
    fruit['lime'] = 'a sour, green cirtus fruit'

    print(fruit['lemon'])
    print(fruit['grape'])

print(fruit)

print("=" * 50)

# Keep shelf open. Requires the shelf to be closed manually.
fruit = shelve.open('ShelfTest')
fruit['orange'] = 'a sweet, orange, citrus fruit'
fruit['apple'] = 'good for making cider'
fruit['lemon'] = 'a sour, yellow citrus fruit'
fruit['grape'] = 'a small, sweet fruit growing in bunches'
fruit['lime'] = 'a sour, green citrus fruit'

print(fruit['lemon'])
print(fruit['grape'])
print(fruit['lime'])

print("-" * 40)

# Assign a new value to a key
fruit['lime'] = 'great with tequila'

for snack in fruit:
    print(snack + ': ' + fruit[snack])

print("=" * 50)

while True:
    shelf_key = input("Please enter a fruit: ")
    if shelf_key.lower() == "quit":
        break

    description = fruit.get(shelf_key, "We don't have a " + shelf_key)
    print(description)

print("-" * 40)

# Alternative method
while True:
    dict_key = input("Please enter a fruit: ")
    if dict_key.lower() == "quit":
        break

    if dict_key in fruit:
        description = fruit[dict_key]
        print(description)
    else:
        print("We don't have a " + dict_key)

print("=" * 50)

# Keys are unsorted and order is undefined
for f in fruit:
    print(f + " - " + fruit[f])

print("-" * 40)

# Create sorted list first
ordered_keys = list(fruit.keys())
ordered_keys.sort()

for f in ordered_keys:
    print(f + " - " + fruit[f])

print("=" * 50)

# Return values and items stored in the shelf
for v in fruit.values():
    print(v)

print("-" * 40)

print(fruit.values())

print("-" * 40)

for f in fruit.items():
    print(f)

print("-" * 40)

print(fruit.items())

# Shelf needs to be closed
fruit.close()

print("=" * 50)

print(fruit)

print("=" * 50)

books = shelve.open("book")
books["recipes"] = {"blt": ["bacon", "lettuce", "tomato", "bread"],
                    "beans_on_toast": ["beans", "bread"],
                    "scrambled_eggs": ["eggs", "butter", "milk"],
                    "soup": ["tin of soup"],
                    "pasta": ["pasta", "cheese"]}
books["maintenance"] = {"stuck": ["oil"],
                        "loose": ["gaffer tape"]}

print(books["recipes"]["soup"])
print(books["recipes"]["scrambled_eggs"])
print(books["maintenance"]["loose"])

books.close()

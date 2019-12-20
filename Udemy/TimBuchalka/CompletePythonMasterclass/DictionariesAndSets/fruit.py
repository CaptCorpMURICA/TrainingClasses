"""
    Author:         CaptCorpMURICA
    File:           fruit.py
    Creation Date:  1/8/2018, 12:31 PM
    Description:    More methods using dictionaries
"""

fruit = {"orange": "a sweet, orange, citrus fruit",
         "apple": "good for making cider",
         "lemon": "a sour, yellow citrus fruit",
         "grape": "a small, sweet fruit growing in bunches",
         "lime": "a sour, green citrus fruit"}

print(fruit)

veg = {"cabbage": "every child's favorite",
       "sprouts": "mmmmm, lovely",
       "spinach": "can I have more fruit, please"}

print(veg)

# Combine two dictionaries together
veg.update(fruit)

print(veg)

print(fruit.update(veg)) # Method does not return anything (No new object created)
print(fruit)

print("=" * 50)

# Create a new dictionary with two dictionaries, use the copy method
fruit = {"orange": "a sweet, orange, citrus fruit",
         "apple": "good for making cider",
         "lemon": "a sour, yellow citrus fruit",
         "grape": "a small, sweet fruit growing in bunches",
         "lime": "a sour, green citrus fruit"}

veg = {"cabbage": "every child's favorite",
       "sprouts": "mmmmm, lovely",
       "spinach": "can I have more fruit, please"}

nice_and_nasty = fruit.copy()
nice_and_nasty.update(veg)
print(nice_and_nasty)
print(veg)
print(fruit)
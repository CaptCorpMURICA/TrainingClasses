"""
    Author:         CaptCorpMURICA
    File:           shelveUpdating.py
    Creation Date:  11/2/2018, 3:20 PM
    Description:    Updating with Shelve
"""

import shelve

blt = ["bacon", "lettuce", "tomato", "bread"]
beans_on_toast = ["beans", "bread"]
scrambled_eggs = ["eggs", "butter", "milk"]
soup = ["tin of soup"]
pasta = ["pasta", "cheese"]

with shelve.open('recipes') as recipes:
    recipes["blt"] = blt
    recipes["beans_on_toast"] = beans_on_toast
    recipes["scrambled_eggs"] = scrambled_eggs
    recipes["pasta"] = pasta
    recipes["soup"] = soup

    for snack in recipes:
        print(snack, recipes[snack])

    print("=" * 50)

    # Append to a copy, but need to execute code to update the shelve.
    recipes["blt"].append("butter")
    recipes["pasta"].append("tomato")

    for snack in recipes:
        print(snack, recipes[snack])

    print("=" * 50)

    # Solution 1
    # Update existing items in the shelve
    temp_list = recipes["blt"]
    temp_list.append("butter")
    recipes["blt"] = temp_list

    temp_list = recipes["pasta"]
    temp_list.append("tomato")
    recipes["pasta"] = temp_list

    for snack in recipes:
        print(snack, recipes[snack])

    print("=" * 50)

# Solution 2
# Perform a write back method - simpler, but heavier memory usage.
with shelve.open('recipes', writeback=True) as recipes:
    recipes["blt"] = blt
    recipes["beans_on_toast"] = beans_on_toast
    recipes["scrambled_eggs"] = scrambled_eggs
    recipes["pasta"] = pasta
    recipes["soup"] = soup

    recipes["soup"].append("croutons")

    for snack in recipes:
        print(snack, recipes[snack])

print("=" * 50)

# May want to update a shelf immediately after writing - using the sync() method
# This updates the objects in the wrong order, so it is not advisable to update objects using sync().
# Better to store data in database rather than shelves.
with shelve.open('recipes', writeback=True) as recipes:
    recipes["blt"] = blt
    recipes["beans_on_toast"] = beans_on_toast
    recipes["scrambled_eggs"] = scrambled_eggs
    recipes["pasta"] = pasta
    recipes["soup"] = soup
    recipes.sync()
    soup.append("cream")

    for snack in recipes:
        print(snack, recipes[snack])

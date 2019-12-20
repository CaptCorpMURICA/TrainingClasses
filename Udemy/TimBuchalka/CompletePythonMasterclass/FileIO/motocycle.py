"""
    Author:         CaptCorpMURICA
    File:           motocycle.py
    Creation Date:  11/2/2018, 1:23 PM
    Description:    Example of shelve nuances.
"""

import shelve

with shelve.open("bike") as bike:
    bike["make"] = "Honda"
    bike["model"] = "250 Dream"
    bike["color"] = "Red"
    bike["engine_size"] = 250

    print(bike["engine_size"])
    print(bike["color"])

print("=" * 50)

# Shelves are persistent. Correcting the typo does not remove the error from the database.
with shelve.open("bike2") as bike:
    # bike["make"] = "Honda"
    # bike["model"] = "250 Dream"
    # bike["color"] = "Red"
    # bike["engin_size"] = 250
    for key in bike:
        print(key)

    print("-" * 40)

    print(bike["engine_size"])
    print(bike["engin_size"])
    print(bike["color"])

    print("-" * 40)

    # Use the del key to remove items from the shelf
    del bike["engin_size"]

    for key in bike:
        print(key)

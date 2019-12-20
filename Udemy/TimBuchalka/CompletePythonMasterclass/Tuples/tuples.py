"""
    Author:         CaptCorpMURICA
    Project:        Tuples
    File:           tuples.py
    Creation Date:  12/4/2017, 3:45 PM
    Description:    Basics of Tuples in Python
"""

# Unlike lists, the content of a Tuple cannot be changed.
t = "a", "b", "c" # A Tuple
print(t)

print("a", "b", "c") # Not a Tuple
print(("a", "b", "c")) # A Tuple

print("=" * 50)

welcome = "Welcome to my Nightmare", "Alice Cooper", 1975
bad = "Bad Company", "Bad Company", 1974
budgie = "Nightflight", "Budgie", 1981
imelda = "More Mayhem", "Imelda May", 2011
metallica = "Ride the Lightning", "Metallica", 1984

print(metallica)
print(metallica[0])
print(metallica[1])
print(metallica[2])

print("=" * 50)

# metallica[0] = "Master of Puppets" provides an error because tuples cannot change value,
# but can replace in new object. Below is how lists handle correcting items.
metallica2 = ["Ride the Lightning", "Metallica", 1984]
print(metallica2)
metallica2[0] = "Master of Puppets"
print(metallica2)

print("=" * 50)

# Cannot change the spelling error in imelda.
# However can assign a new value using slicing.
print(imelda)
imelda = imelda[0], "Imelda May", imelda[2]
print(imelda)

# Tuples are excellent to use when items that could be stored in a list should not be able to be changed (Album info).
# It adds a new level of security to ensure information that shouldn't change, doesn't.

print("=" * 50)

# Can pull out the elements of a tuple in a single assignment (Unpacking the Tuple)
imelda = "More Mayhem", "Imelda May", 2011
title, artist, year = imelda
print("Title: {}".format(title))
print("Artist: {}".format(artist))
print("Year: {}".format(year))
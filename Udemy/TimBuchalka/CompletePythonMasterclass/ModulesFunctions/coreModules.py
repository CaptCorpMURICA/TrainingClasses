"""
    Author:         CaptCorpMURICA
    File:           coreModules.py
    Creation Date:  11/12/2018, 2:32 PM
    Description:    Explore modules automatically imported as part of the base Python language
"""

# dir(): display the directory information where the file is located
print(dir())

print("=" * 50)

# '__builtins__' is the list of built-in functions
for m in dir(__builtins__):
    print(m)

print("=" * 50)

import shelve
print(dir())
print("-" * 40)
print(dir(shelve))

print("=" * 50)

for obj in dir(shelve.Shelf):
    if obj[0] != '_':
        print(obj)

# Can examine source code by holding Command and clicking on the function.
# shelve.Shelf

# Print module reference information with link to documentation
help(shelve)

import random

help(random.randint)

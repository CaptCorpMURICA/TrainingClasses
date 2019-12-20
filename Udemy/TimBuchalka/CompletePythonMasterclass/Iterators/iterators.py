"""
    Author:         CaptCorpMURICA
    Project:        Iterators
    File:           iterators.py
    Creation Date:  12/4/2017, 1:48 PM
    Description:    Overview of iterators in Python
"""

string = "1234567890"

for char in string:
    print(char)

print("===================")

my_iterator = iter(string)
print(my_iterator)
print(next(my_iterator))
print(next(my_iterator))
print(next(my_iterator))
print(next(my_iterator))
print(next(my_iterator))
print(next(my_iterator))
print(next(my_iterator))
print(next(my_iterator))
print(next(my_iterator))
print(next(my_iterator))

print("===================")

for char in iter(string):
    print(char)
"""
    Author:         CaptCorpMURICA
    Project:        Tuples
    File:           demo.py
    Creation Date:  12/4/2017, 4:07 PM
    Description:    Assignment demo in Python
"""
# All four variables are assigned the same value.
a = b = c = d = 12
print(a, b, c, d)

# Can assign different values in a single line.
a, b = 12, 13
print(a, b)

# Right hand side is evaluated first.
a, b = 12, 13
a, b = b, a # a, b = 13, 12
print("a is {}".format(a))
print("b is {}".format(b))
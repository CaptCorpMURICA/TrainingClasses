"""
    Author:         CaptCorpMURICA
    Project:        NumberSystems
    File:           hexadecimal.py
    Creation Date:  12/5/2017, 1:53 PM
    Description:    Understand how Hexadecimal notation differs from binary.
"""

# How to read hexadecimal
# Python uses x to signify hexadecimal (not h)
for i in range(257):
    print("{0:>3} in hex is {0:>02x}".format(i))

x = 0x20
y = 0x0a

print(x)
print(y)
print(x * y)

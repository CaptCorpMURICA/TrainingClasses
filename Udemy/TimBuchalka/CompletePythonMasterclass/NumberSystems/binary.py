"""
    Author:         CaptCorpMURICA
    Project:        Binary
    File:           binary.py
    Creation Date:  12/5/2017, 1:38 PM
    Description:    Understand binary computations to fully grasp Python's memory allocation capabilities.
"""

# How to read binary (base 2)
# Decimal is base 10
# Octal is base 8 (used for linux permissions)
# Python uses b to signify binary
for i in range(257):
    print("{0:>3} in binary is {0:>09b}".format(i))

print(0b00101010)

# Leading zeros are not required for binary
print(0b101010)
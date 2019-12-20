"""
    Author:         CaptCorpMURICA
    Project:        Tabs
    File:           tabs.py
    Creation Date:  11/30/2017, 11:01 AM
    Description:    Understand how indentation works with Python
"""

# A block is a piece of Python program text that is executed as a unit.

# Python does not use delimiters to identify a block of code; it uses tabs
for i in range(1, 12):
    print("No. {:2} squared is {:4} and cubed is {:4}.".format(i, i ** 2, i ** 4))
    print("Calculation Complete")
    print("Try Again")
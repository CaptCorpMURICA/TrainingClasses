"""
    Author:         CaptCorpMURICA
    Project:        StringFormatting
    File:           stringFormatting.py
    Creation Date:  11/29/2017, 5:12 PM
    Description:    Understand different functions that can be completed on strings.
"""

# Convert information in the parentheses to a string
age = 24
print("My age is " + str(age) + " years.")

# Replacement field
# Number in curly brackets is an index based on the data to replace
print("My age is {0} years.".format(age))
print("There are {0} days in {1}, {2}, {3}, {4}, {5}, {6}, and {7}.".format(31, "January", "March", "May", "July", "August", "October", "December"))
print("""January: {2}
February: {0}
March: {2}
April: {1}
May: {2}
June: {1}
July: {2}
August: {2}
September: {1}
October: {2}
November: {1}
December: {2}""".format(28,30,31))

# Replacement: Can replace one field at a time
# Depreciated Script. This only works for Python 2.
# %d is to replace a numeric value
# %s is to replace a string value
print("My age is %d years." % age)
print("My age is %d %s, %d, %s" % (age, "years", 6, "months"))

# %2d is to allocate two spaces for the numeric replacement
for i in range(1, 12):
    print("No. %2d squared is %4d and cubed is %4d." % (i, i ** 2, i ** 3))

# %12.50f is signifies the precision.
# There will be 12 digits of precision to the left of the period.
# There will be 50 digits of precision to the right of the period.
print("Pi is approximately %12f" % (22 / 7))
print("Pi is approximately %12.50f" % (22 / 7))


# How to do replacement field syntax in Python 3
# Provides the same value as old syntax
# {Position:Width}
for i in range(1, 12):
    print("No. {0:2} squared is {1:4} and cubed is {2:4}.".format(i, i ** 2, i ** 3))

# Use < before Width to left justify the value.
for i in range(1, 12):
    print("No. {0:2} squared is {1:<4} and cubed is {2:<4}.".format(i, i ** 2, i ** 3))

# Pi example in new format
print("Pi is approximately {0:12.50}".format(22 / 7))

# Numerical designations are not required to work and can still add formatting requirements.
# The numerical designations are required if using the reference multiple times in the string.
for i in range(1, 12):
    print("No. {} squared is {} and cubed is {:4}.".format(i, i ** 2, i ** 3))
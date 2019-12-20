"""
    Author:         CaptCorpMURICA
    Project:        IntroToLists
    File:           lists.py
    Creation Date:  12/4/2017, 1:11 PM
    Description:    Introduction to Lists in Python
"""
# Using the count function
ipAddress = input("Please enter an IP address: ")
print("The number of periods in the IP address is {}.".format(ipAddress.count(".")))

print("==============")

# Add an additional entry to a list
parrot_list = ["non pinin'", "no more", "a stiff", "bereft of life"]

parrot_list.append("A Norwegian Blue")
for state in parrot_list:
    print("This parrot is " + state)

print("==============")

# Concatenate two lists
even = [2, 4, 6, 8]
odd = [1, 3, 5, 7, 9]

numbers = even + odd
print(numbers) # Unsorted
print(sorted(numbers)) # Sorted
numbers.sort()
print(numbers) # Sorted

numbers_in_order = sorted(numbers)
print(numbers_in_order)
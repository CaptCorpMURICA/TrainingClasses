"""
    Author:         CaptCorpMURICA
    Project:        IntroToLists
    File:           moreAboutLists.py
    Creation Date:  12/4/2017, 1:24 PM
    Description:    Lists tutorial continued on clean file
"""
# Two methods for creating empty lists.
list_1 = []
list_2 = list()

print("List 1: {}".format(list_1))
print("List 2: {}".format(list_2))

if list_1 == list_2:
    print("The lists are equal.")

print("===============")

# List() creates a list where each character is a separate entry in the list.
print(list("The lists are equal."))

print("===============")

# Since variable another_even is built off the list even. Both variables are sorted and treated as the same variable.
# In order to create a new version, a function needs to be called on the original list when creating the new one.
even = [2, 4, 6, 8]

another_even = even

print(another_even is even) # Prints true if the two variables are considered the same

another_even.sort(reverse=True)
print(even)
print(another_even)

print("-------------")

even = [2, 4, 6, 8]

another_even2 = list(even)

print(another_even2 is even) # Prints true if the two variables are considered the same

another_even2.sort(reverse=True)
print(even)
print(another_even2)

print("-------------")

even = [2, 4, 6, 8]

another_even3 = sorted(even, reverse=True)

print(another_even3 is even) # Prints true if the two variables are considered the same

print(even)
print(another_even3)

print("===============")

even = [2, 4, 6, 8]
odd = [1, 3, 5, 7, 9]

numbers = [even, odd]
print(numbers)

for number_set in numbers:
    print(number_set)

    for value in number_set:
        print(value)

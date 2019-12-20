"""
    Author:         CaptCorpMURICA
    Project:        Iterators
    File:           iteratorChallenge.py
    Creation Date:  12/4/2017, 2:06 PM
    Description:    Create a list of items (you may use either strings or numbers in the list),
                    then create an iterator using the iter() function.

                    Use a FOR loop "n" times, where n is the number of items in your list.
                    Each time round the loop, use next() on your list to print the next item.

                    Hint: Use the len() function rather than counting the number of items in the list.
"""

spam = ["spam", "spam", "spam", "spam", "spam", "bacon", "spam"]
spam_iterator = iter(spam)

i = 0
for n in range(0, len(spam)):
    ingredient = next(spam_iterator)
    print("Ingredient {}: {}".format(i, ingredient))
    i += 1

print("=============")

# His solution
my_list = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]

my_iterator = iter(my_list)

for i in range(0, len(my_list)):
    next_item = next(my_iterator)
    print(next_item)
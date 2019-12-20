"""
    Author:         CaptCorpMURICA
    Project:        IntroToLists
    File:           listsChallenge.py
    Creation Date:  12/4/2017, 1:42 PM
    Description:    Add to the program below so that if it finds a meal with spam
                    it prints out each of the ingredients of the meal.
                    You will need to set up the menu as we did in lines 11-19.
"""

menu = []
menu.append(["egg", "spam", "bacon"])
menu.append(["egg", "sausage", "bacon"])
menu.append(["egg", "spam"])
menu.append(["egg", "bacon", "spam"])
menu.append(["egg", "bacon", "sausage", "spam"])
menu.append(["spam", "bacon", "sausage", "spam"])
menu.append(["spam", "egg", "spam", "spam", "bacon", "spam"])
menu.append(["spam", "egg", "sausage", "spam"])

for meal in menu:
    if not "spam" in meal:
        i = 0
        while i < len(meal):
            print("Ingredient {0}: {1}".format(i, meal[i]))
            i += 1
        else:
            print("End of meal.")


print("===================")

# His solution
for meal in menu:
    if not "spam" in meal:
        print(meal)
        for ingredient in meal:
            print(ingredient)
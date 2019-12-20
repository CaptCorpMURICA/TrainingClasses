"""
    Author:         CaptCorpMURICA
    Project:        ContinueBreakElse
    File:           continueBreak.py
    Creation Date:  12/1/2017, 1:35 PM
    Description:    How to implement a Continue and Break into your Python program
                    Use CONTINUE to advance to next iterator in loop.
                    Use BREAK to end current code block and advance to next code block.
                    CONTINUE and BREAK are used to improve processing efficiency.
"""

# Use CONTINUE to stop processing the block when TRUE and move to the next iterator
shopping_list = ["milk", "pasta", "eggs", "spam", "bread", "rice"]
for item in shopping_list:
    if item.lower() == "spam":
        print("I will never buy {}.".format(item))
        continue
    print("You need to buy {}.".format(item))

print("===============")

# Use BREAK to stop the loop completely when TRUE
shopping_list = ["milk", "pasta", "eggs", "spam", "bread", "rice"]
for item in shopping_list:
    if item.lower() == "spam":
        print("I will never buy {}.".format(item))
        print("I'm done here.")
        break
    print("You need to buy {}.".format(item))

print("===============")

# Use a BREAK to end a search program once match is found. Improves efficiency.
meal = ["egg", "bacon", "spam", "sausages"]
nasty_food_item = ""

for item in meal:
    if item.lower() == "spam":
        nasty_food_item = item
        break

if nasty_food_item:
    print("Can't I have anything without spam in it?")

print("===============")

# Else for loops is executed only when the loop runs to the end. No breaks allowed.
meal = ["egg", "bacon", "pancakes", "sausages"]
nasty_food_item = ""

for item in meal:
    if item.lower() == "spam":
        nasty_food_item = item
        break
else:
    print("I'll have a plate of that, then, please.")

if nasty_food_item:
    print("Can't I have anything without spam in it?")

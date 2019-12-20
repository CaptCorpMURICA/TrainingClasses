"""
    Author:         CaptCorpMURICA
    Project:        While
    File:           whileLoops.py
    Creation Date:  12/4/2017, 11:23 AM
    Description:    While Loops in Python
"""

for i in range(10):
    print("i is now {}".format(i))

print("===============")

i = 0
while i < 10:
    print("i is now {}".format(i))
    i += 1

print("===============")

available_exits = ["east", "north east", "south"]

chosen_exit = ""
while chosen_exit.lower() not in available_exits:
    chosen_exit = input("Please choose a direction: ")

print("Aren't you glad you got out of there?")

print("===============")

available_exits = ["east", "north east", "south"]

chosen_exit = ""
while chosen_exit.lower() not in available_exits:
    chosen_exit = input("Please choose a direction: ")
    if chosen_exit.lower() == "quit":
        print("Game Over Quitter")
        break
else:
    print("Aren't you glad you got out of there?")

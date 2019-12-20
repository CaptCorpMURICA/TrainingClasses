"""
    Author:         CaptCorpMURICA
    Project:        IfThenElseChallenge
    File:           ifChallenge.py
    Creation Date:  11/30/2017, 1:45 PM
    Description:    Write a small program to ask for a name and an age.
                    When both values have been entered, check if the person
                    is the right age to go on an 18-30 holiday (they must be
                    over 18 and under 31).
                    If they are, welcome them to the holiday, otherwise print
                    a (polite) message refusing them entry.
"""

name = input("What is your name? ")
age = int(input("What is your age, {0}? ".format(name)))

if 18 <= age <= 30:
    print("Welcome to the booze cruise, {0}. Make some terrible decisions.".format(name))
elif age < 18:
    print("You are too young to enjoy this fun, {0}. Come back in {1} years.".format(name, 18 - age))
else:
    print("""You are too old to enjoy this fun Grampa {0}. Isn't Murder She Wrote on right now?.""".format(name))


# His solution
name = input("Please enter your name: ")
age = int(input("How old are you , {0}? ".format(name)))

# if 18 <= age < 31:
if age >= 18 and age < 31:
    print("Welcome to club 18-30 holidays, {0}".format(name))
else:
    print("I'm sorry, our holidays are only for seriously cool people.")
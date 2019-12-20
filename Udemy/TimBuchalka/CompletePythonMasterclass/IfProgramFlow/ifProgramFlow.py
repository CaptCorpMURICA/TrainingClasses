"""
    Author:         CaptCorpMURICA
    Project:        IfProgramFlow
    File:           ifProgramFlow.py
    Creation Date:  11/30/2017, 11:09 AM
    Description:    Understand If statements in Python
"""

# name = input("Please enter your name: ")
# age = int(input("How old are you, {0}? ".format(name)))
# print(name + " is " + str(age) + " years old.")
#
# if age >= 18:
#     print("You are old enough to vote.")
#     print("Please put an X in the box.")
# elif (18 - age) == 1:
#     print(name + ", please come back in {0} year to be old enough to vote.".format(18 - age))
# else:
#     print(name + ", please come back in {0} years to be old enough to vote.".format(18 - age))


# Nested If statements
# print("Please guess a number between 1 and 10: ")
# guess = int(input())
#
# if guess < 5:
#     print("Please guess higher.")
#     guess = int(input())
#     if guess == 5:
#         print("Well done, you guessed it.")
#     else:
#         print("Sorry, you have not guessed correctly.")
# elif guess > 5:
#     print("Please guess lower.")
#     guess = int(input())
#     if guess == 5:
#         print("Well done, you guessed it.")
#     else:
#         print("Sorry, you have not guessed correctly.")
# else:
#     print("You got it the first time. Congratulations.")
#
# # Code would be better using a combination of a For/While loop and If statements
# # User has 3 chances to select the correct answer.
# # If correct, loop exits and number of tries is printed with the message.
#
# if guess != 5:
#     if guess < 5:
#         print("Please guess higher.")
#     else: # Guess must be greater than 5
#         print("Please guess lower.")
#
#     guess = int(input())
#     if guess == 5:
#         print("Well done, you guessed it.")
#     else:
#         print("Sorry, you have not guessed correctly.")
# else:
#     print("You got it the first time. Congratulations.")

# Using AND/OR operators in an IF statement
# age = int(input("How old are you? "))
#
# # if age >= 16 and age <= 65:
# # if (age >= 16) and (age <= 65):
# # if 16 <= age <= 65:
# # if 15 < age < 66:
# #     print("Have a good day at work.")
#
# if (age < 16) or (age > 65):
#     print("Enjoy your free time.")
# else:
#     print("Have a good day at work.")

# # Python does not have a boolean data type
# # True is 1 and False is 0
# # In a condition, any non-integer value is identified as True
# x = "false"
# if x:
#     print("x is true")
# else:
#     print("x is false")

# # Show the output of various inputs to bool() function
# print("""False: {0}
# None: {1}
# 0: {2}
# 0.0: {3}
# empty list []: {4}
# empty tuple (): {5}
# empty string '': {6}
# empty string "": {7}
# empty mapping {{}}: {8}
# """.format(False, bool(None), bool(0), bool(0.0), bool([]), bool(()), bool(''), bool(""), bool({})))

# x = False
# if x:
#     print("x is true")
# else:
#     print("x is false")

# x = input("Please enter some text: ")
# if x:
#     print("You entered '{}'".format(x))
# else:
#     print("You did not enter anything.")

# # You can use the NOT keyword to do the opposite of a condition
# print(not False)
# print(not True)

# age = int(input("How old are you? "))
# if not(age < 18):
#     print("You are old enough to vote.")
#     print("Please put an X in the box.")
# else:
#     print("Please come back in {0} years.".format(18 - age))

# Using the IN operator
parrot = "Norwegian Blue"
letter = input("Enter a character: ")

# if bool(letter) == False:
#     print("You did not enter a letter. Try again.")
# elif letter.lower() in parrot.lower():
#     print("Give me an {}, Bob.".format(letter))
# else:
#     print("I don't need that letter.")

# Using the NOT operator in conjunction with the IN operator
if letter not in parrot:
    print("I don't need that letter.")
else:
    print("Give me an {}, Bob.".format(letter))
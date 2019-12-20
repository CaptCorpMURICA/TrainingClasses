"""
    Author:         CaptCorpMURICA
    Project:        While
    File:           whileChallenge.py
    Creation Date:  12/4/2017, 12:40 PM
    Description:    Create number guessing game with unlimited guessing options.
"""
import random

highest = int(input("What is the upper bound for the game? "))
answer = random.randint(1, highest)

print("Please guess a number between 1 and {}: ".format(highest))
guess = int(input())
while guess != answer:
    if guess == 0:
        print("Game Over Quitter")
        break
    elif guess < answer:
        print("Please guess higher.")
        print("Enter zero to quit.")
        guess = int(input())
    else:
        print("Please guess lower.")
        print("Enter zero to quit.")
        guess = int(input())
else:
    print("Well done, you guessed the number correctly ({}).".format(answer))

print("==================")

# His solution
import random

highest = 10
answer = random.randint(1, highest)

print("Please guess a number between 1 and {}: ".format(highest))
guess = 0 # initialize to any number outside of the valid range.
while guess != answer:
    guess = int(input())
    if guess < answer:
        print("Please guess higher")
    elif guess > answer:
        print("Please guess lower")
    else:
        print("Well done, you guessed it")
"""
    Author:         CaptCorpMURICA
    Project:        TrainingClasses
    File:           program.py
    Creation Date:  12/23/19, 4:26 PM
    Description:    Guess a number between 0 and 100. The user guesses the value and the program provides feedback for
                    subsequent guesses.
"""

import random

print('---------------------------------')
print('     GUESS THAT NUMBER GAME')
print('---------------------------------')
print()

the_number = random.randint(0, 100)
guess = -1

name = input('Player, what is your name? ')

while guess != the_number:
    guess_text = input('Guess a number between 0 and 100: ')
    guess = int(guess_text)

    if guess < the_number:
        print(f'Sorry {name}, your guess, {guess}, is LOWER than the number.')
    elif guess > the_number:
        print(f'Sorry {name}, your guess, {guess}, is HIGHER than the number.')
    else:
        print(f'Excellent work {name}, you won. The number was {guess}.')

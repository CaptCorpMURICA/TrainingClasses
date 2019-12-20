"""
    Author:         CaptCorpMURICA
    File:           setsChallenge.py
    Creation Date:  1/8/2018, 4:09 PM
    Description:    Create a program that takes some text and returns a list of
                    all the characters in teh text that are not vowels, sorted in
                    alphabetical order.

                    You can either enter the text from the keyboard or
                    initialize a string variable with the string.
"""

text = input("Enter some text: ")

vowels = frozenset("aeiou")

finalSet = set(text).difference(vowels)
print(finalSet)

finalList = sorted(finalSet)
print(finalList)

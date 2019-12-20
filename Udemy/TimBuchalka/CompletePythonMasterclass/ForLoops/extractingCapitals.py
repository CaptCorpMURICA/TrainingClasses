"""
    Author:         CaptCorpMURICA
    File:           extractingCapitals.py
    Creation Date:  10/2/2018, 11:14 AM
    Description:    Write a program to print out the capital letters in the string
                    "Alright, but apart from the Sanitation, the Medicine, Education, Wine, Public Order, Irrigation,
                    Roads, the Fresh-Water System, and Public Health, what have the Romans ever done for us?"
"""

quote = """
Alright, but apart from the Sanitation, the Medicine, Education, Wine,
Public Order, Irrigation, Roads, the Fresh-Water System,
and Public Health, what have the Romans ever done for us?
"""

# Use a for loop and an if statement to print just the capitals in the quote above.
for i in range(0, len(quote)):
    if quote[i].lower() in 'abcdefghijklmnopqrstuvwxyz' and quote[i] == quote[i].upper():
        print(quote[i])

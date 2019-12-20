"""
    Author:         CaptCorpMURICA
    File:           simpleCondition.py
    Creation Date:  10/2/2018, 11:02 AM
    Description:    Write a small program that assigns the value 5 to one variable, called `x`, and the values 7 to
                    another, called `y`.
                    Your program should then use an `if` statement to compare the values, and print out `x is greater
                    than y` if x is greater, or `x is smaller than y` if y is greater. If x equals y, print out `x
                    equals y`.
                    I know you don't really need a computer to tell you the result, but we're getting practice at
                    writing `if/elif/else` statements.
                    Once your program is working, copy and paste it into a new file in your IDE, and test it with
                    different values for `x` and `y`.
                    This coding system is looking for the output when x is 5 and y is 7, so you can't use this to test
                    other values. Pasting the code into your usual IDE will let you do that.
"""

x = 5
y = 7

if x > y:
    print('x is greater than y')
elif x < y:
    print('x is smaller than y')
else:
    print('x equals y')

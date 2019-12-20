"""
    Author:         CaptCorpMURICA
    File:           break.py
    Creation Date:  10/2/2018, 11:49 AM
    Description:    Modify the code so that it stops printing when it reaches a number that's exactly divisible by 11.
                    That number should be the last value printed.
                    Reminder: If a value, x, is divisible by 11 then `x % 11` will be zero.
                    Hint: 0 is exactly divisible by every number, so your solution will need to allow for that.
"""

# Modify this loop to stop when i is exactly divisible by 11
for i in range(0, 100, 7):
    print(i)
    if i > 0 and i % 11 == 0:
        break

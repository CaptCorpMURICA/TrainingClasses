"""
    Author:         CaptCorpMURICA
    File:           integerDivision.py
    Creation Date:  10/2/2018, 10:34 AM
    Description:    You have a shop selling buns for @2.40 each. A customer comes in with $15, and would like to buy as
                    many buns as possible.
                    Complete the code to calculate how many buns the customer can afford.
                    Note: Your customer won't be happy if you try to sell them part of a bun.

                    Print only the result, any other text in the output will cause the checker to fail.
"""

bun_price = 2.40
money = 15

print(money // bun_price)
"""
    Author:         CaptCorpMURICA
    Project:        Ranges
    File:           moreAboutRanges.py
    Creation Date:  12/4/2017, 2:34 PM
    Description:    Deeper dive into ranges in Python
"""

decimals = range(0, 100)
my_range = decimals[3:40:3]
print(my_range == range(3, 40, 3))

print("=" * 50)

# End point of range is not inclusive
print(range(0, 5, 2) == range(0, 6, 2))
print(list(range(0, 5, 2)))
print(list(range(0, 6, 2)))

print("=" * 50)

r = range(0, 100)
print(r)

print("=" * 50)

for i in r[::-2]:
    print(i)

print("=" * 50)

for i in range(99, 0, -2):
    print(i)

print("=" * 50)

print(range(0, 100)[::-2] == range(99, 0, -2))

# Does not provide an output because range starts at 0 and tries to reduce by two each iteration until 100.
# This is not possible, so the for loop does not run.
for i in range(0, 100, -2):
    print(i)

print("=" * 50)

backString = "egaugnal lufrewop yrev a si nohtyP"
print(backString[::-1])

print("=" * 50)

r = range(0, 10)
for i in r[::-1]:
    print(i)

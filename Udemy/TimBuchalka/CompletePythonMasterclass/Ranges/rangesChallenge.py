"""
    Author:         CaptCorpMURICA
    Project:        Ranges
    File:           rangesChallenge.py
    Creation Date:  12/4/2017, 2:42 PM
    Description:    Experiment with different ranges and slices to get a feel for how they work.
                    Remember that you can print the range as well as iterating through it to print
                    its values, to check that your ranges are what you expected.
                    You may also want to include things like:
                        o = range(0, 100, 4)
                        print(o)
                        p = o[::5]
                        print(p)
                        for i in p:
                            print(i)
                    and see if you can work out what will be printed before running the program. If you are unsure, use
                    a for loop to print out the values of o to see why p returns what it does.
"""

# By using the slice, the new range uses the value at that location as the new value.
# For example, location 2 in list o is 8. When the step is altered with the value 2, it is replaces with an 8.
# The new list now has a step value of 8.
o = range(0, 100, 4)
print(o)
for i in o:
    print(i)

print("=" * 50)

p = o[::5]
print(o[5])
print(p)
for i in p:
    print(i)

print("=" * 50)

q = o[::2]
print(o[2])
print(q)
for i in q:
    print(i)

print("=" * 50)

r = o[5::]
print(o[5])
print(r)
for i in r:
    print(i)

print("=" * 50)

s = o[:5:]
print(o[5])
print(s)
for i in s:
    print(i)
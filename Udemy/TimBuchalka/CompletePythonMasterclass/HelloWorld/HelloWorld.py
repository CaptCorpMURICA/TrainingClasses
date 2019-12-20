"""
    Author:         CaptCorpMURICA
    Project:        HelloWorld
    File:           HelloWorld
    Creation Date:  11/29/2017, 4:05 PM
    Description:    Depict the basics of Python and get used to the IntelliJ IDE
"""
    
print('Hello, World!')
print(1 + 2)
print(7 * 6)
print()
print("The End")
print("Python's strings are easy to use")
print('We can even include "quotes" in strings')
print("Hello" + " World!")
greeting = "Hello"
name = "Kevin"
print(greeting + name)
# if we want a space, we can add that too
print(greeting + ' ' + name)

# Receive input from the user to continue
name = input("Please enter your name: ")
print(greeting + ' ' + name)

# Split text over multiple lines
splitString = "This string has been\nsplit over\nseveral\nlines"
print(splitString)

# Split text with tabs
tabbedString = "1\t2\t3\t4\t5\t"
print(tabbedString)

print('The pet shop owner said "No, no, \'e\'s uh,...he\'s resting"')
print("The pet shop owner said \"No, no, 'e's uh,...he's resting\"")

# The triple quotes can be exceptionally useful
anotherSplitString = """This string has been
split over
several lines"""
print(anotherSplitString)

print('''The pet shop owner said "No, no, 'e's' uh,...he's resting"''')
print("""The pet shop owner said "No, no, 'e's' uh,...he's resting" """)
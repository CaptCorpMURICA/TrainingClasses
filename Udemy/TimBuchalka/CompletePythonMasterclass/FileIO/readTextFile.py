"""
    Author:         CaptCorpMURICA
    File:           readTextFile.py
    Creation Date:  1/8/2018, 4:17 PM
    Description:    Reading Text Files
"""

# Prints the line of the poem where Jabberwock is present
# Required method for Python 2.x
jabber = open("sample.txt", 'r')  # Open file in a read-only setting

for line in jabber:
    if "jabberwock" in line.lower():
        print(line, end='')

# Could cause the file to be corrupted if forget to close
jabber.close()

print("=" * 50)

# Improved method of opening and reading a file to reduce the risk of corruption
# With statement does not require the file to be closed.
with open("sample.txt", 'r') as jabber:
    for line in jabber:
        if "JAB" in line.upper():
            print(line, end='')

print("=" * 50)

# Using the readline() function
with open("sample.txt", 'r') as jabber:
    line = jabber.readline()
    while line:
        print(line, end='')
        line = jabber.readline()

print("=" * 50)

# Using the readlines() function to store the content as a list
# Hidden line terminating characters can be observed by printing the list.
with open("sample.txt", 'r') as jabber:
    lines = jabber.readlines()
print(lines)

print("-" * 25)

for line in lines:
    print(line, end='')

print("=" * 50)

# Iterating the list through a reverse slice by lines
with open("sample.txt", 'r') as jabber:
    lines = jabber.readlines()
print(lines)

print("-" * 25)

for line in lines[::-1]:
    print(line, end='')

print("=" * 50)

# Iterating the list through a reverse slice by character
with open("sample.txt", 'r') as jabber:
    lines = jabber.read()
print(lines)

print("-" * 25)

for line in lines[::-1]:
    print(line, end='')

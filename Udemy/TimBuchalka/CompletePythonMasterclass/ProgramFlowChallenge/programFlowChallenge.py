"""
    Author:         CaptCorpMURICA
    Project:        ProgramFlowChallenge
    File:           programFlowChallenge.py
    Creation Date:  12/1/2017, 2:10 PM
    Description:    Create a program that takes an IP address entered at the keyboard
                    and prints out the number of segments it contains, and the length of each segment.

                    An IP address consists of 4 numbers, separated from each other with a full stop. But
                    your program should just count however many are entered.
                    Examples of the input you may get are:
                        127.0.0.1
                        .192.168.0.1
                        10.0.123456.255
                        172.16
                        255

                    So your program should work even with invalid IP Addresses. We're just interested in the
                    number of segments and how long each one is.

                    Once you have a working program, here are some more suggestions for invalid inputs to test:
                        .123.45.678.91
                        123.4567.8.9
                        123.156.289.10123456
                        10.10t.10.10
                        12.9.34.6.12.90
                        '' - that is, pressing enter without typing anything

                    This challenge is intended to practice FOR loops and IF/ELSE statements, so although
                    you could use other techniques (such as splitting the string up), that's not the
                    approach we're looking for here.
"""

# Not perfect. It runs into errors when IP Address starts with a non-numeric character or has more than one
# consecutive non-numeric characters.
ipAddress = input("Please enter an IP address: ")
segment = ""
numSegments = 0
j = 1

if ipAddress:
    for i in range(0, len(ipAddress)):
        if ipAddress[i] not in "0123456789":
            print("Segment {0} ({1}) had {2} numbers in it.".format(j, segment, len(segment)))
            j += 1
            numSegments += 1
            segment = ""
            continue
        else:
            segment += ipAddress[i]
    print("Segment {0} ({1}) had {2} numbers in it.".format(j, segment, len(segment)))
    print("There were {0} segments in the IP Address.".format(numSegments + 1))
else:
    print("You did not enter an IP Address.")

print("===============")

# Solution from the course
ipAddress = input("Please enter an IP address: ")

segment = 1
segment_length = 0
character = ""

for character in ipAddress:
    if character == ".":
        print("Segment {0} contains {1} characters.".format(segment, segment_length))
        segment += 1
        segment_length = 0
    else:
        segment_length += 1

# unless the final character in the string was a "." then we haven't printed the last segment.
if character != ".":
    print("Segment {0} contains {1} characters.".format(segment, segment_length))

print("===============")

# Alternative solution from the course
# Causes error when string is ended with a period.
ipAddress = input("Please enter an IP address: ")
ipAddress += "."

segment = 1
segment_length = 0

for character in ipAddress:
    if character == ".":
        print("Segment {0} contains {1} characters.".format(segment, segment_length))
        segment += 1
        segment_length = 0
    else:
        segment_length += 1

print("===============")

# Alternative solution from the course
# Solved the period ending string issue.
ipAddress = input("Please enter an IP address: ")
if ipAddress[-1] != ".":
    ipAddress += "."

segment = 1
segment_length = 0

for character in ipAddress:
    if character == ".":
        print("Segment {0} contains {1} characters.".format(segment, segment_length))
        segment += 1
        segment_length = 0
    else:
        segment_length += 1
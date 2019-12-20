"""
    Author:         CaptCorpMURICA
    Project:        AugmentedAssignment
    File:           aa.py
    Creation Date:  12/1/2017, 1:55 PM
    Description:    Understand the shorthand operators called Augmented Assignment (+=, etc.)
                    List of all Augmented Assignments:
                        +=  : Addition
                        -=  : Subtraction
                        *=  : Multiplication
                        /=  : Division
                        //= : Floor Division
                        %=  : Remainder/Modulus
                        **= : Exponent
                        <<= : Left Shift
                        >>= : Right Shift
                        &=  : And
                        ^=  : Exclusive Or
                        |=  : Inclusive Or
"""

# Augmented Assignment improves efficiency because Python does not need to create temporary variable for the operation.
number = "9,223,372,036,854,775,807"
cleanedNumber = ""

for i in range(0, len(number)):
    if number[i] in "0123456789":
        # cleanedNumber = cleanedNumber + number[i]
        cleanedNumber += number[i]

newNumber = int(cleanedNumber)
print("The number is {}.".format(newNumber))

print("==================")

x = 23
x += 1
print(x)

print("==================")

x -= 4
print(x)

print("==================")

x *= 5
print(x)

print("==================")

x /= 4
print(int(x))

print("==================")

x **= 2 # To the power of 2
print(int(x))

print("==================")

x %= 60 # Remainder of 60
print(int(x))

print("==================")

greeting = "Good "
greeting += "morning "
print(greeting)

print("==================")

greeting *= 5
print(greeting)

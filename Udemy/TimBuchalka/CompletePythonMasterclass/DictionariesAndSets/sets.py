"""
    Author:         CaptCorpMURICA
    File:           sets.py
    Creation Date:  1/8/2018, 3:13 PM
    Description:    Overview of sets in Python
"""

# Sets are unordered by their nature.
# Sets can be created either by using curly brackets or the set() function
# If turning range, tuple, etc. into a set, then the function is required.

farm_animals = {"sheep", "cow", "hen"}
print(farm_animals)

for animal in farm_animals:
    print(animal)

print("=" * 50)

wild_animals = set(["lion", "tiger", "panther", "elephant", "hare"])
print(wild_animals)

for animal in wild_animals:
    print(animal)

print("=" * 50)

farm_animals.add("horse")
wild_animals.add("horse")
print(farm_animals)
print(wild_animals)

print("=" * 50)

# Create an empty set
empty_set = set()
empty_set.add("a")
print(empty_set)

print("=" * 50)

even = set(range(0, 40, 2))
print(even)

print("=" * 50)

squares_tuple = (4, 6, 9, 16, 25)
squares = set(squares_tuple)
print(squares)

print("=" * 50)

print(even.union(squares))
print("Even Length: " + str(len(even.union(squares))))
print("Squares Length: " + str(len(squares.union(even))))

print("=" * 50)

# Print the intersection between two sets.
print(even.intersection(squares))
print(even & squares)
print(squares.intersection(even))
print(squares & even)

print("=" * 50)

# Subtracting Set B from Set A removes any items in Set B from Set A
even = set(range(0, 40, 2))
print(sorted(even))
squares_tuple = (4, 6, 9, 16, 25)
squares = set(squares_tuple)
print(sorted(squares))

print("-" * 25)

print("Even minus Squares")
print(sorted(even.difference(squares)))
print(sorted(even - squares))

print("-" * 25)

print("Squares minus Even")
print(sorted(squares.difference(even)))
print(sorted(squares - even))

print("=" * 50)

print(sorted(even))
print(squares)
even.difference_update(squares)  # Update occurs on the even set.
print(sorted(even))

print("=" * 50)

# Symmetric difference between two sets

even = set(range(0, 40, 2))
print(sorted(even))
squares_tuple = (4, 6, 9, 16, 25)
squares = set(squares_tuple)
print(sorted(squares))

print("-" * 25)

print("Symmetric Even minus Squares")
print(sorted(even.symmetric_difference(squares)))

print("-" * 25)

print("Symmetric Squares minus Even")
print(sorted(squares.symmetric_difference(even)))

print("=" * 50)

print(sorted(even))
print(squares)
even.symmetric_difference_update(squares)  # Update occurs on the even set.
print(sorted(even))

print("=" * 50)

even = set(range(0, 40, 2))
print(sorted(even))
squares_tuple = (4, 6, 9, 16, 25)
squares = set(squares_tuple)
print(sorted(squares))

print("-" * 25)

squares.discard(4)
squares.remove(16)
squares.discard(8)  # Runs without an error, but doesn't do anything.
print(squares)

print("-" * 25)

# squares.remove(8) -- Does not run, raises an error.
if 8 in squares:
    squares.remove(8)

print("-" * 25)

try:
    squares.remove(8)
except KeyError:
    print("The item 8 is not a member of the set.")

print("=" * 50)

even = set(range(0, 40, 2))
print(even)
squares_tuple = (4, 6, 16)
squares = set(squares_tuple)
print(squares)

print("-" * 25)

if squares.issubset(even):
    print("Squares is a subset of even.")

if even.issuperset(squares):
    print("Even is a superset of squares.")

print("=" * 50)

# Frozen sets are immutable sets
even = frozenset(range(0, 100, 2))
print(even)
# even.add(3) -- Provides error because Frozen sets are immutable

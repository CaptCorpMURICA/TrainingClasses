"""
    Author:         CaptCorpMURICA
    File:           writingTextFiles.py
    Creation Date:  10/5/2018, 11:08 AM
    Description:    Writing Text Files
"""

cities = ["Adelaide", "Alice Springs", "Darwin", "Melbourne", "Sydney"]

with open("cities.txt", 'w') as city_file:
    for city in cities:
        print(city, file=city_file)

cities = []

with open("cities.txt", 'r') as city_file:
    for city in city_file:
        cities.append(city.strip('\n'))

print(cities)
for city in cities:
    print(city)

# Save a tuple to a file
imelda = "More Mayhem", "Imelda May", "2011", (
    (1, "Pulling the Rug"), (2,"Psycho"), (3, "Mayhem"), (4, "Kentish Town Waltz"))

with open("imelda3.txt", 'w') as imelda_file:
    print(imelda, file=imelda_file)

# Read a tuple format from a file and store as a tuple
# Use the eval() function to read the string as a tuple
with open("imelda3.txt", 'r') as imelda_file:
    contents = imelda_file.readline()

imelda = eval(contents)

print(imelda)
title, artist, year, tracks = imelda
print(title)
print(artist)
print(year)
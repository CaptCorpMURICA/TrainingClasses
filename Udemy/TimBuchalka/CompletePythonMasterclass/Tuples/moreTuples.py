"""
    Author:         CaptCorpMURICA
    Project:        Tuples
    File:           moreTuples.py
    Creation Date:  12/4/2017, 4:14 PM
    Description:    Unpacking Tuples
"""

welcome = "Welcome to my Nightmare", "Alice Cooper", 1975
bad = "Bad Company", "Bad Company", 1974
budgie = "Nightflight", "Budgie", 1981
imelda = "More Mayhem", "Imilda May", 2011
metallica = "Ride the Lightning", "Metallica", 1984

metallica2 = ["Ride the Lightning", "Metallica", 1984]
print(metallica2)

title, artist, year = imelda
print("Title: {}".format(title))
print("Artist: {}".format(artist))
print("Year: {}".format(year))

print("=" * 50)

metallica2.append("Rock")
# title, artist, year = metallica2 - Provides error because too many items and not enough variable declarations.
title, artist, year, genre = metallica2
print("Title: {}".format(title))
print("Artist: {}".format(artist))
print("Year: {}".format(year))
print("Genre: {}".format(genre))

# # Provides and error because tuple is immutable
# imelda.append("Jazz")

print("=" * 50)

imelda = "More Mayhem", "Imilda May", 2011, (
    (1, "Pulling the Rug"), (2, "Psycho"), (3, "Mayhem"), (4, "Kentish Town Waltz"))

print(imelda)

title, artist, year, tracks = imelda
print("Title: {}".format(title))
print("Artist: {}".format(artist))
print("Year: {}".format(year))
print("Tracks: {}".format(tracks))

print("=" * 50)

# A tuple that houses a list is cannot be changed, but the list contained can be changed.

imelda = "More Mayhem", "Imilda May", 2011, (
    [(1, "Pulling the Rug"), (2, "Psycho"), (3, "Mayhem"), (4, "Kentish Town Waltz")])

print(imelda)

imelda[3].append((5, "All For You"))

title, artist, year, tracks = imelda
tracks.append((6, "Eternity"))

print("Title: {}".format(title))
print("Artist: {}".format(artist))
print("Year: {}".format(year))

for song in tracks:
    trackNum, trackTitle = song
    print("\tTrack {}: {}".format(trackNum, trackTitle))

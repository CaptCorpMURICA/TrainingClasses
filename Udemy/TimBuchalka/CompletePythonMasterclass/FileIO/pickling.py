"""
    Author:         CaptCorpMURICA
    File:           pickling.py
    Creation Date:  11/2/2018, 12:22 PM
    Description:    Learn how to serialize objects using pickling.
"""

import pickle

imelda = ('More Mayhem',
          'Imelda May',
          '2011',
          ((1, 'Pulling the Rug'),
           (2, 'Psycho'),
           (3, 'Mayhem'),
           (4, 'Kentish Town Waltz')))

# Even though this is a tuple of tuples, pickle can handle writing with a single dump command.
with open("imelda.pickle", "wb") as pickle_file:
    pickle.dump(imelda, pickle_file)

# Pickle files can only be read in Python
# Use the pickle.load() function to read the pickle file in Python
with open("imelda.pickle", "rb") as imelda_pickled:
    imelda2 = pickle.load(imelda_pickled)

print(imelda2)

album, artist, year, track_list = imelda2

print(album)
print(artist)
print(year)
for track in track_list:
    track_number, track_title = track
    print(track_number, track_title)

print("=" * 50)

# Can add multiple independent variables to a single pickle.
# WARNING: The data must be read in the same order in which it was written.
imelda = ('More Mayhem',
          'Imelda May',
          '2011',
          ((1, 'Pulling the Rug'),
           (2, 'Psycho'),
           (3, 'Mayhem'),
           (4, 'Kentish Town Waltz')))

even = list(range(0, 10, 2))
odd = list(range(1, 10, 2))

with open("imelda.pickle", "wb") as pickle_file:
    pickle.dump(imelda, pickle_file)
    pickle.dump(even, pickle_file)
    pickle.dump(odd, pickle_file)
    pickle.dump(2998302, pickle_file)

with open("imelda.pickle", "rb") as imelda_pickled:
    imelda2 = pickle.load(imelda_pickled)
    even_list = pickle.load(imelda_pickled)
    odd_list = pickle.load(imelda_pickled)
    x = pickle.load(imelda_pickled)

print(imelda2)

album, artist, year, track_list = imelda2

print("*" * 40)
print("Imelda Tuple")
print("-" * 12)

print(album)
print(artist)
print(year)
for track in track_list:
    track_number, track_title = track
    print(track_number, track_title)

print("*" * 40)
print("Even List")
print("-" * 9)

for i in even_list:
    print(i)

print("*" * 40)
print("Odd List")
print("-" * 8)

for i in odd_list:
    print(i)

print("*" * 40)
print("Random Number")
print("-" * 13)

print(x)

print("=" * 50)

# NOTE: Pickling is not backwards compatible. Pickles written in a later protocol version cannot be read by an earlier
#       one.

# For Python 3, the default protocol is 3. This can be read by all versions of Python 3 or greater, but not earlier.

# Manually declare protocol 0 for pickle file
with open("imelda_protocol_0.pickle", "wb") as pickle_file:
    pickle.dump(imelda, pickle_file, protocol=0)
    pickle.dump(even, pickle_file, protocol=0)
    pickle.dump(odd, pickle_file, protocol=0)
    pickle.dump(2998302, pickle_file, protocol=0)

# Manually declare protocol 1 for pickle file. This is the binary protocol that can be read by all versions of Python.
with open("imelda_protocol_1.pickle", "wb") as pickle_file:
    pickle.dump(imelda, pickle_file, protocol=1)
    pickle.dump(even, pickle_file, protocol=1)
    pickle.dump(odd, pickle_file, protocol=1)
    pickle.dump(2998302, pickle_file, protocol=1)

# Can dynamically write with the highest or default protocol version.
with open("imelda_protocol_dynamic.pickle", "wb") as pickle_file:
    pickle.dump(imelda, pickle_file, protocol=pickle.HIGHEST_PROTOCOL)
    pickle.dump(even, pickle_file, protocol=1)
    pickle.dump(odd, pickle_file, protocol=pickle.DEFAULT_PROTOCOL)
    pickle.dump(2998302, pickle_file, protocol=pickle.DEFAULT_PROTOCOL)

print("=" * 50)

# URGENT: Only unpickle data from sources you trust. Pickling can be a major security breach if the file is not fully
#         vetted first.

# This command removes the pickle file.
# pickle.loads(b"cos\nsystem\n(S'rm imelda.pickle'\ntR.")     # Mac/Linux
pickle.loads(b"cos\nsystem\n(S'del imelda.pickle'\ntR.")     # Windows
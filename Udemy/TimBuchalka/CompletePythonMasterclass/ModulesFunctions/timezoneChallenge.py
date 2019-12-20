"""
    Author:         CaptCorpMURICA
    Project:        CompletePythonMasterclass
    File:           timezoneChallenge.py
    Creation Date:  1/11/2019, 4:20 PM
    Description:    Create a program that allows a user to choose one of up to nine timezones from a menu. You can
                    choose any zones you want from the all_timezones list.
                    The program will then display the time in that timezone, as well as local time and UTC time.
                    Entering 0 as the choice will quit the program.
                    Display the dates and times in a format suitable for the user of your program to understand, and
                    include the timezone name when displaying the chosen time.
"""

# This is my over engineered solution

import pytz
import datetime
import random

zone_key = []
all_zones = []
num_zones = 0

# Creates a counter with the total number of timezones and a list that contain the names
for x in sorted(pytz.country_names):
    if x in pytz.country_timezones:
        for zone in sorted(pytz.country_timezones[x]):
            all_zones.append(zone)
            num_zones += 1

# Initial declaration of the values to be used as keys to grab the timezones
for i in range(0, 9):
    zone_key.append(random.randint(0, num_zones - 1))

# Remove any duplicated keys from the initial declaration
zone_key = list(dict.fromkeys(zone_key))

# Repopulate the list with new keys until there are nine options
while len(zone_key) != 9:
    for i in range(0, 9 - len(zone_key)):
        zone_key.append(random.randint(0, num_zones - 1))
        zone_key = list(dict.fromkeys(zone_key))

# Create a tuple of available zones based off the randomly generated keys
avail_zones = {"1": all_zones[zone_key[0]],
               "2": all_zones[zone_key[1]],
               "3": all_zones[zone_key[2]],
               "4": all_zones[zone_key[3]],
               "5": all_zones[zone_key[4]],
               "6": all_zones[zone_key[5]],
               "7": all_zones[zone_key[6]],
               "8": all_zones[zone_key[7]],
               "9": all_zones[zone_key[8]]}

# User input for challenge
print("Instructions:")
print("\tPlease select one of the following options to display the timezone.")
print("\tYou can quit the program by entering `0`.")
print()
print("Options:")
for x in sorted(avail_zones):
    print("\t{}: {}".format(x, avail_zones[x]), end='\n')

while True:
    location_key = input("Please select a location: ")

    if location_key == '0':
        print("Thank you for using the program. Have a great day.")
        break

    if location_key in avail_zones.keys():
        tz_to_display = pytz.timezone(avail_zones[location_key])
        choice_time = datetime.datetime.now(tz=tz_to_display)
        local_time = datetime.datetime.now()
        utc_time = datetime.datetime.utcnow()
        print("The time in {} is {} ({}).".format(avail_zones[location_key], choice_time.strftime('%A, %x at %X %z'), choice_time.tzname()))
        print("The local time is {}".format(local_time.strftime('%A, %x at %X %z')))
        print("The UTC time is {}".format(utc_time.strftime('%A, %x at %X %z')))
    else:
        print("That is not an available option. Please try again.")

# This is the instructor's solution (mine is cooler)
print("+" * 23)
print("+ Instructor Solution +")
print("+" * 23)

available_zones = {"1": "Africa/Tunis",
                   "2": "Asia/Kolkata",
                   "3": "Australia/Adelaide",
                   "4": "Europe/Brussels",
                   "5": "Europe/London",
                   "6": "Japan",
                   "7": "Pacific/Tahiti",
                   "8": "US/Hawaii",
                   "9": "Zulu"}

print("Please choose a timezone (or 0 to quit):")
for place in sorted(available_zones):
    print("\t{}. {}".format(place, available_zones[place]))

while True:
    choice = input()

    if choice == '0':
        break

    if choice in available_zones.keys():
        tz_to_display = pytz.timezone(available_zones[choice])
        world_time = datetime.datetime.now(tz=tz_to_display)
        print("The time in {} is {} {}".format(available_zones[choice], world_time.strftime('%A %x %X %z'), world_time.tzname()))
        print("Local time is {}.".format(datetime.datetime.now().strftime("%A %x %X")))
        print("UTC time is {}.".format(datetime.datetime.utcnow().strftime("%A %x %X")))
        print()

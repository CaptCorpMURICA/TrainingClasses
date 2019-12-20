"""
    Author:         CaptCorpMURICA
    File:           dateAndTime.py
    Creation Date:  12/28/2018, 3:22 PM
    Description:    Learning about the timezone functions
"""

import time

print("The epoch on this system starts at " + time.strftime('%c', time.gmtime(0)))

print("The current timezone is {0} with an offset of {1} hours.".format(time.tzname[0], int(time.timezone/3600)))

if time.daylight != 0:
    print("\tDaylight Saving Time is in effect for this location.")
    print("\tThe DST timezone is " + time.tzname[1])

print("Local time is " + time.strftime('%Y-%m-%d %H:%M:%S', time.localtime()))
print("UTC time is " + time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime()))

print("=" * 50)

import datetime

print(datetime.datetime.today())
print(datetime.datetime.now())
print(datetime.datetime.utcnow())

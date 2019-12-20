"""
    Author:         CaptCorpMURICA
    File:           awareTime.py
    Creation Date:  1/11/2019, 3:56 PM
    Description:    Learn how to convert time between local to UTC back to local
"""

# Converting local time to UTC has it's own share of problems.
# Converting back and forth between the two can cause errors unless the timezone information is stored as well.
import datetime
import pytz

local_time = datetime.datetime.now()
utc_time = datetime.datetime.utcnow()

print("Naive local time {}".format(local_time))
print("Naive UTC {}".format(utc_time))

aware_local_time = pytz.utc.localize(local_time)
aware_utc_time = pytz.utc.localize(utc_time)

print("Aware local time {}, timezone {}".format(aware_local_time, aware_local_time.tzinfo))
print("Aware UTC time {}, timezone {}".format(aware_utc_time, aware_utc_time.tzinfo))

# The timezone information is not accurate for the local time.
# The localize() method is used to localize a naive datetime (datetime with no timezone information).
# Should use UTC time for the entire code until needed to present the time to the user.

print("=" * 50)

# In order to correct the issue, use the astimezone() function when localizing UTC time
aware_local_time = pytz.utc.localize(utc_time).astimezone()
aware_utc_time = pytz.utc.localize(utc_time)

print("Aware local time {}, timezone {}".format(aware_local_time, aware_local_time.tzinfo))
print("Aware UTC time {}, timezone {}".format(aware_utc_time, aware_utc_time.tzinfo))

print("=" * 50)

gap_time = datetime.datetime(2015, 10, 25, 1, 30, 0, 0)
print(gap_time)
print(gap_time.timestamp())

print("-" * 25)

# Number of seconds from epoch in Great Britain on 2015-10-25 at 1:30 AM
s = 1445733000
t = s + (60 * 60)

gb = pytz.timezone('GB')
dt1 = pytz.utc.localize(datetime.datetime.fromtimestamp(s)).astimezone(gb)
dt2 = pytz.utc.localize(datetime.datetime.fromtimestamp(t)).astimezone(gb)

print("{} seconds since the epoch is {}".format(s, dt1))
print("{} seconds since the epoch is {}".format(t, dt2))

# This fails because the local time (EST) was used for the program instead of the desired UK timezone.

print("-" * 25)

dt1 = pytz.utc.localize(datetime.datetime.utcfromtimestamp(s)).astimezone(gb)
dt2 = pytz.utc.localize(datetime.datetime.utcfromtimestamp(t)).astimezone(gb)

print("{} seconds since the epoch is {}".format(s, dt1))
print("{} seconds since the epoch is {}".format(t, dt2))

# By switching to the utcfromtimestamp() function, the error is corrected.
# This script can be run from anywhere in the world since the logic uses UTC time instead of local time.

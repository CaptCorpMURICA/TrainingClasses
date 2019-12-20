"""
    Author:         CaptCorpMURICA
    Project:        CompletePythonMasterclass
    File:           tztest.py
    Creation Date:  1/10/2019, 3:24 PM
    Description:    Understand how indentation works with Python
"""

import pytz
import datetime

country = 'Europe/Moscow'

tz_to_display = pytz.timezone(country)
local_time = datetime.datetime.now(tz=tz_to_display)
print("The time in {} is {}".format(country, local_time))
print("UTC is {}".format(datetime.datetime.utcnow()))

print("=" * 50)

for x in pytz.all_timezones:
    print(x)

print("=" * 50)

for x in sorted(pytz.country_names):
    print(x + ": " + pytz.country_names[x])

print("=" * 50)

print("-- Code crashes due to no timezone being available for BV.")
print("for x in sorted(pytz.country_names):")
print("    print('{}: {}: {}'.format(x, pytz.country_names[x], pytz.country_timezones[x]))")

print("=" * 50)

# Timezone database
# http://www.iana.org/time-zones
for x in sorted(pytz.country_names):
    print("{}: {}: {}".format(x, pytz.country_names[x], pytz.country_timezones.get(x)))

print("=" * 50)

# Defensively code to add a message when a country doesn't have a timezone.
for x in sorted(pytz.country_names):
    print("{}: {}".format(x, pytz.country_names[x]), end=': ')
    if x in pytz.country_timezones:
        print(pytz.country_timezones[x])
    else:
        print("No timezone defined.")

print("=" * 50)

# Modify the script to add the current time in each timezone.
for x in sorted(pytz.country_names):
    print("{}: {}".format(x, pytz.country_names[x]), end='\n')
    if x in pytz.country_timezones:
        for zone in sorted(pytz.country_timezones[x]):
            tz_to_display = pytz.timezone(zone)
            local_time = datetime.datetime.now(tz=tz_to_display)
            print("\t\t{}: {}".format(zone, local_time))
    else:
        print("\t\tNo timezone defined.")

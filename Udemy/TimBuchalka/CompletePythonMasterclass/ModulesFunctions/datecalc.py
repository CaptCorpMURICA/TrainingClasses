"""
    Author:         CaptCorpMURICA
    File:           datecalc.py
    Creation Date:  12/14/2018, 3:12 PM
    Description:    Overview of date functions in Python
"""

import time

# Convert seconds since the Epoch to a time tuple expressing UTC (a.k.a. GMT).
# When 'seconds' is not passed in, convert the current time instead.
print(time.gmtime(0))

# Convert seconds since the Epoch to a time tuple expressing local time.
# When 'seconds' is not passed in, convert the current time instead.
print(time.localtime())
print(time.localtime(time.time()))

# Return the current time in seconds since the Epoch.
# Fractions of a second may be present if the system clock provides them.
print(time.time())

# The date/time is stored as a tuple
time_here = time.localtime()
print(time_here)
print("Year: ", time_here[0], time_here.tm_year)
print("Month: ", time_here[1], time_here.tm_mon)
print("Day: ", time_here[2], time_here.tm_mday)

print("=" * 50)

# Create simple reaction timer game
from time import time as my_timer
import random

input("Press enter to start")

wait_time = random.randint(1, 6)
time.sleep(wait_time)
start_time = my_timer()
input("Press enter to stop")

end_time = my_timer()

print("Started at " + time.strftime("%X", time.localtime(start_time)))
print("Ended at " + time.strftime("%X", time.localtime(end_time)))

print("Your reaction time was {} seconds".format(end_time - start_time))

print("=" * 50)

# Update the reaction game to solve some of the bugs.
# In the original method, the user could cheat by quickly hitting enter twice or changing the computer time.
# Additionally, if DST switched while in the game, the reaction time would be radically different than reality.

# perf_counter is the most accurate time counter and great for program benchmarking
from time import perf_counter as my_timer
import random

input("Press enter to start")

wait_time = random.randint(1, 6)
time.sleep(wait_time)
start_time = my_timer()
input("Press enter to stop")

end_time = my_timer()

print("Started at " + time.strftime("%X", time.localtime(start_time)))
print("Ended at " + time.strftime("%X", time.localtime(end_time)))

print("Your reaction time was {} seconds".format(end_time - start_time))

print("=" * 50)

# Another option using the monotonic method
# This makes sure the time cannot go backwards. It would fix the DST issue.
from time import monotonic as my_timer
import random

input("Press enter to start")

wait_time = random.randint(1, 6)
time.sleep(wait_time)
start_time = my_timer()
input("Press enter to stop")

end_time = my_timer()

print("Started at " + time.strftime("%X", time.localtime(start_time)))
print("Ended at " + time.strftime("%X", time.localtime(end_time)))

print("Your reaction time was {} seconds".format(end_time - start_time))

print("=" * 50)

# Provide CPU time
# This is not applicable for this game, but is extremely valuable to profile code.
from time import process_time as my_timer
import random

input("Press enter to start")

wait_time = random.randint(1, 6)
time.sleep(wait_time)
start_time = my_timer()
input("Press enter to stop")

end_time = my_timer()

print("Started at " + time.strftime("%X", time.localtime(start_time)))
print("Ended at " + time.strftime("%X", time.localtime(end_time)))

print("Your reaction time was {} seconds".format(end_time - start_time))

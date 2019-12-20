"""
    Author:         CaptCorpMURICA
    File:           dateChallenge.py
    Creation Date:  12/14/2018, 4:05 PM
    Description:    Write a small program to display information on the
                    four clocks whose functions we have just looked at:
                    i.e time(), perf_counter(), monotonic(), and process_time().

                    Use the documentation for the get_clock_info() function
                    to work out how to call it for each of the clocks.
"""

import time

# adjustable: True if the clock can be changed automatically (e.g. by a NTP daemon) or manually by the system
#             administrator, False otherwise
# implementation: The name of the underlying C function used to get the clock value. Refer to Clock ID Constants for
#                 possible values.
# monotonic: True if the clock cannot go backward, False otherwise
# resolution: The resolution of the clock in seconds (float)

print("Information on time():\t\t\t", time.get_clock_info('time'))
print("Information on perf_counter():\t", time.get_clock_info('perf_counter'))
print("Information on monotonic():\t\t", time.get_clock_info('monotonic'))
print("Information on process_time():\t", time.get_clock_info('process_time'))

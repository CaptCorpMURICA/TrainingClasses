"""
    Author:         CaptCorpMURICA
    File:           browser.py
    Creation Date:  11/12/2018, 2:45 PM
    Description:    Learn about the WebBrowser module
"""

import webbrowser

# Opens web browser to specified URL
webbrowser.open("https://www.python.org")

help(webbrowser)

for i in range(10):
    print(1, 2, 3, 4, 5, 6, 7, 8, 9, sep=';', end=' ')

# new=1, a new browser window is opened if possible
webbrowser.open("https://www.python.org", new=1)

# new=2, a new browser page ("tab") is opened if possible
webbrowser.open("https://www.python.org", new=2)

# If autoraise is True, the window is raised if possible (note that under many window managers this will occur
# regardless of the setting of this variable).
webbrowser.open("https://www.python.org", new=2, autoraise=True)

# Specify the web browser to open.
chrome = webbrowser.get(using='google-chrome')
chrome.open_new("https://www.python.org")

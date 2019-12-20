"""
    Author:         CaptCorpMURICA
    Project:        CompletePythonMasterclass
    File:           tkinterDemo.py
    Creation Date:  1/23/2019, 7:11 PM
    Description:    Tk is the only cross-platform GUI toolkit designed exclusively for high-level dynamic languages.
"""

try:
    import tkinter
except ImportError:  # python 2
    import Tkinter as tkinter

print(tkinter.TkVersion)
print(tkinter.TclVersion)

tkinter._test()

mainWindow = tkinter.Tk()

mainWindow.title("Hello World")
# Window size of 640x480 pixels that has 8 pixels to the left of the window and 400 pixels to the top of the window
mainWindow.geometry("640x480+8+400")
mainWindow.mainloop()

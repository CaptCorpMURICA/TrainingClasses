"""
    Author:         CaptCorpMURICA
    Project:        TrainingClasses
    File:           journal.py
    Creation Date:  1/2/20, 3:38 PM
    Description:    Manages the data for the daily journal app.
"""
import os


def load(name):
    """
    Open the journal data file and write the entries to a list to be returned to the user.

    :param name: Name of the journal to be loaded.
    :return: Returns the populated or empty dataset if the file exists.
    """
    data = []
    filename = get_full_pathname(name)

    print(f"Loading journal: {name}.jrl")

    if os.path.exists(filename):
        with open(filename) as fin:
            for entry in fin.readlines():
                data.append(entry.rstrip())

    return data


def save(name, journal_data):
    """
    Overwrites the existing journal file with all existing and new journal entries.

    :param name: Name of the journal file
    :param journal_data: Journal list object that contains existing and new journal entries
    :return: None
    """
    filename = get_full_pathname(name)
    print(f"..... saving to: {filename}")

    with open(filename, 'w') as fout:
        for entry in journal_data:
            fout.write(entry + '\n')


def add_entry(text, journal_data):
    """
    Appends the new entry to the journal list.

    :param text: Text to be added to the journal as a new entry.
    :param journal_data: Existing journal list object to be appended with the new entry.
    :return: None
    """
    journal_data.append(text)


def get_full_pathname(name):
    """
    Obtains the full path of the journal file for the app.

    :param name: Name of the journal file
    :return: Full file path of the journal file
    """
    filename = os.path.abspath(os.path.join(".", "journals", f"{name}.jrl"))
    return filename

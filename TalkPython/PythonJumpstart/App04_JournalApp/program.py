"""
    Author:         CaptCorpMURICA
    Project:        TrainingClasses
    File:           program.py
    Creation Date:  1/2/20, 2:28 PM
    Description:    User interface for daily journal app.
"""
import journal


def main():
    """
    Main program flow of the journal app.

    :return: None
    """
    print_header()
    run_event_loop()


def print_header():
    """
    Prints the header for the birthday app with the proper formatting.

    :return: Print the formatted output
    """
    print('-' * 32)
    print(f'{"PERSONAL JOURNAL APP":^32}')
    print('-' * 32)
    print()


def run_event_loop():
    """
    Main user interface of the program. Provides options to list or add entries for the journal. The user can also
    specify a specific journal with the default = 'journal'.

    :return: None
    """
    print("What do you want to do with your journal?")
    cmd = 'EMPTY'
    journal_name = 'journal'
    journal_data = journal.load(journal_name)

    while cmd != 'x' and cmd:
        cmd = input("[L]ist entries, [A]dd an entry, Select a journal by [n]ame, E[x]it: ").lower().strip()

        if cmd == 'l':
            list_entries(journal_data)
        elif cmd == 'a':
            add_entries(journal_data)
        elif cmd == 'n':
            journal.save(journal_name, journal_data)
            journal_name = input("What is the name of the journal? ").lower()
            journal_name = ''.join(journal_name.split())
            journal_data = journal.load(journal_name)
        elif cmd != 'x' and cmd:
            print(f"Sorry, we don't understand '{cmd}'.")

    print("Done. Goodbye.")
    journal.save(journal_name, journal_data)


def list_entries(data):
    """
    Provides the user with a list of all of the entries in the journal list object in reversed order.

    :param data: Receives the journal list object as an input in order to print the contents.
    :return: Print the contents of the journal list object.
    """
    print("Your journal entries:")
    entries = reversed(data)
    for i, entry in enumerate(entries):
        print(f"{i + 1}: {entry}")


def add_entries(data):
    """
    Appends the user's new journal entry to the list. Since a list is an ordered object, the new entries are stored at
    the end of the current list object.

    :param data: Receives the journal list object as an input in order to append additional entries to the list.
    :return: Updated journal list object with the new entry appended to the end of the list.
    """
    text = input("Type your entry, <enter> to exit: ")
    journal.add_entry(text, data)


if __name__ == '__main__':
    main()

"""
    Author:         CaptCorpMURICA
    Project:        TrainingClasses
    File:           program.py
    Creation Date:  1/1/20, 4:46 PM
    Description:    Prompts the user for their date of birth and returns the number of days until their birthday.
"""
import datetime


def print_header():
    """
    Prints the header for the birthday app with the proper formatting.
    :return: Print the formatted output.
    """
    print('-' * 32)
    print(f'{"BIRTHDAY APP":^32}')
    print('-' * 32)
    print()


def get_birthday_from_user():
    """
    Prompts the user for their date of birth and returns the birthday as a variable
    :return: birthday datetime object
    """
    print("When were you born? ")
    year = int(input("Year [YYYY]: "))
    month = int(input("Month [MM]: "))
    day = int(input("Day [DD]: "))

    birthday = datetime.date(year, month, day)
    return birthday


def compute_days_between_dates(original_date, target_date):
    """
    Compute the day difference between the birthday and today.
    :param original_date: Birthday datetime object obtained from the user
    :param target_date: Date the program is run
    :return: number_of_days = number of days between birthday and current date to calculate the time until next birthday
    """
    this_year = datetime.date(year=target_date.year, month=original_date.month, day=original_date.day)

    dt = this_year - target_date
    return dt.days


def print_birthday_information(days):
    """
    Format the output based on the proximity of the user's birthday this year. If the user's birthday has already
    passed, then the user is informed the number of days in the past. If in the future, the number of days until their
    birthday. And if today is their birthday, the program congratulates them on their birthday.
    :param days: Number of days between the current date and the user's birthday this year.
    :return: Print the formatted output.
    """
    if days < 0:
        print(f"You had your birthday {-days} days ago this year.")
    elif days > 0:
        print(f"Your birthday is in {days} days.")
    else:
        print("Today is your birthday. Happy Birthday!!!")


if __name__ == '__main__':
    print_header()
    bday = get_birthday_from_user()
    today = datetime.date.today()
    number_of_days = compute_days_between_dates(bday, today)
    print_birthday_information(number_of_days)

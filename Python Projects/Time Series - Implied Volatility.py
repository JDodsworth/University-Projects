import csv
import math
import statistics
import numpy as np
import matplotlib.dates as pld
import matplotlib.pyplot as plt
from datetime import datetime


def black_scholes(exercise_price, interest_rate, maturity_time, option_type,
                  underlying_price, volatility):
    """
    Return the price of an option using the Black-Scholes formula.

    Parameters
    ----------
    exercise_price : float
        This is the price at which the option can be exercised at
        maturity time, assumed to be positive.
    interest_rate : float
        This is the interest rate over the time-period of the option,
        assumed to be annualised and positive. Interest rate
        repesents a number, rather than a percentage (e.g. r = 0.02
        means 2%, not 0.02%) and is treated as constant.
    maturity_time : float
        This is the length of time of the option contract, assumed to
        be annualised (e.g. maturity_time == 1 means 1 year,
        maturity_time == 1/365 means one day, etc.) and positive.
    option_type : str
        This is the type of European option, either a put or a call.
    underlying_price : float
        This is the current price of the underlying asset assumed to
        be positive.
    volatility : float
        This represents implied volatility which explains the
        market's view on the future variation of the underlying
        asset. This is assumed to be constant, annualised and
        represents a number, not a percentage.

    Returns
    -------
    float
        The price of the European option.

    Raises
    ------
    ValueError
        If any of the parameters that take values are less than zero.
    TypeError
        If the parameter option_type is not either 'call' or 'put'
    """
    # The following section is checking for any errors within the
    # parameters, either values or type.
    val_parameters = [exercise_price, interest_rate, maturity_time,
                      underlying_price, volatility]
    for i, param in enumerate(val_parameters):
        if float(param) <= 0:
            parameter_names = ['exercise_price', 'interest_rate',
                               'maturity_time', 'underlying_price',
                               'volatility']
            raise ValueError(
                f'{parameter_names[i]} = {param} must be positive')
    if option_type not in ['put', 'call']:
        raise TypeError(f'{option_type=} must be either "put" or "call"')

    # The two variables d1 and d2 needed for the option_price formula
    # are calculated.
    d1 = ((np.log(underlying_price/exercise_price)
           + (interest_rate + (volatility**2)/2)*maturity_time)) \
        / (volatility*np.sqrt(maturity_time))
    d2 = d1 - volatility*np.sqrt(maturity_time)
    # An if-else statement used to distinguish between calculating a
    # call or put option.
    if option_type == 'call':
        option_price = underlying_price\
                       * statistics.NormalDist(mu=0, sigma=1).cdf(d1) \
                       - exercise_price * np.exp((-interest_rate)
                                                 * maturity_time) \
                       * statistics.NormalDist(mu=0, sigma=1).cdf(d2)
    else:
        option_price = exercise_price*np.exp((-interest_rate)
                                             * maturity_time) \
                       * statistics.NormalDist(mu=0, sigma=1).cdf(-d2) \
                       - underlying_price \
                       * statistics.NormalDist(mu=0, sigma=1).cdf(-d1)
    return option_price


def time_series_iv(in_filename, out_filename, plot_filename=None, *,
                   date_field, exercise_price, int_rate_field, iv_field,
                   maturity_field, option_price_field, option_type,
                   underlying_price_field):
    """
    Create new file with implied volatility and optional plot.

    The function processes a CSV file containing time series data of
    a single European option and writes a new CSV file with an added
    field for the implied volatility (as a percentage and
    annualised), and can optionally output a graph of implied
    volatility (on y-axis) against time (along x-axis).

    Parameters
    ----------
    in_filename : str
        This is the filename of the input CSV file.
    out_filename : str
        This is the filename of the output CSV file.
    plot_filename : str, optional
        This is the filename of the optional plot. This has a default
        of None, therefore if no filename is given, then plot is not
        produced.
    date_field : str
        This is the CSV field of the current date that each option is
        priced at.
    exercise_price : int
        This is the exercise price of every option in the CSV file.
    int_rate_field : str
        This is the CSV field of the annualised risk-free interest
        rate of each option (in %).
    iv_field : str
        This is the CSV field of the implied volatility of each
        option (in %).
    maturity_field : str
        This is the CSV field of the maturity time of each option
        (in days).
    option_price_field : str
        This is the CSV field of the price of the option.
    option_type : str
        This is the type of every option in the CSV file, either
        'call' or 'put'.
    underlying_price_field : str
        This is the CSV field of the price of the underlying asset
        at that date.

    Returns
    -------
    None

    Raises
    ------
    Error
        If iv_field is a header in the input file.
        If plot_filename is None.
    ValueError
        If any of the fields are not headers of the input file.
    """
    # The following section opens the in_filename CSV file, splits the
    # file by rows, strips of unwanted characters ('\r'), and creates a
    # DictReader object where the header fields of the CSV file become
    # keys of a dictionary.
    with open(in_filename, 'r', newline='') as input_file:
        reader = csv.DictReader(input_file)
        headers = reader.fieldnames

        # The section below raises errors depending on whether
        # certain fields are or are not headers in the CSV file.
        if iv_field in headers:
            raise Exception(
                f'{iv_field} must not be a header within CSV file.')

        required_fields = [date_field, int_rate_field, maturity_field,
                           option_price_field, underlying_price_field]
        for i, field in enumerate(required_fields):
            if field not in headers:
                field_names = ['date_field', 'int_rate_field',
                               'maturity_field', 'option_price_field',
                               'underlying_price_field']
                raise ValueError(
                    f'{field_names[i]} = {field} must be a header within CSV'
                      ' file.')

        # The following lines of code write a new out_filename CSV file,
        # add an additional header 'iv_field', and Dictwriter() method
        # is used to apply keys to the headers.
        with open(out_filename, 'w', newline='') as output_file:
            output_headers = headers + [iv_field]
            writer = csv.DictWriter(output_file, fieldnames=output_headers)
            writer.writeheader()

            # The for loop runs through each row of data from the input
            # file (reader) and places it within the black_scholes_iv
            # function to find implied volatility. This is added under
            # the new header 'iv_field' within the dictionary. Finally,
            # each row of data is written into the new output file,
            # including implied volatility.
            for row in reader:
                iv = black_scholes_iv(float(row[option_price_field]),
                                      exercise_price=exercise_price,
                                      interest_rate=float(row[int_rate_field])
                                      / 100,
                                      maturity_time=float(row[maturity_field])
                                      / 365,
                                      option_type=option_type,
                                      underlying_price=float(
                                      row[underlying_price_field]))
                row[iv_field] = float(iv)
                writer.writerow(row)

        # After closing the output file that has been written in, the
        # output file is reopened in read format. The output file is
        # split into rows, stripped of unwanted characters ('\r'), and a
        # new variable is created where the header fields of the output
        # CSV file become keys of a dictionary.
        with open(out_filename, 'r', newline='') as output_file:
            output_rows = output_file.read().split('\n')
            for i in range(len(output_rows)):
                output_rows[i] = output_rows[i].replace('\r', '')
            output_data = output_rows[1:]
            output_reader = csv.DictReader(output_data,
                                           fieldnames=output_headers)

            # Initialising dates and iv_values as empty lists. These
            # lists will contain the data required for the optional
            # plot.
            dates = []
            iv_values = []
            # An iteration of each row of the output_file, pulling
            # through dates and implied volatilities and appending to
            # the empty lists.
            for row in output_reader:
                dates.append(datetime.strptime(row[date_field], '%d%b%Y'))
                iv_values.append(float(row[iv_field])*100)

            # Raising an error if plot_filename is None and therefore the
            # program not producing a plot.
            if plot_filename is None:
                raise Exception('plot_filename is None, Therefore program'
                                'does not produce plot.')
            else:
                # The following section explains the formation of the plot.
                # This includes choosing the correct values for the axes,
                # adjusting the x-axis, and labelling the figure and axes.
                fig, ax = plt.subplots()
                ax.plot(dates, iv_values)
                ax.xaxis.set_major_locator(pld.MonthLocator())
                ax.set_title('Volatility vs. Time')
                ax.set_ylabel(r'$Implied\ volatility\ (\%)$')
                ax.set_xlabel('$Time$')
    return


def black_scholes_iv(option_price, *, lower_vol=0.0001, upper_vol=100,
                     **k_args):
    """
    Return the implied volatility of a European option.

    The function calculates the implied volatility by finding the root
    of the difference between the theoretical price of the option
    calculated by the Black-Scholes formula and the market's view of
    the price of the option. Therefore, the function assumes that these
    two option prices should be equal to each other.

    Parameters
    ----------
    option_price : float
        This is the market's view of the price of the option, taken from
        the CSV file.
    lower_vol : float, optional
        This is the lower bound of the implied volatility interval.
    upper_vol : float, optional
        This is the lower bound of the implied volatility interval.
    **k_args : dict
        Additonal parameters required for the black-scholes function
        where the values of these parameters are taken from the CSV
        file.

    Returns
    -------
    float
        the implied volatility of the european option.
    """
    return find_root(lambda vol: black_scholes(**k_args, volatility=vol)
                     - option_price, lower_vol, upper_vol)


def find_root(f, a, b, tol=10**-9, max_iter=math.inf):
    """
    Return an approximate root of a give function, f.

    Parameters
    ----------
    f : function
        A continuous function that takes one parameter, is defined on
        the interval [a,b], and where an approximate root is trying to
        be found.
    a : int
        Lower bound of the interval.
    b : int
        Upper bound of the interval.
    tol : float, optional
        Tolerance for root approximation which defaults to 10^(-9) and
        therefore assumed to be non-negative.
    max_iter : float, optional
        The maximum number of iterations which defaults to infinity.

    Returns
    -------
    float
        Value of the approximate root, otherwise None.
    """
    # Checking whether a or b are already an approximate root of f.
    if abs(f(a)) <= tol:
        return a
    elif abs(f(b)) <= tol:
        return b
    # Checking that f(a) and f(b) have opposite signs.
    elif f(a)*f(b) > 0:
        return
    # Assigning a and b such that f(x_negative) < 0 < f(x_positive)
    elif f(b) > 0:
        x_positive = b
        x_negative = a
    elif f(b) < 0:
        x_positive = a
        x_negative = b
    # Implementation of algorithm
    i = 0
    while i < max_iter:
        i += 1
        # Defining y has the iterative formula to calculate the next
        # approximate root of f
        y = (x_negative * f(x_positive) - x_positive *
             f(x_negative))/(f(x_positive)-f(x_negative))
        # Creating a conditional statement on whether y is or is not an
        # approximate root of f
        if abs(f(y)) <= tol or y == x_negative or y == x_positive:
            # Returning y if any of the above statments are true and
            # therefore indicating that this iteration has provided an
            # approximate root of f
            return y
        # Assigning the value of y to either x_negative or x_positive,
        # on the basis of not satisfying the above conditions, and to
        # then be placed back into the iterative formula y
        elif f(y) < 0:
            x_negative = y
        elif f(y) > 0:
            x_positive = y
    return y

import math
import random


def vasicek_sim(initial, final_time, sim_path_len, num_paths=None, *, a, b,
                sigma, allow_neg=True):
    """Return a number of historic, current and future interest rate paths.

    future interest rates are calculated using the Vasicek interest model and
    Monte-Carlo simulation.

    Parameters
    ----------
    initial : float or list of floats
        the current interest rate or the historical and current interest
        rates if initial is a list. the farthest right entry is the
        current interest rate.
    final_time : float
        a positive number that represents the upper bound of the
        interval in which the simulation is run in.
    sim_path_len : int
        number of future interest rates to simulate within the time
        interval.
    num_paths : int, optional
        number of paths simulated. If not specified, defaults to None.
    a, b, sigma : float
        parameters of the Vasicek model, assumed to be positive.
    allow_neg : bool, optional
        determines if negative interest rate are allowed and defaults to
        True.

    Returns
    -------
    list of list of floats
        a given number of paths that represent interest rates over a
        period time.
    """
    # Assigning the number of paths needing to be simulated equal to one
    # if num_path is defaulted.
    if num_paths is None:
        num_paths = 1
    # Creating an empty list to which our simulated paths will be added
    # to.
    paths = []
    # Finding the distance between each future interest rate over the
    # time interval.
    delta = final_time / sim_path_len
    # Assigning initial as a list if initial is a float when the
    # function is called.
    if isinstance(initial, float):
        initial = [initial]

    # Implementation of the algorithm.
    # Loops for each path that needs to be simulated.
    for j in range(num_paths):
        # Assigning a single path as the intial list.
        path = initial.copy()
        # Creating the variable r equal to the last element in the
        # initial list, the current interest rate.
        r = float(initial[-1])
        # Loops for each new future interest rate.
        for k in range(sim_path_len):
            # Creating the standard normal variable.
            Z = random.gauss(0, 1)
            # Implementation of the Vasicek model using the previous
            # interest rate.
            r = math.exp(-a*delta)*r + b*(1-math.exp(-a*delta)) + sigma\
                * math.sqrt((1-math.exp(-2*a*delta))/(2*a))*Z
            # Returning a simulated path up until a negative
            # interest rate if we do not want to allow negative
            # interest rates.
            if not allow_neg and r < 0:
                break
            path.append(r)
        # Adding each simulated path to the total list of paths
        paths.append(path)
    # Returns simulated path or paths of historical, current and future
    # interest rates.
    return paths if num_paths > 1 else paths

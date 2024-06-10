import math
import numpy as np
import random
import statistics


class SimulatedAsset:
    """An abstract class where assets are simulated using the chosen model.

    Parameters
    ----------
    name : str
        The name of the asset.
    current_price : int or float
        The current price of the asset.
    dividend_yield : int or float, optional
        The (continuous) dividend yield of the asset. This is defualted to
        zero.
    volatility : int or float
        The volatility of the asset.

    Attributes
    ----------
    name : str
        The name of the asset.
    current_price : int or float
        The current price of the asset.
    dividend_yield : int or float, optional
        The (continuous) dividend yield of the asset. This is defualted to
        zero.
    volatility : int or float
        The volatility of the asset.

    Raises
    ------
    NameError
        If either the name is not a string or an empty string.
    ValueError
        If the current_price is not an integer or float or is less than or
        equal to zero.
        If the dividend_yield is not an integer or float or is less than zero.
        If the volatility is not an integer or float or is less than zero.
    """

    def __init__(self, name, current_price, *, dividend_yield=0, volatility):
        # Initialise instance variables
        self.name = name
        self.current_price = current_price
        self.dividend_yield = dividend_yield
        self.volatility = volatility

        # Check variables and raise appropiate errors
        if not isinstance(name, str) or len(name) == 0:
            raise NameError("name must be a non-empty string.")
        if not isinstance(current_price, (int, float)) or current_price <= 0:
            raise ValueError(f"{current_price = } must be a positive number")
        if not isinstance(dividend_yield, (int, float)) or dividend_yield < 0:
            raise ValueError(f"{dividend_yield = } must be a non-negative \
                             number")
        if not isinstance(volatility, (int, float)) or volatility < 0:
            raise ValueError(f"{volatility = } must be a positive number")

    def simulate_path(self, simulated_times, *, interest_rate,
                      current_price=None):
        """Yield simulated prices along a path of times.

        Paramters
        ---------
        simulated_times : list of ints or floats
            A strictly-increasing, non-empty sequence of positive times to be
            simulated.
        interest_rate : int or float
            The risk-free interest rate.
        current_price : int or float, optional
            The current price of the asset if provided. This is defualted to
            None.

        Yields
        ------
        simul_price : float
            The simulated next price found using chosen model.

        Raises
        ------
        ValueError
            If the interest_rate is not an integer or float or is less than or
            equal to zero.
            If the simulated_times are not a strictly-increasing, non_empty
            sequence of positve numbers.
        """
        # Check variables and raise appropiate errors
        if not isinstance(interest_rate, (int, float)) or interest_rate <= 0:
            raise ValueError(f"{interest_rate = } must be a positive number")
        if not isinstance(simulated_times, (list)):
            raise ValueError(f"{simulated_times = } must be a \
                             strictly-increasing, non_empty sequence of \
                                 positve numbers")

        # Set the current_price if not provided
        if current_price is None:
            current_price = self.current_price

        # Iterate over simulated times to check its format and raise appropiate
        # errors
        for i, time in enumerate(simulated_times):
            if time <= 0 or time == simulated_times[i-1]:
                raise ValueError("Simulated times must be a \
                                 strictly-increasing, non_empty sequence of \
                                     positve numbers")

            # In the same iteration, find the next simulated price and set
            # equal to the current price, so that it may be called upon the
            # next step of the iteration
            simul_price = self.simulate_next_price(time,
                                                   interest_rate=interest_rate,
                                                   current_price=current_price)
            current_price = simul_price
            # Yield the next simulated price as instructed
            yield simul_price


class BlackScholesAsset(SimulatedAsset):
    """A subclass where the asset is simulated using the Black-Scholes Model.

    Parameters
    ----------
    name : str
        The name of the asset.
    current_price : int or float
        The current price of the asset.
    dividend_yield : int or float, optional
        The (continuous) dividend yield of the asset. This is defualted to
        zero.
    volatility : int or float
        The volatility of the asset.

    Attributes
    ----------
    name : str
        The name of the asset.
    current_price : int or float
        The current price of the asset.
    dividend_yield : int or float, optional
        The (continuous) dividend yield of the asset. This is defualted to
        zero.
    volatility : int or float
        The volatility of the asset.

    Raises
    ------
    NameError
        If either the name is not a string or an empty string.
    ValueError
        If the current_price is not an integer or float or is less than or
        equal to zero.
        If the dividend_yield is not an integer or float or is less than zero.
        If the volatility is not an integer or float or is less than zero.
    """

    def __init__(self, name, current_price, *, dividend_yield=0, volatility):
        # Call on the constructor from the parent class: SimulatedAsset
        super().__init__(name, current_price, dividend_yield=dividend_yield,
                         volatility=volatility)
        # The SimulatedASset constructor contained checks and raises of
        # appropiate errors, therefore not needed again in this constructor
        # due to super proxy.

    def simulate_next_price(self, time, *, interest_rate, current_price=None):
        """Simulate the next price of the asset using the Black-Scholes model.

        Parameters
        ----------
        time : int or float
            The time between the current price and the next price.
        interest_rate : int or float
            The risk-free interest rate.
        current_price : int or float, optional
            The current price of the asset if provided. This is defualted to
            None.

        Returns
        -------
        simul_price : float
            The simulated next price.

        Raises
        ------
        ValueError
            If the interest_rate is not an integer or float or is less than or
            equal to zero.
            If the simulated_times are not a strictly-increasing, non-empty
            sequence of positve numbers.
        """
        # Check variables and raise appropiate errors
        if not isinstance(interest_rate, (int, float)) or interest_rate <= 0:
            raise ValueError(f"{interest_rate = } must be a positive number")
        if not isinstance(time, (int, float)) or time <= 0:
            raise ValueError(f"{time = } must be a positive number")

        # Set the current_price if not provided and raise possible errors
        if current_price is None:
            current_price = self.current_price
        elif not isinstance(current_price, (int, float)) or current_price <= 0:
            raise ValueError(f"{current_price = } must be a positive number")

        # Calculate the next simulated price using Black-Scholes formula
        simul_price = current_price*math.exp((interest_rate
                                              - self.dividend_yield
                                              - (self.volatility**2)/2)*time
                                             + self.volatility
                                             * random.gauss(0,
                                                            math.sqrt(time)))
        return simul_price


class MertonAsset(SimulatedAsset):
    """A subclass where the asset is simulated using the Merton Model.

    Parameters
    ----------
    name : str
        The name of the asset.
    current_price : int or float
        The current price of the asset.
    dividend_yield : int or float, optional
        The (continuous) dividend yield of the asset. This is defualted to
        zero.
    volatility : int or float
        The volatility of the asset.
    jump_rate : int or float
        The jump_rate is used in the Poisson distribution to overall define the
        compound Poisson process
    jump_alpha : int or float
        The jump_alpha is used in the normal distribution to overall define the
        compound Poisson process.
    jump_beta : int or float
        The jump_beta is used in the normal distribution to overall define the
        compound Poisson process.

    Attributes
    ----------
    name : str
        The name of the asset.
    current_price : int or float
        The current price of the asset.
    dividend_yield : int or float, optional
        The (continuous) dividend yield of the asset. This is defualted to
        zero.
    volatility : int or float
        The volatility of the asset.
    jump_rate : int or float
        The jump_rate is used in the Poisson distribution to overall define the
        compound Poisson process
    jump_alpha : int or float
        The jump_alpha is used in the normal distribution to overall define the
        compound Poisson process.
    jump_beta : int or float
        The jump_beta is used in the normal distribution to overall define the
        compound Poisson process.

    Raises
    ------
    NameError
        If either the name is not a string or an empty string.
    ValueError
        If the current_price is not an integer or float or is less than or
        equal to zero.
        If the dividend_yield is not an integer or float or is less than zero.
        If the volatility is not an integer or float or is less than zero.
        If the jump_rate is not an integer or float or is less than or equal to
        zero.
        If the jump_alpha is not an integer or float.
        If the jump_beta is not an integer or float or is less than or equal to
        zero.
    """

    def __init__(self, name, current_price, *, dividend_yield=0, volatility,
                 jump_rate, jump_alpha, jump_beta):
        # Call on the constructor from the parent class: SimulatedAsset
        super().__init__(name, current_price, dividend_yield=dividend_yield,
                         volatility=volatility)

        # Initialise additional instance variables
        self.jump_rate = jump_rate
        self.jump_alpha = jump_alpha
        self.jump_beta = jump_beta

        # Check additional variables and raise appropiate errors
        if not isinstance(jump_rate, (int, float)) or jump_rate <= 0:
            raise ValueError(f"{jump_rate = } must be a positive number")
        if not isinstance(jump_alpha, (int, float)):
            raise ValueError(f"{jump_alpha = } must be a number")
        if not isinstance(jump_beta, (int, float)) or jump_beta <= 0:
            raise ValueError(f"{jump_beta = } must be a positive number")

    def simulate_next_price(self, time, *, interest_rate, current_price=None):
        """Simulate the next price of the asset using the Merton model.

        Parameters
        ----------
        time : int or float
            The time between the current price and the next price.
        interest_rate : int or float
            The risk-free interest rate.
        current_price : int or float, optional
            The current price of the asset if provided. This is defualted to
            None.

        Returns
        -------
        simul_price : float
            The simulated next price.

        Raises
        ------
        ValueError
            If the interest_rate is not an integer or float or is less than or
            equal to zero
            If the simulated_times are not a strictly-increasing, non_empty
            sequence of positve numbers.
        """
        # Check variables and raise appropiate errors
        if not isinstance(interest_rate, (int, float)) or interest_rate <= 0:
            raise ValueError(f"{interest_rate = } must be a positive number")
        if not isinstance(time, (int, float)) or time <= 0:
            raise ValueError(f"{time = } must be a positive number")

        # Set the current_price if not provided and raise possible errors
        if current_price is None:
            current_price = self.current_price
        elif not isinstance(current_price, (int, float)) or current_price <= 0:
            raise ValueError(f"{current_price = } must be a positive number")

        # Define N(t): Poisson process; Y(t): Compound Poisson process;
        # z: Brownian motion
        Nt = np.random.poisson(self.jump_rate * time)
        Yt = Nt * random.gauss(self.jump_alpha, self.jump_beta)
        z = random.gauss(0, math.sqrt(time))

        # Calculate the next simulated price using Merton formula
        simul_price = current_price*math.exp((interest_rate
                                              - self.dividend_yield
                                              - (self.volatility**2)/2)*time
                                             + self.volatility*z+Yt)
        return simul_price


class BermudanOption:
    """A Bermudan option made from a simulated asset.

    Parameters
    ----------
    name : str
        The name of the asset.
    underlying : SimulatedAsset
        The underlying simulated asset for the Bermudan option.
    exercise_times : list of ints or floats
        A strictly-increasing, non-empty sequence of positive times at which
        the option can be exercised.
    option_type : str
        This is the type of the Bermudan option, either a 'call' or 'put'.
    strike_price : int or float
        The strike price of the Bermudan option.

    Attributes
    ----------
    name : str
        The name of the asset.
    underlying : SimulatedAsset
        The underlying simulated asset for the Bermudan option.
    exercise_times : list of ints or floats
        A strictly-increasing, non-empty sequence of positive times at which
        the option can be exercised.
    option_type : str
        This is the type of the Bermudan option, either a 'call' or 'put'.
    strike_price : int or float
        The strike price of the Bermudan option.

    Methods
    -------
    payoff(current_price=None)
        Find the payoff of the option using current price and strike price.
    value_estimate(branches, simulations, *, confidence_level=0.95,
                   interest_rate)
        Calculate the minimum, point and maximum value estimate of the price of
        the option.
    tree_generator(branches, interest_rate)
        Generate a tree of node sequences and their corresponding prices.
    generate_node_sequences(self, k, branches)
        Generate node sequences iteratively.

    Raises
    ------
    TypeError
        If underlying is not an instance of SimulatedAsset.
        If option_type is not either 'call' or 'put'.
    NameError
        If either the name is not a string or an empty string.
    ValueError
        If the exercise_times are not a strictly-increasing, non_empty sequence
        of positve numbers.
        If the strike_price is not an integer or float or is less than or equal
        to zero.
    """

    def __init__(self, name, underlying, *, exercise_times, option_type,
                 strike_price):

        # Assign attributes
        self.name = name
        self.underlying = underlying
        self.exercise_times = exercise_times
        self.option_type = option_type
        self.strike_price = strike_price

        # Check attributes and raise appropiate errors
        if not isinstance(name, str) or len(name) == 0:
            raise NameError("name must be a non-empty string.")
        if not isinstance(underlying, SimulatedAsset):
            raise TypeError(f"{underlying = } must be an instance of \
                            SimulatedAsset")
        if not isinstance(exercise_times, (list)):
            raise ValueError(f"{exercise_times = } must be a \
                             strictly-increasing, non_empty sequence of \
                                 positve numbers")
        if option_type not in ['put', 'call']:
            raise TypeError(f'{option_type = } must be either "put" or "call"')
        if not isinstance(strike_price, (int, float)) or strike_price <= 0:
            raise ValueError(f"{strike_price = } must be a positive number")
        for i, time in enumerate(exercise_times):
            if time <= 0 or time == exercise_times[i-1]:
                raise ValueError(f"{exercise_times = } must be a \
                                 strictly-increasing, non_empty sequence of \
                                     positve numbers")

    @property
    def maturity_time(self):
        """A property that retrieves the final exercise time.

        Returns
        -------
        float or int
            The final exercise time.
        """
        return max(self.exercise_times)

    def payoff(self, current_price=None):
        """Find the payoff of the option using current price and strike price.

        Paramters
        ---------
        current_price : int or float, optional
            The current price of the asset if provided. This is defualted to
            None.

        Returns
        -------
        payoff : int or float
            The payoff of the option at the current price.

        Raises
        ------
        ValueError
            If the current_price is not an integer or float or is less than or
            equal to zero.
        """
        # Set the current_price if not provided and raise possible errors
        if current_price is None:
            current_price = self.underlying.current_price
        elif not isinstance(current_price, (int, float)) or current_price <= 0:
            raise ValueError(f"{current_price = } must be a positive number")

        # Calculate the payoff depending on whether the option is a 'call' or a
        # 'put'
        if self.option_type == 'call':
            payoff = max(current_price - self.strike_price, 0)
        else:
            payoff = max(self.strike_price - current_price, 0)
        return payoff

    def value_estimate(self, branches, simulations, *, confidence_level=0.95,
                       interest_rate):
        """Calculate the minimum, point and maximum value estimate.

        Parameters
        ----------
        branches : int
            The (whole) number of branches (at least 2) each non-terminal node
            in the tree has.
        simulations : int
            The (whole) number of Monte-Carlo simulations (at least 2) to
            perform.
        confidence interval : float, optional
            The confidence level for the (conservative, approximate) confidence
            interval, which should be a number strictly between 0 and 1, with
            default value 0.95.
        interest_rate : int or float
            The risk-free interest_rate.

        Returns
        -------
        tuple
            The minimum, point and maximum value estimate.

        Raises
        ------
        ValueError
            If branches is not an integer is not more than or equal to two.
            If simulations is not an integer is not more than or equal to two.
            If confidence_interval is not a float or does not lie strictly
            between zero and one.
            If the interest_rate is not an integer or float or is less than or
            equal to zero
        """
        # Check attributes and raise appropiate errors
        if not isinstance(branches, int) or branches < 2:
            raise ValueError(f"{branches = } must be an integer of at least 2")
        if not isinstance(simulations, int) or simulations < 2:
            raise ValueError(f"{simulations = } must be an integer of at \
                             least 2")
        if not isinstance(confidence_level, float) or not (0 < confidence_level
                                                           < 1):
            raise ValueError(f"{confidence_level = } must be anumber strictly \
                             between 0 and 1")
        if not isinstance(interest_rate, (int, float)) or interest_rate <= 0:
            raise ValueError(f"{interest_rate = } must be a positive number")

        # Create empty lists where eventually simulations of a high and low
        # estimate at the initial node () will be added
        High_initial_node = []
        Low_initial_node = []

        # Perform Monte-Carlo simulations
        for sim in range(simulations):
            # generate a price tree and create three empty dictionaries
            tree = self.tree_generator(branches, interest_rate)
            payoff_tree = {}
            High_tree = {}
            Low_tree = {}

            # Iterate through the node sequences of the tree in reverse.
            for node_seq, value in reversed(tree.items()):

                # Determine differences in payoff when the length of the node
                # varies
                if len(node_seq) > 0:
                    # All non-zero node sequences will have their payoff
                    # calculated
                    payoff_tree[node_seq] = self.payoff(value)
                    # Find deltak which represents the time between each
                    # exercise time
                    exercise_time_index = len(node_seq) - 1
                    if exercise_time_index > 0:
                        deltak = self.exercise_times[exercise_time_index]
                        - self.exercise_times[exercise_time_index-1]
                    else:
                        deltak = self.exercise_times[0]

                else:
                    # Since 0 can never be an exercise time, the payoff at the
                    # initial node is zero
                    payoff_tree[()] = 0

                # The next if else statement separates the terminal and
                # non-terminal nodes
                if len(node_seq) == len(self.exercise_times):
                    # According to the instructions, the high and low estimates
                    # are equal to the payoff at the terminal nodes
                    High_tree[node_seq] = payoff_tree[node_seq]
                    Low_tree[node_seq] = payoff_tree[node_seq]

                # Now the non-terminal nodes
                else:
                    sum_low_hat = 0
                    sum_high_next_node_seq = 0
                    # Create generator that yields all possible nodes from the
                    # node currently in the reverse iteration
                    next_node_seq = [node_seq + (a,) for a in range(branches)]
                    # Iterate through each possible node in the generator
                    for a in next_node_seq:
                        sum_high_next_node_seq += High_tree[a]
                        # Create a similar generator to before that yields all
                        # possible nodes apart from the node currently in the
                        # first generator
                        low_prime = [Low_tree[a_prime] for a_prime in
                                     next_node_seq if a_prime != a]
                        average_low_prime = (np.exp(-1 * interest_rate
                                                    * deltak) / (branches-1)) \
                            * sum(low_prime)
                        # Determine which value the low_hat should be at each a
                        if average_low_prime <= payoff_tree[node_seq]:
                            low_hat = payoff_tree[node_seq]
                        else:
                            low_hat = np.exp(-1*interest_rate * deltak) \
                                * Low_tree[a]
                        sum_low_hat += low_hat
                    # Implement the max function as instructed from the problem
                    High_tree[node_seq] = max(payoff_tree[node_seq],
                                              ((math.exp(-1 * interest_rate
                                                         * deltak)) / branches)
                                              * sum_high_next_node_seq)
                    # Find the low estimate by averaging the low_hats
                    Low_tree[node_seq] = (1 / branches) * sum_low_hat

            # Append the the initial node of the high estimate and low estimate
            # trees to the empty lists
            High_initial_node.append(High_tree[()])
            Low_initial_node.append(Low_tree[()])

        # Find the means of the high and low estimates
        L_mean = np.mean(Low_initial_node)
        H_mean = np.mean(High_initial_node)

        # Find the minimum, point and maximum etimate of the price of the
        # option using the formula given
        V_min = L_mean - ((np.std(Low_initial_node)
                           / math.sqrt(simulations))) \
            * statistics.NormalDist(0, 1).inv_cdf((1 + confidence_level) / 2)
        point_estimate = (H_mean + L_mean) / 2
        V_max = H_mean + ((np.std(High_initial_node)
                           / math.sqrt(simulations))) \
            * statistics.NormalDist(0, 1).inv_cdf((1 + confidence_level)/2)

        # Return these results as a tuple
        return (V_min, point_estimate, V_max)

    def tree_generator(self, branches, interest_rate):
        """Generate a tree of node sequences and their corresponding prices.

        Parameters
        ----------
        branches : int
            The (whole) number of branches (at least 2) each non-terminal node
            in the tree has.
        interest_rate : int or float
            The risk-free interest_rate.

        Returns
        -------
        tree : dict
            A tree of node sequences and asset prices

        Raises
        ------
        ValueError
            If branches is not an integer is not more than or equal to two.
            If the interest_rate is not an integer or float or is less than or
            equal to zero
        """
        # Check variables and raise appropiate errors
        if not isinstance(branches, int) or branches < 2:
            raise ValueError(f"{branches = } must be an integer of at least 2")
        if not isinstance(interest_rate, (int, float)) or interest_rate <= 0:
            raise ValueError(f"{interest_rate = } must be a positive number")

        # Create an empyt dictionary which will eventually store the node
        # sequences and their corresponding asset prices
        tree = {}

        # Call the instance of SimulatedAsset to obtain the current price of
        # the asset and set this equal to the initial node of the tree
        current_price = self.underlying.current_price
        tree[()] = current_price

        # Iterate through each of the exercise times
        for k in range(0, len(self.exercise_times)):
            # Find deltak which represents the time between each exercise time
            if k == 0:
                deltak = self.exercise_times[0]
            else:
                deltak = self.exercise_times[k] - self.exercise_times[k-1]

            # Iterate through all possible node sequences at the number of
            # exercise times so far
            for node_seq in self.generate_node_sequences((k), branches):
                # Iterate through the number of branches
                for i in range(branches):
                    # Create the next prices at each new node and set equal to
                    # the value of the corresponding key (node sequence) in the
                    # tree dicitonary
                    next_price = self.underlying.\
                        simulate_next_price(deltak,
                                            interest_rate=interest_rate,
                                            current_price=tree[node_seq])
                    tree[node_seq + (i,)] = next_price
        return tree

    def generate_node_sequences(self, k, branches):
        """Generate node sequences iteratively.

        Parameters
        ----------
        k : int
            k is the iterative index in allowing for the tree node sequences to
            be formed.
        branches : int
            The (whole) number of branches (at least 2) each non-terminal node
            in the tree has.

        Yields
        ------
        tuple
            A sequence that represents a specific node in the tree
        """
        # The only possible node sequence that is before the first branches is
        # ()
        if k == 0:
            yield ()
        else:
            # Iterate through all previous nodes and add the number of branches
            # onto each one
            for seq in self.generate_node_sequences(k-1, branches):
                for i in range(branches):
                    yield seq + (i,)

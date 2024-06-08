import math

def find_root(f, a, b, tol=10**-9, max_iter=math.inf):
    """Returns an approximate root of a give function, f.
    
    Parameters
    ----------
    f : function
        A continuous function that takes one parameter, is defined on the interval [a,b], and where an approximate root is trying to be found.
    a : int
        Lower bound of the interval.
    b : int
        Upper bound of the interval.
    tol : float, optional
        Tolerance for root approximation which defaults to 10^(-9) and therefore assumed to be non-negative.
    max_iter : float, optional
        The maximum number of iterations which defaults to infinity.
    
    Returns
    -------
    float
        Value of the approximate root, otherwise None.
    """
    # Checking whether a or b are already an approximate root of f
    if abs(f(a)) <= tol:
        return a
    elif abs(f(b)) <= tol:
        return b
    # Checking that f(a) and f(b) have opposite signs
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
        # Defining y has the iterative formula to calculate the next approximate root of f
        y = (x_negative * f(x_positive) - x_positive *
             f(x_negative))/(f(x_positive)-f(x_negative))
        # Creating a conditional statement on whether y is or is not an approximate root of f
        if abs(f(y)) <= tol or y == x_negative or y == x_positive:
        # Returning y if any of the above statments are true and therefore indicating that this iteration has provided an approximate root of f
            return y
        # Assigning the value of y to either x_negative or x_positive, on the basis of not satisfying the above conditions, and to then be placed back into the iterative formula y
        elif f(y) < 0:
            x_negative = y
        elif f(y) > 0:
            x_positive = y
    return y
    
if __name__ == '__main__':
    def f(x):
        return -85*x**2 - 84*x + 23
    x = find_root(f, 0, 1)
    print(f'{x = }, {f(x) = }')
    y = find_root(f, 0, 1, max_iter=5)
    print(f'{y = }, {f(y) = }')
    z = find_root(math.cos, 1, 2, tol=0)
    print(f'{z = }, {math.cos(z) = }')

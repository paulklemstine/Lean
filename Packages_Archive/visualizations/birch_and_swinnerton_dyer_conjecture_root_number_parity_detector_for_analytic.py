from typing import Literal

def parity_from_root_number(root_number: Literal[-1, 1]) -> str:
    """
    Parity theorem  (-1)^{ord_{s=1} Lambda} = w.  Given the global root number
    w = +-1 of a curve, return the forced parity of the analytic rank (and, under
    BSD, of the Mordell-Weil rank).  w = -1 forces odd rank >= 1, hence (under BSD)
    infinitely many rational points.  Complexity: O(1).
    """
    if root_number == -1:
        return "odd rank (>= 1): central L-value must vanish; infinitely many points under BSD"
    if root_number == 1:
        return "even rank: central L-value parity is even (rank 0 possible)"
    raise ValueError("root number must be +1 or -1")

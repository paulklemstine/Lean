from typing import Tuple

Word = Tuple[int, ...]

def weight_of_sum(wx: int, wy: int, ov: int) -> int:
    """Inclusion-exclusion (Theorem 4.1):  wt(x+y) = wt(x) + wt(y) - 2*overlap(x,y).

    Lets you update the weight of x+y from cached weights and overlap, with no recount.
    """
    return wx + wy - 2 * ov

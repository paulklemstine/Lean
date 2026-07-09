from typing import Sequence


def in_tail_zero_ideal(f: Sequence[int], n: int) -> bool:
    """Decide membership f in I_n = {f : f(i)=0 for all i>=n} in a product ring.

    Runs in O(len(f)) by scanning the tail from index n onward.
    """
    return all(f[i] == 0 for i in range(n, len(f)))

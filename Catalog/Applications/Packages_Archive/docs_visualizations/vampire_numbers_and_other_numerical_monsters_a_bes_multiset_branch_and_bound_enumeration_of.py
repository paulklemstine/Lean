from itertools import combinations_with_replacement
from typing import List

def narcissistic_with_d_digits(d: int) -> List[int]:
    """Enumerate all d-digit narcissistic numbers without scanning 10**d integers.

    Key idea: the digit-power sum depends only on the MULTISET of digits, not on
    their order. So iterate over multisets of d digits (there are C(d+9, 9) of
    them, vastly fewer than 10**d), compute the candidate value v = sum(c**d),
    and accept v iff it has exactly d digits AND its own digit multiset equals
    the multiset we started from.
    """
    results: List[int] = []
    lo, hi = 10 ** (d - 1), 10 ** d
    for multiset in combinations_with_replacement(range(10), d):
        v = sum(c ** d for c in multiset)
        if lo <= v < hi:
            digits_of_v = sorted(int(ch) for ch in str(v))
            if digits_of_v == sorted(multiset):
                results.append(v)
    return sorted(results)

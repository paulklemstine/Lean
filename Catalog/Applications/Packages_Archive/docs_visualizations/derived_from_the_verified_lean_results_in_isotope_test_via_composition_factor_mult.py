from math import prod
from typing import List, Tuple

def isotope_test(factors_a: List[int],
                 factors_b: List[int]) -> Tuple[bool, int, int]:
    order_a, order_b = prod(factors_a), prod(factors_b)
    same = sorted(factors_a) == sorted(factors_b)
    if same:
        assert order_a == order_b, 'mass law violated -- impossible'
    return same, order_a, order_b

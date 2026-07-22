from itertools import product
from typing import Callable

Valuation = tuple[bool, ...]

def exhaustive_acceptance_count(m: int, evaluate: Callable[[Valuation], bool]) -> int:
    if m < 0:
        raise ValueError("m must be nonnegative")
    return sum(1 for v in product((False, True), repeat=m) if evaluate(v))

from itertools import product
from typing import Callable, Optional, Tuple

Op = Callable[[int, int], int]

def recover_unit(n: int, m1: Op) -> Optional[int]:
    """Unique two-sided identity of m1, if any."""
    for e in range(n):
        if all(m1(e, x) == x and m1(x, e) == x for x in range(n)):
            return e
    return None

def rigidity_witness(n: int, m1: Op, m2: Op) -> Tuple[Optional[int], bool]:
    """Return (recovered unit, whether m2 is forced equal to m1)."""
    e = recover_unit(n, m1)
    same_op = all(m1(a, b) == m2(a, b)
                  for a, b in product(range(n), repeat=2))
    return e, same_op

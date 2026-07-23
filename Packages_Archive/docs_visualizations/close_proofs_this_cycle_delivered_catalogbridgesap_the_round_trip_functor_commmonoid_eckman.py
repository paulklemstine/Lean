from typing import Callable, Tuple

Op = Callable[[int, int], int]

class EHData:
    def __init__(self, n: int, m1: Op, m2: Op, unit: int) -> None:
        self.n, self.m1, self.m2, self.unit = n, m1, m2, unit

def of_comm_monoid(n: int, mul: Op, one: int) -> EHData:
    """CommMonoid -> EH data: duplicate the multiplication."""
    return EHData(n, mul, mul, one)

def to_comm_monoid(E: EHData) -> Tuple[int, Op, int]:
    """EH data -> CommMonoid: keep (m1, unit); m2 = m1 by same_op."""
    return E.n, E.m1, E.unit

from typing import List, Union

Val = Union[int, float]

def attained_at_least_twice(w: List[Val]) -> bool:
    if len(w) < 2:
        return False
    m = min(w)
    return sum(1 for v in w if v == m) >= 2

def corner_two_monomials(a: Val, b: Val) -> bool:
    closed = (a == b)
    assert closed == attained_at_least_twice([a, b])  # Theorem 6.1
    return closed

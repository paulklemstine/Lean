from typing import Set

def circulant_two_symmetric(n: int, S: Set[int]) -> bool:
    assert n % 2 == 0, 'need even n'
    d: int = (n // 2) % n
    S = {s % n for s in S}
    if (1 % n) not in S:
        return False
    if d == 0:
        return False
    return True

from math import factorial
from typing import Callable


def eventually_beats(f: Callable[[int], int], c: int, horizon: int) -> bool:
    """Finite witness for 'f eventually exceeds c^n' up to `horizon`."""
    for cutoff in range(horizon):
        if all(f(n) > c ** n for n in range(cutoff, horizon)):
            return True
    return False


HEAD = {1: 6, 2: 8, 3: 12, 4: 24, 5: 40, 6: 80}


def good_count(n: int) -> int:
    return HEAD.get(n, 2 ** n)


def classify_growth(horizon: int = 40) -> str:
    """Classify a(n): exponential iff some fixed c^n eventually overtakes it."""
    beaten_by_3 = eventually_beats(lambda n: 3 ** n, 1, 1)  # placeholder
    # a(n) is super-exponential iff it beats every c^n; test c=3.
    a_super = eventually_beats(good_count, 3, horizon)
    return "super-exponential" if a_super else "exponential (fixed base)"

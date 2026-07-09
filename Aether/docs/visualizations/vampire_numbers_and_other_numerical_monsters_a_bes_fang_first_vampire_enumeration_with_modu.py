from collections import Counter
from typing import Dict, List, Tuple
def digit_multiset(n: int) -> Counter:
    return Counter(str(n))
def enumerate_vampires(n: int) -> Dict[int, List[Tuple[int, int]]]:
    lo, hi = 10 ** (n - 1), 10 ** n - 1
    results: Dict[int, List[Tuple[int, int]]] = {}
    for x in range(lo, hi + 1):
        for y in range(x, hi + 1):
            if x % 10 == 0 and y % 10 == 0:
                continue
            if ((x - 1) * (y - 1)) % 9 != 1 % 9:
                continue
            if x % 3 == 1 or y % 3 == 1:
                continue
            v = x * y
            if len(str(v)) != 2 * n:
                continue
            if digit_multiset(v) == digit_multiset(x) + digit_multiset(y):
                results.setdefault(v, []).append((x, y))
    return results

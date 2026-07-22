from typing import Callable, List, Optional, Tuple

def v2(a: int) -> int:
    if a == 0:
        return 10 ** 9
    a, e = abs(a), 0
    while a % 2 == 0:
        a //= 2; e += 1
    return e

def check_law(t: List[int], m: int,
              law: Callable[[int], int]) -> Optional[Tuple[int, int, int, int]]:
    """Verify nu_2(t[(m-1)*n + j]) == law(n) for all valid n, j. Returns None if
    the law holds, else the first failing (n, j, actual, predicted)."""
    block = m - 1
    n = 0
    while block * n + block - 1 < len(t):
        pred = law(n)
        for j in range(block):
            actual = v2(t[block * n + j])
            if actual != pred:
                return (n, j, actual, pred)
        n += 1
    return None

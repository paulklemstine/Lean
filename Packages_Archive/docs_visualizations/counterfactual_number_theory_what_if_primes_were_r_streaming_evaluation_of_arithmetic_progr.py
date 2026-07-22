import math
from typing import Iterable

def partial_sums(cutoffs: Iterable[int], q: int = 1, a: int = 0) -> list[tuple[int, float]]:
    if q <= 0 or a < 0:
        raise ValueError("require q > 0 and a >= 0")
    out: list[tuple[int, float]] = []
    total = 0.0
    targets = sorted(cutoffs)
    if not targets or targets[0] <= 0:
        raise ValueError("cutoffs must be positive")
    j = 0
    for n in range(targets[-1]):
        total += 1.0 / math.log(q * n + a + 2)
        if n + 1 == targets[j]:
            out.append((n + 1, total))
            j += 1
            if j == len(targets):
                break
    return out

if __name__ == "__main__":
    for row in partial_sums([10, 100, 1000, 10000], 4, 1):
        print(row)

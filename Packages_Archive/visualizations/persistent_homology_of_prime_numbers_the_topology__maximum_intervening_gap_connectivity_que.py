from typing import Sequence

def connection_threshold(x: Sequence[float], i: int, j: int) -> float:
    if i > j: i, j = j, i
    if i == j: return 0.0
    return max(x[k + 1] - x[k] for k in range(i, j))

print(connection_threshold([2,3,5,7,11,13], 0, 5))

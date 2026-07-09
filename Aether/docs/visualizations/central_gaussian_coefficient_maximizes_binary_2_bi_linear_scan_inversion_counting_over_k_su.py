from itertools import combinations
from typing import Tuple, List

def class_row_linear_scan(n: int, k: int) -> List[int]:
    """Coefficient row of [n choose k]_q via O(n) inversion counting per word.

    For each k-subset of positions, the inversion number is accumulated with a
    single left-to-right scan: maintain the count of ones seen so far and add it
    whenever a zero is met (each such zero closes that many scattered 10 pairs).
    Total cost O(n * C(n,k)).
    """
    row = [0] * (k * (n - k) + 1)
    for positions in combinations(range(n), k):
        ones = set(positions)
        seen_ones = 0
        inv = 0
        for p in range(n):
            if p in ones:
                seen_ones += 1
            else:
                inv += seen_ones
        row[inv] += 1
    return row

from __future__ import annotations
from math import comb

def sum_two_edges(n: int) -> list[tuple[int, int]]:
    if n < 0:
        raise ValueError("n must be nonnegative")
    values = [1] * n
    return [(i, j) for i in range(n) for j in range(i + 1, n)
            if values[i] + values[j] == 2]

if __name__ == "__main__":
    for n in range(2, 11):
        edges = sum_two_edges(n)
        print(n, len(edges), comb(n, 2))

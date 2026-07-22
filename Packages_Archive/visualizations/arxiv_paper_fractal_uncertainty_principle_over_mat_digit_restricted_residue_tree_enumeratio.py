from __future__ import annotations
from typing import Sequence

def digit_restricted_set(q: int, depth: int, digits: Sequence[int]) -> list[int]:
    if q < 2 or depth < 0 or any(d < 0 or d >= q for d in digits):
        raise ValueError("invalid tree parameters")
    leaves = [0]
    place = 1
    for _ in range(depth):
        leaves = [x + d * place for x in leaves for d in sorted(set(digits))]
        place *= q
    return leaves

if __name__ == "__main__":
    leaves = digit_restricted_set(5, 3, [0, 1])
    print(leaves)
    print("leaf count:", len(leaves), "expected:", 2 ** 3)

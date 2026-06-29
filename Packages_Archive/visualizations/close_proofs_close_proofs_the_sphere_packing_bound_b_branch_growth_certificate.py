from __future__ import annotations
import math
from typing import List, Tuple

Triple = Tuple[int, int, int]


def child_B(t: Triple) -> Triple:
    a, b, c = t
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def b_branch_hypotenuses(depth: int) -> List[int]:
    t: Triple = (3, 4, 5)
    seq: List[int] = [t[2]]
    for _ in range(depth):
        t = child_B(t)
        assert t[2] > 5 * seq[-1]          # sharp five-fold growth
        assert t[0] * t[0] + t[1] * t[1] == t[2] * t[2]
        seq.append(t[2])
    return seq


if __name__ == "__main__":
    seq = b_branch_hypotenuses(8)
    print('hypotenuses:', seq)
    for i in range(len(seq) - 1):
        print(f'  ratio {seq[i+1]/seq[i]:.5f}')
    print(f'limit 3+2*sqrt(2) = {3 + 2 * math.sqrt(2):.5f}')

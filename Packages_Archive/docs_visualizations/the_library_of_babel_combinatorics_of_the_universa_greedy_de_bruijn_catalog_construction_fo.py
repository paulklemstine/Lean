from __future__ import annotations
from typing import List

def de_bruijn(b: int, n: int) -> str:
    """Construct a de Bruijn sequence B(b, n): a cyclic string of length b^n over
    the alphabet {0,...,b-1} in which every length-n word appears exactly once as
    a contiguous (cyclic) substring.  Uses the FKM / 'prefer-largest' algorithm,
    which runs in time O(b^n) -- linear in the output -- and serves as an optimal
    'catalog' enumerating every length-n pattern of a mini-Library in one sweep.
    """
    a: List[int] = [0] * (b * n)
    seq: List[int] = []

    def db(t: int, p: int) -> None:
        if t > n:
            if n % p == 0:
                seq.extend(a[1:p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for j in range(a[t - p] + 1, b):
                a[t] = j
                db(t + 1, t)

    db(1, 1)
    return "".join(str(x) for x in seq)

if __name__ == "__main__":
    s = de_bruijn(4, 3)
    cyc = s + s[:2]
    assert len({cyc[i:i + 3] for i in range(len(s))}) == 4 ** 3
    print(len(s), s)

from fractions import Fraction
from math import comb
from typing import List

Seq = List[Fraction]

def binomial_convolution(a: Seq, b: Seq) -> Seq:
    """Counting sequence of the species product F.G (Theorem 3.2 / 3.8).

    (a * b)_n = sum_{i+j=n} C(n, i) a_i b_j.
    """
    n_max = min(len(a), len(b))
    out: Seq = []
    for n in range(n_max):
        out.append(sum(Fraction(comb(n, i)) * a[i] * b[n - i] for i in range(n + 1)))
    return out

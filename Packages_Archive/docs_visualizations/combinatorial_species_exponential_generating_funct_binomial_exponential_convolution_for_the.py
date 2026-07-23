from fractions import Fraction
from math import comb
from typing import Dict

Seq = Dict[int, Fraction]


def binomial_convolution(a: Seq, b: Seq) -> Seq:
    """Binomial / exponential convolution (a (*) b)_n = sum C(n,i) a_i b_{n-i}.

    This is the counting sequence of the structural product of two combinatorial
    species; its exponential generating function is the ordinary product of the
    factors' EGFs. The positive weights C(n,i) preserve the unique-extremal-pair
    structure, so the order and degree still add exactly. Complexity
    O(|supp a| * |supp b|) integer-binomial evaluations.
    """
    out: Seq = {}
    for i, ai in a.items():
        for j, bj in b.items():
            n = i + j
            out[n] = out.get(n, Fraction(0)) + Fraction(comb(n, i)) * ai * bj
    return {n: c for n, c in out.items() if c != 0}

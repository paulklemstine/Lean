from fractions import Fraction
from typing import Dict

Seq = Dict[int, Fraction]


def cauchy_convolution(f: Seq, g: Seq) -> Seq:
    """Finitely supported Cauchy convolution (f * g)_n = sum_{i+j=n} f_i g_j.

    Iterates over the (finite) supports of f and g, accumulating products into
    index i + j. Complexity O(|supp f| * |supp g|). The extremal index
    ord f + ord g receives exactly one contribution, f_{ord f} * g_{ord g},
    which is nonzero in an integral domain — the engine behind exact additivity.
    """
    out: Seq = {}
    for i, a in f.items():
        if a == 0:
            continue
        for j, b in g.items():
            if b == 0:
                continue
            out[i + j] = out.get(i + j, Fraction(0)) + a * b
    return {n: c for n, c in out.items() if c != 0}

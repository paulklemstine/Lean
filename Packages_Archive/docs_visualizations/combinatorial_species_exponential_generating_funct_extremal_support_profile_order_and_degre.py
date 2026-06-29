from fractions import Fraction
from math import inf
from typing import Dict, Union

Seq = Dict[int, Fraction]
Ext = Union[int, float]


def extremal_indices(f: Seq) -> tuple[Ext, Ext]:
    """Return (ord f, deg f): the least and greatest indices of nonzero coefficients.

    Empty support (the zero sequence) yields (+inf, -inf), matching the lattice
    conventions ord 0 = top and deg 0 = bot. Runs in O(|support|).
    """
    keys = [n for n, c in f.items() if c != 0]
    if not keys:
        return (inf, -inf)
    return (min(keys), max(keys))

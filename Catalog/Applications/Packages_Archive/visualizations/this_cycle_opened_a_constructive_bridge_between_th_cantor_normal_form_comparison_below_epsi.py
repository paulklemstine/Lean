from __future__ import annotations
from typing import Tuple


def cnf_compare(a_terms: Tuple, b_terms: Tuple) -> int:
    """Compare two ordinals below epsilon-0 given in Cantor normal form.

    Each ordinal is a tuple of (exponent, coefficient) pairs in strictly
    decreasing exponent order; an exponent is itself such a tuple (recursively).
    Returns -1, 0, or +1. This is the order whose well-foundedness drives the
    entire termination framework.
    """
    i = 0
    while i < len(a_terms) and i < len(b_terms):
        (ea, ca), (eb, cb) = a_terms[i], b_terms[i]
        c = cnf_compare(ea, eb)
        if c != 0:
            return c
        if ca != cb:
            return -1 if ca < cb else 1
        i += 1
    if len(a_terms) == len(b_terms):
        return 0
    return -1 if len(a_terms) < len(b_terms) else 1

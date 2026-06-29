from __future__ import annotations
from typing import Tuple

Pair = Tuple[bool, bool]  # (evidence_for, evidence_against)

# Belnap value as a 2-bit pair: N=(0,0) F=(0,1) T=(1,0) B=(1,1)
def neg(a: Pair) -> Pair:
    """Negation: swap the two evidence channels."""
    return (a[1], a[0])

def conf(a: Pair) -> Pair:
    """Conflation: swap-then-negate (dualizes the knowledge order)."""
    return (not a[1], not a[0])

def kmeet(a: Pair, b: Pair) -> Pair:   # knowledge meet (consensus)
    return (a[0] and b[0], a[1] and b[1])

def kjoin(a: Pair, b: Pair) -> Pair:   # knowledge join (gather all evidence)
    return (a[0] or b[0], a[1] or b[1])

def tmeet(a: Pair, b: Pair) -> Pair:   # truth conjunction (twist 2nd coord)
    return (a[0] and b[0], a[1] or b[1])

def tjoin(a: Pair, b: Pair) -> Pair:   # truth disjunction (twist 2nd coord)
    return (a[0] or b[0], a[1] and b[1])

def designated(a: Pair) -> bool:
    """Assertible iff there is evidence FOR it (first bit set)."""
    return a[0]

from __future__ import annotations
from math import sqrt
from typing import Dict, Tuple


def wrapping_spectrum(radius: int) -> Tuple[Dict[int, int], float]:
    """Enumerate the length spectrum of the cubic 3-torus up to a lattice radius.

    Returns (multiplicities, systole) where multiplicities maps a squared length
    k = a^2+b^2+c^2 to r_3(k) = number of geodesics of length sqrt(k), and
    systole is the length of the shortest non-constant closed geodesic.
    Complexity: O(radius^3) lattice vectors.
    """
    counts: Dict[int, int] = {}
    rng = range(-radius, radius + 1)
    for a in rng:
        for b in rng:
            for c in rng:
                if (a, b, c) != (0, 0, 0):
                    k = a * a + b * b + c * c
                    counts[k] = counts.get(k, 0) + 1
    systole = sqrt(min(counts)) if counts else 0.0
    return counts, systole

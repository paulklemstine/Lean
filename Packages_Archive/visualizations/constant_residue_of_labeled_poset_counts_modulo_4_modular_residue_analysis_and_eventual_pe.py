from __future__ import annotations
from typing import Dict, List, Optional

def residue_sequence(values: Dict[int, int], modulus: int) -> List[int]:
    """Return [P(n) mod modulus for n in sorted order]."""
    return [values[n] % modulus for n in sorted(values)]

def detect_eventual_period(seq: List[int], max_period: int) -> Optional[int]:
    """Smallest p such that seq is eventually periodic with period p.

    Scans candidate periods; returns the least p for which the tail of the
    sequence repeats with period p, or None if no period <= max_period fits.
    Used to test the modulo-2^k periodicity conjecture.
    """
    n = len(seq)
    for p in range(1, max_period + 1):
        for start in range(n - 2 * p):
            if all(seq[i] == seq[i + p] for i in range(start, n - p)):
                return p
    return None

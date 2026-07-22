from __future__ import annotations
from typing import Dict, List


def v2(n: int) -> int:
    c = 0
    while n % 2 == 0:
        n //= 2
        c += 1
    return c


def n_ell(ell: int) -> int:
    return v2((ell * ell - 1) // 8)


def stratify_by_residue(limit: int) -> Dict[int, List[int]]:
    """Group odd primes below `limit` by residue class mod 8, recording depths.

    Returns a mapping residue (mod 8) -> sorted list of depths n_ell observed.
    Confirms n_ell = 0 exactly for residues 3 and 5.
    """
    def is_prime(x: int) -> bool:
        if x < 2:
            return False
        d = 2
        while d * d <= x:
            if x % d == 0:
                return False
            d += 1
        return True

    table: Dict[int, List[int]] = {}
    for ell in range(3, limit, 2):
        if is_prime(ell):
            table.setdefault(ell % 8, []).append(n_ell(ell))
    return {r: sorted(set(v)) for r, v in sorted(table.items())}

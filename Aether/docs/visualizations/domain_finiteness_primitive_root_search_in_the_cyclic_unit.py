from typing import List, Optional

def prime_factors(m: int) -> List[int]:
    """Distinct prime factors of m."""
    fs, d = [], 2
    while d * d <= m:
        if m % d == 0:
            fs.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        fs.append(m)
    return fs

def primitive_root(p: int) -> Optional[int]:
    """
    Find a generator of (Z/pZ)^x, guaranteed by units_isCyclic / zmod_units_isCyclic.
    g is primitive iff g^((p-1)/l) != 1 (mod p) for every prime l | (p-1).
    Complexity: O(p * #primes(p-1) * log p) in the worst case.
    """
    if p == 2:
        return 1
    phi = p - 1
    fac = prime_factors(phi)
    for g in range(2, p):
        if all(pow(g, phi // l, p) != 1 for l in fac):
            return g
    return None

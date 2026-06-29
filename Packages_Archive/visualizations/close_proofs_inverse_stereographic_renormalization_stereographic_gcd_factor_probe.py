from math import gcd
from typing import Optional

def stereo_factor_probe(N: int, max_q: int = 200) -> Optional[int]:
    """Return a nontrivial factor of N found via stereographic numerators, or None."""
    for q in range(2, max_q + 1):
        for p in range(1, q):
            for numerator in (2 * p * q, q * q - p * p):
                r: int = numerator % N
                if r != 0:
                    g: int = gcd(r, N)
                    if 1 < g < N:
                        return g
    return None

if __name__ == "__main__":
    print("factor of 91 :", stereo_factor_probe(91))
    print("factor of 187:", stereo_factor_probe(187))

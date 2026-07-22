from math import gcd
from typing import List

def spanning_generators(n: int = 12) -> List[int]:
    """All intervals 0 < k < n that span every pitch class (coprime to n).

    By the spanning-iff-coprimality theorem these are exactly the residues with
    gcd(n, k) = 1; their count equals Euler's totient phi(n).
    Complexity: O(n log n).
    """
    return [k for k in range(1, n) if gcd(n, k) == 1]

from typing import Optional

def modular_inverse_pigeonhole(a: int, n: int) -> Optional[int]:
    """
    Constructive inverse b = L_a^{-1}(1) guaranteed by the Domain Finiteness
    Bridge over Z/nZ. Scans the orbit of left multiplication x -> a*x (mod n).
    Returns b with a*b = 1 (mod n), or None if a is a zero divisor.
    Complexity: O(n) ring operations (existence proof). For a prime n and
    a != 0 the bridge guarantees success.
    """
    target = 1 % n
    for b in range(n):
        if (a * b) % n == target:
            return b
    return None

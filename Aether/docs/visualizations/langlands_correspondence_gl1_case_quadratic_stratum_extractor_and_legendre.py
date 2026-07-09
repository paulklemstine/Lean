from typing import List

def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)

def units_mod(n: int) -> List[int]:
    return [a for a in range(1, n) if gcd(a, n) == 1]

def square_roots_of_one(p: int) -> List[int]:
    """The set {x in (Z/pZ)^x : x^2 = 1}; for odd prime p this is exactly {1, p-1}."""
    return [x for x in units_mod(p) if (x * x) % p == 1]

def legendre_symbol(a: int, p: int) -> int:
    """Euler's criterion: (a/p) = a^((p-1)/2) mod p, valued in {-1, 0, +1}."""
    a %= p
    if a == 0:
        return 0
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1

def quadratic_characters(p: int) -> List[str]:
    """The two quadratic Dirichlet characters mod an odd prime p."""
    assert p % 2 == 1
    return ["trivial", "legendre_symbol"]

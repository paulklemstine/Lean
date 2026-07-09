from typing import List, Tuple

def e(n: int, a: int, b: int) -> int:
    return (a * b) % n  # symmetric pairing model on Z_n -> mu_n (exponents)

def aggregate_verify(n: int, g: int,
                     pairs: List[Tuple[int, int]], sigma: int) -> bool:
    lhs: int = e(n, sigma, g)
    rhs: int = 0  # identity of mu_n is exponent 0
    for H, X in pairs:
        rhs = (rhs + e(n, H, X)) % n  # product in mu_n == sum of exponents
    return lhs == rhs

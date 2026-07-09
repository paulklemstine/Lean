from typing import List, Tuple

Point = Tuple[int, int]

def g_add(p: Point, q: Point, n: int) -> Point:
    return ((p[0] + q[0]) % n, (p[1] + q[1]) % n)

def g_smul(x: int, p: Point, n: int) -> Point:
    return ((x * p[0]) % n, (x * p[1]) % n)

def weil_pairing(p: Point, q: Point, n: int) -> int:
    a, b = p; c, d = q
    return (a * d - b * c) % n

def bls_keygen(x: int, g: Point, n: int) -> Point:
    """Public key X = x * g from secret key x."""
    return g_smul(x, g, n)

def bls_sign(x: int, H: Point, n: int) -> Point:
    """Signature sigma = x * H (a single group element)."""
    return g_smul(x, H, n)

def bls_verify(sigma: Point, g: Point, H: Point, X: Point, n: int) -> bool:
    """Accept iff e(sigma, g) = e(H, X)."""
    return weil_pairing(sigma, g, n) == weil_pairing(H, X, n)

def bls_aggregate_verify(sigs: List[Point], g: Point,
                         hashes: List[Point], pubkeys: List[Point],
                         n: int) -> bool:
    """Verify one aggregate point against the product of per-signer pairings.

    The aggregate signature is the single group element sum(sigs); the verifier
    checks e(sum(sigs), g) == product_i e(H_i, X_i).
    """
    agg = (0, 0)
    for s in sigs:
        agg = g_add(agg, s, n)
    lhs = weil_pairing(agg, g, n)
    rhs = 0
    for H, X in zip(hashes, pubkeys):
        rhs = (rhs + weil_pairing(H, X, n)) % n   # product in mu_n = sum of exponents
    return lhs == rhs

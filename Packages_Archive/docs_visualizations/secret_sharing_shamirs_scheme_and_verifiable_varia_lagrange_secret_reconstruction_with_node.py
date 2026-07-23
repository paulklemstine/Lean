from typing import Sequence

def modinv(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)          # Fermat inverse, p prime

def lagrange_weight(nodes: Sequence[int], i: int, p: int) -> int:
    """w_i = basis_i(0): node-only reconstruction weight (lagrangeCoeff)."""
    xi, num, den = nodes[i], 1, 1
    for j, xj in enumerate(nodes):
        if j != i:
            num = (num * (0 - xj)) % p
            den = (den * (xi - xj)) % p
    return (num * modinv(den, p)) % p

def reconstruct_secret(nodes: Sequence[int], shares: Sequence[int], p: int) -> int:
    """secret = sum_i share_i * w_i  (shamir_explicit_reconstruction)."""
    return sum(s * lagrange_weight(nodes, i, p)
               for i, s in enumerate(shares)) % p

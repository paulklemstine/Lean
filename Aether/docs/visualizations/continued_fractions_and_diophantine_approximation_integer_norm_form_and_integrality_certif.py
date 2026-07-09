def norm_form(p: int, q: int) -> int:
    """Integer norm N(p, q) = p^2 - p*q - q^2 of the element p - q*phi in Z[phi].

    By the factorization (p - q*phi)(p - q*psi) = p^2 - p*q - q^2 and the fact
    that 5 is not a perfect square, N(p, q) != 0 whenever q >= 1, hence
    |N(p, q)| >= 1. This single integrality fact powers the whole proof.
    """
    return p * p - p * q - q * q


def min_nonzero_norm(q_max: int) -> int:
    """Smallest nonzero |N(p, q)| over 1 <= q <= q_max, 0 <= p <= 2q+1."""
    best = None
    for q in range(1, q_max + 1):
        for p in range(0, 2 * q + 2):
            n = abs(norm_form(p, q))
            if n != 0 and (best is None or n < best):
                best = n
    return best  # always 1

def point_count_residue(n: int, q: int) -> int:
    """Return (#P^n(F_q) mod (q-1)).

    By the proven congruence #P^n(F_q) = 1 + q + ... + q^n is congruent to
    the topological Euler characteristic n+1 modulo q-1, because q-1 | q^i - 1.
    This function verifies that by direct computation. O(n) work.
    """
    N = sum(q ** i for i in range(n + 1))
    return N % (q - 1)


def euler_char_pn(n: int) -> int:
    """chi(P^n) = n + 1 (only the n+1 diagonal Hodge cells survive)."""
    return n + 1

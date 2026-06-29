def point_count(q: int, n: int) -> int:
    """#P^n(F_q) = 1 + q + ... + q^n."""
    return sum(q ** i for i in range(n + 1))

def verify_congruence(q: int, n: int) -> bool:
    """Verify #P^n(F_q) == chi(P^n) = n+1  (mod q-1)."""
    N = point_count(q, n)
    m = q - 1
    # geometric-series witness for divisibility:
    assert m * N == q ** (n + 1) - 1
    return N % m == (n + 1) % m

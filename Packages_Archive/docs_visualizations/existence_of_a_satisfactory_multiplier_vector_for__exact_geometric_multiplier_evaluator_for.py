def torus_norm_rational(m: int, n: int) -> float:
    """Exact ||m/n||_T = min(m%n, n-(m%n)) / n."""
    r = m % n
    return min(r, n - r) / n

def geometric_bound(q: int, k: int) -> float:
    """Exact ||q^k / (q+1)||_T, provably equal to 1/(q+1)."""
    return torus_norm_rational(pow(q, k, q + 1), q + 1)

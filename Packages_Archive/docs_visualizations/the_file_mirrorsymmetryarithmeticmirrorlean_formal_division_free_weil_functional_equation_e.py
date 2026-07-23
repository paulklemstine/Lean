def fe_lhs(q: int, n: int, T: float) -> float:
    out = 1.0
    for i in range(n + 1):
        out *= q ** (n - i) * T - 1
    return out

def fe_rhs(q: int, n: int, T: float) -> float:
    out = 1.0
    for i in range(n + 1):
        out *= 1 - q ** i * T
    return ((-1) ** (n + 1)) * out

def verify_functional_equation(q: int, n: int, T: float,
                               tol: float = 1e-9) -> bool:
    """Verify prod_i (q^(n-i)T - 1) = (-1)^(n+1) prod_i (1 - q^i T)."""
    lhs, rhs = fe_lhs(q, n, T), fe_rhs(q, n, T)
    return abs(lhs - rhs) <= tol * (1 + abs(lhs))

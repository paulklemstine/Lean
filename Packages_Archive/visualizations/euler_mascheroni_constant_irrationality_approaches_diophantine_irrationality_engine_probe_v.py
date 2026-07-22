def admits_small_form(x: float, eps: float, q_max: int = 100000) -> tuple[int, int] | None:
    """Irrationality-engine probe: search for a nonzero integer linear form
    |q*x - p| < eps with 1 <= q <= q_max. Returns (q, p) or None.

    A rational a/b in lowest terms satisfies |q*x - p| >= 1/b whenever the form
    is nonzero (the hard floor), so for eps < 1/b no form is found; an irrational
    admits such forms for every eps (Dirichlet)."""
    best: tuple[int, int] | None = None
    best_val: float = eps
    for q in range(1, q_max + 1):
        p: int = round(q * x)
        val: float = abs(q * x - p)
        if 0.0 < val < best_val:
            best_val = val
            best = (q, p)
    return best

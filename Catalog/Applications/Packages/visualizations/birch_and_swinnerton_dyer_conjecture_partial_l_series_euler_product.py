def partial_l_product(point_counts: dict, s: float = 1.0) -> float:
    """Compute partial Euler product for L(E,s)."""
    product = 1.0
    for p, N in point_counts.items():
        ap = p + 1 - N
        T = p ** (-s)
        inv_factor = 1 - ap * T + p * T * T
        if abs(inv_factor) > 1e-15:
            product /= inv_factor
    return product
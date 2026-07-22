def product_polarization(x: float, y: float) -> float:
    """Polynomial EML product valid on all of R^2:
    x*y = 1/4 (x+y)^2 - 1/4 (x-y)^2."""
    return (1.0 / 4.0) * (x + y) ** 2 + (-1.0 / 4.0) * (x - y) ** 2

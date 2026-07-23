def power_saving_constant(k: int) -> float:
    return 1.0 / (k * k)

def power_saving_ceiling(k: int, n: int) -> float:
    """Corridor ceiling n^(k - 1/k^2); requires k >= 2, n >= 1."""
    assert k >= 2 and n >= 1
    exponent: float = k - power_saving_constant(k)
    assert exponent >= 1.0  # admissibility of the constant
    return float(n) ** exponent

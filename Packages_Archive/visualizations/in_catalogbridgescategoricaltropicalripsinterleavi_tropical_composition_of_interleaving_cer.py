def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary addition (shifts compose)."""
    return a + b

def trop_add(a: float, b: float) -> float:
    """Tropical addition = minimum (optimal interleaving)."""
    return min(a, b)

def tropical_compose(eps: float, delta: float) -> float:
    """Compose an eps- and a delta-interleaving: shift = eps (x)_trop delta."""
    assert eps >= 0 and delta >= 0
    return trop_mul(eps, delta)

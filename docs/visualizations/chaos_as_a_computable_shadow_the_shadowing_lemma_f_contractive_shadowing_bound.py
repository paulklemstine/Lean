def contractive_shadowing_bound(delta: float, L: float) -> float:
    """Compute shadowing bound for contraction with ratio L."""
    assert 0 <= L < 1, f"Need L < 1, got {L}"
    return delta / (1.0 - L)
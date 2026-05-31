def pattern_count_from_radius(r: float) -> int:
    assert r > 0
    l = int(1.0 / r)
    return 2 * l + 1
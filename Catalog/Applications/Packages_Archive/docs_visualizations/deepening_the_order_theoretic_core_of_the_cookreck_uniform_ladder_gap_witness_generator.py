def ladder_gap_threshold(k: int, c: int, window: int = 5) -> int:
    """Threshold n0 = c+2 past which (2^(n^k)+2)^c < 2^(n^(k+1))."""
    assert k >= 1
    n0 = c + 2
    for n in range(n0, n0 + window + 1):
        assert (2 ** (n ** k) + 2) ** c < 2 ** (n ** (k + 1))
    return n0

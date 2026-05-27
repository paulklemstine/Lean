def count_backtrack_free(m: int) -> int:
    """Count backtrack-free words of length m.
    Formula: 4 * 3^(m-1) for m >= 1."""
    if m == 0:
        return 1
    return 4 * (3 ** (m - 1))
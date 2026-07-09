def correction_radius(n: int, k: int) -> int:
    """Optimal unique-decoding radius tau = floor((n-k)/2) for a GRS[n,k] code."""
    if not (1 <= k <= n):
        raise ValueError("require 1 <= k <= n")
    d: int = n - k + 1            # Singleton-optimal minimum distance
    tau: int = (d - 1) // 2
    assert 2 * tau + 1 <= d       # packing condition of grs_corrects_errors
    return tau
def frobenius_trace(p: int, point_count: int) -> int:
    """Compute Frobenius trace from point count. O(1) time."""
    return p + 1 - point_count

def verify_hasse_bound(p: int, ap: int) -> bool:
    """Check |a_p| <= 2*sqrt(p). O(1) time."""
    return ap * ap <= 4 * p
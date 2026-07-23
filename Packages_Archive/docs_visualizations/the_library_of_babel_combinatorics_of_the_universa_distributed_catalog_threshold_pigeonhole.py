def min_catalog_volumes(b: int, L: int) -> int:
    """distributed_catalog_iff: minimal number N of volumes whose combined
    L*N reference slots can index every one of the b^L volumes, i.e. the least
    N with N*L >= b^L, namely N = ceil(b^L / L)."""
    total: int = b ** L
    return -(-total // L)  # ceiling division

def catalog_can_index(b: int, L: int, N: int) -> bool:
    """True iff a distributed catalog of N volumes indexes the whole Library."""
    return N * L >= b ** L

def min_distributed_catalog_volumes(b: int, length: int) -> int:
    """Minimal number of volumes whose combined capacity can index the entire
    library of b**L volumes. A single volume holds L symbol-slots, so by the
    cardinality threshold b**L <= N*L the minimal count is ceil(b**L / L).
    Uses exact big-integer arithmetic.
    """
    if b <= 1 or length == 0:
        return 1
    return -(-(b ** length) // length)  # exact ceiling division of big ints

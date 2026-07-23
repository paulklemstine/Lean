def level_pk_eigensystem_count(p: int, k: int) -> int:
    """Number of level-p^k torsion eigensystems for GL_1: phi(p^k) = p^{k-1}(p-1).

    This is the order of the unit group (Z/p^k)^*, and is the maximal generic
    count; deviations below it in an arithmetic family signal ramification at p.
    Complexity: O(1) arithmetic (plus the cost of the integer power).
    """
    if k < 1:
        raise ValueError("k must be a positive integer")
    return p ** (k - 1) * (p - 1)

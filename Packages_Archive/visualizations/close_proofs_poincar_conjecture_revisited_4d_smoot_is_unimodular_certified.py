def is_unimodular_certified(gram: list[list[int]], inv: list[list[int]]) -> bool:
    """Certify unimodularity by exhibiting an integral inverse: gram @ inv = I.
    This is exactly how E8inv certifies that det(E8) is a unit. O(n^3)."""
    n = len(gram)
    prod = [[sum(gram[i][k] * inv[k][j] for k in range(n)) for j in range(n)]
            for i in range(n)]
    return prod == [[1 if i == j else 0 for j in range(n)] for i in range(n)]

def not_smoothly_standard(gram: list[list[int]]) -> bool:
    """Return True if the positive-rank form is provably NOT standard-diagonalizable
    (hence, with Donaldson, not the form of a smooth definite 4-manifold): this holds
    whenever the form is even and of positive rank (even_not_stdDiagonalizable)."""
    n = len(gram)
    return n > 0 and all(gram[i][i] % 2 == 0 for i in range(n))

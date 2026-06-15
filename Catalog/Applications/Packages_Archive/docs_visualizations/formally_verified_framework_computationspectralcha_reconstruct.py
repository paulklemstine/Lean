def reconstruct(matrix_rows, elements):
    """Algorithm C (Reconstruct): from a separating Boolean matrix (rows = tests),
    build a certified one-seed family mapping each element to its own column
    vector (Theorem 8.1). No search; separation is inherited from the matrix."""
    def f(_seed, x):
        return tuple(row(x) for row in matrix_rows)
    return f, {x: f(0, x) for x in elements}

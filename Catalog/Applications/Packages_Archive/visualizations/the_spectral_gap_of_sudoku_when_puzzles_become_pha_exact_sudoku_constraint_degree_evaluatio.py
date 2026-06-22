def sudoku_degree(n: int) -> int:
    """Cell degree in the order-n Sudoku constraint graph: 3n^2 - 2n - 1."""
    latin: int = 2 * (n ** 2 - 1)
    box_only: int = (n - 1) ** 2
    total: int = latin + box_only
    assert total == 3 * n ** 2 - 2 * n - 1
    assert total == (3 * n + 1) * (n - 1)
    return total
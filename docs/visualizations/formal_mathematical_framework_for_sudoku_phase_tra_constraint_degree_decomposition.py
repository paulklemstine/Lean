def sudoku_degree(n: int) -> int:
    latin = 2 * (n**2 - 1)
    box_only = (n - 1) ** 2
    total = latin + box_only
    assert total == (3 * n + 1) * (n - 1)
    return total
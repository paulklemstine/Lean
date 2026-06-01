def sudoku_constraint_degree(n: int) -> tuple[int, int, int]:
    sudoku = 3 * n**2 - 2 * n - 1
    latin = 2 * (n**2 - 1)
    box = (n - 1) ** 2
    assert sudoku == latin + box
    return sudoku, latin, box
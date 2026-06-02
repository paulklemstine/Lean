def neural_complexity(input_dim: int, widths: list) -> int:
    result = 1
    for w in widths:
        result *= zaslavsky_bound(input_dim, w)
    return result
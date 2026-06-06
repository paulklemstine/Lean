def hierarchical_survival(depth, reset_fn, board_size=2):
    if depth == 0:
        return reset_fn(0)
    total = 0
    for _ in range(reset_fn(depth)):
        total += hierarchical_survival(depth - 1, reset_fn, board_size)
    return total
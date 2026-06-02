def obstruction_degree(w: list[float]) -> int:
    m = sum(w)
    if m > 1e-12: return 1
    elif m < -1e-12: return -1
    return 0
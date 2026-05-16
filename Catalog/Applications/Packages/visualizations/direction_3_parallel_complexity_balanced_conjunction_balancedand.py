def balanced_and(xs: list) -> bool:
    n = len(xs)
    if n == 0: return True
    if n == 1: return xs[0]
    mid = n // 2
    return balanced_and(xs[:mid]) and balanced_and(xs[mid:])
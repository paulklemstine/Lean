def tower_exp(h, n):
    result = n
    for _ in range(h):
        result = 2 ** result
    return result
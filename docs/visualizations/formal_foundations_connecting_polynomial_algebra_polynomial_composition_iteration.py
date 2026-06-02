def poly_iterate(p, n):
    result = [0, 1]  # X
    for _ in range(n):
        result = poly_compose(p, result)
    return result
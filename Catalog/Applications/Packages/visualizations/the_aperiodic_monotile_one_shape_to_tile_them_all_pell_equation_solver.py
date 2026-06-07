def pell_solutions(n: int) -> list:
    a, b = [2, 4], [0, 1]
    for k in range(2, n):
        a.append(4*a[-1] - a[-2])
        b.append(4*b[-1] - b[-2])
    return [(a[k], b[k]) for k in range(n)]
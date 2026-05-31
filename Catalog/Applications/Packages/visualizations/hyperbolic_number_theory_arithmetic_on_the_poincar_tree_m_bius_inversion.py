def tree_moebius_invert(g: list, k: int) -> list:
    f = [g[0]]
    for i in range(1, len(g)):
        f.append(g[i] - k * g[i-1])
    return f
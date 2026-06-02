def brute_invert(p, c, n, solve):
    pre = [c]
    for _ in range(n):
        pre = [x for y in pre for x in solve(p, y)]
    return pre
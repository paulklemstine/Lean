def depth_filtration(coeffs, p):
    depths = {}
    for x in range(p):
        current, d = x, 0
        for _ in range(p+1):
            nxt = newton_step(coeffs, current, p)
            if nxt == current:
                depths[x] = d; break
            current = nxt; d += 1
        else:
            depths[x] = -1
    return depths
def trace_spectrum(k: int) -> set:
    S = (0, -1, 1, 0)
    T = (1, 1, 0, 1)
    gens = [S, T, (0,1,-1,0), (1,-1,0,1)]
    current = {(1,0,0,1)}
    traces = {2}
    for _ in range(k):
        nxt = set()
        for g in current:
            for h in gens:
                p = (g[0]*h[0]+g[1]*h[2], g[0]*h[1]+g[1]*h[3], g[2]*h[0]+g[3]*h[2], g[2]*h[1]+g[3]*h[3])
                traces.add(p[0]+p[3])
                nxt.add(p)
        current = nxt
    return traces
def hodge_rank(widths, p, q):
    if len(widths) < 2: return 0
    w1 = widths[0]
    wL = widths[-1] if len(widths) >= 3 else widths[0]
    return math.comb(w1, p) * math.comb(wL, q)
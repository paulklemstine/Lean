def compute_circularity_gap(derive, universe):
    # Ascending iteration for lfp
    lfp = frozenset()
    while True:
        nxt = derive(lfp)
        if nxt == lfp: break
        lfp = nxt
    # Descending iteration for gfp
    gfp = universe
    while True:
        nxt = derive(gfp)
        if nxt == gfp: break
        gfp = nxt
    return gfp - lfp, lfp, gfp
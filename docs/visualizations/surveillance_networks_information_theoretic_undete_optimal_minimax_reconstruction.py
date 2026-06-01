def optimal_reconstruction(encode, configs):
    fibers = {}
    for g in configs:
        c = encode(g)
        fibers.setdefault(c, []).append(g)
    recon = {}
    for code, fiber in fibers.items():
        best = min(fiber, key=lambda cand: max(edge_distortion(cand, g) for g in fiber))
        recon[code] = best
    return lambda c: recon.get(c, configs[0])
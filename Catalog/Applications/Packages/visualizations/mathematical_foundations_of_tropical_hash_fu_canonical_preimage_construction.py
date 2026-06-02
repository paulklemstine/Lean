def canonical_preimage(h, y, p):
    return [y - h[i] for i in range(len(h))]
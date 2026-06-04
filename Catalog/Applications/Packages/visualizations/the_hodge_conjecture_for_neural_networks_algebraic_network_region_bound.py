def network_region_bound(input_dim, widths):
    bound = 1
    for w in widths:
        bound *= zaslavsky_bound(w, input_dim)
    return bound
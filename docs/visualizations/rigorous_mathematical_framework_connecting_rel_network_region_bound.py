def network_region_bound(input_dim, layer_widths):
    from math import prod
    return prod(zaslavsky_bound(w, input_dim) for w in layer_widths)
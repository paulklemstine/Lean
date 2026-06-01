def find_packing_set(configs, D):
    packing = []
    for g in configs:
        if all(edge_distortion(g, p) > D for p in packing):
            packing.append(g)
    return packing
def spectral_gap(points):
    dists = set()
    for i, p in enumerate(points):
        for j, q in enumerate(points):
            if i != j:
                d = euclidean_dist(p, q)
                if d > 0: dists.add(d)
    return min(dists) if dists else None
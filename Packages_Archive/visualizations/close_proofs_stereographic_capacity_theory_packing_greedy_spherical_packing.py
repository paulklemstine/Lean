def greedy_spherical_packing(r, sphere_points):
    """Greedy lower-bound construction of a 2r-chordally-separated set on S^n.

    sphere_points : iterable of unit vectors in R^{n+1}.
    Returns a maximal (greedy) subset whose pairwise Euclidean distance >= 2r.
    By the degenerate-packing theorem, if r > 1 the result has size <= 1.
    """
    import math

    def norm(v):
        return math.sqrt(sum(c * c for c in v))

    chosen = []
    for p in sphere_points:
        if all(norm([a - b for a, b in zip(p, q)]) >= 2.0 * r for q in chosen):
            chosen.append(p)
    return chosen

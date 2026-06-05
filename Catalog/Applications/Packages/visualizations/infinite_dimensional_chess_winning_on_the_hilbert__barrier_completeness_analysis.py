def barrier_completeness_radius(threats, king):
    max_r = (len(threats) - 1) // 2
    for r in range(1, max_r + 1):
        sphere = chebyshev_sphere(king, r)
        if not all(sq in threats for sq in sphere):
            return r - 1
    return max_r
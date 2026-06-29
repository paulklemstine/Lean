def stereo_separated(r, points):
    """Verify the StereoSeparated predicate for a finite planar set.

    points : list of vectors in R^n.
    Returns True iff for every distinct pair (p, q):
        exclusion(r, p) + exclusion(r, q) <= ||p - q||,
    where exclusion(r, x) = tan(r) * (1 + ||x||^2) / 2.
    """
    import math

    def norm(v):
        return math.sqrt(sum(c * c for c in v))

    def excl(x):
        return math.tan(r) * (1.0 + norm(x) ** 2) / 2.0

    for i, p in enumerate(points):
        for j, q in enumerate(points):
            if i < j:
                gap = norm([a - b for a, b in zip(p, q)])
                if gap < excl(p) + excl(q):
                    return False
    return True

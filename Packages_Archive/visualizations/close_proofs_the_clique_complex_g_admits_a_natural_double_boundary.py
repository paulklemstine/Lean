def boundary_squared(s):
    """Compose the boundary with itself; provably returns the empty (zero) chain."""
    total = {}
    for face1, c1 in boundary(s).items():
        for face2, c2 in boundary(face1).items():
            total[face2] = total.get(face2, 0) + c1 * c2
    return {f: c for f, c in total.items() if c != 0}  # always {}

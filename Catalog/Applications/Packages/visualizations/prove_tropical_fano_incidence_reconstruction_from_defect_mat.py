def reconstruct_incidence(D, tolerance=0.0):
    return (D <= tolerance).astype(int)
def find_tropical_vertex(a1, b1, a2, b2):
    if abs(a1 - a2) < 1e-15:
        return None
    return (b2 - b1) / (a1 - a2)
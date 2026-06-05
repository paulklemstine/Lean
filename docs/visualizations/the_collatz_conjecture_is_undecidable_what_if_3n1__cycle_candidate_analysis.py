def cycle_candidate(w):
    s, c = compute_affine_iterative(w)
    if s == 1: return None
    return c / (1 - s)
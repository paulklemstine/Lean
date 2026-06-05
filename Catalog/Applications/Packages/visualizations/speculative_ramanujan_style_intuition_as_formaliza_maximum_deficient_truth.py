def find_max_deficient(oracles, n):
    best_t, best_d = None, -1
    for t in all_assignments(n):
        d = min(hamming_distance(f, t) for f in oracles)
        if d > best_d: best_t, best_d = t, d
    return best_t, best_d
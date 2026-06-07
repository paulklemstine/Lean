def universal_joke(setup, expected, candidates):
    best_p = candidates[0]
    best_h = euclidean_dist(expected, candidates[0])
    for p in candidates[1:]:
        h = euclidean_dist(expected, p)
        if h > best_h:
            best_h = h
            best_p = p
    return best_p, best_h
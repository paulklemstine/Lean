def optimal_joke_search(expected, candidates):
    dists = np.linalg.norm(candidates - expected, axis=1)
    best_idx = np.argmax(dists)
    return candidates[best_idx], float(dists[best_idx])
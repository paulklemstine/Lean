def find_fixed_point(update, init, tol=1e-10, max_iter=10000):
    current = init.copy()
    for step in range(max_iter):
        next_scores = update(current)
        if max(abs(next_scores[i] - current[i]) for i in range(len(current))) < tol:
            return next_scores, step + 1
        current = next_scores
    return current, max_iter
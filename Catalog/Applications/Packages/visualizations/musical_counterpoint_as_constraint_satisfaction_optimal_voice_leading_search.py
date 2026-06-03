def optimal_voice_leading(source, constraints, bound):
    n = len(source)
    best, best_cost = None, float('inf')
    for motion in itertools.product(range(-bound, bound+1), repeat=n):
        if all(c(source, motion) for c in constraints):
            cost = sum(abs(m) for m in motion)
            if cost < best_cost:
                best, best_cost = motion, cost
    return best
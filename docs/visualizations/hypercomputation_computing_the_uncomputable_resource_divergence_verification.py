def verify_divergence(cost, target, max_n=10000):
    total = 0.0
    for n in range(max_n):
        total += cost(n)
        if total > target:
            return n
    return None
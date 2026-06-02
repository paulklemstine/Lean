def computable_approx(oracle, n, max_steps=1000):
    results = []
    prev = 0
    for k in range(max_steps):
        a = oracle(k, n)
        results.append((k, math.log2(max(1,a)) / n if n > 0 else 1.0))
        if a == prev and k > 0: break
        prev = a
    return results
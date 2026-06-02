def estimate_dimension(b, oracle, d, N):
    S = sum(1 for _ in range(N) if all(oracle(l, random.randint(0,b-1)) for l in range(d)))
    p = S / N
    return 1 + math.log(p) / (d * math.log(b)) if p > 0 else 0.0
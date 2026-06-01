def classify_decay(samples):
    import math
    log_pairs = [(math.log(abs(t)), math.log(abs(f))) for t, f in samples if abs(t) > 0.5 and abs(f) > 1e-15]
    n = len(log_pairs)
    sx = sum(x for x, _ in log_pairs)
    sy = sum(y for _, y in log_pairs)
    sxy = sum(x*y for x, y in log_pairs)
    sxx = sum(x*x for x, _ in log_pairs)
    beta = -(n*sxy - sx*sy) / (n*sxx - sx*sx)
    return beta
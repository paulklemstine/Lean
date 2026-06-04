def compute_rit(f, g):
    n = len(f)
    return [sum(f[j] * g[(j + k) % n] for j in range(n)) for k in range(n)]
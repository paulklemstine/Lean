def privacy_defect(encode, configs):
    N = len(configs)
    if N <= 1:
        return 0.0
    k = len(set(encode(g) for g in configs))
    return (k - 1) / (N - 1)
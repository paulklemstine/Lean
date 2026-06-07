def compute_phi(weight):
    n = len(weight)
    if n < 2: return 0.0, None
    min_cut = float('inf')
    min_part = None
    for r in range(1, n):
        for subset in itertools.combinations(range(n), r):
            S = set(subset)
            Sc = set(range(n)) - S
            cw = sum(weight[i][j] for i in S for j in Sc) + sum(weight[i][j] for i in Sc for j in S)
            if cw < min_cut:
                min_cut = cw
                min_part = S
    return min_cut, min_part
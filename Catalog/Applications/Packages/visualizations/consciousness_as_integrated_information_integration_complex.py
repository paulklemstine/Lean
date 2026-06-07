def integration_complex(weight, threshold):
    n = len(weight)
    result = []
    for r in range(1, n):
        for subset in itertools.combinations(range(n), r):
            S = set(subset)
            Sc = set(range(n)) - S
            cw = sum(weight[i][j] for i in S for j in Sc) + sum(weight[i][j] for i in Sc for j in S)
            if cw > threshold:
                result.append(S)
    return result
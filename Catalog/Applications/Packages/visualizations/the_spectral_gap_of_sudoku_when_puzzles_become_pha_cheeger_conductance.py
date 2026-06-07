def cheeger_conductance(P, pi):
    n = P.shape[0]
    best = float('inf')
    for mask in range(1, 2**n - 1):
        S = [i for i in range(n) if mask & (1 << i)]
        Sc = [i for i in range(n) if not (mask & (1 << i))]
        pi_S = sum(pi[i] for i in S)
        if pi_S > 0.5: continue
        flow = sum(pi[i]*P[i,j] for i in S for j in Sc)
        best = min(best, flow / pi_S)
    return best
def greedy_wedge(G, A):
    S = set(A)
    while True:
        found = False
        for v in range(G.V):
            if v not in S and G.cut_weight(S | {v}) <= G.cut_weight(S):
                S.add(v)
                found = True
                break
        if not found:
            break
    return S
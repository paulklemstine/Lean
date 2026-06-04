def find_product_witnesses(S, N):
    S_sorted = sorted(S)
    witnesses = []
    for i, a in enumerate(S_sorted):
        for b in S_sorted[i:]:
            if a*b > N: break
            if a*b in S: witnesses.append((a,b,a*b))
    return witnesses
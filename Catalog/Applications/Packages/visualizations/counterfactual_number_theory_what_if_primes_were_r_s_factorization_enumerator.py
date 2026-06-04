def enumerate_factorizations(S, n, depth=20):
    if depth<=0: return []
    res = [[n]] if n in S else []
    for a in sorted(x for x in S if 2<=x*x<=n):
        if n%a==0:
            for sf in enumerate_factorizations(S,n//a,depth-1):
                if sf and a<=sf[0]: res.append([a]+sf)
    return res
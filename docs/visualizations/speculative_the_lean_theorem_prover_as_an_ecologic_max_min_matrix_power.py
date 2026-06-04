def maxmin_matpow(M, n, k):
    import math
    R = [[(-math.inf if i!=j else math.inf) for j in range(n)] for i in range(n)]
    for _ in range(k):
        N = [[-math.inf]*n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                for l in range(n):
                    N[i][j] = max(N[i][j], min(R[i][l], M[l][j]))
        R = N
    return R
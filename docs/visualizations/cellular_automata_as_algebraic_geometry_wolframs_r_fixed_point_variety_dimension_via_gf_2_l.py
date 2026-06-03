def fixed_point_dim_linear(rule_num, n):
    coeffs = compute_anf(rule_num)
    alpha, beta, gamma = coeffs[1], coeffs[2], coeffs[3]
    M = [[0]*n for _ in range(n)]
    for i in range(n):
        M[i][(i-1)%n] ^= alpha
        M[i][i] ^= beta
        M[i][(i+1)%n] ^= gamma
    MI = [[(M[i][j] ^ (1 if i==j else 0)) for j in range(n)] for i in range(n)]
    # GF(2) Gaussian elimination
    rank = 0
    for col in range(n):
        pivot = None
        for r in range(rank, n):
            if MI[r][col]: pivot = r; break
        if pivot is None: continue
        MI[rank], MI[pivot] = MI[pivot], MI[rank]
        for r in range(n):
            if r != rank and MI[r][col]:
                MI[r] = [MI[r][j] ^ MI[rank][j] for j in range(n)]
        rank += 1
    return n - rank
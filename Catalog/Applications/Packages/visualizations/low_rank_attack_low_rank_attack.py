def low_rank_attack(G, P, r, U, V, max_search=10000):
    H = trop_matmul(V, U)  # r×r core
    H_power = trop_identity(r)
    for e in range(max_search):
        candidate = trop_matmul(trop_matmul(U, H_power), V)
        if np.array_equal(candidate, P):
            return e + 1
        H_power = trop_matmul(H_power, H)
    return None

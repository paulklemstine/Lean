def tcke_exchange(G, a, b):
    PA = trop_mat_pow(G, a)
    PB = trop_mat_pow(G, b)
    K = trop_mat_mul(PA, trop_mat_mul(PB, G))
    return PA, PB, K
def lfp_iterate(phi, bottom, eq_fn, max_iter=1000):
    L = bottom
    for _ in range(max_iter):
        L_new = phi(L)
        if eq_fn(L_new, L):
            return L
        L = L_new
    return L
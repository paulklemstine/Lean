def compute_centralizer(G, bound):
    from itertools import product
    n = G.shape[0]
    cent = []
    for vals in product(range(bound+1), repeat=n*n):
        M = np.array(vals, float).reshape(n,n)
        if np.array_equal(trop_mat_mul(M,G), trop_mat_mul(G,M)):
            cent.append(M)
    return cent
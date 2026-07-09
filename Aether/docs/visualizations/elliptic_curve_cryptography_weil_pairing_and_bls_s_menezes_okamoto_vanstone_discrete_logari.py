def mov_recover(bls, pub: int) -> int:
    u = bls.e(bls.g, bls.g)
    v = bls.e(pub, bls.g)
    # brute-force discrete log in the (small) order-n target subgroup
    for k in range(bls.n):
        if pow(u, k, bls.p) == v:
            return k
    raise RuntimeError('discrete log not found')

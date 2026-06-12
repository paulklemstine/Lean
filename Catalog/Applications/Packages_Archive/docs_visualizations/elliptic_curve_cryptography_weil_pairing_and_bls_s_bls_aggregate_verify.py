def bls_aggregate_verify(g: int, pubkeys: list[int],
                         hashes: list[int], agg_sig: int) -> bool:
    '''Accept iff e(agg_sig, g) == prod_i e(H_i, X_i).'''
    rhs = 1
    for X, H in zip(pubkeys, hashes):
        rhs = (rhs * e(H, X)) % P
    return e(agg_sig, g) == rhs

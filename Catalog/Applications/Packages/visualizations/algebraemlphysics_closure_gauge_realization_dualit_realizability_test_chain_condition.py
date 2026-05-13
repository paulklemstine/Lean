def is_gauge_realizable(cl_fn, universe):
    closed = compute_all_closed_sets(cl_fn, universe)
    for S in closed:
        for T in closed:
            if not (S.issubset(T) or T.issubset(S)):
                return False, None
    v = reconstruct_valuation(cl_fn, universe)
    return True, v
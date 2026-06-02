def compute_spn(tau, all_tops, max_n=10):
    finer = [t for t in all_tops if set(tau) < set(t)]
    if not finer: return 0
    for n in range(2, min(max_n, len(finer))+1):
        for combo in combinations(finer, n):
            if compute_consensus(list(combo)) == tau:
                return n
    return 0
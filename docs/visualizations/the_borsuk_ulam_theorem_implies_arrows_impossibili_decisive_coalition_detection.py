def compute_decisive_coalitions(swf, n_voters, n_alts):
    from itertools import permutations
    all_rankings = list(permutations(range(n_alts)))
    decisive = []
    for S_mask in range(2**n_voters):
        S = frozenset(i for i in range(n_voters) if S_mask & (1<<i))
        is_decisive = True
        for a in range(n_alts):
            for b in range(n_alts):
                if a == b: continue
                r_ab = next(r for r in all_rankings if r[a] < r[b])
                r_ba = next(r for r in all_rankings if r[b] < r[a])
                profile = tuple(r_ab if i in S else r_ba for i in range(n_voters))
                if swf(profile)[a] >= swf(profile)[b]:
                    is_decisive = False; break
            if not is_decisive: break
        if is_decisive: decisive.append(S)
    return decisive
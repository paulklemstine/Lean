def compute_game_hop_bound(real_game, hybrid_game, predicate, weight_fn, domain):
    sum_real = sum(weight_fn(c) * real_game(c) for c in domain)
    sum_hybrid = sum(weight_fn(c) * hybrid_game(c) for c in domain)
    lhs = abs(sum_real - sum_hybrid)
    bad_weight = sum(weight_fn(c) for c in domain if not predicate(c))
    return {'lhs': lhs, 'rhs': bad_weight, 'bound_holds': lhs <= bad_weight + 1e-12}
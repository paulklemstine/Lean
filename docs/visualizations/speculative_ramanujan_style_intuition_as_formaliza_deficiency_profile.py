def deficiency_profile(oracles, n):
    total = 2**n
    return [total - len(oracle_coverage(oracles, d, n)) for d in range(n + 1)]
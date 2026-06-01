def test_density_separation(hierarchy, n, N_max):
    for N in range(1, N_max + 1):
        p_n = oracle_power(hierarchy.level(n), N)
        p_n1 = oracle_power(hierarchy.level(n + 1), N)
        if p_n >= p_n1:
            return f'REFUTED at N={N}'
    return f'SUPPORTED up to N={N_max}'
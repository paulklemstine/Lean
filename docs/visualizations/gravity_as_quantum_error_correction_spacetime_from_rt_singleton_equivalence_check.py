def rt_singleton_check(n, k, d):
    s_ent = (n - k) / 2.0
    is_mds = (2*d + k == n + 2)
    gap = (n + 2) - (2*d + k)
    return {'singleton_entropy': s_ent, 'is_mds': is_mds, 'gap': gap}
def asymp_compare(t1, t2):
    diff = {g: t1.get(g, 0) - t2.get(g, 0) for g in set(t1) | set(t2)}
    diff = {g: c for g, c in diff.items() if abs(c) > 1e-15}
    if not diff:
        return 0
    g_max = max(diff.keys())
    return 1 if diff[g_max] > 0 else -1
def fixed_points(rule_num, n):
    results = []
    for s in itertools.product([0, 1], repeat=n):
        updated = tuple((rule_num >> (4*s[(i-1)%n] + 2*s[i] + s[(i+1)%n])) & 1 for i in range(n))
        if updated == s:
            results.append(s)
    return results
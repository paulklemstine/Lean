def brute_force_min_transversal(vertices, edges):
    from itertools import combinations
    if not edges: return set(), 0
    v_list = sorted(vertices)
    for k in range(1, len(v_list) + 1):
        for combo in combinations(v_list, k):
            T = set(combo)
            if all(T & e for e in edges):
                return T, k
    return set(v_list), len(v_list)
def family_query(profiles, n, search_bound=100):
    return any(profiles(k)(n) for k in range(n + search_bound))
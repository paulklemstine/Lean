def find_threshold(prop, max_search=100000):
    for n in range(max_search, -1, -1):
        if not prop(n): return n + 1
    return 0
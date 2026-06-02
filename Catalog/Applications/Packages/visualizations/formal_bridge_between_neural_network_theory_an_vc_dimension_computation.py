def vc_dimension(family, ground_size):
    from itertools import combinations
    best = 0
    for size in range(ground_size + 1):
        found = False
        for combo in combinations(range(ground_size), size):
            subset = frozenset(combo)
            trace = {A & subset for A in family}
            if len(trace) == 2**size:
                found = True
                best = size
                break
        if not found and size > best:
            break
    return best
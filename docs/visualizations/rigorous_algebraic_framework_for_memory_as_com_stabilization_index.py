def stabilization_index(f, n):
    domain = list(range(n))
    current = {i: i for i in domain}
    prev_rank = n
    for k in range(1, n+1):
        current = {i: f(current[i]) for i in domain}
        r = len(set(current.values()))
        if r == prev_rank:
            return k - 1
        prev_rank = r
    return n
def find_growth_rank(f, max_index=200):
    indices = list(range(2, max_index))
    for k in range(20):
        if all(f(i) <= i**k for i in indices):
            return k
    return None
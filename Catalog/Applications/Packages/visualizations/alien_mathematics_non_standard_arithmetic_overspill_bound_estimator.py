def overspill_bound(p, n=10000):
    def f(i):
        bound = 0
        for k in range(i + 1):
            if p(i, k):
                bound = k
            else:
                break
        return bound
    return f
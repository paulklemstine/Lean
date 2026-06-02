def find_eventual_idempotent(f):
    domain = sorted(f.keys())
    def iterate(x, k):
        for _ in range(k): x = f[x]
        return x
    for N in range(1, len(domain)**2 + 1):
        fn = {x: iterate(x, N) for x in domain}
        if all(fn[fn[x]] == fn[x] for x in domain):
            return N, fn
    raise ValueError('unreachable')
def prime_cycle_count(A, K):
    from functools import reduce
    N = [np.trace(np.linalg.matrix_power(A, k)) for k in range(K+1)]
    def mobius(n):
        if n == 1: return 1
        factors, d, t = [], 2, n
        while d*d <= t:
            if t % d == 0:
                factors.append(d)
                while t % d == 0: t //= d
            d += 1
        if t > 1: factors.append(t)
        t2 = n
        for p in factors:
            c = 0
            while t2 % p == 0: t2 //= p; c += 1
            if c > 1: return 0
        return (-1)**len(factors)
    return [0]+[sum(mobius(k//d)*N[d] for d in range(1,k+1) if k%d==0)/k for k in range(1,K+1)]
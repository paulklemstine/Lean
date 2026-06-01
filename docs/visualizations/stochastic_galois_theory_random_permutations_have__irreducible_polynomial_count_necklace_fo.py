def irred_count(n, q):
    from functools import reduce
    def mobius(k):
        factors = set(); t = k; d = 2
        while d*d <= t:
            while t%d==0: factors.add(d); t//=d
            d+=1
        if t>1: factors.add(t)
        t2 = k
        for f in factors:
            if t2%(f*f)==0: return 0
        return (-1)**len(factors)
    return sum(mobius(n//d)*q**d for d in range(1,n+1) if n%d==0)//n
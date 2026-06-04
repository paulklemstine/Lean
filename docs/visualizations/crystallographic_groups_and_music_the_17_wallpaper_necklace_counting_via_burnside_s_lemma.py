def necklace_count(n):
    from math import gcd
    def phi(k):
        r = k
        p = 2
        t = k
        while p*p <= t:
            if t % p == 0:
                while t % p == 0: t //= p
                r -= r // p
            p += 1
        if t > 1: r -= r // t
        return r
    return sum(phi(n//d) * 2**d for d in range(1,n+1) if n%d==0) // n
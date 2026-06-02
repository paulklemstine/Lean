def catalan_hankel(size, shift=0):
    from math import comb
    C = lambda n: comb(2*n, n) // (n+1)
    M = [[C(i+j+shift) for j in range(size)] for i in range(size)]
    def det(m):
        n = len(m)
        if n <= 1: return m[0][0] if n else 1
        return sum((-1)**j * m[0][j] * det([r[:j]+r[j+1:] for r in m[1:]]) for j in range(n))
    return det(M)
def fast_hecke(a, q, n):
    if n == 0: return 1
    def mat_mul(A, B):
        return [[A[0][0]*B[0][0]+A[0][1]*B[1][0], A[0][0]*B[0][1]+A[0][1]*B[1][1]],
                [A[1][0]*B[0][0]+A[1][1]*B[1][0], A[1][0]*B[0][1]+A[1][1]*B[1][1]]]
    result = [[1,0],[0,1]]
    base = [[a,-q],[1,0]]
    while n > 0:
        if n % 2 == 1: result = mat_mul(result, base)
        base = mat_mul(base, base)
        n //= 2
    return result[0][0]
def hecke_seq_fast(a, q, n):
    def mat_mul(A, B):
        return (A[0]*B[0]+A[1]*B[2], A[0]*B[1]+A[1]*B[3], A[2]*B[0]+A[3]*B[2], A[2]*B[1]+A[3]*B[3])
    def mat_pow(M, n):
        if n == 0: return (1,0,0,1)
        if n == 1: return M
        if n % 2 == 0:
            h = mat_pow(M, n//2)
            return mat_mul(h, h)
        return mat_mul(M, mat_pow(M, n-1))
    if n <= 1: return [1, a][n]
    Mn = mat_pow((a, -q, 1, 0), n)
    return Mn[2] * a + Mn[3]
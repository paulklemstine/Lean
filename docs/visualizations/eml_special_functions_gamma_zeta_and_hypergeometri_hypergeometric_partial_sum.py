def hypergeom_sum(a, b, c, z, N):
    total, coeff, zk = 0.0, 1.0, 1.0
    for k in range(N):
        total += coeff * zk
        coeff *= (a+k)*(b+k)/((c+k)*(k+1))
        zk *= z
    return total
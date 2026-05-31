def saunderson(m, n):
    u, v, w = m*m-n*n, 2*m*n, m*m+n*n
    return tuple(sorted([abs(u*(4*v*v-w*w)), abs(v*(4*u*u-w*w)), abs(4*u*v*w)]))
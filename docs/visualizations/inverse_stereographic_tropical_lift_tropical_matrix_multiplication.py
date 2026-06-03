def tropical_mat_mul(M, N):
    a1,b1,c1,d1 = M
    a2,b2,c2,d2 = N
    return (max(a1+a2,b1+c2), max(a1+b2,b1+d2), max(c1+a2,d1+c2), max(c1+b2,d1+d2))
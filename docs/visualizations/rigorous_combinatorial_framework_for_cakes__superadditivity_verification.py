def verify_superadditivity(g1, b1, n1, g2, b2, n2):
    d1 = 6*g1-6+2*n1+3*b1
    d2 = 6*g2-6+2*n2+3*b2
    gn, bn, nn = g1+g2+1, b1+b2-2, n1+n2
    dn = 6*gn-6+2*nn+3*bn
    return dn == d1 + d2 + 6
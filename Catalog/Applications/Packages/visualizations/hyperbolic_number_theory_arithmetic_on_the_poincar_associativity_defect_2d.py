def assoc_defect_2d(z1, z2, z3):
    def madd(z, w): return (z+w)/(1+z.conjugate()*w)
    return abs(madd(madd(z1,z2),z3) - madd(z1,madd(z2,z3)))
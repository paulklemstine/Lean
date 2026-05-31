def fricke_vogt_check(A, B):
    def mul(a,b): return (a[0]*b[0]+a[1]*b[2], a[0]*b[1]+a[1]*b[3], a[2]*b[0]+a[3]*b[2], a[2]*b[1]+a[3]*b[3])
    def inv(m): return (m[3],-m[1],-m[2],m[0])
    def tr(m): return m[0]+m[3]
    AB = mul(A,B)
    comm = mul(mul(AB, inv(A)), inv(B))
    return tr(A)**2 + tr(B)**2 + tr(AB)**2 == tr(A)*tr(B)*tr(AB) + tr(comm) + 2
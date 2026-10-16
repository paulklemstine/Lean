# ---------------------------------------------------------------------------
# debug_hnp3.sage -- inspect the reduced basis rows for the toy HNP instance
# ---------------------------------------------------------------------------
from sage.all import *
from fpylll import LLL, BKZ, IntegerMatrix
load('common.sage')

P_TOY = 2305843009213697761
E_TOY = EllipticCurve(GF(P_TOY), [0,7])
N_TOY = int(E_TOY.order())
NB = Integer(N_TOY).nbits()
TOY = dict(p=int(P_TOY), a=0, b=7, n=int(N_TOY),
           G=(int(E_TOY.gens()[0][0]), int(E_TOY.gens()[0][1])))
set_random_seed(1)

def to_fpylll(B):
    A = IntegerMatrix(B.nrows(), B.ncols())
    for i in range(B.nrows()):
        for j in range(B.ncols()):
            A[i,j] = int(B[i,j])
    return A
def from_fpylll(A):
    return Matrix(ZZ, A.nrows, A.ncols, [[int(A[i,j]) for j in range(A.ncols)] for i in range(A.nrows)])

ell, t = 8, 24
K = 2**(NB-ell); kbi = 2**ell; n = N_TOY
d = Integer(ZZ.random_element(1, n-1))
Q = mul_G(int(d), TOY)
r, s, z, kbar, eps = [], [], [], [], []
for i in range(t):
    while True:
        k = int(ZZ.random_element(1, n-1))
        zi = int(ZZ.random_element(0, n))
        Pk = mul_G(k, TOY)
        ri = Pk[0] % n
        try:
            si = (inverse_mod(k, n)*(zi + ri*int(d))) % n
        except ZeroDivisionError:
            continue
        if ri and si: break
    r.append(ri); s.append(si); z.append(zi)
    kbar.append((k//K)*K); eps.append(k - (k//K)*K)

B, tcol = hnp_basis_plain(r, s, z, kbar, n, NB, ell)
R = from_fpylll(LLL.reduction(to_fpylll(B), delta=0.99))
tgt = vector(ZZ, [2*kbi*eps[i]-n for i in range(t)] + [int(d), -n])
print("d =", d)
print("target norm^2 =", tgt.dot_product(tgt))
for i, row in enumerate(R):
    nrm = sqrt(row.dot_product(row))
    c = Integer(row[tcol]) % n
    tag = ""
    if i < 8: tag = "  coords[:4]=%s  c=%%d" % (c,)
    print("row %2d  |v|=%12.1f   c%%n=%s   last=%s   %s" %
          (i, float(nrm), str(c)[:14], str(row[t+1])[:10],
           "  <== c == d !!!" if c == int(d) % n else ""))
print()
print("is target in the row span of the reduced basis?")
M = matrix(ZZ, R)
try:
    sol = M.solve_left(tgt)
    print("   integral:", all(x in ZZ for x in sol))
except Exception as ex:
    print("   ", ex)
print("(0,...,0,n,0) in lattice:", all(x in ZZ for x in B.solve_left(vector(ZZ,[0]*t+[n,0]))))
print("(0,...,0,1,0) in lattice:", all(x in ZZ for x in B.solve_left(vector(ZZ,[0]*t+[1,0]))))

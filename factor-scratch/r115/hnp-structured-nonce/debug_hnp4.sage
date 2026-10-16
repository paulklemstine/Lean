# ---------------------------------------------------------------------------
# debug_hnp4.sage -- compare the reduced rows against the target in detail
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

print("d               =", d)
print("target  |v|^2   =", tgt.dot_product(tgt))
print("target  coords[:5] =", tgt[:5])
print("target  c =", tgt[tcol], " last =", tgt[t+1])
print()
for i in range(4):
    row = R[i]
    print("row %d  |v|^2 = %d" % (i, row.dot_product(row)))
    print("   coords[:5] =", row[:5])
    print("   c = %s   last = %s" % (row[tcol], row[tcol+1]))
    # residual signature: how many coords are in [0, 2*kbi*K) ?
    small = sum(1 for j in range(t) if abs(row[j]) < 2*kbi*K)
    print("   #coords with |.| < 2*kbi*K = %d / %d" % (small, t))
print()
small_tgt = sum(1 for j in range(t) if abs(tgt[j]) < 2*kbi*K)
print("target #coords with |.| < 2*kbi*K = %d / %d" % (small_tgt, t))
print("2*kbi*K = 2^%.2f ; n = 2^%.2f ; modulus M = 2^%.2f" %
      (float(log(2*kbi*K,2)), float(log(n,2)), float(log(2*kbi*n,2))))
# can we form target = row1 + (0,...,0,j*n,0) - adjustments?
print()
print("row1 - target =", (R[1]-tgt)[:5], " c-diff =", R[1][tcol]-tgt[tcol], " last-diff =", R[1][tcol+1]-tgt[tcol+1])

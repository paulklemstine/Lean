# ---------------------------------------------------------------------------
# debug_hnp2.sage -- why doesn't LLL return the target row?
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
    nr, nc = B.nrows(), B.ncols()
    A = IntegerMatrix(nr, nc)
    for i in range(nr):
        for j in range(nc):
            A[i,j] = int(B[i,j])
    return A
def from_fpylll(A):
    nr, nc = A.nrows, A.ncols
    return Matrix(ZZ, nr, nc, [[int(A[i,j]) for j in range(nc)] for i in range(nr)])

for ell, tmult in [(8, 3), (8, 4), (4, 8), (12, 3)]:
    t = int(ceil(NB/float(ell)))*tmult
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
    A = to_fpylll(B)
    Rl = from_fpylll(LLL.reduction(A, delta=0.99))
    tgt = vector(ZZ, [2*kbi*eps[i]-n for i in range(t)] + [int(d), -n])
    print("=== ell=%d t=%d t*ell=%d  target norm 2^%.2f  GH 2^%.2f" %
          (ell, t, t*ell, float(log(sqrt(tgt.dot_product(tgt)),2)),
           float(log(abs(B.det()),2)/(t+2))))
    found = False
    for i, row in enumerate(Rl):
        c = Integer(row[tcol]) % n
        if c == int(d) % n:
            hit = mul_G(int(c), TOY) == Q
            print("   row %d has t-coord == d : norm 2^%.2f  EC-verified=%s"
                  % (i, float(log(sqrt(to_fpylll_norm := row.dot_product(row)),2)), hit))
            found = True
    if not found:
        norms = sorted([float(log(sqrt(row.dot_product(row)),2)) for row in Rl])
        print("   no row with t-coord == d. shortest norms:", ["%.2f"%x for x in norms[:6]])
        # how many rows have t-coord that reduces to something plausible?
        col = [Integer(row[tcol]) % n for row in Rl]
        print("   t-col values mod n (first 6):", [str(c)[:14] for c in col[:6]])
    # BKZ for comparison
    Rb = from_fpylll(BKZ.reduction(to_fpylll(B), BKZ.Param(block_size=20, strategies=BKZ.DEFAULT_STRATEGY)))
    fb = any((Integer(row[tcol]) % n) == int(d) % n for row in Rb)
    print("   BKZ(20) finds a row with t-coord==d :", fb)

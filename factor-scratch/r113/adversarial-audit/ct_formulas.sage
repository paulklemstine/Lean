# Verify ecm2.py's Jacobian formulas against SAGE's own EC arithmetic (the
# oracle).  If this fails, every ECM timing below is VOID.
#
# Run:  ~/sage_mamba/envs/sage/bin/sage ct_formulas.sage
import sys
sys.path.insert(0, '/home/raver1975/lean/factor-scratch/r113/adversarial-audit')
from ecm2 import jac_dbl, jac_add, jac_mul

def inv(v, m):
    return pow(v, -1, m)

fails = 0
checked = 0
set_random_seed(4242)
for trial in range(120):
    m = next_prime(10**4)   # small prime so E.points() is cheap
    A = randint(2, m - 2)
    Bc = randint(2, m - 2)
    try:
        E = EllipticCurve(GF(m), [0, 0, 0, A, Bc])
    except TypeError:
        continue
    if E.is_singular():
        continue
    pts = [pt for pt in E.points() if pt[0] != 0][:4]
    if len(pts) < 2:
        continue
    for pt in pts:
        for k in [1, 2, 3, 5, 7, 13, 100, 1001, 65537, 1048576]:
            want = (pt * k)
            X, Y, Z = jac_mul((int(pt[0]), int(pt[1]), 1), k, int(A), int(m))
            checked += 1
            if Z == 0:
                ok = (want == E(0))
            else:
                xx = X * inv(Z * Z, m) % m
                yy = Y * inv(Z * Z % m * Z, m) % m
                ok = (E(xx, yy) == want)
            if not ok:
                fails += 1
                if fails <= 3:
                    print("  MISMATCH m=%s A=%s k=%d" % (m, A, k))
    # mixed addition
    for i in range(min(3, len(pts))):
        for j in range(min(3, len(pts))):
            p1, p2 = pts[i], pts[j]
            X3, Y3, Z3 = jac_add(int(p1[0]), int(p1[1]), 1, int(p2[0]), int(p2[1]), 1, int(A), int(m))
            want = p1 + p2
            checked += 1
            if Z3 == 0:
                ok = (want == E(0))
            else:
                xx = X3 * inv(Z3 * Z3, m) % m
                yy = Y3 * inv(Z3 * Z3 % m * Z3, m) % m
                ok = (E(xx, yy) == want)
            if not ok:
                fails += 1
                if fails <= 5:
                    print("  XADD MISMATCH %s + %s" % (p1, p2))

print("Jacobian formulas checked %d times against Sage; mismatches = %d" % (checked, fails))
if fails:
    print("HARNESS BROKEN -- ECM measurements would be VOID")
    sys.exit(1)
print("HARNESS VERIFIED -- ecm2.py group law is exact.")

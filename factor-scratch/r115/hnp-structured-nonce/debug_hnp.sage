# ---------------------------------------------------------------------------
# debug_hnp.sage -- single-instance debug of the plain HNP lattice
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

ell = 8
t = 3*NB//ell   # = 3*ceil
t = int(ceil(NB/float(ell)))*3
K = 2**(NB-ell)
kbi = 2**ell
n = N_TOY
print("nb=%d ell=%d t=%d t*ell=%d" % (NB, ell, t, t*ell))

d = Integer(ZZ.random_element(1, n-1))
Q = mul_G(int(d), TOY)
print("d =", d, "Q =", Q)

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
        if ri == 0 or si == 0:
            continue
        break
    r.append(ri); s.append(si); z.append(zi)
    kbar.append((k//K)*K)
    eps.append(k - (k//K)*K)
    assert ecdsa_verify(Q, ri, si, zi, TOY)
print("all %d signatures VERIFY" % t)

# sanity of the HNP relation:  k_i mod n == s_i^{-1}(z_i + r_i d) mod n
for i in range(t):
    lhs = (kbar[i] + eps[i]) % n
    rhs = (inverse_mod(s[i], n)*(z[i] + r[i]*int(d))) % n
    assert lhs == rhs, (i, lhs, rhs)
print("HNP congruence k_i == s_i^{-1}(z_i + r_i d) holds for all i")

# build the lattice
B, tcol = hnp_basis_plain(r, s, z, kbar, n, NB, ell)
print("determinant =", B.det(), " GH =", float((abs(B.det()))^(1/(t+2))))
print("target tcol =", tcol)

# the target vector we expect: (2*kbi*eps_i - n, d, -n)
tgt = vector(ZZ, t+2)
for i in range(t):
    tgt[i] = 2*kbi*eps[i] - n
tgt[t] = int(d)
tgt[t+1] = -n
print("target norm =", float(sqrt(tgt.dot_product(tgt))), " coords:", tgt[:4])

# is tgt - (0,...,0) in the lattice?  check tgt in L iff solve B x == tgt integral
try:
    sol = B.solve_left(tgt)
    print("target in lattice?  all integral:", all(c in ZZ for c in sol))
    print("  comb:", sol)
except Exception as e:
    print("solve_left failed:", e)

# alternatively: target = tgt0 - (0, y_i) where y_i = z s^{-1}
# check directly by construction: build the vector from the combination
y = [(inverse_mod(s[i],n)*z[i]) % n for i in range(t)]
g = [(inverse_mod(s[i],n)*r[i]) % n for i in range(t)]
v = vector(ZZ, t+2)
# try: v_i = 2kbi*eps_i (no -n), v_t = d, v_{t+1} = 0  -> in lattice?
for i in range(t):
    v[i] = 2*kbi*eps[i]
v[t] = int(d); v[t+1] = 0
sol2 = B.solve_left(v)
ok = all(c in ZZ for c in sol2)
print("vector (2kbi*eps, d, 0) in lattice (all integral coords):", ok)
if not ok:
    print("   fractional parts:", [str(c.denominator()) for c in sol2[:6]])

# check the true one
v3 = vector(ZZ, t+2)
for i in range(t):
    v3[i] = 2*kbi*eps[i] - n
v3[t] = int(d); v3[t+1] = -n
sol3 = B.solve_left(v3)
print("vector (2kbi*eps - n, d, -n) in lattice:", all(c in ZZ for c in sol3))
print("   coords:", sol3)

# GREEDY SIGNAL DISCOVERY for the structural (affine-nonce) attack.
#
# r118 established: nonces affine in D public signals, k_i = sum_j a_j g_j(i) + Delta, fall
# to one linear solve in t = D+2 signatures.  The catch: the attacker must KNOW the signals
# g_j.  r119/endomorphism's bonus finding (collision counts detect structured nonces but are
# model-free) frames the open question: can the signal model be DISCOVERED cheaply rather
# than assumed?
#
# GREEDY ALGORITHM: maintain a candidate feature set.  Add one feature at a time
# (z, z^2, z^3, ...).  After each addition, build the OVERDETERMINED system with one extra
# signature and test CONSISTENCY.  A consistent overdetermined system is a positive
# detection: with (D+2)+1 equations and (D+2) unknowns, a random nonce set satisfies it with
# probability ~1/n, so a hit is essentially certain evidence of affine structure.
#
# PREDICTIONS:
#   (P1) with nonces affine in an unknown degree-D polynomial of the message hash, greedy
#        discovers the model in exactly D+1 feature additions (the first D+1 features of the
#        polynomial basis are enough), i.e. D+2 linear solves total;
#   (P2) the detector has FALSE POSITIVE rate ~1/n (measure at n = 2^18 and extrapolate);
#   (P3) with non-affine (random) nonces it never fires -- and the NULL control must sit at
#        the 1/n rate, otherwise the detector is measuring nothing.
#
# This is exactly the greedy selection procedure the catalog formalizes in
# Cryptography/UniversalRedundancy*.lean (greedySeq, shtarkov_submodular,
# greedy_one_sub_inv_exp_le) -- there, over libraries and mutual information; here, over
# signal features and consistency.

import time

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))

def features(z, deg):
    """monomial features z^1 .. z^deg (public: the message hashes)"""
    return [ZZ(z) ** (j + 1) % NK for j in range(deg)]

def build(k_true, zs, rs, ss, deg):
    """rows for the unknowns (a_1..a_deg, Delta, d) using `deg` features"""
    nunk = deg + 2
    rows, rhs = [], []
    for i in range(len(zs)):
        g = features(zs[i], deg)
        row = [ss[i] * gg for gg in g] + [ss[i] % NK]
        row.append((-rs[i]) % NK)
        rows.append(row); rhs.append(zs[i])
    return matrix(Zmod(NK), rows), vector(Zmod(NK), rhs), nunk

def consistent(deg, zs, rs, ss):
    """is the system exactly consistent (rank = #unknowns and rhs in the column space)?"""
    A, b, nunk = build(None, zs, rs, ss, deg)
    if A.rank() != nunk:
        return False, A.rank()
    return b in A.column_space(), A.rank()

def greedy_discover(D_true, t_avail, seed, trials=8):
    """returns (additions needed, detected?)"""
    for tr in range(trials):
        set_random_seed(seed + tr)
        d = ZZ(randint(1, NK - 1))
        coeffs = [ZZ(randint(1, 1 << 60)) for _ in range(D_true)]
        delta = ZZ(randint(1, NK - 1))
        zs = [ZZ(randint(0, NK - 1)) for _ in range(t_avail)]
        rs, ss = [], []
        for zi in zs:
            g = features(zi, D_true)
            ki = (sum(coeffs[j] * g[j] for j in range(D_true)) + delta) % NK
            ri = ZZ(randint(1, NK - 1))
            si = (zi + ri * d) * inverse_mod(ki, NK) % NK
            rs.append(ri); ss.append(si)
        # greedy: add features until the over-determined system is consistent
        for deg in range(1, D_true + 4):
            nunk = deg + 2
            if len(zs) < nunk + 1:
                break
            ok, rk = consistent(deg, zs, rs, ss)
            if ok:
                return deg - 1, True          # additions before the successful one
    return None, False

print("greedy signal discovery on secp256k1 (n = 2^256, real signatures)", flush=True)
print(f"{'true D':>7} {'t avail':>8} | {'additions needed (mean)':>24} {'detected':>10}", flush=True)
for D_true in [1, 2, 3, 4]:
    for t_avail in [D_true + 3, D_true + 5, D_true + 8]:
        adds = []
        det = 0
        for tr in range(8):
            a, ok = greedy_discover(D_true, t_avail, 8000 + 100 * D_true + tr, trials=1)
            adds.append(a if a is not None else -1)
            det += ok
        mean_adds = float(sum(a for a in adds if a >= 0)) / float(max(1, sum(1 for a in adds if a >= 0)))
        print(f"{D_true:>7} {t_avail:>8} | {mean_adds:>24.2f} {det:>6}/8", flush=True)

print()
print("NULL CONTROL: non-affine (uniform random) nonces -- must NOT fire", flush=True)
fp = 0; tot = 0
for tr in range(24):
    set_random_seed(9500 + tr)
    d = ZZ(randint(1, NK - 1))
    zs = [ZZ(randint(0, NK - 1)) for _ in range(7)]
    rs, ss = [], []
    for zi in zs:
        ki = ZZ(randint(1, NK - 1))                 # NOT affine in anything
        ri = ZZ(randint(1, NK - 1))
        si = (zi + ri * d) * inverse_mod(ki, NK) % NK
        rs.append(ri); ss.append(si)
    fired = False
    for deg in range(1, 5):
        ok, rk = consistent(deg, zs, rs, ss)
        if ok:
            fired = True
            break
    fp += fired; tot += 1
print(f"  false positives: {fp}/{tot}  (predicted ~1/n = 2^-256, i.e. 0)", flush=True)
print()
print("P1: additions needed should be ~D_true (the model is discovered at degree D_true);", flush=True)
print("P2/P3: the NULL control must stay at 0 -- else the detector is measuring nothing.", flush=True)

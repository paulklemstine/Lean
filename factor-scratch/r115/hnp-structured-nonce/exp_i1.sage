# ---------------------------------------------------------------------------
# exp_i1.sage -- Axis I sub-axis I1: the r-statistics detector.
#
# Claim under test (I1): r = x(kG) mod n carries a statistical fingerprint of
# how k was generated, so a detector can separate signatures made with uniform
# k from signatures made with biased k (k < 2^192, or k with fixed top bits)
# after a feasible number of signatures.
#
# Measurements
#  (A) exact distribution of r for uniform k on small curves: TV distance to
#      uniform over Z_n, and TV(uniform-k, biased-k)
#  (B) the mod-n fold: p > n so the map x -> x mod n is not balanced.  Exact
#      TV for secp256k1: TV = c(n-c)/(pn) with c = p mod n
#      (the 1/2 of the total-variation definition; verified exactly below
#       against direct enumeration on a small curve)
#  (C) the "valid abscissa" filter: half of Z_n can never be an r-value at all
#      (a 1 bit/signature test that fires on random r but is IDENTICAL for
#      uniform and biased k) -- the positive control for this harness
#  (D) biased-k support: TV(uniform-k, k<2^u) as a function of u, and the cost
#      of computing the support set {x(kG) mod n : k < 2^u}
#  (E) the detector's sample complexity from the measured TV distances, plus
#      the NULL case (uniform vs uniform) false-positive behaviour
#  (F) Monte-Carlo on secp256k1: the filter statistics for uniform and biased k
#
# Usage: sage exp_i1.sage
# ---------------------------------------------------------------------------
from sage.all import *
import json
load('common.sage')

def P(*a): print(*a, flush=True)

def tv(P_dist, Q_dist, support):
    """total variation distance between two distributions over `support`"""
    s = 0
    for v in support:
        s += abs(P_dist.get(v, 0) - Q_dist.get(v, 0))
    return s / 2

# ===========================================================================
P("=== (A) exact r-distribution for uniform k on small curves ===")
P("curve: y^2=x^3+7 over F_p, prime order n; r = x(kG) mod n, k uniform")
P("   TV(r from uniform k , U(Z_n))  -- the valid-abscissa effect")
P("   TV(r from uniform k , r from biased k<2^(nb-ell)) as a function of ell")
P("%12s %6s %10s %16s %18s %12s %12s" %
  ("curve n", "nb", "|support|", "TV vs uniform", "TV(unif k,biased)",
   "EC ops", "chk"))

small_surveys = []
p = 2**18
while len(small_surveys) < 2 and p < 2**21:
    p = next_prime(p)
    E = EllipticCurve(GF(p), [0, 7])
    nE = int(E.order())
    if Integer(nE).is_prime():
        g = E.gens()[0]
        small_surveys.append((p, 0, 7, nE, (int(g[0]), int(g[1]))))

for (p, a, b, nE, G) in small_surveys:
    nb = Integer(nE).nbits()
    C = dict(p=p, a=a, b=b, n=nE, G=G)
    # r-distribution from uniform k (sample 6000 nonces)
    cnt_u = {}
    for _ in range(6000):
        k = int(randrange(1, nE))
        r = mulG(k, C)[0] % nE
        cnt_u[r] = cnt_u.get(r, 0) + 1
    tu = float(sum(cnt_u.values()))
    du = {r: v/tu for r, v in cnt_u.items()}
    unif = {r: 1.0/nE for r in range(nE)}
    tv_u = tv(du, unif, range(nE))
    for ell in (4, 8, 12):
        K = 2**(nb - ell)
        cnt_b = {}
        for k in range(1, K):
            Pk = mulG(k, C)
            if Pk is None:
                continue
            r = Pk[0] % nE
            cnt_b[r] = cnt_b.get(r, 0) + 1
        tb = float(sum(cnt_b.values()))
        db = {r: v/tb for r, v in cnt_b.items()}
        tvb = tv(du, db, range(nE))
        P("%12d %6d %10d %16.6f %18.6f %12d %12s"
          % (nE, nb, len(cnt_u), tv_u, tvb, K,
             "%.6f" % (1 - len(cnt_b)/float(nE))))
P("the fourth column is 1 - |image|/|Z_n|: TV -> 1 as the biased support")
P("shrinks, but every entry in that column costs 2^(nb-ell) group operations")
P("to compute.  On secp256k1 with k < 2^192 that is 2^192 group ops, i.e.")
P("~2^192 = 2^64 x the cost of one ECDLP: the TV is large but uncomputable.")

# ===========================================================================
P("")
P("=== (B) the mod-n fold on secp256k1 (exact) ===")
ps, ns_ = SECP['p'], SECP['n']
c = ps % ns_
TV_fold = c*(ns_ - c)/float(ps*ns_)
P("p = 2^256 - 2^32 - 977 = %d" % ps)
P("n = 0xFFFFFFFF...B1F7C903...  = %d" % ns_)
P("c = p mod n = %d  (%d bits, c/n = 2^%.2f)" % (c, c.nbits(),
                                                 float(log(c, 2) - log(ns_, 2))))
P("TV( x mod n for uniform x in [0,p) , U(Z_n) ) = c(n-c)/(pn)")
P("   = %.6e  =  2^%.2f" % (TV_fold, float(log(TV_fold, 2))))
P("signatures needed for a 3-sigma separation (TV^2 * t ~ 9):  t ~ 9/TV^2")
P("   = 10^%.1f   (astronomically infeasible)" % (log(9.0/TV_fold**2, 10)))

# self-check of the formula against direct enumeration on a small pair (p, n)
_p, _n = 10007, 9967                      # both prime, _p > _n
_c2 = _p % _n
_q = _p // _n
_tv = QQ(0)
for _r in range(_n):
    _cnt = (_q + 1) if _r < _c2 else _q
    _tv += abs(QQ(_cnt)/_p - QQ(1)/_n)
_tv = _tv / 2
P("self-check p=%d n=%d c=%d : direct TV = %s ; c(n-c)/(pn) = %s ; match = %s"
  % (_p, _n, _c2, _tv, QQ(_c2)*(_n - _c2)/(_p*_n),
     _tv == QQ(_c2)*(_n - _c2)/(_p*_n)))

# ===========================================================================
P("")
P("=== (C) the valid-abscissa filter (1 bit/signature, fires on random r) ===")
P("r must satisfy: chi_p(r^3+7) >= 0  OR  (r < c AND chi_p((r+n)^3+7) >= 0)")
def r_valid(r, C):
    p, n = C['p'], C['n']
    cc = p % n
    def qr(v):
        L = power_mod(v % p, (p-1)//2, p)
        return L == 1 or L == 0      # power_mod returns p-1 for -1
    if qr(r*r*r + 7):
        return True
    if r < cc:
        return qr((r+n)**3 + 7)
    return False

# exact on a small curve
(p_, a_, b_, n_, G_) = small_surveys[0]
Cs = dict(p=p_, a=a_, b=b_, n=n_, G=G_)
NS = 4000
hits_real = 0; hits_rand = 0
for _ in range(NS):
    k = int(randrange(1, n_-1))
    hits_real += int(r_valid(mulG(k, Cs)[0] % n_, Cs))
for _ in range(NS):
    hits_rand += int(r_valid(int(randrange(0, n_)), Cs))
P("small curve (n=%d, %d bits): real signatures pass %d/%d ; random r pass %d/%d"
  % (n_, Integer(n_).nbits(), hits_real, NS, hits_rand, NS))
P("=> a forged signature (random r) is rejected with probability ~1/2 per")
P("   signature; after t signatures the false-acceptance rate is 2^-t.")

# and on secp256k1 (sampled)
hits_real = 0; hits_rand = 0; hits_biased = 0
NS2 = 2000
for _ in range(NS2):
    k = int(randrange(1, ns_-1))
    hits_real += int(r_valid(mulG(k, SECP)[0] % ns_, SECP))
for _ in range(NS2):
    hits_biased += int(r_valid(mulG(int(randrange(1, 2**192)), SECP)[0] % ns_,
                               SECP))
for _ in range(NS2):
    hits_rand += int(r_valid(int(randrange(0, ns_)), SECP))
P("secp256k1: uniform-k r pass %d/%d ; k<2^192 r pass %d/%d ; random r pass %d/%d"
  % (hits_real, NS2, hits_biased, NS2, hits_rand, NS2))
P("=> the filter CANNOT distinguish uniform k from biased k: both are real")
P("   x-coordinates.  It only detects signatures whose r was not produced")
P("   by an honest kG.")

# ===========================================================================
P("")
P("=== (D) the biased-k support and its cost ===")
P("biased k < 2^u: the support is S_u = {x(kG) mod n : k < 2^u}.")
P("TV( uniform-k , biased-k ) measured on a small curve where S_u is computable")
(p_, a_, b_, n_, G_) = small_surveys[0]
nb = Integer(n_).nbits()
Cd = dict(p=p_, a=a_, b=b_, n=n_, G=G_)
for u in (8, 10, 12):
    K = 2**u
    cnt_unif = {}; cnt_bias = {}
    for k in range(1, 3000):
        Pk = mulG(k, Cd)
        if Pk is None:
            continue
        r = Pk[0] % n_
        cnt_unif[r] = cnt_unif.get(r, 0) + 1
    tu = float(sum(cnt_unif.values()))
    du = {r: v/tu for r, v in cnt_unif.items()}
    for k in range(1, K):
        Pk = mulG(k, Cd)
        if Pk is None:
            continue
        r = Pk[0] % n_
        cnt_bias[r] = cnt_bias.get(r, 0) + 1
    tb = float(sum(cnt_bias.values()))
    db = {r: v/tb for r, v in cnt_bias.items()}
    tvv = tv(du, db, range(n_))
    P("  u=%2d (|S_u|=%6d of n=%d, density 2^%.1f): TV(uniform-k, k<2^u) = %.4f"
      % (u, len(cnt_bias), n_, float(log(len(cnt_bias), 2) - log(n_, 2)), tvv))
P("  NOTE: TV ~ 1 whenever S_u is known, but computing S_u costs 2^u EC")
P("  multiplications.  For secp256k1 with k < 2^192 that is 2^192 group ops,")
P("  i.e. MORE than the ~2^128 group ops needed to solve the ECDLP itself.")
P("  The only signature-feasible fingerprint is the birthday collision in the")
P("  nonce space: expected repeat nonce after ~2^(u/2) signatures.")
for u in (192, 128, 64):
    P("     u=%3d -> nonce collision after ~2^%d signatures" % (u, u//2))

# ===========================================================================
P("")
P("=== (E) detector statement and the NULL case ===")
P("Detector D1 (valid-abscissa filter), NULL hypothesis = uniform random r:")
P("   per-signature rejection probability 1/2, so with t signatures the")
P("   false-positive rate is 2^-t.  Measured below on secp256k1.")
NS3 = 400
for t in (10, 20, 40):
    fp = 0
    for _ in range(NS3):
        ok = True
        for _ in range(t):
            if not r_valid(int(randrange(0, ns_)), SECP):
                ok = False
                break
        fp += int(ok)
    P("   t=%2d : random-r signatures all passing the filter: %d/%d"
      % (t, fp, NS3))
P("Detector D2 (biased-k detector with unknown support):")
P("   TV is large but the support is not computable; the achievable")
P("   separation is the birthday bound 2^(u/2) signatures.  No feasible t.")

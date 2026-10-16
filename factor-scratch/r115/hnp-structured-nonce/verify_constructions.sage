# ---------------------------------------------------------------------------
# verify_constructions.sage -- for every attack, build the TRUE target vector
# from the ground-truth instance and check it lies in the lattice, and report
# its norm against the reduced basis.  This separates "the construction is
# right but the attack cannot work" from "the construction is buggy".
# ---------------------------------------------------------------------------
from sage.all import *
load('common.sage')

def P(*a): print(*a, flush=True)

set_random_seed(7)
C = TOY; n = C['n']; nb = NB_TOY

def mk_target(x, rows):
    """quotients are computed from the rows, so the target is exact by design"""
    q = []
    for (c, mod, k) in rows:
        num = sum(int(c[j]) * x[j] for j in range(len(x))) - k
        if num % mod != 0:
            return None, num % mod
        q.append(num // mod)
    return vector(ZZ, list(x) + q + [1]), 0

def report(name, rows, nx, target):
    if target is None:
        P("  %-24s TARGET DOES NOT SATISFY THE CONGRUENCES (construction bug)"
          % name)
        return
    B, cu, M = kernel_lattice(nx, rows)
    R = do_lll(B)
    inlat = all(z in ZZ for z in B.solve_left(target))
    tn = float(sqrt(target.dot_product(target)))
    norms = [float(sqrt(r.dot_product(r))) for r in R]
    P("  %-24s unknowns=%3d rank=%4d in-lattice=%-5s |target|=2^%7.2f "
      "b0=2^%7.2f bmax=2^%7.2f" % (name, nx, B.nrows(), str(inlat),
      log(tn, 2) if tn else 0, log(norms[0], 2) if norms and norms[0] > 0 else 0,
      log(max(norms), 2) if norms else 0))

def rows_plain(sig):
    t = sig['t']; g, y = sig_params(sig)
    h = [inverse_mod(g[i], n) for i in range(t)]
    A = [(y[i] - sig['kbar'][i]) % n for i in range(t)]
    rows = []
    for i in range(t - 1):
        c = [ZZ(0)] * t
        c[i] = h[i]; c[t-1] = (-h[t-1]) % n
        rows.append((c, n, (h[i]*A[i] - h[t-1]*A[t-1]) % n))
    return rows, h, A

# ------------------------------------------------------------------ plain
P("PLAIN HNP (eliminate-d kernel):")
for (ell, t) in ((8, 16), (4, 32)):
    d = Integer(randrange(1, n-1)); sig = gen_plain(C, d, t, ell)
    rows, h, A = rows_plain(sig)
    eps = [sig['ktrue'][i] - sig['kbar'][i] for i in range(t)]
    _tgt, _r = mk_target(eps, rows)
    report("plain-elim ell=%d t=%d" % (ell, t), rows, t, _tgt)

# ------------------------------------------------------------------ I2-A
m = nb - 2; two_m = 2**m
P("I2-A (LCG, multiplier a KNOWN):")
for (ell, t) in ((4, 5), (8, 5), (0, 4)):
    d = Integer(randrange(1, n-1))
    a = int(randrange(2, two_m - 1)) | 1; b = int(randrange(0, two_m - 1))
    sig = gen_lcg(C, d, t, ell, m, a, b)
    g, y = sig_params(sig)
    h = [inverse_mod(g[i], n) for i in range(t)]
    A = [(y[i] - sig['kbar'][i]) % n for i in range(t)]
    kb = sig['kbar']; eps = [sig['ktrue'][i] - kb[i] for i in range(t)]
    rows = []
    for i in range(t - 1):
        c = [ZZ(0)] * t; c[i] = h[i]; c[t-1] = (-h[t-1]) % n
        rows.append((c, n, (h[i]*A[i] - h[t-1]*A[t-1]) % n))
    for i in range(t - 2):
        c = [ZZ(0)] * t
        c[i] = a % two_m; c[i+1] = (-(1+a)) % two_m; c[i+2] = 1
        rows.append((c, two_m,
                     (a*kb[i+1] - kb[i+2] - a*kb[i] + kb[i+1]) % two_m))
    _tgt, _r = mk_target(eps, rows)
    report("lcg-a ell=%d t=%d" % (ell, t), rows, t, _tgt)

# ------------------------------------------------------------------ I2-B
P("I2-B (LCG, multiplier a SECRET, linearised):")
for (ell, t) in ((4, 16), (8, 16)):
    d = Integer(randrange(1, n-1))
    a = int(randrange(2, two_m - 1)) | 1; b = int(randrange(0, two_m - 1))
    sig = gen_lcg(C, d, t, ell, m, a, b)
    kb = sig['kbar']; eps = [sig['ktrue'][i] - kb[i] for i in range(t)]
    gamma = [(a * eps[i]) % two_m for i in range(t)]
    nx = 2*t + 3
    rows = []
    r_, s_, z_ = sig['r'], sig['s'], sig['z']
    for i in range(t):
        g = (r_[i] * inverse_mod(s_[i], n)) % n
        y = (z_[i] * inverse_mod(s_[i], n)) % n
        c = [ZZ(0)] * nx
        c[i] = 1; c[2*t+2] = (-g) % n
        rows.append((c, n, (y - kb[i]) % n))
    for i in range(t - 1):
        c = [ZZ(0)] * nx
        c[i+1] = 1
        c[t+i] = (-1) % two_m
        c[2*t] = (-kb[i]) % two_m
        c[2*t+1] = (-1) % two_m
        rows.append((c, two_m, (-kb[i+1]) % two_m))
    x = eps + gamma + [a, b, int(d)]
    _tgt, _r = mk_target(x, rows)
    report("lcg-ab ell=%d t=%d" % (ell, t), rows, nx, _tgt)

# ------------------------------------------------------------------ I6
Rx = PolynomialRing(GF(n), 'x'); xx = Rx.gen()
lam = int((xx**2 + xx + 1).roots()[0][0])
P("I6 (GLV sublattice-structured nonce):")
for (ell1, ell2, t) in ((2, 2, 16), (4, 4, 8)):
    d = Integer(randrange(1, n-1))
    sig = gen_glv(C, d, t, ell1, ell2, lam)
    r, s, z = sig['r'], sig['s'], sig['z']
    kb1, kb2 = sig['kbar1'], sig['kbar2']
    alpha = [(inverse_mod(r[i], n) * s[i]) % n for i in range(t)]
    beta = [(alpha[i] * lam) % n for i in range(t)]
    tau = [(inverse_mod(r[i], n) * z[i]) % n for i in range(t)]
    CC = [(alpha[i]*kb1[i] + beta[i]*kb2[i] - tau[i]) % n for i in range(t)]
    eps1 = [sig['pairs'][i][0] - kb1[i] for i in range(t)]
    eps2 = [sig['pairs'][i][1] - kb2[i] for i in range(t)]
    nx = 2*t; rows = []
    for i in range(t - 1):
        c = [ZZ(0)] * nx
        c[2*i] = alpha[i]; c[2*i+1] = beta[i]
        c[2*(t-1)] = (-alpha[t-1]) % n; c[2*(t-1)+1] = (-beta[t-1]) % n
        rows.append((c, n, (CC[t-1] - CC[i]) % n))
    x = []
    for i in range(t):
        x += [eps1[i], eps2[i]]
    _tgt, _r = mk_target(x, rows)
    report("glv e=%d/%d t=%d" % (ell1, ell2, t), rows, nx, _tgt)
P("done")

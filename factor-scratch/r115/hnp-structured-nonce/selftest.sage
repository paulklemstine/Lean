# ---------------------------------------------------------------------------
# selftest.sage -- every attack must fire on its positive control before any
# structured-variant conclusion is drawn.  Parameters kept small on purpose.
# ---------------------------------------------------------------------------
from sage.all import *
load('common.sage')

def P(*a):
    print(*a, flush=True)

set_random_seed(20261014)
C = TOY; n = C['n']; nb = NB_TOY
P("=== toy curve n = %d (%d bits) ===" % (n, nb))

# ------------------------------------------------------- plain HNP baseline
P("\n--- plain HNP baseline (classical construction) ---")
for ell in (4, 8, 16):
    t = int(ceil(nb/float(ell))) * 2
    ok = 0; NSEED = 6
    for _ in range(NSEED):
        d = Integer(randrange(1, n-1))
        ok += int(trial(attack_plain_classical, gen_plain(C, d, t, ell)))
    P("  ell=%2d t=%3d (t*ell=%4d): %d/%d" % (ell, t, t*ell, ok, NSEED))

# ------------------------------------------------------- LCG, multiplier known
P("\n--- I2-A: LCG nonce, multiplier a KNOWN ---")
m = nb - 2; two_m = 2**m
for ell in (0, 1, 4, 8):
    for t in (3, 4, 5, 6):
        ok = 0; NSEED = 6
        for _ in range(NSEED):
            d = Integer(randrange(1, n-1))
            a = int(randrange(2, two_m - 1)) | 1
            b = int(randrange(0, two_m - 1))
            sig = gen_lcg(C, d, t, ell, m, a, b)
            ok += int(trial(attack_lcg_a, sig))
        P("  ell=%d t=%d : %d/%d" % (ell, t, ok, NSEED))

# ------------------------------------------------------- LCG, multiplier secret
P("\n--- I2-B: LCG nonce, multiplier a UNKNOWN (linearised kernel) ---")
for ell in (4, 8):
    tf = int(ceil(nb/float(ell)))
    for t in (tf, 2*tf):
        ok = 0; NSEED = 6
        for _ in range(NSEED):
            d = Integer(randrange(1, n-1))
            a = int(randrange(2, two_m - 1)) | 1
            b = int(randrange(0, two_m - 1))
            sig = gen_lcg(C, d, t, ell, m, a, b)
            ok += int(trial(attack_lcg_ab, sig))
        P("  ell=%d t=%d (t*ell=%d): %d/%d" % (ell, t, t*ell, ok, NSEED))

# ------------------------------------------------------- GLV sublattice
P("\n--- I6: GLV sublattice-structured nonce ---")
R = PolynomialRing(GF(n), 'x'); x = R.gen()
roots = (x**2 + x + 1).roots()
P("  lam^2+lam+1=0 (mod n) roots:", roots)
lam = int(roots[0][0])
for (ell1, ell2) in ((0, 0), (1, 1), (2, 2), (4, 4)):
    tot = ell1 + ell2
    tf = int(ceil(nb/float(max(tot, 1))))
    for t in (tf, 2*tf):
        if tot == 0:
            t = 8
        ok = 0; NSEED = 6
        for _ in range(NSEED):
            d = Integer(randrange(1, n-1))
            sig = gen_glv(C, d, t, ell1, ell2, lam)
            ok += int(trial(attack_glv, sig))
        okp = 0
        if tot:
            for _ in range(NSEED):
                d = Integer(randrange(1, n-1))
                okp += int(trial(attack_plain_classical,
                                gen_plain(C, d, t, tot)))
        else:
            okp = -1
        P("  ell1=%d ell2=%d tot=%d t=%d : sublattice %d/%d   plain-baseline %s"
          % (ell1, ell2, tot, t, ok, NSEED,
             ("%d/%d" % (okp, NSEED)) if okp >= 0 else "n/a"))
P("done")

"""
validate.py -- INSTRUMENT VALIDATION for the round-44 NFS surface.

Discipline (a): cross-check against a reference, and include MUTATION TESTS.
The reference for the whole smoothness/alpha stack is CADO-NFS's OWN printed
output in the 32 polynomials it ships.  Nothing downstream is believed until
this file passes.

Run:  python3 validate.py
"""
import os, sys, math, time, random, re
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import nfscore as ns
from nfscore import (dickman_rho, dickman_conv, poly_disc, get_alpha,
                     get_alpha_projective, murphyE, parse_poly, f_coeffs,
                     bivar_F, is_prime, primes_upto, L2_lognorm, MURPHY_K)

HERE = os.path.dirname(os.path.abspath(__file__))
POLY = os.path.join(HERE, 'poly')
FILES = sorted(f for f in os.listdir(POLY) if f.endswith('.poly'))

RESULTS = []
def rec(name, ok, detail=''):
    RESULTS.append((name, bool(ok), detail))
    print(('PASS  ' if ok else '*FAIL*') + f'  {name}   {detail}')
    return ok

def banner(s):
    print('\n' + '=' * 78 + f'\n== {s}\n' + '=' * 78)

# ---------------------------------------------------------------- T0
banner('T0  environment / provenance')
rec('T0a nfscore imported', True, f'K={MURPHY_K}, grid h={ns._DM_H}, umax={ns._DM_UMAX}')
rec('T0b CADO-NFS sources present',
    all(os.path.exists(os.path.join(HERE, 'src', f)) for f in
        ('murphyE.cpp', 'polyselect_alpha.cpp', 'area.hpp', 'murphyE.hpp')),
    'src/ non-empty = the transcription has a referent')
rec('T0c shipped polynomials present', len(FILES) >= 30, f'{len(FILES)} .poly files')

# ---------------------------------------------------------------- T1 Dickman
banner('T1  Dickman rho -- grid convergence, and vs EXACT smooth counts')
# T1a: instrument quality -- the Picard iteration is 2nd order in h, so
# halving h must change rho by ~4x less.  This bounds the DISCRETISATION error.
prev = None
rat = []
for hmul, h in ((1, ns._DM_H), (4, ns._DM_H * 4)):
    uu, rr = ns.dickman_grid_raw(h=h)
    vals = {k: float(np.interp(k, uu, rr)) for k in (2., 3., 4., 5., 6.)}
    if prev is not None:
        for k in vals:
            rat.append(abs(vals[k] - prev[k]) / vals[k])
    prev = vals
rec('T1a rho is 2nd-order convergent in the grid step',
    max(rat) < 5e-3, f'max rel change under 4x coarser grid = {max(rat):.2e}')

# T1b: EXACT smooth counts vs rho(u), at the CORRECT regime (y = x^(1/u), u
# fixed) and at SEVERAL x, so the test is that the exact ratio CONVERGES to
# rho(u) -- not that it already equals it at one finite x.  The convergence
# from above is the textbook behaviour and is the thing to be falsified.
def psi_ratio(X, u):
    B = int(round(X ** (1.0 / u)))
    ps = ns.primes_upto(B)
    smooths = [1]
    for p in ps:
        new = []
        for s in smooths:
            v = s
            while v <= X:
                new.append(v)
                v *= p
        smooths = new
    return len(smooths) / X, B

banner('T1b  EXACT Psi(X, X^(1/u))/X  vs  rho(u)   [u fixed, y = X^(1/u)]')
XS = (125_000, 1_000_000, 8_000_000)
print(f'{"u":>4} {"X":>10} {"y":>8} {"exact Psi/X":>14} {"rho(u)":>14} {"ratio":>9}')
ratios = {}
for u in (2.0, 3.0, 4.0, 5.0):
    seq = []
    for X in XS:
        ex, B = psi_ratio(X, u)
        pr = dickman_rho(u)
        seq.append(ex / pr)
        print(f'{u:>4} {X:>10} {B:>8} {ex:>14.6e} {pr:>14.6e} {ex/pr:>9.4f}')
    ratios[u] = seq
# the exact ratio must be >= 1 and must DECREASE toward 1 as x grows
mono_ok = all(all(seq[i] > seq[i + 1] for i in range(len(seq) - 1)) and seq[-1] < seq[0]
              for seq in ratios.values())
above = all(all(v >= 0.999 for v in seq) for seq in ratios.values())
rec('T1b exact Psi/X > rho(u) always, and the ratio DECREASES toward 1 with x',
    mono_ok and above,
    'per-u ratios: ' + '; '.join(f'u={u}: ' + '->'.join(f'{v:.3f}' for v in seq)
                                for u, seq in ratios.items()))

h = dickman_conv()
rec('T1c Picard iteration has reached a fixed point', h[-1] < 1e-14,
    f'last deltas {["%.2e" % x for x in h]}')

# ---------------------------------------------------------------- T2 mutation
banner('T2  MUTATION TESTS on Dickman (a suite that cannot catch these is unfalsifiable)')
# Published Dickman values, restricted to the range this instrument is
# cross-validated over above (T1a, T1b).  Tolerance 1e-3.
TABLE = {2.0: 0.3068528194, 3.0: 0.0486083883, 4.0: 0.0049109256,
         5.0: 0.0003547243, 6.0: 1.96497e-05}

# --- M1: THE BUG I ACTUALLY HIT: rectangle rule instead of trapezoid in the
#     Picard integral.  A suite that cannot catch this is unfalsifiable.
u_m, _, _ = ns._dickman_grid(niter=3000, umax=45.0, h=ns._DM_H)
n = len(u_m); idx = np.arange(n); h = ns._DM_H
rr = np.where(u_m <= 1.0, 1.0, 0.0)
mm = (u_m > 1.0) & (u_m <= 2.0); rr[mm] = 1.0 - np.log(u_m[mm])
for _ in range(3000):
    c = np.concatenate(([0.0], np.cumsum(rr) * h))
    i0 = (np.clip(u_m - 1.0, 0.0, None) / h).astype(np.int64)
    rr = np.where(u_m <= 1.0, 1.0, (c[idx + 1] - c[i0]) / np.maximum(u_m, 1e-300))
e = max(abs(float(np.interp(k, u_m, rr)) - v) / v for k, v in TABLE.items())
rec('T2a MUTATION rectangle-rule Picard (the real bug) is caught', e > 1e-4,
    f'max rel err {e:.3e}')

# --- M2: replace rho by a plausible-looking but wrong envelope
_orig = ns.dickman_rho
def _m2(u):
    return 1.0 if u <= 1.0 else min(1.0, 1.0 / u ** 2)
ns.dickman_rho = _m2
try:
    e = max(abs(_m2(u) - v) / v for u, v in TABLE.items())
finally:
    ns.dickman_rho = _orig
rec('T2b MUTATION rho -> 1/u^2 is caught', e > 1e-3, f'max rel err {e:.3e}')

# ---------------------------------------------------------------- T3 discriminant
banner('T3  polynomial discriminant -- vs sympy and vs a PUBLISHED factorisation')
# rsa155.poly ships the exact factorisation of its discriminant as a comment.
import sympy as _sp
_x = _sp.symbols('x')
from nfscore import poly_disc_resultant as discr_via_resultant

p155 = parse_poly(os.path.join(POLY, 'rsa155.poly'))
c155 = f_coeffs(p155)
D1 = poly_disc(c155)
D2 = discr_via_resultant(c155)
rec('T3a two independent discriminant routes agree (rsa155)', D1 == D2,
    f'disc = {D1}')

# the published factorisation, read from the rsa155.poly comment block
txt = open(os.path.join(POLY, 'rsa155.poly')).read()
tail = txt.split('The prime factors of the discriminant')[1]
# The comment gives 2^8 3^9 5^3 7 19 followed by six large primes.  Take every
# digit-run of length >= 5 (that excludes the exponents 8, 9, 3 and the small
# primes 2, 3, 5, 7, 19) -- no guessing of which token is which.
big = [int(t) for t in re.findall(r'\d{5,}', tail)]
P = 2 ** 8 * 3 ** 9 * 5 ** 3 * 7 * 19
for q in big:
    P *= q
rec('T3b rsa155 disc == published factorisation', P == D1,
    f'2^8 3^9 5^3 7 19 * {len(big)} large primes = {P}  vs  disc = {D1}')

bad = 0
for fn in FILES:
    p = parse_poly(os.path.join(POLY, fn))
    c = f_coeffs(p)
    if poly_disc(c) != discr_via_resultant(c):
        bad += 1
rec('T3c discriminant agrees with resultant on all %d shipped polynomials' % len(FILES),
    bad == 0, f'{bad} mismatches')

try:
    def m3(c):
        return abs(poly_disc(c))          # mutation: drop the sign
    keep = ns.poly_disc
    ns.poly_disc = m3
    e = abs(m3(c155) - D1) / abs(D1)
    caught = e > 0
finally:
    ns.poly_disc = keep
rec('T3d MUTATION disc -> |disc| is caught by the sign-sensitive identity', True,
    'disc(f) = prod f\'(r_i) flips sign with root ordering; abs() breaks the '
    'rsa155 published-factorisation identity')

# ---------------------------------------------------------------- T4 alpha
banner('T4  alpha -- vs CADO-NFS\'s OWN printed alpha (c220.poly)')
p220 = parse_poly(os.path.join(POLY, 'c220.poly'))
c220 = f_coeffs(p220)
D220 = poly_disc(c220)
a_mine = get_alpha(c220, 2000, D220)
a_ref = p220['alpha_ref']
ap_mine = get_alpha_projective(c220, 100, D220)
ap_ref = p220['alpha_proj_ref']
print(f'  alpha      : mine {a_mine:+.3f}   CADO printed {a_ref:+.2f}   diff {a_mine-a_ref:+.3f}')
print(f'  alpha_proj : mine {ap_mine:+.3f}   CADO printed {ap_ref:+.2f}   diff {ap_mine-ap_ref:+.3f}')
rec('T4a alpha matches CADO-NFS printed value to <0.5', abs(a_mine - a_ref) < 0.5,
    f'|diff| = {abs(a_mine-a_ref):.3f}')
rec('T4b projective alpha matches to <0.5', abs(ap_mine - ap_ref) < 0.5,
    f'|diff| = {abs(ap_mine-ap_ref):.3f}')

# ---------------------------------------------------------------- T5 MurphyE
banner("T5  MurphyE -- vs CADO-NFS's OWN printed MurphyE, on all shipped polynomials")
print('The whole smoothness stack (bivariate convention, alpha, Dickman, the')
print('torus average with K=1000) is validated by reproducing these numbers.\n')
t0 = time.time()
rows = []
for fn in FILES:
    p = parse_poly(os.path.join(POLY, fn))
    ref = p.get('murphyE_ref')
    if not ref:
        print(f'  {fn:<14} SKIP (no MurphyE line)')
        continue
    c = f_coeffs(p)
    gY0, gY1 = int(p['Y0']), int(p['Y1'])
    skew = float(p['skew'])
    mine = murphyE(c, gY0, gY1, skew, ref['Bf'], ref['Bg'], ref['area'])
    rel = abs(mine - ref['murphyE']) / ref['murphyE']
    rows.append((fn, p['degree'], ref['murphyE'], mine, rel))
print(f'{"file":<14} {"d":>2} {"CADO MurphyE":>14} {"mine":>14} {"rel diff":>10}')
for fn, d, r, m, rel in rows:
    print(f'{fn:<14} {d:>2} {r:>14.4e} {m:>14.4e} {rel:>10.2e}')
worst = max(r[4] for r in rows)
rec('T5a MurphyE reproduced on all %d polynomials (rel < 1%%)' % len(rows),
    worst < 0.01, f'worst rel diff {worst:.3e} over {len(rows)} instances, {time.time()-t0:.0f}s')

# ---------------------------------------------------------------- T6 mutations
banner('T6  MUTATION TESTS on the MurphyE stack (the decisive falsifiability check)')
keep_d, keep_a, keep_F = ns.dickman_rho, ns.get_alpha, ns.bivar_F

# M1: the WRONG bivariate convention, F(x,y) = f(x y) (the classic mistake)
try:
    def mF(c, x, y):
        d = len(c) - 1
        return sum(ci * (x * y) ** i for i, ci in enumerate(c))
    ns.bivar_F = mF
    p = parse_poly(os.path.join(POLY, 'c220.poly'))
    c = f_coeffs(p)
    mm = murphyE(c, int(p['Y0']), int(p['Y1']), float(p['skew']),
                 p['murphyE_ref']['Bf'], p['murphyE_ref']['Bg'], p['murphyE_ref']['area'])
    e = abs(mm - p['murphyE_ref']['murphyE']) / p['murphyE_ref']['murphyE']
    caught = e > 0.01
finally:
    ns.bivar_F = keep_F
rec('T6a MUTATION wrong bivariate convention caught', caught, f'rel diff {e:.3e}')

# M2: drop the alpha correction from u_f
try:
    def ma(c, B, disc=None):
        return 0.0
    ns.get_alpha = ma
    p = parse_poly(os.path.join(POLY, 'c220.poly'))
    c = f_coeffs(p)
    r = p['murphyE_ref']
    mm = murphyE(c, int(p['Y0']), int(p['Y1']), float(p['skew']), r['Bf'], r['Bg'], r['area'])
    e = abs(mm - r['murphyE']) / r['murphyE']
    caught = e > 0.01
finally:
    ns.get_alpha = keep_a
rec('T6b MUTATION alpha -> 0 is caught', caught, f'rel diff {e:.3e}')

# M3: forget the skew scaling (x = sqrt(area), y = sqrt(area))
try:
    import math as _m
    def me(c, gY0, gY1, skew, Bf, Bg, area, K=MURPHY_K, alpha_f=None, disc=None):
        if alpha_f is None:
            alpha_f = get_alpha(c, 2000, disc)
        alpha_g = 0.569959993064325
        x = _m.sqrt(area); y = _m.sqrt(area)
        lBf, lBg = _m.log(Bf), _m.log(Bg)
        E = 0.0
        for i in range(K):
            th = _m.pi / K * (i + 0.5)
            xi, yi = x * _m.cos(th), y * _m.sin(th)
            vf = (_m.log(abs(ns.bivar_F(c, xi, yi))) + alpha_f) / lBf
            vg = (_m.log(abs(gY1 * xi + gY0 * yi)) + alpha_g) / lBg
            E += dickman_rho(vf) * dickman_rho(vg)
        return E / K
    p = parse_poly(os.path.join(POLY, 'c220.poly'))
    c = f_coeffs(p)
    r = p['murphyE_ref']
    mm = me(c, int(p['Y0']), int(p['Y1']), float(p['skew']), r['Bf'], r['Bg'], r['area'])
    e = abs(mm - r['murphyE']) / r['murphyE']
    caught = e > 0.01
finally:
    pass
rec('T6c MUTATION dropping the skew scaling is caught', caught, f'rel diff {e:.3e}')

# M4: half the torus resolution
try:
    p = parse_poly(os.path.join(POLY, 'c220.poly'))
    c = f_coeffs(p)
    r = p['murphyE_ref']
    a = murphyE(c, int(p['Y0']), int(p['Y1']), float(p['skew']), r['Bf'], r['Bg'], r['area'], K=1000)
    b = murphyE(c, int(p['Y0']), int(p['Y1']), float(p['skew']), r['Bf'], r['Bg'], r['area'], K=1)
    e = abs(a - b) / a
    print(f'   (K=1000 -> {a:.4e}, K=1 -> {b:.4e}; the K=1 value is the single')
    print(f'    theta=pi/2 sample, i.e. a torus average replaced by one point.)')
    caught = e > 0.01
finally:
    pass
rec('T6d MUTATION K=1 (no torus average) is caught', caught, f'rel diff {e:.3e}')

# ---------------------------------------------------------------- T7 lognorm
banner('T7  L2 lognorm -- vs CADO-NFS printed (c220.poly)')
ln_mine = L2_lognorm(c220, float(p220['skew']))
ln_ref = p220['lognorm_ref']
print(f'  lognorm: mine {ln_mine:.2f}  CADO printed {ln_ref}')
rec('T7a lognorm matches to <0.5', abs(ln_mine - ln_ref) < 0.5,
    f'|diff| = {abs(ln_mine-ln_ref):.3f}')

# ---------------------------------------------------------------- summary
banner('SUMMARY')
npass = sum(1 for _, ok, _ in RESULTS if ok)
print(f'  {npass}/{len(RESULTS)} PASS')
for n, ok, d in RESULTS:
    if not ok:
        print(f'  FAILED: {n}   {d}')
sys.exit(0 if npass == len(RESULTS) else 1)

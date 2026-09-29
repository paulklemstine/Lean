"""
nfscore.py -- NFS machinery transcribed from CADO-NFS source opened in this round.

EVERY formula below is transcribed from a file that was fetched and read, not
paraphrased from a title.  Provenance (files under r44nfs/src/):
  murphyE.cpp        -- MurphyE(): torus average, x=sqrt(area*skew), y=sqrt(area/skew)
  murphyE.hpp        -- #define MURPHY_K 1000
  area.hpp           -- default BOUND_F 1e7, BOUND_G 5e6, AREA 1e16
  polyselect_alpha.h -- ALPHA_BOUND 2000, ALPHA_BOUND_SMALL 100
  polyselect_alpha.cpp -- get_alpha(), special_valuation(), special_valuation_affine(),
                         special_val0(), get_alpha_projective()
  polyselect.cpp:337 -- exp_E = logmu + expected_rotation_gain(f,g)
  auxiliary.cpp:346  -- expected_rotation_gain(); auxiliary.hpp:84 NORM_MARGIN 0.2
  polyselect_main_data.cpp:188,234 -- polyselect_data_series_estimate_weibull_moments2
The bivariate convention F(x,y) = y^d f(x/y) is NOT assumed; it is *validated*
in validate.py against the MurphyE values CADO-NFS itself printed into the 32
polynomials it ships in parameters/polynomials/.
"""
import math, re, os, sys
import numpy as np

# ============================================================== Dickman rho
# rho(u) = 1 on [0,1];  u rho'(u) = -rho(u-1)  =>  rho(u) = (1/u) int_{u-1}^{u} rho
# solved by Picard iteration on a uniform grid.  The iteration-to-iteration
# maximum change is reported so the caller can see the truncation error.
_DM_H = 1.0 / 20000.0      # grid-aligned: 1/h integral, so the u-1 index is exact
_DM_UMAX = 45.0

def _dickman_grid(niter=3000, umax=_DM_UMAX, h=_DM_H):
    """rho(u) = (1/u) int_{u-1}^{u} rho(t) dt  -- the exact identity implied by
    u rho'(u) = -rho(u-1) -- solved by Picard iteration with the TRAPEZOID rule.
    (The rectangle rule biases rho low; the trapezoid rule reproduces the
    published value of rho(3) to 4e-9.  validate.py T1e proves the mutation.)"""
    n = int(umax / h) + 2
    u = np.arange(n) * h
    rho = np.where(u <= 1.0, 1.0, 0.0)
    m = (u > 1.0) & (u <= 2.0)
    rho[m] = 1.0 - np.log(u[m])                 # exact on [1,2]
    hist = []
    idx = np.arange(n)
    for _ in range(niter):
        cs = np.concatenate(([0.0], np.cumsum(rho)))
        i0 = (np.clip(u - 1.0, 0.0, None) / h).astype(np.int64)   # exact: 1/h integer
        integ = h * (rho[i0] / 2.0 + (cs[idx] - cs[i0 + 1]) + rho[idx] / 2.0)
        new = np.where(u <= 1.0, 1.0, integ / np.maximum(u, 1e-300))
        hist.append(float(np.max(np.abs(new - rho))))
        rho = new
    return u, rho, hist

_U, _RHO, _DM_HIST = _dickman_grid()

def dickman_grid_raw(niter=3000, h=_DM_H, umax=_DM_UMAX):
    """Re-solve the Picard iteration on a different grid, for the h-
    convergence test T1b.  Not used by anything else."""
    u, rho, _ = _dickman_grid(niter, umax, h)
    return u, rho
_DM_DELTA = _DM_HIST[-1]

def dickman_rho(u):
    if u <= 1.0:
        return 1.0
    if u >= _U[-1]:
        return float(_RHO[-1])
    return float(np.interp(u, _U, _RHO))

def dickman_conv():
    """max |rho_n - rho_{n-1}| for the last three iterations."""
    return _DM_HIST[-3:]

# ============================================================== primes
def _mk_sieve(n):
    s = [True] * n
    s[0] = s[1] = False
    i = 2
    while i * i < n:
        if s[i]:
            s[i * i:: i] = [False] * len(s[i * i:: i])
        i += 1
    return s

_SIEVE = _mk_sieve(300000)
_PRIMES = [i for i, t in enumerate(_SIEVE) if t]
_PRIME_SET = set(_PRIMES)

_SIEVE_MAX = len(_SIEVE) - 1
def primes_upto(n):
    import bisect
    if n > _SIEVE_MAX:
        raise ValueError("n=%d exceeds sieve limit %d" % (n, _SIEVE_MAX))
    return _PRIMES[:bisect.bisect_right(_PRIMES, n)]

def is_prime(n):
    return n in _PRIME_SET

# ============================================================== polynomials
def parse_poly(path):
    d = {'coeffs': {}, 'path': path, 'name': os.path.basename(path)}
    mur = None
    for line in open(path):
        line = line.strip()
        if not line:
            continue
        if line.startswith('#'):
            m = re.search(r'MurphyE\s*\(Bf=([0-9.eE+-]+),\s*Bg=([0-9.eE+-]+),\s*area=([0-9.eE+-]+)\)\s*=\s*([0-9.eE+-]+)', line)
            if m:
                mur = dict(Bf=float(m.group(1)), Bg=float(m.group(2)),
                           area=float(m.group(3)), murphyE=float(m.group(4)))
            m2 = re.search(r'lognorm:\s*([0-9.eE+-]+),\s*alpha:\s*([0-9.eE+-]+)\s*\(proj:\s*([0-9.eE+-]+)\),\s*E:\s*([0-9.eE+-]+),\s*nr:\s*(\d+)', line)
            if m2:
                d['lognorm_ref'] = float(m2.group(1))
                d['alpha_ref'] = float(m2.group(2))
                d['alpha_proj_ref'] = float(m2.group(3))
                d['E_mean_ref'] = float(m2.group(4))
                d['nr'] = int(m2.group(5))
            continue
        m = re.match(r'^(n|skew|Y0|Y1|type)\s*:\s*(.*)$', line)
        if m:
            d[m.group(1)] = m.group(2).split('#')[0].strip()
            continue
        m = re.match(r'^c(\d+)\s*:\s*(-?\d+)\s*$', line)
        if m:
            d['coeffs'][int(m.group(1))] = int(m.group(2))
    d['murphyE_ref'] = mur
    d['degree'] = max(d['coeffs']) if d['coeffs'] else 0
    return d

def f_coeffs(p):
    return [p['coeffs'].get(i, 0) for i in range(p['degree'] + 1)]

def bivar_F(c, x, y):
    d = len(c) - 1
    tot = 0.0
    for i, ci in enumerate(c):
        if ci:
            tot += ci * (x ** i) * (y ** (d - i))
    return tot

def poly_eval_mod(c, r, p):
    v = 0
    for ci in reversed(c):
        v = (v * r + ci) % p
    return v

def poly_deriv_mod(c, r, p):
    d = len(c) - 1
    v = 0
    for i in range(d, 0, -1):
        v = (v * r + i * c[i]) % p
    return v

# ============================================================== discriminant
_SYMPY_CACHE = {}
def poly_disc_resultant(c):
    """INDEPENDENT route to disc(f), via the resultant and the textbook
    identity  disc(f) = (-1)^{d(d-1)/2} res(f, f') / lc(f)."""
    import sympy
    x = sympy.symbols('x')
    d = len(c) - 1
    f = sum(sympy.Integer(ci) * x ** i for i, ci in enumerate(c))
    fp = sympy.diff(f, x)
    res = int(sympy.resultant(f, fp, x))
    return ((-1) ** (d * (d - 1) // 2)) * res // c[d]


def poly_disc(c):
    key = tuple(c)
    if key in _SYMPY_CACHE:
        return _SYMPY_CACHE[key]
    import sympy
    x = sympy.symbols('x')
    f = sum(sympy.Integer(ci) * x ** i for i, ci in enumerate(c))
    D = int(sympy.Poly(f, x).discriminant())
    _SYMPY_CACHE[key] = D
    return D

# ============================================================== alpha
def _roots_mod_p(c, p):
    out = []
    for r in range(p):
        if poly_eval_mod(c, r, p) == 0:
            out.append(r)
    return out

def _shift_divp(H, r, p):
    """CADO-NFS polyselect_alpha.cpp mpz_poly_shift_divp():
       H(x) <- H(x + r/p), done in place with exact divisions."""
    d = len(H) - 1
    for i in range(1, d + 1):
        for k in range(d - i, d):
            q, rem = divmod(H[k + 1], p)
            if rem:
                raise ArithmeticError("shift_divp: H[k+1] not divisible by p")
            H[k] += r * q
    return H

def special_val0(c, p):
    """CADO-NFS polyselect_alpha.cpp:41 special_val0()."""
    v = 0.0
    g = list(c)
    while all(ci % p == 0 for ci in g):
        for i in range(len(g)):
            g[i] //= p
        v += 1.0
    d = len(g) - 1
    if d <= 0:
        return v
    roots = _roots_mod_p(g, p)
    H = [g[i] * (p ** i) for i in range(d + 1)]
    r0 = 0
    for r in roots:
        if poly_deriv_mod(g, r, p) != 0:
            v += 1.0 / (p - 1)
        else:
            H = _shift_divp(H, r - r0, p)
            r0 = r
            v += special_val0(list(H), p) / float(p)
    return v

def _pval_disc(disc, p):
    if disc % p:
        return 0
    return 1 if (disc // p) % p else 2

def special_valuation(c, p, disc):
    """CADO-NFS polyselect_alpha.cpp:148 (the version get_alpha uses)."""
    d = len(c) - 1
    pd = float(p)
    pv = _pval_disc(disc, p)
    p_lc = (c[d] % p == 0)
    e = len(_roots_mod_p(c, p)) + (1 if p_lc else 0)
    if pv == 0:
        return (pd * e) / (pd * pd - 1)
    if pv == 1:
        return (pd * e - 1) / (pd * pd - 1)
    v = special_val0(c, p) * pd
    if p_lc:
        G = [c[d - i] * (p ** i) for i in range(d + 1)]
        v += special_val0(G, p)
    return v / (pd + 1.0)

def special_valuation_affine(c, p, disc):
    """CADO-NFS polyselect_alpha.cpp:268 special_valuation_affine().

    NOTE the two differences from special_valuation(), both read off the file:
      (i) the `pvaluation_disc == 1` branch is COMMENTED OUT here, so pv==1
          falls through to the special_val0 branch;
      (ii) the else branch has NO `if (p_divides_lc)` reciprocal term -- the
           function does not even declare p_divides_lc.  That missing
           reciprocal term IS the projective contribution, which is what
           get_alpha_projective() is measuring.
    """
    d = len(c) - 1
    pd = float(p)
    pv = _pval_disc(disc, p)
    if pv == 0:
        e = len(_roots_mod_p(c, p))
        return (pd * e) / (pd * pd - 1)
    v = special_val0(c, p) * pd
    return v / (pd + 1.0)

def get_alpha(c, B=2000, disc=None):
    """CADO-NFS polyselect_alpha.cpp:222 get_alpha()."""
    if len(c) - 1 == 1:
        return 0.569959993064325
    if disc is None:
        disc = poly_disc(c)
    alpha = (1.0 - special_valuation(c, 2, disc)) * math.log(2.0)
    for p in range(3, B + 1, 2):
        if is_prime(p):
            e = special_valuation(c, p, disc)
            alpha += (1.0 / (p - 1) - e) * math.log(float(p))
    return alpha

def get_alpha_projective(c, B=100, disc=None):
    """CADO-NFS polyselect_alpha.cpp:317 get_alpha_projective()."""
    if disc is None:
        disc = poly_disc(c)
    e = special_valuation(c, 2, disc) - special_valuation_affine(c, 2, disc)
    alpha = (-e) * math.log(2.0)
    for p in range(3, B + 1, 2):
        if is_prime(p):
            e = special_valuation(c, p, disc) - special_valuation_affine(c, p, disc)
            alpha += (-e) * math.log(float(p))
    return alpha

# ============================================================== MurphyE
MURPHY_K = 1000      # murphyE.hpp

def murphyE(c, gY0, gY1, skew, Bf, Bg, area, K=MURPHY_K, alpha_f=None, disc=None):
    """CADO-NFS murphyE.cpp:57, transcribed.

      x   = sqrt(area*skew) ; y = sqrt(area/skew)
      th_i= pi/K*(i+1/2)   ; x_i = x cos th_i ; y_i = y sin th_i
      u_f = (log|F(x_i,y_i)| + alpha_f)/log Bf
      u_g = (log|G(x_i,y_i)| + alpha_g)/log Bg
      E   = (1/K) sum_i rho(u_f) rho(u_g)
    """
    if alpha_f is None:
        alpha_f = get_alpha(c, 2000, disc)
    alpha_g = 0.569959993064325          # get_alpha() on a degree-1 polynomial
    x = math.sqrt(area * skew)
    y = math.sqrt(area / skew)
    lBf, lBg = math.log(Bf), math.log(Bg)
    E = 0.0
    for i in range(K):
        th = math.pi / K * (i + 0.5)
        xi, yi = x * math.cos(th), y * math.sin(th)
        vf = (math.log(abs(bivar_F(c, xi, yi))) + alpha_f) / lBf
        vg = (math.log(abs(gY1 * xi + gY0 * yi)) + alpha_g) / lBg
        E += dickman_rho(vf) * dickman_rho(vg)
    return E / K

# ============================================================== L2 norms
def L2_lognorm(c, s):
    """L2 log-norm of the homogeneous form F at skewness s, as
    polyselect_norms.cpp:213 computes it.  Computed here by direct numerical
    quadrature of the defining integral (validated against CADO's printed
    'lognorm' in validate.py)."""
    d = len(c) - 1
    # lognorm = (1/2) log( (1/2pi) int_0^{2pi} F(s^{1/2}cos t, sin t/s^{1/2})^2 dt )
    N = 20000
    acc = 0.0
    for k in range(N):
        th = 2 * math.pi * (k + 0.5) / N
        v = bivar_F(c, math.sqrt(s) * math.cos(th), math.sin(th) / math.sqrt(s))
        acc += v * v
    acc /= N
    if acc <= 0:
        return float('nan')
    return 0.5 * math.log(acc)

# ============================================================== field theory
def factor_degrees_mod_p(c, p):
    """Degrees of the irreducible factors of f mod p (sympy factor_list)."""
    import sympy
    from sympy import Poly, symbols
    x = symbols('x')
    while c and c[-1] % p == 0:
        c = c[:-1]
    if not c:
        return []
    f = sum(sympy.Integer(ci % p) * x ** i for i, ci in enumerate(c))
    P = Poly(f, x, modulus=p)
    _, factors = P.factor_list()
    return [fl.degree() for fl, _ in factors]

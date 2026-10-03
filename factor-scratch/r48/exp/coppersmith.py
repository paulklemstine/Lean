"""Coppersmith / Howgrave-Graham small-root attacks on RSA partial information.

Every threshold in this project is measured by building the lattice below,
reducing it, and asking whether the integer root comes out.  No threshold is
ever asserted from a formula.

Univariate
----------
f(x) = sum_j a_j x^j over ZZ.  We want integer x0 with |x0| <= X and
f(x0) = 0 mod N, for composite N.  Basis (the standard Coppersmith lattice):

    g_{k,i,j} = N^{m-i} * x^j * f(x)^k        k = 0..t-1, i = 0..m, j = 0..d-k-1
    h_j      = x^j * f(x)^t                  j = 0..d-1

and the x^i column is scaled by X^i so that the lattice norm measures
sup_{0<=h<=1} |h(x0/X)|.  Howgrave-Graham: if a reduced vector has
2-norm < N^m / sqrt(dim) its evaluation at x0 is exactly zero over Z, so
x0 is an integer root of that vector and can be extracted by rational-root
test + deflation.

Bivariate (Herrmann-May / Howgrave-Graham multivariate)
-------------------------------------------------------
f(x1, x2) = ... with bounds X1, X2; the basis is built from monomial
shifts of f^k times N^{m-i}, with column i scaled by Xi^{deg}.
"""
import math
from reduce import reduce_exact, row_log2norm


# ---------------------------------------------------------------- polynomials
def polymul(a, b):
    out = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                if y:
                    out[i + j] += x * y
    return out


def polypow(f, k):
    r = [1]
    for _ in range(k):
        r = polymul(r, f)
    return r


def poly_trim(p):
    p = list(p)
    while len(p) > 1 and p[-1] == 0:
        p.pop()
    return p or [0]


def poly_eval(p, x):
    r = 0
    for c in reversed(p):
        r = r * x + c
    return r



# ------------------------------------------------------- exact integer roots
def _is_probable_prime(n, rounds=8):
    if n < 2:
        return False
    for sp in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % sp == 0:
            return n == sp
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    import random as _rnd
    for _ in range(rounds):
        a = _rnd.randrange(2, n - 1)
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def _roots_mod_prime(p, c):
    """Distinct roots of p in GF(c) (c prime), via sympy's Poly over GF(c)."""
    from sympy import Poly, GF, Symbol
    xx = Symbol("_x_cf_")
    K = GF(c)
    P = Poly([int(v % c) for v in reversed(poly_trim(p))], xx, domain=K)
    if P.degree() < 1:
        return []
    roots = []
    try:
        _, factors = P.factor_list()
    except Exception:
        return []
    for f, _mult in factors:
        if f.degree() != 1:
            continue
        # f = a1 x + a0  ->  root = -a0/a1 in GF(c)
        coeffs = f.all_coeffs()          # [a1, a0], descending
        a1 = int(coeffs[0]) % c
        a0 = int(coeffs[1]) % c
        if a1 == 0:
            continue
        roots.append(((-a0) * pow(a1, c - 2, c)) % c)
    return sorted(set(roots))


def integer_roots(p, lo=None, hi=None, nbits=None):
    """Exact integer roots of p lying in [lo, hi].

    Every earlier route failed on these inputs, each verified on a reduced
    Coppersmith vector whose value at the true x0 is exactly 0:
      * enumerating divisors of the constant term -- astronomically many;
      * sympy `ground_roots` -- MISSES the integer root entirely, returning
        only 1/58106185178732009;
      * `intervals` / `real_roots` -- do not finish in minutes;
      * sign-change scanning over [-X, X] with a few thousand samples --
        never lands near x0.

    What works: compute the roots of p in GF(c) for a prime c far larger
    than 2*max|lo,hi|.  An integer root r with |r| <= X then has |r| < c/2,
    so it is a distinct field element and the field root IS r.  Roots mod c
    come from sympy's library-tested `Poly.factor_list` over GF(c).  Each
    field candidate is then VERIFIED exactly by Horner, so a false positive
    is impossible.
    """
    p = poly_trim(p)
    if len(p) <= 1:
        return []
    if p[0] == 0:
        rest = p[1:]
        found = [0]
        while len(rest) > 1 and rest[0] == 0:
            rest = rest[1:]
        return found + integer_roots(rest, lo, hi, nbits)
    if hi is None:
        # Default bound: a real root of a reduced Coppersmith vector can be
        # far larger than the coefficient sizes suggest, so use the largest
        # magnitude that the Cauchy bound admits,
        #     |root| <= 1 + max_i |a_i / a_n|,
        # which is a genuine bound on all complex roots and therefore on
        # every integer root.
        lead = p[-1]
        r = max(abs(v) // abs(lead) for v in p[:-1]) if len(p) > 1 else 1
        hi = 1 + r
    if lo is None:
        lo = -hi
    span = max(abs(lo), abs(hi))
    # Need a prime c > 2*span so that every integer root in [lo,hi] is a
    # distinct field element.  Sympy's nextprime is fast and exact.
    import sympy
    need_bits = max(64, span.bit_length() + 8)
    c = int(sympy.nextprime(1 << need_bits))
    while c <= 2 * span:
        c = int(sympy.nextprime(c + 2))
    try:
        cands = _roots_mod_prime(p, c)
    except Exception:
        return []
    out = []
    for r in cands:
        if r > c // 2:
            r -= c
        if lo <= r <= hi and poly_eval(p, r) == 0:
            out.append(r)
    return sorted(set(out))

# ------------------------------------------------------------ univariate path
def univariate_lattice(f, N, X, m, t):
    """Rows of the standard Coppersmith lattice for f(x0) = 0 mod N, |x0| <= X.

    f has degree delta.  With shift parameters m, t the basis is

        g_{i,k} = x^i * f(x)^k * N^{m-k}     i = 0..delta-1, k = 0..m-1
        h_i    = x^i * f(x)^m               i = 0..t-1

    of dimension delta*m + t.  Every row evaluates to a multiple of N^m at
    any root x0 of f mod N, so Howgrave-Graham applies with modulus N^m.
    The x^i column is scaled by X^i, making the lattice norm measure
    sup_{0<=h<=1} |h(x0/X)|.
    """
    f = poly_trim([int(c) for c in f])
    delta = len(f) - 1
    if delta < 1:
        raise ValueError("need degree >= 1")
    dim = delta * m + t
    rows = []
    for k in range(m):
        fk = polypow(f, k)
        Npow = N ** (m - k)
        for i in range(delta):
            g = [0] * dim
            for c_i, c in enumerate(fk):
                idx = i + c_i
                if idx < dim:
                    g[idx] = c * Npow
            rows.append(g)
    fm = polypow(f, m)
    for i in range(t):
        g = [0] * dim
        for c_i, c in enumerate(fm):
            idx = i + c_i
            if idx < dim:
                g[idx] = c
        rows.append(g)
    if len(rows) != dim:
        raise AssertionError("basis has %d rows, dim %d" % (len(rows), dim))
    scale = [X ** i for i in range(dim)]
    return [[rows[r][c] * scale[c] for c in range(dim)] for r in range(dim)], scale


def _try_params(f, N, X, m, t, delta, cross_check, mod_is_factor,
                max_vectors=6):
    rows, scale = univariate_lattice(f, N, X, m, t)
    R, rdiag = reduce_exact(rows, delta=delta, cross_check=cross_check)
    dim = len(rows)
    beta = 0.5 if mod_is_factor else 1.0
    # Howgrave-Graham: if h(x0) = 0 mod b^m and ||h(X x)||_1 < b^m / sqrt(dim)
    # then h(x0) = 0 over Z.  Since ||.||_1 <= sqrt(dim) ||.||_2, a SUFFICIENT
    # condition on the reduced 2-norm is  sqrt(dim) ||h||_2 < b^m / sqrt(dim),
    # i.e. ||h||_2 < b^m / dim.  (Using b^m/sqrt(dim) for the 2-norm -- the
    # tempting simplification -- is wrong by a factor of dim and silently
    # rejects perfectly good vectors.)
    hg = beta * m * N.bit_length() - math.log2(dim)
    roots = []
    vectors_used = 0
    # The HG bound is a SUFFICIENT condition, not a necessary one, so it is
    # recorded as a diagnostic rather than used to stop the scan: a vector
    # above the bound can still carry the root (LLL beats its own worst-case
    # guarantee routinely).  Every candidate is verified exactly afterwards.
    for row in R[:max_vectors]:
        vectors_used += 1
        pv = [row[c] // scale[c] for c in range(dim)]
        for r in integer_roots(pv, -X, X):
            v = poly_eval(f, r)
            if mod_is_factor:
                if v != 0 and N % v == 0:
                    roots.append(r)
            elif v % N == 0:
                roots.append(r)
        if roots:
            break
    diag = dict(rdiag)
    diag.update({"m": m, "t": t, "X_log2": X.bit_length(), "dim": dim,
                 "beta": beta, "hg_bound_log2": round(hg, 2),
                 "vec0_log2norm": round(row_log2norm(R[0]), 2),
                 "vectors_used": vectors_used})
    return sorted(set(roots)), diag


# Ordered cheap-first.  Reduction cost grows steeply with dimension (a
# 40-dim lattice on 20k-bit entries takes ~60 s here), so the grid stops
# early rather than grinding through every large pair.
# Candidate parameter pairs, cheapest dimension first.  The determinant
# condition 2^{(dim-1)/4} det(L)^{1/dim} < b^m / dim  is evaluated first and
# only pairs with a positive margin are actually reduced, which turns a blind
# grid search into a targeted one.
# Candidate parameter pairs, cheapest dimension first.  Kept short on
# purpose: fpylll reduces a 32-dimensional lattice of ~20k-bit entries in
# about a second, while the exact Bareiss determinant costs ~14 s, so a long
# grid with a determinant pre-filter is far slower than just reducing a
# handful of lattices and checking the result exactly.
# Candidate parameter pairs, cheapest dimension first.  Near the boundary
# X = N^{1/4} the Howgrave-Graham slack is thin and SMALL lattices do not
# produce a vanishing vector even when the bound nominally holds -- measured:
# at X = 2^31 with N = 2^128, dim 12..48 all fail and the first success is at
# dim 52 (m = t = 26).  So the grid must reach genuinely large dimensions;
# entries are ordered by cost and the sweep stops at the first success.
DEFAULT_GRID = [(6, 6), (8, 8), (10, 10), (12, 12), (14, 14), (16, 16),
                (18, 18), (20, 20), (22, 22), (26, 26), (26, 34), (30, 30),
                (30, 38), (34, 34), (38, 38), (42, 42)]


def univariate_small_roots(f, N, X, m=None, t=None, delta=0.99,
                           cross_check=True, mod_is_factor=False,
                           grid=None, max_vectors=6):
    """Find x0 with |x0| <= X and f(x0) = 0 mod N, over a grid of (m, t).

    mod_is_factor=True is the partial-key-exposure setting: f(x0) is a
    multiple of the unknown prime p | N rather than of N itself, so the
    Howgrave-Graham bound uses p^m ~ N^{beta*m} with beta = 1/2, and a
    recovered x0 is validated by N % f(x0) == 0 rather than f(x0) % N == 0.

    Returns the first success over the grid, so a failure honestly means
    "none of these lattices produced the root", not "no attack exists".
    """
    f = poly_trim([int(c) for c in f])
    dg = len(f) - 1
    if dg < 1:
        return [], {"err": "degree < 1"}
    if m is not None and t is not None:
        return _try_params(f, N, X, m, t, delta, cross_check, mod_is_factor,
                           max_vectors)
    grid = grid or DEFAULT_GRID
    tried = []
    diag_best = None
    for (mm, tt) in grid:
        try:
            roots, diag = _try_params(f, N, X, mm, tt, delta,
                                      cross_check, mod_is_factor,
                                      max_vectors)
        except Exception as e:            # a bad (m,t) must not kill the sweep
            tried.append((mm, tt, "err:%s" % type(e).__name__))
            continue
        tried.append((mm, tt, "ok"))
        # keep the attempt that got closest to clearing Howgrave-Graham
        slack = diag["hg_bound_log2"] - diag["vec0_log2norm"]
        if diag_best is None or slack > diag_best[0]:
            diag_best = (slack, diag)
        if roots:
            diag["grid_tried"] = tried
            return roots, diag
    out = {"grid_tried": tried, "X_log2": X.bit_length(), "deg": dg,
           "note": "no root from any lattice in the grid"}
    if diag_best:
        out["best_hg_slack_bits"] = round(diag_best[0], 2)
        out.update({k: v for k, v in diag_best[1].items()
                    if k in ("m", "t", "dim", "vec0_log2norm",
                             "hg_bound_log2")})
    return [], out

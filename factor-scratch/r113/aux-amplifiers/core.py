"""Independent Coppersmith / Howgrave-Graham harness for known-high-bits attacks.

Written from scratch for r113 (does NOT import r110-r112 or r48 harnesses).
f(x) = x + a is MONIC of degree 1; we seek x0 with 0 <= x0 < X and (a+x0) | N.
Every recovered factor is re-verified by multiplying back to N.
"""
import random, time
from fpylll import IntegerMatrix, LLL
from sympy import isprime


# ---------------------------------------------------------------- instances
def _rand_prime(rng, bits):
    while True:
        c = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if isprime(c):
            return c


def make_instance(bits, seed):
    """bits = bit length of EACH factor.  Deterministic in (bits, seed)."""
    rng = random.Random(seed * 1000003 + bits)
    p = _rand_prime(rng, bits)
    q = _rand_prime(rng, bits)
    while q == p:
        q = _rand_prime(rng, bits)
    N = p * q
    assert p * q == N and isprime(p) and isprime(q)
    assert N.bit_length() in (2 * bits - 1, 2 * bits)
    return p, q, N


# ---------------------------------------------------------------- polynomials
# f(x) = x + a  =>  f(x)^k = sum_j C(k,j) a^(k-j) x^j
def fpow_lin(a, k):
    """coefficient list of (x+a)^k, index j = coeff of x^j."""
    return [__import__('math').comb(k, j) * pow(a, k - j) for j in range(k + 1)]


def polymul(u, v):
    out = [0] * (len(u) + len(v) - 1)
    for i, x in enumerate(u):
        if x:
            for j, y in enumerate(v):
                if y:
                    out[i + j] += x * y
    return out


def build_lattice(a, N, X, m, t):
    """Coppersmith (m,t) lattice for monic linear f=x+a over Z, unknown factor.

    rows: {x^j N^(m-k) f^k : k=0..m-1, j=0..t} U {x^j f^m : j=0..t}
    column i scaled by X^i.  Returns (IntegerMatrix, dim).
    """
    rows = []                      # each row is a coefficient list
    for k in range(m):
        fk = fpow_lin(a, k)
        nk = pow(N, m - k)
        for j in range(t + 1):
            r = polymul(fk, [0] * j + [1])
            r = [c * nk for c in r]
            rows.append(r)
    fm = fpow_lin(a, m)
    for j in range(t + 1):
        rows.append(polymul(fm, [0] * j + [1]))
    dim = len(rows)
    deg = max(len(r) for r in rows)
    # left-pad every row to `deg`, then scale column i by X^i
    A = IntegerMatrix(dim, deg)
    for r_i, r in enumerate(rows):
        for c_i, c in enumerate(r):
            A[r_i, c_i] = c * pow(X, c_i)
    return A, dim, deg


def _extract_int_roots(poly, lo, hi):
    """All integer roots of a poly with small degree and huge coefficients."""
    out = set()
    P = [int(c) for c in reversed(poly)]     # sympy wants high->low
    while P and P[0] == 0:
        P.pop(0)
    if not P or len(P) < 2:
        return out
    # sympy ground_roots via exact rational root theorem on the leading-desc form
    from sympy import Poly, Symbol, Rational
    x = Symbol('x')
    try:
        g = Poly(sum(Rational(P[i]) * x ** (len(P) - 1 - i)
                     for i in range(len(P))), x, domain=QQ_DOMAIN)
        for r in g.ground_roots():
            if r.is_Integer and lo <= int(r) <= hi:
                out.add(int(r))
    except Exception:
        # fallback: rational root theorem by hand on the deflated form
        g = _rat_roots(P, lo, hi)
        out |= g
    return out


QQ_DOMAIN = None
def _QQ():
    global QQ_DOMAIN
    if QQ_DOMAIN is None:
        from sympy import QQ
        QQ_DOMAIN = QQ
    return QQ_DOMAIN


def _rat_roots(P, lo, hi):
    out = set()
    # P is high->low.  Use sympy's factor over QQ on a scaled copy.
    from sympy import Poly, Symbol, QQ
    x = Symbol('x')
    try:
        g = Poly(sum(P[i] * x ** (len(P) - 1 - i) for i in range(len(P))),
                 x, domain=QQ)
        _, mult = g.factor_list()
        for fac, _e in mult:
            if fac.degree() == 1:
                r = -fac.all_coeffs()[1] / fac.all_coeffs()[0]
                if r.is_Integer and lo <= int(r) <= hi:
                    out.add(int(r))
    except Exception:
        pass
    return out


# ---------------------------------------------------------------- the attack
def attack(a, N, X, m=6, t=12, verbose=False):
    """Recover x0 < X with (a+x0) | N.  Returns list of verified roots."""
    A, dim, deg = build_lattice(a, N, X, m, t)
    t0 = time.time()
    LLL.reduction(A)
    dt = time.time() - t0
    Npow = pow(N, m)
    found = []
    tried = 0
    for i in range(dim):
        vec = [int(A[i, c]) for c in range(deg)]
        if max(abs(v) for v in vec) == 0:
            continue
        # unscaled coefficient list (divide column c by X^c)
        coef = [vec[c] // pow(X, c) for c in range(deg)]
        # Howgrave-Graham test on the scaled form
        if sum(abs(vec[c]) for c in range(deg)) >= Npow:
            continue
        tried += 1
        roots = _extract_int_roots(coef, -X, X)
        for r in roots:
            cand = a + r
            if cand > 1 and N % cand == 0 and 1 < cand < N:
                found.append(r)
        if verbose:
            print(f"   row {i} tried={tried} roots={sorted(roots)[:4]}")
        if found:
            break
    return found, dict(dim=dim, deg=deg, seconds=round(dt, 3),
                       rows_tried=tried, lll_time=dt)


def verify(N, cand_factors):
    """Ground truth check: multiply the reported factors back to N."""
    fs = [f for f in cand_factors if f > 1]
    if not fs:
        return False
    prod = 1
    for f in fs:
        prod *= f
    return prod == N


def verified_factor(N, cand):
    """A single candidate is a genuine factor iff cand * (N//cand) == N."""
    c = int(cand)
    if c <= 1 or c >= N:
        return False
    return c * (N // c) == N

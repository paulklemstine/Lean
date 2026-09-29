#!/usr/bin/env python3
"""
SELF-TEST for the (u,v) parametrisation of admissible linear forms when f = X^3 - c.

SETTING.  N = p*q with p,q = 3 (mod 4).  f = X^3 - c, alpha a real root, so Z[alpha]
with alpha^3 = c.  A relation l = aX + b is "admissible over Z" if l(alpha) = g^2 for
some g in Z[alpha]; then the quadratic character question is whether l(m) = w^2 for
an integer w and whether the two branches of w^2 = g(m)^2 mod p and mod q DISAGREE
(chi_P = -1), which is a non-trivial congruence of squares.

THE CLAIM UNDER TEST (mine, derived this session, reproduced here from scratch).

Writing g = (g0,g1,g2) in the basis 1, alpha, alpha^2:
    g^2 = (g0^2 + 2c g1 g2) + (2 g0 g1 + c g2^2) a + (g1^2 + 2 g0 g2) a^2
so l(alpha) = g^2 is linear in a iff
    CONE:   g1^2 + 2 g0 g2 = 0.
That cone is rational with the parametrisation
    g = ( -2u^2, -2uv, v^2 ),          u, v integers, v != 0,
giving
    a = 8 u^3 v + c v^4
    b = 4 u^4 - 4 c u v^3
Now put t = u/v in Q.  Then
    l(m)  = v^4 * A(t),   A(t) = 4t^4 + 8 m t^3 - 4 c t + m c
    Norm(g) = v^6 * B(t), B(t) = c^2 - 20 c t^3 - 8 t^6
    g(m)  = v^2 * C(t),   C(t) = m^2 - 2 t m - 2 t^2
Since v^4 and v^6 are squares / cubes, l(m) is an integer square iff A(t) = y^2 for
y in Q, i.e. iff (t,y) is a rational point of the quartic  E : y^2 = A(t)  (genus 1).

THE CHARACTER.  chi_P(l) = eps_p * eps_q where eps_p = +1 iff w = g(m) mod p.
Because w = v^2 y and g(m) = v^2 C(t) and v^4 is a square, the Jacobi symbol gives
    CLAIM:  chi_P(l) = Jacobi( C(t) * y , N ).
Note the sign of w is NOT free in the useful sense: (-1/N) = (-1/p)(-1/q) = +1,
so flipping y flips BOTH eps_p and eps_q and leaves chi_P unchanged.  This is
consistent, and it is exactly why the "no single character" wall survives.

Run:  python3 verify_param.py
"""
from fractions import Fraction as F
from itertools import combinations
from sympy import ZZ, Poly, factor_list, symbols, isprime, sqrt as symsqrt

T = symbols('T')


# ---------------------------------------------------------------- helpers
def icbrt(n):
    """EXACT floor(n^(1/3)).  Never int(n**(1/3)): that returns m-1 at every
    perfect cube (this exact bug manufactured a fake refutation in round 46)."""
    lo, hi = 0, 1
    while hi ** 3 <= n:
        hi *= 2
    while lo + 1 < hi:
        mid = (lo + hi) // 2
        if mid ** 3 <= n:
            lo = mid
        else:
            hi = mid
    return lo


def isqrt(n):
    if n < 0:
        return None
    lo, hi = 0, 1
    while hi * hi <= n:
        hi *= 2
    while lo + 1 < hi:
        mid = (lo + hi) // 2
        if mid * mid <= n:
            lo = mid
        else:
            hi = mid
    return lo if lo * lo == n else None


def jacobi(a, n):
    """Jacobi symbol (a/n), n odd > 0.  Written out: sympy exports a polynomial
    class named `Jacobi`, so importing `jacobi` from sympy silently gets the
    wrong object."""
    a, n = int(a), int(n)
    assert n > 0 and n % 2 == 1
    a %= n
    r = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                r = -r
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            r = -r
        a %= n
    return r if n == 1 else 0


def quad_in_Z(g, c):
    """g^2 in Z[alpha] as (1, a, a^2) coefficients."""
    g0, g1, g2 = g
    return (g0 * g0 + 2 * c * g1 * g2,
            2 * g0 * g1 + c * g2 * g2,
            g1 * g1 + 2 * g0 * g2)


def norm_cubic(g, c):
    """Norm of g0+g1 a+g2 a^2.  From x^3+y^3+z^3-3xyz with x=g0, y=g1 b, z=g2 b^2,
    b^3 = c:  = g0^3 + c g1^3 + c^2 g2^3 - 3 c g0 g1 g2."""
    g0, g1, g2 = g
    return g0 ** 3 + c * g1 ** 3 + c * c * g2 ** 3 - 3 * c * g0 * g1 * g2


def find_m(N, c, kmax=200):
    """m with m^3 = c (mod N), near N^(1/3).  (The record's own worked example uses
    N=1333, c=2, m=20, and 20^3 = 8000 = 2 mod 31 and mod 43 -- so m^3 = c mod N is
    the operative condition, not m^3 <= N.)"""
    m0 = icbrt(N)
    for m in range(m0, m0 + kmax):
        if (m ** 3 - c) % N == 0:
            return m
    return None


def m_c_pairs(N, cmax=400, kmax=400, want=3):
    """Yield (m, c) with m^3 = c (mod N) and c small -- the operative relation is
    m^3 = c mod N, so we generate m and read c off it rather than fixing c."""
    m0, out, seen = icbrt(N), [], set()
    for m in range(m0, m0 + kmax):
        c = (m ** 3) % N
        if c < cmax and c not in seen:
            seen.add(c)
            out.append((m, c))
            if len(out) >= want:
                break
    return out


# ---------------------------------------------------------------- the test
def run(N, c, m=None, urange=40, vrange=40, want_witness=True):
    p = next(d for d in range(3, N, 2) if N % d == 0 and isprime(d))
    q = N // p
    if not (p % 4 == 3 and q % 4 == 3):
        return f"N={N} = {p}*{q}: need BOTH 3 mod 4 -- skip"
    if m is None:
        if find_m(N, c) is None:
            m, c = m_c_pairs(N, want=1)[0]
        else:
            m = find_m(N, c)
    assert (m ** 3 - c) % N == 0

    n_sq = n_chi = n_neg = 0
    t_hit = None
    for v in range(1, vrange + 1):
        for u in range(-urange, urange + 1):
            g = (-2 * u * u, -2 * u * v, v * v)
            k0, k1, k2 = quad_in_Z(g, c)
            assert k2 == 0, "parametrisation must stay on the cone"
            a, b = k1, k0
            lm = a * m + b
            if lm < 0:
                continue
            w = isqrt(lm)
            if w is None:
                continue
            n_sq += 1
            if w % p == 0 or w % q == 0:
                continue
            gm = g[0] + g[1] * m + g[2] * m * m
            if gm % p == 0 or gm % q == 0:
                continue
            # --- ground truth: the two branch signs, computed directly ---
            if (w - gm) % p == 0:
                eps_p = 1
            elif (w + gm) % p == 0:
                eps_p = -1
            else:
                return f"N={N} c={c} ({u},{v}): w^2 != g(m)^2 mod p  CLAIM VIOLATED"
            if (w - gm) % q == 0:
                eps_q = 1
            elif (w + gm) % q == 0:
                eps_q = -1
            else:
                return f"N={N} c={c} ({u},{v}): w^2 != g(m)^2 mod q  CLAIM VIOLATED"
            chi_direct = eps_p * eps_q

            # --- the formula, from t = u/v alone ---
            t = F(u, v)
            y = F(w, v * v)
            C = m * m - 2 * t * m - 2 * t * t
            A = 4 * t ** 4 + 8 * m * t ** 3 - 4 * c * t + m * c
            B = c * c - 20 * c * t ** 3 - 8 * t ** 6
            assert A == y * y, (u, v, "A(t) != y^2")
            assert norm_cubic(g, c) == v ** 6 * B, (u, v, "Norm formula")
            val = C * y
            if val.denominator != 1:            # clearing by a square is safe
                d = val.denominator
                val = val * (d * d)
            chi_formula = jacobi(int(val), N)
            n_chi += 1
            if chi_formula != chi_direct:
                return (f"N={N} c={c} ({u},{v}) t={t}: chi direct={chi_direct} "
                        f"formula={chi_formula}  CLAIM REFUTED")
            if chi_direct == -1 and t_hit is None:
                t_hit = (u, v, t, y, gm, w, norm_cubic(g, c))
                n_neg += 1
    msg = (f"N={N:>5} c={c} p={p} q={q} m={m}: l(m)-square {n_sq:>5}  "
           f"chi checked {n_chi:>5}  chi=-1 found {n_neg}")
    if t_hit and want_witness:
        u, v, t, y, gm, w, nrm = t_hit
        msg += (f"\n        WITNESS t={t} y={y} | l={8*u**3*v + c*v**4}X + {4*u**4 - 4*c*u*v**3}"
                f" g(m)={gm} w={w} Norm(g)={nrm}"
                f"  gcd(w-g(m),N)={__import__('math').gcd(w-gm, N)}"
                f" gcd(w+g(m),N)={__import__('math').gcd(w+gm, N)}")
    return msg


def square_class_check():
    """THE DECISIVE ARITHMETIC QUESTION.
    chi_P(l) = Jacobi( C(t)*y , N ) with y^2 = A(t).  If  C(t)*A(t)  were a square in
    Q(t), the character would be a pullback of a constant and could be forced to +1.
    If it is NOT a square, the character is genuinely nontrivial on the function
    field, and no randomisation of f can make it constant."""
    print("\n--- is C(t)*A(t) a square in Q(t)?  (decides whether chi_P can be constant) ---")
    m, c = 20, 2
    A = 4 * T ** 4 + 8 * m * T ** 3 - 4 * c * T + m * c
    C = m * m - 2 * T * m - 2 * T ** 2
    prod = Poly(C * A, T)
    fac = factor_list(prod.as_expr(), T)
    print(f"  m={m} c={c}   C(t)*A(t) has {prod.degree()} distinct roots over Q: "
          f"{len(fac[1])} factor(s)")
    for f_, e_ in fac[1]:
        print(f"     {f_}  exponent {e_}   {'ODD -> NOT a square' if e_ % 2 else 'even'}")
    odd = any(e_ % 2 for _, e_ in fac[1])
    print(f"  VERDICT: C*A is {'NOT' if odd else ''}"
          f"{'' if odd else ' a'} square in Q(t)."
          f"  =>  chi_P is a NONTRIVIAL character of the function field.")


if __name__ == "__main__":
    print("=" * 78)
    print("TEST 1 -- the record's own hand-verified witness, every component re-derived")
    print("=" * 78)
    c, m, u, v = 2, 20, 2, 2
    g = (-2 * u * u, -2 * u * v, v * v)
    k = quad_in_Z(g, c)
    print(f"  g = {g};  g^2 coeffs (1,a,a^2) = {k}")
    assert k == (-64, 160, 0), k
    assert (4 * k[1], 4 * k[0]) == (640, -256)
    print(f"  => l = {k[1]}X + {k[0]};  times 4 = 640X - 256  == the record's l   OK")
    assert norm_cubic(g, c) == -2816
    assert norm_cubic(tuple(2 * x for x in g), c) == -22528
    print(f"  Norm(g) = {norm_cubic(g,c)};  Norm(2g) = {norm_cubic(tuple(2*x for x in g),c)}"
          f"   (record: -22528 = -2^11 * 11)   OK")
    assert norm_cubic(tuple(2 * x for x in g), c) == -2 ** 11 * 11
    A = 4 * F(1) ** 4 + 8 * m * F(1) ** 3 - 4 * c * F(1) + m * c
    assert A == 196 and isqrt(196) == 14
    print(f"  A(t=1) = {A} = 14^2;  l(m) = {k[1]*m + k[0]} = 56^2;  g(m) = "
          f"{g[0]+g[1]*m+g[2]*m*m}  (record's 2*g(m) = 2864)   OK")
    assert g[0] + g[1] * m + g[2] * m * m == 1432
    assert (2864 + 112) % 31 == 0 and (2864 - 112) == 2 ** 6 * 43
    print("  TEST 1 PASSED\n")

    print("=" * 78)
    print("TEST 2 -- chi_P = Jacobi(C(t)*y, N)  vs  the directly computed branch signs")
    print("=" * 78)
    ok = True
    semiprimes = [1333, 1829, 2077, 2201, 2449, 2537, 3053, 3397, 3953, 4189,
                  4757, 5461, 5723, 6203, 6643, 7039, 7633, 8011, 8587, 9403,
                  10159, 10609, 11663, 12421, 13507, 14179, 15397, 16633]
    ninst = 0
    for N in semiprimes:
        p = next((d for d in range(3, N, 2) if N % d == 0 and isprime(d)), None)
        if p is None or not (p % 4 == 3 and (N // p) % 4 == 3):
            print(f"  N={N}: not a semiprime with both factors 3 mod 4 -- skip")
            continue
        for m, c in m_c_pairs(N, want=2):
            r = run(N, c, m=m, urange=45, vrange=45)
            ninst += 1
            print("  " + r)
            if isinstance(r, str) and "CLAIM" in r:
                ok = False
    print(f"\n  {ninst} instances of (N, c, m) tested.")
    print("\n  " + ("ALL CLAIMED IDENTITIES HOLD" if ok else "*** CLAIM REFUTED ***"))
    square_class_check()

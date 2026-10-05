#!/usr/bin/env python3
"""
VERIFY the GIFP threshold gamma > 4*alpha*(1-sqrt(alpha)) end-to-end.

Faithful re-implementation of Feng-Nitaj-Pan arXiv:2304.08718v3, following the
authors' reference code (github.com/fffmath/gifp: gifp.sage, create_lattice,
reconstruct_polynomials, find_roots_groebner). We use fpylll for LLL (exact
integer) and sympy for the Groebner step, which is where the rational roots (and
hence p2) actually come from.

THE PIPELINE (from the authors' code, corrected):
  1. shifts g = (yz)^j w^s f^i M^(m-i) N1^max(t-i,0) (N2^-1)^min(i+j,s),
     taken in R/(zw - N2) via qr(g).lift(), reduced mod modular = M^m N1^t.
  2. lattice L[row, col] = coeff(monomial) * monomial(X,Y,Z)   [create_lattice]
  3. LLL (integer; the authors use Sage dense LLL over QQ, equivalent here since
     all entries are integers). reconstruct: poly = L[row,col]*monomial //
     monomial(bounds)  -> INTEGER coefficients; drop rows with
     norm^2 * w >= modular^2; divide out f; drop constants.
  4. insert (z*w - N2); Groebner basis over QQ (lex). If GB length == nvars,
     extract univariate factors and their rational roots -> (x0,y0,z0,w0) with
     w0 = p2, z0 = q2.
  5. p1 = gcd(N1, p2 + x0 + y0 * 2^(gamma*n + b2)).
"""
import math, random, sys
import sympy
from sympy import Poly, ZZ, QQ, groebner, gcd as spgcd
from fpylll import IntegerMatrix, LLL

x, y, z, w = sympy.symbols('x y z w')

def is_prime(n):
    if n < 2: return False
    for p in [2,3,5,7,11,13,17,19,23,29,31,37]:
        if n % p == 0: return n == p
    dd = n-1; r = 0
    while dd % 2 == 0: dd //= 2; r += 1
    for a in [2,3,5,7,11,13,17,19,23,29,31,37]:
        v = pow(a, dd, n)
        if v in (1, n-1): continue
        for _ in range(r-1):
            v = v*v % n
            if v == n-1: break
        else: return False
    return True
def gp(b):
    while True:
        p = random.getrandbits(b) | (1 << (b-1)) | 1
        if is_prime(p): return p

def to_quotient_lift(g, N2):
    P = Poly(g, x, y, z, w, domain=ZZ)
    maxmw = max((mo[3] for mo in P.monoms()), default=0)
    acc = 0
    for (mx,my,mz,mw), c in P.terms():
        acc += int(c) * (N2**mw) * x**mx * y**my * z**(mz-mw)
    return sympy.expand(acc * (z**maxmw))

def eliminate_N2(poly, modular):
    P = Poly(poly, x, y, z, w, domain=ZZ)
    out = 0
    for (mx,my,mz,mw), c in P.terms():
        out += (int(c) % modular) * x**mx * y**my * z**mz * w**mw
    return sympy.expand(out)

def gifp_factor(N1, N2, n, alpha, gamma, b1, b2, m):
    g_bits = int(gamma*n)
    f = x*z + (2**(b2+g_bits))*y*z + N2
    X = 2**int(b2)
    Y = 2**int(n - alpha*n - g_bits - b1)
    Z = 2**int(alpha*n)
    M = 2**int(b2-b1)
    t = int(round((1-math.sqrt(alpha))*m))
    s = int(round(math.sqrt(alpha)*m))
    modular = (M**m) * (N1**t)
    N2_inv = pow(N2, -1, modular)
    shifts = []
    for i in range(m+1):
        for j in range(m-i+1):
            g = (y*z)**j * (w**s) * (f**i) * (M**(m-i)) * (N1**max(t-i,0)) * (N2_inv**min(i+j, s))
            g = eliminate_N2(to_quotient_lift(g, N2), modular)
            shifts.append(Poly(g, x, y, z, domain=ZZ))
    allm = set()
    for P in shifts: allm |= set(P.monoms())
    allm = sorted(allm)
    bounds = {(a,b,c): (X**a)*(Y**b)*(Z**c) for (a,b,c) in allm}
    B = IntegerMatrix(len(shifts), len(allm))
    for r, P in enumerate(shifts):
        for (a,b,c), coef in zip(P.monoms(), P.coeffs()):
            B[r, allm.index((a,b,c))] = int(coef) * bounds[(a,b,c)]
    LLL.reduction(B)
    polys = []
    for r in range(B.nrows):
        expr = 0; norm2 = 0; ww = 0
        for (a,b,c), fct in zip(allm, [bounds[mo] for mo in allm]):
            v = int(B[r, allm.index((a,b,c))])
            if v == 0: continue
            norm2 += v*v; ww += 1
            expr += (v // fct) * x**a * y**b * z**c
        if ww == 0 or norm2 * ww >= modular**2:
            continue
        P = Poly(expr, x, y, z, domain=ZZ)
        if P.as_expr() != 0:
            polys.append(P.as_expr())
    if not polys:
        return None, "no polys"
    gens = list(polys) + [z*w - N2]
    G = groebner(gens, x, y, z, w, order='lex')
    roots = {}
    for gi in G:
        if len(gi.free_symbols) == 1:
            v = list(gi.free_symbols)[0]
            up = sympy.Poly(gi.as_expr(), v, domain=QQ)
            for r, mult in up.roots():
                roots[v] = sympy.Rational(r)
    p2 = roots.get(w)
    if p2 is None or not p2.is_Integer:
        return None, "no integer p2 from GB roots"
    p2 = int(p2)
    if p2 <= 1 or p2 >= N2 or N2 % p2 != 0:
        return None, "p2 not a factor of N2"
    return p2, "ok"

def main():
    random.seed(1)
    n = 300; alpha = 0.1; m = 4
    thr = 4*alpha*(1-math.sqrt(alpha))
    print(f"GIFP end-to-end verification (integer LLL + Groebner over QQ)")
    print(f"n={n} alpha={alpha} m={m}; predicted threshold gamma={thr:.4f}\n")
    print(" alpha | gamma | predicted | recovered? | note")
    for gamma in [0.20, 0.30, 0.40, 0.50, 0.60]:
        alpha_bits = int(alpha*n); p_bits = n - alpha_bits; g_bits = int(gamma*n)
        while True:
            p1 = gp(p_bits); base = p1 & ((1 << g_bits) - 1)
            hi2 = random.randrange(1 << max(1, p_bits-g_bits-1), 1 << max(1, p_bits-g_bits))
            p2 = base | (hi2 << g_bits)
            if is_prime(p2) and p2 != p1: break
        q1 = gp(alpha_bits); q2 = gp(alpha_bits)
        N1 = p1*q1; N2 = p2*q2
        try:
            p2f, note = gifp_factor(N1, N2, n, alpha, gamma, 0, 0, m)
        except Exception as e:
            p2f, note = None, f"exc:{type(e).__name__}:{e}"
        rec = (p2f == p2)
        pred = gamma > thr
        print(f"  {alpha} | {gamma:.3f} | {'YES' if pred else 'no ':3s} | {str(rec):5s} | {note}")

if __name__ == "__main__":
    main()
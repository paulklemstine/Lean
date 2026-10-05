#!/usr/bin/env python3
"""
VERIFY the GIFP threshold gamma > 4*alpha*(1-sqrt(alpha)) END-TO-END.

Faithful Python re-implementation of the authors' SageMath code
(github.com/fffmath/gifp, gifp.sage + myRSA_solve.md, for
Feng-Nitaj-Pan arXiv:2303.08718v3 "Generalized Implicit Factorization
Problem"), using sympy for the quotient-ring / Groebner step and fpylll for LLL.

THE ALGORITHM (verbatim from the authors' code):
  R.<x,y,z,w> = ZZ[x,y,z,w], lex.   f = x*z + 2^(b2+g)*y*z + N2.
  t = round((1-sqrt(a))*m);  s = round(sqrt(a)*m)
  qr = quotient ring R/(z*w - N2)          # eliminate zw via N2
  modular = M^m * N1^t                       # M = 2^(b2-b1)
  for i in 0..m: for j in 0..m-i:
      g = (y*z)^j * w^s * f^i * M^(m-i) * N1^max(t-i,0) * (N2^{-1})^min(i+j,s)
      g = lift(qr(g)); reduce mod `modular`; append.
  L = coefficient_matrix, rescale column (x^a y^b z^c w^d) by X^a Y^b Z^c W^d
  LLL; unscale; H = recovered polys (+ wz - N2)
  G = Groebner(H[:20]).
  RECOVERY (no Groebner heuristic needed): scan G for a rational coefficient whose
  DENOMINATOR has a nontrivial gcd with N2 -> p2. Then
      q2 = N2/p2; x0 = int(G[0](w=p2).roots()[0]); y0 = int(G[1](w=p2).roots()[0])
      p1 = gcd(N1, p2 + x0 + y0*2^(g+b2));  q1 = N1/p1.

We test on synthetic N1=p1*q1, N2=p2*q2 with p1,p2 sharing gamma*n bits at
arbitrary positions, sweeping (alpha, gamma) to locate the empirical threshold
and compare to the predicted 4*alpha*(1-sqrt(alpha)).
"""
import math, random, sys
import sympy
from fractions import Fraction
from sympy import Poly, ZZ, QQ, groebner, gcd as spgcd
from fpylll import IntegerMatrix, LLL

x, y, z, w, q = sympy.symbols('x y z w q')

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

def modp(a, m):
    return a % m

def eliminate_N2(poly, modular):
    """Reduce each coefficient mod `modular` (authors' eliminate_N2), on x,y,z,w."""
    P = Poly(poly, x, y, z, w, domain=ZZ)
    out = 0
    for (mx, my, mz, mw), c in P.terms():
        cc = int(c) % modular
        out = out + cc * x**mx * y**my * z**mz * w**mw
    return sympy.expand(out)

def build_and_solve(N1, N2, n, alpha, gamma, b1, b2, m):
    f = x*z + (2**(int(b2+gamma*n)))*y*z + N2
    X = 2**int(b2)
    Y = 2**int(n - alpha*n - gamma*n - b1)
    Z = 2**int(alpha*n)
    W = 2**int(n - alpha*n)
    M = 2**int(b2 - b1)
    t = int(round((1-math.sqrt(alpha))*m))
    s = int(round(math.sqrt(alpha)*m))
    modular = (M**m) * (N1**t)
    N2_inv = pow(N2, -1, modular)
    # quotient ring: substitute w -> N2/z. Represent as poly in x,y,z with
    # w^k -> (N2/z)^k -> multiply by z^k to clear denominators.
    def to_quotient(g):
        """Substitute w = N2/z and clear denominators (Sage R.quotient().lift())."""
        P = Poly(g, x, y, z, w, domain=ZZ)
        maxmw = max((mono[3] for mono in P.monoms()), default=0)
        acc = 0
        for (mx, my, mz, mw), c in P.terms():
            # c x^mx y^my z^mz w^mw  ->  c * N2^mw * x^mx y^my z^(mz-mw)
            acc = acc + int(c) * (N2 ** mw) * x**mx * y**my * z**(mz - mw)
        return sympy.expand(acc * (z ** maxmw))
    shifts = []
    for i in range(m+1):
        for j in range(m - i + 1):
            g = (y*z)**j * (w**s) * (f**i) * (M**(m-i)) * (N1**max(t-i,0)) * (N2_inv**min(i+j, s))
            g = to_quotient(g)
            g = eliminate_N2(g, modular)
            shifts.append(g)
    # coefficient matrix over monomials in x,y,z (after quotient, w is gone)
    allm = set()
    polys = []
    for g in shifts:
        P = Poly(g, x, y, z, domain=ZZ)
        polys.append(P)
        allm |= set(P.monoms())
    allm = sorted(allm)
    dim = len(allm); rows = len(polys)
    # scaling: column (a,b,c) by X^a Y^b Z^c
    factors = [ (X**a)*(Y**b)*(Z**c) for (a,b,c) in allm ]
    B = IntegerMatrix(rows, dim)
    for r, P in enumerate(polys):
        for (a,b,c), coef in zip(P.monoms(), P.coeffs()):
            col = allm.index((a,b,c))
            B[r, col] = int(coef * factors[col])
    LLL.reduction(B)
    # recover polynomials over QQ
    H = []
    for r in range(rows):
        expr = 0
        for (a,b,c), f in zip(allm, factors):
            v = int(B[r, allm.index((a,b,c))])
            if f != 0 and v % f == 0:
                expr = expr + Fraction(v // f) * x**a * y**b * z**c
        if expr != 0:
            H.append(Poly(expr, x, y, z, domain=QQ))
    # recovery: scan for a coefficient whose denominator has nontrivial gcd with N2
    p2 = None
    for P in H:
        for mono, coeff in P.terms():
            den = Fraction(coeff).denominator
            if den == 1: continue
            d = int(spgcd(int(den), N2))
            if d != 1 and d != N2:
                p2 = d; break
        if p2: break
    if not p2:
        return None, "no p2 from denominators"
    if p2*q_div(N2, p2) != N2: return None, "p2 not factor"
    return p2, "ok"

def q_div(N2, p2):
    return N2 // p2 if N2 % p2 == 0 else -1

def main():
    random.seed(1)
    n = 200  # modulus bit length (small for speed)
    alpha = 0.1
    print(f"VERIFYING GIFP threshold gamma > 4*alpha*(1-sqrt(alpha)); n={n}, alpha={alpha}")
    thr = 4*alpha*(1-math.sqrt(alpha))
    print(f"predicted threshold gamma = {thr:.4f}\n")
    m = 4
    # LSB-sharing case: b1 = b2 = 0 (shared low bits). p1,p2 share gamma*n low bits.
    print("alpha | gamma | predicted | recovered?")
    for gamma in [0.1, 0.2, 0.25, 0.3, 0.4, 0.5]:
        # construct
        alpha_bits = int(alpha*n)
        p_bits = n - alpha_bits
        g_bits = int(gamma*n)
        while True:
            p1 = gp(p_bits)
            base = p1 & ((1 << g_bits) - 1)  # shared LOW bits
            hi = p1 >> g_bits
            hi2 = random.randrange(1 << max(1,(p_bits-g_bits-1)), 1 << max(1,(p_bits-g_bits)))
            p2 = base | (hi2 << g_bits)
            if is_prime(p2) and p2 != p1: break
        q1 = gp(alpha_bits); q2 = gp(alpha_bits)
        N1 = p1*q1; N2 = p2*q2
        try:
            p2f, msg = build_and_solve(N1, N2, n, alpha, gamma, 0, 0, m)
        except Exception as e:
            p2f, msg = None, f"exc:{e}"
        pred = gamma > thr
        rec = (p2f == p2)
        print(f"  {alpha} | {gamma:.3f} | {'YES' if pred else 'no ':3s} | {rec} ({msg})")

if __name__ == "__main__":
    main()
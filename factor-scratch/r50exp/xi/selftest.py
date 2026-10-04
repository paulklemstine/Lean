#!/usr/bin/env python3
"""
SELF-TEST for the xi(N) task.  WRITTEN FIRST, BEFORE ANY CLAIM.

THE QUANTITIES CLAIMED, IN ORDER OF LOAD-BEARING

 (Q1, primary)  xi(N) FROM THEOREM 17 of arXiv:2007.02730v2 (p.2, verified
     against the rendered page image, NOT pdftotext):
         xi(N) = 4 logloglog N / (3 loglog N)
                 + ( -2 log 2 + log 3/6 - 2 ) / loglog N   * (1 + o(1))
     Pure closed-form arithmetic.  Fully testable: the identity
         xi(N) ~ 4 logloglog N/(3 loglog N)
     is checkable for internal consistency (the two-term value must differ
     from the leading term by O(1/loglog N)), and the SIGN is checkable.

 (Q2, secondary)  THE DICKMAN REMAINDER
         R = ln( Psi(x,y) / (x rho(u)) ),  u = ln x / ln y.
     Measured ONLY at u <= 4, where rho is validated below.  Beyond that it
     is NOT DETERMINABLE on this host: exact Psi needs y ~ 10^18 at NFS scale
     and enumeration needs x*rho(u) < 10^8.  Stated as a limit, not a number.

 ⚠️ TWO METHODS TRIED AND REJECTED, recorded because both are traps:

 1. The recursion  Psi(x,y) = Psi(x,y-1) + Psi(x/y,y)  is FALSE unless y is
    prime.  Counterexample (x=10, y=4): 4-smooth and 3-smooth sets below 10
    are identical, so the LHS difference is 0, while Psi(2.5,4) = 2.
    The correct all-y identity is  Psi(x,y) = 1 + sum_{p<=y} Psi(x/p, p),
    each y-smooth integer counted once by its largest prime factor.

 2. Enumerating y-smooth integers to get Psi fails in the NFS regime: with
    u = ln x/ln y ~ 42, Psi(x,y) ~ x*rho(u) is astronomically large
    (~10^40+), so enumeration cannot terminate.

DESIGN RULE: decide() is two-sided against a tolerance band and MUST be able
to return NULL.  Every test prints the RAW number beside its verdict.
"""
import math, sys
import numpy as np

LN2 = math.log(2.0)

# --------------------------------------------------------------- Dickman rho
def dickman(U, h=2e-5):
    """rho(u)=1 on [0,1];  rho(u) = 1 - int_0^{u-1} rho(t)/(t+1) dt.
    Trapezoid on a grid of step h; the delay u-1 lands on the grid."""
    inv = int(round(1.0 / h))
    J = int(math.ceil(U * inv)) + 2
    u = [i * h for i in range(J + 1)]
    R = [1.0] * (J + 1)
    D = [0.0] * (J + 1)
    for k in range(1, J + 1):
        R[k] = max(0.0, 1.0 - D[k - inv]) if k - inv >= 0 else 1.0
        D[k] = D[k - 1] + 0.5 * h * (R[k - 1] / (u[k - 1] + 1.0)
                                      + R[k] / (u[k] + 1.0))
    def f(q):
        if q <= 1: return 1.0
        j = int(q / h)
        if j >= J: return R[J]
        w = q / h - j
        return R[j] + w * (R[j + 1] - R[j])
    return f

_RHO = None
def rho(q):
    global _RHO
    if _RHO is None or _RHO[1] < q:
        _RHO = (dickman(max(q + 1.0, 20.0)), q + 1.0)
    return _RHO[0](q)

# ---------------------------------------------------- exact Psi (brute force)
def psi_sieve(x, y):
    s = bytearray([1]) * (x + 1); s[0] = s[1] = 0
    i = 2
    while i * i <= x:
        if s[i]: s[i * i::i] = bytearray(len(s[i * i::i]))
        i += 1
    lpf = [1] * (x + 1)
    for p in range(2, x + 1):
        if s[p]:
            for m in range(p, x + 1, p): lpf[m] = p
    return sum(1 for m in range(1, x + 1) if lpf[m] <= y)

def psi_smoothgen(x, y):
    """INDEPENDENT implementation: build the y-smooth set by repeated
    multiplication by each prime <= y.  No largest-prime-factor array."""
    s = bytearray([1]) * (x + 1); s[0] = s[1] = 0
    i = 2
    while i * i <= x:
        if s[i]: s[i * i::i] = bytearray(len(s[i * i::i]))
        i += 1
    vals = {1}
    for p in range(2, x + 1):
        if s[p] and p <= y:
            new = set()
            for v in vals:
                w = v
                while w <= x:
                    new.add(w); w *= p
            vals |= new
    return len(vals)

# --------------------------------------------------- Theorem 17 as a function
def xi_leading(bits):
    """4 logloglog N / (3 loglog N), N = 2^bits."""
    l1 = bits * LN2; l2 = math.log(l1); l3 = math.log(l2)
    return 4.0 * l3 / (3.0 * l2)

def xi_twoterm(bits):
    """Theorem 17 full two-term statement."""
    l1 = bits * LN2; l2 = math.log(l1); l3 = math.log(l2)
    return 4.0 * l3 / (3.0 * l2) + (-2.0 * LN2 + math.log(3.0) / 6.0 - 2.0) / l2

def exponent_scale(bits):
    """S = (ln N)^{1/3} (lnln N)^{2/3}; the o(1)-free exponent scale."""
    l1 = bits * LN2; l2 = math.log(l1)
    return l1 ** (1 / 3) * l2 ** (2 / 3)

C_NFS = (64.0 / 9.0) ** (1.0 / 3.0)
def cost_bits(bits, xi=0.0):
    """Formula (1), p.1: exp( c (lnN)^{1/3}(lnlnN)^{2/3} (1+xi) ), in log2."""
    return C_NFS * exponent_scale(bits) * (1.0 + xi) / LN2

# ------------------------------------------------------------------ verdict
def decide(R, tol):
    if R is None or not math.isfinite(R):
        return "NULL (undefined)"
    if abs(R) <= tol:
        return f"NULL / no remainder (|R|={abs(R):.2e} <= tol={tol:.1e})"
    return f"REMAINDER R={R:+.4e} = {R / LN2:+.3f} bits"

# ===========================================================================
if __name__ == "__main__":
    ok = True
    print("=" * 78)
    print("T1  Dickman rho vs CLOSED FORM (only u<=4 is claimed usable)")
    for u, ex, tolr in [(1.0, 1.0, 1e-12), (2.0, 1 - math.log(2), 1e-9),
                        (3.0, 0.0486083882915, 1e-8), (4.0, 0.0049109256474, 1e-6)]:
        g = rho(u); rel = abs(g - ex) / ex
        good = rel < tolr; ok &= good
        print(f"  {'OK ' if good else 'FAIL'} rho({u}) exact={ex:.10e} "
              f"got={g:.10e} relerr={rel:.2e}")
    print("  NOTE: rho(u>4) is NOT validated here and is NOT used in any claim.")

    print()
    print("=" * 78)
    print("T2  Psi: two INDEPENDENT implementations must agree")
    for x, y in [(10 ** 4, 10), (10 ** 4, 100), (10 ** 5, 50),
                 (2 * 10 ** 6, 7), (2 * 10 ** 6, 1000)]:
        a = psi_sieve(x, y); b = psi_smoothgen(x, y)
        good = a == b; ok &= good
        print(f"  {'OK ' if good else 'FAIL'} x={x:<10d} y={y:<7d} "
              f"lpf-sieve={a:<9d} smoothgen={b}")
    for x in (1000, 10 ** 5, 10 ** 6):
        g = psi_sieve(x, x) == x; ok &= g
        print(f"  {'OK ' if g else 'FAIL'} Psi({x},{x}) == x (must hold)")

    print()
    print("=" * 78)
    print("T3  Theorem 17 INTERNAL CONSISTENCY (Q1, primary)")
    print("     xi_2term - xi_lead must be exactly (c1)/loglogN, c1=-2ln2+ln3/6-2")
    c1 = -2.0 * LN2 + math.log(3.0) / 6.0 - 2.0
    print(f"     c1 = {c1:.8f}")
    for b in (512, 1024, 2048, 4096):
        l2 = math.log(b * LN2)
        diff = xi_twoterm(b) - xi_leading(b)
        want = c1 / l2
        good = abs(diff - want) < 1e-12; ok &= good
        print(f"  {'OK ' if good else 'FAIL'} N=2^{b:<5d} diff={diff:+.8f} "
              f"expected c1/loglogN={want:+.8f}")
    print()
    print("     sign check (the sign is the load-bearing claim):")
    for b in (512, 1024, 2048, 4096, 8192):
        print(f"       2^{b:<5d}  xi_lead={xi_leading(b):+.4f} "
              f"xi_2term={xi_twoterm(b):+.4f}  "
              f"cost shift: lead {xi_leading(b)*exponent_scale(b)/LN2:+.2f} bits, "
              f"2term {xi_twoterm(b)*exponent_scale(b)/LN2:+.2f} bits")

    print()
    print("=" * 78)
    print("T4  REPRODUCE the inherited 2^45 from the TOY functions g,g0 (p.2)")
    b = 2048
    S = exponent_scale(b); l2 = math.log(b * LN2)
    g0b = S / LN2
    gb = (S / (1.0 + 20.0 / l2)) / LN2
    print(f"     g0(2^2048) = 2^{g0b:.4f}   paper says ~2^61   "
          f"{'MATCH' if abs(g0b-61)<1 else 'MISMATCH'}")
    print(f"     g (2^2048) = 2^{gb:.4f}   paper says ~2^16   "
          f"{'MATCH' if abs(gb-16)<1 else 'MISMATCH'}")
    print(f"     ratio g0/g = 2^{g0b-gb:.4f}   <-- origin of the inherited '2^45'")
    print("     These are ILLUSTRATIVE functions (the 20 is chosen by hand),")
    print("     NOT xi(N).  The paper says only 'a behavior SIMILAR TO' g.")

    print()
    print("=" * 78)
    print("T5  (Q2) Dickman remainder at REACHABLE u only")
    tol = 5e-3
    print(f"  {'x':>12} {'y':>8} {'u':>7} {'Psi':>12} {'x*rho(u)':>12} "
          f"{'R':>11}  verdict")
    for x, y in [(10 ** 6, 10 ** 3), (10 ** 6, 10 ** 4), (10 ** 7, 10 ** 4),
                 (10 ** 7, 10 ** 5), (10 ** 8, 10 ** 5), (10 ** 8, 10 ** 6),
                 (10 ** 9, 10 ** 6)]:
        u = math.log(x) / math.log(y)
        if u > 4.0:
            print(f"  {x:>12d} {y:>8d} {u:>7.3f} {'--':>12} {'--':>12} "
                  f"{'--':>11}  SKIPPED (u>4: rho not validated here)")
            continue
        P = psi_sieve(x, y)
        model = x * rho(u)
        R = math.log(P / model)
        print(f"  {x:>12d} {y:>8d} {u:>7.3f} {P:>12d} {model:>12.4e} "
              f"{R:>11.4f}  {decide(R, tol)}")
    print()
    print("  NFS-scale u (ln x / ln B at 2048 bits) is ~42.  The rows above")
    print("  reach u ~ 3.  The extrapolation gap is 14x in u; the value of")
    print("  R there is NOT DETERMINABLE on this host.")

    print()
    print("=" * 78)
    print("T6  NULL-CAPABILITY / NEGATIVE CONTROL")
    Rf = math.log((rho(3.0) * 1.05) / rho(3.0))
    if "NULL" in decide(Rf, tol): ok = False; print("  FAIL insensitive")
    else: print(f"  OK  5% corruption detected  R={Rf:+.4e}")
    Rf2 = math.log((rho(3.0) * 1.0002) / rho(3.0))
    if "NULL" not in decide(Rf2, tol): ok = False; print("  FAIL null not returned")
    else: print(f"  OK  null correctly returned   R={Rf2:+.4e}")

    print()
    print("=" * 78)
    print("SELF-TEST", "PASSED" if ok else "FAILED")
    sys.exit(0 if ok else 1)

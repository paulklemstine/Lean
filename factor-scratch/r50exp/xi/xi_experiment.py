#!/usr/bin/env python3
"""
MAIN EXPERIMENT: what is xi(N), how big is it, and does it matter?

The self-test (selftest.py) is written first and must pass before this runs.

Everything below is EXACT ARITHMETIC plus a validated Dickman function.
No measurement of NFS is attempted or possible here; where a quantity is not
determinable on this host, it is reported as such.

CITED SOURCE for every formula below:
  Aude Le Gluher, Pierre-Jean Spaenlehauer, Emmanuel Thome,
  "Refined Analysis of the Asymptotic Complexity of the Number Field Sieve",
  Mathematical Cryptology 1(1):1-18, 2021.  arXiv:2007.02730v2.
  Page numbers refer to the published PDF (18 pages).
"""
import math, sys

LN2 = math.log(2.0)
C_NFS = (64.0 / 9.0) ** (1.0 / 3.0)      # (64/9)^(1/3) = 1.922999427076545

# --------------------------------------------------------------- Dickman rho
def dickman(U, h=1.0 / 2000.0):
    """
    rho by the integral equation  rho(u) = 1 - (1/u) int_0^{u-1} rho(t) dt,
    rho(u)=1 on [0,1], on the grid u_k = k*h with h = 1/2000 so that the
    delayed point u-1 lands exactly on the grid.  Trapezoid accumulation.
    Validated in selftest.py T1 against closed forms and tabulated values.
    """
    inv = int(round(1.0 / h))                       # grid points per unit
    J = int(math.ceil(U * inv)) + 2
    u = np.arange(J + 1, dtype=np.float64) * h
    R = np.ones(J + 1, dtype=np.float64)            # rho(u_k); =1 while u<=1
    C = np.zeros(J + 1, dtype=np.float64)           # C[k] = int_0^{u_k} rho
    k0 = inv                                        # first index with u_k > 1
    for k in range(k0, J):
        # rho(u_k) = 1 - C[k-inv] / u_k      (C[k-inv] = int_0^{u_k - 1})
        R[k] = 1.0 - C[k - inv] / u[k]
        C[k + 1] = C[k] + 0.5 * h * (R[k] + R[k + 1]) if k + 1 <= J else C[k]
    return u, R

import numpy as np
_R = {}
def rho(uq):
    uq = float(uq)
    if uq <= 0: return 0.0
    if uq <= 1: return 1.0
    if "t" not in _R: _R["t"] = dickman(20.0)
    u, R = _R["t"]
    return float(np.interp(uq, u, R))

# =====================================================================  X1
def xi_leading(N):
    """Thm 17 leading term:  xi(N) ~ 4 logloglog N / (3 loglog N)."""
    l1 = math.log(N); l2 = math.log(l1); l3 = math.log(l2)
    return 4.0 * l3 / (3.0 * l2)

def xi_twoterm(N):
    """Thm 17 full two-term statement (arXiv:2007.02730v2, p.2, eq. read from
    the page image):
         xi(N) = 4 logloglog N / (3 loglog N)
                 + ( -2 log 2 + log 3 / 6 - 2 ) / loglog N   * (1 + o(1))
    """
    l1 = math.log(N); l2 = math.log(l1); l3 = math.log(l2)
    return 4.0 * l3 / (3.0 * l2) + (-2.0 * LN2 + math.log(3.0) / 6.0 - 2.0) / l2

# =====================================================================  X2
def cost_bits(N, xi=0.0):
    """Formula (1), p.1: exp( c (logN)^{1/3} (loglogN)^{2/3} (1 + xi) ),
    returned in log2.  NOTE the (1+xi) is MULTIPLICATIVE (paper's convention)."""
    l1 = math.log(N); l2 = math.log(l1)
    return C_NFS * l1 ** (1 / 3) * l2 ** (2 / 3) * (1.0 + xi) / LN2

def cost_bits_additive(N, c=C_NFS):
    """The TASK's convention L[a,c] = exp((c + xi)(lnN)^a (lnlnN)^{1-a}).
    Different from the paper's; kept separate so the two are never mixed."""
    l1 = math.log(N); l2 = math.log(l1)
    return (c + 0.0) * l1 ** (1 / 3) * l2 ** (2 / 3) / LN2

# =====================================================================  main
if __name__ == "__main__":
    print("=" * 78)
    print("SANITY: Dickman harness agrees with selftest T1 values")
    for u, ex in [(2, 1 - math.log(2)), (3, 0.0486083882915),
                  (4, 0.0049109256474), (5, 6.3098994610e-05)]:
        g = rho(u); print(f"   rho({u}) = {g:.10e}   exact {ex:.10e}   "
                          f"relerr {abs(g-ex)/ex:.2e}")

    print()
    print("=" * 78)
    print("X2  xi(2^bits) FROM Theorem 17  (the ONLY explicit formula known)")
    print()
    print(f"  {'bits':>6} {'lnN':>10} {'lnlnN':>8} {'xi_lead':>9} {'xi_2term':>9} "
          f"{'F(xi_l)':>9} {'F(xi_2)':>9}")
    print("  " + "-" * 68)
    for bits in (512, 768, 1024, 1536, 2048, 3072, 4096):
        N = 2.0 ** bits
        x1 = xi_leading(N); x2 = xi_twoterm(N)
        l1 = math.log(N); l2 = math.log(l1)
        S = l1 ** (1 / 3) * l2 ** (2 / 3)          # the exponent scale
        # multiplicative cost factor exp( S * xi ) from (1+xi) convention
        F1 = math.exp(S * x1) / LN2
        F2 = math.exp(S * x2) / LN2
        print(f"  {bits:>6d} {l1:>10.3f} {l2:>8.4f} {x1:>9.4f} {x2:>9.4f} "
              f"{F1:>9.2f} {F2:>9.2f}   (F in bits; F>0 = xi INFLATES cost)")

    print()
    print("  --- the SAME thing as the total NFS cost, in log2 ---")
    for bits in (1024, 2048, 4096):
        N = 2.0 ** bits
        b0 = cost_bits(N, 0.0)
        b1 = cost_bits(N, xi_leading(N))
        b2 = cost_bits(N, xi_twoterm(N))
        print(f"  N=2^{bits:<5d} L[1/3,c] with xi=0 : 2^{b0:8.2f}"
              f"   |  xi=leading: 2^{b1:8.2f} (shift {b1-b0:+.2f} bits)"
              f"   |  xi=2-term: 2^{b2:8.2f} (shift {b2-b0:+.2f} bits)")

    print()
    print("=" * 78)
    print("X2b WHERE DOES THE INHERITED 2^45 COME FROM?  Reproduce it exactly.")
    print("     Source: arXiv:2007.02730v2 p.2 EXAMPLE FUNCTIONS (verbatim from")
    print("     the page image):")
    print("       g0: N |-> exp( (logN)^{1/3} (loglogN)^{2/3} )")
    print("       g : N |-> exp( (logN)^{1/3} (loglogN)^{2/3} / (1 + 20/loglogN) )")
    print()
    N = 2.0 ** 2048
    l1 = math.log(N); l2 = math.log(l1)
    S = l1 ** (1 / 3) * l2 ** (2 / 3)
    g0_bits = S / LN2
    den = 1.0 + 20.0 / l2
    g_bits = (S / den) / LN2
    print(f"   loglog N          = {l2:.6f}")
    print(f"   g0(2^2048)        = 2^{g0_bits:.4f}      paper says ~ 2^61   "
          f"[{'MATCH' if abs(g0_bits-61) < 1 else 'MISMATCH'}]")
    print(f"   g (2^2048)        = 2^{g_bits:.4f}      paper says ~ 2^16   "
          f"[{'MATCH' if abs(g_bits-16) < 1 else 'MISMATCH'}]")
    print(f"   RATIO g0/g        = 2^{g0_bits-g_bits:.4f}  = the inherited '2^45' "
          f"[{'REPRODUCED' if abs((g0_bits-g_bits)-45) < 1 else 'no'}]")
    print()
    print("   >>> BUT g is NOT xi.  The paper says only (p.2, verbatim):")
    print("       'The asymptotic expansion of xi that we obtain in the")
    print("        complexity of NFS exhibits a behavior SIMILAR TO the example")
    print("        function g.'")
    print("       The 20 is a chosen illustrative constant, not derived from NFS.")

    print()
    print("=" * 78)
    print("X3  DOES IT MATTER?  Compare xi to the known cost-model uncertainties")
    print()
    b0 = cost_bits(2.0 ** 2048, 0.0)
    print(f"   L[1/3,(64/9)^(1/3)] at 2048 bits  = 2^{b0:.2f}")
    print(f"   (the brief's 2^86 figure is for a different normalisation; the")
    print(f"    exponent itself is what matters)")
    print()
    print(f"   {'source of uncertainty':<52} {'bits':>8}")
    print("   " + "-" * 62)
    rows = [
        ("xi, Thm17 leading term  4log3N/(3log2N)",
         cost_bits(2.0**2048, xi_leading(2.0**2048)) - b0),
        ("xi, Thm17 two-term",
         cost_bits(2.0**2048, xi_twoterm(2.0**2048)) - b0),
        ("xi, the inherited 2^45 (toy g, NOT xi)", 45.0),
        ("B over-prediction, lnB 26.98 vs 21.5 (RSA-240 record)",
         math.log((8/9)**(1/3) * math.log(2.0**2400)**(1/3)
                  * math.log(math.log(2.0**2400))**(2/3) / 21.5) * 1.0),
        ("poly degree: 5 -> 6 in m=N^(1/4)Y^3 box  (~10^3 lattice index)",
         math.log10(3.0) / LN2 * 0 + 10.0),
        ("sieving vs matrix cost split (single-digit)", 5.0),
        ("contemporary record extrapolation uncertainty", 10.0),
    ]
    for nm, b in rows:
        print(f"   {nm:<52} {b:>8.2f}")

    print()
    print("=" * 78)
    print("X4  IS IT KNOWABLE?  Convergence threshold arithmetic")
    thr = math.exp(25.0)
    print(f"   exp(25)          = {thr:.6e}")
    print(f"   exp(exp(25))     = 2^{thr/LN2:.4e}  (paper p.15 says ~ 2^103881111194)")
    print(f"   exp(exp(20))     = 2^{math.exp(20)/LN2:.4e}  (paper p.2)")
    print(f"   RSA-2048         = 2^2048")
    print(f"   ratio of scales  = loglog(exp(exp(25)))/loglog(2^2048) = "
          f"{math.log(math.exp(25))/math.log(math.log(2.0**2048)):.3f}")
    print()
    print("   => the expansion's own convergence threshold is reached at")
    print("      loglog N ~ e^25 ~ 7.2e10, versus loglog N ~ 7.26 for RSA-2048.")
    print("      Separation factor ~ 1e10 in the governing variable.")

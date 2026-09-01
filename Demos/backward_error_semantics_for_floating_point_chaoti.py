"""
Backward-Error Semantics for Floating-Point Chaotic Programs
============================================================

Numerical demonstrations of the two-layer theory:

  (S) SEMANTICS  A floating-point Horner evaluation of a polynomial is the
                 EXACT evaluation, at the same point, of a polynomial whose
                 coefficients differ relatively by at most

                     gamma_{2n}(u) = (1+u)^{2n} - 1,

                 n = number of coefficients, u = unit roundoff.  Consequently a
                 finite execution of a polynomial iteration is an exact
                 delta-pseudo-orbit of the exact real map with

                     delta = gamma_{2n}(u) * sum_i |a_i| B^i.

  (D) DYNAMICS   A delta-pseudo-orbit is tracked by a true orbit with error
                     delta * (L^n - 1)/(L - 1)         (forward, L-Lipschitz)
                     delta / (lambda - 1)              (backward, lambda-expanding)
                     E_{n+1} = delta + L_n E_n         (a-posteriori, observed L_n)

Everything below is self-contained: standard library plus `fractions` for exact
rational arithmetic (used to compute the "exact real" reference orbits).

Run:  python3 demo.py
"""

from __future__ import annotations

from decimal import Decimal, getcontext
from fractions import Fraction
from typing import List, Sequence, Tuple

getcontext().prec = 120   # working precision for the "exact real" reference orbits

# ----------------------------------------------------------------------------
# 0.  The error constant gamma_k(u) = (1+u)^k - 1
# ----------------------------------------------------------------------------

U_BINARY64: float = 2.0 ** -53
U_BINARY32: float = 2.0 ** -24


def gamma(u: float, k: int) -> float:
    """gamma_k(u) = (1+u)^k - 1, the accumulated relative-distortion budget
    after k roundings.  Computed via expm1/log1p for accuracy at tiny u."""
    import math

    return math.expm1(k * math.log1p(u))


def gamma_classical(u: float, k: int) -> float:
    """Higham's classical form k*u/(1 - k*u), valid (and an upper bound for
    gamma_k(u)) whenever k*u < 1."""
    if k * u >= 1.0:
        return float("inf")
    return k * u / (1.0 - k * u)


# ----------------------------------------------------------------------------
# 1.  Horner evaluation: exact (rational), machine (float), and instrumented
# ----------------------------------------------------------------------------


def horner_exact(coeffs: Sequence[Fraction], x: Fraction) -> Fraction:
    """Exact rational Horner evaluation of a_0 + a_1 x + ... + a_{n-1} x^{n-1}."""
    acc = Fraction(0)
    for a in reversed(coeffs):
        acc = a + x * acc
    return acc


def horner_float(coeffs: Sequence[float], x: float) -> float:
    """Machine (binary64) Horner evaluation: n multiplications, n additions."""
    acc = 0.0
    for a in reversed(coeffs):
        acc = a + x * acc
    return acc


def horner_backward_coeffs(
    coeffs: Sequence[float], x: float
) -> Tuple[List[Fraction], Fraction]:
    """Constructive witness for the Backward-Error Semantics Theorem.

    Replays the machine Horner recursion, recording after each level the exact
    rounding factors actually incurred, and returns the perturbed coefficient
    list b (as exact rationals) together with the machine value.  The identity
        horner_exact(b, x) == Fraction(horner_float(coeffs, x))
    then holds to the last bit.

    The perturbation is reconstructed level by level:
        level value  v_j   = fl(a_j + fl(x * v_{j+1}))
        multiply factor t2 = fl(x*v)/(x*v)     (=1 if x*v == 0)
        add factor      t1 = fl(s)/s           (=1 if s == 0)
    and every coefficient inherited from deeper levels is scaled by t1*t2 while
    the head coefficient a_j is scaled by t1 alone.
    """
    xq = Fraction(x)
    b: List[Fraction] = []          # perturbed coefficients, index 0 = deepest so far
    v_float = 0.0                   # machine partial value
    for a in reversed(coeffs):
        prod = x * v_float
        exact_prod = xq * Fraction(v_float)
        t2 = Fraction(prod) / exact_prod if exact_prod != 0 else Fraction(1)
        s = a + prod
        exact_s = Fraction(a) + Fraction(prod)
        t1 = Fraction(s) / exact_s if exact_s != 0 else Fraction(1)
        b = [Fraction(a) * t1] + [c * t1 * t2 for c in b]
        v_float = s
    return b, Fraction(v_float)


def magnitude_functional(coeffs: Sequence[float], x: float) -> float:
    """A(a, x) = sum_i |a_i| |x|^i, the intermediate-magnitude control."""
    acc = 0.0
    for a in reversed(coeffs):
        acc = abs(a) + abs(x) * acc
    return acc


def certified_defect(coeffs: Sequence[float], bound: float, u: float) -> float:
    """delta = gamma_{2n}(u) * A(a, B): the local defect certificate."""
    n = len(coeffs)
    return gamma(u, 2 * n) * magnitude_functional(coeffs, bound)


# ----------------------------------------------------------------------------
# 2.  Orbits
# ----------------------------------------------------------------------------


def fl_orbit(coeffs: Sequence[float], x0: float, steps: int) -> List[float]:
    """The floating-point orbit X_{k+1} = machine-Horner(a, X_k)."""
    out = [x0]
    for _ in range(steps):
        out.append(horner_float(coeffs, out[-1]))
    return out


def horner_decimal(coeffs: Sequence[float], x: Decimal) -> Decimal:
    """Horner evaluation in 120-digit decimal arithmetic.  Used as a stand-in for
    exact real evaluation: with 120 significant digits the reference orbit is
    correct far beyond the ~16 digits at stake.  (A genuinely exact rational
    reference is impossible here: the denominator squares at every step.)"""
    acc = Decimal(0)
    for a in reversed(coeffs):
        acc = Decimal(a) + x * acc
    return acc


def reference_orbit(coeffs: Sequence[float], x0: Decimal, steps: int) -> List[Decimal]:
    """The exact real orbit of the polynomial, to 120 significant digits."""
    out = [x0]
    for _ in range(steps):
        out.append(horner_decimal(coeffs, out[-1]))
    return out


def observed_defects(coeffs: Sequence[float], orbit: Sequence[float]) -> List[Fraction]:
    """|X_{k+1} - p(X_k)| computed exactly, where p is the exact real map."""
    cq = [Fraction(a) for a in coeffs]
    return [
        abs(Fraction(orbit[k + 1]) - horner_exact(cq, Fraction(orbit[k])))
        for k in range(len(orbit) - 1)
    ]


# ----------------------------------------------------------------------------
# 3.  Shadowing bounds
# ----------------------------------------------------------------------------


def forward_shadow_bound(delta: float, lipschitz: float, n: int) -> float:
    """delta * (1 + L + ... + L^{n-1}) — Finite-Time Shadowing."""
    if lipschitz == 1.0:
        return delta * n
    return delta * (lipschitz ** n - 1.0) / (lipschitz - 1.0)


def aposteriori_bounds(
    delta: float, local_factors: Sequence[float]
) -> List[float]:
    """E_0 = 0, E_{n+1} = delta + L_n E_n — Nonautonomous A-Posteriori Shadowing."""
    out = [0.0]
    for ell in local_factors:
        out.append(delta + ell * out[-1])
    return out


def uniform_shadow_bound(delta: float, lam: float) -> float:
    """delta / (lambda - 1) — Uniform-in-Time Backward Shadowing (lambda > 1)."""
    return delta / (lam - 1.0)


def certified_horizon(bounds: Sequence[float], tol: float) -> int:
    """Largest n with E_n <= tol, i.e. the number of steps still certified."""
    horizon = 0
    for n, e in enumerate(bounds):
        if e <= tol:
            horizon = n
        else:
            break
    return horizon


# ----------------------------------------------------------------------------
# Demonstration 1: the machine solved a *different polynomial*, exactly
# ----------------------------------------------------------------------------


def demo_backward_semantics() -> None:
    print("=" * 78)
    print("1.  BACKWARD-ERROR SEMANTICS: the machine solved a nearby problem EXACTLY")
    print("=" * 78)
    coeffs = [0.1, -3.7, 2.9, 1.3, -0.75]   # a_0 .. a_4
    x = 0.9137
    n = len(coeffs)

    b, machine_value = horner_backward_coeffs(coeffs, x)
    reconstructed = horner_exact(b, Fraction(x))

    print(f"  coefficients a = {coeffs}")
    print(f"  evaluation point x = {x}")
    print(f"  machine Horner value      = {float(machine_value)!r}")
    print(f"  exact value of perturbed p= {float(reconstructed)!r}")
    print(f"  identity holds bit-exactly: {reconstructed == machine_value}")
    print()
    print("  perturbed coefficients b_i and their relative deviation:")
    budget = gamma(U_BINARY64, 2 * n)
    worst = 0.0
    for i, (bi, ai) in enumerate(zip(b, coeffs)):
        rel = abs(float(bi) - ai) / abs(ai) if ai != 0 else 0.0
        worst = max(worst, rel)
        print(f"    i={i}  a_i={ai:+.6f}  |b_i-a_i|/|a_i| = {rel:.3e}")
    print(f"  worst observed relative deviation = {worst:.3e}")
    print(f"  certified budget gamma_(2n)(u)    = {budget:.3e}   (2n = {2*n})")
    print(f"  certificate respected: {worst <= budget}")
    print()

    exact_value = horner_exact([Fraction(a) for a in coeffs], Fraction(x))
    fwd = abs(float(machine_value - exact_value))
    cert = certified_defect(coeffs, abs(x), U_BINARY64)
    print("  Derived forward defect certificate:")
    print(f"    observed |fl(p(x)) - p(x)| = {fwd:.3e}")
    print(f"    certified bound            = {cert:.3e}")
    print(f"    certificate respected: {fwd <= cert}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 2: gamma_k(u) and its classical form
# ----------------------------------------------------------------------------


def demo_gamma_constant() -> None:
    print("=" * 78)
    print("2.  THE ERROR CONSTANT gamma_k(u) = (1+u)^k - 1  AND  k u/(1 - k u)")
    print("=" * 78)
    print(f"  {'k':>6} {'gamma_k(2^-53)':>18} {'k u/(1-k u)':>18} {'ratio':>10}")
    for k in (1, 2, 6, 8, 20, 100, 10_000):
        g = gamma(U_BINARY64, k)
        c = gamma_classical(U_BINARY64, k)
        print(f"  {k:>6} {g:>18.6e} {c:>18.6e} {c / g:>10.6f}")
    print("  (the classical form is an upper bound, tight to ~1 + k u)")
    print()
    print(f"  {'k':>6} {'gamma_k(2^-24)  [binary32]':>30}")
    for k in (2, 6, 8, 20):
        print(f"  {k:>6} {gamma(U_BINARY32, k):>30.6e}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 3: a logistic execution is a certified pseudo-orbit
# ----------------------------------------------------------------------------

LOGISTIC_COEFFS: List[float] = [0.0, 4.0, -4.0]   # 4z - 4z^2 = 4z(1-z)


def demo_logistic_pseudo_orbit() -> None:
    print("=" * 78)
    print("3.  SEMANTIC TRANSLATION: a binary64 logistic run IS a pseudo-orbit")
    print("=" * 78)
    x0 = 0.2
    steps = 30
    orbit = fl_orbit(LOGISTIC_COEFFS, x0, steps)

    stayed = all(0.0 <= xk <= 1.0 for xk in orbit)
    print(f"  runtime check 'orbit stayed in [0,1]' : {stayed}")

    delta_cert = certified_defect(LOGISTIC_COEFFS, 1.0, U_BINARY64)
    delta_paper = 2.0 ** -46
    defects = observed_defects(LOGISTIC_COEFFS, orbit)
    worst = max(float(d) for d in defects)

    print(f"  certified delta = gamma_6(u) * A(a,1) = {delta_cert:.6e}")
    print(f"  paper's rounded certificate  2^-46    = {delta_paper:.6e}")
    print(f"  largest observed local defect         = {worst:.6e}")
    print(f"  certificate respected: {worst <= delta_cert <= delta_paper}")
    print()
    print("  first few local defects |X_{k+1} - 4 X_k (1 - X_k)|:")
    for k in range(6):
        print(f"    k={k}  X_k={orbit[k]:.15f}   defect={float(defects[k]):.3e}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 4: forward shadowing bound vs. reality, and the horizon
# ----------------------------------------------------------------------------


def demo_forward_shadowing() -> None:
    print("=" * 78)
    print("4.  FORWARD SHADOWING: certified 2^-46 (4^n - 1)/3, and the true drift")
    print("=" * 78)
    x0 = 0.2
    steps = 30
    fl = fl_orbit(LOGISTIC_COEFFS, x0, steps)
    ex = reference_orbit(LOGISTIC_COEFFS, Decimal(x0), steps)

    delta = 2.0 ** -46
    print("  reference orbit computed in 120-digit arithmetic from the same x0")
    print(f"  {'n':>4} {'|X_n - f^n(x0)|':>20} {'certified bound':>20} {'ok':>5}")
    for n in range(0, steps + 1, 3):
        actual = abs(float(Decimal(fl[n]) - ex[n]))
        bound = forward_shadow_bound(delta, 4.0, n)
        print(f"  {n:>4} {actual:>20.6e} {bound:>20.6e} {str(actual <= bound):>5}")

    bounds = [forward_shadow_bound(delta, 4.0, n) for n in range(60)]
    print()
    print(f"  certified horizon at tolerance 1e-3 : n = {certified_horizon(bounds, 1e-3)}")
    print(f"  certified horizon at tolerance 1.0  : n = {certified_horizon(bounds, 1.0)}")
    print("  (beyond that the certificate says nothing — the state space has diameter 1)")
    print()


# ----------------------------------------------------------------------------
# Demonstration 5: sharpness of the forward bound
# ----------------------------------------------------------------------------


def demo_forward_sharpness() -> None:
    print("=" * 78)
    print("5.  SHARPNESS: the geometric factor (L^n-1)/(L-1) is ATTAINED")
    print("=" * 78)
    L, delta = 4.0, 1e-12
    # witness: f(z) = L z, x_0 = 0, x_{k+1} = L x_k + delta
    x = 0.0
    print("  witness  f(z) = L z ,  x_0 = 0 ,  x_{k+1} = L x_k + delta")
    print(f"  {'n':>4} {'|x_n - f^n(x_0)|':>20} {'bound':>20} {'equal?':>8}")
    for n in range(0, 13):
        bound = forward_shadow_bound(delta, L, n)
        # true orbit through x_0 = 0 stays at 0, so the distance is |x_n|
        equal = abs(x - bound) <= 1e-9 * max(1.0, bound)
        print(f"  {n:>4} {x:>20.10e} {bound:>20.10e} {str(equal):>8}")
        x = L * x + delta
    print("  => no arithmetic improvement can remove the exponential factor;")
    print("     it belongs entirely to the dynamics layer.")
    print()


# ----------------------------------------------------------------------------
# Demonstration 6: a-posteriori bound with observed local expansion
# ----------------------------------------------------------------------------


def demo_aposteriori() -> None:
    print("=" * 78)
    print("6.  A-POSTERIORI CERTIFICATE: observed local expansion 4*max(x, 1-x)")
    print("=" * 78)
    delta = 2.0 ** -46
    for x0 in (0.2, 0.5000001, 0.813):
        orbit = fl_orbit(LOGISTIC_COEFFS, x0, 40)
        local = [4.0 * max(xk, 1.0 - xk) for xk in orbit[:-1]]
        apost = aposteriori_bounds(delta, local)
        glob = [forward_shadow_bound(delta, 4.0, n) for n in range(len(apost))]
        mean_local = sum(local) / len(local)
        h_a = certified_horizon(apost, 1.0)
        h_g = certified_horizon(glob, 1.0)
        print(f"  x0 = {x0}")
        print(f"    mean observed local factor = {mean_local:.4f}   (global constant 4)")
        print(f"    certified horizon, global constant  : n = {h_g}")
        print(f"    certified horizon, observed factors : n = {h_a}")
        print(f"    bound at n=20: global {glob[20]:.3e}   observed {apost[20]:.3e}")
        print(f"    a-posteriori is never worse: {all(a <= g * (1+1e-12) for a, g in zip(apost, glob))}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 7: uniform-in-time shadowing of an expanding cubic
# ----------------------------------------------------------------------------

CUBIC_COEFFS: List[float] = [0.0, 2.0, 0.0, 1.0]   # p(z) = 2z + z^3


def demo_expanding_cubic() -> None:
    print("=" * 78)
    print("7.  UNIFORM-IN-TIME SHADOWING for the expanding cubic p(z) = z^3 + 2z")
    print("=" * 78)
    for B in (0.5, 1.0, 2.0):
        delta = gamma(U_BINARY64, 8) * (2.0 * B + B ** 3)
        print(f"  magnitude bound B = {B}")
        print(f"    delta = gamma_8(u)(2B + B^3)     = {delta:.6e}")
        print(f"    uniform shadowing bound delta/(lambda-1), lambda = 2 : "
              f"{uniform_shadow_bound(delta, 2.0):.6e}")
        print(f"    forward bound at n = 30 would be : "
              f"{forward_shadow_bound(delta, 2.0, 30):.6e}")
    print("  => the uniform bound is independent of the number of steps;")
    print("     the SAME defect certificate feeds both dynamical theorems.")
    print()

    # Sanity: the map really is 2-expanding, and its inverse is 1/2-Lipschitz.
    def p(z: float) -> float:
        return z ** 3 + 2.0 * z

    def p_inv(w: float, iters: int = 200) -> float:
        lo, hi = -10.0, 10.0
        for _ in range(iters):
            mid = 0.5 * (lo + hi)
            if p(mid) < w:
                lo = mid
            else:
                hi = mid
        return 0.5 * (lo + hi)

    pairs = [(-1.3, 0.4), (0.0, 2.0), (0.77, 0.7701)]
    print("  expansion check |p(a)-p(b)| >= 2|a-b| and |p^-1(z)-p^-1(w)| <= |z-w|/2:")
    for a, bb in pairs:
        exp_ok = abs(p(a) - p(bb)) >= 2.0 * abs(a - bb) - 1e-12
        ia, ib = p_inv(p(a)), p_inv(p(bb))
        con_ok = abs(ia - ib) <= abs(p(a) - p(bb)) / 2.0 + 1e-9
        print(f"    a={a:+.4f} b={bb:+.4f}  expanding={exp_ok}  inverse-contracting={con_ok}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 8: structural backward error — the program, not the function
# ----------------------------------------------------------------------------


def demo_structural_backward_error() -> None:
    print("=" * 78)
    print("8.  STRUCTURAL BACKWARD ERROR: r*(x*(1-x)) is an EXACT logistic map")
    print("    at a detuned parameter r'; the expanded form r*x - r*x*x is not.")
    print("=" * 78)
    r, x = 3.9, 0.371829
    # product form: three roundings, all collectible onto r
    step_product = r * (x * (1.0 - x))
    exact_kernel = Fraction(x) * (Fraction(1) - Fraction(x))
    r_prime = Fraction(step_product) / exact_kernel
    rel = abs(float(r_prime) - r) / abs(r)
    budget3 = gamma(U_BINARY64, 3)
    print(f"  r = {r},  x = {x}")
    print(f"  machine value r (x) (1-x)  = {step_product!r}")
    print(f"  recovered parameter r'     = {float(r_prime)!r}")
    print(f"  exactness of r' x (1-x):   {Fraction(r_prime) * exact_kernel == Fraction(step_product)}")
    print(f"  |r'-r|/|r| = {rel:.3e}   <=  gamma_3(u) = {budget3:.3e}   -> {rel <= budget3}")
    print()

    # expanded form: r occurs twice, so no single r' need exist
    print("  Expanded implementation r*x - r*(x*x), scanned over many (r,x):")
    failures = 0
    trials = 0
    worst_rel = 0.0
    for i in range(1, 400):
        rr = 3.0 + i * 0.0025
        for j in range(1, 40):
            xx = j / 41.0
            trials += 1
            expanded = rr * xx - rr * (xx * xx)
            kern = Fraction(xx) * (Fraction(1) - Fraction(xx))
            rp = Fraction(expanded) / kern
            # is the recovered parameter representable, i.e. is the run exactly a
            # logistic step at a *machine-meaningful* detuned parameter with the
            # SAME budget gamma_3?  Test the relative deviation against gamma_3.
            d = abs(float(rp) - rr) / abs(rr)
            worst_rel = max(worst_rel, d)
            if d > budget3:
                failures += 1
    print(f"    trials = {trials}")
    print(f"    worst recovered |r'-r|/|r| = {worst_rel:.3e}")
    print(f"    gamma_3(u) budget          = {budget3:.3e}")
    print(f"    cases exceeding the product-form budget: {failures}")
    print("    (the expanded form has TWO occurrences of r, receiving independent")
    print("     distortions, so the single-parameter budget is not structural)")
    print()

    # A whole run is an exact nonautonomous logistic family.
    print("  A whole product-form run is an exact nonautonomous logistic family:")
    y = 0.25
    params: List[float] = []
    for _ in range(8):
        nxt = r * (y * (1.0 - y))
        kern = Fraction(y) * (Fraction(1) - Fraction(y))
        params.append(float(Fraction(nxt) / kern) if kern != 0 else r)
        y = nxt
    print(f"    nominal r = {r}")
    print("    detuned parameters r_k actually realized:")
    for k, pk in enumerate(params):
        print(f"      k={k}  r_k = {pk!r}   |r_k - r|/|r| = {abs(pk-r)/r:.3e}")
    print(f"    all within gamma_3(u): {all(abs(pk-r)/r <= budget3 for pk in params)}")
    print()

    # Boundary: detuning past 4 destroys invariance of [0,1].
    print("  Boundary of the theory: if r > 4 then r/4 = Phi_r(1/2) escapes [0,1]:")
    for rr in (3.9999999, 4.0, 4.0000001, 4.5):
        val = rr * 0.5 * 0.5
        print(f"    r = {rr:<12} Phi_r(1/2) = {val:.10f}   in [0,1]: {0.0 <= val <= 1.0}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 9: precision scaling — layer (S) improves, layer (D) does not
# ----------------------------------------------------------------------------


def demo_precision_scaling() -> None:
    print("=" * 78)
    print("9.  PRECISION SCALING: horizon grows LINEARLY in the number of bits")
    print("=" * 78)
    print(f"  {'bits':>6} {'u':>14} {'delta':>14} {'horizon (tol=1)':>18}")
    for bits in (11, 24, 53, 64, 113, 237):
        u = 2.0 ** -bits
        delta = gamma(u, 6) * 8.0
        bounds = [forward_shadow_bound(delta, 4.0, n) for n in range(400)]
        print(f"  {bits:>6} {u:>14.3e} {delta:>14.3e} {certified_horizon(bounds, 1.0):>18}")
    print("  (each extra bit of precision buys 1/log2(4) = 0.5 additional certified steps)")
    print()


def main() -> None:
    demo_backward_semantics()
    demo_gamma_constant()
    demo_logistic_pseudo_orbit()
    demo_forward_shadowing()
    demo_forward_sharpness()
    demo_aposteriori()
    demo_expanding_cubic()
    demo_structural_backward_error()
    demo_precision_scaling()
    print("=" * 78)
    print("All demonstrations complete.")
    print("=" * 78)


if __name__ == "__main__":
    main()


"""Algorithm C — Backward Coefficient Reconstruction (Constructive Witness).

Turns the Backward-Error Semantics Theorem into an explicit witness: given a
coefficient list a and a point x, it replays the machine Horner recursion,
records the two rounding factors incurred at each nesting level, and emits the
exact rational coefficient list b such that

        machine-Horner(a, x)  ==  exact-Horner(b, x)      (bit for bit)

together with the verification that |b_i - a_i| <= gamma_{2n}(u) |a_i|.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import List, Sequence, Tuple


def gamma(u: float, k: int) -> float:
    return math.expm1(k * math.log1p(u))


def horner_float(coeffs: Sequence[float], x: float) -> float:
    acc = 0.0
    for a in reversed(coeffs):
        acc = a + x * acc
    return acc


def horner_exact(coeffs: Sequence[Fraction], x: Fraction) -> Fraction:
    acc = Fraction(0)
    for a in reversed(coeffs):
        acc = a + x * acc
    return acc


def backward_reconstruction(
    coeffs: Sequence[float], x: float
) -> Tuple[List[Fraction], Fraction]:
    """Return (b, v) with v the machine value and exact-Horner(b, x) == v.

    At the level whose head coefficient is a_j the machine computes
        v_j = fl(a_j + fl(x * v_{j+1})).
    Writing t2 = fl(x*v)/(x*v) and t1 = fl(s)/s for s = a_j + fl(x*v), the head
    coefficient picks up the factor t1 while every coefficient inherited from
    deeper levels picks up t1*t2.  Accumulating these factors gives b exactly.

    Complexity: O(n) machine operations plus O(n^2) exact-rational
    multiplications for the accumulation (O(n) if the factors are stored
    lazily and applied at the end).
    """
    xq = Fraction(x)
    b: List[Fraction] = []
    v = 0.0
    for a in reversed(coeffs):
        prod = x * v
        exact_prod = xq * Fraction(v)
        t2 = Fraction(prod) / exact_prod if exact_prod != 0 else Fraction(1)
        s = a + prod
        exact_s = Fraction(a) + Fraction(prod)
        t1 = Fraction(s) / exact_s if exact_s != 0 else Fraction(1)
        b = [Fraction(a) * t1] + [c * t1 * t2 for c in b]
        v = s
    return b, Fraction(v)


def verify_witness(
    coeffs: Sequence[float], x: float, u: float = 2.0 ** -53
) -> dict[str, object]:
    """Reconstruct b and check both the exactness identity and the budget."""
    b, v = backward_reconstruction(coeffs, x)
    exact_identity = horner_exact(b, Fraction(x)) == v
    budget = gamma(u, 2 * len(coeffs))
    rels = [
        (abs(float(bi) - ai) / abs(ai) if ai != 0 else 0.0)
        for bi, ai in zip(b, coeffs)
    ]
    return {
        "machine_value": float(v),
        "perturbed_coefficients": [float(bi) for bi in b],
        "relative_deviations": rels,
        "worst_relative_deviation": max(rels) if rels else 0.0,
        "certified_budget_gamma_2n": budget,
        "identity_holds_bit_exactly": exact_identity,
        "budget_respected": (max(rels) if rels else 0.0) <= budget,
    }


if __name__ == "__main__":
    report = verify_witness([0.1, -3.7, 2.9, 1.3, -0.75], 0.9137)
    for key, value in report.items():
        print(f"{key:>30}: {value}")


"""Algorithm A — Compositional Local Defect Certificate.

Computes delta = gamma_{2n}(u) * sum_i |a_i| B^i, the certified per-step defect
of a floating-point Horner iteration observed to stay within magnitude B.
"""

from __future__ import annotations

import math
from typing import List, Sequence


def gamma(u: float, k: int) -> float:
    """gamma_k(u) = (1+u)^k - 1, computed stably for tiny u."""
    return math.expm1(k * math.log1p(u))


def gamma_classical(u: float, k: int) -> float:
    """Higham's upper bound k*u/(1 - k*u), valid when k*u < 1."""
    if k * u >= 1.0:
        raise ValueError("k*u must be < 1 for the classical form")
    return k * u / (1.0 - k * u)


def magnitude_functional(coeffs: Sequence[float], bound: float) -> float:
    """A(a, B) = sum_i |a_i| B^i, evaluated by Horner in O(n)."""
    acc = 0.0
    for a in reversed(coeffs):
        acc = abs(a) + abs(bound) * acc
    return acc


def certified_defect(coeffs: Sequence[float], bound: float, u: float) -> float:
    """The local defect certificate delta = gamma_{2n}(u) * A(a, B).

    Guarantees: if X_{k+1} is the machine Horner evaluation of the polynomial
    with coefficient list `coeffs` at X_k, and |X_k| <= bound for all k <= N,
    then |X_{k+1} - p(X_k)| <= delta for all k < N, where p is the exact real
    polynomial.  Complexity O(n); no dynamical hypothesis is used.
    """
    return gamma(u, 2 * len(coeffs)) * magnitude_functional(coeffs, bound)


def certified_defect_report(
    coeffs: Sequence[float], bound: float, u: float
) -> dict[str, float | int]:
    """Full breakdown of the certificate into its two independent factors."""
    n = len(coeffs)
    return {
        "n_coefficients": n,
        "roundings": 2 * n,
        "unit_roundoff": u,
        "gamma_2n": gamma(u, 2 * n),
        "gamma_2n_classical_upper": gamma_classical(u, 2 * n),
        "magnitude_functional": magnitude_functional(coeffs, bound),
        "delta": certified_defect(coeffs, bound, u),
    }


if __name__ == "__main__":
    logistic: List[float] = [0.0, 4.0, -4.0]
    cubic: List[float] = [0.0, 2.0, 0.0, 1.0]
    for name, cs, B in (("logistic 4z(1-z)", logistic, 1.0),
                        ("cubic z^3+2z", cubic, 1.0)):
        rep = certified_defect_report(cs, B, 2.0 ** -53)
        print(f"{name}: delta = {rep['delta']:.6e}   "
              f"(gamma_{rep['roundings']} = {rep['gamma_2n']:.3e}, "
              f"A = {rep['magnitude_functional']})")


"""Algorithm B — Instrumented Iteration with Runtime Shadowing Certificate.

Runs a floating-point polynomial iteration while carrying, in lockstep, the
a-posteriori shadowing recursion E_0 = 0, E_{n+1} = delta + L_n E_n driven by
the *observed* local expansion factors.  Aborts if the runtime magnitude check
|X_k| <= B fails (that is exactly the "no overflow / no exceptional value"
hypothesis of the semantics layer).
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Callable, List, Sequence


def gamma(u: float, k: int) -> float:
    return math.expm1(k * math.log1p(u))


def horner_float(coeffs: Sequence[float], x: float) -> float:
    acc = 0.0
    for a in reversed(coeffs):
        acc = a + x * acc
    return acc


def magnitude_functional(coeffs: Sequence[float], bound: float) -> float:
    acc = 0.0
    for a in reversed(coeffs):
        acc = abs(a) + abs(bound) * acc
    return acc


@dataclass
class CertifiedRun:
    """Output of the instrumented iteration."""
    orbit: List[float] = field(default_factory=list)
    error_bounds: List[float] = field(default_factory=list)
    local_factors: List[float] = field(default_factory=list)
    delta: float = 0.0
    aborted_at: int | None = None
    certified_horizon: int = 0


def instrumented_iteration(
    coeffs: Sequence[float],
    x0: float,
    steps: int,
    magnitude_bound: float,
    unit_roundoff: float,
    local_expansion: Callable[[float], float],
    tolerance: float = 1.0,
) -> CertifiedRun:
    """Iterate x -> machine-Horner(coeffs, x), certifying as we go.

    Arguments
    ---------
    coeffs            coefficient list a_0, ..., a_{n-1}
    x0                initial condition
    steps             number of iterations requested
    magnitude_bound   B; the run is aborted if |X_k| > B (semantic hypothesis)
    unit_roundoff     u (2^-53 for binary64)
    local_expansion   x |-> L(x), a valid one-sided Lipschitz factor of the
                      exact map at the observed point x
    tolerance         error level beyond which the certificate is uninformative

    Guarantee
    ---------
    For every n not exceeding the returned certified horizon,
        |X_n - f^n(x_0)| <= error_bounds[n] <= tolerance,
    where f is the exact real polynomial map.

    Complexity: O(n) arithmetic per step for an n-coefficient polynomial, i.e.
    the certification adds only O(1) overhead on top of the iteration itself.
    """
    delta = gamma(unit_roundoff, 2 * len(coeffs)) * magnitude_functional(
        coeffs, magnitude_bound
    )
    run = CertifiedRun(orbit=[x0], error_bounds=[0.0], delta=delta)
    for k in range(steps):
        x = run.orbit[-1]
        if not (abs(x) <= magnitude_bound) or not math.isfinite(x):
            run.aborted_at = k
            break
        ell = local_expansion(x)
        run.local_factors.append(ell)
        run.orbit.append(horner_float(coeffs, x))
        run.error_bounds.append(delta + ell * run.error_bounds[-1])
    horizon = 0
    for n, e in enumerate(run.error_bounds):
        if e <= tolerance:
            horizon = n
        else:
            break
    run.certified_horizon = horizon
    return run


if __name__ == "__main__":
    logistic = [0.0, 4.0, -4.0]
    run = instrumented_iteration(
        coeffs=logistic,
        x0=0.2,
        steps=40,
        magnitude_bound=1.0,
        unit_roundoff=2.0 ** -53,
        local_expansion=lambda x: 4.0 * max(x, 1.0 - x),
        tolerance=1.0,
    )
    print(f"delta            = {run.delta:.6e}")
    print(f"aborted at       = {run.aborted_at}")
    print(f"certified horizon= {run.certified_horizon} steps")
    for n in (5, 10, 15, 20, 25, 30):
        print(f"  n={n:>3}  X_n={run.orbit[n]:.15f}  certified |X_n - f^n(x0)| <= "
              f"{run.error_bounds[n]:.3e}")


"""Assemble PACKAGE.json from the prose, demo, algorithm, visualization and
widget sources in this directory and the project root."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
ASSETS = ROOT / "package_assets"
LEAN_DIR = ROOT / "Catalog" / "Novelty"

LEAN_FILES = [
    "Catalog/Novelty/FloatBackwardErrorHorner.lean",
    "Catalog/Novelty/FloatPseudoOrbitShadowing.lean",
    "Catalog/Novelty/FloatExpandingShadowing.lean",
    "Catalog/Novelty/FloatShadowingSharpness.lean",
    "Catalog/Novelty/FloatLogisticParameterError.lean",
]


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


FUTURE_DIRECTIONS = """# Future directions — backward-error semantics for floating-point chaotic programs

Derived from five research cycles: backward-error semantics of rounded Horner
evaluation; the translation of executions into certified pseudo-orbits together
with finite-time shadowing; uniform-in-time shadowing for expanding maps;
sharpness of the forward shadowing bound together with a-posteriori
nonautonomous certificates; and structural backward error for the logistic
parameter.

## What the cycles established

1. **Semantics is separable from dynamics.**  A finite floating-point execution
   of a polynomial iteration, in an execution free of overflow and exceptional
   values, is *exactly* the orbit of a nonautonomous polynomial system whose
   coefficients lie in a relative `γ_{2n}(u)`-neighbourhood of the nominal ones,
   hence a `δ`-pseudo-orbit with `δ = γ_{2n}(u)·Σ|aᵢ|Bⁱ`.  No dynamical
   hypothesis is used at this layer.
2. **The dynamics layer is a black box consuming the defect.**  Forward tracking
   gives `δ(Lⁿ−1)/(L−1)`, which is *sharp* (it is attained by an exactly
   L-Lipschitz map and a pseudo-orbit with constant defect); backward tracking
   under expansivity gives `δ/(λ−1)` uniformly in `n`.
3. **A-posteriori certificates are available.**  Nonautonomous shadowing and its
   instantiation to a double-precision logistic execution replace the global
   Lipschitz constant by the observed local expansion factors `4·max(xₖ,1−xₖ)`,
   computable from the execution itself.
4. **Program structure matters.**  The product implementation of the logistic
   map has *structural* backward error: it is an exact logistic map at a detuned
   parameter — a statement about the program, not the mathematical function.

## Bold conjectures for the next cycle

### 1. Structural backward error is a property of the evaluation scheme, not the polynomial

**Conjecture.** For a parameterised polynomial family `p_θ`, a straight-line
evaluation program admits *family-structural* backward error (every rounded
execution equals the exact `p_{θ'}` for some `θ'` with `|θ'−θ| ≤ γ_k(u)|θ|`)
**iff** the program's expression DAG factors through a single occurrence of each
parameter.  The key insight is that structural backward error is a *syntactic*
invariant of the DAG (parameter multiplicity), not a numerical property.
**Why now?** Cycle 4 proved the positive direction for the single-occurrence
product form `r ⊗ (x ⊗ (1 ⊖ x))` and identified the expanded form `r x − r x²`,
where `r` occurs twice, as the natural candidate counterexample; the general
statement is now a finite combinatorial claim about DAGs.

### 2. Nonautonomous shadowing with observed local expansion beats the global constant

**Conjecture.** For the `r = 4` logistic map the a-posteriori bound
`E(n+1) = δ + |4 − 8xₙ| · E(n)` grows like `e^{n ln 2}`, not `4ⁿ`, for
Lebesgue-a.e. initial condition, so the certified shadowing horizon doubles.
The key insight is that the Birkhoff average of `ln|f'|` against the natural
invariant density `1/(π√(z(1−z)))` is `ln 2`, not `ln 4`: the orbit visits the
strongly expanding endpoints of the interval rarely enough that the *product* of
the observed local factors grows at the Lyapunov rate rather than at the
worst-case rate.

### 3. Uniform shadowing beyond invertibility

Extend the backward (inverse-branch) construction to maps with critical points by
choosing inverse branches along an itinerary, and determine whether a
double-precision logistic execution is shadowed uniformly in time by *some* exact
orbit — not necessarily the one through the same initial point.

### 4. Mixed relative/absolute rounding models

Replace the relative-error model by `fl(a ∘ b) = (a ∘ b)(1 + e) + η` with
`|e| ≤ u`, `|η| ≤ η_min` to cover gradual underflow, and determine how the local
defect certificate degrades near the bottom of the exponent range.

### 5. Interval and stochastic refinements

The runtime certificate is deterministic and worst-case.  A probabilistic version
— treating the individual rounding errors as independent bounded random variables
— should replace `γ_{2n}(u)` by `O(√n · u)` with high probability, giving a
horizon extension of `½ log_L n` steps.
"""


INTERACTIVE_LAYOUT = r"""
# The Computer Was Never Wrong — It Was Solving a Different Problem

> **The claim.** A floating-point run of a polynomial iteration is *not* an
> approximation to anything. It is the **exact** orbit of a slightly different
> polynomial. Everything else in this notebook follows from taking that sentence
> literally.

Simulate a chaotic system and folklore tells you the picture on your screen is
rounding noise. That is half true, and the half that is false is the interesting
half. Let us separate two questions that the folklore tangles together:

| | question | depends on |
|---|---|---|
| **(S) Semantics** | *Which* exact problem did the machine solve? | the arithmetic only |
| **(D) Dynamics** | How far can that problem's answer drift from yours? | the map only |

By the end of this page you will be able to write down, for a real program, a
number you can check at runtime that bounds the distance between what your
computer printed and the true mathematical orbit — and you will know exactly
which half of the bound to attack if it is too weak.

---

## 1. What a machine does to a number

Fix a machine. When it multiplies, it does not return $ab$; it returns the
nearest representable number to $ab$. The classical model — exactly right for
IEEE-754 arithmetic *as long as nothing overflows, underflows, or produces an
infinity or a NaN* — says every operation returns

$$\mathrm{fl}(a \circ b) = (a \circ b)(1+e), \qquad |e| \le u,$$

for $\circ \in \{+,-,\times\}$, where $u$ is the **unit roundoff**:
$u = 2^{-24}$ in single precision, $u = 2^{-53} \approx 1.1\times10^{-16}$ in
double.

That single inequality is the *entire* content of "the run avoided overflow and
exceptional values". Nothing about bit layouts is used, so everything below holds
for any faithfully-rounded arithmetic.

Errors compound rather than add. After $k$ roundings the accumulated distortion
factor sits within

$$\gamma_k(u) := (1+u)^k - 1$$

of $1$, and this quantity is the accountant of the whole theory.

<details>
<summary><b>The three facts about $\gamma_k$ you need (click to expand)</b></summary>

1. **Monotone and nonnegative.** $0 \le \gamma_k(u) \le \gamma_l(u)$ for $k \le l$,
   and $\gamma_1(u) = u$.
2. **Composition — the engine of the theory.** If $|t_1-1| \le \gamma_a(u)$ and
   $|t_2-1| \le \gamma_b(u)$ then $|t_1t_2-1| \le \gamma_{a+b}(u)$.
   *Proof:* write $t_1t_2-1=(t_1-1)t_2+(t_2-1)$ and use $|t_2| \le (1+u)^b$;
   the two terms telescope to $(1+u)^{a+b}-1$. The exponent is therefore an
   additive count of "how many roundings have touched this quantity".
3. **The classical estimate.** If $ku<1$ then
   $\gamma_k(u) \le \dfrac{ku}{1-ku}$, so for realistic $k$ it is just
   "$ku$, give or take". *Proof:* induction on $k$ using
   $\gamma_{k+1} = \gamma_k(1+u)+u$.

</details>

---

## 2. The main event: backward-error semantics

Almost all scientific code evaluates a polynomial by **Horner's rule**, the
nested form $a_0 + x(a_1 + x(a_2 + \cdots))$. Each nesting level costs one
multiplication and one addition — **two roundings per coefficient**.

> ### Backward-Error Semantics for Rounded Horner Evaluation
> Let $p(x)=a_0+a_1x+\cdots+a_{n-1}x^{n-1}$ and let $\widehat p(x)$ be the value
> produced by evaluating it at $x$ by Horner's rule in floating-point arithmetic
> with unit roundoff $u$, in a run free of overflow and exceptional values. Then
> there are **real** numbers $b_0,\dots,b_{n-1}$ with
> $$|b_i - a_i| \le \gamma_{2n}(u)\,|a_i| \quad\text{for every } i$$
> such that
> $$\widehat p(x) = b_0 + b_1x + \cdots + b_{n-1}x^{n-1} \qquad \textbf{exactly.}$$

No error term. No inequality. The number on your screen is the *exact* value, at
the *exact* point you supplied, of a polynomial agreeing with yours to fifteen
or sixteen significant digits in every coefficient.

<details>
<summary><b>Proof sketch: peel one nesting level (click to expand)</b></summary>

Induct on the number of coefficients. At the outermost level the machine forms
$\mathrm{fl}(a_0 + x \otimes v)$ where $v$ is whatever the inner levels returned.
The multiplication contributes a factor $1+e_2$, the addition a factor $1+e_1$,
so the result equals
$$a_0(1+e_1) + x\,v\,(1+e_1)(1+e_2).$$
The head coefficient picks up $1+e_1$ — relative distortion at most $u$ — and
*every* inherited coefficient picks up the common factor
$t = (1+e_1)(1+e_2)$, which by the composition fact lies within
$\gamma_2(u)$ of $1$. Composition again upgrades the inductive bound
$\gamma_{2(n-1)}$ to $\gamma_{2n}$. Two roundings per level, $n$ levels,
exponent $2n$: the bookkeeping is forced.
</details>

<details>
<summary><b>Why the backward statement is strictly better than a forward one</b></summary>

A forward bound says "the answer is close to $p(x)$". Whether that is *useful*
depends on how sensitive $p$ is at $x$: near an ill-conditioned root, a
sixteenth-digit change in the coefficients can move the value by 100%. The
backward statement instead tells you exactly **which problem was solved**,
letting you assess conditioning separately. And the forward bound follows from it
in two lines, while the converse derivation is impossible.
</details>

The algorithm below turns the theorem into a *witness*: it replays a real
double-precision Horner run, records the rounding factors, and hands you the
perturbed coefficient list $b$ — then checks that
$\text{machine-Horner}(a,x) = \text{exact-Horner}(b,x)$ **bit for bit**.

{{algorithm:2}}

And here is what the tube of perturbed coefficients looks like as the evaluation
point sweeps across an interval. Every reconstructed coefficient stays inside
the certified envelope $\pm\gamma_{2n}(u)$ — and, in the right-hand panel, a
first glimpse of the punchline of Section 6.

{{visualization:1}}

---

## 3. From one evaluation to a whole run

Iterate. You want the orbit $x_0, p(x_0), p(p(x_0)), \dots$; your program computes
$X_{k+1} = \widehat p(X_k)$, feeding rounded output back in as input.

Dynamicists call a sequence that *almost* follows a map a **$\delta$-pseudo-orbit**:
$|X_{k+1} - p(X_k)| \le \delta$ for each step. Pseudo-orbits are the input to a
whole industry of [shadowing theorems](https://en.wikipedia.org/wiki/Shadowing_lemma).
The backward theorem hands us one, with a $\delta$ you can compute:

> ### Semantic Translation Theorem
> If a program iterates $p$ by Horner's rule with unit roundoff $u$, and it is
> **observed** that $|X_k| \le B$ for all $k \le N$, then $(X_k)$ is an exact
> $\delta$-pseudo-orbit of the exact real map, with
> $$\delta = \gamma_{2n}(u)\sum_i |a_i| B^i.$$
> Moreover each step is *exactly* a step of a polynomial map whose coefficients
> lie within relative distance $\gamma_{2n}(u)$ of the nominal ones.

Two things to notice, and they are the reason this is worth doing:

* **No dynamical hypothesis appears.** No Lyapunov exponent, no hyperbolicity,
  no chaos. This layer is unconditional.
* **The hypothesis that does appear is a runtime check.** "$|X_k| \le B$" is not
  an assumption about the world; your program can test it while running, and
  passing it is precisely the certificate that no overflow occurred.

{{algorithm:0}}

---

## 4. Now — and only now — let chaos in

With a certified $\delta$ in hand we hand the problem to dynamics.

> ### Finite-Time Shadowing
> If $f$ is $L$-Lipschitz on a region containing both the pseudo-orbit and the
> true orbit through $X_0$, then
> $$|X_n - f^{\,n}(X_0)| \le \delta\,(1 + L + \cdots + L^{n-1}) = \delta\,\frac{L^n-1}{L-1}.$$

The proof is the obvious induction: each step adds a fresh $\delta$ and
multiplies the accumulated discrepancy by at most $L$.

And here is the uncomfortable part — that exponential is *not* an artifact:

> ### Sharpness
> For every $L \ge 0$ and $\delta \ge 0$ there are a map with
> $|f(a)-f(b)| = L|a-b|$ for **all** $a,b$ and a sequence with defect exactly
> $\delta$ at **every** step for which $|X_n - f^n(X_0)|$ *equals*
> $\delta(L^n-1)/(L-1)$ for every $n$.

<details>
<summary><b>The witness is three symbols long (click to expand)</b></summary>

Take $f(z) = Lz$ and $X_0 = 0$, $X_{k+1} = LX_k + \delta$. The true orbit stays
at $0$; the pseudo-orbit is the geometric sum $\delta(1+L+\cdots+L^{n-1})$.
So even a machine whose *only* sin is a constant defect $\delta$ per step is
displaced by exactly the certified amount. Chaos really does what it is accused
of — but it does it in the dynamics layer, downstream of anything to do with
floating point.
</details>

### The logistic map, with numbers attached

Take the poster child $f(z) = 4z(1-z)$ on $[0,1]$, coefficient list $(0,4,-4)$,
in double precision. Three coefficients $\Rightarrow$ six roundings; the
magnitude functional at $B=1$ is $|0|+|4|+|-4| = 8$; and
$\gamma_6(2^{-53}) \le 12\cdot 2^{-53}$, so $\delta \le 2^{-46} \approx 1.4\times10^{-14}$.
The map is $4$-Lipschitz on $[0,1]$. Composing:

$$\boxed{\;|X_n - f^{\,n}(x_0)| \le 2^{-46}\,\frac{4^n-1}{3}\;}$$

for any run observed to stay in $[0,1]$. Everything is attributable: the
$2^{-46}$ came *only* from the arithmetic, the $(4^n-1)/3$ *only* from the
dynamics. Set the bound to $1$ — the diameter of the state space — and the
certificate goes vacuous at about $n = 23$.

---

## 5. The laboratory

Now play. The widget below runs a real reduced-precision execution, computes the
genuine drift against a 240-bit reference orbit, and draws all three certificates
on the same axes. Three experiments are worth doing in order:

1. **Drag precision from 53 down to 24.** The white certificate slides *down* by
   a constant; its slope does not move. Precision is layer (S).
2. **Switch to the expanding cubic.** The green line is *flat*: an exact orbit
   shadows the run to $\sim10^{-15}$ forever. Same arithmetic, different question.
3. **Watch the blue curve.** The a-posteriori bound uses the expansion the run
   *actually experienced*, and it beats the global constant whenever the orbit
   avoids the endpoints of the interval.

{{interactive_demo:0}}

Also worth doing: push precision below about 12 bits on the logistic map and
watch the certified horizon collapse to two or three steps — and note that the
observed defects still respect the certificate, because the certificate never
assumed anything about precision being small.

---

## 6. Two ways to do better

### 6a. Stop insisting on the same starting point

The forward bound demands that the true orbit start at exactly the point your
program started at. That is a *choice*. Classical hyperbolic dynamics builds the
shadowing orbit **backwards** along inverse branches, letting the initial
condition move — and then contraction beats accumulation.

> ### Uniform-in-Time Shadowing for Expanding Maps
> If $f$ has inverse branches $g_n$ (so $f(g_n(z))=z$) each contracting by
> $1/\lambda$ with $\lambda>1$, then every $\delta$-pseudo-orbit of length $N$ is
> shadowed by a **genuine** orbit with
> $$|y_n - x_n| \le \frac{\delta}{\lambda-1} \quad\text{for all } n \le N,$$
> **independently of $N$.**

<details>
<summary><b>Why the exponential disappears (click to expand)</b></summary>

Run the induction *backwards along the horizon*. If the tail from time $1$ is
already shadowed to within $E$, pulling back through one inverse branch gives an
error at time $0$ of at most $(\delta + E)/\lambda$. The map
$E \mapsto (\delta+E)/\lambda$ is a contraction whose fixed point is
$\delta/(\lambda-1)$ — so the induction converges instead of diverging. The
price is that $y_0 \ne x_0$.
</details>

Instantiate on $p(z) = z^3+2z$, which satisfies $|p(a)-p(b)| \ge 2|a-b|$
everywhere, is therefore injective, is surjective by the intermediate value
theorem, and so has a global inverse that is $\tfrac12$-Lipschitz. Result: any
finite double-precision run of $p$ observed to stay within magnitude $B$ is
shadowed by an exact real orbit with error at most $\gamma_8(u)(2B+B^3)$ — about
$6\times10^{-15}$ at $B=1$ — **at every step, forever**.

Expansivity is genuinely needed: $4z(1-z)$ has a critical point at $z=\tfrac12$,
so it admits no uniformly contracting global inverse branch, and the theorem does
not quietly subsume the logistic case.

### 6b. Use what the run actually did

The constant $L=4$ is the *worst* expansion over $[0,1]$, attained only at the
endpoints. The local factor at $a$ is $|f'(a)| = |4-8a|$, and one has
$|f(a)-f(b)| \le 4\max(a,1-a)|a-b|$ for all $b \in [0,1]$ — a number in $[2,4]$
that your program can read off its own output.

> ### Nonautonomous (A-Posteriori) Shadowing
> With observed local factors $L_0,L_1,\dots$, the error obeys
> $$E_0 = 0,\qquad E_{n+1} = \delta + L_n E_n,$$
> and $|X_n - f^n(X_0)| \le E_n$. With a constant $L_k \equiv L$ the recursion
> reproduces $\delta(L^n-1)/(L-1)$ exactly, so nothing is ever lost.

This is a different *kind* of statement: not a theorem proved in advance about
all runs, but a number your program computes about **its own** run, alongside the
run. Here is the instrumented iteration that does it:

{{algorithm:1}}

And here is the whole picture in one figure — drift, three certificates, and the
linear payoff of precision:

{{visualization:0}}

---

## 7. The twist: it's the *program*, not the function

Write the logistic map the way a programmer would:

```
y = r * (x * (1 - x))
```

Three operations, three roundings. Trace them: the subtraction contributes
$1+e_1$, the inner multiplication $1+e_2$, the outer $1+e_3$, and the output is
$r(1+e_1)(1+e_2)(1+e_3) \cdot x(1-x)$. All three distortions land on the single
parameter $r$.

> ### Structural Backward Error
> The floating-point evaluation of $r \otimes (x \otimes (1 \ominus x))$ is
> **exactly** the logistic map of the same family at a detuned parameter $r'$
> with $|r'-r| \le \gamma_3(u)|r|$. Hence a whole floating-point logistic run is
> the exact orbit of a nonautonomous logistic family whose parameters all lie
> within relative distance $\gamma_3(u)$ of the nominal $r$.

Your simulation at $r = 3.9$ is not a noisy logistic map. It is a perfectly clean
logistic map whose knob wobbles in the sixteenth digit.

<details>
<summary><b>Why the algebraically equivalent program behaves differently</b></summary>

Expand the same function as $rx - rx^2$. Now $r$ occurs **twice** and receives
two independent distortions, which need not agree; the result is generally not
*any* logistic map. Structural backward error is therefore a **syntactic**
invariant of the expression graph — how many times each parameter appears — not
a property of the function computed. The right-hand panel of the tube figure in
Section 2 shows exactly this: green points (one occurrence) stay inside the
$\gamma_3(u)$ band; red points (two occurrences) leave it.
</details>

There is a warning attached. If $r$ wobbles *up* past $4$, the unit interval
stops being invariant: the midpoint maps to $r/4 > 1$ and escapes. Arbitrarily
small detuning can change the qualitative global behaviour — which is precisely
why the runtime hypothesis "the run stayed in $[0,1]$" is load-bearing and cannot
be argued away in advance.

---

## 8. Everything at once

The full numerical tour, with every claim on this page checked against exact
rational and high-precision arithmetic:

{{demo:0}}

---

## What to take away

* Floating-point execution of a polynomial iteration is **not an approximation**.
  It is an exact computation on perturbed data, with the perturbation bounded by
  $\gamma_{2n}(u)$ relatively per coefficient.
* The pseudo-orbit certificate $\delta = \gamma_{2n}(u)\sum_i|a_i|B^i$ is
  **unconditional in the dynamics** and **checkable at runtime**.
* Chaos then enters through one isolated, *sharp* dynamical factor:
  $(L^n-1)/(L-1)$ forward, or nothing at all if you let the shadowing orbit start
  elsewhere and the map expands.
* Whether your program admits a *structural* backward error depends on how you
  wrote the expression, not on which function it computes.

The machine was never lying to you. It was answering a slightly different
question — and the whole content of the theory is that you can say precisely
which one.

### Further reading

- [Backward error analysis](https://en.wikipedia.org/wiki/Backward_error_analysis)
- [IEEE 754 floating-point arithmetic](https://en.wikipedia.org/wiki/IEEE_754)
- [Horner's method](https://en.wikipedia.org/wiki/Horner%27s_method)
- [Shadowing lemma](https://en.wikipedia.org/wiki/Shadowing_lemma)
- [Logistic map](https://en.wikipedia.org/wiki/Logistic_map)
"""


def main() -> None:
    package = {
        "title": "Backward-Error Semantics for Floating-Point Chaotic Programs",
        "domain": "Novelty",
        "description": (
            "A finite floating-point execution of a polynomial iteration, free of "
            "overflow and exceptional values, is shown to be exactly the orbit of a "
            "nonautonomous polynomial system whose coefficients lie within relative "
            "distance (1+u)^{2n}-1 of the nominal ones, hence an exact pseudo-orbit "
            "with a computable local defect. Composing that certificate with sharp "
            "shadowing theorems yields explicit, runtime-checkable error bounds for "
            "chaotic simulations, separating the contribution of the arithmetic from "
            "the contribution of the dynamics."
        ),
        "authors": ["Aristotle"],
        "date": "2026-09-01",
        "key_results": [
            "Backward-Error Semantics for Rounded Horner Evaluation: the "
            "floating-point evaluation of a polynomial with n coefficients at a point "
            "x is the exact real evaluation at the same x of a polynomial whose "
            "coefficients differ relatively by at most (1+u)^{2n} - 1.",
            "Semantic Translation Theorem: a finite floating-point execution observed "
            "to stay within magnitude B is an exact pseudo-orbit of the exact real map "
            "with local defect ((1+u)^{2n}-1) times the sum of |a_i| B^i, with no "
            "hypothesis whatsoever on the dynamics.",
            "Sharpness of forward shadowing: the geometric error factor "
            "delta (L^n - 1)/(L - 1) is attained by an exactly L-Lipschitz map together "
            "with a pseudo-orbit of constant per-step defect delta, so the exponential "
            "degradation belongs to the dynamics and not to the arithmetic.",
            "Uniform-in-time shadowing for expanding maps: a pseudo-orbit of a map "
            "whose inverse branches contract by 1/lambda is shadowed by a genuine orbit "
            "with error delta/(lambda - 1) independently of the number of steps; for the "
            "cubic z^3 + 2z in double precision this is about 6e-15 at every step.",
            "Structural backward error: the three-operation implementation of the "
            "logistic step is the exact logistic map of the same family at a parameter "
            "detuned by at most (1+u)^3 - 1 relatively — a property of the evaluation "
            "expression rather than of the function, which fails for the expanded form.",
        ],
        "keywords": [
            "backward error analysis",
            "floating-point arithmetic",
            "unit roundoff",
            "Horner's rule",
            "pseudo-orbit",
            "shadowing",
            "logistic map",
            "expanding maps",
        ],
        "article": read(ROOT / "ARTICLE.md"),
        "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
        "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
        "demo": read(ROOT / "demo.py"),
        "demos": [
            {
                "name": "End-to-End Numerical Tour of Backward-Error Semantics and "
                        "Certified Shadowing",
                "description": (
                    "Nine self-checking numerical experiments covering the whole "
                    "theory. (1) Reconstructs, from a real double-precision Horner "
                    "run, the exact perturbed polynomial the machine solved, and "
                    "verifies bit-for-bit that the machine value equals the exact "
                    "value of that polynomial at the same point, with every "
                    "coefficient inside the certified relative envelope "
                    "(1+u)^{2n}-1. (2) Tabulates the error constant against its "
                    "classical form ku/(1-ku) across seven magnitudes of k and two "
                    "precisions. (3) Evaluates, in exact rational arithmetic, the "
                    "local defect of every step of a double-precision logistic run "
                    "and checks it against the certificate. (4) Compares the "
                    "certified forward bound with the genuine drift measured against "
                    "a 120-digit reference orbit, and locates the certified horizon. "
                    "(5) Exhibits the extremal witness showing the geometric bound is "
                    "attained exactly. (6) Contrasts the a-posteriori bound driven by "
                    "observed local expansion factors with the global-constant bound "
                    "for three initial conditions. (7) Computes the uniform-in-time "
                    "bound for the expanding cubic and verifies its expansion and "
                    "inverse-contraction properties numerically. (8) Recovers the "
                    "detuned parameter of the product-form logistic implementation "
                    "exactly and scans 15561 parameter/state pairs to show that the "
                    "algebraically equivalent expanded form escapes the same budget. "
                    "(9) Demonstrates the linear growth of the certified horizon in "
                    "the number of mantissa bits from half precision to octuple "
                    "precision."
                ),
                "code": read(ROOT / "demo.py"),
            }
        ],
        "algorithms": [
            {
                "name": "Compositional Local Defect Certificate for a Polynomial "
                        "Iteration",
                "description": (
                    "Computes the certified per-step defect "
                    "delta = gamma_{2n}(u) * sum_i |a_i| B^i of a floating-point "
                    "Horner iteration, where gamma_k(u) = (1+u)^k - 1, u is the unit "
                    "roundoff, n the number of coefficients and B an observed "
                    "magnitude bound on the iterates. Mathematically the certificate "
                    "is the forward shadow of the backward-error semantics theorem: "
                    "the rounded evaluation equals the exact evaluation of a "
                    "coefficientwise-perturbed polynomial, and the triangle "
                    "inequality against the magnitude functional converts that into "
                    "an absolute defect. The factorization is the point: the first "
                    "factor depends only on the arithmetic and the program length, "
                    "the second only on the data, and no dynamical hypothesis enters. "
                    "The magnitude functional is itself evaluated by Horner's rule, "
                    "so the whole computation is O(n) arithmetic operations and O(1) "
                    "memory. The error constant is evaluated as expm1(k*log1p(u)) to "
                    "avoid catastrophic cancellation at u near 2^-53, and the "
                    "classical bound ku/(1-ku) is reported alongside for comparison."
                ),
                "pseudocode": (
                    "INPUT   coefficient list a[0..n-1], observed magnitude bound B, "
                    "unit roundoff u >= 0\n"
                    "OUTPUT  certified per-step defect delta\n"
                    "\n"
                    "1.  gamma <- expm1(2n * log1p(u))            // = (1+u)^{2n} - 1\n"
                    "2.  A <- 0\n"
                    "3.  for i from n-1 downto 0 do               // Horner on |a_i|\n"
                    "4.      A <- |a[i]| + |B| * A\n"
                    "5.  end for                                  // A = sum_i |a_i| B^i\n"
                    "6.  delta <- gamma * A\n"
                    "7.  return delta\n"
                    "\n"
                    "GUARANTEE  If X_{k+1} is the machine Horner evaluation of a at "
                    "X_k and |X_k| <= B for all k <= N, then\n"
                    "               |X_{k+1} - p(X_k)| <= delta   for all k < N,\n"
                    "           where p is the exact real polynomial.\n"
                    "COMPLEXITY O(n) time, O(1) space."
                ),
                "code": read(ASSETS / "alg_defect_certificate.py"),
            },
            {
                "name": "Instrumented Polynomial Iteration with Runtime Shadowing "
                        "Certificate",
                "description": (
                    "Executes a floating-point polynomial iteration while carrying, "
                    "in lockstep, the a-posteriori shadowing recursion E_0 = 0, "
                    "E_{n+1} = delta + L_n E_n, where L_n is the local expansion "
                    "factor of the exact map measured at the point the run actually "
                    "visited. At every step the algorithm also performs the runtime "
                    "magnitude check |X_k| <= B: that check is exactly the hypothesis "
                    "'the execution avoided overflow and exceptional values' on which "
                    "the semantic layer rests, and if it fails the certificate is "
                    "void and the run is aborted. The output is a certified horizon: "
                    "the largest n for which the guaranteed distance between the "
                    "computed iterate and the true real orbit is below a caller-"
                    "supplied tolerance. Because a constant local factor makes the "
                    "recursion reproduce the geometric sum delta(L^n-1)/(L-1) exactly, "
                    "the a-posteriori bound is never worse than the global-constant "
                    "bound, and is strictly better whenever the orbit visits regions "
                    "of weaker expansion — for the logistic map at parameter 4 the "
                    "observed factor 4*max(x,1-x) ranges over [2,4] and equals its "
                    "maximum only at the endpoints. Cost is O(n) arithmetic per step "
                    "for an n-coefficient polynomial, i.e. the certification adds only "
                    "O(1) overhead on top of the iteration itself."
                ),
                "pseudocode": (
                    "INPUT   coefficients a[0..n-1], initial point x0, step count N,\n"
                    "        magnitude bound B, unit roundoff u,\n"
                    "        local expansion oracle L(.), tolerance tol\n"
                    "OUTPUT  orbit X, certified error bounds E, certified horizon H\n"
                    "\n"
                    " 1.  delta <- gamma_{2n}(u) * sum_i |a_i| B^i     // Algorithm A\n"
                    " 2.  X[0] <- x0 ; E[0] <- 0\n"
                    " 3.  for k from 0 to N-1 do\n"
                    " 4.      if |X[k]| > B or X[k] is not finite then\n"
                    " 5.          abort: the semantic hypothesis has failed at step k\n"
                    " 6.      end if\n"
                    " 7.      ell <- L(X[k])                    // observed expansion\n"
                    " 8.      X[k+1] <- machine-Horner(a, X[k]) // the actual iteration\n"
                    " 9.      E[k+1] <- delta + ell * E[k]      // a-posteriori recursion\n"
                    "10.  end for\n"
                    "11.  H <- max { n : E[n] <= tol }\n"
                    "12.  return X, E, H\n"
                    "\n"
                    "GUARANTEE  For every n <= H, the exact real orbit f^n(x0) through\n"
                    "           the same initial point satisfies |X[n] - f^n(x0)| <= E[n] <= tol.\n"
                    "COMPLEXITY O(n) per step; O(N) memory."
                ),
                "code": read(ASSETS / "alg_instrumented_iteration.py"),
            },
            {
                "name": "Constructive Backward Coefficient Reconstruction (Witness "
                        "Extraction)",
                "description": (
                    "Turns the backward-error semantics theorem from an existence "
                    "statement into an explicit witness. Given a coefficient list and "
                    "an evaluation point, the algorithm replays the machine Horner "
                    "recursion and records, at each nesting level, the two relative "
                    "rounding factors actually incurred: t2 = fl(x*v)/(x*v) from the "
                    "multiplication and t1 = fl(s)/s from the addition. The head "
                    "coefficient of that level is scaled by t1, while every "
                    "coefficient inherited from deeper levels is scaled by t1*t2 — "
                    "which is precisely the induction in the proof of the theorem, "
                    "run forwards as a computation. The factors are accumulated in "
                    "exact rational arithmetic, so the emitted list b satisfies the "
                    "identity exact-Horner(b, x) = machine-Horner(a, x) bit for bit; "
                    "the algorithm verifies this identity and also checks every "
                    "relative deviation |b_i - a_i|/|a_i| against the certified budget "
                    "(1+u)^{2n} - 1. This is the operational content of the claim "
                    "'the machine solved a nearby problem exactly': the user is handed "
                    "the nearby problem. Cost is O(n) machine operations plus O(n^2) "
                    "exact rational multiplications for the eager accumulation, "
                    "reducible to O(n) by storing the level factors and applying them "
                    "lazily."
                ),
                "pseudocode": (
                    "INPUT   coefficient list a[0..n-1], evaluation point x,\n"
                    "        unit roundoff u (for the budget check only)\n"
                    "OUTPUT  perturbed exact coefficients b[0..n-1] with\n"
                    "        exact-Horner(b,x) = machine-Horner(a,x) exactly\n"
                    "\n"
                    " 1.  b <- empty list ; v <- 0            // v = machine partial value\n"
                    " 2.  for i from n-1 downto 0 do\n"
                    " 3.      prod  <- fl(x * v)\n"
                    " 4.      t2    <- prod / (x * v)   in exact arithmetic  (1 if x*v = 0)\n"
                    " 5.      s     <- fl(a[i] + prod)\n"
                    " 6.      t1    <- s / (a[i] + prod) in exact arithmetic (1 if sum = 0)\n"
                    " 7.      b     <- [ a[i] * t1 ]  ++  [ c * t1 * t2  for c in b ]\n"
                    " 8.      v     <- s\n"
                    " 9.  end for\n"
                    "10.  assert exact-Horner(b, x) = v            // bit-exact identity\n"
                    "11.  assert |b[i] - a[i]| <= ((1+u)^{2n} - 1) * |a[i]|  for all i\n"
                    "12.  return b\n"
                    "\n"
                    "COMPLEXITY O(n) machine operations; O(n^2) exact multiplications\n"
                    "           eagerly, O(n) if the level factors are applied lazily."
                ),
                "code": read(ASSETS / "alg_backward_reconstruction.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Certified Shadowing Horizon and the Linear Payoff of "
                        "Precision",
                "description": (
                    "Two panels. The left panel plots, on a logarithmic error axis "
                    "against iteration count, four curves for a double-precision "
                    "logistic execution: the genuine drift from the exact real orbit "
                    "(measured against a 150-digit reference), the certified forward "
                    "bound delta*(4^n-1)/3, the a-posteriori bound driven by the "
                    "observed local expansion factors 4*max(X_n, 1-X_n), and the "
                    "flat uniform-in-time bound delta/(lambda-1) available for the "
                    "expanding cubic z^3+2z. A horizontal marker at the state-space "
                    "diameter shows where each certificate becomes vacuous. The right "
                    "panel plots the certified horizon against mantissa bits from "
                    "half precision to octuple precision and fits a straight line of "
                    "slope 1/log2(4) = 0.5, exhibiting the linear-in-bits payoff of "
                    "improving the semantics layer against the exponential cost "
                    "imposed by the dynamics layer."
                ),
                "code": read(ASSETS / "viz_shadowing_horizons.py"),
            },
            {
                "name": "The Backward-Error Tube and the Syntactic Nature of "
                        "Structural Backward Error",
                "description": (
                    "Two panels. The left panel sweeps the evaluation point across an "
                    "interval and, for each point, reconstructs from an actual "
                    "double-precision Horner run the perturbed coefficient list that "
                    "the machine exactly evaluated; the five relative deviations are "
                    "plotted against the certified envelope +/- ((1+u)^{2n} - 1). "
                    "Every reconstructed coefficient lies inside the tube, and each "
                    "reconstruction satisfies the bit-exact identity between the "
                    "machine value and the exact value of the perturbed polynomial. "
                    "The right panel compares two algebraically identical "
                    "implementations of a logistic step: the product form, in which "
                    "the parameter occurs once and the recovered detuning always lies "
                    "inside the structural budget (1+u)^3 - 1, and the expanded form, "
                    "in which the parameter occurs twice and the recovered detuning "
                    "routinely leaves that band — a direct visual demonstration that "
                    "structural backward error is an invariant of the expression, not "
                    "of the function."
                ),
                "code": read(ASSETS / "viz_coefficient_tube.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Backward-Error Shadowing Laboratory",
                "description": (
                    "A live laboratory in which the two layers of the theory can be "
                    "moved independently. Choose a system (the chaotic logistic map "
                    "at parameter 4, the logistic family at a tunable parameter, or "
                    "the expanding cubic z^3+2z), an initial condition, a working "
                    "precision from 8 to 53 mantissa bits, a horizon and a tolerance. "
                    "The widget then executes a genuine reduced-precision run — every "
                    "arithmetic operation is rounded to the selected number of bits — "
                    "and measures the true drift against a reference orbit computed "
                    "in 240-bit fixed-point arithmetic, together with the exact "
                    "per-step local defect. Four curves are drawn on a logarithmic "
                    "error axis: the actual drift, the certified forward bound "
                    "delta*(L^n-1)/(L-1), the a-posteriori bound driven by the "
                    "observed local expansion factors, and (for the expanding cubic) "
                    "the flat uniform-in-time bound delta/(lambda-1). Side panels "
                    "report the semantic layer (unit roundoff, number of roundings, "
                    "the error constant, the magnitude functional, the certified "
                    "delta, the largest observed defect, and a live pass/fail badge "
                    "for the certificate) separately from the dynamical layer (global "
                    "Lipschitz constant and the certified horizons under each bound). "
                    "The runtime magnitude check is enforced: if the orbit leaves the "
                    "observed region the widget announces that the semantic hypothesis "
                    "is void, which is exactly what happens to an expanding map after "
                    "about twenty doubling steps. Three guided experiments are built "
                    "into the page: dropping the precision shifts the certificate down "
                    "without changing its slope; switching to the expanding map "
                    "flattens the certificate entirely; and reading off the horizon at "
                    "53 bits reproduces the classical 23-step limit for double-"
                    "precision logistic simulation."
                ),
                "html": read(ASSETS / "widget_shadowing_lab.html"),
            }
        ],
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": "\n\n".join(
            f"-- FILE: {rel}\n{read(ROOT / rel)}" for rel in LEAN_FILES
        ),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": read(ROOT / "demo.py")},
        "lean_files": LEAN_FILES,
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


"""Visualization — The Backward-Error Tube: Which Polynomial Did the Machine Solve?

Left panel: for many evaluation points x, the perturbed coefficient list b
reconstructed from an actual binary64 Horner run is plotted as relative
deviation (b_i - a_i)/a_i, together with the certified envelope
+/- gamma_{2n}(u).  Every reconstructed coefficient lies inside the tube, and
the reconstruction satisfies machine-Horner(a,x) == exact-Horner(b,x) bit for
bit.

Right panel: structural backward error for the logistic step.  For the
single-occurrence product form r*(x*(1-x)) the recovered detuned parameter r'
always lies within gamma_3(u)|r| of r; for the algebraically equivalent
expanded form r*x - r*(x*x), in which r occurs twice, the recovered parameter
routinely leaves that band — structural backward error is a property of the
expression, not of the function.

Requires: matplotlib, numpy (standard library `fractions` for exactness).
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np

U64: float = 2.0 ** -53


def gamma(u: float, k: int) -> float:
    return math.expm1(k * math.log1p(u))


def backward_reconstruction(
    coeffs: Sequence[float], x: float
) -> Tuple[List[Fraction], Fraction]:
    xq = Fraction(x)
    b: List[Fraction] = []
    v = 0.0
    for a in reversed(coeffs):
        prod = x * v
        ep = xq * Fraction(v)
        t2 = Fraction(prod) / ep if ep != 0 else Fraction(1)
        s = a + prod
        es = Fraction(a) + Fraction(prod)
        t1 = Fraction(s) / es if es != 0 else Fraction(1)
        b = [Fraction(a) * t1] + [c * t1 * t2 for c in b]
        v = s
    return b, Fraction(v)


def make_figure() -> plt.Figure:
    coeffs = [0.37, -1.9, 2.4, -0.8, 1.15]
    n = len(coeffs)
    budget = gamma(U64, 2 * n)

    xs = np.linspace(-1.4, 1.4, 260)
    deviations = np.zeros((len(xs), n))
    for j, x in enumerate(xs):
        b, _ = backward_reconstruction(coeffs, float(x))
        for i, (bi, ai) in enumerate(zip(b, coeffs)):
            deviations[j, i] = (float(bi) - ai) / ai

    fig, (ax, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.2))

    palette = ["#c0392b", "#2980b9", "#27ae60", "#8e44ad", "#d35400"]
    for i in range(n):
        ax.plot(xs, deviations[:, i] / 1e-16, lw=1.1, alpha=0.85,
                color=palette[i % len(palette)], label=f"$b_{i}$")
    ax.axhline(budget / 1e-16, color="black", lw=2.0,
               label=r"$\pm\,\gamma_{2n}(u)$ certified envelope")
    ax.axhline(-budget / 1e-16, color="black", lw=2.0)
    ax.axhline(0.0, color="grey", lw=0.7)
    ax.set_xlabel("evaluation point $x$")
    ax.set_ylabel(r"relative deviation $(b_i-a_i)/a_i$   [units of $10^{-16}$]")
    ax.set_title("The polynomial the machine actually solved\n"
                 r"$p(x)=0.37-1.9x+2.4x^2-0.8x^3+1.15x^4$, binary64 Horner",
                 fontsize=11)
    ax.grid(alpha=0.25)
    ax.legend(fontsize=8.5, ncol=2, loc="upper right")

    # --- structural backward error ------------------------------------------
    r = 3.9
    budget3 = gamma(U64, 3)
    xs2 = np.linspace(0.02, 0.98, 700)
    prod_dev, exp_dev = [], []
    for x in xs2:
        xf = float(x)
        kern = Fraction(xf) * (Fraction(1) - Fraction(xf))
        v_prod = r * (xf * (1.0 - xf))
        v_exp = r * xf - r * (xf * xf)
        prod_dev.append(float(Fraction(v_prod) / kern - Fraction(r)) / r)
        exp_dev.append(float(Fraction(v_exp) / kern - Fraction(r)) / r)

    ax2.plot(xs2, np.array(exp_dev) / 1e-16, ".", ms=2.4, color="#c0392b",
             label=r"expanded  $r\,x - r\,x^2$  (two occurrences of $r$)")
    ax2.plot(xs2, np.array(prod_dev) / 1e-16, ".", ms=3.2, color="#27ae60",
             label=r"product  $r\otimes(x\otimes(1\ominus x))$  (one occurrence)")
    ax2.axhline(budget3 / 1e-16, color="black", lw=2.0,
                label=r"$\pm\,\gamma_3(u)$ structural budget")
    ax2.axhline(-budget3 / 1e-16, color="black", lw=2.0)
    ax2.axhline(0.0, color="grey", lw=0.7)
    ax2.set_xlabel("state $x$")
    ax2.set_ylabel(r"recovered detuning $(r'-r)/r$   [units of $10^{-16}$]")
    ax2.set_title("Structural backward error is syntactic\n"
                  "one occurrence of the parameter: exact logistic map at $r'$",
                  fontsize=11)
    ax2.set_ylim(-45, 45)
    ax2.grid(alpha=0.25)
    ax2.legend(fontsize=8.5, loc="upper right")

    fig.tight_layout()
    return fig


if __name__ == "__main__":
    figure = make_figure()
    figure.savefig("coefficient_tube.png", dpi=160, bbox_inches="tight")
    print("wrote coefficient_tube.png")


"""Visualization — The Certified Shadowing Horizon: Three Regimes.

Plots, on a logarithmic error axis against the iteration count:

  * the actual drift of a binary64 logistic execution from the exact real orbit
    through the same initial point (computed against a 120-digit reference);
  * the certified forward bound 2^-46 (4^n - 1)/3;
  * the a-posteriori bound E_{n+1} = delta + 4 max(X_n, 1-X_n) E_n driven by the
    observed local expansion factors;
  * the uniform-in-time bound delta/(lambda-1) available for the expanding
    cubic z^3 + 2z, which is a horizontal line.

A second panel shows how the certified horizon grows linearly with the number
of mantissa bits — the precision-scaling law of the semantics layer.

Requires: matplotlib, numpy (standard library `decimal` for the reference).
"""

from __future__ import annotations

import math
from decimal import Decimal, getcontext
from typing import List, Sequence

import matplotlib.pyplot as plt
import numpy as np

getcontext().prec = 150

LOGISTIC: List[float] = [0.0, 4.0, -4.0]
CUBIC: List[float] = [0.0, 2.0, 0.0, 1.0]
U64: float = 2.0 ** -53


def gamma(u: float, k: int) -> float:
    return math.expm1(k * math.log1p(u))


def horner_float(coeffs: Sequence[float], x: float) -> float:
    acc = 0.0
    for a in reversed(coeffs):
        acc = a + x * acc
    return acc


def horner_decimal(coeffs: Sequence[float], x: Decimal) -> Decimal:
    acc = Decimal(0)
    for a in reversed(coeffs):
        acc = Decimal(a) + x * acc
    return acc


def magnitude_functional(coeffs: Sequence[float], bound: float) -> float:
    acc = 0.0
    for a in reversed(coeffs):
        acc = abs(a) + abs(bound) * acc
    return acc


def make_figure(x0: float = 0.2, steps: int = 34) -> plt.Figure:
    # --- machine orbit and 150-digit reference orbit -------------------------
    fl = [x0]
    ref = [Decimal(x0)]
    for _ in range(steps):
        fl.append(horner_float(LOGISTIC, fl[-1]))
        ref.append(horner_decimal(LOGISTIC, ref[-1]))
    drift = [abs(float(Decimal(a) - b)) for a, b in zip(fl, ref)]

    delta = gamma(U64, 6) * magnitude_functional(LOGISTIC, 1.0)
    ns = np.arange(steps + 1)
    forward = [delta * (4.0 ** n - 1.0) / 3.0 for n in ns]

    apost = [0.0]
    for k in range(steps):
        ell = 4.0 * max(fl[k], 1.0 - fl[k])
        apost.append(delta + ell * apost[-1])

    delta_cubic = gamma(U64, 8) * magnitude_functional(CUBIC, 1.0)
    uniform = [delta_cubic / (2.0 - 1.0)] * (steps + 1)

    fig, (ax, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.4))

    ax.semilogy(ns, [max(d, 1e-18) for d in drift], "o-", ms=4, lw=1.4,
                color="#c0392b", label="actual drift of the binary64 run")
    ax.semilogy(ns, forward, "-", lw=2.2, color="#2c3e50",
                label=r"certified forward bound  $\delta\,(4^n-1)/3$")
    ax.semilogy(ns, apost, "--", lw=2.0, color="#2980b9",
                label=r"a-posteriori bound  $E_{n+1}=\delta+4\max(X_n,1-X_n)E_n$")
    ax.semilogy(ns, uniform, ":", lw=2.4, color="#27ae60",
                label=r"uniform bound for $z^3{+}2z$:  $\delta/(\lambda-1)$")
    ax.axhline(1.0, color="grey", lw=1.0, alpha=0.7)
    ax.text(0.4, 1.6, "state-space diameter — certificate vacuous above",
            fontsize=8, color="grey")

    ax.set_xlabel("iteration $n$")
    ax.set_ylabel("error")
    ax.set_title("Logistic map $4z(1-z)$ in binary64: drift and certificates\n"
                 r"$\delta=\gamma_6(u)\cdot 8\leq 2^{-46}$",
                 fontsize=11)
    ax.set_ylim(1e-18, 1e6)
    ax.grid(alpha=0.25, which="both")
    ax.legend(fontsize=8.5, loc="lower right")

    # --- precision scaling ---------------------------------------------------
    bits = np.array([11, 16, 24, 32, 53, 64, 80, 113, 160, 237])
    horizons = []
    for b in bits:
        u = 2.0 ** float(-b)
        d = gamma(u, 6) * 8.0
        n = 0
        while d * (4.0 ** (n + 1) - 1.0) / 3.0 <= 1.0:
            n += 1
        horizons.append(n)
    ax2.plot(bits, horizons, "s-", color="#8e44ad", lw=2.0, ms=6,
             label="certified horizon (tolerance 1)")
    fit = np.polyfit(bits, horizons, 1)
    ax2.plot(bits, np.polyval(fit, bits), "--", color="grey", lw=1.2,
             label=f"linear fit: slope {fit[0]:.3f} " r"$\approx 1/\log_2 4$")
    for b, h, tag in ((24, horizons[2], "binary32"), (53, horizons[4], "binary64"),
                      (113, horizons[7], "binary128")):
        ax2.annotate(tag, (b, h), textcoords="offset points", xytext=(6, -12),
                     fontsize=8.5)
    ax2.set_xlabel("mantissa bits")
    ax2.set_ylabel("certified steps")
    ax2.set_title("Precision buys horizon linearly\n"
                  "(improving the semantics layer, not the dynamics)", fontsize=11)
    ax2.grid(alpha=0.25)
    ax2.legend(fontsize=9)

    fig.suptitle("Backward-error semantics: the certificate and where it runs out",
                 fontsize=13, y=1.0)
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    figure = make_figure()
    figure.savefig("shadowing_horizons.png", dpi=160, bbox_inches="tight")
    print("wrote shadowing_horizons.png")

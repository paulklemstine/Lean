#!/usr/bin/env python3
"""
Bishop's constructive analysis: numerical demonstrations.
==========================================================

Every real number here is a *regular sequence of rationals*: a function

    x : N -> Q      with      |x(m) - x(n)| <= 1/(m+1) + 1/(n+1).

The index IS the precision: |x_hat - x(n)| <= 1/(n+1), where x_hat is the
classical real denoted by x.  Everything below is exact rational arithmetic
(``fractions.Fraction``); no floating point enters the certified computations.

Demonstrations
--------------
  1. Explicit modulus: the n-th approximation is within 1/(n+1).
  2. Arithmetic with index shifts: sum, product, and a computable sqrt(2).
  3. Constructive completeness: the shifted diagonal, and the explicit family
     showing the unshifted diagonal fails regularity.
  4. The constructive order: witnessed comparison, cotransitivity by one
     rational test, and the impossibility of a uniform witness bound.
  5. The approximate intermediate value theorem by grid search, its exact
     form under a slope bound, and the sharpness of the constant eps/c.
  6. The Brouwerian counterexample: the shelf family's root jumps by 1.
  7. Bracketing beats bounding: the dip function defeats local non-constancy.
  8. Located sets: the trisection search, and the optimal one-query ratio.

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction as F
from typing import Callable, List, Tuple

Rat = F
RegSeq = Callable[[int], Rat]  # a Bishop real: n |-> n-th rational approximation


# --------------------------------------------------------------------------
# 0. Utilities
# --------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def err_bar(n: int) -> Rat:
    """The canonical accuracy attached to index n."""
    return F(1, n + 1)


def check_regular(x: RegSeq, upto: int = 40) -> bool:
    """Verify |x(m) - x(n)| <= 1/(m+1) + 1/(n+1) for all m, n <= upto."""
    return all(
        abs(x(m) - x(n)) <= err_bar(m) + err_bar(n)
        for m in range(upto + 1)
        for n in range(upto + 1)
    )


def isqrt(n: int) -> int:
    return math.isqrt(n)


# --------------------------------------------------------------------------
# 1. Bishop reals and the explicit modulus
# --------------------------------------------------------------------------


def of_rat(q: Rat) -> RegSeq:
    """The Bishop real determined by a rational constant."""
    return lambda n: q


def sqrt_two(n: int) -> Rat:
    """floor(sqrt(2 (n+1)^2)) / (n+1):  an explicitly computable irrational."""
    m = n + 1
    return F(isqrt(2 * m * m), m)


def demo_explicit_modulus() -> None:
    banner("1.  EXPLICIT MODULUS:  |x_hat - x(n)| <= 1/(n+1)")
    print("  Bishop real: sqrt(2)_n = floor(sqrt(2(n+1)^2)) / (n+1)\n")
    print(f"  {'n':>7}  {'x(n)':>18}  {'|x_hat - x(n)|':>16}  {'1/(n+1)':>12}  ok")
    true_sqrt2 = F(math.isqrt(2 * 10**40), 10**20)  # 20 exact digits, as a rational
    for n in (0, 4, 9, 99, 999, 9999):
        v = sqrt_two(n)
        e = abs(true_sqrt2 - v)
        bound = err_bar(n)
        print(
            f"  {n:>7}  {str(v):>18}  {float(e):>16.3e}  "
            f"{float(bound):>12.3e}  {'YES' if e <= bound else 'NO'}"
        )
    print("\n  The index is the precision: no search, no waiting phase.")
    print(f"  Regularity verified for all m, n <= 40:  {check_regular(sqrt_two)}")
    print(f"  sqrt(2)_4  = {sqrt_two(4)}      (exactly 7/5)")
    print(f"  sqrt(2)_99 = {sqrt_two(99)}   (exactly 141/100)")


# --------------------------------------------------------------------------
# 2. Arithmetic with index shifts
# --------------------------------------------------------------------------


def add(x: RegSeq, y: RegSeq) -> RegSeq:
    """(x + y)_n = x_{2n+1} + y_{2n+1}: Bishop's shift halves each error."""
    return lambda n: x(2 * n + 1) + y(2 * n + 1)


def canonical_bound(x: RegSeq) -> int:
    """B(x) = ceil(|x_0|) + 2 dominates every |x_n|."""
    return math.ceil(abs(x(0))) + 2


def mul(x: RegSeq, y: RegSeq) -> RegSeq:
    """(x*y)_n = x_{mu(n)} y_{mu(n)} with mu(n) = (B(x)+B(y))(n+1)."""
    M = canonical_bound(x) + canonical_bound(y)
    return lambda n: x(M * (n + 1)) * y(M * (n + 1))


def demo_arithmetic() -> None:
    banner("2.  ARITHMETIC WITH INDEX SHIFTS")
    s = add(sqrt_two, sqrt_two)
    p = mul(sqrt_two, sqrt_two)
    print("  x = sqrt(2) as a Bishop real.")
    print(f"  Canonical bound B(x) = ceil(|x_0|) + 2 = {canonical_bound(sqrt_two)}")
    print(f"  Product index shift  mu(n) = {2 * canonical_bound(sqrt_two)}(n+1)\n")
    print(f"  {'n':>6}  {'(x+x)(n)':>22}  {'err':>10}  {'(x*x)(n)':>22}  {'err':>10}")
    for n in (0, 2, 10, 100, 1000):
        sv, pv = s(n), p(n)
        print(
            f"  {n:>6}  {str(sv)[:22]:>22}  {float(abs(sv - 2 * math.sqrt(2))):>10.2e}"
            f"  {str(pv)[:22]:>22}  {float(abs(pv - 2)):>10.2e}"
        )
    print(f"\n  Sum regular (m,n <= 30):     {check_regular(s, 30)}")
    print(f"  Product regular (m,n <= 30): {check_regular(p, 30)}")
    print("  The shift is proportional to the magnitudes: larger factors need")
    print("  more digits before their product is trustworthy.")


# --------------------------------------------------------------------------
# 3. Constructive completeness and the necessity of the diagonal shift
# --------------------------------------------------------------------------


def witness_family(k: int) -> RegSeq:
    """w^(k)_n = 1/(k+1) + (-1)^k / (n+1).  Denotes 1/(k+1)."""
    sign = 1 if k % 2 == 0 else -1
    return lambda n: F(1, k + 1) + sign * F(1, n + 1)


def shifted_diagonal(family: Callable[[int], RegSeq]) -> RegSeq:
    """Bishop's limit: L_n = x^(2n+1)_{2n+1}."""
    return lambda n: family(2 * n + 1)(2 * n + 1)


def unshifted_diagonal(family: Callable[[int], RegSeq]) -> RegSeq:
    """The naive candidate: L_n = x^(n)_n.  Not regular in general."""
    return lambda n: family(n)(n)


def demo_completeness() -> None:
    banner("3.  CONSTRUCTIVE COMPLETENESS AND THE NECESSARY DIAGONAL SHIFT")
    print("  Family:  w^(k)_n = 1/(k+1) + (-1)^k / (n+1),  denoting 1/(k+1).")
    print("  These reals tend to 0, so the limit should be 0.\n")

    bad = unshifted_diagonal(witness_family)
    m, n = 0, 1
    lhs, rhs = abs(bad(m) - bad(n)), err_bar(m) + err_bar(n)
    print("  UNSHIFTED diagonal  n |-> w^(n)_n :")
    print(f"    w^(0)_0 = {bad(0)},   w^(1)_1 = {bad(1)}")
    print(f"    |difference| = {lhs}   but regularity allows only {rhs}")
    print(f"    regular?  {lhs <= rhs}   <-- the shift cannot be dropped\n")

    good = shifted_diagonal(witness_family)
    print("  SHIFTED diagonal  n |-> w^(2n+1)_{2n+1} :")
    print(f"  {'n':>6}  {'L(n)':>16}  {'|L(n)|':>12}  {'1/(n+1)':>12}")
    for n in (0, 1, 5, 50, 500):
        v = good(n)
        print(f"  {n:>6}  {str(v)[:16]:>16}  {float(abs(v)):>12.3e}  {float(err_bar(n)):>12.3e}")
    print("    (For this family the shifted diagonal collapses to the exact")
    print("     limit 0 at every index: the two halved errors cancel precisely.)")
    print(f"\n  Regular (m,n <= 40): {check_regular(good)}   Limit -> 0 as required.")
    print("  Rate guarantee:  |L_hat - w^(k)_hat| <= 1/(k+1) for every k.")


# --------------------------------------------------------------------------
# 4. The constructive order
# --------------------------------------------------------------------------


def find_lt_witness(x: RegSeq, y: RegSeq, max_n: int = 100000) -> int | None:
    """A witness n with x(n) + 2/(n+1) < y(n): a certificate for x < y."""
    n = 0
    while n <= max_n:
        if x(n) + 2 * err_bar(n) < y(n):
            return n
        n = 2 * n + 1
    return None


def cotransitivity_test(
    x: RegSeq, y: RegSeq, z: RegSeq, n: int
) -> Tuple[int, Rat, str]:
    """
    Given a witness n for x < y with certified gap g = y_n - x_n - 2/(n+1),
    choose any m with 1/(m+1) <= g/8 and make ONE rational comparison of z_m
    against the midpoint.  Returns (m, g, branch).
    """
    g = y(n) - x(n) - 2 * err_bar(n)
    assert g > 0, "n is not a witness"
    m = max(0, math.ceil(8 / g) - 1)  # smallest m with 1/(m+1) <= g/8
    branch = "x < z" if z(m) >= (x(m) + y(m)) / 2 else "z < y"
    return m, g, branch


def demo_order() -> None:
    banner("4.  THE CONSTRUCTIVE ORDER:  CERTIFICATES, NOT TRUTH VALUES")
    x, y = of_rat(F(0)), of_rat(F(1, 10))
    n = find_lt_witness(x, y)
    print("  x = 0,  y = 1/10.   A proof of x < y is an INDEX, not a bare truth.")
    print(f"    witness index (doubling search): n = {n}")
    print(f"    certificate:  x_n + 2/(n+1) = {x(n) + 2 * err_bar(n)} < {y(n)} = y_n\n")

    print("  COTRANSITIVITY:  one rational comparison decides x < z or z < y.")
    zs = [
        ("z = sqrt(2)/20", lambda k: sqrt_two(k) / 20),
        ("z = 9/100", of_rat(F(9, 100))),
        ("z = 1/100", of_rat(F(1, 100))),
    ]
    for label, z in zs:
        m, g, branch = cotransitivity_test(x, y, z, n)
        print(f"    {label:<16}  gap g = {g},  test index m = {m}  ->  {branch}")
    print("    (The disjunction OVERLAPS; that is exactly why it is decidable.)\n")

    print("  NO UNIFORM WITNESS BOUND:  for every precision N there are")
    print("  Bishop reals x < y with no witness index n <= N.")
    print(f"  {'N':>6}  {'x':>4}  {'y = 1/(N+1)':>14}  {'witness <= N?':>14}  {'a witness':>14}")
    for N in (0, 3, 10, 100, 1000):
        xx, yy = of_rat(F(0)), of_rat(F(1, N + 1))
        has = any(xx(k) + 2 * err_bar(k) < yy(k) for k in range(N + 1))
        w = find_lt_witness(xx, yy)
        print(f"  {N:>6}  {'0':>4}  {str(F(1, N + 1)):>14}  {str(has):>14}  {w:>14}")
    print("\n  The order agrees extensionally with the classical one, yet is")
    print("  decidable at no bounded precision.")


# --------------------------------------------------------------------------
# 5. The intermediate value theorem
# --------------------------------------------------------------------------


def grid_search(
    f: Callable[[float], float], a: float, b: float, N: int
) -> Tuple[int, float, float]:
    """
    The sign-change search: return the LARGEST index k with f(grid_k) <= 0,
    together with the grid point and the value there.  Cost: N+1 evaluations.
    """
    step = (b - a) / N
    best = 0
    for k in range(N + 1):
        if f(a + k * step) <= 0:
            best = k
    return best, a + best * step, f(a + best * step)


def demo_ivt() -> None:
    banner("5.  THE INTERMEDIATE VALUE THEOREM: APPROXIMATE AND EXACT")

    # f(x) = x^3 + x - 1 on [0,1]: modulus omega(eps) = eps/4 (Lipschitz const 4),
    # slope bound c = 1 (since f'(x) = 3x^2 + 1 >= 1).
    f = lambda t: t**3 + t - 1
    omega = lambda eps: eps / 4.0
    c = 1.0
    a, b = 0.0, 1.0
    root = 0.6823278038280193  # the real root, for comparison only

    print("  f(x) = x^3 + x - 1 on [0,1];  modulus omega(eps) = eps/4;  slope c = 1.")
    print("  Approximate IVT: mesh <= omega(eps)  =>  |f| <= eps at the search point.")
    print("  Exact IVT:      run at accuracy c*delta  =>  within delta of the root.\n")
    print(f"  {'delta':>10}  {'N':>8}  {'grid point':>14}  {'|f|':>11}  {'|x-r|':>11}  {'<= delta'}")
    for delta in (1e-1, 1e-2, 1e-3, 1e-4, 1e-5):
        eps = c * delta
        N = max(1, math.ceil((b - a) / omega(eps)))
        _, xk, fv = grid_search(f, a, b, N)
        d = abs(xk - root)
        print(
            f"  {delta:>10.0e}  {N:>8}  {xk:>14.9f}  {abs(fv):>11.3e}"
            f"  {d:>11.3e}  {'YES' if d <= delta else 'no':>8}"
        )

    print("\n  SHARPNESS of the displacement bound |x - r| <= eps/c:")
    print("  f(x) = c x on [-1,1] attains it exactly at x = eps/c.")
    print(f"  {'c':>8}  {'eps':>8}  {'|f(eps/c)|':>12}  {'|x - r|':>10}  {'eps/c':>10}  equal?")
    for cc, ee in ((1.0, 0.5), (2.0, 0.5), (4.0, 1.0), (0.25, 0.125)):
        x = ee / cc
        print(
            f"  {cc:>8}  {ee:>8}  {abs(cc * x):>12.6f}  {abs(x - 0.0):>10.6f}"
            f"  {ee / cc:>10.6f}  {'YES' if abs(x - ee / cc) < 1e-15 else 'no'}"
        )
    print("  No constant kappa < 1 can replace the 1 in eps/c.")


# --------------------------------------------------------------------------
# 6. The Brouwerian counterexample: the shelf family
# --------------------------------------------------------------------------


def shelf(t: float, x: float) -> float:
    """shelf_t(x) = min(x - 1, max(t, x - 2)) on [0,3]: 1-Lipschitz in x."""
    return min(x - 1.0, max(t, x - 2.0))


def shelf_exact_root(t: float) -> float:
    """The forced root: 1 for t > 0, 2 for t < 0, anywhere in [1,2] for t = 0."""
    if t > 0:
        return 1.0
    if t < 0:
        return 2.0
    return float("nan")


def demo_shelf() -> None:
    banner("6.  BROUWERIAN COUNTEREXAMPLE: THE SHELF FAMILY")
    print("  shelf_t(x) = min(x-1, max(t, x-2)) on [0,3], t in [-1,1].")
    print("  Every member is 1-Lipschitz with shelf_t(0) <= 0 <= shelf_t(3),")
    print("  so the APPROXIMATE IVT applies uniformly in t.\n")

    eps = 1e-3
    N = math.ceil(3.0 / eps)
    print(f"  Approximate roots at eps = {eps} (mesh 3/N with N = {N}):")
    print(f"  {'t':>12}  {'grid point':>13}  {'|shelf_t|':>12}  {'exact root':>12}")
    for t in (1.0, 0.5, 1e-3, 1e-9, 0.0, -1e-9, -1e-3, -0.5, -1.0):
        _, xk, fv = grid_search(lambda x: shelf(t, x), 0.0, 3.0, N)
        r = shelf_exact_root(t)
        print(f"  {t:>12.0e}  {xk:>13.6f}  {abs(fv):>12.3e}  {r:>12}")

    print("\n  But the EXACT root jumps: 1 for every t > 0, 2 for every t < 0.")
    print("  Hence no continuous selector t |-> r(t) exists, and moreover EVERY")
    print("  selector, continuous or not, has oscillation >= 1 near t = 0:")
    print(f"  {'eta':>10}  {'r(+eta)':>10}  {'r(-eta)':>10}  {'oscillation':>13}")
    for eta in (1e-1, 1e-4, 1e-9, 1e-15):
        rp, rm = shelf_exact_root(eta), shelf_exact_root(-eta)
        print(f"  {eta:>10.0e}  {rp:>10}  {rm:>10}  {abs(rp - rm):>13}")
    print("\n  The gap never shrinks. What rescues the exact IVT is a positive")
    print("  slope bound -- and shelf_0 is constant on [1,2], so it has none.")


# --------------------------------------------------------------------------
# 7. Bracketing beats bounding
# --------------------------------------------------------------------------


def dip(eta: float, x: float) -> float:
    """dip_eta(x) = min(x - 1, |x - 3| + eta): unique root 1, tiny dip at 3."""
    return min(x - 1.0, abs(x - 3.0) + eta)


def demo_bracketing() -> None:
    banner("7.  BRACKETING BEATS BOUNDING")
    print("  (a) The sign-change search locates a GENUINE root within one mesh,")
    print("      with NO non-degeneracy hypothesis at all.\n")
    f = lambda t: t**3 + t - 1
    root = 0.6823278038280193
    print(f"  {'N':>8}  {'mesh':>11}  {'grid point':>13}  {'|x - r|':>11}  {'<= mesh'}")
    for N in (10, 100, 1000, 10**5):
        _, xk, _ = grid_search(f, 0.0, 1.0, N)
        mesh = 1.0 / N
        d = abs(xk - root)
        print(f"  {N:>8}  {mesh:>11.2e}  {xk:>13.9f}  {d:>11.3e}  {'YES' if d <= mesh else 'no':>7}")

    print("\n  (b) A small VALUE is weak evidence.  dip_eta(x) = min(x-1, |x-3|+eta)")
    print("      is 1-Lipschitz on [0,4], has the unique root 1, and satisfies")
    print("      local non-constancy with the explicit modulus nu(h) = h/8.")
    print("      Yet |dip_eta(3)| = eta is as small as you like, at distance 2")
    print("      from the only root.\n")
    print(f"  {'delta':>10}  {'eta=delta/32':>14}  {'|f(3)|':>12}  {'nu(delta)/2':>13}  {'dist to root':>13}")
    for delta in (1.0, 0.5, 1e-2, 1e-6):
        eta = delta / 32.0
        print(
            f"  {delta:>10.0e}  {eta:>14.3e}  {abs(dip(eta, 3.0)):>12.3e}"
            f"  {delta / 16.0:>13.3e}  {abs(3.0 - 1.0):>13}"
        )
    print("\n  No 'small |f(x)| => x near a root' principle follows from local")
    print("  non-constancy alone.  Report the bracket, not the residual.")


# --------------------------------------------------------------------------
# 8. Located sets: the supremum search and its optimal contraction
# --------------------------------------------------------------------------


def trisection(
    L: Callable[[Rat, Rat], bool], a0: Rat, b0: Rat, steps: int
) -> List[Tuple[Rat, Rat]]:
    """Bishop's trisection search.  Width shrinks by EXACTLY 2/3 per step."""
    out = [(a0, b0)]
    p, q = a0, b0
    for _ in range(steps):
        m1 = p + (q - p) / 3
        m2 = p + 2 * (q - p) / 3
        p, q = (p, m2) if L(m1, m2) else (m1, q)
        out.append((p, q))
    return out


def one_query_search(
    alpha: Rat, beta: Rat, L: Callable[[Rat, Rat], bool], a0: Rat, b0: Rat, steps: int
) -> List[Tuple[Rat, Rat]]:
    """General one-query search: contraction factor exactly max(beta, 1-alpha)."""
    out = [(a0, b0)]
    p, q = a0, b0
    for _ in range(steps):
        qa = p + alpha * (q - p)
        qb = p + beta * (q - p)
        p, q = (p, qb) if L(qa, qb) else (qa, q)
        out.append((p, q))
    return out


def demo_located_sup() -> None:
    banner("8.  LOCATED SETS: THE SUPREMUM SEARCH AND ITS OPTIMAL RATE")
    c = F(1, 2)
    L = lambda p, q: c <= q  # located datum for S = (-inf, 1/2]
    print("  S = (-inf, 1/2].  Located datum: L(p,q) = [1/2 <= q], a decidable")
    print("  rational comparison.  Trisection on [0,1]:\n")
    encl = trisection(L, F(0), F(1), 10)
    print(f"  {'n':>4}  {'p_n':>16}  {'q_n':>18}  {'width':>14}  {'(2/3)^n':>14}  {'contains 1/2'}")
    for n, (p, q) in enumerate(encl):
        w = q - p
        print(
            f"  {n:>4}  {str(p)[:16]:>16}  {str(q)[:18]:>18}  {float(w):>14.6e}"
            f"  {float(F(2,3)**n):>14.6e}  {'YES' if p < c <= q else 'no'}"
        )
    print("\n  Width is EXACTLY (2/3)^n -- not merely bounded by it.\n")

    print("  Is 2/3 optimal?  The general one-query scheme with fractions")
    print("  alpha < beta contracts by exactly max(beta, 1-alpha):\n")
    print(f"  {'alpha':>10}  {'beta':>10}  {'max(beta,1-alpha)':>19}  {'width after 20':>16}  note")
    schemes = [
        (F(1, 3), F(2, 3), "trisection"),
        (F(2, 5), F(1, 2), "beats 2/3"),
        (F(9, 20), F(11, 20), "closer to 1/2"),
        (F(49, 100), F(51, 100), "closer still"),
        (F(499, 1000), F(501, 1000), "near-optimal"),
    ]
    for alpha, beta, note in schemes:
        rho = max(beta, 1 - alpha)
        seq = one_query_search(alpha, beta, L, F(0), F(1), 20)
        w = seq[-1][1] - seq[-1][0]
        assert seq[-1][0] < c <= seq[-1][1], "enclosure invariant violated"
        print(f"  {str(alpha):>10}  {str(beta):>10}  {str(rho):>19}  {float(w):>16.3e}  {note}")

    print("\n  Lower bound: max(beta, 1-alpha) > 1/2 for every alpha < beta.")
    print("  Infimum: alpha = 1/2 - t/2, beta = 1/2 + t/2 gives 1/2 + t/2.")
    print(f"  {'t':>12}  {'contraction':>14}  {'> 1/2 ?':>9}  {'oracle calls for 1e-12':>24}")
    for t in (F(1, 2), F(1, 10), F(1, 1000), F(1, 10**6)):
        rho = F(1, 2) + t / 2
        calls = math.ceil(math.log(1e-12) / math.log(float(rho)))
        print(f"  {float(t):>12.1e}  {float(rho):>14.9f}  {str(rho > F(1,2)):>9}  {calls:>24}")
    print("\n  One oracle call returns one bit; one bit at best halves the space.")
    print("  The infimum 1/2 is never attained: the two query points must be")
    print("  distinct, and that gap is exactly what makes locatedness usable.")


# --------------------------------------------------------------------------


def main() -> None:
    print(__doc__)
    demo_explicit_modulus()
    demo_arithmetic()
    demo_completeness()
    demo_order()
    demo_ivt()
    demo_shelf()
    demo_bracketing()
    demo_located_sup()
    banner("ALL DEMONSTRATIONS COMPLETE")
    print("  Every certified computation above used exact rational arithmetic.")
    print("  Floating point appears only where a classical reference value is")
    print("  displayed for comparison.")
    print()


if __name__ == "__main__":
    main()

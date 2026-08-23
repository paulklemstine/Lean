#!/usr/bin/env python3
"""
Numerical demonstrations for
    "The Knee of a Domain Is a Concentration Functional, Not a Token Count"

Everything below is exact rational arithmetic (fractions.Fraction) wherever a
theorem asserts an exact value, so the printed numbers *are* the theorem
statements rather than floating-point approximations of them.

Contents
--------
1.  The measured domain table and its two refuting statistics
      Spearman rho = -2/5,  R^2 = 4225/1054258.
2.  The order-theoretic obstruction: discordant / concordant pair certificates
    that kill every increasing and every decreasing law.
3.  Capture curves, the knee functional, and the three concentration bounds
      k* >= tau/m,   k* >= tau/p0,   k* >= tau^2/S.
4.  The decoupling theorem: identical token density, arbitrary knee.
5.  The exactly solvable geometric family and the 2-vs-14 domain shift.
6.  Majorization duality and the mixture sandwich, checked on samples.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction as F
from itertools import combinations
from typing import Callable, Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 0.  The measured data
# ----------------------------------------------------------------------------

# Four uncensored domains, in the order (code, prose-de, math, prose-en).
DOMAINS: List[str] = ["code", "prose-de", "math", "prose-en"]
TPW: List[F] = [F(1950, 1000), F(1885, 1000), F(1214, 1000), F(1173, 1000)]
KNEE: List[F] = [F(12), F(20), F(16), F(16)]

# The censored fifth domain: French, tpw 1.246, knee > 32 at the original grid.
FRENCH_TPW: F = F(1246, 1000)
FRENCH_KNEE_LOWER_BOUND: int = 32


# ----------------------------------------------------------------------------
# 1.  Rank statistics
# ----------------------------------------------------------------------------

def ascending_ranks_ordinal(x: Sequence[F]) -> List[F]:
    """Ordinal ranks 1..n, ties broken by index order (smallest value = rank 1)."""
    order = sorted(range(len(x)), key=lambda i: (x[i], i))
    ranks: List[F] = [F(0)] * len(x)
    for position, i in enumerate(order):
        ranks[i] = F(position + 1)
    return ranks


def ascending_ranks_competition(x: Sequence[F]) -> List[F]:
    """Competition rank: 1 + number of strictly smaller entries."""
    return [F(1 + sum(1 for v in x if v < xi)) for xi in x]


def ascending_ranks_midrank(x: Sequence[F]) -> List[F]:
    """Tie-averaged (fractional) ranks."""
    out: List[F] = []
    for xi in x:
        smaller = sum(1 for v in x if v < xi)
        equal = sum(1 for v in x if v == xi)
        # average of ranks smaller+1 .. smaller+equal
        out.append(F(2 * smaller + equal + 1, 2))
    return out


def spearman(r: Sequence[F], s: Sequence[F]) -> F:
    """Spearman coefficient from the sum of squared rank differences."""
    n = len(r)
    d2 = sum((ri - si) ** 2 for ri, si in zip(r, s))
    return F(1) - F(6) * d2 / (F(n) * (F(n) ** 2 - 1))


# ----------------------------------------------------------------------------
# 2.  Least-squares statistics
# ----------------------------------------------------------------------------

def mean(x: Sequence[F]) -> F:
    return sum(x, F(0)) / F(len(x))


def cov(x: Sequence[F], y: Sequence[F]) -> F:
    mx, my = mean(x), mean(y)
    return sum((xi - mx) * (yi - my) for xi, yi in zip(x, y))


def r_squared(x: Sequence[F], y: Sequence[F]) -> F:
    return cov(x, y) ** 2 / (cov(x, x) * cov(y, y))


def least_squares_line(x: Sequence[F], y: Sequence[F]) -> Tuple[F, F]:
    a = cov(x, y) / cov(x, x)
    b = mean(y) - a * mean(x)
    return a, b


# ----------------------------------------------------------------------------
# 3.  Order-theoretic certificates
# ----------------------------------------------------------------------------

def discordant_pair(x: Sequence[F], y: Sequence[F]) -> Tuple[int, int] | None:
    """A pair with x_i < x_j but not y_i < y_j: refutes every increasing law."""
    for i, j in combinations(range(len(x)), 2):
        for a, b in ((i, j), (j, i)):
            if x[a] < x[b] and not (y[a] < y[b]):
                return (a, b)
    return None


def concordant_pair(x: Sequence[F], y: Sequence[F]) -> Tuple[int, int] | None:
    """A pair with x_i < x_j and y_i < y_j: refutes every decreasing law."""
    for i, j in combinations(range(len(x)), 2):
        for a, b in ((i, j), (j, i)):
            if x[a] < x[b] and y[a] < y[b]:
                return (a, b)
    return None


# ----------------------------------------------------------------------------
# 4.  Capture curves, knees, concentration statistics
# ----------------------------------------------------------------------------

def capture_curve(mass: Sequence[F]) -> Callable[[int], F]:
    """Prefix sums of a sorted-descending mass vector, saturating at the total."""
    prefix: List[F] = [F(0)]
    for m in mass:
        prefix.append(prefix[-1] + m)

    def C(k: int) -> F:
        return prefix[min(k, len(prefix) - 1)]

    return C


def knee(C: Callable[[int], F], tau: F, ceiling: int = 10_000) -> int:
    """Least k with C(k) >= tau."""
    for k in range(ceiling + 1):
        if C(k) >= tau:
            return k
    raise ValueError("tolerance not reached below the ceiling")


def collision_index(mass: Sequence[F]) -> F:
    """S = sum p_i^2; 1/S is the effective number of participating keys."""
    return sum((m * m for m in mass), F(0))


def concentration_bounds(mass: Sequence[F], tau: F) -> Dict[str, F]:
    """The three certified lower bounds on the knee."""
    sorted_mass = sorted(mass, reverse=True)
    p0 = sorted_mass[0]
    step_cap = p0  # for a sorted vector the largest single step is p0
    S = collision_index(sorted_mass)
    return {
        "per-key bound  tau/m": tau / step_cap,
        "top-mass bound tau/p0": tau / p0,
        "participation  tau^2/S": tau * tau / S,
    }


# ----------------------------------------------------------------------------
# 5.  Model families
# ----------------------------------------------------------------------------

def uniform_profile_curve(tau: F, k: int) -> Callable[[int], F]:
    """Each of the first k keys carries tau/k: knee is exactly k at tolerance tau."""
    def C(j: int) -> F:
        return min(F(1), F(j) * tau / F(k))
    return C


def geometric_profile_curve(r: F) -> Callable[[int], F]:
    """C(k) = 1 - r^k: residual attention decays at rate r."""
    def C(k: int) -> F:
        return F(1) - r ** k
    return C


def geometric_knee(r: F, tau: F) -> int:
    """Least k with r^k <= 1 - tau (exact, by repeated multiplication)."""
    slack = F(1) - tau
    k, residual = 0, F(1)
    while residual > slack:
        residual *= r
        k += 1
    return k


def mixture_curve(lam: F,
                  CP: Callable[[int], F],
                  CQ: Callable[[int], F]) -> Callable[[int], F]:
    def C(k: int) -> F:
        return lam * CP(k) + (F(1) - lam) * CQ(k)
    return C


def majorizes(CP: Callable[[int], F], CQ: Callable[[int], F], upto: int) -> bool:
    return all(CQ(k) <= CP(k) for k in range(upto + 1))


def knee_dominates(CP: Callable[[int], F],
                   CQ: Callable[[int], F],
                   taus: Sequence[F]) -> bool:
    return all(knee(CP, t) <= knee(CQ, t) for t in taus)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_measured_table() -> None:
    banner("1.  The measured table and the two refuting statistics")
    print(f"{'domain':<10}{'TPW':>10}{'knee k*':>10}")
    for name, t, k in zip(DOMAINS, TPW, KNEE):
        print(f"{name:<10}{float(t):>10.3f}{int(k):>10d}")
    print(f"{'prose-fr':<10}{float(FRENCH_TPW):>10.3f}{'>32':>10}   (censored)")

    r_tpw = ascending_ranks_ordinal(TPW)
    conventions: Dict[str, List[F]] = {
        "reported (math before en)": [F(1), F(4), F(2), F(3)],
        "alternate (en before math)": [F(1), F(4), F(3), F(2)],
        "competition": ascending_ranks_competition(KNEE),
        "midrank": ascending_ranks_midrank(KNEE),
    }
    print("\nascending TPW ranks:", [int(v) for v in r_tpw])
    print("Spearman rho under each tie convention:")
    for label, r_knee in conventions.items():
        rho = spearman(r_tpw, r_knee)
        print(f"   {label:<28} ranks={[str(v) for v in r_knee]}"
              f"  rho = {rho} = {float(rho):+.4f}")
    print("\n   -> every convention gives rho < 0.  P1 (rho >= 0.9) REFUTED,")
    print("      and refuted with the wrong sign.")

    a, b = least_squares_line(TPW, KNEE)
    R2 = r_squared(TPW, KNEE)
    print(f"\nleast-squares line:  k* = {float(a):+.4f} * TPW {float(b):+.4f}")
    print(f"R^2 = {R2} = {float(R2):.6f}")
    assert R2 == F(4225, 1054258)
    print("   -> exactly 4225/1054258.  P2 (R^2 >= 0.8) REFUTED.")
    print("      An exact affine law would force R^2 = 1, so no line fits.")


def demo_order_certificates() -> None:
    banner("2.  Order-theoretic certificates: no monotone law of any shape")
    d = discordant_pair(TPW, KNEE)
    c = concordant_pair(TPW, KNEE)
    assert d is not None and c is not None
    i, j = d
    print(f"discordant pair: {DOMAINS[i]} (TPW {float(TPW[i]):.3f}, k* {int(KNEE[i])})"
          f"  <  {DOMAINS[j]} (TPW {float(TPW[j]):.3f}, k* {int(KNEE[j])})")
    print("   TPW increases but the knee does NOT  ->  kills every increasing law.")
    i, j = c
    print(f"concordant pair: {DOMAINS[i]} (TPW {float(TPW[i]):.3f}, k* {int(KNEE[i])})"
          f"  <  {DOMAINS[j]} (TPW {float(TPW[j]):.3f}, k* {int(KNEE[j])})")
    print("   TPW and knee increase together     ->  kills every decreasing law.")

    print("\ncompetition ranks are invariant under strictly increasing maps:")
    print("   crank(TPW)        =", [int(v) for v in ascending_ranks_competition(TPW)])
    print("   crank(TPW^3)      =",
          [int(v) for v in ascending_ranks_competition([t ** 3 for t in TPW])])
    print("   crank(knee)       =", [int(v) for v in ascending_ranks_competition(KNEE)])
    print("   -> crank(knee) != crank(TPW): code is rank 4 in density, rank 1 in knee.")

    print("\nthe censored French point only strengthens the increasing horn:")
    print(f"   fr TPW {float(FRENCH_TPW):.3f} < de TPW {float(TPW[1]):.3f}, "
          f"yet fr knee >= {FRENCH_KNEE_LOWER_BOUND} > 20 = de knee.")


def demo_concentration_bounds() -> None:
    banner("3.  Capture curves, knees, and the three concentration bounds")
    tau = F(3, 4)

    examples: Dict[str, List[F]] = {
        "four equal keys": [F(1, 4)] * 4,
        "one dominant key": [F(4, 5), F(1, 10), F(1, 20), F(1, 20)],
        "twenty equal keys": [F(1, 20)] * 20,
        "power law 1/i^2": None,  # filled in below
    }
    weights = [F(1, (i + 1) ** 2) for i in range(20)]
    total = sum(weights, F(0))
    examples["power law 1/i^2"] = [w / total for w in weights]

    for name, mass in examples.items():
        C = capture_curve(mass)
        k = knee(C, tau)
        bounds = concentration_bounds(mass, tau)
        S = collision_index(mass)
        print(f"\n{name}:")
        print(f"   effective #keys 1/S = {float(1 / S):7.3f}   "
              f"top mass p0 = {float(max(mass)):.3f}")
        print(f"   true knee at tau=3/4 : {k}")
        for label, value in bounds.items():
            ok = "ok" if F(k) >= value else "VIOLATED"
            print(f"   {label:<24} >= {float(value):7.3f}   [{ok}]")
            assert F(k) >= value


def demo_decoupling() -> None:
    banner("4.  Decoupling: same token density, every possible knee")
    tau = F(1, 2)
    density = F(1173, 1000)  # English's density, attached to every profile
    for k in (1, 2, 5, 12, 33):
        C = uniform_profile_curve(tau, k)
        got = knee(C, tau)
        print(f"   density {float(density):.3f}, uniform profile with k={k:>2}"
              f"  ->  knee = {got}")
        assert got == k
    print("\n   Every (density, knee) pair is realised, so NO function g with")
    print("   k* = g(TPW) can exist -- not merely no monotone one.")

    print("\n   The four measured points, realised by concentration alone:")
    for name, t, k in zip(DOMAINS, TPW, KNEE):
        C = uniform_profile_curve(tau, int(k))
        print(f"      {name:<10} density {float(t):.3f}   knee {knee(C, tau):>2}")


def demo_geometric_shift() -> None:
    banner("5.  The exactly solvable geometric family: the shift at equal density")
    tau = F(3, 4)
    print("   C(k) = 1 - r^k;  k*(tau) <= k  <=>  r^k <= 1 - tau")
    print(f"\n   {'r':>8}{'k*(3/4)':>10}{'residual r^k*':>16}")
    for r in (F(1, 10), F(1, 4), F(1, 2), F(7, 10), F(9, 10), F(95, 100)):
        k = geometric_knee(r, tau)
        assert knee(geometric_profile_curve(r), tau) == k
        print(f"   {str(r):>8}{k:>10}{float(r ** k):>16.5f}")

    k_fast = geometric_knee(F(1, 2), tau)
    k_slow = geometric_knee(F(9, 10), tau)
    assert (k_fast, k_slow) == (2, 14)
    print(f"\n   decay 1/2  -> knee {k_fast}")
    print(f"   decay 9/10 -> knee {k_slow}")
    print("   Identical tokens-per-word; a sevenfold memory gap generated purely")
    print("   by attention decay -- the in-model analogue of code vs French.")


def demo_majorization_and_mixtures() -> None:
    banner("6.  Duality with majorization, and the mixture sandwich")
    taus = [F(i, 20) for i in range(1, 20)]
    fast = geometric_profile_curve(F(1, 2))
    slow = geometric_profile_curve(F(9, 10))

    print("   fast (r=1/2) vs slow (r=9/10):")
    print(f"      capture majorization (k <= 60): {majorizes(fast, slow, 60)}")
    print(f"      knee dominance at 19 tolerances: {knee_dominates(fast, slow, taus)}")
    print("      -> the two agree, as the Duality Theorem requires.")

    print("\n   knee curves (a complete invariant of the capture curve):")
    row_t = "      tau     " + "".join(f"{float(t):>7.2f}" for t in taus[::3])
    row_f = "      fast k* " + "".join(f"{knee(fast, t):>7d}" for t in taus[::3])
    row_s = "      slow k* " + "".join(f"{knee(slow, t):>7d}" for t in taus[::3])
    print(row_t); print(row_f); print(row_s)

    print("\n   mixtures interleave (tau = 3/4, components have knees 2 and 14):")
    lo, hi = knee(fast, F(3, 4)), knee(slow, F(3, 4))
    for lam in (F(0), F(1, 4), F(1, 2), F(3, 4), F(9, 10), F(1)):
        k = knee(mixture_curve(lam, fast, slow), F(3, 4))
        assert min(lo, hi) <= k <= max(lo, hi)
        print(f"      lambda = {str(lam):>5}   mixed knee = {k:>3}"
              f"   in [{min(lo, hi)}, {max(lo, hi)}]  ok")
    print("\n   No blend of domains escapes the band spanned by its ingredients,")
    print("   so the observed inter-domain spread is genuine structure.")


def main() -> None:
    demo_measured_table()
    demo_order_certificates()
    demo_concentration_bounds()
    demo_decoupling()
    demo_geometric_shift()
    demo_majorization_and_mixtures()
    banner("All assertions passed.")


if __name__ == "__main__":
    main()

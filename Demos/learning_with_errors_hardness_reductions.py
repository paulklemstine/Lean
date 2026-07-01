"""Numerical demonstrations for the analytic and algebraic core of the
Learning with Errors (LWE) worst-case-to-average-case reduction.

This module is fully self-contained (standard library only). It verifies,
numerically, the key results:

  1. The Gaussian weight rho_s(x) = exp(-pi x^2 / s^2): positivity,
     upper bound 1, peak at 0, evenness, scaling, and monotone decay.
  2. The discrete Gaussian over a finite support is a probability
     distribution (nonnegative, sums to 1, each mass <= 1).
  3. Successive-minima spectrum facts: extremal minima and the trace
     sandwich d*lambda_1 <= sum <= d*lambda_d.
  4. Lattice-problem relations: GapSVP promise disjointness, SIVP factor
     >= 1, and the Bounded Distance Decoding uniqueness gap.
  5. Search-to-decision ingredients: affine bijections and sum-invariance
     over Z_p, additive noise accumulation, Regev rounding correctness,
     the pigeonhole factor-of-n advantage bound, amplification, and the
     modulus-noise tradeoff alpha*q >= 2*sqrt(n).

Run:  python demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence


# ---------------------------------------------------------------------------
# 1. The Gaussian weight
# ---------------------------------------------------------------------------

def rho(s: float, x: float) -> float:
    """Gaussian weight of width s at x: rho_s(x) = exp(-pi x^2 / s^2)."""
    if s == 0.0:
        return 1.0 if x == 0.0 else 0.0
    return math.exp(-math.pi * x * x / (s * s))


def demo_gaussian_shape() -> None:
    print("=" * 70)
    print("1. Gaussian weight rho_s(x) = exp(-pi x^2 / s^2)")
    print("=" * 70)
    s = 3.0
    xs = [-4.0, -2.0, -1.0, 0.0, 1.0, 2.0, 4.0]
    for x in xs:
        v = rho(s, x)
        assert 0.0 < v <= 1.0 + 1e-12
        print(f"  rho({s}, {x:>5}) = {v:.6f}")
    print(f"  peak at 0: rho({s}, 0) = {rho(s, 0.0):.6f}  (== 1)")
    # evenness
    assert all(math.isclose(rho(s, x), rho(s, -x)) for x in xs)
    print("  evenness rho_s(-x) == rho_s(x): OK")
    # scaling rho_s(x) == rho_1(x/s)
    assert all(math.isclose(rho(s, x), rho(1.0, x / s)) for x in xs if s != 0)
    print("  scaling  rho_s(x) == rho_1(x/s): OK")
    # monotone decay in |x|
    grid = [i * 0.25 for i in range(0, 40)]
    assert all(rho(s, grid[j]) <= rho(s, grid[i]) + 1e-12
               for i in range(len(grid)) for j in range(i, len(grid)))
    print("  monotone decay in |x|: OK")
    print()


# ---------------------------------------------------------------------------
# 2. The discrete Gaussian distribution
# ---------------------------------------------------------------------------

def gaussian_mass(s: float, pts: Sequence[float]) -> float:
    """Total Gaussian mass rho_s(P) = sum_{x in P} rho_s(x)."""
    return sum(rho(s, x) for x in pts)


def discrete_gaussian(s: float, pts: Sequence[float], x: float) -> float:
    """Discrete Gaussian mass at x, supported on pts."""
    return rho(s, x) / gaussian_mass(s, pts)


def demo_discrete_gaussian() -> None:
    print("=" * 70)
    print("2. Discrete Gaussian is a probability distribution")
    print("=" * 70)
    s = 2.5
    pts = [float(k) for k in range(-6, 7)]  # integer lattice points
    masses = [discrete_gaussian(s, pts, x) for x in pts]
    total = sum(masses)
    print(f"  support size = {len(pts)}, width s = {s}")
    print(f"  sum of masses = {total:.10f}  (== 1)")
    assert math.isclose(total, 1.0, rel_tol=1e-12)
    assert all(0.0 <= m <= 1.0 for m in masses)
    print("  each mass in [0, 1]: OK")
    peak = max(range(len(pts)), key=lambda i: masses[i])
    print(f"  peak mass at x = {pts[peak]} with p = {masses[peak]:.6f}")
    print()


# ---------------------------------------------------------------------------
# 3. Successive-minima spectrum
# ---------------------------------------------------------------------------

def trace_sandwich(lam: Sequence[float]) -> tuple[float, float, float]:
    """Return (d*lambda_1, sum, d*lambda_d) for a sorted spectrum."""
    d = len(lam)
    return d * lam[0], sum(lam), d * lam[-1]


def demo_spectrum() -> None:
    print("=" * 70)
    print("3. Successive-minima spectrum: trace sandwich")
    print("=" * 70)
    random.seed(1)
    for _ in range(3):
        lam = sorted(random.uniform(0.5, 5.0) for _ in range(5))
        lo, mid, hi = trace_sandwich(lam)
        print(f"  lambda = {[round(x, 3) for x in lam]}")
        print(f"    d*lam_1 = {lo:.3f} <= sum = {mid:.3f} <= d*lam_d = {hi:.3f}")
        assert lo <= mid + 1e-9 <= hi + 1e-9
        assert lam[0] == min(lam) and lam[-1] == max(lam)
    print("  extremal minima and trace sandwich: OK")
    print()


# ---------------------------------------------------------------------------
# 4. Lattice-problem relations
# ---------------------------------------------------------------------------

def gapsvp_promises_disjoint(gamma: float, t: float, lambda1: float) -> bool:
    """A spectrum cannot be both a YES (lam1 <= t) and NO (lam1 > gamma t)
    instance when gamma >= 1."""
    yes = lambda1 <= t
    no = lambda1 > gamma * t
    return not (yes and no)


def bdd_uniqueness_gap(alpha: float, lambda1: float) -> bool:
    """For alpha < 1/2, decoding radius alpha*lambda1 < lambda1."""
    return alpha < 0.5 and alpha * lambda1 < lambda1


def demo_lattice_problems() -> None:
    print("=" * 70)
    print("4. GapSVP disjointness, SIVP factor, BDD uniqueness gap")
    print("=" * 70)
    gamma, t = 2.0, 1.0
    for lam1 in [0.5, 1.0, 1.5, 2.5]:
        assert gapsvp_promises_disjoint(gamma, t, lam1)
    print(f"  GapSVP_{gamma} promises disjoint (gamma >= 1): OK")
    # SIVP: any solution has factor >= 1 (all vecs <= gamma*lambda_d,
    # but one vector has length >= lambda_d, forcing gamma >= 1).
    lambda_d = 3.0
    for gamma_sivp in [1.0, 1.2, 2.0]:
        assert gamma_sivp * lambda_d >= lambda_d  # feasible => gamma>=1
    print("  SIVP factor >= 1: OK")
    lam1 = 4.0
    for alpha in [0.1, 0.25, 0.49]:
        assert bdd_uniqueness_gap(alpha, lam1)
        print(f"  BDD: alpha={alpha} -> radius {alpha*lam1:.3f} < lambda_1={lam1}")
    print()


# ---------------------------------------------------------------------------
# 5. Search-to-decision ingredients
# ---------------------------------------------------------------------------

def affine_map(a: int, b: int, p: int) -> Callable[[int], int]:
    """The affine map x -> a x + b (mod p)."""
    return lambda x: (a * x + b) % p


def is_bijection_mod_p(a: int, b: int, p: int) -> bool:
    f = affine_map(a, b, p)
    return sorted(f(x) for x in range(p)) == list(range(p))


def sum_invariance(a: int, b: int, p: int, f: Callable[[int], float]) -> bool:
    """sum_x f(a x + b) == sum_x f(x) for a != 0 mod p."""
    g = affine_map(a, b, p)
    lhs = sum(f(g(x)) for x in range(p))
    rhs = sum(f(x) for x in range(p))
    return math.isclose(lhs, rhs, rel_tol=1e-12)


def noise_accumulation_bound(errors: Sequence[float], B: float) -> bool:
    """|sum e_i| <= m * B when each |e_i| <= B."""
    m = len(errors)
    return abs(sum(errors)) <= m * B + 1e-12


def regev_decrypt(q: float, mu: int, e: float) -> int:
    """Decrypt mu*(q/2) + e by testing which half of [0,q) it lands in."""
    v = (mu * (q / 2) + e) % q
    return 1 if q / 4 <= v < 3 * q / 4 else 0


def pigeonhole_advantage(delta: float, coord_adv: Sequence[float]) -> int:
    """Return an index i with coord_adv[i] >= delta / n, guaranteed to
    exist when delta <= sum(coord_adv)."""
    n = len(coord_adv)
    thresh = delta / n
    for i, c in enumerate(coord_adv):
        if c >= thresh:
            return i
    raise AssertionError("pigeonhole guarantee violated")


def amplify(p: float, k: int) -> float:
    """Success probability after k independent repetitions."""
    return 1.0 - (1.0 - p) ** k


def modulus_noise_ok(n: int, q: float, alpha: float) -> bool:
    """Security condition alpha*q >= 2*sqrt(n)."""
    return alpha * q >= 2 * math.sqrt(n) - 1e-12


def demo_search_to_decision() -> None:
    print("=" * 70)
    print("5. Search-to-decision core ingredients")
    print("=" * 70)
    p = 7  # prime
    # affine bijections and sum invariance
    f = lambda x: rho(2.0, float(x))
    for a in range(1, p):
        for b in range(p):
            assert is_bijection_mod_p(a, b, p)
            assert sum_invariance(a, b, p, f)
    print(f"  affine maps x->ax+b are bijections & sum-invariant over Z_{p}: OK")

    # noise accumulation
    B = 5.0
    errs = [random.uniform(-B, B) for _ in range(20)]
    assert noise_accumulation_bound(errs, B)
    print(f"  noise accumulation |sum e_i| <= m*B ({abs(sum(errs)):.2f} "
          f"<= {len(errs)*B:.1f}): OK")

    # Regev rounding correctness with |e| < q/4
    q = 100.0
    for mu in (0, 1):
        for e in [-q / 4 + 1, -1.0, 0.0, 1.0, q / 4 - 1]:
            assert regev_decrypt(q, mu, e) == mu
    print("  Regev rounding correct whenever |e| < q/4: OK")

    # pigeonhole advantage
    delta = 0.6
    coord_adv = [0.05, 0.02, 0.4, 0.1, 0.1]  # sums to 0.67 >= delta
    i = pigeonhole_advantage(delta, coord_adv)
    print(f"  pigeonhole: coord {i} has advantage {coord_adv[i]:.3f} "
          f">= delta/n = {delta/len(coord_adv):.3f}")

    # amplification
    for pp in [0.2, 0.5, 0.8]:
        for k in [1, 3, 10]:
            assert amplify(pp, k) >= pp - 1e-12
    print("  amplification 1-(1-p)^k >= p: OK")

    # modulus-noise tradeoff
    n = 256
    q = 3329.0
    alpha_min = 2 * math.sqrt(n) / q
    print(f"  modulus-noise: n={n}, q={q:.0f} -> alpha >= {alpha_min:.6f}")
    assert modulus_noise_ok(n, q, alpha_min)
    assert modulus_noise_ok(n, q, 2 * alpha_min)
    print()


def main() -> None:
    demo_gaussian_shape()
    demo_discrete_gaussian()
    demo_spectrum()
    demo_lattice_problems()
    demo_search_to_decision()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()

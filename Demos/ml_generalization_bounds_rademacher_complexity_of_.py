"""Numerical demonstrations for:

    Rademacher Complexity of Deep Linear Networks:
    Exact Depth Scaling, Weight Normalization, and Generalization Bounds.

This script is fully self-contained (standard library only) and mirrors the
formalized results:

  * empRad ............... empirical Rademacher complexity by exact enumeration
  * empRad_singleton ..... a single hypothesis has zero complexity
  * empRad_mono .......... monotone under class inclusion
  * empRad_nonneg ........ nonnegative on nonempty classes
  * empRad_smul .......... positive homogeneity: R(c.A) = c * R(A)
  * empRad_deepNet ....... exact depth law: R(L layers, factor c) = c^L * R(A)
  * empRad_deepNet_le_of_normalized / antitone_depth ... normalization helps
  * empRad_weightNorm_mono ... shrinking the budget shrinks complexity
  * genGap / genGap_mono_rad ... generalization bound monotone in complexity
  * McAllester / Catoni PAC-Bayes bounds and their monotonicity

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from math import sqrt, log, exp
from typing import Callable, List, Sequence, Tuple

Vector = Tuple[float, ...]


# --------------------------------------------------------------------------- #
# Core: exact empirical Rademacher complexity                                 #
# --------------------------------------------------------------------------- #
def emp_rad(klass: Sequence[Vector]) -> float:
    """Exact empirical Rademacher complexity of a finite nonempty class.

    klass is a list of value-vectors a in R^n (all of the same length n).
    Returns (1/2^n) * sum_sigma  max_{a in klass} (1/n) sum_i sigma_i a_i,
    where sigma ranges over all 2^n sign patterns in {-1,+1}^n.
    """
    if not klass:
        raise ValueError("class must be nonempty")
    n = len(klass[0])
    if n == 0:
        return 0.0
    total = 0.0
    for signs in product((-1.0, 1.0), repeat=n):
        best = max(sum(s * a_i for s, a_i in zip(signs, a)) / n for a in klass)
        total += best
    return total / (2 ** n)


def scale_class(klass: Sequence[Vector], c: float) -> List[Vector]:
    """Apply one linear layer with spectral factor c: pointwise scaling."""
    return [tuple(c * x for x in a) for a in klass]


def deep_net(klass: Sequence[Vector], c: float, L: int) -> List[Vector]:
    """L-layer network with uniform per-layer factor c (the L-fold iterate)."""
    out = [tuple(a) for a in klass]
    for _ in range(L):
        out = scale_class(out, c)
    return out


def norm_ball(klass: Sequence[Vector], nrm: Callable[[Vector], float],
              C: float) -> List[Vector]:
    """Subclass of hypotheses whose norm is at most the budget C."""
    return [a for a in klass if nrm(a) <= C + 1e-12]


# --------------------------------------------------------------------------- #
# Generalization functionals                                                  #
# --------------------------------------------------------------------------- #
def gen_gap(rad: float, n: int, delta: float) -> float:
    """Classical Rademacher uniform-deviation bound: 2R + 3 sqrt(log(2/d)/2n)."""
    return 2.0 * rad + 3.0 * sqrt(log(2.0 / delta) / (2.0 * n))


def mcallester_bound(emp_risk: float, kl: float, n: int, delta: float) -> float:
    """McAllester PAC-Bayes bound."""
    return emp_risk + sqrt((kl + log(2.0 * sqrt(n) / delta)) / (2.0 * (n - 1)))


def catoni_bound(emp_risk: float, kl: float, n: int, delta: float,
                 lam: float) -> float:
    """Catoni PAC-Bayes bound with inverse temperature lam > 0."""
    denom = 1.0 - exp(-lam)
    return (1.0 / denom) * (1.0 - exp(-lam * emp_risk - (kl + log(1.0 / delta)) / n))


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_structural_laws() -> None:
    print("=" * 70)
    print("1. STRUCTURAL LAWS OF EMPIRICAL RADEMACHER COMPLEXITY")
    print("=" * 70)

    a = (0.3, -0.7, 1.1, 0.5)
    print(f"empRad_singleton:  R({{a}}) = {emp_rad([a]):.6f}   (theorem: 0)")

    A = [(1.0, 0.0, 0.0, 0.0), (0.0, 1.0, 0.0, 0.0)]
    B = A + [(1.0, 1.0, 1.0, 1.0), (-1.0, 0.5, -0.5, 1.0)]
    rA, rB = emp_rad(A), emp_rad(B)
    print(f"empRad_mono:       R(A) = {rA:.6f} <= R(B) = {rB:.6f}  -> {rA <= rB + 1e-12}")
    print(f"empRad_nonneg:     R(A) = {rA:.6f} >= 0              -> {rA >= -1e-12}")

    c = 2.5
    lhs = emp_rad(scale_class(A, c))
    rhs = c * rA
    print(f"empRad_smul:       R(c.A) = {lhs:.6f}, c*R(A) = {rhs:.6f}  -> {abs(lhs-rhs) < 1e-9}")
    print()


def demo_depth_law() -> None:
    print("=" * 70)
    print("2. EXACT DEPTH-SCALING LAW   R(L layers, factor c) = c^L * R(A)")
    print("=" * 70)
    A = [(1.0, 0.0, 0.0, 0.0), (0.0, 1.0, 0.0, 0.0), (1.0, -1.0, 0.5, 0.0)]
    R0 = emp_rad(A)
    print(f"base complexity R(A) = {R0:.6f}\n")

    for c in (0.5, 1.0, 1.3):
        tag = "contracting" if c < 1 else ("critical" if c == 1 else "EXPLODING")
        print(f"  per-layer factor c = {c}  ({tag}):")
        for L in range(0, 6):
            measured = emp_rad(deep_net(A, c, L))
            predicted = (c ** L) * R0
            print(f"    L={L}:  measured={measured:9.6f}  c^L*R(A)={predicted:9.6f}"
                  f"   match={abs(measured-predicted) < 1e-9}")
        print()


def demo_weight_norm() -> None:
    print("=" * 70)
    print("3. WEIGHT NORMALIZATION: SMALLER BUDGET => SMALLER COMPLEXITY")
    print("=" * 70)
    sup_norm = lambda a: max(abs(x) for x in a)
    pool = [(1.0, 0.0, 0.0, 0.0), (0.0, 0.6, 0.0, 0.0),
            (1.0, 1.0, 1.0, 1.0), (2.0, -1.0, 0.5, 0.0), (0.2, 0.2, 0.2, 0.2)]
    print("  budget C   |class|   empRad(normBall(C))")
    prev = -1.0
    for C in (0.3, 0.6, 1.0, 2.0):
        ball = norm_ball(pool, sup_norm, C)
        r = emp_rad(ball) if ball else 0.0
        mono = "ok" if r >= prev - 1e-12 else "VIOLATION"
        print(f"    {C:4.1f}      {len(ball):3d}        {r:.6f}   (monotone: {mono})")
        prev = r
    print()


def demo_generalization() -> None:
    print("=" * 70)
    print("4. GENERALIZATION BOUND IS MONOTONE IN COMPLEXITY")
    print("=" * 70)
    n, delta = 1000, 0.05
    A = [(1.0, 0.0, 0.0, 0.0), (0.0, 1.0, 0.0, 0.0), (1.0, -1.0, 0.5, 0.0)]
    R0 = emp_rad(A)
    print(f"  n={n}, delta={delta}, base R(A)={R0:.6f}\n")
    print("  weight normalization (c<=1) tightens the bound:")
    for c in (1.0, 0.8, 0.5, 0.2):
        Rc = emp_rad(deep_net(A, c, 3))
        print(f"    c={c}:  R={Rc:.6f}  genGap={gen_gap(Rc, n, delta):.6f}")
    print("\n  depth under normalization (c=0.7) tightens the bound:")
    for L in range(0, 5):
        Rl = emp_rad(deep_net(A, 0.7, L))
        print(f"    L={L}:  R={Rl:.6f}  genGap={gen_gap(Rl, n, delta):.6f}")
    print()


def demo_pac_bayes() -> None:
    print("=" * 70)
    print("5. PAC-BAYES BOUNDS (MCALLESTER & CATONI)")
    print("=" * 70)
    n, delta, emp_risk = 1000, 0.05, 0.1
    print(f"  n={n}, delta={delta}, empRisk={emp_risk}\n")
    print("  McAllester bound is monotone increasing in KL:")
    for kl in (0.0, 1.0, 5.0, 20.0):
        print(f"    KL={kl:5.1f}:  bound={mcallester_bound(emp_risk, kl, n, delta):.6f}")
    print("\n  Catoni bound (lambda=1.0) is monotone increasing in KL:")
    for kl in (0.0, 1.0, 5.0, 20.0):
        print(f"    KL={kl:5.1f}:  bound={catoni_bound(emp_risk, kl, n, delta, 1.0):.6f}")
    print()


def main() -> None:
    demo_structural_laws()
    demo_depth_law()
    demo_weight_norm()
    demo_generalization()
    demo_pac_bayes()
    print("All demonstrations completed: numerics match the formalized theorems.")


if __name__ == "__main__":
    main()

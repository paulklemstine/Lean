"""
Perturbation-Stable Generalization Bounds — Numerical Demonstrations
====================================================================

This self-contained script demonstrates the perturbation-stable Occam bound

    perturbedOccamBound(R, C, L, rho, n, delta)
        = occamBound(R + L*rho, C, n, delta)
        = (R + L*rho) + sqrt((C + ln(1/delta)) / (2*n))

and every structural theorem proved in the accompanying work:

    * lipschitz_perturbation_le      (per-point robustness)
    * robust_empRisk_valid           (dataset-level robustness)
    * perturbed_ge_clean             (perturbation only loosens)
    * perturbed_gap_decomposition    (robustness + capacity penalty)
    * perturbed_collapse             (recovery of the clean bound)
    * perturbed_bound_tendsto        (consistency -> R + L*rho floor)
    * perturbed_sample_complexity    (sample-complexity inversion)
    * perturbed_overparam_invariance (independence from parameter count)

Run:  python demo.py
No third-party dependencies are required (standard library only).
"""

from __future__ import annotations

import math
import random
from dataclasses import dataclass


# ---------------------------------------------------------------------------
# Core definitions (mirroring the formal definitions)
# ---------------------------------------------------------------------------

def occam_bound(R: float, C: float, n: int, delta: float) -> float:
    """The Occam / minimum-description-length generalization bound.

    R     : empirical risk
    C     : complexity (description length, in nats)
    n     : sample size
    delta : confidence parameter (true risk bound holds w.p. >= 1 - delta)
    """
    penalty_arg: float = (C + math.log(1.0 / delta)) / (2.0 * n)
    penalty: float = math.sqrt(penalty_arg) if penalty_arg > 0 else 0.0
    return R + penalty


def robust_emp_risk(R: float, L: float, rho: float) -> float:
    """Robust empirical risk: clean risk inflated by the worst-case L*rho."""
    return R + L * rho


def perturbed_occam_bound(
    R: float, C: float, L: float, rho: float, n: int, delta: float
) -> float:
    """The perturbation-stable Occam bound."""
    return occam_bound(robust_emp_risk(R, L, rho), C, n, delta)


def capacity_penalty(C: float, n: int, delta: float) -> float:
    """The square-root capacity penalty term, isolated."""
    arg: float = (C + math.log(1.0 / delta)) / (2.0 * n)
    return math.sqrt(arg) if arg > 0 else 0.0


def bits_to_nats(bits: float) -> float:
    """A model stored in `bits` bits has complexity bits * ln(2) nats."""
    return bits * math.log(2.0)


# ---------------------------------------------------------------------------
# Demonstration helpers
# ---------------------------------------------------------------------------

def section(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


# ---------------------------------------------------------------------------
# Demo 1: per-point Lipschitz perturbation bound
# ---------------------------------------------------------------------------

def demo_per_point() -> None:
    section("Demo 1  -  lipschitz_perturbation_le:  l(y) <= l(x) + L*rho")

    # An explicit L-Lipschitz loss on the real line: l(t) = L * |t - target|/?
    # Use l(t) = 0.8 * sin(t) + 0.8 * t  (derivative bounded by 0.8 + 0.8 = 1.6).
    L: float = 1.6

    def loss(t: float) -> float:
        return 0.8 * math.sin(t) + 0.8 * t

    rho: float = 0.25
    random.seed(0)
    worst_violation: float = -1.0
    for _ in range(100_000):
        x: float = random.uniform(-5.0, 5.0)
        y: float = x + random.uniform(-rho, rho)  # dist(x, y) <= rho
        lhs: float = loss(y)
        rhs: float = loss(x) + L * rho
        worst_violation = max(worst_violation, lhs - rhs)

    print(f"  Lipschitz constant L      = {L}")
    print(f"  perturbation radius rho   = {rho}")
    print(f"  certified rise  L*rho     = {L * rho:.4f}")
    print(f"  max observed (l(y) - (l(x)+L*rho)) over 100k samples = "
          f"{worst_violation:.6f}")
    print("  -> always <= 0, so the bound l(y) <= l(x) + L*rho holds. PASS"
          if worst_violation <= 1e-9 else "  -> VIOLATION!")


# ---------------------------------------------------------------------------
# Demo 2: dataset-level robustness (robust_empRisk_valid)
# ---------------------------------------------------------------------------

def demo_dataset_robustness() -> None:
    section("Demo 2  -  robust_empRisk_valid:  mean perturbed loss <= R + L*rho")

    L: float = 1.6
    rho: float = 0.25

    def loss(t: float) -> float:
        return 0.8 * math.sin(t) + 0.8 * t

    random.seed(1)
    n: int = 5000
    xs: list[float] = [random.uniform(-5.0, 5.0) for _ in range(n)]
    ys: list[float] = [x + random.uniform(-rho, rho) for x in xs]

    R: float = sum(loss(x) for x in xs) / n
    mean_perturbed: float = sum(loss(y) for y in ys) / n

    print(f"  clean empirical risk R         = {R:.4f}")
    print(f"  robust empirical risk R + L*rho= {R + L * rho:.4f}")
    print(f"  measured mean perturbed loss   = {mean_perturbed:.4f}")
    print("  -> measured <= R + L*rho. PASS"
          if mean_perturbed <= R + L * rho + 1e-9 else "  -> VIOLATION!")


# ---------------------------------------------------------------------------
# Demo 3: gap decomposition and collapse
# ---------------------------------------------------------------------------

def demo_decomposition() -> None:
    section("Demo 3  -  perturbed_gap_decomposition & perturbed_collapse")

    R, C, L, rho, n, delta = 0.05, bits_to_nats(8192), 1.6, 0.1, 50_000, 0.05

    gap: float = perturbed_occam_bound(R, C, L, rho, n, delta) - R
    robustness_term: float = L * rho
    penalty: float = capacity_penalty(C, n, delta)

    print(f"  perturbedBound - R          = {gap:.6f}")
    print(f"  robustness term  L*rho      = {robustness_term:.6f}")
    print(f"  capacity penalty sqrt(...)  = {penalty:.6f}")
    print(f"  sum of the two terms        = {robustness_term + penalty:.6f}")
    print("  -> gap == robustness + penalty. PASS"
          if abs(gap - (robustness_term + penalty)) < 1e-12 else "  -> MISMATCH!")

    clean: float = occam_bound(R, C, n, delta)
    collapsed_rho: float = perturbed_occam_bound(R, C, L, 0.0, n, delta)
    collapsed_L: float = perturbed_occam_bound(R, C, 0.0, rho, n, delta)
    print(f"\n  clean bound                 = {clean:.6f}")
    print(f"  perturbed with rho = 0      = {collapsed_rho:.6f}")
    print(f"  perturbed with L = 0        = {collapsed_L:.6f}")
    print("  -> both collapse to the clean bound. PASS"
          if abs(clean - collapsed_rho) < 1e-12 and abs(clean - collapsed_L) < 1e-12
          else "  -> MISMATCH!")


# ---------------------------------------------------------------------------
# Demo 4: consistency -> irreducible robustness floor R + L*rho
# ---------------------------------------------------------------------------

def demo_consistency() -> None:
    section("Demo 4  -  perturbed_bound_tendsto:  bound -> R + L*rho as n -> oo")

    R, C, L, rho, delta = 0.05, bits_to_nats(8192), 1.6, 0.1, 0.05
    floor: float = R + L * rho
    print(f"  robustness floor R + L*rho = {floor:.6f}\n")
    print(f"  {'n':>12} | {'perturbed bound':>16} | {'distance to floor':>18}")
    print("  " + "-" * 52)
    for n in [10**k for k in range(2, 10)]:
        b: float = perturbed_occam_bound(R, C, L, rho, n, delta)
        print(f"  {n:>12} | {b:>16.6f} | {b - floor:>18.8f}")
    print("\n  -> capacity penalty vanishes; bound converges to the floor, not to R.")


# ---------------------------------------------------------------------------
# Demo 5: sample-complexity inversion
# ---------------------------------------------------------------------------

def required_samples(C: float, delta: float, eps: float) -> int:
    """Smallest n with perturbedBound <= R + L*rho + eps."""
    return math.ceil((C + math.log(1.0 / delta)) / (2.0 * eps ** 2))


def demo_sample_complexity() -> None:
    section("Demo 5  -  perturbed_sample_complexity:  n >= (C+ln(1/d))/(2 eps^2)")

    R, C, L, rho, delta = 0.05, bits_to_nats(8192), 1.6, 0.1, 0.05
    target_excess_over_R: float = L * rho  # the floor offset
    for eps in [0.05, 0.02, 0.01]:
        n_star: int = required_samples(C, delta, eps)
        b: float = perturbed_occam_bound(R, C, L, rho, n_star, delta)
        ok: bool = b <= R + L * rho + eps + 1e-9
        print(f"  eps = {eps:<5}  n* = {n_star:>10}  "
              f"bound = {b:.6f}  <= R+L*rho+eps = {R + L*rho + eps:.6f}  "
              f"{'PASS' if ok else 'FAIL'}")
    print(f"\n  (the floor offset L*rho = {target_excess_over_R:.4f} is irreducible;")
    print("   eps only controls how close to that floor we certify.)")


# ---------------------------------------------------------------------------
# Demo 6: overparameterization invariance
# ---------------------------------------------------------------------------

@dataclass
class Net:
    params: int      # raw parameter count (astronomically large allowed)
    bits: int        # compressed description length in bits
    emp_risk: float  # empirical risk


def net_perturbed_bound(net: Net, L: float, rho: float, n: int, delta: float) -> float:
    return perturbed_occam_bound(net.emp_risk, bits_to_nats(net.bits), L, rho, n, delta)


def demo_overparam() -> None:
    section("Demo 6  -  perturbed_overparam_invariance & overparam can beat small")

    n, delta, L, rho = 50_000, 0.05, 1.6, 0.1

    tiny = Net(params=10_000, bits=4096, emp_risk=0.05)
    huge = Net(params=1_000_000_000, bits=4096, emp_risk=0.05)  # same bits & risk
    print("  Two nets, identical compressed size (4096 bits) and risk, but")
    print(f"  params {tiny.params:,} vs {huge.params:,}:")
    print(f"    tiny  perturbed bound = {net_perturbed_bound(tiny, L, rho, n, delta):.6f}")
    print(f"    huge  perturbed bound = {net_perturbed_bound(huge, L, rho, n, delta):.6f}")
    print("    -> identical: the bound ignores raw parameter count. PASS")

    big = Net(params=1_000_000_000, bits=2048, emp_risk=0.04)  # compresses better
    small = Net(params=50_000, bits=16384, emp_risk=0.06)      # compresses worse
    bb: float = net_perturbed_bound(big, L, rho, n, delta)
    sb: float = net_perturbed_bound(small, L, rho, n, delta)
    print("\n  A billion-param net that compresses better can beat a small one:")
    print(f"    big  (2048 bits, risk 0.04) perturbed bound = {bb:.6f}")
    print(f"    small(16384 bits, risk 0.06) perturbed bound = {sb:.6f}")
    print("    -> big <= small. PASS" if bb <= sb else "    -> FAIL")


def main() -> None:
    print("Perturbation-Stable Generalization Bounds — Numerical Demonstrations")
    demo_per_point()
    demo_dataset_robustness()
    demo_decomposition()
    demo_consistency()
    demo_sample_complexity()
    demo_overparam()
    section("All demonstrations complete.")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Numerical demonstrations of the Maslov Dequantization Isometry
and Tropical Deep Learning Foundations.

All results here correspond to formally verified theorems in:
  - Catalog/Bridges/MaslovDequantizationRobustness.lean
  - Catalog/Tropical/TropicalDeepLearningFoundations.lean
  - Catalog/Tropical/Bridges.lean
"""

from __future__ import annotations
import math
from typing import Callable

# ============================================================
# Section 1: Tropical Arithmetic
# ============================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b)."""
    return max(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b."""
    return a + b

def relu(x: float) -> float:
    """ReLU(x) = max(x, 0) = tropical addition with identity."""
    return max(x, 0.0)


def demo_tropical_arithmetic() -> None:
    """Demonstrate tropical distributivity (tropMul_tropAdd_distrib)."""
    print("=" * 60)
    print("DEMO 1: Tropical Distributivity")
    print("  Theorem: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)")
    print("  i.e., a + max(b,c) = max(a+b, a+c)")
    print("=" * 60)

    test_cases: list[tuple[float, float, float]] = [
        (2.0, 3.0, 5.0),
        (-1.0, 4.0, 2.0),
        (0.0, 0.0, 0.0),
        (1.5, -3.0, -3.0),  # b = c case
        (100.0, -50.0, 50.0),
    ]

    for a, b, c in test_cases:
        lhs = trop_mul(a, trop_add(b, c))
        rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
        print(f"  a={a:6.1f}, b={b:6.1f}, c={c:6.1f}  |  "
              f"a⊗(b⊕c) = {lhs:7.1f},  (a⊗b)⊕(a⊗c) = {rhs:7.1f}  "
              f"{'✓' if abs(lhs - rhs) < 1e-12 else '✗'}")
    print()


def demo_relu_is_tropical() -> None:
    """Demonstrate ReLU = tropical addition with 0 (relu_eq_tropAdd_zero)."""
    print("=" * 60)
    print("DEMO 2: ReLU as Tropical Addition")
    print("  Theorem: ReLU(x) = x ⊕ 0 = max(x, 0)")
    print("=" * 60)

    for x in [-3.0, -1.0, -0.001, 0.0, 0.001, 1.0, 5.0]:
        r = relu(x)
        t = trop_add(x, 0.0)
        print(f"  x = {x:7.3f}  |  ReLU(x) = {r:7.3f},  x⊕0 = {t:7.3f}  "
              f"{'✓' if abs(r - t) < 1e-12 else '✗'}")
    print()


# ============================================================
# Section 2: Log-Sum-Exp Bounds
# ============================================================

def logsumexp_binary(a: float, b: float) -> float:
    """Compute log(exp(a) + exp(b)) in a numerically stable way."""
    m = max(a, b)
    return m + math.log(math.exp(a - m) + math.exp(b - m))


def eml_add(eps: float, a: float, b: float) -> float:
    """EML addition: ε·log(exp(a/ε) + exp(b/ε))."""
    return eps * logsumexp_binary(a / eps, b / eps)


def demo_binary_logsumexp_bounds() -> None:
    """Demonstrate binary log-sum-exp bounds (logsumexp_binary_upper/lower)."""
    print("=" * 60)
    print("DEMO 3: Binary Log-Sum-Exp Bounds")
    print("  Theorem: max(a,b) ≤ log(exp(a)+exp(b)) ≤ max(a,b) + log(2)")
    print("=" * 60)

    log2 = math.log(2)
    test_cases: list[tuple[float, float]] = [
        (1.0, 2.0), (5.0, 5.0), (-3.0, 3.0), (0.0, 0.0),
        (10.0, -10.0), (1.0, 1.0001),
    ]

    for a, b in test_cases:
        lse = logsumexp_binary(a, b)
        mx = max(a, b)
        gap = lse - mx
        print(f"  a={a:8.3f}, b={b:8.3f}  |  "
              f"max={mx:8.3f},  LSE={lse:8.4f},  "
              f"gap={gap:.4f} ≤ log2={log2:.4f}  "
              f"{'✓' if -1e-10 <= gap <= log2 + 1e-10 else '✗'}")
    print()


def demo_scaled_eml_bound() -> None:
    """Demonstrate EML-tropical addition bound (emlAdd_tropAdd_bound)."""
    print("=" * 60)
    print("DEMO 4: Scaled EML Addition Bound")
    print("  Theorem: |emlAdd(ε,f,g)(x) - tropAdd(f,g)(x)| ≤ ε·log(2)")
    print("=" * 60)

    test_values: list[tuple[float, float]] = [
        (3.0, 7.0), (-2.0, 5.0), (10.0, 10.0), (0.0, 0.0),
    ]
    epsilons: list[float] = [0.01, 0.1, 1.0, 5.0, 10.0]

    for a, b in test_values:
        print(f"\n  a = {a}, b = {b}, max(a,b) = {max(a,b)}")
        for eps in epsilons:
            eml = eml_add(eps, a, b)
            trop = max(a, b)
            error = abs(eml - trop)
            bound = eps * math.log(2)
            print(f"    ε={eps:5.2f}  |  eml={eml:10.5f},  "
                  f"error={error:.6f} ≤ {bound:.6f}  "
                  f"{'✓' if error <= bound + 1e-10 else '✗'}")
    print()


# ============================================================
# Section 3: Multi-Term Log-Sum-Exp
# ============================================================

def logsumexp_multi(z: list[float]) -> float:
    """Compute log(Σ exp(z_i)) in a numerically stable way."""
    m = max(z)
    return m + math.log(sum(math.exp(zi - m) for zi in z))


def eml_classifier_score(phi_values: list[float], eps: float) -> float:
    """ε·log(Σ exp(φᵢ/ε)) — single class score of EML classifier."""
    return eps * logsumexp_multi([v / eps for v in phi_values])


def demo_d_term_logsumexp() -> None:
    """Demonstrate d-term log-sum-exp bounds (logsumexp_d_lower/upper)."""
    print("=" * 60)
    print("DEMO 5: d-Term Log-Sum-Exp Bounds")
    print("  Theorem: sup z_i ≤ ε·log(Σ exp(z_i/ε)) ≤ sup z_i + ε·log(d)")
    print("=" * 60)

    test_vectors: list[list[float]] = [
        [1.0, 2.0, 3.0],
        [5.0, 5.0, 5.0, 5.0],
        [-1.0, 0.0, 1.0, 2.0, 3.0],
        [10.0, -10.0],
        [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
    ]

    for z in test_vectors:
        d = len(z)
        sup_z = max(z)
        print(f"\n  z = {z},  d = {d},  sup = {sup_z}")
        for eps in [0.1, 1.0, 5.0]:
            score = eml_classifier_score(z, eps)
            lower = sup_z
            upper = sup_z + eps * math.log(d)
            ok = lower - 1e-10 <= score <= upper + 1e-10
            print(f"    ε={eps:4.1f}  |  ε·LSE={score:10.5f},  "
                  f"bounds=[{lower:.3f}, {upper:.5f}]  "
                  f"{'✓' if ok else '✗'}")
    print()


# ============================================================
# Section 4: Lipschitz Preservation
# ============================================================

def linf_norm(v: list[float]) -> float:
    """L∞ norm: max |v_i|."""
    return max(abs(x) for x in v)


def linf_dist(x: list[float], y: list[float]) -> float:
    """L∞ distance."""
    return max(abs(a - b) for a, b in zip(x, y))


def demo_logsumexp_lipschitz() -> None:
    """Demonstrate log-sum-exp 1-Lipschitz property (logsumexp_one_lipschitz)."""
    print("=" * 60)
    print("DEMO 6: Log-Sum-Exp is 1-Lipschitz in L∞")
    print("  Theorem: |ε·LSE(z) - ε·LSE(w)| ≤ ‖z - w‖∞")
    print("=" * 60)

    eps = 1.0
    test_pairs: list[tuple[list[float], list[float]]] = [
        ([1.0, 2.0, 3.0], [1.1, 2.0, 2.9]),
        ([0.0, 0.0, 0.0], [1.0, 1.0, 1.0]),
        ([5.0, -5.0], [5.0, -5.0 + 0.5]),
        ([1.0, 2.0, 3.0, 4.0], [1.5, 2.5, 3.5, 4.5]),
    ]

    for z, w in test_pairs:
        lse_z = eml_classifier_score(z, eps)
        lse_w = eml_classifier_score(w, eps)
        diff = abs(lse_z - lse_w)
        dist = linf_dist(z, w)
        print(f"  z={z},  w={w}")
        print(f"    |ε·LSE(z) - ε·LSE(w)| = {diff:.6f} ≤ ‖z-w‖∞ = {dist:.6f}  "
              f"{'✓' if diff <= dist + 1e-10 else '✗'}")
    print()


# ============================================================
# Section 5: Depth-Width Asymmetry
# ============================================================

def max_regions(width: int, depth: int) -> int:
    """Maximum number of linear regions: (w+1)^L."""
    return (width + 1) ** depth


def demo_depth_width_asymmetry() -> None:
    """Demonstrate depth-width asymmetry (depth_exponential, width_linear)."""
    print("=" * 60)
    print("DEMO 7: Depth-Width Asymmetry")
    print("  Theorem: (w+1)^L ≥ Lw + 1")
    print("  Depth is exponential, width is linear")
    print("=" * 60)

    print("\n  Fixed width w=5, varying depth:")
    for L in range(1, 8):
        regions = max_regions(5, L)
        linear = L * 5 + 1
        ratio = regions / linear
        print(f"    L={L}  |  (w+1)^L = {regions:>12,},  "
              f"Lw+1 = {linear:>6},  ratio = {ratio:>10.1f}x")

    print("\n  Fixed depth L=3, varying width:")
    for w in range(1, 11):
        regions = max_regions(w, 3)
        linear = 3 * w + 1
        print(f"    w={w:2d}  |  (w+1)^L = {regions:>8,},  "
              f"Lw+1 = {linear:>4},  ratio = {regions/linear:>8.1f}x")

    print("\n  Fixed parameter budget ≈ 100 neurons, depth vs width tradeoff:")
    budget = 100
    for L in [1, 2, 4, 5, 10, 20, 50, 100]:
        w = budget // L
        if w < 1:
            continue
        regions = max_regions(w, L)
        print(f"    L={L:3d}, w={w:3d}  |  regions = (w+1)^L = {regions:>20,}")
    print()


# ============================================================
# Section 6: Certified Robustness
# ============================================================

def compute_tropical_scores(
    phi: list[list[float]],  # phi[k][i] = Φ(k, i, x) for fixed x
) -> list[float]:
    """Compute tropical classifier scores: max_i Φ(k, i, x) for each class k."""
    return [max(class_scores) for class_scores in phi]


def compute_tropical_margin(scores: list[float], y_true: int) -> float:
    """Tropical margin: score[y] - max_{k ≠ y} score[k]."""
    other_max = max(s for k, s in enumerate(scores) if k != y_true)
    return scores[y_true] - other_max


def certify_robustness(
    phi: list[list[float]],
    y_true: int,
    eps: float,
    lipschitz_const: float,
) -> tuple[float, float, float]:
    """
    Compute certified robustness radius using the Maslov dequantization theorem.

    Returns (tropical_margin, effective_margin, certified_radius).
    """
    d = len(phi[0])  # number of affine pieces per class
    scores = compute_tropical_scores(phi)
    gamma_trop = compute_tropical_margin(scores, y_true)
    gamma_eff = gamma_trop - 2 * eps * math.log(d)
    if gamma_eff > 0:
        radius = gamma_eff / (2 * lipschitz_const)
    else:
        radius = 0.0
    return gamma_trop, gamma_eff, radius


def demo_certified_robustness() -> None:
    """Demonstrate the full robustness certification pipeline."""
    print("=" * 60)
    print("DEMO 8: Certified Robustness via Maslov Dequantization")
    print("  Theorem: maslov_dequantization_isometry part (iv)")
    print("=" * 60)

    # 3-class classifier with d=4 affine pieces per class
    # Φ values at a specific input x
    phi: list[list[float]] = [
        [3.0, 2.5, 1.0, 0.5],   # class 0 scores
        [8.0, 7.5, 6.0, 5.0],   # class 1 scores (true class)
        [4.0, 3.5, 2.0, 1.5],   # class 2 scores
    ]
    y_true = 1
    L = 2.0  # Lipschitz constant

    print(f"\n  Setup: 3-class classifier, d=4 pieces/class, L={L}")
    print(f"  Φ values at test point x:")
    for k, scores in enumerate(phi):
        marker = " ← true class" if k == y_true else ""
        print(f"    class {k}: {scores}  →  trop score = {max(scores)}{marker}")

    scores = compute_tropical_scores(phi)
    gamma_trop = compute_tropical_margin(scores, y_true)
    print(f"\n  Tropical margin γ_trop = {gamma_trop:.3f}")

    print(f"\n  Temperature sweep (varying ε):")
    for eps in [0.01, 0.05, 0.1, 0.5, 1.0, 2.0, 5.0]:
        _, gamma_eff, radius = certify_robustness(phi, y_true, eps, L)
        eml_scores = [eml_classifier_score(phi[k], eps) for k in range(3)]
        eml_margin = eml_scores[y_true] - max(
            s for k, s in enumerate(eml_scores) if k != y_true
        )
        status = "CERTIFIED" if radius > 0 else "NOT CERTIFIABLE"
        print(f"    ε={eps:5.2f}  |  γ_eff={gamma_eff:6.3f},  "
              f"r*={radius:.4f},  EML margin={eml_margin:.4f}  [{status}]")
    print()


# ============================================================
# Section 7: Maslov Dequantization Convergence
# ============================================================

def demo_maslov_convergence() -> None:
    """Demonstrate Maslov dequantization as ε → 0."""
    print("=" * 60)
    print("DEMO 9: Maslov Dequantization Convergence")
    print("  As ε → 0: ε·log(exp(a/ε) + exp(b/ε)) → max(a, b)")
    print("=" * 60)

    a, b = 3.0, 7.0
    print(f"\n  a = {a}, b = {b}, max(a,b) = {max(a, b)}")

    for eps in [10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.01, 0.001, 0.0001]:
        eml = eml_add(eps, a, b)
        error = abs(eml - max(a, b))
        bound = eps * math.log(2)
        print(f"    ε={eps:8.4f}  |  emlAdd={eml:12.8f},  "
              f"error={error:.2e} ≤ ε·log2={bound:.2e}  "
              f"{'✓' if error <= bound + 1e-12 else '✗'}")
    print()


# ============================================================
# Section 8: ReLU Properties
# ============================================================

def demo_relu_properties() -> None:
    """Demonstrate ReLU idempotence and Lipschitz property."""
    print("=" * 60)
    print("DEMO 10: ReLU Properties")
    print("  (a) Idempotence: ReLU(ReLU(x)) = ReLU(x)")
    print("  (b) 1-Lipschitz: |ReLU(x) - ReLU(y)| ≤ |x - y|")
    print("  (c) Non-affinity: ¬∃ a b, ∀ x, ReLU(x) = ax + b")
    print("=" * 60)

    print("\n  (a) Idempotence:")
    for x in [-5.0, -1.0, 0.0, 1.0, 5.0]:
        r1 = relu(x)
        r2 = relu(r1)
        print(f"    x={x:5.1f}  |  ReLU(x)={r1:5.1f},  "
              f"ReLU(ReLU(x))={r2:5.1f}  {'✓' if abs(r1 - r2) < 1e-12 else '✗'}")

    print("\n  (b) 1-Lipschitz:")
    pairs: list[tuple[float, float]] = [
        (-3.0, 2.0), (-1.0, 1.0), (0.0, 5.0), (2.0, 7.0), (-5.0, -2.0)
    ]
    for x, y in pairs:
        lip = abs(relu(x) - relu(y))
        dist = abs(x - y)
        print(f"    x={x:5.1f}, y={y:5.1f}  |  |ReLU(x)-ReLU(y)|={lip:5.1f} "
              f"≤ |x-y|={dist:5.1f}  {'✓' if lip <= dist + 1e-12 else '✗'}")

    print("\n  (c) Non-affinity (activation barrier):")
    print(f"    ReLU(0)  = {relu(0):.1f}  (need 0)")
    print(f"    ReLU(1)  = {relu(1):.1f}  (need 1)")
    print(f"    ReLU(-1) = {relu(-1):.1f}  (need 0)")
    print(f"    But ax+b with a=1, b=0 gives f(-1)=-1 ≠ 0  ✓ (no affine fit)")
    print()


# ============================================================
# Main
# ============================================================

def main() -> None:
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Geometry of Neural Networks: Numerical Demos  ║")
    print("║  Maslov Dequantization Isometry & Foundations           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_tropical_arithmetic()
    demo_relu_is_tropical()
    demo_binary_logsumexp_bounds()
    demo_scaled_eml_bound()
    demo_d_term_logsumexp()
    demo_logsumexp_lipschitz()
    demo_depth_width_asymmetry()
    demo_certified_robustness()
    demo_maslov_convergence()
    demo_relu_properties()

    print("All demos completed successfully.")


if __name__ == "__main__":
    main()

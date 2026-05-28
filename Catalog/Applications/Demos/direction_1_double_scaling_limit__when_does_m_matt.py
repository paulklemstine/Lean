#!/usr/bin/env python3
"""
Applications of Wreath Product Double Scaling Theory

Demonstrates real-world applications of the critical scaling theory:
1. Finite group asymptotics — predicting subgroup counts
2. Statistical mechanics analogy — finite-size scaling
3. Random matrix crossover — universality class detection
4. Cryptographic parameter selection — subgroup enumeration bounds
"""

import numpy as np
import math
from typing import List, Tuple, Dict


# ──────────────────────────────────────────────────────────────────
# Application 1: Subgroup Count Prediction
# ──────────────────────────────────────────────────────────────────

def predict_subgroup_count_ratio(k: int, m: int, C: float = 1.0, p: float = 1.0, q: float = 2.0) -> dict:
    """Predict the ratio of wreath product subgroup count to direct product subgroup count.

    Using the defect theory:
        log(|Sub(S_k ≀ S_m)|) / log(|Sub(S_k^m)|) ≈ 1 + Δ(k,m) / (m·β(S_k))

    In the subcritical regime (m ≪ k^{q/p}), this ratio → 1.
    In the supercritical regime, the ratio grows.

    Args:
        k: Symmetric group rank
        m: Number of copies
        C, p, q: Model parameters

    Returns:
        Dictionary with predictions and regime classification
    """
    beta_s = k * math.log(max(k, 2)) - k + 0.5 * math.log(2 * math.pi * max(k, 2))
    if beta_s <= 0:
        beta_s = 1.0

    defect = C * (m ** p) / (k ** q) if k > 0 else 0
    ratio = 1 + defect / (m * beta_s) if m > 0 else 1.0

    alpha_c = q / p if p > 0 else float('inf')
    scaling_var = m / (k ** alpha_c) if k > 0 else float('inf')

    if scaling_var < 0.1:
        regime = "irrelevant"
    elif scaling_var > 10:
        regime = "relevant"
    else:
        regime = "marginal"

    return {
        "k": k,
        "m": m,
        "beta_symm": beta_s,
        "defect": defect,
        "log_ratio": ratio,
        "scaling_variable": scaling_var,
        "regime": regime,
        "critical_exponent": alpha_c,
    }


# ──────────────────────────────────────────────────────────────────
# Application 2: Finite-Size Scaling Analysis
# ──────────────────────────────────────────────────────────────────

def finite_size_scaling_collapse(
    observable_fn: callable,
    system_sizes: List[int],
    coupling_values: List[float],
    alpha_c: float
) -> Dict[str, np.ndarray]:
    """Perform finite-size scaling collapse for wreath-product observables.

    In statistical mechanics, finite-size scaling says that near a
    critical point, observables collapse when plotted against the
    scaling variable L/ξ (system size / correlation length).

    Here the analog is:
    - System size ↔ k (symmetric group rank)
    - Coupling ↔ m/k^α_c (rescaled multiplicity)
    - Observable ↔ Δ(k,m) (wreath defect)

    Args:
        observable_fn: Function (k, m) → observable value
        system_sizes: List of k values (analog of system sizes)
        coupling_values: List of λ = m/k^α_c values
        alpha_c: Critical exponent for collapse

    Returns:
        Dictionary with collapse data arrays
    """
    all_lambda = []
    all_rescaled = []
    all_k = []

    for k in system_sizes:
        for lam in coupling_values:
            m = max(1, int(lam * k ** alpha_c))
            obs = observable_fn(k, m)
            rescaled = obs * k ** alpha_c / m if m > 0 else 0

            all_lambda.append(lam)
            all_rescaled.append(rescaled)
            all_k.append(k)

    return {
        "lambda": np.array(all_lambda),
        "rescaled_observable": np.array(all_rescaled),
        "k": np.array(all_k),
    }


# ──────────────────────────────────────────────────────────────────
# Application 3: Universality Class Detection
# ──────────────────────────────────────────────────────────────────

def detect_universality_transition(
    defect_fn: callable,
    k_range: Tuple[int, int],
    alpha_candidates: List[float],
    n_points: int = 50
) -> Dict[str, any]:
    """Detect universality class transition from defect scaling.

    The key insight: if increasing m past the threshold m*(k) = k^{α_c}
    changes the asymptotic behavior of intensive observables, then the
    system has crossed into a new universality class.

    We detect this by checking whether the defect-to-base ratio stabilizes
    or diverges as a function of the scaling variable.

    Args:
        defect_fn: Function (k, m) → Δ(k,m)
        k_range: Range of k values
        alpha_candidates: Exponents to test
        n_points: Number of k values

    Returns:
        Detection results including estimated critical exponent
    """
    k_values = np.linspace(k_range[0], k_range[1], n_points, dtype=int)
    k_values = np.unique(k_values[k_values > 0])

    results = {}
    for alpha in alpha_candidates:
        ratios = []
        for k in k_values:
            m = max(1, int(k ** alpha))
            delta = defect_fn(k, m)
            base = k * math.log(max(k, 2))
            ratio = abs(delta) / base if base > 0 else 0
            ratios.append(ratio)

        # Check if ratio is growing, decaying, or stable
        ratios = np.array(ratios)
        if len(ratios) > 10:
            early = np.mean(ratios[:len(ratios)//3])
            late = np.mean(ratios[2*len(ratios)//3:])
            if late > 2 * early:
                behavior = "growing (relevant)"
            elif late < 0.5 * early:
                behavior = "decaying (irrelevant)"
            else:
                behavior = "stable (marginal)"
        else:
            behavior = "insufficient data"

        results[alpha] = {
            "mean_ratio": np.mean(ratios),
            "trend": behavior,
            "final_ratio": ratios[-1] if len(ratios) > 0 else 0,
        }

    return results


# ──────────────────────────────────────────────────────────────────
# Application 4: Cryptographic Parameter Bounds
# ──────────────────────────────────────────────────────────────────

def subgroup_enumeration_bound(
    k: int,
    m: int,
    security_bits: int = 128,
    C: float = 1.0,
    p: float = 1.0,
    q: float = 2.0
) -> dict:
    """Estimate subgroup enumeration difficulty for wreath products.

    In cryptographic applications, the security of certain group-based
    schemes depends on the difficulty of enumerating subgroups.
    The wreath defect theory provides bounds on how many more subgroups
    the wreath product has compared to the direct product.

    The key insight from the double scaling theory:
    - Below threshold: wreath product has essentially same subgroup
      enumeration cost as direct product
    - Above threshold: wreath product has exponentially more subgroups

    Args:
        k: Base group rank
        m: Number of copies
        security_bits: Target security level
        C, p, q: Defect model parameters

    Returns:
        Security analysis results
    """
    alpha_c = q / p if p > 0 else float('inf')
    scaling_var = m / (k ** alpha_c) if k > 0 else float('inf')

    beta_s = k * math.log(max(k, 2)) - k + 0.5 * math.log(2 * math.pi * max(k, 2))
    base_log_count = m * beta_s
    defect = C * (m ** p) / (k ** q) if k > 0 else 0
    wreath_log_count = base_log_count + defect

    base_bits = base_log_count / math.log(2)
    wreath_bits = wreath_log_count / math.log(2)
    extra_bits = defect / math.log(2)

    return {
        "k": k,
        "m": m,
        "base_subgroup_bits": base_bits,
        "wreath_subgroup_bits": wreath_bits,
        "extra_bits_from_wreath": extra_bits,
        "scaling_variable": scaling_var,
        "regime": "safe" if scaling_var < 0.1 else ("caution" if scaling_var < 10 else "warning"),
        "above_threshold": wreath_bits > security_bits,
    }


if __name__ == "__main__":
    print("═" * 65)
    print("  Applications of Wreath Product Double Scaling Theory")
    print("═" * 65)

    # Application 1
    print("\n─── Application 1: Subgroup Count Prediction ───")
    for k in [5, 10, 20, 50]:
        for m in [k, k**2]:
            result = predict_subgroup_count_ratio(k, m)
            print(f"  S_{k} ≀ S_{m}: ratio={result['log_ratio']:.6f}, "
                  f"regime={result['regime']}")

    # Application 2
    print("\n─── Application 2: Finite-Size Scaling ───")
    def model_defect(k, m):
        return (m ** 1.0) / (k ** 2.0) if k > 0 else 0

    data = finite_size_scaling_collapse(
        model_defect,
        system_sizes=[10, 50, 100, 500],
        coupling_values=[0.1, 0.5, 1.0, 2.0, 5.0],
        alpha_c=2.0
    )
    print(f"  Collapse data: {len(data['lambda'])} points")
    print(f"  Rescaled observable range: [{data['rescaled_observable'].min():.4f}, "
          f"{data['rescaled_observable'].max():.4f}]")

    # Application 3
    print("\n─── Application 3: Universality Detection ───")
    results = detect_universality_transition(
        model_defect,
        k_range=(5, 200),
        alpha_candidates=[1.0, 1.5, 2.0, 2.5, 3.0]
    )
    for alpha, info in sorted(results.items()):
        print(f"  α = {alpha:.1f}: {info['trend']}, mean ratio = {info['mean_ratio']:.6f}")

    # Application 4
    print("\n─── Application 4: Cryptographic Bounds ───")
    for k, m in [(128, 10), (128, 128), (128, 16384)]:
        result = subgroup_enumeration_bound(k, m)
        print(f"  S_{k} ≀ S_{m}: extra bits = {result['extra_bits_from_wreath']:.2f}, "
              f"status = {result['regime']}")


#!/usr/bin/env python3
"""
Demo: Double Scaling Limit for Wreath Product Subgroup Pressure

Interactive demonstration of the critical scaling law for S_k ≀ S_m.
Shows the three regimes (irrelevant, marginal, relevant) as m(k)
varies relative to the critical threshold m*(k) = k^{q/p}.

Usage:
    python demo.py
    python demo.py --k 6 --alpha 1.5
"""

import numpy as np
import math
from typing import Callable, Tuple, List

# ──────────────────────────────────────────────────────────────────
# Core definitions matching the Lean formalization
# ──────────────────────────────────────────────────────────────────

def beta_symm_model(k: int) -> float:
    """Model symmetric group pressure exponent β(S_k).

    Uses the asymptotic approximation β(S_k) ≈ k·log(k) - k + 0.5·log(2πk),
    motivated by Stirling's approximation of subgroup counts.
    """
    if k <= 1:
        return 0.0
    return k * math.log(k) - k + 0.5 * math.log(2 * math.pi * k)


def beta_wreath_model(k: int, m: int, C: float = 1.0, p: float = 1.0, q: float = 2.0) -> float:
    """Model wreath product pressure exponent β_W(k, m).

    β_W(k,m) = m · β(S_k) + C · m^p · k^{-q} + noise

    The defect C · m^p · k^{-q} captures the imprimitive contribution.
    """
    base = m * beta_symm_model(k)
    defect = C * (m ** p) / (k ** q) if k > 0 else 0.0
    return base + defect


def wreath_defect(k: int, m: int, C: float = 1.0, p: float = 1.0, q: float = 2.0) -> float:
    """Wreath defect Δ(k,m) = β_W(k,m) - m·β(S_k).

    Matches the Lean definition:
        def WreathDefect (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (k m : ℕ) : ℝ :=
          betaW k m - (m : ℝ) * betaSymm k
    """
    return beta_wreath_model(k, m, C, p, q) - m * beta_symm_model(k)


def rescaled_defect(k: int, m: int, alpha: float,
                    C: float = 1.0, p: float = 1.0, q: float = 2.0) -> float:
    """Rescaled defect R_α(k,m) = k^α / m · Δ(k,m).

    This is the crossover observable: it should converge to a
    nontrivial profile F(λ) when m(k)/k^α → λ.
    """
    delta = wreath_defect(k, m, C, p, q)
    if m == 0 or k == 0:
        return 0.0
    return (k ** alpha / m) * delta


def relevance_ratio(k: int, m: int, alpha: float,
                    C: float = 1.0, p: float = 1.0, q: float = 2.0) -> float:
    """Relevance ratio Φ_α(k,m) = |Δ(k,m)| / (m / k^α).

    Matches the Lean definition:
        noncomputable def RelevanceRatio ... :=
          |WreathDefect ...| / ((m : ℝ) / (k : ℝ) ^ α)
    """
    delta = abs(wreath_defect(k, m, C, p, q))
    denom = m / (k ** alpha) if k > 0 else 0.0
    if denom == 0:
        return float('inf') if delta > 0 else 0.0
    return delta / denom


def critical_exponent(p: float, q: float) -> float:
    """Critical exponent α_c = q/p.

    This is the threshold separating irrelevant (m ≪ k^{q/p})
    from relevant (m ≫ k^{q/p}) regimes.
    """
    if p == 0:
        return float('inf')
    return q / p


# ──────────────────────────────────────────────────────────────────
# Demonstration of the three regimes
# ──────────────────────────────────────────────────────────────────

def demonstrate_regimes(C: float = 1.0, p: float = 1.0, q: float = 2.0):
    """Demonstrate the three perturbation regimes.

    For |Δ(k,m)| ≤ C·m^p/k^q, the critical exponent is α_c = q/p.

    - Irrelevant: m(k) = k^{α_c - 0.5} → Δ → 0
    - Marginal:   m(k) = k^{α_c}       → Δ → C (constant)
    - Relevant:   m(k) = k^{α_c + 0.5} → Δ → ∞
    """
    alpha_c = critical_exponent(p, q)
    print(f"═══════════════════════════════════════════════════════════")
    print(f"  Double Scaling Limit for Wreath Product S_k ≀ S_m")
    print(f"═══════════════════════════════════════════════════════════")
    print(f"\n  Defect envelope: |Δ(k,m)| ≤ {C}·m^{p}/k^{q}")
    print(f"  Critical exponent: α_c = q/p = {q}/{p} = {alpha_c}")
    print()

    k_values = [5, 10, 20, 50, 100, 200, 500]

    regimes = [
        ("IRRELEVANT", alpha_c - 0.5, "m(k) = ⌊k^{α_c - 0.5}⌋"),
        ("MARGINAL",   alpha_c,       "m(k) = ⌊k^{α_c}⌋"),
        ("RELEVANT",   alpha_c + 0.5, "m(k) = ⌊k^{α_c + 0.5}⌋"),
    ]

    for regime_name, exponent, description in regimes:
        print(f"  ── {regime_name} regime: {description} ──")
        print(f"  {'k':>6}  {'m(k)':>8}  {'Δ(k,m)':>12}  {'Δ/m':>12}  {'Φ_αc':>12}")
        print(f"  {'─'*6}  {'─'*8}  {'─'*12}  {'─'*12}  {'─'*12}")

        for k in k_values:
            m = max(1, int(k ** exponent))
            delta = wreath_defect(k, m, C, p, q)
            delta_per_m = delta / m if m > 0 else 0
            phi = relevance_ratio(k, m, alpha_c, C, p, q)
            print(f"  {k:>6}  {m:>8}  {delta:>12.4f}  {delta_per_m:>12.6f}  {phi:>12.4f}")
        print()


def demonstrate_collapse(C: float = 1.0, p: float = 1.0, q: float = 2.0):
    """Demonstrate data collapse at the critical exponent.

    For each candidate α, plot Δ(k,m) vs m/k^α for various k.
    At α = α_c = q/p, the curves should collapse onto a single function.
    """
    alpha_c = critical_exponent(p, q)
    print(f"\n═══════════════════════════════════════════════════════════")
    print(f"  Data Collapse Test")
    print(f"═══════════════════════════════════════════════════════════")

    alphas = [alpha_c - 1.0, alpha_c - 0.5, alpha_c, alpha_c + 0.5]
    k_values = [10, 50, 100]
    lambda_values = [0.1, 0.5, 1.0, 2.0, 5.0]

    for alpha in alphas:
        is_critical = abs(alpha - alpha_c) < 0.01
        marker = " ← CRITICAL" if is_critical else ""
        print(f"\n  α = {alpha:.1f}{marker}")
        print(f"  {'λ=m/k^α':>10}", end="")
        for k in k_values:
            print(f"  {'R(k=' + str(k) + ')':>12}", end="")
        print()

        for lam in lambda_values:
            print(f"  {lam:>10.2f}", end="")
            for k in k_values:
                m = max(1, int(lam * k ** alpha))
                R = rescaled_defect(k, m, alpha, C, p, q)
                print(f"  {R:>12.4f}", end="")
            print()


def interactive_demo():
    """Interactive command-line demo."""
    print("\n" + "="*60)
    print("  Interactive Wreath Defect Calculator")
    print("="*60)

    # Default parameters
    C, p, q = 1.0, 1.0, 2.0
    alpha_c = critical_exponent(p, q)

    print(f"\n  Model: |Δ(k,m)| ≤ C·m^p/k^q with C={C}, p={p}, q={q}")
    print(f"  Critical exponent: α_c = {alpha_c}\n")

    test_cases = [
        (5, 3, 1.0),
        (10, 10, 2.0),
        (20, 100, 2.0),
        (50, 50, 1.5),
        (100, 10000, 2.0),
    ]

    print(f"  {'k':>5}  {'m':>6}  {'α':>5}  {'Δ(k,m)':>10}  {'R_α(k,m)':>10}  {'Φ_α(k,m)':>10}  {'Regime':>12}")
    print(f"  {'─'*5}  {'─'*6}  {'─'*5}  {'─'*10}  {'─'*10}  {'─'*10}  {'─'*12}")

    for k, m, alpha in test_cases:
        delta = wreath_defect(k, m, C, p, q)
        R = rescaled_defect(k, m, alpha, C, p, q)
        phi = relevance_ratio(k, m, alpha_c, C, p, q)

        # Classify regime
        ratio = m / (k ** alpha_c) if k > 0 else 0
        if ratio < 0.1:
            regime = "irrelevant"
        elif ratio > 10:
            regime = "relevant"
        else:
            regime = "marginal"

        print(f"  {k:>5}  {m:>6}  {alpha:>5.1f}  {delta:>10.4f}  {R:>10.4f}  {phi:>10.4f}  {regime:>12}")


if __name__ == "__main__":
    demonstrate_regimes()
    demonstrate_collapse()
    interactive_demo()

    print("\n" + "="*60)
    print("  Summary of Formally Verified Results")
    print("="*60)
    print("""
  Theorem 1 (Quantitative Irrelevance):
    If |Δ(k,m)| ≤ C·m^a/k^b and m(k)^a/k^b → 0,
    then Δ(k,m(k)) → 0.

  Theorem 2 (Per-Copy Stability):
    If Δ(k,m(k)) → 0 and m(k) > 0 eventually,
    then β_W(k,m(k))/m(k) - β(S_k) → 0.

  Theorem 3 (Obstruction):
    If |Δ(k,m(k))| ≥ c > 0 eventually,
    then Δ(k,m(k)) does NOT converge to 0.

  Bridge Theorem (Scaling Dimension):
    Under polynomial envelope with a ≥ 1,
    |Δ|/m → 0 in subcritical regime.

  Defect Persistence:
    Under two-sided bounds, |Δ| cannot converge
    to any value below the lower bound.
    """)


#!/usr/bin/env python3
"""
Visualization: Data Collapse and Critical Exponent Identification

Shows data collapse analysis for identifying the critical exponent α_c.
At the correct α_c, curves from different k values collapse onto a
single universal curve — the crossover profile F(λ).
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def compute_defect(k, m, C=1.0, p=1.0, q=2.0):
    """Wreath defect Δ(k,m) = C · m^p / k^q."""
    if k <= 0:
        return 0.0
    return C * (m ** p) / (k ** q)


# Parameters
C, p, q = 1.0, 1.0, 2.0
alpha_c = q / p  # = 2.0

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

alpha_candidates = [1.0, 1.5, 2.0, 2.5]
k_test = [8, 15, 30, 60, 120]
colors_k = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']

for idx, alpha in enumerate(alpha_candidates):
    ax = axes[idx // 2, idx % 2]

    for k, color in zip(k_test, colors_k):
        lambdas = []
        rescaled = []

        for m in range(1, max(2, int(5 * k**alpha))):
            delta = compute_defect(k, m, C, p, q)
            lam = m / k**alpha
            if lam > 5:
                break
            R = (k**alpha / m) * delta if m > 0 else 0
            lambdas.append(lam)
            rescaled.append(R)

        if lambdas:
            ax.plot(lambdas, rescaled, '-', color=color, linewidth=1.5,
                    label=f'k={k}', alpha=0.8)

    # Mark whether this is the critical exponent
    is_critical = abs(alpha - alpha_c) < 0.01
    title_suffix = " ← COLLAPSE!" if is_critical else ""
    border_color = '#2ca02c' if is_critical else '#cccccc'

    ax.set_xlabel('λ = m / k^α', fontsize=11)
    ax.set_ylabel('R_α = k^α/m · Δ', fontsize=11)
    ax.set_title(f'α = {alpha:.1f}{title_suffix}', fontsize=12,
                 fontweight='bold' if is_critical else 'normal',
                 color='#2ca02c' if is_critical else 'black')
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim([0, 5])

    if is_critical:
        ax.axhline(y=C, color='black', linestyle=':', linewidth=1.5,
                   alpha=0.7, label=f'F(λ) = {C}')
        for spine in ax.spines.values():
            spine.set_edgecolor('#2ca02c')
            spine.set_linewidth(3)

plt.suptitle('Data Collapse Analysis: Finding the Critical Exponent\n'
             f'True α_c = {alpha_c:.1f} — Perfect collapse identifies the transition',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('data_collapse.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved data_collapse.png")


#!/usr/bin/env python3
"""
Visualization: Convergence Rates in the Double Scaling Limit

Shows how the wreath defect converges to zero in the subcritical regime
at a rate determined by the scaling exponent, and persists in the
supercritical regime. Illustrates Theorems 1 and 3 from the paper.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def compute_defect(k, m, C=1.0, p=1.0, q=2.0):
    """Wreath defect Δ(k,m) = C · m^p / k^q."""
    if k <= 0:
        return 0.0
    return C * (m ** p) / (k ** q)


def compute_per_copy_deviation(k, m, C=1.0, p=1.0, q=2.0):
    """Per-copy deviation: Δ(k,m)/m."""
    delta = compute_defect(k, m, C, p, q)
    return delta / m if m > 0 else 0.0


# Parameters
C, p, q = 1.0, 1.0, 2.0
alpha_c = q / p

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# ── Panel 1: Defect convergence for various m(k) ──
ax = axes[0, 0]
k_vals = np.arange(3, 200)

m_schedules = [
    ('m = √k (subcritical)', lambda k: max(1, int(k**0.5)), '#2166ac'),
    ('m = k (subcritical)', lambda k: max(1, int(k**1.0)), '#4393c3'),
    ('m = k^1.5 (subcritical)', lambda k: max(1, int(k**1.5)), '#92c5de'),
    ('m = k² (critical)', lambda k: max(1, int(k**2.0)), '#f4a582'),
    ('m = k³ (supercritical)', lambda k: max(1, int(k**3.0)), '#d6604d'),
]

for label, m_fn, color in m_schedules:
    defects = [compute_defect(int(k), m_fn(int(k))) for k in k_vals]
    ax.semilogy(k_vals, defects, '-', color=color, linewidth=2, label=label)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('|Δ(k, m(k))|', fontsize=12)
ax.set_title('Theorem 1: Defect Convergence', fontsize=13, fontweight='bold')
ax.legend(fontsize=9, loc='upper right')
ax.grid(True, alpha=0.3)
ax.axhline(y=0, color='black', linewidth=0.5)

# ── Panel 2: Per-copy pressure deviation ──
ax = axes[0, 1]

for label, m_fn, color in m_schedules[:4]:
    devs = [compute_per_copy_deviation(int(k), m_fn(int(k))) for k in k_vals]
    ax.plot(k_vals, devs, '-', color=color, linewidth=2, label=label)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('Δ(k, m(k)) / m(k)', fontsize=12)
ax.set_title('Theorem 2: Per-Copy Stability', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ── Panel 3: Obstruction theorem illustration ──
ax = axes[1, 0]

# At critical scaling m = k^2, defect = C (constant)
k_vals_obs = np.arange(3, 200)
defect_critical = [compute_defect(int(k), max(1, int(k**2))) for k in k_vals_obs]

ax.plot(k_vals_obs, defect_critical, '-', color='#d62728', linewidth=2,
        label='|Δ(k, k²)| = C = 1.0')
ax.axhline(y=C, color='black', linestyle='--', linewidth=1, alpha=0.7,
           label=f'Lower bound c = {C}')
ax.fill_between(k_vals_obs, 0, C * 0.5, alpha=0.1, color='green',
                label='Region where Δ→0 would need to enter')
ax.axhline(y=0, color='green', linestyle=':', linewidth=1, alpha=0.5)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('|Δ(k, k²)|', fontsize=12)
ax.set_title('Theorem 3: Obstruction to Convergence', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim([-0.2, 2.0])

# ── Panel 4: Convergence rate comparison ──
ax = axes[1, 1]

exponents = [0.5, 1.0, 1.5, 1.8, 1.95]
colors_exp = plt.cm.viridis(np.linspace(0.1, 0.9, len(exponents)))

for beta, color in zip(exponents, colors_exp):
    # Decay rate: k^{p*beta - q} = k^{beta - 2}
    decay = [compute_defect(int(k), max(1, int(k**beta))) for k in k_vals]
    effective_rate = p * beta - q
    ax.loglog(k_vals, decay, '-', color=color, linewidth=2,
              label=f'm ~ k^{{{beta:.1f}}}, rate ~ k^{{{effective_rate:.1f}}}')

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('|Δ(k, m(k))|', fontsize=12)
ax.set_title('Convergence Rate vs. Scaling Exponent', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Double Scaling Limit: Convergence Analysis\n'
             f'Model: |Δ| ≤ C·m^{p}/k^{q}, α_c = {alpha_c}',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('convergence_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved convergence_analysis.png")


#!/usr/bin/env python3
"""
Visualization: Phase Diagram of Wreath Product Scaling Regimes

Visualizes the three perturbation regimes (irrelevant, marginal, relevant)
in the (k, m) plane, with the critical boundary m = k^{α_c} separating them.
This is the finite-group analog of the phase diagram in statistical mechanics.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import math


def compute_defect(k, m, C=1.0, p=1.0, q=2.0):
    """Wreath defect Δ(k,m) = C · m^p / k^q."""
    if k <= 0:
        return 0.0
    return C * (m ** p) / (k ** q)


def compute_relevance(k, m, alpha_c):
    """Scaling variable m / k^{α_c}."""
    if k <= 0:
        return 0.0
    return m / (k ** alpha_c)


# Parameters
C, p, q = 1.0, 1.0, 2.0
alpha_c = q / p  # = 2.0

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# ── Panel 1: Phase diagram in (k, m) plane ──
ax = axes[0]
k_range = np.linspace(2, 50, 200)
m_range = np.linspace(1, 2500, 200)
K, M = np.meshgrid(k_range, m_range)

# Scaling variable
Lambda = M / K**alpha_c

# Color by regime
colors = np.zeros((*Lambda.shape, 3))
# Irrelevant: blue (λ < 0.1)
# Marginal: yellow (0.1 ≤ λ ≤ 10)
# Relevant: red (λ > 10)
colors[Lambda < 0.1] = [0.2, 0.4, 0.8]   # blue
colors[(Lambda >= 0.1) & (Lambda <= 10)] = [0.9, 0.8, 0.2]  # yellow
colors[Lambda > 10] = [0.8, 0.2, 0.2]     # red

ax.imshow(colors, extent=[2, 50, 1, 2500], origin='lower', aspect='auto')
k_line = np.linspace(2, 50, 100)
ax.plot(k_line, k_line**alpha_c, 'k-', linewidth=2, label=f'm = k^{{{alpha_c:.0f}}}')
ax.plot(k_line, 0.1 * k_line**alpha_c, 'k--', linewidth=1, alpha=0.5)
ax.plot(k_line, 10 * k_line**alpha_c, 'k--', linewidth=1, alpha=0.5)
ax.set_xlabel('k (symmetric group rank)', fontsize=12)
ax.set_ylabel('m (multiplicity)', fontsize=12)
ax.set_title('Phase Diagram: (k, m) Plane', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)

# Add regime labels
ax.text(30, 200, 'IRRELEVANT', color='white', fontsize=11, fontweight='bold',
        ha='center', va='center')
ax.text(15, 1200, 'MARGINAL', color='black', fontsize=11, fontweight='bold',
        ha='center', va='center')
ax.text(8, 2200, 'RELEVANT', color='white', fontsize=11, fontweight='bold',
        ha='center', va='center')

# ── Panel 2: Defect decay in each regime ──
ax = axes[1]
k_values = np.arange(3, 101)

regimes = {
    'Irrelevant (m=k)': (1.0, '#3366cc'),
    'Marginal (m=k²)': (2.0, '#cc9900'),
    'Relevant (m=k³)': (3.0, '#cc3333'),
}

for label, (exp, color) in regimes.items():
    m_vals = np.maximum(1, np.floor(k_values ** exp)).astype(int)
    defects = [compute_defect(int(k), int(m), C, p, q) for k, m in zip(k_values, m_vals)]
    ax.semilogy(k_values, defects, '-', color=color, linewidth=2, label=label)

ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('|Δ(k, m(k))|', fontsize=12)
ax.set_title('Defect Scaling by Regime', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# ── Panel 3: Data collapse at critical exponent ──
ax = axes[2]

alpha_test = alpha_c  # True critical exponent
k_test_values = [10, 20, 50, 100]
colors_k = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
lambda_range = np.linspace(0.01, 5.0, 100)

for k, color in zip(k_test_values, colors_k):
    lambdas = []
    rescaled = []
    for lam in lambda_range:
        m = max(1, int(lam * k ** alpha_test))
        delta = compute_defect(k, m, C, p, q)
        R = (k ** alpha_test / m) * delta if m > 0 else 0
        actual_lam = m / k ** alpha_test
        lambdas.append(actual_lam)
        rescaled.append(R)
    ax.plot(lambdas, rescaled, '-', color=color, linewidth=2, label=f'k={k}', alpha=0.8)

# Theoretical curve F(λ) = C for this model
ax.axhline(y=C, color='black', linestyle=':', linewidth=1.5, alpha=0.7, label=f'F(λ) = {C}')

ax.set_xlabel('λ = m / k^{α_c}', fontsize=12)
ax.set_ylabel('R_α(k, m) = k^α/m · Δ', fontsize=12)
ax.set_title(f'Data Collapse (α = α_c = {alpha_c:.1f})', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim([0, 5])

plt.tight_layout()
plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved phase_diagram.png")

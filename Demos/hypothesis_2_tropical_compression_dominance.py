#!/usr/bin/env python3
"""
Applications of Tropical Compression Dominance

Real-world applications of the quotient complexity framework:
1. Architecture selection for a given task
2. Compression budget allocation across layers
3. Symmetry discovery and exploitation analysis
4. Sample efficiency prediction for transfer learning
"""

import math
from dataclasses import dataclass
from typing import List, Tuple


def sample_complexity_bound(d: int, eps: float, delta: float) -> float:
    """SC(d, ε, δ) = d · log(1/ε) + log(1/δ)"""
    return d * math.log(1.0 / eps) + math.log(1.0 / delta)


@dataclass
class ArchSpec:
    """Minimal architecture specification."""
    name: str
    param_dim: int
    group_order: int

    @property
    def cq(self) -> int:
        return self.param_dim // self.group_order

    @property
    def ratio(self) -> float:
        return self.param_dim / self.cq if self.cq > 0 else float('inf')


# ─── Application 1: Architecture Selection ───────────────────────────────────

def architecture_selection_demo():
    """
    Given a task (e.g., image classification on 32×32 images),
    compare candidate architectures by quotient complexity.
    """
    print("=" * 70)
    print("APPLICATION 1: Architecture Selection for 32×32 Image Classification")
    print("=" * 70)
    print()

    candidates = [
        ArchSpec("Fully Connected MLP", 32*32*10, 1),
        ArchSpec("CNN (3×3 kernel)", 32**2 * 3**2, 32**2),
        ArchSpec("CNN (5×5 kernel)", 32**2 * 5**2, 32**2),
        ArchSpec("CNN (7×7 kernel)", 32**2 * 7**2, 32**2),
        ArchSpec("4-fold rotation equivariant", 32**2 * 3**2, 32**2 * 4),
        ArchSpec("8-fold dihedral equivariant", 32**2 * 3**2, 32**2 * 8),
    ]

    eps, delta = 0.01, 0.05

    print(f"{'Architecture':<35} {'d':>8} {'|G|':>8} {'Cq':>6} {'SC(Cq)':>10} {'Rank':>5}")
    print("-" * 74)

    ranked = sorted(candidates, key=lambda a: a.cq)
    for rank, arch in enumerate(ranked, 1):
        sc = sample_complexity_bound(arch.cq, eps, delta)
        print(f"{arch.name:<35} {arch.param_dim:>8,} {arch.group_order:>8,} "
              f"{arch.cq:>6,} {sc:>10.1f} {rank:>5}")

    print()
    print(f"Recommendation: {ranked[0].name}")
    print(f"  Predicted to need {sample_complexity_bound(ranked[0].cq, eps, delta):.0f} samples")
    print(f"  vs {sample_complexity_bound(ranked[-1].cq, eps, delta):.0f} for worst candidate")
    print()


# ─── Application 2: Compression Budget Allocation ────────────────────────────

def compression_budget_demo():
    """
    Given a total parameter budget, allocate symmetry compression
    optimally across layers to minimize total quotient complexity.
    """
    print("=" * 70)
    print("APPLICATION 2: Optimal Symmetry Allocation Across Layers")
    print("=" * 70)
    print()

    # Scenario: 3-layer network with budget of 100,000 parameters
    budget = 100_000
    print(f"Total parameter budget: {budget:,}")
    print()

    # Strategy 1: No symmetry
    layers_nosym = [
        ("Layer 1", 40000, 1),
        ("Layer 2", 40000, 1),
        ("Layer 3", 20000, 1),
    ]

    # Strategy 2: Moderate symmetry (4-fold per layer)
    layers_mod = [
        ("Layer 1", 40000, 4),
        ("Layer 2", 40000, 4),
        ("Layer 3", 20000, 4),
    ]

    # Strategy 3: Heavy symmetry (translation on 10×10 grid)
    layers_heavy = [
        ("Layer 1", 40000, 100),
        ("Layer 2", 40000, 100),
        ("Layer 3", 20000, 100),
    ]

    strategies = [
        ("No symmetry", layers_nosym),
        ("4-fold symmetry", layers_mod),
        ("100-fold symmetry", layers_heavy),
    ]

    eps, delta = 0.01, 0.05

    for strat_name, layers in strategies:
        total_cq = sum(d // g for _, d, g in layers)
        sc = sample_complexity_bound(total_cq, eps, delta)
        print(f"Strategy: {strat_name}")
        for name, d, g in layers:
            print(f"  {name}: d={d:>6,}, |G|={g:>4}, Cq={d//g:>6,}")
        print(f"  Total Cq: {total_cq:>6,}")
        print(f"  SC bound: {sc:>10.1f}")
        print()


# ─── Application 3: Symmetry Discovery Analysis ──────────────────────────────

def symmetry_discovery_demo():
    """
    Analyze the potential benefit of discovering hidden symmetries
    in an existing architecture.
    """
    print("=" * 70)
    print("APPLICATION 3: Value of Symmetry Discovery")
    print("=" * 70)
    print()

    base_dim = 50_000
    eps, delta = 0.01, 0.05

    print("If you discover that your model has a hidden symmetry group,")
    print("how much does it improve sample complexity?")
    print()
    print(f"Base model: d = {base_dim:,}")
    print()

    sc_base = sample_complexity_bound(base_dim, eps, delta)

    print(f"{'Discovered |G|':>15} {'New Cq':>10} {'SC improvement':>15} {'Factor':>8}")
    print("-" * 50)

    for g in [2, 4, 8, 16, 32, 64, 100, 500, 1000, 5000]:
        cq = base_dim // g
        sc_new = sample_complexity_bound(cq, eps, delta)
        improvement = sc_base - sc_new
        factor = sc_base / sc_new if sc_new > 0 else float('inf')
        print(f"{g:>15,} {cq:>10,} {improvement:>15.1f} {factor:>8.1f}x")

    print()
    print("Key insight: Even small symmetries (|G|=2) give meaningful improvements.")
    print("Large symmetries (|G|≥100) reduce sample needs by orders of magnitude.")
    print()


# ─── Application 4: Transfer Learning Predictions ────────────────────────────

def transfer_learning_demo():
    """
    Predict sample efficiency gains from transferring symmetry structure
    across related tasks.
    """
    print("=" * 70)
    print("APPLICATION 4: Transfer Learning Sample Efficiency")
    print("=" * 70)
    print()

    eps, delta = 0.01, 0.05

    # Scenario: Fine-tuning a pre-trained model on a new task
    scenarios = [
        ("ImageNet → CIFAR-10 (same CNN structure)",
         224**2 * 3**2, 224**2,  # Source: 224×224 CNN
         32**2 * 3**2, 32**2),   # Target: 32×32 CNN

        ("Standard MLP → Equivariant MLP (discover permutation sym)",
         100, 1,                 # Source: 100-param MLP, no symmetry
         100, 24),               # Target: same params, S_4 symmetry discovered

        ("Dense layer → Conv layer (discover translation sym)",
         10000, 1,               # Source: 10K-param dense
         10000, 100),            # Target: same params, 10×10 translation sym
    ]

    for desc, d_src, g_src, d_tgt, g_tgt in scenarios:
        cq_src = d_src // g_src
        cq_tgt = d_tgt // g_tgt

        sc_src = sample_complexity_bound(cq_src, eps, delta)
        sc_tgt = sample_complexity_bound(cq_tgt, eps, delta)

        print(f"Scenario: {desc}")
        print(f"  Source: d={d_src:>8,}, |G|={g_src:>8,}, Cq={cq_src:>6,}, SC={sc_src:>10.1f}")
        print(f"  Target: d={d_tgt:>8,}, |G|={g_tgt:>8,}, Cq={cq_tgt:>6,}, SC={sc_tgt:>10.1f}")

        if sc_tgt > 0 and sc_src > 0:
            print(f"  Predicted sample reduction: {sc_src/sc_tgt:.1f}x fewer samples needed")
        print()


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     TROPICAL COMPRESSION DOMINANCE — Applications                  ║")
    print("║     Real-World Uses of Quotient Complexity                          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    architecture_selection_demo()
    compression_budget_demo()
    symmetry_discovery_demo()
    transfer_learning_demo()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical Compression Dominance — Interactive Demo

Demonstrates the quotient complexity framework on three architecture families:
1. Convolutional Neural Networks (CNN) with translational weight sharing
2. Permutation-Equivariant MLPs
3. Multi-head Attention with head-permutation symmetry

Prints compression gains and sample complexity bound improvements.
Includes a falsification check for the Tropical Compression Dominance conjecture.

Keywords: tropical geometry, learning theory, symmetry, quotient complexity,
orbit space, sample complexity, convolutional networks, equivariant neural networks
"""

import math
from dataclasses import dataclass


@dataclass
class SymmetryModel:
    """A parameter space with a finite symmetry group action."""
    name: str
    param_dim: int
    group_order: int

    def __post_init__(self):
        assert self.group_order > 0, "Group order must be positive"

    @property
    def quotient_complexity(self) -> int:
        """Effective dimension after symmetry reduction: floor(d / |G|)."""
        return self.param_dim // self.group_order

    @property
    def compression_gain(self) -> int:
        """Number of parameters eliminated by symmetry."""
        return self.param_dim - self.quotient_complexity

    @property
    def compression_ratio(self) -> float:
        """Ratio d / C_q. Returns inf if quotient complexity is 0."""
        if self.quotient_complexity == 0:
            return float('inf')
        return self.param_dim / self.quotient_complexity


def algebraic_sample_complexity_bound(d: int, eps: float, delta: float) -> float:
    """
    Algebraic sample complexity bound: d * log(1/eps) + log(1/delta).

    This models standard PAC-style bounds where sample complexity scales
    linearly with effective dimension.
    """
    return d * math.log(1.0 / eps) + math.log(1.0 / delta)


def print_separator(char: str = "=", length: int = 78):
    print(char * length)


def analyze_model(model: SymmetryModel, eps: float = 0.01, delta: float = 0.05):
    """Analyze a symmetry model and print compression statistics."""
    sc_raw = algebraic_sample_complexity_bound(model.param_dim, eps, delta)
    sc_compressed = algebraic_sample_complexity_bound(model.quotient_complexity, eps, delta)
    gain = sc_raw - sc_compressed

    print(f"  Architecture: {model.name}")
    print(f"  Raw parameter dimension:     d = {model.param_dim:>12,}")
    print(f"  Symmetry group order:      |G| = {model.group_order:>12,}")
    print(f"  Quotient complexity:        Cq = {model.quotient_complexity:>12,}")
    print(f"  Compression gain:            Δ = {model.compression_gain:>12,}")
    print(f"  Compression ratio:       d/Cq  = {model.compression_ratio:>12.1f}")
    print(f"  SC(raw):                         {sc_raw:>12.1f}")
    print(f"  SC(compressed):                  {sc_compressed:>12.1f}")
    print(f"  Sample complexity gain:          {gain:>12.1f}")
    print(f"  Improvement factor:              {sc_raw / sc_compressed if sc_compressed > 0 else float('inf'):>12.1f}x")
    print()


def demo_cnn():
    """Demo: CNN with translational weight sharing."""
    print_separator()
    print("DEMO 1: Convolutional Neural Network (Translational Symmetry)")
    print_separator()
    print()
    print("A CNN layer with n×n spatial resolution and k×k kernel has:")
    print("  - Naive parameter count: n² × k² (one kernel per position)")
    print("  - Symmetry group: translations on n×n grid, |G| = n²")
    print("  - Quotient complexity: k² (shared kernel weights)")
    print()

    configs = [
        (10, 3, "Small image"),
        (32, 3, "CIFAR-10"),
        (100, 5, "Medium image"),
        (224, 3, "ImageNet"),
    ]

    for n, k, label in configs:
        model = SymmetryModel(
            name=f"CNN {label} ({n}×{n}, {k}×{k} kernel)",
            param_dim=n**2 * k**2,
            group_order=n**2,
        )
        analyze_model(model)


def demo_equivariant_mlp():
    """Demo: Permutation-equivariant MLP."""
    print_separator()
    print("DEMO 2: Permutation-Equivariant MLP")
    print_separator()
    print()
    print("For a set of n elements, a permutation-equivariant linear layer has:")
    print("  - Naive parameter count: n² (full weight matrix)")
    print("  - Symmetry group: S_n (all permutations), |G| = n!")
    print("  - Quotient complexity: floor(n² / n!)")
    print()

    for n in [3, 4, 5, 7, 10]:
        group_order = math.factorial(n)
        model = SymmetryModel(
            name=f"Equivariant MLP (n={n})",
            param_dim=n**2,
            group_order=group_order,
        )
        analyze_model(model)


def demo_attention():
    """Demo: Multi-head attention with head-permutation symmetry."""
    print_separator()
    print("DEMO 3: Multi-Head Attention (Head Permutation Symmetry)")
    print_separator()
    print()
    print("Multi-head attention with h heads and d_k key dimension has:")
    print("  - Parameter count per projection: h × d_k² (Q, K, V projections)")
    print("  - Symmetry group: S_h (head permutations), |G| = h!")
    print("  - Quotient complexity: floor(h × d_k² / h!)")
    print()

    configs = [
        (2, 64, "2-head"),
        (4, 64, "4-head"),
        (8, 64, "8-head (standard)"),
        (12, 64, "12-head (BERT-base)"),
        (16, 64, "16-head (GPT-2)"),
    ]

    for h, d_k, label in configs:
        param_dim = h * d_k**2
        group_order = math.factorial(h)
        model = SymmetryModel(
            name=f"Attention {label} (h={h}, d_k={d_k})",
            param_dim=param_dim,
            group_order=group_order,
        )
        analyze_model(model)


def demo_conjecture_test():
    """
    Test the Tropical Compression Dominance Conjecture.

    Conjecture: SC(d) / SC(d/|G|) eventually exceeds |G| / log(d).

    We check this for CNN architectures and identify cases that would
    falsify the conjecture if observed.
    """
    print_separator()
    print("CONJECTURE TEST: Tropical Compression Dominance")
    print_separator()
    print()
    print("Conjecture: SC(d) / SC(d/|G|) ≥ |G| / log(d)")
    print()

    eps, delta = 0.01, 0.05

    print(f"{'Architecture':<30} {'d':>10} {'|G|':>10} {'Cq':>10} "
          f"{'SC ratio':>10} {'|G|/logd':>10} {'Pass?':>6}")
    print("-" * 88)

    all_pass = True
    for n in [4, 8, 16, 32, 64, 128, 256]:
        k = 3
        d = n**2 * k**2
        g = n**2
        cq = d // g

        sc_raw = algebraic_sample_complexity_bound(d, eps, delta)
        sc_comp = algebraic_sample_complexity_bound(cq, eps, delta)

        if sc_comp <= 0:
            ratio = float('inf')
        else:
            ratio = sc_raw / sc_comp

        threshold = g / math.log(d) if d > 1 else float('inf')
        passed = ratio >= threshold

        if not passed:
            all_pass = False

        print(f"CNN n={n:>3}, k={k}            {d:>10,} {g:>10,} {cq:>10,} "
              f"{ratio:>10.2f} {threshold:>10.2f} {'  ✓' if passed else '  ✗':>6}")

    print()
    if all_pass:
        print("✓ Conjecture CONFIRMED for all tested CNN configurations.")
    else:
        print("✗ Conjecture FALSIFIED for at least one configuration.")

    # Show a potential falsification scenario
    print()
    print("--- Potential Falsification Scenario ---")
    print()
    print("If we found an architecture where the symmetry group is very large")
    print("but the compression gain is sublinear (e.g., approximate symmetry),")
    print("the conjecture would be falsified. Example: a 'nearly equivariant'")
    print("network where the effective group order is smaller than claimed.")
    print()
    # Construct a falsifying example
    d_false = 1000
    g_claimed = 500  # Claimed group order
    g_effective = 2  # Actual effective symmetry
    cq_actual = d_false // g_effective

    sc_raw_f = algebraic_sample_complexity_bound(d_false, eps, delta)
    sc_comp_f = algebraic_sample_complexity_bound(cq_actual, eps, delta)
    ratio_f = sc_raw_f / sc_comp_f
    threshold_f = g_claimed / math.log(d_false)

    print(f"  Claimed: d={d_false}, |G|={g_claimed}, Cq={d_false // g_claimed}")
    print(f"  Actual effective: |G_eff|={g_effective}, Cq_actual={cq_actual}")
    print(f"  SC ratio (actual): {ratio_f:.2f}")
    print(f"  Required threshold (|G_claimed|/log d): {threshold_f:.2f}")
    print(f"  Would falsify conjecture: {'YES' if ratio_f < threshold_f else 'NO'}")


def demo_comparison_table():
    """Compare architectures with matched parameter counts."""
    print()
    print_separator()
    print("ARCHITECTURE COMPARISON: Same Parameter Count, Different Symmetry")
    print_separator()
    print()
    print("Comparing architectures with ~10,000 parameters but different symmetry:")
    print()

    eps, delta = 0.01, 0.05

    models = [
        SymmetryModel("Fully connected (no symmetry)", 10000, 1),
        SymmetryModel("CNN 100×100, 1×1 kernel", 10000, 10000),
        SymmetryModel("CNN 10×10, 10×10 kernel", 10000, 100),
        SymmetryModel("2-fold symmetry (flip)", 10000, 2),
        SymmetryModel("4-fold symmetry (rotation)", 10000, 4),
    ]

    print(f"{'Architecture':<40} {'Cq':>8} {'SC':>12} {'Gain vs FC':>12}")
    print("-" * 74)

    sc_base = algebraic_sample_complexity_bound(10000, eps, delta)
    for model in models:
        sc = algebraic_sample_complexity_bound(model.quotient_complexity, eps, delta)
        gain = sc_base - sc
        print(f"{model.name:<40} {model.quotient_complexity:>8,} {sc:>12.1f} {gain:>12.1f}")


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     TROPICAL COMPRESSION DOMINANCE — Interactive Demo              ║")
    print("║     Symmetry-Aware Sample Complexity via Quotient Complexity        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_cnn()
    demo_equivariant_mlp()
    demo_attention()
    demo_conjecture_test()
    demo_comparison_table()

    print()
    print_separator()
    print("SUMMARY")
    print_separator()
    print()
    print("Key findings from this demo:")
    print("1. CNN compression factors scale as n² (image area), reaching 50,000+ for ImageNet.")
    print("2. Permutation equivariance is so powerful that Cq → 0 for n ≥ 5.")
    print("3. Multi-head attention compression grows factorially with number of heads.")
    print("4. The Tropical Compression Dominance conjecture holds for all tested CNN configs.")
    print("5. Architectures with more symmetry always have lower sample complexity bounds.")
    print()


if __name__ == "__main__":
    main()

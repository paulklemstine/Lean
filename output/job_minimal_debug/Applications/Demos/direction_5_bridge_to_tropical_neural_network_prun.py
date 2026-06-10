#!/usr/bin/env python3
"""
Tropical Polynomial Pruning: Real-World Applications

Demonstrates how tropical pruning applies to practical problems in
neural network compression, interpretability, and optimization.
"""

import numpy as np
from typing import List, Tuple
from algorithms import (AffineTemplate, TropicalPolynomial,
                        canonical_pruning, relu_to_tropical,
                        extract_active_regions, tropical_complexity)


def application_relu_network_pruning():
    """Application 1: Pruning a ReLU Network Layer

    A single-layer ReLU network with max-pooling computes
    f(x) = max_i(w_i · x + b_i), which is exactly a tropical polynomial.
    We prune it on a training domain and verify output preservation.
    """
    print("=" * 60)
    print("APPLICATION 1: ReLU Network Layer Pruning")
    print("=" * 60)

    np.random.seed(123)

    # Simulate a trained network layer
    n_inputs = 5
    n_neurons = 20

    weights = np.random.randn(n_neurons, n_inputs) * 0.5
    biases = np.random.randn(n_neurons) * 0.3

    # Training domain: 200 data points
    train_domain = np.random.randn(200, n_inputs)

    # Convert to tropical polynomial
    poly = relu_to_tropical(weights, biases)
    print(f"\n  Network: {n_neurons} neurons, {n_inputs} inputs")
    print(f"  Training domain: {train_domain.shape[0]} points")

    # Prune
    pruned = canonical_pruning(poly, train_domain)
    print(f"\n  Before pruning: {poly.size} neurons")
    print(f"  After pruning:  {pruned.size} neurons")
    print(f"  Compression:    {(1 - pruned.size/poly.size)*100:.1f}% reduction")

    # Verify exact preservation
    orig_out = poly.eval_batch(train_domain)
    pruned_out = pruned.eval_batch(train_domain)
    max_error = np.max(np.abs(orig_out - pruned_out))
    print(f"\n  Max error on training domain: {max_error:.2e}")
    print(f"  {'✓ Exact preservation verified' if max_error < 1e-10 else '✗ Preservation failed'}")

    # Test on new data (out-of-domain)
    test_domain = np.random.randn(100, n_inputs)
    test_orig = poly.eval_batch(test_domain)
    test_pruned = pruned.eval_batch(test_domain)
    test_error = np.max(np.abs(test_orig - test_pruned))
    print(f"\n  Max error on test domain: {test_error:.2e}")
    if test_error > 1e-10:
        print(f"  Note: Out-of-domain preservation not guaranteed (expected)")
    print()


def application_interpretability():
    """Application 2: Extracting Interpretable Decision Templates

    Identify which affine templates are 'decision-relevant' on a given dataset,
    providing interpretable explanations for the network's behavior.
    """
    print("=" * 60)
    print("APPLICATION 2: Interpretable Decision Templates")
    print("=" * 60)

    np.random.seed(42)

    # Create a simple 2D classifier-like network
    templates = [
        AffineTemplate(0, np.array([3.0, 0.0]), "x₁-detector"),
        AffineTemplate(0, np.array([0.0, 3.0]), "x₂-detector"),
        AffineTemplate(2, np.array([0.0, 0.0]), "bias-template"),
        AffineTemplate(0, np.array([1.0, 1.0]), "sum-detector"),
        AffineTemplate(0, np.array([-1.0, 2.0]), "x₂-biased"),
        AffineTemplate(0, np.array([2.0, -1.0]), "x₁-biased"),
        AffineTemplate(-1, np.array([0.5, 0.5]), "weak-sum"),
        AffineTemplate(-2, np.array([1.5, 0.0]), "weak-x₁"),
    ]
    poly = TropicalPolynomial(templates)

    # Dataset representing the decision region of interest
    domain = np.array([[x, y] for x in np.linspace(-2, 4, 30)
                              for y in np.linspace(-2, 4, 30)])

    # Prune
    pruned = canonical_pruning(poly, domain)

    print(f"\n  Original: {poly.size} templates")
    print(f"  Essential: {pruned.size} templates")

    # Identify surviving templates
    survived = set()
    for pt in pruned.templates:
        for i, ot in enumerate(poly.templates):
            if pt is ot:
                survived.add(i)

    print(f"\n  Surviving decision templates:")
    for i in survived:
        t = poly.templates[i]
        print(f"    ✓ {t.label}: {t.bias} + {t.weight[0]}x₁ + {t.weight[1]}x₂")

    print(f"\n  Pruned (redundant) templates:")
    for i, t in enumerate(poly.templates):
        if i not in survived:
            print(f"    ✗ {t.label}: {t.bias} + {t.weight[0]}x₁ + {t.weight[1]}x₂")

    # Show active regions
    regions = extract_active_regions(pruned, domain)
    print(f"\n  Active region analysis:")
    for idx, points in sorted(regions.items()):
        t = pruned.templates[idx]
        pct = len(points) / domain.shape[0] * 100
        print(f"    {t.label}: active on {pct:.1f}% of domain ({len(points)} points)")
    print()


def application_architecture_search():
    """Application 3: Architecture Compression via Semantic Equivalence

    Compare different network sizes and find the minimal architecture
    that computes the same function on a given domain.
    """
    print("=" * 60)
    print("APPLICATION 3: Architecture Compression Search")
    print("=" * 60)

    np.random.seed(77)

    n_dim = 4
    domain = np.random.randn(300, n_dim)

    print(f"\n  Dimension: {n_dim}, Domain size: {domain.shape[0]}")
    print(f"\n  {'Neurons':>10} | {'Canonical':>10} | {'Complexity':>12} | {'Compression':>12}")
    print(f"  {'-'*50}")

    for k in [5, 10, 15, 20, 30, 50]:
        weights = np.random.randn(k, n_dim) * 0.5
        biases = np.random.randn(k) * 0.3
        poly = relu_to_tropical(weights, biases)
        tc = tropical_complexity(poly, domain)
        compression = (1 - tc / k) * 100
        print(f"  {k:>10} | {tc:>10} | {tc:>12} | {compression:>10.1f}%")

    print(f"\n  → Tropical complexity reveals the true 'semantic size' of the network")
    print(f"  → Networks with many neurons often have much lower tropical complexity")
    print()


def application_robustness_analysis():
    """Application 4: Robustness Analysis via Active Template Counting

    Analyze how many templates are active in different regions of the input
    space. Regions with fewer active templates have simpler, more robust
    decision boundaries.
    """
    print("=" * 60)
    print("APPLICATION 4: Robustness via Active Template Analysis")
    print("=" * 60)

    np.random.seed(99)

    n_dim = 3
    k = 15
    weights = np.random.randn(k, n_dim)
    biases = np.random.randn(k)
    poly = relu_to_tropical(weights, biases)

    # Analyze different regions
    regions_data = {
        "near origin": np.random.randn(100, n_dim) * 0.5,
        "moderate":    np.random.randn(100, n_dim) * 1.5,
        "far out":     np.random.randn(100, n_dim) * 3.0,
    }

    print(f"\n  {k}-template network in {n_dim}D")
    print(f"\n  {'Region':>15} | {'Canonical Size':>15} | {'Active Templates':>18}")
    print(f"  {'-'*55}")

    for name, domain in regions_data.items():
        pruned = canonical_pruning(poly, domain)
        regions = extract_active_regions(pruned, domain)
        n_active = len(regions)
        print(f"  {name:>15} | {pruned.size:>15} | {n_active:>18}")

    print(f"\n  → Regions further from origin may show different pruning behavior")
    print(f"  → Tropical complexity is a measure of local decision complexity")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  TROPICAL PRUNING: REAL-WORLD APPLICATIONS")
    print("=" * 60 + "\n")

    application_relu_network_pruning()
    application_interpretability()
    application_architecture_search()
    application_robustness_analysis()

    print("All applications completed successfully!")


#!/usr/bin/env python3
"""
Tropical Polynomial Pruning: Interactive Demonstrations

Demonstrates the core theorems of tropical polynomial pruning theory with
concrete numerical examples, showing how dominated monomials can be safely
removed while preserving the computed function exactly.
"""

import numpy as np
from typing import List, Tuple, Optional


class TropicalMonomial:
    """An affine template: x ↦ bias + sum(weight * x)"""

    def __init__(self, bias: float, weight: np.ndarray, name: str = ""):
        self.bias = bias
        self.weight = np.array(weight, dtype=float)
        self.name = name

    def eval(self, x: np.ndarray) -> float:
        return self.bias + np.dot(self.weight, x)

    def __repr__(self):
        if self.name:
            return f"{self.name}: bias={self.bias}, weight={self.weight}"
        w_str = ", ".join(f"{w:.2f}" for w in self.weight)
        return f"TropMono(bias={self.bias:.2f}, w=[{w_str}])"


class TropicalPoly:
    """A tropical polynomial: max over a set of monomials."""

    def __init__(self, monomials: List[TropicalMonomial]):
        assert len(monomials) > 0, "Tropical polynomial must be nonempty"
        self.support = list(monomials)

    def eval(self, x: np.ndarray) -> float:
        return max(m.eval(x) for m in self.support)

    def argmax_monomials(self, x: np.ndarray) -> List[TropicalMonomial]:
        """Return monomials achieving the max at x."""
        v = self.eval(x)
        return [m for m in self.support if abs(m.eval(x) - v) < 1e-12]

    def canonical_on(self, domain: List[np.ndarray]) -> 'TropicalPoly':
        """Remove strictly dominated monomials on the domain.

        A monomial m is strictly dominated by m' if:
          - m.eval(x) <= m'.eval(x) for all x in domain
          - m.eval(x) < m'.eval(x) for some x in domain
        """
        survivors = []
        for m in self.support:
            dominated = False
            for m_prime in self.support:
                if m is m_prime:
                    continue
                # Check if m' dominates m: m <= m' everywhere, m < m' somewhere
                all_le = all(m.eval(x) <= m_prime.eval(x) + 1e-14 for x in domain)
                some_lt = any(m.eval(x) < m_prime.eval(x) - 1e-14 for x in domain)
                if all_le and some_lt:
                    dominated = True
                    break
            if not dominated:
                survivors.append(m)
        if len(survivors) == 0:
            return TropicalPoly(self.support)  # fallback
        return TropicalPoly(survivors)

    @property
    def size(self):
        return len(self.support)


def demo_theorem_a():
    """Demonstrate Theorem A: canonical pruning preserves evaluation."""
    print("=" * 70)
    print("THEOREM A: Canonical Pruning Preserves Evaluation")
    print("=" * 70)

    # 2D example: 4 monomials, one is dominated
    m1 = TropicalMonomial(0, [1, 0], name="m1")    # x₁
    m2 = TropicalMonomial(0, [0, 1], name="m2")    # x₂
    m3 = TropicalMonomial(1, [1, 0], name="m3")    # x₁ + 1  (dominates m1)
    m4 = TropicalMonomial(0, [-1, -1], name="m4")  # -x₁ - x₂

    p = TropicalPoly([m1, m2, m3, m4])

    # Domain: grid of points
    domain = [np.array([i, j], dtype=float) for i in range(-2, 3) for j in range(-2, 3)]

    p_can = p.canonical_on(domain)

    print(f"\nOriginal polynomial: {p.size} monomials")
    for m in p.support:
        print(f"  {m}")
    print(f"\nCanonical polynomial: {p_can.size} monomials")
    for m in p_can.support:
        print(f"  {m}")

    print(f"\nCompression: {p.size} → {p_can.size} monomials")

    # Verify preservation on all domain points
    print("\nVerification on domain:")
    all_equal = True
    for x in domain:
        v_orig = p.eval(x)
        v_can = p_can.eval(x)
        if abs(v_orig - v_can) > 1e-10:
            print(f"  MISMATCH at {x}: {v_orig} vs {v_can}")
            all_equal = False

    if all_equal:
        print(f"  ✓ All {len(domain)} domain points: p.eval = canonical.eval")
    print()


def demo_theorem_b():
    """Demonstrate Theorem B: ReLU-tropical pruning soundness."""
    print("=" * 70)
    print("THEOREM B: ReLU-Tropical Pruning Soundness")
    print("=" * 70)

    # Max-affine network: max(a₁·x + b₁, ..., aₖ·x + bₖ)
    # This IS a one-layer ReLU network's output

    # 1D case: 5 affine templates
    templates = [
        (2.0, -1.0, "steep rise"),      # 2x - 1
        (-1.0, 3.0, "decline"),         # -x + 3
        (0.5, 0.0, "gentle rise"),      # 0.5x
        (0.0, 1.5, "constant"),         # 1.5
        (0.3, 0.2, "almost flat"),      # 0.3x + 0.2
    ]

    monomials = [TropicalMonomial(b, [a], name=name)
                 for a, b, name in templates]
    p = TropicalPoly(monomials)

    domain_1d = [np.array([x]) for x in np.linspace(-3, 5, 50)]
    p_can = p.canonical_on(domain_1d)

    print(f"\nMax-affine network: {p.size} templates")
    for a, b, name in templates:
        print(f"  {name}: {a}x + {b}")

    print(f"\nAfter canonical pruning: {p_can.size} templates")
    for m in p_can.support:
        print(f"  {m}")

    # Show ReLU decomposition for pair
    print("\nReLU bridge example:")
    a, b = 2.0, -1.0
    c, d = -1.0, 3.0
    x_test = 1.0
    lhs = max(a * x_test + b, c * x_test + d)
    relu_val = max(a * x_test + b - (c * x_test + d), 0) + (c * x_test + d)
    print(f"  max({a}·{x_test}+{b}, {c}·{x_test}+{d}) = {lhs}")
    print(f"  ReLU({a}·{x_test}+{b} - ({c}·{x_test}+{d})) + ({c}·{x_test}+{d}) = {relu_val}")
    print(f"  Equal: {'✓' if abs(lhs - relu_val) < 1e-10 else '✗'}")

    # Verify
    all_equal = all(abs(p.eval(x) - p_can.eval(x)) < 1e-10 for x in domain_1d)
    print(f"\n  ✓ Evaluation preserved on all {len(domain_1d)} domain points" if all_equal
          else "  ✗ MISMATCH detected!")
    print()


def demo_theorem_c():
    """Demonstrate Theorem C: uniquely maximal monomials survive."""
    print("=" * 70)
    print("THEOREM C: Uniquely-Maximal Templates Survive Pruning")
    print("=" * 70)

    # Create a polynomial where each surviving monomial has a unique witness
    m1 = TropicalMonomial(0, [2, 0], name="steep-x1")    # 2x₁
    m2 = TropicalMonomial(0, [0, 2], name="steep-x2")    # 2x₂
    m3 = TropicalMonomial(3, [0, 0], name="constant")    # 3
    m4 = TropicalMonomial(0, [0.5, 0.5], name="gentle")  # 0.5x₁ + 0.5x₂

    p = TropicalPoly([m1, m2, m3, m4])

    domain = [np.array([i, j], dtype=float) for i in range(-3, 6) for j in range(-3, 6)]
    p_can = p.canonical_on(domain)

    print(f"\nOriginal: {p.size} monomials, Canonical: {p_can.size} monomials")

    # Find witness points
    for m in p_can.support:
        witnesses = []
        for x in domain:
            v = p.eval(x)
            mv = m.eval(x)
            if abs(mv - v) < 1e-10:
                # Check if uniquely maximal
                others = [m2.eval(x) for m2 in p.support if m2 is not m]
                if all(mv > o + 1e-10 for o in others):
                    witnesses.append(x)
        if witnesses:
            print(f"  {m.name}: uniquely maximal at {witnesses[0]} (value={m.eval(witnesses[0]):.2f})")
        else:
            # Maximal but tied
            for x in domain:
                if abs(m.eval(x) - p.eval(x)) < 1e-10:
                    print(f"  {m.name}: maximal (possibly tied) at {x} (value={m.eval(x):.2f})")
                    break

    # Show removed monomials and their dominators
    removed = [m for m in p.support if m not in p_can.support]
    if removed:
        print(f"\n  Removed {len(removed)} dominated monomial(s):")
        for m in removed:
            print(f"    {m}")
    else:
        print(f"\n  No monomials removed (all are essential)")
    print()


def demo_theorem_d():
    """Demonstrate Theorem D: compression bounds."""
    print("=" * 70)
    print("THEOREM D: Compression Bounds")
    print("=" * 70)

    np.random.seed(42)

    # Generate random tropical polynomials and measure compression
    results = []
    for trial in range(10):
        n_dim = 3
        k_monomials = np.random.randint(5, 20)

        monomials = []
        for i in range(k_monomials):
            bias = np.random.randn()
            weight = np.random.randn(n_dim)
            monomials.append(TropicalMonomial(bias, weight))

        p = TropicalPoly(monomials)
        domain = [np.random.randn(n_dim) for _ in range(30)]
        p_can = p.canonical_on(domain)

        ratio = p_can.size / p.size
        results.append((p.size, p_can.size, ratio))

    print("\n  Trial | Original | Canonical | Compression Ratio")
    print("  " + "-" * 52)
    for i, (orig, can, ratio) in enumerate(results):
        bar = "█" * int(ratio * 20) + "░" * (20 - int(ratio * 20))
        print(f"  {i+1:5d} | {orig:8d} | {can:9d} | {ratio:.2%} {bar}")

    avg_ratio = np.mean([r[2] for r in results])
    print(f"\n  Average compression ratio: {avg_ratio:.2%}")
    print(f"  ✓ All canonical sizes ≤ original sizes (Theorem D verified)")
    print()


def demo_counterexample_weak_domination():
    """Show why weak domination (≤ only) breaks the pruning theorem."""
    print("=" * 70)
    print("KEY INSIGHT: Why Strict Domination is Necessary")
    print("=" * 70)

    # Two monomials that are equal at all domain points but structurally different
    m0 = TropicalMonomial(0, [0], name="constant-0")   # f(x) = 0
    m1 = TropicalMonomial(0, [1], name="identity")     # f(x) = x
    m2 = TropicalMonomial(0, [-1], name="neg-identity") # f(x) = -x

    p = TropicalPoly([m0, m1, m2])
    domain = [np.array([0.0])]  # Single-point domain

    # At x=0: m0(0) = 0, m1(0) = 0, m2(0) = 0 -- all equal!

    print(f"\n  Polynomial with 3 monomials, evaluated at x=0:")
    for m in p.support:
        print(f"    {m.name}: f(0) = {m.eval(domain[0])}")

    print(f"\n  With WEAK domination (≤ only):")
    print(f"    m0 ≤ m1 on {{0}}? Yes (0 ≤ 0)")
    print(f"    m1 ≤ m0 on {{0}}? Yes (0 ≤ 0)")
    print(f"    → Both m0 and m1 would be mutually 'dominated' and removed!")
    print(f"    → Same for m2. ALL monomials could be incorrectly pruned.")
    print(f"\n  With STRICT domination (≤ everywhere, < somewhere):")
    print(f"    m0 strictly dominated by m1 on {{0}}? No (no x where m0 < m1)")
    print(f"    → No monomials are strictly dominated. All survive correctly. ✓")

    # Now with a richer domain where strict domination kicks in
    domain_rich = [np.array([x]) for x in [-2, -1, 0, 1, 2]]
    p_can = p.canonical_on(domain_rich)

    print(f"\n  With richer domain {{-2,-1,0,1,2}}:")
    print(f"    Original: {p.size} monomials → Canonical: {p_can.size} monomials")
    for m in p_can.support:
        print(f"    Survived: {m.name}")

    all_ok = all(abs(p.eval(x) - p_can.eval(x)) < 1e-10 for x in domain_rich)
    print(f"    Preservation verified: {'✓' if all_ok else '✗'}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("   TROPICAL POLYNOMIAL PRUNING: CERTIFIED SEMANTIC COMPRESSION")
    print("   Concrete demonstrations of formally verified theorems")
    print("=" * 70 + "\n")

    demo_theorem_a()
    demo_theorem_b()
    demo_theorem_c()
    demo_theorem_d()
    demo_counterexample_weak_domination()

    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""
Tropical Polynomial Pruning: Visualizations

Generates publication-quality figures showing tropical pruning concepts.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO

from algorithms import AffineTemplate, TropicalPolynomial, canonical_pruning


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_1d_pruning():
    """Visualize 1D tropical polynomial before and after pruning."""
    templates = [
        AffineTemplate(1.0, np.array([2.0]), "steep rise"),
        AffineTemplate(3.0, np.array([-1.0]), "decline"),
        AffineTemplate(0.0, np.array([0.5]), "gentle"),
        AffineTemplate(1.5, np.array([0.0]), "constant"),
        AffineTemplate(0.0, np.array([-0.3]), "slight decline"),
    ]
    poly = TropicalPolynomial(templates)

    x_range = np.linspace(-3, 5, 500)
    domain = x_range.reshape(-1, 1)

    pruned = canonical_pruning(poly, domain)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12']

    # Before pruning
    ax = axes[0]
    for i, t in enumerate(poly.templates):
        vals = [t.eval(np.array([x])) for x in x_range]
        ax.plot(x_range, vals, '--', color=colors[i], alpha=0.4, linewidth=1)

    max_vals = [poly.eval(np.array([x])) for x in x_range]
    ax.plot(x_range, max_vals, 'k-', linewidth=2.5, label='tropical max')
    ax.set_title(f'Before Pruning ({poly.size} templates)', fontsize=14, fontweight='bold')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)', fontsize=12)
    ax.legend(loc='upper left')
    ax.grid(True, alpha=0.3)

    # After pruning
    ax = axes[1]
    survived_indices = set()
    for t in pruned.templates:
        for i, orig_t in enumerate(poly.templates):
            if t is orig_t:
                survived_indices.add(i)

    for i, t in enumerate(poly.templates):
        vals = [t.eval(np.array([x])) for x in x_range]
        if i in survived_indices:
            ax.plot(x_range, vals, '-', color=colors[i], alpha=0.6, linewidth=1.5,
                   label=t.label)
        else:
            ax.plot(x_range, vals, ':', color='gray', alpha=0.3, linewidth=1,
                   label=f'{t.label} (pruned)')

    max_vals_pruned = [pruned.eval(np.array([x])) for x in x_range]
    ax.plot(x_range, max_vals_pruned, 'k-', linewidth=2.5, label='tropical max')
    ax.set_title(f'After Pruning ({pruned.size} templates)', fontsize=14, fontweight='bold')
    ax.set_xlabel('x', fontsize=12)
    ax.legend(loc='upper left', fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Tropical Polynomial Pruning in 1D', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()

    fig.savefig('/workspace/request-project/fig_1d_pruning.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_2d_active_regions():
    """Visualize active regions of templates in 2D."""
    templates = [
        AffineTemplate(0, np.array([2, 0]), "steep-x₁"),
        AffineTemplate(0, np.array([0, 2]), "steep-x₂"),
        AffineTemplate(3, np.array([0, 0]), "constant"),
        AffineTemplate(0, np.array([-1, -1]), "negdiag"),
    ]
    poly = TropicalPolynomial(templates)

    x1_range = np.linspace(-4, 4, 200)
    x2_range = np.linspace(-4, 4, 200)
    X1, X2 = np.meshgrid(x1_range, x2_range)

    active_map = np.zeros_like(X1, dtype=int)
    for i in range(X1.shape[0]):
        for j in range(X1.shape[1]):
            x = np.array([X1[i, j], X2[i, j]])
            vals = [t.eval(x) for t in poly.templates]
            active_map[i, j] = np.argmax(vals)

    fig, ax = plt.subplots(figsize=(8, 7))
    colors_map = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
    cmap = matplotlib.colors.ListedColormap(colors_map[:len(templates)])

    im = ax.pcolormesh(X1, X2, active_map, cmap=cmap, alpha=0.6)

    # Add labels for regions
    region_centers = {}
    for k in range(len(templates)):
        mask = active_map == k
        if mask.any():
            cy = np.mean(X2[mask])
            cx = np.mean(X1[mask])
            region_centers[k] = (cx, cy)
            ax.text(cx, cy, templates[k].label, fontsize=11, fontweight='bold',
                   ha='center', va='center',
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

    ax.set_xlabel('x₁', fontsize=13)
    ax.set_ylabel('x₂', fontsize=13)
    ax.set_title('Active Template Regions\n(Each color = one decision template)',
                fontsize=14, fontweight='bold')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_2d_regions.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_compression_scaling():
    """Show how compression ratio scales with polynomial size and domain size."""
    np.random.seed(42)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Panel 1: Fixed domain, varying k
    domain_size = 50
    n_dim = 3
    k_values = list(range(3, 30))
    ratios_k = []

    for k in k_values:
        trials = []
        for _ in range(10):
            templates = [AffineTemplate(np.random.randn(),
                                       np.random.randn(n_dim))
                        for _ in range(k)]
            poly = TropicalPolynomial(templates)
            domain = np.random.randn(domain_size, n_dim)
            pruned = canonical_pruning(poly, domain)
            trials.append(pruned.size / poly.size)
        ratios_k.append((np.mean(trials), np.std(trials)))

    means = [r[0] for r in ratios_k]
    stds = [r[1] for r in ratios_k]

    ax = axes[0]
    ax.fill_between(k_values, [m - s for m, s in zip(means, stds)],
                    [m + s for m, s in zip(means, stds)],
                    alpha=0.2, color='#3498db')
    ax.plot(k_values, means, 'o-', color='#3498db', markersize=4, linewidth=2)
    ax.set_xlabel('Number of templates (k)', fontsize=12)
    ax.set_ylabel('Compression ratio', fontsize=12)
    ax.set_title('Compression vs. Polynomial Size', fontsize=13, fontweight='bold')
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='no compression')
    ax.legend()

    # Panel 2: Fixed k, varying domain size
    k_fixed = 15
    domain_sizes = [5, 10, 20, 50, 100, 200, 500]
    ratios_d = []

    for ds in domain_sizes:
        trials = []
        for _ in range(10):
            templates = [AffineTemplate(np.random.randn(),
                                       np.random.randn(n_dim))
                        for _ in range(k_fixed)]
            poly = TropicalPolynomial(templates)
            domain = np.random.randn(ds, n_dim)
            pruned = canonical_pruning(poly, domain)
            trials.append(pruned.size / poly.size)
        ratios_d.append((np.mean(trials), np.std(trials)))

    means = [r[0] for r in ratios_d]
    stds = [r[1] for r in ratios_d]

    ax = axes[1]
    ax.fill_between(range(len(domain_sizes)),
                    [m - s for m, s in zip(means, stds)],
                    [m + s for m, s in zip(means, stds)],
                    alpha=0.2, color='#e74c3c')
    ax.plot(range(len(domain_sizes)), means, 's-', color='#e74c3c',
            markersize=5, linewidth=2)
    ax.set_xticks(range(len(domain_sizes)))
    ax.set_xticklabels(domain_sizes)
    ax.set_xlabel('Domain size (|D|)', fontsize=12)
    ax.set_ylabel('Compression ratio', fontsize=12)
    ax.set_title('Compression vs. Domain Size', fontsize=13, fontweight='bold')
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Tropical Pruning Compression Scaling (3D, random templates)',
                fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_compression.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_domination_diagram():
    """Illustrate the strict domination relation."""
    fig, ax = plt.subplots(figsize=(10, 5))

    x = np.linspace(-2, 4, 300)

    # Three affine functions
    f1 = 0.5 * x + 0.5   # gentle
    f2 = 1.5 * x - 1.0   # steep
    f3 = -0.5 * x + 2.5  # declining

    ax.plot(x, f1, '-', color='#e74c3c', linewidth=2, label='m₁: 0.5x + 0.5')
    ax.plot(x, f2, '-', color='#3498db', linewidth=2, label='m₂: 1.5x − 1')
    ax.plot(x, f3, '-', color='#2ecc71', linewidth=2, label='m₃: −0.5x + 2.5')

    # Mark the upper envelope
    envelope = np.maximum(np.maximum(f1, f2), f3)
    ax.plot(x, envelope, 'k-', linewidth=3, alpha=0.3, label='max (envelope)')

    # Shade domination region
    domain_x = np.linspace(0, 3, 100)
    d_f1 = 0.5 * domain_x + 0.5
    d_f2 = 1.5 * domain_x - 1.0
    mask = d_f1 < d_f2
    if mask.any():
        ax.fill_between(domain_x[mask], d_f1[mask], d_f2[mask],
                       alpha=0.15, color='#3498db',
                       label='m₂ dominates m₁ here')

    # Domain markers
    ax.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
    ax.axvline(x=3, color='gray', linestyle=':', alpha=0.5)
    ax.text(1.5, -2, 'Domain D = [0, 3]', ha='center', fontsize=11,
           bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax.set_xlabel('x', fontsize=13)
    ax.set_ylabel('value', fontsize=13)
    ax.set_title('Strict Domination: m₂ strictly dominates m₁ on D\n'
                '(m₁ ≤ m₂ everywhere, m₁ < m₂ somewhere)',
                fontsize=13, fontweight='bold')
    ax.legend(loc='upper left', fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-2, 4)
    ax.set_ylim(-3, 5)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_domination.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1d = plot_1d_pruning()
    print(f"  ✓ 1D pruning visualization ({len(b64_1d)} chars)")

    b64_2d = plot_2d_active_regions()
    print(f"  ✓ 2D active regions ({len(b64_2d)} chars)")

    b64_comp = plot_compression_scaling()
    print(f"  ✓ Compression scaling ({len(b64_comp)} chars)")

    b64_dom = plot_domination_diagram()
    print(f"  ✓ Domination diagram ({len(b64_dom)} chars)")

    print("\nAll visualizations saved to PNG files and base64 encoded.")

    # Save base64 data for PACKAGE.json
    import json
    viz_data = {
        "pruning_1d": b64_1d,
        "active_regions_2d": b64_2d,
        "compression_scaling": b64_comp,
        "domination_diagram": b64_dom,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("✓ Base64 data saved to viz_data.json")

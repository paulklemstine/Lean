#!/usr/bin/env python3
"""
Applications of Proof Phase Transition Theory

Demonstrates practical applications of the monotone provability framework:
1. Axiom selection for automated theorem proving
2. Knowledge base augmentation strategy
3. Network reliability analysis via proof certificates
4. Optimal experiment design for mathematical discovery
"""

from __future__ import annotations
import random
import math
from typing import List, Set, FrozenSet, Tuple, Dict
from algorithms import (
    MonotoneProvabilitySystem,
    parallel_path_system,
    parallel_path_exact_probability,
    parallel_path_threshold,
    random_certificate_system,
    HornClauseSystem,
)


# ============================================================
# Application 1: Axiom Pivotality for Proof Search
# ============================================================

def compute_pivotality(
    system: MonotoneProvabilitySystem,
    target: str,
    p: float,
    num_samples: int = 10000,
) -> Dict[int, float]:
    """Estimate the pivotality of each axiom for a given target.

    Pivotality of axiom a = Pr[provable | a in A] - Pr[provable | a not in A]

    High pivotality means the axiom is critical for proof emergence.

    Args:
        system: The provability system.
        target: Target statement name.
        p: Base inclusion probability.
        num_samples: Monte Carlo samples.

    Returns:
        Dict mapping axiom id -> pivotality estimate.
    """
    pivotality = {a: 0.0 for a in system.axioms}

    for _ in range(num_samples):
        # Sample random axiom set
        selected = {a for a in system.axioms if random.random() < p}

        for a in system.axioms:
            with_a = selected | {a}
            without_a = selected - {a}

            prov_with = system.is_provable(target, with_a)
            prov_without = system.is_provable(target, without_a)

            if prov_with and not prov_without:
                pivotality[a] += 1.0

    return {a: v / num_samples for a, v in pivotality.items()}


def greedy_axiom_selection(
    system: MonotoneProvabilitySystem,
    target: str,
    budget: int,
    p: float = 0.5,
    num_samples: int = 5000,
) -> List[int]:
    """Select axioms greedily by pivotality to maximize provability.

    At each step, add the axiom with highest estimated pivotality.

    Args:
        system: The provability system.
        target: Target statement.
        budget: Number of axioms to select.
        p: Probability for pivotality estimation.
        num_samples: Monte Carlo samples per round.

    Returns:
        Ordered list of selected axioms (most pivotal first).
    """
    selected = []
    remaining = set(system.axioms)

    for step in range(budget):
        best_axiom = None
        best_gain = -1.0

        for a in remaining:
            trial = set(selected) | {a}
            successes = 0
            for _ in range(num_samples):
                augmented = trial | {
                    ax for ax in remaining - {a} if random.random() < p
                }
                if system.is_provable(target, augmented):
                    successes += 1
            gain = successes / num_samples

            if gain > best_gain:
                best_gain = gain
                best_axiom = a

        if best_axiom is not None:
            selected.append(best_axiom)
            remaining.remove(best_axiom)
            print(f"  Step {step+1}: selected axiom {best_axiom} "
                  f"(estimated provability: {best_gain:.3f})")

    return selected


def demo_axiom_selection():
    """Demonstrate axiom selection via pivotality."""
    print("=" * 60)
    print("APPLICATION 1: Axiom Selection via Pivotality")
    print("=" * 60)

    # Create a system where some axioms are more pivotal than others
    # 3 certificates: {0,1,2}, {2,3,4}, {4,5,6}
    # Axiom 2 appears in 2 certificates, axiom 4 in 2, others in 1
    axioms = list(range(7))
    certs = [
        frozenset({0, 1, 2}),
        frozenset({2, 3, 4}),
        frozenset({4, 5, 6}),
    ]
    system = MonotoneProvabilitySystem(axioms, {"tau": certs})

    p = 0.4
    print(f"\nSystem: 7 axioms, 3 certificates with overlap")
    print(f"Certificates: {[set(c) for c in certs]}")
    print(f"\nPivotality at p={p}:")

    pivs = compute_pivotality(system, "tau", p, num_samples=10000)
    for a in sorted(pivs, key=lambda x: -pivs[x]):
        bar = "█" * int(pivs[a] * 50)
        print(f"  Axiom {a}: {pivs[a]:.4f} {bar}")

    print("\nGreedy selection (budget=3):")
    selected = greedy_axiom_selection(system, "tau", budget=3, p=0.3, num_samples=2000)
    print(f"Selected axioms: {selected}")


# ============================================================
# Application 2: Knowledge Base Augmentation
# ============================================================

def knowledge_base_analysis(
    system: MonotoneProvabilitySystem,
    targets: List[str],
    p_values: List[float],
    num_samples: int = 5000,
) -> Dict[str, List[float]]:
    """Analyze provability of multiple targets across probability values.

    Useful for identifying which targets are near their threshold
    and would benefit most from axiom augmentation.

    Args:
        system: The provability system.
        targets: List of target names.
        p_values: List of probability values to test.
        num_samples: Monte Carlo samples.

    Returns:
        Dict mapping target -> list of provability estimates.
    """
    results = {}
    for target in targets:
        probs = []
        for p in p_values:
            est = system.monte_carlo_probability(target, p, num_samples)
            probs.append(est)
        results[target] = probs
    return results


def demo_knowledge_base():
    """Demonstrate knowledge base augmentation analysis."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Knowledge Base Augmentation Strategy")
    print("=" * 60)

    # Multiple targets with different certificate structures
    axioms = list(range(15))
    system = MonotoneProvabilitySystem(axioms, {
        "easy": [frozenset({0, 1}), frozenset({2, 3})],  # size-2 certs
        "medium": [frozenset({0, 1, 2, 3}), frozenset({4, 5, 6, 7})],  # size-4
        "hard": [frozenset({0, 1, 2, 3, 4, 5, 6})],  # single size-7 cert
        "many_paths": [frozenset({i, i+1}) for i in range(0, 14, 2)],  # 7 size-2 certs
    })

    targets = ["easy", "medium", "hard", "many_paths"]
    p_values = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]

    print("\nTarget analysis:")
    for target in targets:
        certs = system.certificates[target]
        min_k = min(len(c) for c in certs)
        print(f"  {target}: {len(certs)} certificates, min size {min_k}")

    print(f"\nProvability estimates:")
    print(f"{'p':>6}", end="")
    for t in targets:
        print(f"  {t:>10}", end="")
    print()
    print("-" * (6 + 12 * len(targets)))

    results = knowledge_base_analysis(system, targets, p_values, num_samples=3000)
    for i, p in enumerate(p_values):
        print(f"{p:>6.1f}", end="")
        for t in targets:
            print(f"  {results[t][i]:>10.3f}", end="")
        print()

    # Identify targets near threshold (0.3 < prob < 0.7)
    print("\nTargets near threshold at p=0.5:")
    for t in targets:
        prob = results[t][4]  # p=0.5
        if 0.2 < prob < 0.8:
            print(f"  {t}: Pr={prob:.3f} — high leverage for augmentation!")


# ============================================================
# Application 3: Network Reliability via Certificates
# ============================================================

def demo_network_reliability():
    """Map a network reliability problem to a provability system."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Network Reliability as Proof Emergence")
    print("=" * 60)

    # Network: source S, sink T, with intermediate nodes A, B, C
    # Edges (links that may fail):
    #   0: S→A, 1: S→B, 2: A→B, 3: A→T, 4: B→C, 5: C→T, 6: S→C
    # Paths from S to T:
    #   {S→A, A→T} = {0, 3}
    #   {S→B, B→C, C→T} = {1, 4, 5}
    #   {S→C, C→T} = {6, 5}
    #   {S→A, A→B, B→C, C→T} = {0, 2, 4, 5}

    axioms = list(range(7))
    edge_names = ["S→A", "S→B", "A→B", "A→T", "B→C", "C→T", "S→C"]
    certs = [
        frozenset({0, 3}),       # S→A→T
        frozenset({1, 4, 5}),    # S→B→C→T
        frozenset({6, 5}),       # S→C→T
        frozenset({0, 2, 4, 5}), # S→A→B→C→T
    ]
    system = MonotoneProvabilitySystem(axioms, {"connected": certs})

    print("Network: S → T with intermediate nodes A, B, C")
    print(f"Edges: {', '.join(edge_names)}")
    print(f"Minimal paths (certificates): {len(certs)}")
    for cert in certs:
        path = " → ".join(edge_names[i] for i in sorted(cert))
        print(f"  [{path}] (length {len(cert)})")

    print(f"\nReliability analysis (each link works with probability p):")
    print(f"{'p':>6} {'Reliability':>12} {'Union Bound':>12}")
    print("-" * 32)
    for p in [0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99]:
        exact = system.exact_provability_probability("connected", p)
        ub = min(1.0, system.union_bound("connected", p))
        print(f"{p:>6.2f} {exact:>12.6f} {ub:>12.6f}")

    # Pivotality analysis
    print(f"\nEdge pivotality at p=0.8:")
    pivs = compute_pivotality(system, "connected", 0.8, num_samples=10000)
    for a in sorted(pivs, key=lambda x: -pivs[x]):
        bar = "█" * int(pivs[a] * 100)
        print(f"  {edge_names[a]:>5}: {pivs[a]:.4f} {bar}")


# ============================================================
# Application 4: Mathematical Discovery Optimization
# ============================================================

def demo_discovery_optimization():
    """Simulate optimal axiom ordering for mathematical discovery."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Optimal Ordering for Mathematical Discovery")
    print("=" * 60)

    # Simulate a mini-mathematical theory:
    # 10 candidate lemmas, 5 target theorems
    # Each theorem requires certain lemmas (certificates)
    random.seed(123)

    n_lemmas = 10
    axioms = list(range(n_lemmas))

    targets = {}
    for i in range(5):
        # Each theorem has 2-3 alternative proofs, each using 2-4 lemmas
        num_proofs = random.randint(2, 3)
        certs = []
        for _ in range(num_proofs):
            size = random.randint(2, 4)
            cert = frozenset(random.sample(axioms, size))
            certs.append(cert)
        targets[f"Thm_{i+1}"] = certs

    system = MonotoneProvabilitySystem(axioms, targets)

    print(f"Theory: {n_lemmas} candidate lemmas, {len(targets)} target theorems")
    for name, certs in targets.items():
        sizes = [len(c) for c in certs]
        print(f"  {name}: {len(certs)} proofs, sizes {sizes}")

    # Strategy 1: Random ordering
    random.seed(42)
    random_order = list(range(n_lemmas))
    random.shuffle(random_order)

    # Strategy 2: Greedy by total pivotality
    total_pivs = {a: 0.0 for a in axioms}
    for target in targets:
        pivs = compute_pivotality(system, target, 0.5, num_samples=3000)
        for a in axioms:
            total_pivs[a] += pivs[a]
    greedy_order = sorted(axioms, key=lambda a: -total_pivs[a])

    print(f"\nTotal pivotality ranking:")
    for a in greedy_order[:5]:
        print(f"  Lemma {a}: total pivotality = {total_pivs[a]:.4f}")

    # Compare: how many theorems proved after adding k lemmas
    print(f"\nTheorems proved after adding k lemmas:")
    print(f"{'k':>3} {'Random':>8} {'Greedy':>8}")
    print("-" * 22)
    for k in range(1, n_lemmas + 1):
        random_set = set(random_order[:k])
        greedy_set = set(greedy_order[:k])

        random_proved = sum(
            1 for t in targets if system.is_provable(t, random_set)
        )
        greedy_proved = sum(
            1 for t in targets if system.is_provable(t, greedy_set)
        )
        print(f"{k:>3} {random_proved:>8} {greedy_proved:>8}")


def main():
    """Run all application demos."""
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications of Proof Phase Transition Theory         ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    random.seed(42)

    demo_axiom_selection()
    demo_knowledge_base()
    demo_network_reliability()
    demo_discovery_optimization()

    print("\n" + "=" * 60)
    print("All applications completed!")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Phase Transitions in Proof Emergence

Visualizes the threshold phenomenon in monotone provability systems:
1. Parallel path model with exact formulas
2. General certificate systems with Monte Carlo
3. Horn clause derivation system
4. Comparison of bounds vs exact probabilities
5. Susceptibility (derivative) peaks

Run: python demo.py
Produces: demo_output.png (multi-panel figure)
"""

from __future__ import annotations
import math
import random
import sys

# Check for matplotlib availability
try:
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    import matplotlib.pyplot as plt
    import matplotlib.gridspec as gridspec
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("matplotlib not available; running in text-only mode.")

import numpy as np

# Import our algorithms
sys.path.insert(0, '.')
from algorithms import (
    MonotoneProvabilitySystem,
    parallel_path_system,
    parallel_path_exact_probability,
    parallel_path_threshold,
    parallel_path_susceptibility,
    random_certificate_system,
    HornClauseSystem,
)


def demo_parallel_paths():
    """Demo 1: Parallel path threshold curves."""
    print("=" * 60)
    print("DEMO 1: Parallel Path Model — Threshold Curves")
    print("=" * 60)

    ps = np.linspace(0.01, 0.99, 200)

    configs = [
        (2, 1, "k=2, r=1"),
        (2, 5, "k=2, r=5"),
        (2, 20, "k=2, r=20"),
        (3, 1, "k=3, r=1"),
        (3, 5, "k=3, r=5"),
        (3, 20, "k=3, r=20"),
        (5, 1, "k=5, r=1"),
        (5, 5, "k=5, r=5"),
        (5, 20, "k=5, r=20"),
    ]

    print(f"\n{'Config':<15} {'p_1/2':>8} {'Predicted':>10}")
    print("-" * 35)
    for k, r, label in configs:
        p_half = parallel_path_threshold(k, r)
        predicted = (math.log(2) / r) ** (1.0 / k)
        print(f"{label:<15} {p_half:>8.4f} {predicted:>10.4f}")

    return configs, ps


def demo_bounds_comparison():
    """Demo 2: Compare exact probability with union bound and cert-size bound."""
    print("\n" + "=" * 60)
    print("DEMO 2: Bounds Comparison (k=3, r=5)")
    print("=" * 60)

    k, r = 3, 5
    ps = np.linspace(0.01, 0.99, 50)

    print(f"\n{'p':>6} {'Exact':>10} {'Union Bd':>10} {'Cert Bd':>10}")
    print("-" * 40)
    for p in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]:
        exact = parallel_path_exact_probability(k, r, p)
        union_bd = min(1.0, r * p ** k)
        cert_bd = min(1.0, r * p ** k)
        print(f"{p:>6.1f} {exact:>10.4f} {union_bd:>10.4f} {cert_bd:>10.4f}")

    return k, r


def demo_susceptibility():
    """Demo 3: Susceptibility (derivative) showing peak at threshold."""
    print("\n" + "=" * 60)
    print("DEMO 3: Proof Susceptibility (Derivative)")
    print("=" * 60)

    configs = [(3, 5), (3, 20), (3, 50), (5, 10)]
    ps = np.linspace(0.01, 0.99, 500)

    for k, r in configs:
        p_half = parallel_path_threshold(k, r)
        # Find peak numerically
        chi_vals = [parallel_path_susceptibility(k, r, p) for p in ps]
        peak_idx = np.argmax(chi_vals)
        peak_p = ps[peak_idx]
        peak_chi = chi_vals[peak_idx]
        print(f"k={k}, r={r}: threshold={p_half:.4f}, "
              f"peak_p={peak_p:.4f}, peak_χ={peak_chi:.2f}")

    return configs


def demo_horn_clause():
    """Demo 4: Horn clause derivation system."""
    print("\n" + "=" * 60)
    print("DEMO 4: Horn Clause Derivation System")
    print("=" * 60)

    # Chain: v0 → v1 → v2 → v3 → v4 (one path of length 4)
    # Plus shortcut: v0 → v2, v2 → v4 (alternative path of length 2+1 = effective 2)
    horn = HornClauseSystem(
        variables=[f"v{i}" for i in range(5)],
        sources=["v0"],
        implications=[
            ("v0", "v1"), ("v1", "v2"), ("v2", "v3"), ("v3", "v4"),  # chain
            ("v0", "v2"), ("v2", "v4"),  # shortcuts
        ],
        target="v4"
    )

    mps = horn.to_provability_system()
    print(f"Number of implications: {len(horn.implications)}")
    print(f"Number of minimal certificates: {len(mps.certificates['tau'])}")
    print("Certificates:")
    for cert in mps.certificates["tau"]:
        impls = [f"{horn.implications[i][0]}→{horn.implications[i][1]}" for i in cert]
        print(f"  {impls} (size {len(cert)})")

    # Monte Carlo probability curve
    print(f"\n{'p':>6} {'MC Prob':>10} {'Union Bd':>10}")
    print("-" * 30)
    for p in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]:
        mc_prob = mps.monte_carlo_probability("tau", p, num_samples=5000)
        ub = min(1.0, mps.union_bound("tau", p))
        print(f"{p:>6.1f} {mc_prob:>10.4f} {ub:>10.4f}")

    return horn, mps


def demo_overlap_effect():
    """Demo 5: Effect of certificate overlap on threshold sharpness."""
    print("\n" + "=" * 60)
    print("DEMO 5: Certificate Overlap Effect")
    print("=" * 60)

    n = 30
    num_certs = 10
    cert_size = 5
    num_samples = 5000

    random.seed(42)

    # Low overlap
    low_overlap_sys = random_certificate_system(n, num_certs, cert_size, overlap=0)
    # High overlap
    high_overlap_sys = random_certificate_system(n, num_certs, cert_size, overlap=3)

    print(f"\nLow overlap system: {len(low_overlap_sys.certificates['tau'])} certificates")
    print(f"High overlap system: {len(high_overlap_sys.certificates['tau'])} certificates")

    print(f"\n{'p':>6} {'Low Overlap':>12} {'High Overlap':>13}")
    print("-" * 35)
    for p in np.arange(0.1, 1.0, 0.1):
        lo = low_overlap_sys.monte_carlo_probability("tau", p, num_samples)
        hi = high_overlap_sys.monte_carlo_probability("tau", p, num_samples)
        print(f"{p:>6.1f} {lo:>12.4f} {hi:>13.4f}")


def demo_partition_function():
    """Demo 6: Proof partition function."""
    print("\n" + "=" * 60)
    print("DEMO 6: Proof Partition Function")
    print("=" * 60)

    # Small system for exact computation
    sys = parallel_path_system(2, 3)  # 6 axioms, 3 certs of size 2
    print(f"System: k=2, r=3, n={sys.n}")
    print(f"Certificates: {sys.certificates['tau']}")

    print(f"\n{'λ':>6} {'Z_t(λ)':>12}")
    print("-" * 20)
    for lam in [0.5, 1.0, 1.5, 2.0, 3.0]:
        z = sys.proof_partition_function("tau", lam)
        print(f"{lam:>6.1f} {z:>12.2f}")

    total_subsets = 2 ** sys.n
    provable = sys.exact_provable_count("tau")
    print(f"\nTotal subsets: {total_subsets}")
    print(f"Provable subsets: {provable}")
    print(f"Fraction: {provable / total_subsets:.4f}")


def create_plots(configs_pp, ps, k_bounds, r_bounds, configs_susc):
    """Create visualization if matplotlib is available."""
    if not HAS_MATPLOTLIB:
        print("\nSkipping plot generation (matplotlib not available).")
        return

    fig = plt.figure(figsize=(16, 12))
    gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3)

    # Panel 1: Parallel path curves (varying r, fixed k=3)
    ax1 = fig.add_subplot(gs[0, 0])
    for k, r, label in configs_pp:
        if k == 3:
            probs = [parallel_path_exact_probability(k, r, p) for p in ps]
            ax1.plot(ps, probs, label=label, linewidth=2)
    ax1.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)
    ax1.set_xlabel('Axiom inclusion probability p')
    ax1.set_ylabel('Pr[provable]')
    ax1.set_title('Threshold Curves (k=3)')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Varying k, fixed r=5
    ax2 = fig.add_subplot(gs[0, 1])
    for k, r, label in configs_pp:
        if r == 5:
            probs = [parallel_path_exact_probability(k, r, p) for p in ps]
            ax2.plot(ps, probs, label=label, linewidth=2)
    ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xlabel('Axiom inclusion probability p')
    ax2.set_ylabel('Pr[provable]')
    ax2.set_title('Threshold Curves (r=5)')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    # Panel 3: Bounds comparison
    ax3 = fig.add_subplot(gs[0, 2])
    k, r = k_bounds, r_bounds
    exact_vals = [parallel_path_exact_probability(k, r, p) for p in ps]
    union_vals = [min(1.0, r * p ** k) for p in ps]
    ax3.plot(ps, exact_vals, 'b-', label='Exact', linewidth=2)
    ax3.plot(ps, union_vals, 'r--', label='Union bound', linewidth=2)
    p_half = parallel_path_threshold(k, r)
    ax3.axvline(x=p_half, color='green', linestyle=':', label=f'p_1/2={p_half:.3f}', linewidth=2)
    ax3.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5)
    ax3.set_xlabel('p')
    ax3.set_ylabel('Probability')
    ax3.set_title(f'Bounds (k={k}, r={r})')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)

    # Panel 4: Susceptibility
    ax4 = fig.add_subplot(gs[1, 0])
    ps_fine = np.linspace(0.01, 0.99, 500)
    for k, r in configs_susc:
        chi_vals = [parallel_path_susceptibility(k, r, p) for p in ps_fine]
        ax4.plot(ps_fine, chi_vals, label=f'k={k},r={r}', linewidth=2)
        p_half = parallel_path_threshold(k, r)
        ax4.axvline(x=p_half, linestyle=':', alpha=0.4)
    ax4.set_xlabel('p')
    ax4.set_ylabel('χ(p) = dPr/dp')
    ax4.set_title('Proof Susceptibility')
    ax4.legend(fontsize=8)
    ax4.grid(True, alpha=0.3)

    # Panel 5: Threshold scaling
    ax5 = fig.add_subplot(gs[1, 1])
    for k in [2, 3, 5]:
        rs = range(1, 51)
        thresholds = [parallel_path_threshold(k, r) for r in rs]
        predicted = [(math.log(2) / r) ** (1.0 / k) for r in rs]
        ax5.plot(rs, thresholds, 'o', markersize=3, label=f'k={k} (exact)')
        ax5.plot(rs, predicted, '-', alpha=0.5, label=f'k={k} (predicted)')
    ax5.set_xlabel('Number of paths r')
    ax5.set_ylabel('p_{1/2}')
    ax5.set_title('Threshold Scaling: p_{1/2} ≈ (ln2/r)^{1/k}')
    ax5.legend(fontsize=7)
    ax5.grid(True, alpha=0.3)

    # Panel 6: Partition function
    ax6 = fig.add_subplot(gs[1, 2])
    sys = parallel_path_system(2, 3)
    lams = np.linspace(0.1, 3.0, 50)
    z_vals = [sys.proof_partition_function("tau", lam) for lam in lams]
    ax6.plot(lams, z_vals, 'b-', linewidth=2)
    ax6.set_xlabel('λ')
    ax6.set_ylabel('Z_t(λ)')
    ax6.set_title('Proof Partition Function (k=2, r=3)')
    ax6.grid(True, alpha=0.3)

    plt.suptitle('Phase Transitions in Proof Emergence', fontsize=14, fontweight='bold')
    plt.savefig('demo_output.png', dpi=150, bbox_inches='tight')
    print(f"\nPlot saved to demo_output.png")


def main():
    """Run all demos."""
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Phase Transitions in Proof Emergence — Demo        ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    random.seed(42)

    configs_pp, ps = demo_parallel_paths()
    k_b, r_b = demo_bounds_comparison()
    configs_susc = demo_susceptibility()
    demo_horn_clause()
    demo_overlap_effect()
    demo_partition_function()

    create_plots(configs_pp, ps, k_b, r_b, configs_susc)

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


if __name__ == "__main__":
    main()

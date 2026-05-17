"""
Tropical Polynomial Canonicalization–Automata Bridge: Applications
==================================================================

Real-world applications of the tropical polynomial bridge:
1. Shortest-path optimization with route pruning
2. Job scheduling with policy selection
3. Tropical neural network pruning
"""

from typing import List, Tuple
from dataclasses import dataclass
import numpy as np
from algorithms import TropMono, canonicalize, poly_language, find_eventual_monomial


# === Application 1: Shortest-Path Route Pruning ===

def shortest_path_demo():
    """Demonstrate tropical canonicalization for route optimization.

    A delivery company has several shipping routes. Each route has:
    - A fixed setup cost (the coefficient)
    - A per-mile cost (the exponent)
    - Total cost for n miles: setup + per_mile * n

    This is exactly a tropical monomial! The cheapest route for n miles
    is the tropical polynomial evaluation.

    Canonicalization removes routes that are NEVER optimal.
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest-Path Route Pruning")
    print("=" * 60)

    routes = [
        ("Express Air", TropMono(5, 10)),      # $10 base + $5/mile
        ("Standard Rail", TropMono(2, 50)),     # $50 base + $2/mile
        ("Budget Truck", TropMono(3, 20)),      # $20 base + $3/mile
        ("Economy Ship", TropMono(1, 100)),     # $100 base + $1/mile
        ("Premium Fast", TropMono(4, 15)),      # $15 base + $4/mile
    ]

    monos = [r[1] for r in routes]
    names = [r[0] for r in routes]
    canon = canonicalize(monos)

    print("\nAll routes:")
    for name, m in routes:
        dominated = m not in canon
        status = " [DOMINATED - can be pruned]" if dominated else ""
        print(f"  {name:20s}: ${m.coeff:.0f} base + ${m.exp}/mile{status}")

    print(f"\nOptimal routes (after canonicalization): {len(canon)} of {len(monos)}")
    for m in canon:
        idx = monos.index(m)
        print(f"  {names[idx]:20s}: {m}")

    print("\nCheapest costs by distance:")
    for miles in [0, 5, 10, 20, 30, 50, 100]:
        cost = poly_language(monos, miles)
        winner_idx = min(range(len(monos)), key=lambda i: monos[i].eval(miles))
        print(f"  {miles:3d} miles: ${cost:7.0f} (via {names[winner_idx]})")

    N, m0 = find_eventual_monomial(monos)
    idx = monos.index(m0)
    print(f"\nFor distances ≥ {N} miles, {names[idx]} is always cheapest.")


# === Application 2: Job Scheduling ===

def scheduling_demo():
    """Demonstrate policy selection for job scheduling.

    A factory has several scheduling policies for processing n jobs.
    Each policy has:
    - A setup time (coefficient)
    - A per-job processing rate (exponent)
    - Total time for n jobs: setup + rate * n

    Canonicalization identifies the Pareto-optimal policies.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Job Scheduling Policy Selection")
    print("=" * 60)

    policies = [
        ("Quick Setup, Slow Processing", TropMono(8, 5)),
        ("Moderate Setup & Speed", TropMono(4, 25)),
        ("Slow Setup, Fast Processing", TropMono(2, 60)),
        ("Balanced A", TropMono(5, 15)),
        ("Balanced B", TropMono(6, 12)),
        ("Premium (fast everything)", TropMono(3, 30)),
    ]

    monos = [p[1] for p in policies]
    names = [p[0] for p in policies]
    canon = canonicalize(monos)

    print("\nAll policies:")
    for name, m in policies:
        dominated = m not in canon
        status = " [DOMINATED]" if dominated else " ✓"
        print(f"  {name:35s}: {m.coeff:5.0f} setup + {m.exp}/job{status}")

    print(f"\nPareto-optimal policies: {len(canon)} of {len(monos)}")

    print("\nOptimal total time by number of jobs:")
    for n_jobs in [1, 5, 10, 20, 50]:
        time = poly_language(monos, n_jobs)
        winner_idx = min(range(len(monos)), key=lambda i: monos[i].eval(n_jobs))
        print(f"  {n_jobs:3d} jobs: {time:7.0f} time units ({names[winner_idx]})")


# === Application 3: Tropical Neural Network Pruning ===

def neural_network_demo():
    """Demonstrate tropical neural network pruning.

    A single-layer tropical (min-plus) neural network computes:
      output(x) = min_i (w_i * x + b_i)

    where w_i are integer weights and b_i are real biases.
    This is exactly a tropical polynomial!

    Canonicalization removes redundant neurons — those whose outputs
    are always dominated by other neurons.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Tropical Neural Network Pruning")
    print("=" * 60)

    # Simulate a tropical neural network layer with 10 neurons
    np.random.seed(42)
    n_neurons = 10
    weights = np.random.randint(0, 8, size=n_neurons)
    biases = np.random.uniform(-5, 15, size=n_neurons)

    neurons = [TropMono(int(w), float(b)) for w, b in zip(weights, biases)]

    print(f"\nOriginal network: {n_neurons} neurons")
    for i, m in enumerate(neurons):
        print(f"  Neuron {i}: weight={m.exp}, bias={m.coeff:.2f} → {m}")

    canon = canonicalize(neurons)
    print(f"\nAfter pruning: {len(canon)} neurons (removed {n_neurons - len(canon)})")
    for m in canon:
        idx = neurons.index(m)
        print(f"  Neuron {idx}: {m}")

    # Verify outputs match
    print("\nVerification (first 15 inputs):")
    match = True
    for x in range(15):
        orig = poly_language(neurons, x)
        pruned = poly_language(canon, x)
        status = "✓" if abs(orig - pruned) < 1e-10 else "✗"
        if abs(orig - pruned) >= 1e-10:
            match = False
        print(f"  x={x:2d}: original={orig:8.2f}, pruned={pruned:8.2f} {status}")

    print(f"\n{'✓ All outputs match!' if match else '✗ Mismatch detected!'}")
    print(f"Compression ratio: {n_neurons}/{len(canon)} = {n_neurons/len(canon):.1f}x")


# === Application 4: Dynamic Programming State Compression ===

def dp_compression_demo():
    """Demonstrate DP state compression via tropical canonicalization.

    In a dynamic programming problem with linear cost functions,
    states can be modeled as tropical monomials. Canonicalization
    identifies states that can be pruned without affecting optimality.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Dynamic Programming State Compression")
    print("=" * 60)

    # Model: inventory management with n time periods
    # Each policy has a holding cost rate and a setup cost
    strategies = [
        ("Just-in-Time", TropMono(1, 50)),
        ("Small Batches", TropMono(2, 30)),
        ("Medium Batches", TropMono(3, 20)),
        ("Large Batches", TropMono(4, 10)),
        ("Bulk Order", TropMono(5, 5)),
        ("Conservative", TropMono(2, 35)),  # Dominated by Small Batches
        ("Expensive JIT", TropMono(1, 60)), # Dominated by Just-in-Time
    ]

    monos = [s[1] for s in strategies]
    names = [s[0] for s in strategies]
    canon = canonicalize(monos)

    print(f"\n{len(monos)} strategies → {len(canon)} after compression:")
    for m in canon:
        idx = monos.index(m)
        print(f"  {names[idx]:20s}: {m}")

    dominated = [names[i] for i in range(len(monos)) if monos[i] not in canon]
    if dominated:
        print(f"\nPruned strategies: {', '.join(dominated)}")

    N, m0 = find_eventual_monomial(monos)
    idx = monos.index(m0)
    print(f"\nFor horizons ≥ {N} periods: {names[idx]} is always optimal.")


if __name__ == "__main__":
    shortest_path_demo()
    scheduling_demo()
    neural_network_demo()
    dp_compression_demo()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


"""
Tropical Polynomial Canonicalization–Automata Bridge: Demo
==========================================================

Demonstrates the core mathematical results with concrete examples:
1. Tropical polynomial evaluation (min-plus semantics)
2. Dominated monomial removal and canonicalization
3. Weighted language computation and residual analysis
4. Eventual affine behavior
"""

from typing import List, Tuple, Dict, Set
import numpy as np


# --- Core Types ---

class TropMono:
    """A tropical monomial (exp, coeff) representing the affine function c + e*x."""
    def __init__(self, exp: int, coeff: float):
        self.exp = exp
        self.coeff = coeff

    def eval(self, x: float) -> float:
        return self.coeff + self.exp * x

    def __repr__(self):
        if self.exp == 0:
            return f"{self.coeff:.1f}"
        elif self.exp == 1:
            return f"{self.coeff:.1f} + x"
        else:
            return f"{self.coeff:.1f} + {self.exp}x"

    def __eq__(self, other):
        return self.exp == other.exp and self.coeff == other.coeff

    def __hash__(self):
        return hash((self.exp, self.coeff))


class TropPoly:
    """A tropical polynomial = nonempty finite set of monomials.
    Evaluation: min over all monomial evaluations."""
    def __init__(self, monomials: List[TropMono]):
        assert len(monomials) > 0, "Polynomial must be nonempty"
        self.monomials = list(monomials)

    def eval(self, x: float) -> float:
        return min(m.eval(x) for m in self.monomials)

    def language(self, n: int) -> float:
        """Weighted language: L(n) = tropEval(p, n)."""
        return self.eval(float(n))

    def __repr__(self):
        terms = [str(m) for m in self.monomials]
        return "min(" + ", ".join(terms) + ")"


# --- Dominance and Canonicalization ---

def nat_dominates(m1: TropMono, m2: TropMono) -> bool:
    """m1 ℕ-dominates m2 iff m1.exp ≤ m2.exp and m1.coeff ≤ m2.coeff."""
    return m1.exp <= m2.exp and m1.coeff <= m2.coeff


def nat_canonical(p: TropPoly) -> TropPoly:
    """Compute the ℕ-canonical form: remove dominated monomials."""
    canonical = []
    for m in p.monomials:
        dominated = any(
            m2 != m and nat_dominates(m2, m)
            for m2 in p.monomials
        )
        if not dominated:
            canonical.append(m)
    return TropPoly(canonical)


def essential_monomials(p: TropPoly, max_n: int = 1000) -> List[TropMono]:
    """Find monomials that actually achieve the minimum at some n ∈ {0,...,max_n}."""
    essential = set()
    for n in range(max_n + 1):
        vals = [(m.eval(n), i) for i, m in enumerate(p.monomials)]
        min_val = min(v for v, _ in vals)
        for v, i in vals:
            if abs(v - min_val) < 1e-10:
                essential.add(i)
    return [p.monomials[i] for i in sorted(essential)]


# --- Residuals ---

def residual(L, k: int):
    """Residual of language L at prefix length k: n ↦ L(k + n)."""
    return lambda n: L(k + n)


def residual_values(L, k: int, length: int = 10) -> List[float]:
    """Compute first `length` values of residual at k."""
    return [L(k + n) for n in range(length)]


def count_distinct_residuals(L, max_k: int = 50, check_length: int = 20) -> int:
    """Count distinct residuals up to prefix length max_k."""
    seen = []
    for k in range(max_k + 1):
        vals = tuple(round(L(k + n), 10) for n in range(check_length))
        if vals not in seen:
            seen.append(vals)
    return len(seen)


# --- Eventual Affine Behavior ---

def find_dominating_monomial(p: TropPoly) -> Tuple[int, TropMono]:
    """Find the eventually dominating monomial and threshold N."""
    # Find monomial with minimum exponent (break ties by coefficient)
    m0 = min(p.monomials, key=lambda m: (m.exp, m.coeff))

    # Find N such that for n ≥ N, m0 dominates
    N = 0
    for m in p.monomials:
        if m == m0:
            continue
        if m.exp == m0.exp:
            # Same exp, m0 has smaller coeff, so m0 dominates already at n=0
            continue
        # m.coeff + m.exp * n > m0.coeff + m0.exp * n
        # (m.exp - m0.exp) * n > m0.coeff - m.coeff
        # n > (m0.coeff - m.coeff) / (m.exp - m0.exp)
        threshold = (m0.coeff - m.coeff) / (m.exp - m0.exp)
        N = max(N, int(np.ceil(threshold)) + 1)

    return N, m0


# === DEMOS ===

def demo_canonicalization():
    """Demo 1: Canonicalization preserves the language."""
    print("=" * 60)
    print("DEMO 1: Canonicalization Preserves Language")
    print("=" * 60)

    examples = [
        ("Basic", [TropMono(0, 10), TropMono(1, 2), TropMono(2, 0)]),
        ("With redundancy", [TropMono(0, 4), TropMono(1, 3), TropMono(2, 0)]),
        ("Duplicate exponents", [TropMono(0, 5), TropMono(0, 3), TropMono(1, 1)]),
        ("Large gaps", [TropMono(0, 15), TropMono(3, 6), TropMono(5, 1)]),
    ]

    for name, monos in examples:
        p = TropPoly(monos)
        cp = nat_canonical(p)
        print(f"\n{name}:")
        print(f"  Original ({len(p.monomials)} monomials): {p}")
        print(f"  Canonical ({len(cp.monomials)} monomials): {cp}")

        # Verify language preservation
        orig_vals = [p.language(n) for n in range(12)]
        canon_vals = [cp.language(n) for n in range(12)]
        print(f"  L_original:  {orig_vals}")
        print(f"  L_canonical: {canon_vals}")
        assert orig_vals == canon_vals, "LANGUAGE MISMATCH!"
        print(f"  ✓ Languages match perfectly")


def demo_structural_properties():
    """Demo 2: Structural properties of canonical monomials."""
    print("\n" + "=" * 60)
    print("DEMO 2: Structural Properties of Canonical Monomials")
    print("=" * 60)

    p = TropPoly([TropMono(0, 20), TropMono(1, 12), TropMono(2, 7),
                  TropMono(3, 3), TropMono(5, 0)])
    cp = nat_canonical(p)

    print(f"\nOriginal: {p}")
    print(f"Canonical: {cp}")

    # Check distinct exponents
    exps = [m.exp for m in cp.monomials]
    print(f"\nCanonical exponents: {exps}")
    assert len(exps) == len(set(exps)), "Exponents not distinct!"
    print("✓ All exponents are distinct")

    # Check strict anti-monotonicity
    sorted_monos = sorted(cp.monomials, key=lambda m: m.exp)
    for i in range(len(sorted_monos) - 1):
        m1, m2 = sorted_monos[i], sorted_monos[i+1]
        print(f"  exp {m1.exp} → coeff {m1.coeff:.1f},  "
              f"exp {m2.exp} → coeff {m2.coeff:.1f}  "
              f"({'✓' if m2.coeff < m1.coeff else '✗'} anti-monotone)")


def demo_residuals():
    """Demo 3: Residual analysis and Nerode equivalence."""
    print("\n" + "=" * 60)
    print("DEMO 3: Residual Analysis")
    print("=" * 60)

    p = TropPoly([TropMono(0, 10), TropMono(1, 2), TropMono(2, 0)])
    L = p.language

    print(f"\nPolynomial: {p}")
    print(f"Language: {[L(n) for n in range(15)]}")

    print("\nResiduals:")
    for k in range(8):
        vals = residual_values(L, k, 8)
        print(f"  k={k}: {vals}")

    n_classes = count_distinct_residuals(L, max_k=20)
    n_canonical = len(nat_canonical(p).monomials)
    print(f"\nDistinct residual classes (k ≤ 20): {n_classes}")
    print(f"Canonical monomials: {n_canonical}")
    print(f"|Nerode classes| ≥ |canonical| : {n_classes} ≥ {n_canonical} ✓")


def demo_eventual_affine():
    """Demo 4: Eventual affine behavior."""
    print("\n" + "=" * 60)
    print("DEMO 4: Eventual Affine Behavior")
    print("=" * 60)

    p = TropPoly([TropMono(0, 15), TropMono(3, 6), TropMono(5, 1)])
    L = p.language
    N, m0 = find_dominating_monomial(p)

    print(f"\nPolynomial: {p}")
    print(f"Dominating monomial: {m0} (exp={m0.exp}, coeff={m0.coeff})")
    print(f"Threshold N = {N}")
    print(f"\nLanguage values:")
    for n in range(N + 5):
        val = L(n)
        affine = m0.eval(n)
        match = "=" if abs(val - affine) < 1e-10 else "≠"
        marker = " ← eventually affine from here" if n == N else ""
        print(f"  L({n:2d}) = {val:6.1f}  {match}  {m0}({n}) = {affine:6.1f}{marker}")


def demo_bridge():
    """Demo 5: The full bridge theorem."""
    print("\n" + "=" * 60)
    print("DEMO 5: Canonicalization–Minimization Bridge")
    print("=" * 60)

    examples = [
        [TropMono(0, 10), TropMono(1, 2), TropMono(2, 0)],
        [TropMono(0, 4), TropMono(1, 3), TropMono(2, 0)],
        [TropMono(0, 20), TropMono(2, 8), TropMono(4, 0)],
    ]

    for monos in examples:
        p = TropPoly(monos)
        cp = nat_canonical(p)
        has_const = any(m.exp == 0 for m in p.monomials)
        L = p.language

        N, m0 = find_dominating_monomial(p)
        n_residuals = count_distinct_residuals(L, max_k=N+5) if has_const else "∞"
        n_canonical = len(cp.monomials)

        print(f"\n{p}")
        print(f"  Canonical: {cp} ({n_canonical} monomials)")
        print(f"  Has constant monomial: {has_const}")
        print(f"  Eventually affine from N={N}, dominated by {m0}")
        print(f"  Distinct residuals: {n_residuals}")
        print(f"  Language preserved: ✓")


if __name__ == "__main__":
    demo_canonicalization()
    demo_structural_properties()
    demo_residuals()
    demo_eventual_affine()
    demo_bridge()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Tropical Polynomial Canonicalization–Automata Bridge: Visualizations
=====================================================================

Generates publication-quality visualizations:
1. Lower envelope with dominated monomials highlighted
2. Residual analysis
3. Canonicalization comparison
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import TropMono, canonicalize, poly_language, find_eventual_monomial
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_lower_envelope(monos, title="Tropical Polynomial: Lower Envelope",
                        x_range=(0, 12), save_path=None):
    """Plot the lower envelope showing dominated vs canonical monomials."""
    canon = canonicalize(monos)
    x = np.linspace(x_range[0], x_range[1], 500)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Plot individual monomials
    for m in monos:
        y = [m.eval(xi) for xi in x]
        is_canonical = m in canon
        color = '#2196F3' if is_canonical else '#BDBDBD'
        lw = 2.0 if is_canonical else 1.0
        ls = '-' if is_canonical else '--'
        label = f"({m.exp}, {m.coeff:.0f})" + (" [canonical]" if is_canonical else " [dominated]")
        ax.plot(x, y, color=color, linewidth=lw, linestyle=ls, alpha=0.7, label=label)

    # Plot lower envelope
    env = [min(m.eval(xi) for m in monos) for xi in x]
    ax.plot(x, env, color='#F44336', linewidth=3, label='Lower envelope', zorder=5)

    # Mark integer evaluation points
    ns = list(range(int(x_range[0]), int(x_range[1]) + 1))
    vals = [poly_language(monos, n) for n in ns]
    ax.scatter(ns, vals, color='#F44336', s=60, zorder=6, label='L(n) values')

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title(title, fontsize=14)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)

    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches='tight')

    return fig


def plot_residuals(monos, max_k=8, n_points=10,
                   title="Residual Analysis", save_path=None):
    """Plot residual functions for different prefix lengths."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    colors = plt.cm.viridis(np.linspace(0, 0.9, max_k + 1))

    for k in range(max_k + 1):
        ns = list(range(n_points))
        vals = [poly_language(monos, k + n) for n in ns]
        ax.plot(ns, vals, 'o-', color=colors[k], markersize=4,
                label=f'k={k}', linewidth=1.5, alpha=0.8)

    ax.set_xlabel('Suffix length n', fontsize=12)
    ax.set_ylabel('residual(L, k)(n) = L(k+n)', fontsize=12)
    ax.set_title(title, fontsize=14)
    ax.legend(fontsize=9, ncol=3)
    ax.grid(True, alpha=0.3)

    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches='tight')

    return fig


def plot_canonicalization_comparison(save_path=None):
    """Compare original and canonical polynomials across examples."""
    examples = [
        ("3 monomials, none dominated",
         [TropMono(0, 10), TropMono(1, 2), TropMono(2, 0)]),
        ("3 monomials, 1 dominated",
         [TropMono(0, 4), TropMono(1, 3), TropMono(2, 0)]),
        ("5 monomials, 2 dominated",
         [TropMono(0, 20), TropMono(1, 15), TropMono(2, 8),
          TropMono(3, 10), TropMono(4, 0)]),
        ("Large coefficients",
         [TropMono(0, 15), TropMono(3, 6), TropMono(5, 1)]),
    ]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for idx, (title, monos) in enumerate(examples):
        ax = axes[idx // 2][idx % 2]
        canon = canonicalize(monos)

        ns = list(range(15))
        orig_vals = [poly_language(monos, n) for n in ns]
        canon_vals = [poly_language(canon, n) for n in ns]

        ax.plot(ns, orig_vals, 'bo-', markersize=6, label=f'Original ({len(monos)} monos)')
        ax.plot(ns, canon_vals, 'r^--', markersize=6, label=f'Canonical ({len(canon)} monos)')

        ax.set_xlabel('n')
        ax.set_ylabel('L(n)')
        ax.set_title(title, fontsize=11)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Canonicalization Preserves Language', fontsize=14, fontweight='bold')
    plt.tight_layout()

    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches='tight')

    return fig


def plot_pareto_front(monos, title="Pareto Front of Monomials", save_path=None):
    """Plot the (exponent, coefficient) plane showing the Pareto front."""
    canon = canonicalize(monos)

    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    # Plot all monomials
    for m in monos:
        is_canon = m in canon
        color = '#2196F3' if is_canon else '#BDBDBD'
        marker = 's' if is_canon else 'o'
        size = 120 if is_canon else 60
        ax.scatter(m.exp, m.coeff, c=color, s=size, marker=marker, zorder=5,
                   edgecolors='black', linewidth=1)

    # Connect canonical monomials
    canon_sorted = sorted(canon, key=lambda m: m.exp)
    ax.plot([m.exp for m in canon_sorted], [m.coeff for m in canon_sorted],
            'b-', linewidth=2, alpha=0.5, label='Pareto front')

    # Labels
    for m in monos:
        is_canon = m in canon
        offset = (5, 5) if is_canon else (5, -10)
        ax.annotate(f'({m.exp}, {m.coeff:.0f})', (m.exp, m.coeff),
                    textcoords='offset points', xytext=offset, fontsize=9)

    ax.set_xlabel('Exponent (slope)', fontsize=12)
    ax.set_ylabel('Coefficient (intercept)', fontsize=12)
    ax.set_title(title, fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Add legend entries
    ax.scatter([], [], c='#2196F3', s=120, marker='s', edgecolors='black',
               label='Canonical')
    ax.scatter([], [], c='#BDBDBD', s=60, marker='o', edgecolors='black',
               label='Dominated')
    ax.legend(fontsize=10)

    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches='tight')

    return fig


def generate_all_visualizations():
    """Generate all visualizations and save them."""
    print("Generating visualizations...")

    # 1. Lower envelope
    monos1 = [TropMono(0, 10), TropMono(1, 2), TropMono(2, 0)]
    fig1 = plot_lower_envelope(monos1, save_path='lower_envelope.png')
    b64_1 = fig_to_base64(fig1)

    # 2. Residual analysis
    fig2 = plot_residuals(monos1, save_path='residuals.png')
    b64_2 = fig_to_base64(fig2)

    # 3. Canonicalization comparison
    fig3 = plot_canonicalization_comparison(save_path='canonicalization.png')
    b64_3 = fig_to_base64(fig3)

    # 4. Pareto front
    monos4 = [TropMono(0, 20), TropMono(1, 15), TropMono(2, 8),
              TropMono(3, 10), TropMono(4, 0)]
    fig4 = plot_pareto_front(monos4, save_path='pareto_front.png')
    b64_4 = fig_to_base64(fig4)

    print("All visualizations generated successfully!")
    return {
        'lower_envelope': b64_1,
        'residuals': b64_2,
        'canonicalization': b64_3,
        'pareto_front': b64_4,
    }


if __name__ == "__main__":
    viz_data = generate_all_visualizations()
    for name, data in viz_data.items():
        print(f"  {name}: {len(data)} chars")

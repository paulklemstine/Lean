#!/usr/bin/env python3
"""
Applications of Tropical Envelope Canonicalization.

This module demonstrates real-world applications of the envelope
canonicalization theory in machine learning, optimization, and
automata theory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple


# ============================================================
# APPLICATION 1: Neural Network Pruning via Tropical Analysis
# ============================================================

def tropical_relu_network_pruning():
    """
    Application to neural network pruning.

    A single-layer ReLU network with weights w_i and biases b_i computes:
        f(x) = max_i(w_i * x + b_i) = -min_i(-w_i * x - b_i)

    The negative of this is a tropical polynomial. Envelope canonicalization
    identifies which neurons are "dead" (never contribute to the output)
    and can be safely pruned without changing the network's behavior.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Network Pruning")
    print("=" * 60)

    # Simulate a ReLU network with 8 neurons
    np.random.seed(42)
    n_neurons = 8
    weights = np.random.randn(n_neurons) * 2
    biases = np.random.randn(n_neurons) * 3

    print(f"\nOriginal network: {n_neurons} neurons")
    print("  Neuron  |  Weight  |  Bias")
    print("  --------|----------|-------")
    for i in range(n_neurons):
        print(f"    {i}     | {weights[i]:7.3f} | {biases[i]:7.3f}")

    # Convert to tropical polynomial (negate for min-plus)
    # Each neuron i contributes: -b_i + (-w_i) * x
    monomials = []
    for i in range(n_neurons):
        monomials.append((-biases[i], -weights[i]))  # (coeff, slope) for min

    # Find envelope (which neurons are essential)
    xs = np.linspace(-10, 10, 10000)
    essential = set()
    for x in xs:
        vals = [c + s * x for c, s in monomials]
        min_val = min(vals)
        for i, v in enumerate(vals):
            if abs(v - min_val) < 1e-10:
                essential.add(i)

    pruned = set(range(n_neurons)) - essential
    print(f"\nEssential neurons (envelope): {sorted(essential)}")
    print(f"Prunable neurons: {sorted(pruned)}")
    print(f"Compression: {n_neurons} → {len(essential)} neurons "
          f"({100 * (1 - len(essential)/n_neurons):.0f}% reduction)")

    # Verify semantics preservation
    test_points = np.linspace(-10, 10, 1000)
    full_output = np.array([max(weights[i] * x + biases[i] for i in range(n_neurons))
                           for x in test_points])
    pruned_output = np.array([max(weights[i] * x + biases[i] for i in essential)
                             for x in test_points])
    max_error = np.max(np.abs(full_output - pruned_output))
    print(f"Max approximation error after pruning: {max_error:.2e}")

    # Visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    for i in range(n_neurons):
        ys = weights[i] * test_points + biases[i]
        if i in essential:
            ax1.plot(test_points, ys, linewidth=2, label=f'Neuron {i} (essential)')
        else:
            ax1.plot(test_points, ys, '--', linewidth=1, alpha=0.3,
                    label=f'Neuron {i} (prunable)')

    ax1.plot(test_points, full_output, 'k-', linewidth=3, alpha=0.3,
            label='Network output')
    ax1.set_xlabel('Input x')
    ax1.set_ylabel('Output')
    ax1.set_title('ReLU Network: Essential vs Prunable Neurons')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    ax2.plot(test_points, full_output, 'b-', linewidth=2, label='Full network')
    ax2.plot(test_points, pruned_output, 'r--', linewidth=2, label='Pruned network')
    ax2.set_xlabel('Input x')
    ax2.set_ylabel('Output')
    ax2.set_title('Full vs Pruned Network Output')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.suptitle('Neural Network Pruning via Tropical Envelope', fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_neural_pruning.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: viz_neural_pruning.png")


# ============================================================
# APPLICATION 2: Shortest Path Optimization
# ============================================================

def parametric_shortest_path():
    """
    Application to parametric shortest paths.

    In a network with edge costs c_e + w_e * λ (affine in parameter λ),
    the shortest path cost is a tropical polynomial in λ.
    Envelope canonicalization identifies which paths are ever optimal
    and for which parameter ranges.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Parametric Shortest Path")
    print("=" * 60)

    # Define 5 paths with affine costs: cost_i(λ) = a_i + b_i * λ
    paths = [
        ("Route A (highway)", 10, 0.5),   # Fixed cost 10, low fuel
        ("Route B (city)", 3, 2.0),       # Low fixed, high fuel
        ("Route C (scenic)", 15, 0.2),    # High fixed, very low fuel
        ("Route D (toll road)", 8, 1.0),  # Medium
        ("Route E (shortcut)", 5, 1.5),   # Medium-low fixed, medium fuel
    ]

    print("\nPaths (cost = fixed + fuel_rate × fuel_price):")
    for name, a, b in paths:
        print(f"  {name}: {a} + {b} × λ")

    # Find envelope: which paths are ever optimal
    lambdas = np.linspace(0, 20, 10000)
    essential_paths = set()
    optimal_cost = np.zeros_like(lambdas)

    for j, lam in enumerate(lambdas):
        costs = [a + b * lam for _, a, b in paths]
        min_cost = min(costs)
        optimal_cost[j] = min_cost
        for i, c in enumerate(costs):
            if abs(c - min_cost) < 1e-10:
                essential_paths.add(i)

    non_essential = set(range(len(paths))) - essential_paths
    print(f"\nOptimal paths (envelope): {[paths[i][0] for i in sorted(essential_paths)]}")
    print(f"Never-optimal paths: {[paths[i][0] for i in sorted(non_essential)]}")

    # Find transition points
    print("\nTransition points (fuel price thresholds):")
    for i in range(len(paths)):
        for j in range(i + 1, len(paths)):
            if paths[i][2] != paths[j][2]:  # Different slopes
                cp = (paths[i][1] - paths[j][1]) / (paths[j][2] - paths[i][2])
                if 0 <= cp <= 20:
                    print(f"  λ = {cp:.2f}: {paths[i][0]} ↔ {paths[j][0]}")

    # Visualization
    fig, ax = plt.subplots(figsize=(10, 6))
    colors = plt.cm.Set2(np.linspace(0, 1, len(paths)))

    for i, (name, a, b) in enumerate(paths):
        ys = a + b * lambdas
        if i in essential_paths:
            ax.plot(lambdas, ys, color=colors[i], linewidth=2, label=f'{name} ★')
        else:
            ax.plot(lambdas, ys, color=colors[i], linewidth=1, linestyle='--',
                   alpha=0.4, label=f'{name} (never optimal)')

    ax.plot(lambdas, optimal_cost, 'k-', linewidth=3, alpha=0.3,
           label='Optimal cost (envelope)')
    ax.set_xlabel('Fuel price λ', fontsize=12)
    ax.set_ylabel('Total path cost', fontsize=12)
    ax.set_title('Parametric Shortest Path: Active Constraints = Envelope Monomials',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('viz_shortest_path.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: viz_shortest_path.png")


# ============================================================
# APPLICATION 3: Weighted Automaton State Minimization
# ============================================================

def automaton_minimization():
    """
    Application to weighted automaton minimization.

    A tropical weighted automaton computes a function ℕ → ℝ by taking
    the minimum over finitely many affine state contributions.
    The envelope-canonical form gives the minimal number of states
    needed to realize the same function.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Weighted Automaton Minimization")
    print("=" * 60)

    # States with affine cost functions
    states = [
        ("State 0 (idle)", 0, 2),       # exp=0 means constant cost
        ("State 1 (slow)", 1, 0),       # Linear growth
        ("State 2 (fast)", 2, -1),      # Quadratic-like growth
        ("State 3 (turbo)", 3, -3),     # Fast growth, low start
        ("State 4 (eco)", 1, 1),        # Same slope as State 1, different offset
    ]

    monomials = [(e, c) for _, e, c in states]

    print(f"\nOriginal automaton: {len(states)} states")
    for name, e, c in states:
        print(f"  {name}: cost(n) = {c} + {e}*n")

    # Compute envelope
    envelope_indices = set()
    for n in range(200):
        vals = [c + e * n for _, e, c in states]
        min_val = min(vals)
        for i, v in enumerate(vals):
            if abs(v - min_val) < 1e-10:
                envelope_indices.add(i)

    # Compute Pareto (NatCanonical)
    pareto_indices = set()
    for i, (_, e1, c1) in enumerate(states):
        dominated = False
        for j, (_, e2, c2) in enumerate(states):
            if i == j:
                continue
            if e2 <= e1 and c2 <= c1 and (e2 < e1 or c2 < c1):
                dominated = True
                break
        if not dominated:
            pareto_indices.add(i)

    print(f"\nEnvelope-essential states: {[states[i][0] for i in sorted(envelope_indices)]}")
    print(f"Pareto-essential states:  {[states[i][0] for i in sorted(pareto_indices)]}")
    print(f"\nMinimal automaton: {len(envelope_indices)} states "
          f"(reduced from {len(states)})")
    if pareto_indices != envelope_indices:
        diff = pareto_indices - envelope_indices
        print(f"Coalition-dominated (Pareto but not envelope): "
              f"{[states[i][0] for i in diff]}")

    # Visualization
    fig, ax = plt.subplots(figsize=(10, 6))
    ns = np.arange(0, 15)
    colors = plt.cm.tab10(np.linspace(0, 1, len(states)))

    for i, (name, e, c) in enumerate(states):
        ys = [c + e * n for n in ns]
        if i in envelope_indices:
            ax.plot(ns, ys, 'o-', color=colors[i], linewidth=2, markersize=6,
                   label=f'{name} ★')
        elif i in pareto_indices:
            ax.plot(ns, ys, 's--', color=colors[i], linewidth=1.5, markersize=4,
                   alpha=0.5, label=f'{name} (Pareto only)')
        else:
            ax.plot(ns, ys, 'x:', color=colors[i], linewidth=1, markersize=3,
                   alpha=0.3, label=f'{name} (dominated)')

    # Lower envelope
    env_ys = [min(c + e * n for _, e, c in states) for n in ns]
    ax.plot(ns, env_ys, 'k-', linewidth=3, alpha=0.3, label='Output (min)')

    ax.set_xlabel('Input n', fontsize=12)
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Weighted Automaton: Envelope = Minimal State Set', fontsize=13,
                fontweight='bold')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('viz_automaton.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: viz_automaton.png")


if __name__ == "__main__":
    tropical_relu_network_pruning()
    parametric_shortest_path()
    automaton_minimization()
    print("\n\nAll applications completed successfully.")


#!/usr/bin/env python3
import base64, json, os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def encode_image(path):
    if not os.path.exists(path):
        return ''
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode()
    return f'data:image/png;base64,{data}'

article = read_file('ARTICLE.md')
paper = read_file('RESEARCH_PAPER.md')
future = read_file('FUTURE_DIRECTIONS.md')
lean = read_file('Catalog/Bridges/TropicalEnvelopeMinimization/EnvelopeCanonical.lean')
demo_code = read_file('demo.py')
algo_code = read_file('algorithms.py')
app_code = read_file('applications.py')

viz_files = ['viz_basic_envelope.png', 'viz_coalition_domination.png',
             'viz_generic_position.png', 'viz_neural_pruning.png',
             'viz_shortest_path.png', 'viz_automaton.png']

visualizations = []
for vf in viz_files:
    if os.path.exists(vf):
        visualizations.append({
            'name': vf.replace('viz_', '').replace('.png', '').replace('_', ' ').title(),
            'data': encode_image(vf)
        })

pseudocode = "For each monomial m in p:\n  For n = 0, 1, ..., N:\n    If m(n) <= m'(n) for all m' in p:\n      Mark m as essential; break\nReturn essential monomials"

package = {
    'title': 'Envelope Canonicalization and Exact Minimization for Tropical Polynomials',
    'domain': 'Tropical Geometry / Weighted Automata Theory',
    'article': article,
    'research_paper': paper,
    'future_directions': future,
    'demos': [
        {'name': 'Tropical Envelope Demo', 'code': demo_code},
        {'name': 'Applications Demo', 'code': app_code}
    ],
    'algorithms': [
        {
            'name': 'Envelope Canonical Form',
            'pseudocode': pseudocode,
            'code': algo_code
        }
    ],
    'visualizations': visualizations,
    'lean_proofs': lean
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f'Package created: {os.path.getsize("PACKAGE.json")} bytes')
print(f'Visualizations: {len(visualizations)}')


#!/usr/bin/env python3
"""
Demonstration of Tropical Envelope Canonicalization.

This script demonstrates the key theorems from the formally verified theory
of envelope canonicalization for tropical polynomials. A tropical polynomial
p(x) = min_i(c_i + e_i * x) is the lower envelope of finitely many affine
functions. Envelope canonicalization identifies the monomials that actually
attain the minimum at some natural number — the semantic core of the polynomial.

Key demonstrations:
1. Semantics preservation: removing non-envelope monomials preserves evaluation
2. Coalition domination: a monomial can survive pairwise comparison but be
   hidden by a coalition of competitors
3. Generic position and strict witnesses
4. Exact minimality under generic position
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple, Optional

# A monomial is (exp, coeff), representing the affine function coeff + exp * x
Monomial = Tuple[int, float]  # (exponent, coefficient)


def mono_eval(m: Monomial, x: float) -> float:
    """Evaluate monomial m at point x: coeff + exp * x."""
    return m[1] + m[0] * x


def poly_eval(p: List[Monomial], x: float) -> float:
    """Evaluate tropical polynomial at x: min over all monomials."""
    return min(mono_eval(m, x) for m in p)


def envelope_canonical(p: List[Monomial], max_n: int = 1000) -> List[Monomial]:
    """
    Compute the envelope-canonical form: keep monomials that attain the
    minimum at some n in {0, 1, ..., max_n}.
    """
    envelope = []
    for m in p:
        for n in range(max_n + 1):
            val = mono_eval(m, n)
            if all(val <= mono_eval(m2, n) for m2 in p):
                envelope.append(m)
                break
    return envelope


def nat_canonical(p: List[Monomial]) -> List[Monomial]:
    """
    Compute the ℕ-canonical form: keep monomials not pointwise dominated
    on ℕ by any single competitor.
    """
    canonical = []
    for m in p:
        dominated = False
        for m2 in p:
            if m2 == m:
                continue
            # Check if m2 NatDominates m: m2.exp <= m.exp and m2.coeff <= m.coeff
            if m2[0] <= m[0] and m2[1] <= m[1] and m2 != m:
                dominated = True
                break
        if not dominated:
            canonical.append(m)
    return canonical


def is_generic_position(p: List[Monomial], max_n: int = 10000) -> bool:
    """Check if monomials are in generic position (no ties at natural numbers)."""
    for i, m1 in enumerate(p):
        for j, m2 in enumerate(p):
            if i >= j:
                continue
            for n in range(max_n + 1):
                if abs(mono_eval(m1, n) - mono_eval(m2, n)) < 1e-12:
                    return False
    return True


def strict_witness(p: List[Monomial], m: Monomial, max_n: int = 10000) -> Optional[int]:
    """Find a strict witness: n where m is the unique minimizer."""
    for n in range(max_n + 1):
        val = mono_eval(m, n)
        if all(val < mono_eval(m2, n) - 1e-12 for m2 in p if m2 != m):
            return n
    return None


# ============================================================
# DEMO 1: Basic Envelope Canonicalization
# ============================================================
print("=" * 60)
print("DEMO 1: Basic Envelope Canonicalization")
print("=" * 60)

p1 = [(0, 3), (1, 0), (2, -2)]
print(f"\nPolynomial p = {p1}")
print("Monomials:")
for m in p1:
    print(f"  m(x) = {m[1]} + {m[0]}*x")

env1 = envelope_canonical(p1)
nat1 = nat_canonical(p1)
print(f"\nEnvelope canonical: {env1}")
print(f"Nat canonical:     {nat1}")

# Verify semantics preservation
print("\nSemantics preservation check:")
for n in range(10):
    full_val = poly_eval(p1, n)
    env_val = poly_eval(env1, n)
    print(f"  n={n}: full={full_val:.1f}, envelope={env_val:.1f}, match={abs(full_val-env_val)<1e-10}")


# ============================================================
# DEMO 2: Coalition Domination
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Coalition Domination")
print("=" * 60)

# m₂ is not dominated by any single monomial but is hidden by the coalition {m₁, m₃}
p2 = [(0, 0), (1, -1), (2, -3)]
print(f"\nPolynomial p = {p2}")
print("Monomials:")
for m in p2:
    print(f"  m(x) = {m[1]} + {m[0]}*x")

env2 = envelope_canonical(p2)
nat2 = nat_canonical(p2)
print(f"\nEnvelope canonical: {env2}")
print(f"Nat canonical:     {nat2}")
print(f"\nNote: (1, -1) is in NatCanonical but NOT in EnvelopeCanonical!")
print("It is 'coalition-dominated' by {(0,0), (2,-3)} — neither dominates it alone,")
print("but together they hide it at every natural number.")


# ============================================================
# DEMO 3: Generic Position and Strict Witnesses
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Generic Position and Strict Witnesses")
print("=" * 60)

# Generic position: crossing points avoid integers
p3 = [(0, 2.7), (1, 0.3), (2, -1.8)]
print(f"\nPolynomial p = {p3}")
print(f"Generic position: {is_generic_position(p3)}")

env3 = envelope_canonical(p3)
print(f"Envelope canonical: {env3}")

for m in env3:
    w = strict_witness(p3, m)
    print(f"  Monomial {m}: strict witness at n={w}")


# ============================================================
# DEMO 4: Exact Minimality (Flagship Theorem)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Exact Minimality (Flagship Theorem)")
print("=" * 60)

p4 = [(0, 5.1), (1, 1.3), (3, -4.7)]
print(f"\nPolynomial p = {p4}")
print(f"Generic position: {is_generic_position(p4)}")

env4 = envelope_canonical(p4)
print(f"Envelope canonical: {env4} (size = {len(env4)})")

# Show that removing any envelope monomial changes semantics
for m in env4:
    sub = [m2 for m2 in p4 if m2 != m]
    differs = False
    for n in range(100):
        if abs(poly_eval(sub, n) - poly_eval(p4, n)) > 1e-10:
            differs = True
            print(f"  Removing {m}: changes semantics at n={n} "
                  f"(was {poly_eval(p4, n):.2f}, became {poly_eval(sub, n):.2f})")
            break
    if not differs:
        print(f"  Removing {m}: semantics UNCHANGED (should not happen in generic position)")

# Show that the envelope sub-polynomial preserves semantics
print(f"\nSemantics preservation:")
all_match = True
for n in range(100):
    if abs(poly_eval(env4, n) - poly_eval(p4, n)) > 1e-10:
        all_match = False
        break
print(f"  polyEval(envelope, n) = polyEval(p, n) for n=0..99: {all_match}")


# ============================================================
# DEMO 5: Counterexample — Envelope ⊄ NatCanonical without genericity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Without genericity, Envelope ⊄ NatCanonical")
print("=" * 60)

p5 = [(0, 0), (1, 0)]  # Two monomials with same coeff, different exp
print(f"\nPolynomial p = {p5}")
print("m₁(n) = 0, m₂(n) = n")
print(f"At n=0: m₁(0)=0, m₂(0)=0 → TIE → both in EnvelopeCanonical")

env5 = envelope_canonical(p5)
nat5 = nat_canonical(p5)
print(f"Envelope canonical: {env5}")
print(f"Nat canonical:     {nat5}")
print("(1, 0) is in Envelope (ties at n=0) but NOT in NatCanonical (dominated by (0, 0))")
print("This shows Envelope ⊄ NatCanonical without generic position!")


# ============================================================
# VISUALIZATION
# ============================================================
def plot_tropical_polynomial(p: List[Monomial], title: str, filename: str):
    """Plot the monomials and lower envelope of a tropical polynomial."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ns = np.arange(0, 15)
    xs = np.linspace(0, 15, 300)

    # Left plot: continuous view
    colors = plt.cm.Set1(np.linspace(0, 1, len(p)))
    env = envelope_canonical(p)

    for i, m in enumerate(p):
        ys = [mono_eval(m, x) for x in xs]
        in_env = m in env
        ax1.plot(xs, ys, color=colors[i],
                linewidth=2 if in_env else 1,
                linestyle='-' if in_env else '--',
                alpha=1.0 if in_env else 0.4,
                label=f'{"★ " if in_env else ""}({m[0]}, {m[1]:.1f})')

    # Lower envelope
    env_ys = [poly_eval(p, x) for x in xs]
    ax1.plot(xs, env_ys, 'k-', linewidth=3, alpha=0.3, label='Lower envelope')

    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Monomials and Lower Envelope', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Right plot: discrete (ℕ) evaluation
    for i, m in enumerate(p):
        ys = [mono_eval(m, n) for n in ns]
        in_env = m in env
        ax2.scatter(ns, ys, color=colors[i], s=60 if in_env else 20,
                   marker='o' if in_env else 'x',
                   alpha=1.0 if in_env else 0.4,
                   zorder=3 if in_env else 2)

    # Lower envelope at integers
    env_ys = [poly_eval(p, n) for n in ns]
    ax2.scatter(ns, env_ys, color='black', s=100, marker='D', alpha=0.3,
               zorder=4, label='min value')
    ax2.plot(ns, env_ys, 'k--', alpha=0.3)

    # Mark strict witnesses
    for m in env:
        w = strict_witness(p, m)
        if w is not None and w <= max(ns):
            ax2.annotate(f'witness', xy=(w, mono_eval(m, w)),
                        xytext=(w + 0.5, mono_eval(m, w) - 1),
                        fontsize=8, color='red',
                        arrowprops=dict(arrowstyle='->', color='red'))

    ax2.set_xlabel('n (natural number)', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title('Discrete Evaluation on ℕ', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    fig.suptitle(title, fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\nSaved visualization: {filename}")


# Generate visualizations
plot_tropical_polynomial(
    [(0, 3), (1, 0), (2, -2)],
    "Basic Envelope Canonicalization",
    "viz_basic_envelope.png"
)

plot_tropical_polynomial(
    [(0, 0), (1, -1), (2, -3)],
    "Coalition Domination: Middle Monomial Hidden",
    "viz_coalition_domination.png"
)

plot_tropical_polynomial(
    [(0, 2.7), (1, 0.3), (2, -1.8)],
    "Generic Position: All Monomials Have Strict Witnesses",
    "viz_generic_position.png"
)


# ============================================================
# DEMO 6: Scaling behavior
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Envelope vs NatCanonical Size (Random Polynomials)")
print("=" * 60)

np.random.seed(42)
for num_monomials in [5, 10, 20, 50]:
    env_sizes = []
    nat_sizes = []
    for trial in range(100):
        # Random monomials with distinct integer slopes and random coefficients
        exps = list(range(num_monomials))
        coeffs = np.random.randn(num_monomials) * 10
        p = [(e, c) for e, c in zip(exps, coeffs)]
        env = envelope_canonical(p, max_n=500)
        nat = nat_canonical(p)
        env_sizes.append(len(env))
        nat_sizes.append(len(nat))

    print(f"  {num_monomials} monomials: "
          f"Envelope avg={np.mean(env_sizes):.1f}±{np.std(env_sizes):.1f}, "
          f"NatCanonical avg={np.mean(nat_sizes):.1f}±{np.std(nat_sizes):.1f}")

print("\nAll demonstrations completed successfully.")

#!/usr/bin/env python3
"""
Applications of Karchmer-Wigderson Theory

Demonstrates practical applications:
1. Circuit depth optimization analysis
2. Communication protocol design
3. Lower bound certificates for specific functions
"""

from itertools import product, combinations
import math

def or_fn(x): return any(b == 1 for b in x)
def and_fn(x): return all(b == 1 for b in x)
def threshold_fn(k):
    def f(x): return sum(x) >= k
    return f

def has_clique(adj_matrix, k):
    """Check if a graph (given as adjacency matrix) has a k-clique."""
    n = len(adj_matrix)
    for subset in combinations(range(n), k):
        if all(adj_matrix[i][j] for i, j in combinations(subset, 2)):
            return True
    return False

# ═══════════════════════════════════════════════════════════════════════
# Application 1: Optimal Formula Depth Analysis
# ═══════════════════════════════════════════════════════════════════════

def analyze_optimal_depths():
    """Analyze the optimal monotone formula depth for various functions."""
    print("Application 1: Optimal Formula Depth Analysis")
    print("=" * 55)

    for n in range(2, 7):
        inputs = list(product([0, 1], repeat=n))

        functions = {
            f"OR_{n}": or_fn,
            f"AND_{n}": and_fn,
            f"THR_{(n+1)//2},{n}": threshold_fn((n+1)//2),
        }

        print(f"\nn = {n}:")
        for name, f in functions.items():
            true_count = sum(1 for x in inputs if f(x))
            false_count = 2**n - true_count

            # KW lower bound via leaf counting
            # Each leaf covers at most max_leaf_coverage pairs
            max_leaf = 0
            for i in range(n):
                a = sum(1 for x in inputs if f(x) and x[i] == 1)
                b = sum(1 for y in inputs if not f(y) and y[i] == 0)
                max_leaf = max(max_leaf, a * b)

            total = true_count * false_count
            if max_leaf > 0 and total > 0:
                min_leaves = math.ceil(total / max_leaf)
                lb = math.ceil(math.log2(min_leaves)) if min_leaves > 1 else 0
            else:
                lb = 0

            print(f"  {name:12s}: |f⁻¹(1)| = {true_count:3d}, "
                  f"|f⁻¹(0)| = {false_count:3d}, "
                  f"depth lower bound ≥ {lb}")

# ═══════════════════════════════════════════════════════════════════════
# Application 2: Communication Protocol Design
# ═══════════════════════════════════════════════════════════════════════

def design_protocol_for_threshold():
    """Design and analyze KW protocols for threshold functions."""
    print("\n\nApplication 2: KW Protocols for Threshold Functions")
    print("=" * 55)

    for n in [4, 6, 8]:
        k = n // 2
        f = threshold_fn(k)
        inputs = list(product([0, 1], repeat=n))

        true_inputs = [x for x in inputs if f(x)]
        false_inputs = [y for y in inputs if not f(y)]

        print(f"\nThreshold({k}, {n}): ≥{k} of {n} bits true")
        print(f"  True inputs:  {len(true_inputs)}")
        print(f"  False inputs: {len(false_inputs)}")
        print(f"  Total pairs:  {len(true_inputs) * len(false_inputs)}")

        # Analyze rectangle structure
        best_rect = 0
        best_idx = -1
        for i in range(n):
            a = sum(1 for x in true_inputs if x[i] == 1)
            b = sum(1 for y in false_inputs if y[i] == 0)
            rect = a * b
            if rect > best_rect:
                best_rect = rect
                best_idx = i
            # print(f"    Index {i}: {a} × {b} = {rect}")

        coverage = best_rect / (len(true_inputs) * len(false_inputs)) * 100
        print(f"  Best rectangle: index {best_idx}, "
              f"covers {best_rect} pairs ({coverage:.1f}%)")

        total = len(true_inputs) * len(false_inputs)
        min_leaves = math.ceil(total / best_rect) if best_rect > 0 else total
        lb = math.ceil(math.log2(min_leaves)) if min_leaves > 1 else 0
        print(f"  Depth lower bound: ≥ {lb}")

# ═══════════════════════════════════════════════════════════════════════
# Application 3: Clique Function Analysis
# ═══════════════════════════════════════════════════════════════════════

def analyze_clique_function():
    """Analyze the monotone clique function on small graphs."""
    print("\n\nApplication 3: Clique Function on Small Graphs")
    print("=" * 55)

    for m in [3, 4, 5]:
        edges = list(combinations(range(m), 2))
        n_edges = len(edges)

        for k in [2, 3]:
            if k > m:
                continue

            # Enumerate all graphs as edge vectors
            count_true = 0
            count_false = 0
            for edge_vec in product([0, 1], repeat=n_edges):
                adj = [[0]*m for _ in range(m)]
                for idx, (i, j) in enumerate(edges):
                    if edge_vec[idx]:
                        adj[i][j] = adj[j][i] = 1
                if has_clique(adj, k):
                    count_true += 1
                else:
                    count_false += 1

            total_graphs = 2**n_edges
            print(f"\n  HasClique({k}) on {m} vertices ({n_edges} edges):")
            print(f"    Graphs with {k}-clique:    {count_true} / {total_graphs}")
            print(f"    Graphs without {k}-clique: {count_false} / {total_graphs}")

            if count_true > 0 and count_false > 0:
                # Simple lower bound
                total_pairs = count_true * count_false
                # Each edge can separate at most count_true pairs
                lb = math.ceil(math.log2(max(count_true, count_false)))
                print(f"    Naive depth lower bound:   ≥ {lb}")

# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    analyze_optimal_depths()
    design_protocol_for_threshold()
    analyze_clique_function()


#!/usr/bin/env python3
"""
Demo: Karchmer-Wigderson Correspondence and Monotone Formula Lower Bounds

This script demonstrates the key concepts from the formalized KW theory:
1. Monotone Boolean functions and formulas
2. The KW communication game
3. Formula-to-protocol and protocol-to-formula conversions
4. Concrete lower bound arguments
"""

from itertools import product
from typing import Callable

# ── Monotone Boolean Functions ──────────────────────────────────────────

def bitwise_le(x: tuple, y: tuple) -> bool:
    """Check if x ≤ y in the bitwise (product) ordering."""
    return all(xi <= yi for xi, yi in zip(x, y))

def is_monotone(f: Callable, n: int) -> bool:
    """Check if f is monotone on {0,1}^n."""
    inputs = list(product([0, 1], repeat=n))
    for x in inputs:
        for y in inputs:
            if bitwise_le(x, y) and f(x) and not f(y):
                return False
    return True

def or_fn(x: tuple) -> bool:
    return any(b == 1 for b in x)

def and_fn(x: tuple) -> bool:
    return all(b == 1 for b in x)

def threshold_fn(k: int):
    """Returns the threshold-k function: true iff ≥ k inputs are true."""
    def f(x: tuple) -> bool:
        return sum(x) >= k
    return f

# ── Monotone Formulas ───────────────────────────────────────────────────

class MonoFormula:
    """A monotone Boolean formula (tree of AND/OR gates, no negation)."""
    pass

class Var(MonoFormula):
    def __init__(self, i: int):
        self.i = i
    def eval(self, x):
        return x[self.i] == 1
    def depth(self):
        return 0
    def __repr__(self):
        return f"x{self.i}"

class And(MonoFormula):
    def __init__(self, left: MonoFormula, right: MonoFormula):
        self.left, self.right = left, right
    def eval(self, x):
        return self.left.eval(x) and self.right.eval(x)
    def depth(self):
        return 1 + max(self.left.depth(), self.right.depth())
    def __repr__(self):
        return f"({self.left} ∧ {self.right})"

class Or(MonoFormula):
    def __init__(self, left: MonoFormula, right: MonoFormula):
        self.left, self.right = left, right
    def eval(self, x):
        return self.left.eval(x) or self.right.eval(x)
    def depth(self):
        return 1 + max(self.left.depth(), self.right.depth())
    def __repr__(self):
        return f"({self.left} ∨ {self.right})"

# ── KW Communication Game ──────────────────────────────────────────────

def kw_witness(f, x, y, n):
    """Find a KW witness: index i where x[i]=1 and y[i]=0.
    Requires f(x)=True and f(y)=False and f is monotone."""
    for i in range(n):
        if x[i] == 1 and y[i] == 0:
            return i
    raise ValueError("No witness found (function may not be monotone)")

def formula_to_protocol_demo(phi: MonoFormula, x: tuple, y: tuple, depth=0):
    """Simulate the KW protocol derived from a monotone formula.
    Returns (witness_index, communication_log)."""
    indent = "  " * depth
    if isinstance(phi, Var):
        print(f"{indent}Leaf: output index {phi.i}")
        return phi.i, []

    if isinstance(phi, Or):
        # Alice node: Alice queries φ₁(x)
        q = phi.left.eval(x)
        print(f"{indent}Alice sends: {phi.left}(x) = {q}")
        if q:
            return formula_to_protocol_demo(phi.left, x, y, depth+1)
        else:
            return formula_to_protocol_demo(phi.right, x, y, depth+1)

    if isinstance(phi, And):
        # Bob node: Bob queries φ₁(y)
        q = phi.left.eval(y)
        print(f"{indent}Bob sends: {phi.left}(y) = {q}")
        if not q:
            return formula_to_protocol_demo(phi.left, x, y, depth+1)
        else:
            return formula_to_protocol_demo(phi.right, x, y, depth+1)

# ── Demonstrations ──────────────────────────────────────────────────────

def demo_monotonicity():
    """Demo 1: Verify monotonicity of common functions."""
    print("=" * 60)
    print("Demo 1: Monotonicity Verification")
    print("=" * 60)

    for n in [2, 3, 4]:
        print(f"\nn = {n}:")
        print(f"  OR  is monotone: {is_monotone(or_fn, n)}")
        print(f"  AND is monotone: {is_monotone(and_fn, n)}")
        print(f"  Threshold(⌈n/2⌉) is monotone: {is_monotone(threshold_fn((n+1)//2), n)}")

def demo_kw_game():
    """Demo 2: The KW communication game."""
    print("\n" + "=" * 60)
    print("Demo 2: KW Communication Game for OR₃")
    print("=" * 60)

    n = 3
    # Alice: x with OR(x) = True
    # Bob: y with OR(y) = False (must be all zeros)
    test_cases = [
        ((1, 0, 0), (0, 0, 0)),
        ((0, 1, 0), (0, 0, 0)),
        ((1, 1, 0), (0, 0, 0)),
        ((1, 1, 1), (0, 0, 0)),
    ]

    for x, y in test_cases:
        i = kw_witness(or_fn, x, y, n)
        print(f"  x={x}, y={y} → witness i={i} (x[{i}]=1, y[{i}]=0)")

def demo_formula_protocol():
    """Demo 3: Formula → Protocol conversion."""
    print("\n" + "=" * 60)
    print("Demo 3: Formula → Protocol Conversion")
    print("=" * 60)

    # OR₃ formula: (x₀ ∨ (x₁ ∨ x₂))
    phi = Or(Var(0), Or(Var(1), Var(2)))
    print(f"\nFormula: {phi}")
    print(f"Depth: {phi.depth()}")

    # Test with x = (0, 1, 0), y = (0, 0, 0)
    x, y = (0, 1, 0), (0, 0, 0)
    print(f"\nAlice's input x = {x} (OR = {or_fn(x)})")
    print(f"Bob's input y = {y} (OR = {or_fn(y)})")
    print("\nProtocol execution:")
    idx, _ = formula_to_protocol_demo(phi, x, y)
    print(f"\nResult: witness index = {idx}")
    print(f"Verification: x[{idx}]={x[idx]}, y[{idx}]={y[idx]}")

    # Another test
    x, y = (1, 0, 1), (0, 0, 0)
    print(f"\n--- Second test ---")
    print(f"Alice's input x = {x}, Bob's input y = {y}")
    print("Protocol execution:")
    idx, _ = formula_to_protocol_demo(phi, x, y)
    print(f"Result: witness index = {idx}")

def demo_lower_bound():
    """Demo 4: Lower bound argument for OR."""
    print("\n" + "=" * 60)
    print("Demo 4: Lower Bound Argument for OR")
    print("=" * 60)

    for n in [2, 3, 4, 5]:
        print(f"\nn = {n}:")

        # Try each possible leaf index
        all_fail = True
        for i in range(n):
            # Check if leaf i works: all x with OR(x)=True must have x[i]=1
            counterexample = None
            for x in product([0, 1], repeat=n):
                if or_fn(x) and x[i] == 0:
                    counterexample = x
                    break
            if counterexample:
                print(f"  Leaf i={i}: FAILS for x={counterexample} "
                      f"(OR={or_fn(counterexample)}, x[{i}]={counterexample[i]})")
            else:
                print(f"  Leaf i={i}: Works (all OR-true inputs have x[{i}]=1)")
                all_fail = False

        if all_fail:
            print(f"  → No single leaf works. KW cost ≥ 1. Formula depth ≥ 1. ✓")
        else:
            print(f"  → Some leaf works. KW cost could be 0.")

def demo_optimal_formulas():
    """Demo 5: Optimal formulas and their depths."""
    print("\n" + "=" * 60)
    print("Demo 5: Optimal Monotone Formulas")
    print("=" * 60)

    # Balanced OR tree for different n
    def balanced_or(variables):
        if len(variables) == 1:
            return variables[0]
        mid = len(variables) // 2
        return Or(balanced_or(variables[:mid]), balanced_or(variables[mid:]))

    for n in [1, 2, 3, 4, 8, 16]:
        vars_list = [Var(i) for i in range(n)]
        if n > 0:
            phi = balanced_or(vars_list)
            print(f"\n  OR_{n}: depth = {phi.depth()}, "
                  f"optimal = ⌈log₂({n})⌉ = {max(1, (n-1).bit_length()) if n > 1 else 0}")

            # Verify correctness
            correct = all(phi.eval(x) == or_fn(x)
                         for x in product([0, 1], repeat=n))
            print(f"         formula = {phi}")
            print(f"         correct: {correct}")

if __name__ == "__main__":
    demo_monotonicity()
    demo_kw_game()
    demo_formula_protocol()
    demo_lower_bound()
    demo_optimal_formulas()


#!/usr/bin/env python3
"""
Visualizations for Karchmer-Wigderson Theory

Generates matplotlib figures showing:
1. KW correspondence diagram
2. Formula depth vs KW cost comparison
3. Rectangle coverage heatmap for OR function
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product, combinations
import math
import base64
import io

def fig_to_base64(fig):
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"

def viz_kw_correspondence():
    """Visualize the KW correspondence as a diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 7)
    ax.axis('off')
    ax.set_title('Karchmer-Wigderson Correspondence', fontsize=16, fontweight='bold', pad=20)

    # Formula box
    rect1 = mpatches.FancyBboxPatch((0.5, 4), 3.5, 2.2, boxstyle="round,pad=0.2",
                                      facecolor='#E3F2FD', edgecolor='#1565C0', linewidth=2)
    ax.add_patch(rect1)
    ax.text(2.25, 5.5, 'Monotone\nFormula φ', ha='center', va='center', fontsize=14, fontweight='bold')
    ax.text(2.25, 4.3, f'depth(φ) = d', ha='center', va='center', fontsize=11, style='italic')

    # Protocol box
    rect2 = mpatches.FancyBboxPatch((6, 4), 3.5, 2.2, boxstyle="round,pad=0.2",
                                      facecolor='#FFF3E0', edgecolor='#E65100', linewidth=2)
    ax.add_patch(rect2)
    ax.text(7.75, 5.5, 'KW Protocol\nP', ha='center', va='center', fontsize=14, fontweight='bold')
    ax.text(7.75, 4.3, f'cost(P) = c', ha='center', va='center', fontsize=11, style='italic')

    # Arrows
    ax.annotate('', xy=(5.8, 5.8), xytext=(4.2, 5.8),
                arrowprops=dict(arrowstyle='->', lw=2.5, color='#2E7D32'))
    ax.text(5, 6.2, 'Theorem A\nc ≤ d', ha='center', fontsize=10, color='#2E7D32', fontweight='bold')

    ax.annotate('', xy=(4.2, 4.5), xytext=(5.8, 4.5),
                arrowprops=dict(arrowstyle='->', lw=2.5, color='#C62828'))
    ax.text(5, 4.0, 'Theorem B\nd ≤ c', ha='center', fontsize=10, color='#C62828', fontweight='bold')

    # Equals
    eq_box = mpatches.FancyBboxPatch((3.5, 1), 3, 1.5, boxstyle="round,pad=0.2",
                                       facecolor='#E8F5E9', edgecolor='#2E7D32', linewidth=2)
    ax.add_patch(eq_box)
    ax.text(5, 1.75, 'min depth = min cost', ha='center', va='center',
            fontsize=13, fontweight='bold', color='#1B5E20')

    # Arrow from boxes to equals
    ax.annotate('', xy=(3.5, 1.75), xytext=(2.25, 3.8),
                arrowprops=dict(arrowstyle='->', lw=1.5, color='gray', linestyle='--'))
    ax.annotate('', xy=(6.5, 1.75), xytext=(7.75, 3.8),
                arrowprops=dict(arrowstyle='->', lw=1.5, color='gray', linestyle='--'))

    # Lower bound box
    lb_box = mpatches.FancyBboxPatch((1.5, -0.5), 7, 1.2, boxstyle="round,pad=0.2",
                                       facecolor='#FCE4EC', edgecolor='#880E4F', linewidth=2)
    ax.add_patch(lb_box)
    ax.text(5, 0.1, 'Theorem C: Communication lower bound → Formula depth lower bound',
            ha='center', va='center', fontsize=11, fontweight='bold', color='#880E4F')

    ax.set_ylim(-1, 7)
    return fig_to_base64(fig)

def viz_depth_vs_cost():
    """Compare formula depth and KW cost for various functions."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Balanced OR tree depth vs n
    ns = list(range(1, 33))
    depths = [math.ceil(math.log2(n)) if n > 1 else 0 for n in ns]

    ax1.plot(ns, depths, 'b-o', markersize=4, label='⌈log₂ n⌉ (balanced tree)')
    ax1.plot(ns, [n-1 for n in ns], 'r--', alpha=0.5, label='n-1 (linear chain)')
    ax1.set_xlabel('Number of variables (n)', fontsize=12)
    ax1.set_ylabel('Formula depth', fontsize=12)
    ax1.set_title('OR Function: Formula Depth', fontsize=14, fontweight='bold')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Right: Threshold function depths (computed exactly for small n)
    for n in [4, 6, 8]:
        ks = list(range(1, n+1))
        bounds = []
        for k in ks:
            f = lambda x, k=k: sum(x) >= k
            inputs = list(product([0, 1], repeat=n))
            true_in = [x for x in inputs if f(x)]
            false_in = [x for x in inputs if not f(x)]

            if not true_in or not false_in:
                bounds.append(0)
                continue

            total = len(true_in) * len(false_in)
            max_rect = 0
            for i in range(n):
                a = sum(1 for x in true_in if x[i] == 1)
                b = sum(1 for y in false_in if y[i] == 0)
                max_rect = max(max_rect, a * b)

            if max_rect > 0:
                min_l = math.ceil(total / max_rect)
                bounds.append(math.ceil(math.log2(min_l)) if min_l > 1 else 0)
            else:
                bounds.append(0)

        ax2.plot(ks, bounds, '-o', markersize=5, label=f'n={n}')

    ax2.set_xlabel('Threshold k', fontsize=12)
    ax2.set_ylabel('Depth lower bound', fontsize=12)
    ax2.set_title('Threshold Functions: KW Lower Bounds', fontsize=14, fontweight='bold')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig_to_base64(fig)

def viz_rectangle_coverage():
    """Heatmap showing rectangle coverage for OR function."""
    n = 4
    inputs = list(product([0, 1], repeat=n))
    true_inputs = [x for x in inputs if any(b == 1 for b in x)]
    false_inputs = [x for x in inputs if not any(b == 1 for b in x)]

    # For threshold-2 function (more interesting structure)
    f = lambda x: sum(x) >= 2
    true_inputs = [x for x in inputs if f(x)]
    false_inputs = [x for x in inputs if not f(x)]

    fig, axes = plt.subplots(1, n, figsize=(16, 4))
    fig.suptitle(f'Rectangle Coverage for Threshold(2,4) KW Game\n'
                 f'({len(true_inputs)} true × {len(false_inputs)} false inputs)',
                 fontsize=14, fontweight='bold')

    for idx in range(n):
        ax = axes[idx]
        matrix = np.zeros((len(true_inputs), len(false_inputs)))
        for i, x in enumerate(true_inputs):
            for j, y in enumerate(false_inputs):
                if x[idx] == 1 and y[idx] == 0:
                    matrix[i, j] = 1

        ax.imshow(matrix, cmap='YlOrRd', aspect='auto', interpolation='nearest')
        coverage = matrix.sum() / matrix.size * 100
        ax.set_title(f'Index {idx}\n({coverage:.0f}%)', fontsize=11)
        ax.set_xlabel('Bob inputs', fontsize=9)
        if idx == 0:
            ax.set_ylabel('Alice inputs', fontsize=9)
        ax.tick_params(labelsize=7)

    fig.tight_layout()
    return fig_to_base64(fig)

if __name__ == "__main__":
    print("Generating visualizations...")
    v1 = viz_kw_correspondence()
    print(f"  KW correspondence: {len(v1)} bytes")
    v2 = viz_depth_vs_cost()
    print(f"  Depth vs cost: {len(v2)} bytes")
    v3 = viz_rectangle_coverage()
    print(f"  Rectangle coverage: {len(v3)} bytes")
    print("Done!")

    # Save as separate files too
    import base64 as b64
    for name, data in [("kw_correspondence.png", v1), ("depth_vs_cost.png", v2), ("rectangle_coverage.png", v3)]:
        header = "data:image/png;base64,"
        if data.startswith(header):
            raw = b64.b64decode(data[len(header):])
            with open(name, 'wb') as f:
                f.write(raw)
            print(f"  Saved {name}")

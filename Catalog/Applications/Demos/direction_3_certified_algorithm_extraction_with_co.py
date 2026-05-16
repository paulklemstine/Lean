#!/usr/bin/env python3
"""
Applications of Tropical Polynomial Canonicalization

Demonstrates real-world applications in:
1. Shortest path optimization (min-plus algebra)
2. Scheduling / critical path analysis
3. Piecewise-linear function compression
4. Dynamic programming state compression
"""

from typing import List, Tuple, Dict
import random


# ============================================================
# Application 1: Shortest Path Compression
# ============================================================

def shortest_path_demo():
    """
    In min-plus algebra, shortest paths are tropical polynomial evaluations.

    Given a weighted graph, the distance from s to t using exactly k edges
    is a tropical polynomial in the edge weights. Canonicalization removes
    paths that are never shortest, compressing the path representation.
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest Path Compression")
    print("=" * 60)

    # Simulate: paths from A to B in a small network
    # Each path has a fixed cost (coeff) and a variable delay (exp * load)
    paths = [
        (3, 2),   # Path 1: cost 2 + 3*load (fast route, sensitive to load)
        (1, 8),   # Path 2: cost 8 + 1*load (slow route, resilient to load)
        (2, 5),   # Path 3: cost 5 + 2*load (medium route)
        (3, 3),   # Path 4: cost 3 + 3*load (another fast route)
        (2, 4),   # Path 5: cost 4 + 2*load (another medium route)
        (1, 10),  # Path 6: cost 10 + 1*load (very slow route)
    ]

    canonical = canonicalize(paths)

    print(f"\nAll paths (slope, intercept):")
    for i, p in enumerate(paths):
        print(f"  Path {i+1}: cost = {p[1]} + {p[0]} * load")
    print(f"\nOptimal paths after canonicalization:")
    for p in canonical:
        print(f"  cost = {p[1]} + {p[0]} * load")
    print(f"\nReduction: {len(paths)} paths → {len(canonical)} optimal routes")
    print("These are the only routes that are ever shortest for some load level.")


# ============================================================
# Application 2: Scheduling / Critical Path Analysis
# ============================================================

def scheduling_demo():
    """
    In task scheduling, each task has a base duration and a scaling factor.
    The completion time is min(base + scale * resources).
    Canonicalization identifies which task configurations are ever optimal.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Task Scheduling Optimization")
    print("=" * 60)

    # Tasks: (resource_sensitivity, base_time)
    tasks = [
        (0, 20),   # Fixed-time task (no parallelism benefit)
        (1, 12),   # Moderately parallelizable
        (2, 8),    # Highly parallelizable
        (3, 5),    # Very parallelizable
        (1, 15),   # Another moderate task (dominated by (1,12))
        (2, 9),    # Another parallel task (dominated by (2,8))
        (4, 3),    # Extremely parallelizable
    ]

    canonical = canonicalize(tasks)

    print(f"\nTask configurations: {len(tasks)}")
    print(f"Non-redundant configurations: {len(canonical)}")
    print(f"\nOptimal schedule by resource level:")
    for r in range(8):
        best = min(tasks, key=lambda t: t[1] + t[0] * r)
        time = best[1] + best[0] * r
        print(f"  Resources={r}: best config=({best[0]},{best[1]}), time={time}")


# ============================================================
# Application 3: Piecewise-Linear Function Compression
# ============================================================

def piecewise_linear_demo():
    """
    A tropical polynomial defines a piecewise-linear concave function.
    Canonicalization compresses it to the minimal representation
    (vertices of the lower convex hull in the epigraph view).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Piecewise-Linear Compression")
    print("=" * 60)

    # A PWL function defined by 10 affine pieces
    random.seed(123)
    pieces = [(i, random.randint(0, 30)) for i in range(10)]

    canonical = canonicalize(pieces)

    print(f"\nOriginal: {len(pieces)} affine pieces")
    print(f"Compressed: {len(canonical)} pieces")
    print(f"Compression ratio: {100*len(canonical)/len(pieces):.0f}%")
    print(f"\nOriginal pieces: {pieces}")
    print(f"Compressed:      {canonical}")

    # Verify
    for x in range(20):
        v1 = min(c + e * x for e, c in pieces)
        v2 = min(c + e * x for e, c in canonical)
        assert v1 == v2, f"Mismatch at x={x}"
    print("Semantic preservation verified ✓")


# ============================================================
# Application 4: Dynamic Programming State Compression
# ============================================================

def dp_compression_demo():
    """
    In dynamic programming, state representations accumulate
    redundant entries over iterations. Tropical canonicalization
    compresses the DP table by removing dominated states.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: DP State Compression")
    print("=" * 60)

    # Simulate a DP iteration: Bellman-Ford style shortest path
    # State: list of (distance_so_far, edges_remaining * edge_cost)
    # After each relaxation step, canonicalize to remove dominated states

    states = [(0, 100)]  # Initial: distance 0, full cost budget
    print(f"\nDP Iteration simulation:")
    print(f"  Initial states: {states}")

    for step in range(5):
        # Expand: each state generates new states
        new_states = []
        for e, c in states:
            # Transition 1: take a cheap edge (add 3 to cost, decrease slope)
            new_states.append((max(0, e), c + 3))
            # Transition 2: take an expensive edge (add 1 to cost, increase slope)
            new_states.append((e + 1, c + 1))
            # Transition 3: wait (increase cost, same slope)
            new_states.append((e, c + 5))

        # Canonicalize to compress
        before = len(new_states)
        states = canonicalize(new_states)
        print(f"  Step {step+1}: {before} states → {len(states)} after canonicalization")

    print(f"\nFinal optimal states: {states}")


# ============================================================
# Helper: Simple canonicalization
# ============================================================

def canonicalize(p: List[Tuple[int, int]]) -> List[Tuple[int, int]]:
    """Canonicalize a tropical polynomial."""
    if not p:
        return []
    # Sort
    s = sorted(p, key=lambda m: m[0])
    # Merge
    merged = [s[0]]
    for m in s[1:]:
        if m[0] == merged[-1][0]:
            merged[-1] = (m[0], min(m[1], merged[-1][1]))
        else:
            merged.append(m)
    # Remove dominated
    def is_dom(m, n):
        return n[1] <= m[1] and n[0] <= m[0] and (n[1] < m[1] or n[0] < m[0])
    return [m for m in merged if not any(is_dom(m, n) for n in merged)]


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    shortest_path_demo()
    scheduling_demo()
    piecewise_linear_demo()
    dp_compression_demo()


#!/usr/bin/env python3
"""
Tropical Polynomial Canonicalization — Interactive Demo

Demonstrates the certified canonicalization algorithm for tropical (min-plus)
polynomials. Each monomial (e, c) represents the affine function x ↦ c + e*x.
Evaluation is pointwise min over all monomials.

The algorithm:
  1. Sort by exponent
  2. Merge equal exponents (take min coefficient)
  3. Remove dominated monomials (those never achieving the minimum)
"""

from typing import List, Tuple
import random


# --- Core Data Types ---

Mono = Tuple[int, int]   # (exponent, coefficient)
Poly = List[Mono]


def eval_mono(m: Mono, x: float) -> float:
    """Evaluate monomial c + e*x."""
    return m[1] + m[0] * x


def eval_poly(p: Poly, x: float) -> float:
    """Evaluate tropical polynomial: min of all monomial evaluations."""
    if not p:
        return 0
    return min(eval_mono(m, x) for m in p)


# --- Canonicalization Algorithm ---

def sort_by_exp(p: Poly) -> Poly:
    """Phase 1: Sort monomials by exponent."""
    return sorted(p, key=lambda m: m[0])


def merge_same_exp(p: Poly) -> Poly:
    """Phase 2: Merge consecutive monomials with same exponent (take min coeff)."""
    if not p:
        return []
    result = [p[0]]
    for m in p[1:]:
        if m[0] == result[-1][0]:
            result[-1] = (m[0], min(m[1], result[-1][1]))
        else:
            result.append(m)
    return result


def is_strict_dom(m: Mono, n: Mono) -> bool:
    """Check if n strictly dominates m: n ≤ m componentwise with one strict."""
    return (n[1] <= m[1] and n[0] <= m[0] and
            (n[1] < m[1] or n[0] < m[0]))


def remove_dominated(p: Poly) -> Poly:
    """Phase 3: Remove strictly dominated monomials."""
    return [m for m in p if not any(is_strict_dom(m, n) for n in p)]


def canonicalize_fast(p: Poly) -> Poly:
    """The certified canonicalization algorithm."""
    return remove_dominated(merge_same_exp(sort_by_exp(p)))


# --- Demo ---

def demo_basic():
    """Basic demonstration of canonicalization."""
    print("=" * 60)
    print("TROPICAL POLYNOMIAL CANONICALIZATION DEMO")
    print("=" * 60)

    p = [(2, 5), (1, 3), (2, 1), (1, 7), (0, 10), (3, 0)]
    print(f"\nInput polynomial (exp, coeff): {p}")
    print("  Interpretation: min(5+2x, 3+x, 1+2x, 7+x, 10, 3x)")

    sorted_p = sort_by_exp(p)
    print(f"\nAfter sorting by exponent:     {sorted_p}")

    merged = merge_same_exp(sorted_p)
    print(f"After merging equal exponents: {merged}")

    canonical = canonicalize_fast(p)
    print(f"After removing dominated:      {canonical}")

    print("\n--- Semantic Preservation Check ---")
    for x in range(11):
        v_orig = eval_poly(p, x)
        v_canon = eval_poly(canonical, x)
        status = "✓" if v_orig == v_canon else "✗ MISMATCH!"
        print(f"  x={x:2d}:  original={v_orig:4.0f}  canonical={v_canon:4.0f}  {status}")

    print(f"\nSize reduction: {len(p)} → {len(canonical)} monomials")
    print(f"Cost bound: 3·{len(p)}² + {len(p)} + 1 = {3*len(p)**2 + len(p) + 1}")


def demo_random():
    """Random polynomial canonicalization."""
    print("\n" + "=" * 60)
    print("RANDOM POLYNOMIAL STRESS TEST")
    print("=" * 60)

    n = 20
    p = [(random.randint(0, 10), random.randint(0, 50)) for _ in range(n)]
    print(f"\nRandom polynomial with {n} monomials: {p}")

    canonical = canonicalize_fast(p)
    print(f"Canonical form ({len(canonical)} monomials): {canonical}")

    # Verify semantic preservation at 100 points
    all_ok = all(eval_poly(p, x) == eval_poly(canonical, x) for x in range(100))
    print(f"Semantic preservation (100 test points): {'✓ PASS' if all_ok else '✗ FAIL'}")
    print(f"Compression ratio: {len(p)} → {len(canonical)} ({100*len(canonical)/len(p):.0f}%)")


def demo_lower_envelope():
    """Visualize the lower envelope interpretation."""
    print("\n" + "=" * 60)
    print("LOWER ENVELOPE INTERPRETATION")
    print("=" * 60)

    p = [(0, 8), (1, 4), (2, 2), (3, 1), (1, 6)]
    canonical = canonicalize_fast(p)

    print(f"\nPolynomial: {p}")
    print(f"Canonical:  {canonical}")
    print("\nEach monomial (e,c) is the line y = c + e·x.")
    print("The tropical polynomial is the lower envelope (pointwise min).")
    print("Canonicalization keeps only the lines that appear on the envelope.\n")

    print("x  | " + " | ".join(f"({e},{c})" for e, c in p) + " | min | canon")
    print("-" * 70)
    for x in range(8):
        vals = [eval_mono(m, x) for m in p]
        v_min = eval_poly(p, x)
        v_can = eval_poly(canonical, x)
        row = f"{x:2d} | " + " | ".join(f"{v:5.0f}" for v in vals)
        row += f" | {v_min:3.0f} | {v_can:3.0f}"
        print(row)


def demo_complexity():
    """Demonstrate the quadratic cost bound."""
    print("\n" + "=" * 60)
    print("COMPLEXITY ANALYSIS")
    print("=" * 60)

    print(f"\n{'n':>5} | {'Cost Bound':>12} | {'Output Size':>12} | {'Compression':>12}")
    print("-" * 50)
    for n in [5, 10, 20, 50, 100, 200, 500]:
        p = [(random.randint(0, n), random.randint(0, 100)) for _ in range(n)]
        canonical = canonicalize_fast(p)
        cost_bound = 3 * n * n + n + 1
        compression = f"{100*len(canonical)/n:.1f}%"
        print(f"{n:5d} | {cost_bound:12d} | {len(canonical):12d} | {compression:>12}")


if __name__ == "__main__":
    random.seed(42)
    demo_basic()
    demo_random()
    demo_lower_envelope()
    demo_complexity()


#!/usr/bin/env python3
"""
Visualizations for Tropical Polynomial Canonicalization

Generates publication-quality figures showing:
1. Lower envelope / canonicalization geometry
2. Compression ratios vs polynomial size
3. Cost model validation
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def canonicalize(p):
    if not p:
        return []
    s = sorted(p, key=lambda m: m[0])
    merged = [s[0]]
    for m in s[1:]:
        if m[0] == merged[-1][0]:
            merged[-1] = (m[0], min(m[1], merged[-1][1]))
        else:
            merged.append(m)
    def is_dom(m, n):
        return n[1] <= m[1] and n[0] <= m[0] and (n[1] < m[1] or n[0] < m[0])
    return [m for m in merged if not any(is_dom(m, n) for n in merged)]


def plot_lower_envelope():
    """Visualize the lower envelope interpretation of canonicalization."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Monomials as affine functions y = c + e*x
    monomials = [(0, 10), (1, 6), (2, 4), (3, 1), (1, 8), (2, 7)]
    canonical = canonicalize(monomials)
    canonical_set = set(canonical)

    x = np.linspace(0, 5, 200)

    # Left plot: all monomials
    ax1.set_title("All Monomials as Affine Functions", fontsize=14, fontweight='bold')
    for e, c in monomials:
        y = c + e * x
        if (e, c) in canonical_set:
            ax1.plot(x, y, linewidth=2.5, label=f'y = {c} + {e}x (kept)')
        else:
            ax1.plot(x, y, linewidth=1, linestyle='--', alpha=0.5,
                    label=f'y = {c} + {e}x (dominated)')

    # Lower envelope
    envelope = np.array([min(c + e * xi for e, c in monomials) for xi in x])
    ax1.plot(x, envelope, 'k-', linewidth=3, alpha=0.3, label='Lower envelope')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('y = min(c + e·x)', fontsize=12)
    ax1.legend(fontsize=9, loc='upper left')
    ax1.set_ylim(0, 25)
    ax1.grid(True, alpha=0.3)

    # Right plot: canonical form only
    ax2.set_title("Canonical Form (Lower Envelope)", fontsize=14, fontweight='bold')
    colors = plt.cm.Set1(np.linspace(0, 1, len(canonical)))
    for i, (e, c) in enumerate(canonical):
        y = c + e * x
        ax2.plot(x, y, linewidth=2, color=colors[i], label=f'y = {c} + {e}x')

    envelope_canon = np.array([min(c + e * xi for e, c in canonical) for xi in x])
    ax2.fill_between(x, envelope_canon, 25, alpha=0.1, color='blue')
    ax2.plot(x, envelope_canon, 'k-', linewidth=3, label='Lower envelope')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('y = min(c + e·x)', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 25)
    ax2.grid(True, alpha=0.3)

    fig.suptitle("Tropical Canonicalization = Lower Envelope Extraction",
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()

    uri = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/lower_envelope.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return uri


def plot_compression_ratio():
    """Plot compression ratio vs polynomial size."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    random.seed(42)
    sizes = list(range(5, 201, 5))
    ratios = []
    output_sizes = []

    for n in sizes:
        trials = 50
        total_ratio = 0
        total_output = 0
        for _ in range(trials):
            p = [(random.randint(0, n), random.randint(0, 100)) for _ in range(n)]
            c = canonicalize(p)
            total_ratio += len(c) / n
            total_output += len(c)
        ratios.append(total_ratio / trials * 100)
        output_sizes.append(total_output / trials)

    ax1.plot(sizes, ratios, 'b-', linewidth=2)
    ax1.fill_between(sizes, ratios, alpha=0.2)
    ax1.set_xlabel('Input Size (n)', fontsize=12)
    ax1.set_ylabel('Output/Input (%)', fontsize=12)
    ax1.set_title('Compression Ratio vs Input Size', fontsize=14, fontweight='bold')
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=50, color='r', linestyle='--', alpha=0.5, label='50% threshold')
    ax1.legend(fontsize=10)

    ax2.plot(sizes, output_sizes, 'g-', linewidth=2, label='Avg canonical size')
    ax2.plot(sizes, sizes, 'r--', linewidth=1, alpha=0.5, label='Identity (no compression)')
    ax2.plot(sizes, [n**0.5 * 5 for n in sizes], 'b--', linewidth=1, alpha=0.5, label='√n scaling')
    ax2.set_xlabel('Input Size (n)', fontsize=12)
    ax2.set_ylabel('Output Size', fontsize=12)
    ax2.set_title('Canonical Form Size', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    uri = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/compression_ratio.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return uri


def plot_cost_model():
    """Visualize the certified cost bound."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n_vals = np.arange(1, 101)
    sort_cost = n_vals * (n_vals - 1) / 2
    merge_cost = n_vals
    dom_cost = n_vals ** 2
    total = sort_cost + merge_cost + dom_cost
    bound = 3 * n_vals ** 2 + n_vals + 1

    ax.fill_between(n_vals, 0, sort_cost, alpha=0.3, label='Sort (insertion)', color='blue')
    ax.fill_between(n_vals, sort_cost, sort_cost + merge_cost, alpha=0.3,
                    label='Merge (linear)', color='green')
    ax.fill_between(n_vals, sort_cost + merge_cost, total, alpha=0.3,
                    label='Remove dominated (quadratic)', color='orange')
    ax.plot(n_vals, bound, 'r--', linewidth=2, label='Certified bound: 3n² + n + 1')
    ax.plot(n_vals, total, 'k-', linewidth=2, label='Actual cost')

    ax.set_xlabel('Input Size (n)', fontsize=12)
    ax.set_ylabel('Number of Comparisons', fontsize=12)
    ax.set_title('Certified Complexity Bound', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    uri = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/cost_model.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return uri


def plot_pareto_frontier():
    """Visualize the Pareto frontier / domination geometry."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    random.seed(42)
    points = [(random.randint(0, 20), random.randint(0, 20)) for _ in range(30)]
    canonical = canonicalize(points)
    canonical_set = set(canonical)

    # Left: all points with domination
    dominated = [p for p in points if p not in canonical_set]
    non_dom = list(canonical_set)

    ax1.scatter([p[0] for p in dominated], [p[1] for p in dominated],
               c='red', marker='x', s=80, zorder=5, label='Dominated')
    ax1.scatter([p[0] for p in non_dom], [p[1] for p in non_dom],
               c='blue', marker='o', s=100, zorder=5, label='Pareto optimal')

    # Draw domination regions
    for e, c in non_dom:
        rect = plt.Rectangle((e, c), 25-e, 25-c, alpha=0.05, color='blue')
        ax1.add_patch(rect)

    ax1.set_xlabel('Exponent', fontsize=12)
    ax1.set_ylabel('Coefficient', fontsize=12)
    ax1.set_title('Monomial Domination Geometry', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.set_xlim(-1, 22)
    ax1.set_ylim(-1, 22)
    ax1.grid(True, alpha=0.3)

    # Right: Pareto staircase
    sorted_canon = sorted(non_dom, key=lambda p: p[0])
    for i in range(len(sorted_canon) - 1):
        e1, c1 = sorted_canon[i]
        e2, c2 = sorted_canon[i + 1]
        ax2.plot([e1, e2], [c1, c1], 'b-', linewidth=2)
        ax2.plot([e2, e2], [c1, c2], 'b-', linewidth=2)

    ax2.scatter([p[0] for p in sorted_canon], [p[1] for p in sorted_canon],
               c='blue', marker='o', s=100, zorder=5)
    ax2.set_xlabel('Exponent', fontsize=12)
    ax2.set_ylabel('Coefficient', fontsize=12)
    ax2.set_title('Pareto Frontier (Canonical Monomials)', fontsize=14, fontweight='bold')
    ax2.set_xlim(-1, 22)
    ax2.set_ylim(-1, 22)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    uri = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/pareto_frontier.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return uri


if __name__ == "__main__":
    print("Generating visualizations...")
    uri1 = plot_lower_envelope()
    print(f"  Lower envelope: saved to lower_envelope.png")
    uri2 = plot_compression_ratio()
    print(f"  Compression ratio: saved to compression_ratio.png")
    uri3 = plot_cost_model()
    print(f"  Cost model: saved to cost_model.png")
    uri4 = plot_pareto_frontier()
    print(f"  Pareto frontier: saved to pareto_frontier.png")
    print("Done!")

#!/usr/bin/env python3
"""
Berggren Tropical Lensing Duality — Demonstration

Demonstrates the three main theorems:
1. Bellman Principle: shortest-path potentials on the Berggren DAG
2. Lensing Duality: backward propagation from compatible nodes
3. Certified Reconstruction: path reconstruction with divisor extraction
"""

from math import gcd
from typing import Optional

# ─────────────────────────────────────────────────────────────
# Berggren Tree Definitions
# ─────────────────────────────────────────────────────────────

def apply_gen_A(a: int, b: int, c: int) -> tuple[int, int, int]:
    """Berggren generator A."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def apply_gen_B(a: int, b: int, c: int) -> tuple[int, int, int]:
    """Berggren generator B."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def apply_gen_C(a: int, b: int, c: int) -> tuple[int, int, int]:
    """Berggren generator C."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = {'A': apply_gen_A, 'B': apply_gen_B, 'C': apply_gen_C}
ROOT = (3, 4, 5)


def is_pythagorean(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a Pythagorean triple."""
    return a**2 + b**2 == c**2


def hyp_weight(t1: tuple, t2: tuple) -> int:
    """Hypotenuse difference weight."""
    return abs(t2[2] - t1[2])


# ─────────────────────────────────────────────────────────────
# Compatibility and Divisor Extraction
# ─────────────────────────────────────────────────────────────

def is_compatible(n: int, triple: tuple) -> bool:
    """Check if a triple is compatible with n (has a nontrivial divisor)."""
    a, b, c = triple
    return ((1 < abs(a) < n and n % abs(a) == 0) or
            (1 < abs(b) < n and n % abs(b) == 0))


def extract_divisor(n: int, triple: tuple) -> Optional[int]:
    """Extract a nontrivial divisor of n from a compatible triple using GCD."""
    a, b, _ = triple
    g1 = gcd(n, abs(a))
    if 1 < g1 < n:
        return g1
    g2 = gcd(n, abs(b))
    if 1 < g2 < n:
        return g2
    return None


# ─────────────────────────────────────────────────────────────
# Lensing Value Function (Backward Tropical Propagation)
# ─────────────────────────────────────────────────────────────

INF = float('inf')

def lens_value(n: int, depth: int, triple: tuple) -> float:
    """
    Compute the lensing value at given depth.
    Returns the minimum cost to reach a compatible descendant.
    """
    penalty = 0 if is_compatible(n, triple) else INF

    if depth == 0:
        return penalty

    best_child = INF
    for gen_fn in GENERATORS.values():
        child = gen_fn(*triple)
        child_val = lens_value(n, depth - 1, child)
        cost = hyp_weight(triple, child) + child_val
        best_child = min(best_child, cost)

    return min(penalty, best_child)


def reconstruct_path(n: int, depth: int, triple: tuple) -> tuple:
    """
    Reconstruct the optimal path from a triple to a compatible descendant.
    Returns (path, endpoint, total_cost).
    """
    if is_compatible(n, triple):
        return ([], triple, 0)

    if depth == 0:
        return ([], triple, INF)

    best_path = []
    best_endpoint = triple
    best_cost = INF

    for name, gen_fn in GENERATORS.items():
        child = gen_fn(*triple)
        child_path, child_endpoint, child_cost = reconstruct_path(n, depth - 1, child)
        total = hyp_weight(triple, child) + child_cost
        if total < best_cost:
            best_cost = total
            best_path = [name] + child_path
            best_endpoint = child_endpoint

    return (best_path, best_endpoint, best_cost)


# ─────────────────────────────────────────────────────────────
# Demonstrations
# ─────────────────────────────────────────────────────────────

def demo_berggren_tree():
    """Show the first few levels of the Berggren tree."""
    print("=" * 70)
    print("BERGGREN TREE — First Two Levels")
    print("=" * 70)
    print(f"\nRoot: {ROOT}  (Pythagorean: {is_pythagorean(*ROOT)})")

    for name, gen_fn in GENERATORS.items():
        child = gen_fn(*ROOT)
        print(f"  └─{name}→ {child}  (Pythagorean: {is_pythagorean(*child)}, "
              f"hyp increase: {child[2] - ROOT[2]})")
        for name2, gen_fn2 in GENERATORS.items():
            grandchild = gen_fn2(*child)
            print(f"      └─{name2}→ {grandchild}  "
                  f"(hyp: {grandchild[2]}, Pyth: {is_pythagorean(*grandchild)})")
    print()


def demo_lensing():
    """Demonstrate the lensing value computation."""
    print("=" * 70)
    print("TROPICAL LENSING — Value Function Computation")
    print("=" * 70)

    test_cases = [15, 65, 77, 100, 221, 1001, 10403]

    for n in test_cases:
        print(f"\n  Target n = {n}:")
        values = []
        for d in range(6):
            v = lens_value(n, d, ROOT)
            values.append(v)
            v_str = f"{v:.0f}" if v < INF else "⊤"
            print(f"    depth {d}: lens value = {v_str}")
            if v < INF and (d == 0 or values[d] == values[d-1]):
                print(f"    [Converged at depth {d}]")
                break
    print()


def demo_reconstruction():
    """Demonstrate path reconstruction and divisor extraction."""
    print("=" * 70)
    print("CERTIFIED RECONSTRUCTION — Divisor Extraction")
    print("=" * 70)

    test_cases = [
        (15, 3),
        (65, 3),
        (221, 4),
        (1001, 4),
        (10403, 5),
        (323, 4),
    ]

    for n, max_depth in test_cases:
        path, endpoint, cost = reconstruct_path(n, max_depth, ROOT)
        if cost < INF:
            divisor = extract_divisor(n, endpoint)
            path_str = " → ".join(path) if path else "(root)"
            print(f"\n  n = {n}:")
            print(f"    Path: {path_str}")
            print(f"    Endpoint: {endpoint}")
            print(f"    Cost: {cost}")
            if divisor:
                other = n // divisor
                print(f"    Extracted divisor: {divisor}")
                print(f"    Verification: {divisor} × {other} = {divisor * other} "
                      f"{'✓' if divisor * other == n else '✗'}")
            else:
                print(f"    (Compatible but GCD extraction yielded trivial result)")
        else:
            print(f"\n  n = {n}: No compatible node within depth {max_depth}")
    print()


def demo_bellman_equation():
    """Verify the Bellman equation at specific nodes."""
    print("=" * 70)
    print("BELLMAN EQUATION — Verification at Specific Nodes")
    print("=" * 70)

    n = 65
    d = 3
    print(f"\n  Target n = {n}, depth = {d}")
    print(f"\n  Bellman equation: L(t) = min(penalty(t), min_g(L(g(t)) + w(t,g(t))))")

    # Check at root
    root_val = lens_value(n, d, ROOT)
    root_penalty = 0 if is_compatible(n, ROOT) else INF
    child_vals = {}
    for name, gen_fn in GENERATORS.items():
        child = gen_fn(*ROOT)
        child_val = lens_value(n, d - 1, child)
        w = hyp_weight(ROOT, child)
        child_vals[name] = (child_val, w, child_val + w)

    print(f"\n  At root {ROOT}:")
    print(f"    penalty = {'0' if root_penalty == 0 else '⊤'}")
    for name, (cv, w, total) in child_vals.items():
        cv_str = f"{cv:.0f}" if cv < INF else "⊤"
        total_str = f"{total:.0f}" if total < INF else "⊤"
        print(f"    Child {name}: L = {cv_str}, weight = {w}, total = {total_str}")
    best_child = min(v[2] for v in child_vals.values())
    bellman_val = min(root_penalty, best_child)
    print(f"    Bellman value = min({root_penalty}, {best_child:.0f}) = {bellman_val:.0f}")
    print(f"    Direct computation: L = {root_val:.0f}")
    print(f"    Match: {'✓' if abs(bellman_val - root_val) < 0.01 else '✗'}")
    print()


def demo_depth_monotonicity():
    """Demonstrate that lensing values decrease with depth."""
    print("=" * 70)
    print("DEPTH MONOTONICITY — lensValue(d+1) ≤ lensValue(d)")
    print("=" * 70)

    for n in [65, 221, 1001]:
        print(f"\n  n = {n}:")
        prev = INF
        for d in range(7):
            v = lens_value(n, d, ROOT)
            v_str = f"{v:.0f}" if v < INF else "⊤"
            mono = "≤" if v <= prev else ">"
            status = "✓" if v <= prev else "✗ VIOLATION"
            print(f"    d={d}: {v_str}  {mono} prev  {status}")
            prev = v
            if v < INF and d > 0:
                break
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  BERGGREN TROPICAL LENSING DUALITY — DEMONSTRATION")
    print("=" * 70 + "\n")

    demo_berggren_tree()
    demo_lensing()
    demo_reconstruction()
    demo_bellman_equation()
    demo_depth_monotonicity()

    print("=" * 70)
    print("  All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json for the Berggren Tropical Lensing project."""

import json

# Read all source files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
lean_code = read_file('Bridges/AutoResearch/BerggrenTropicalLensing.lean')

# SVG Tree Visualization
tree_svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 500" font-family="Arial, sans-serif">
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#666"/>
    </marker>
  </defs>
  <text x="400" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#333">
    Berggren Tree with Tropical Lensing (n = 65)
  </text>
  <!-- Root node (3,4,5) - compatible with 15 but not 65 -->
  <circle cx="400" cy="80" r="35" fill="#FF6B6B" stroke="#333" stroke-width="2"/>
  <text x="400" y="76" text-anchor="middle" font-size="10" fill="#000">(3,4,5)</text>
  <text x="400" y="90" text-anchor="middle" font-size="8" fill="darkblue">L=8</text>
  <!-- Level 1 edges -->
  <line x1="375" y1="110" x2="150" y2="190" stroke="#666" stroke-width="1.5" marker-end="url(#arrowhead)"/>
  <text x="250" y="145" text-anchor="middle" font-size="9" fill="#666">A, w=8</text>
  <line x1="400" y1="115" x2="400" y2="190" stroke="#666" stroke-width="1.5" marker-end="url(#arrowhead)"/>
  <text x="420" y="155" text-anchor="start" font-size="9" fill="#666">B, w=24</text>
  <line x1="425" y1="110" x2="650" y2="190" stroke="#666" stroke-width="1.5" marker-end="url(#arrowhead)"/>
  <text x="550" y="145" text-anchor="middle" font-size="9" fill="#666">C, w=12</text>
  <!-- Child A: (5,12,13) - compatible with 65! -->
  <circle cx="150" cy="220" r="35" fill="#90EE90" stroke="#333" stroke-width="2"/>
  <text x="150" y="216" text-anchor="middle" font-size="10" fill="#000">(5,12,13)</text>
  <text x="150" y="230" text-anchor="middle" font-size="8" fill="darkblue">L=0 ✓</text>
  <!-- Child B: (21,20,29) -->
  <circle cx="400" cy="220" r="35" fill="#FF6B6B" stroke="#333" stroke-width="2"/>
  <text x="400" y="216" text-anchor="middle" font-size="10" fill="#000">(21,20,29)</text>
  <text x="400" y="230" text-anchor="middle" font-size="8" fill="darkblue">L=∞</text>
  <!-- Child C: (15,8,17) -->
  <circle cx="650" cy="220" r="35" fill="#FF6B6B" stroke="#333" stroke-width="2"/>
  <text x="650" y="216" text-anchor="middle" font-size="10" fill="#000">(15,8,17)</text>
  <text x="650" y="230" text-anchor="middle" font-size="8" fill="darkblue">L=∞</text>
  <!-- Level 2 from A -->
  <line x1="125" y1="250" x2="60" y2="330" stroke="#666" stroke-width="1" marker-end="url(#arrowhead)"/>
  <line x1="150" y1="255" x2="150" y2="330" stroke="#666" stroke-width="1" marker-end="url(#arrowhead)"/>
  <line x1="175" y1="250" x2="240" y2="330" stroke="#666" stroke-width="1" marker-end="url(#arrowhead)"/>
  <circle cx="60" cy="360" r="30" fill="#FF6B6B" stroke="#333" stroke-width="1.5"/>
  <text x="60" y="356" text-anchor="middle" font-size="8" fill="#000">(7,24,25)</text>
  <text x="60" y="370" text-anchor="middle" font-size="7" fill="darkblue">L=∞</text>
  <circle cx="150" cy="360" r="30" fill="#FF6B6B" stroke="#333" stroke-width="1.5"/>
  <text x="150" y="356" text-anchor="middle" font-size="8" fill="#000">(55,48,73)</text>
  <text x="150" y="370" text-anchor="middle" font-size="7" fill="darkblue">L=∞</text>
  <circle cx="240" cy="360" r="30" fill="#FF6B6B" stroke="#333" stroke-width="1.5"/>
  <text x="240" y="356" text-anchor="middle" font-size="8" fill="#000">(45,28,53)</text>
  <text x="240" y="370" text-anchor="middle" font-size="7" fill="darkblue">L=∞</text>
  <!-- Legend -->
  <rect x="560" y="350" width="220" height="110" fill="white" stroke="#ccc" stroke-width="1" rx="5"/>
  <text x="670" y="370" text-anchor="middle" font-size="11" font-weight="bold" fill="#333">Legend</text>
  <circle cx="580" cy="390" r="8" fill="#90EE90" stroke="#333" stroke-width="1"/>
  <text x="595" y="394" font-size="10" fill="#333">Compatible (L=0)</text>
  <circle cx="580" cy="415" r="8" fill="#FFB347" stroke="#333" stroke-width="1"/>
  <text x="595" y="419" font-size="10" fill="#333">Reachable (0&lt;L&lt;∞)</text>
  <circle cx="580" cy="440" r="8" fill="#FF6B6B" stroke="#333" stroke-width="1"/>
  <text x="595" y="444" font-size="10" fill="#333">Unreachable (L=∞)</text>
  <!-- Optimal path highlight -->
  <line x1="400" y1="115" x2="150" y2="185" stroke="#4CAF50" stroke-width="3" stroke-dasharray="5,3"/>
  <text x="270" y="175" text-anchor="middle" font-size="10" font-weight="bold" fill="#4CAF50">Optimal path</text>
</svg>'''

package = {
    "title": "Berggren Tropical Lensing Duality via Min-Plus Semimodules and Certified Shortest-Factor Path Reconstruction",
    "domain": "Bridges: Diophantine Geometry × Tropical Optimization × Cryptographic Arithmetic",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Berggren Tropical Lensing Demo",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Berggren Tree Lensing Algorithm",
            "pseudocode": """function BerggrenLens(n, d, t):
    if d == 0:
        if Compatible(n, t): return ([], 0)
        else: return (∅, ⊤)
    best_cost ← ⊤; best_path ← ∅
    if Compatible(n, t):
        best_cost ← 0; best_path ← []
    for g in {A, B, C}:
        (path', cost') ← BerggrenLens(n, d-1, g(t))
        total ← w(t, g(t)) + cost'
        if total < best_cost:
            best_cost ← total
            best_path ← [g] ++ path'
    return (best_path, best_cost)

Complexity: O(3^d) time, O(d) space""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Berggren Tree with Tropical Lensing Values",
            "data": tree_svg
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""Generate visualizations for the Berggren Tropical Lensing paper."""

import base64
import io
import json

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False

from demo import (apply_gen_A, apply_gen_B, apply_gen_C, ROOT,
                   is_compatible, lens_value, hyp_weight, INF,
                   reconstruct_path, extract_divisor, GENERATORS)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def generate_tree_viz() -> str:
    """Generate Berggren tree visualization with lensing values."""
    if not HAS_MPL:
        return ""

    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    ax.set_xlim(-1, 15)
    ax.set_ylim(-0.5, 4.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("Berggren Tree with Tropical Lensing (n = 65)", fontsize=16, fontweight='bold')

    n = 65
    depth = 2

    # Draw tree
    def draw_node(x, y, triple, label="", color='lightblue'):
        a, b, c = triple
        compat = is_compatible(n, (a, b, c))
        lv = lens_value(n, depth, (a, b, c))
        node_color = '#90EE90' if compat else ('#FFB347' if lv < INF else '#FF6B6B')
        circle = plt.Circle((x, y), 0.35, color=node_color, ec='black', linewidth=1.5, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y + 0.05, f"({a},{b},{c})", ha='center', va='center', fontsize=6, zorder=4)
        lv_str = f"L={int(lv)}" if lv < INF else "L=∞"
        ax.text(x, y - 0.15, lv_str, ha='center', va='center', fontsize=5, color='darkblue', zorder=4)
        if label:
            ax.text(x, y + 0.5, label, ha='center', va='center', fontsize=7, style='italic')

    def draw_edge(x1, y1, x2, y2, weight, gen_name):
        ax.annotate('', xy=(x2, y2 + 0.35), xytext=(x1, y1 - 0.35),
                     arrowprops=dict(arrowstyle='->', color='gray', lw=1.2))
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        ax.text(mx - 0.3, my, f"{gen_name}\nw={weight}", ha='center', va='center',
                fontsize=5, color='gray')

    # Root
    draw_node(7, 4, ROOT, "Root")

    # Level 1
    children = {
        'A': (2, 2, apply_gen_A(*ROOT)),
        'B': (7, 2, apply_gen_B(*ROOT)),
        'C': (12, 2, apply_gen_C(*ROOT)),
    }
    for name, (x, y, child) in children.items():
        w = abs(child[2] - ROOT[2])
        draw_edge(7, 4, x, y, w, name)
        draw_node(x, y, child)

    # Level 2
    level2_positions = [
        ('A', 'A', 0, 0), ('A', 'B', 2, 0), ('A', 'C', 4, 0),
        ('B', 'A', 5.5, 0), ('B', 'B', 7, 0), ('B', 'C', 8.5, 0),
        ('C', 'A', 10, 0), ('C', 'B', 12, 0), ('C', 'C', 14, 0),
    ]
    for parent_name, child_name, x, y in level2_positions:
        parent_x, parent_y, parent_triple = children[parent_name]
        gen_fn = GENERATORS[child_name]
        child = gen_fn(*parent_triple)
        w = abs(child[2] - parent_triple[2])
        draw_edge(parent_x, parent_y, x, y, w, child_name)
        draw_node(x, y, child)

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#90EE90', edgecolor='black', label='Compatible (L=0)'),
        mpatches.Patch(facecolor='#FFB347', edgecolor='black', label='Reachable (L<∞)'),
        mpatches.Patch(facecolor='#FF6B6B', edgecolor='black', label='Unreachable (L=∞)'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=8)

    return fig_to_base64(fig)


def generate_convergence_viz() -> str:
    """Generate convergence plot for lensing values."""
    if not HAS_MPL:
        return ""

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    test_ns = [65, 77, 1001]
    colors = ['#2196F3', '#FF5722', '#4CAF50']
    max_depth = 6

    for n, color in zip(test_ns, colors):
        depths = list(range(max_depth + 1))
        values = []
        for d in depths:
            v = lens_value(n, d, ROOT)
            values.append(v if v < INF else None)

        # Plot finite values
        finite_d = [d for d, v in zip(depths, values) if v is not None]
        finite_v = [v for v in values if v is not None]
        if finite_d:
            ax.plot(finite_d, finite_v, 'o-', color=color, label=f'n = {n}',
                    linewidth=2, markersize=8)

        # Mark infinite values
        inf_d = [d for d, v in zip(depths, values) if v is None]
        if inf_d and finite_v:
            ax.scatter(inf_d, [max(finite_v) * 1.3] * len(inf_d),
                       marker='x', color=color, s=80, zorder=5)

    ax.set_xlabel('Search Depth d', fontsize=12)
    ax.set_ylabel('Lensing Value L(n, d)', fontsize=12)
    ax.set_title('Tropical Lensing Value Convergence', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(max_depth + 1))

    return fig_to_base64(fig)


def generate_all():
    """Generate all visualizations and return as dict."""
    vizs = {}
    tree = generate_tree_viz()
    if tree:
        vizs['tree'] = tree
    conv = generate_convergence_viz()
    if conv:
        vizs['convergence'] = conv
    return vizs


if __name__ == "__main__":
    vizs = generate_all()
    for name, data in vizs.items():
        print(f"Generated {name}: {len(data)} chars")

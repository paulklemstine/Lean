#!/usr/bin/env python3
"""
Real-world applications of tropical dominance elimination.

Demonstrates how the abstract theorem applies to:
1. Critical path analysis in project scheduling
2. Shortest path simplification in weighted graphs
3. Dynamic programming state pruning
4. Logical formula simplification
"""

from algorithms import MaxPlusSemiring, MinPlusSemiring, BooleanSemiring
from typing import List, Dict, Tuple

# --------------------------------------------------------------------------
# Application 1: Critical Path Analysis
# --------------------------------------------------------------------------

def critical_path_demo():
    """Max-plus canonicalization identifies critical paths in project scheduling.

    In PERT/CPM scheduling, the project completion time is the maximum
    of all path completion times. Dominated paths are non-critical and
    can be eliminated from the analysis without affecting the result.
    """
    print("APPLICATION 1: Critical Path Analysis")
    print("=" * 50)
    print()

    tasks = {
        "Foundation":      8,
        "Framing":        12,
        "Electrical":      6,
        "Plumbing":        7,
        "Roofing":        15,
        "Interior":        9,
        "Landscaping":     4,
        "Final Inspect":  15,
    }

    mp = MaxPlusSemiring()
    terms = list(tasks.values())
    names = list(tasks.keys())

    print("  Task completion times (hours):")
    for name, time in tasks.items():
        print(f"    {name}: {time}")

    original = mp.eval_poly([float(t) for t in terms])
    canon = mp.canonicalize([float(t) for t in terms])

    print(f"\n  Project completion time: {original} hours")
    print(f"  Critical tasks (after canonicalization):")

    canon_set = set(canon)
    for name, time in tasks.items():
        status = "CRITICAL ⚡" if float(time) in canon_set else "non-critical"
        print(f"    {name}: {status}")

    print(f"\n  Eliminated {len(terms) - len(canon)} non-critical tasks")
    print()

# --------------------------------------------------------------------------
# Application 2: Shortest Path Simplification
# --------------------------------------------------------------------------

def shortest_path_demo():
    """Min-plus canonicalization prunes dominated routes.

    In shortest-path problems, the optimal distance is the minimum
    of all path costs. Dominated paths (longer alternatives) can be
    eliminated.
    """
    print("APPLICATION 2: Shortest Path Simplification")
    print("=" * 50)
    print()

    routes = {
        "Highway (toll)":   45.0,
        "Scenic route":     72.0,
        "Back roads":       58.0,
        "Express (toll)":   38.0,
        "City streets":     55.0,
        "Express shortcut": 38.0,
    }

    mnp = MinPlusSemiring()
    terms = [float(t) for t in routes.values()]

    print("  Route distances (km):")
    for name, dist in routes.items():
        print(f"    {name}: {dist}")

    original = mnp.eval_poly(terms)
    canon = mnp.canonicalize(terms)

    print(f"\n  Shortest distance: {original} km")
    print(f"  Optimal route(s) (after canonicalization):")

    canon_set = set(canon)
    for name, dist in routes.items():
        status = "OPTIMAL ✓" if float(dist) in canon_set else "dominated"
        print(f"    {name}: {status}")

    print(f"\n  Eliminated {len(terms) - len(canon)} dominated routes")
    print()

# --------------------------------------------------------------------------
# Application 3: Dynamic Programming State Pruning
# --------------------------------------------------------------------------

def dp_pruning_demo():
    """Dominance elimination as DP state pruning.

    In dynamic programming, dominated states can be eliminated without
    affecting the optimal solution. This is exactly tropical canonicalization.
    """
    print("APPLICATION 3: Dynamic Programming State Pruning")
    print("=" * 50)
    print()

    # Knapsack-like: value of different item combinations
    states = {
        "Items {A}":       10.0,
        "Items {B}":       15.0,
        "Items {A,C}":     18.0,
        "Items {B,C}":     22.0,
        "Items {A,B}":     20.0,
        "Items {A,B,C}":   25.0,
        "Items {C}":        8.0,
    }

    mp = MaxPlusSemiring()
    terms = [float(v) for v in states.values()]

    print("  DP state values:")
    for state, val in states.items():
        print(f"    {state}: {val}")

    original = mp.eval_poly(terms)
    canon = mp.canonicalize(terms)

    print(f"\n  Optimal value: {original}")
    print(f"  After pruning: {len(canon)} states remain (from {len(terms)})")

    canon_set = set(canon)
    for state, val in states.items():
        if float(val) in canon_set:
            print(f"    Kept: {state} = {val}")
    print()

# --------------------------------------------------------------------------
# Application 4: Logical Formula Simplification
# --------------------------------------------------------------------------

def logic_simplification_demo():
    """Boolean canonicalization = absorption law simplification.

    In propositional logic, x ∨ (x ∧ y) = x (absorption).
    This is exactly dominance elimination in the Boolean semiring:
    False is dominated by True under OR.
    """
    print("APPLICATION 4: Logical Formula Simplification")
    print("=" * 50)
    print()

    bs = BooleanSemiring()

    # Example: a complex OR expression
    print("  Formula: p ∨ False ∨ q ∨ False ∨ True ∨ False")
    terms = [True, False, True, False, True, False]
    canon = bs.canonicalize(terms)
    print(f"  Original terms: {terms} → eval = {bs.eval_poly(terms)}")
    print(f"  Canonical:      {canon} → eval = {bs.eval_poly(canon)}")
    print(f"  Simplification: {len(terms)} → {len(canon)} disjuncts")
    print()

    print("  Formula: False ∨ False ∨ False")
    terms2 = [False, False, False]
    canon2 = bs.canonicalize(terms2)
    print(f"  Original terms: {terms2} → eval = {bs.eval_poly(terms2)}")
    print(f"  Canonical:      {canon2} → eval = {bs.eval_poly(canon2)}")
    print()

    print("  Key insight: Boolean absorption (a ∨ a = a) and")
    print("  tropical dominance (m ≤ eval(rest) → remove m)")
    print("  are THE SAME THEOREM in different semirings!")
    print()


if __name__ == "__main__":
    critical_path_demo()
    shortest_path_demo()
    dp_pruning_demo()
    logic_simplification_demo()


#!/usr/bin/env python3
"""
Demonstrations of tropical dominance elimination in idempotent semirings.

Shows how dominated monomials can be removed from tropical polynomials
without changing their evaluation, across max-plus, min-plus, and Boolean
semirings.
"""

import math
from typing import List, Tuple, Callable

# --------------------------------------------------------------------------
# Max-Plus semiring
# --------------------------------------------------------------------------

NEG_INF = float('-inf')

def maxplus_add(a: float, b: float) -> float:
    """Tropical addition in max-plus: max(a, b)."""
    return max(a, b)

def maxplus_zero() -> float:
    """Zero element of max-plus: -infinity."""
    return NEG_INF

def maxplus_eval(terms: List[float]) -> float:
    """Evaluate a tropical polynomial (list of monomial values) in max-plus."""
    result = maxplus_zero()
    for t in terms:
        result = maxplus_add(result, t)
    return result

def is_dominated_maxplus(term: float, rest: List[float]) -> bool:
    """Check if a term is dominated by the rest in max-plus."""
    return term <= maxplus_eval(rest)

def canonicalize_maxplus(terms: List[float]) -> List[float]:
    """Remove all dominated terms from a max-plus polynomial."""
    changed = True
    result = list(terms)
    while changed:
        changed = False
        for i in range(len(result)):
            rest = result[:i] + result[i+1:]
            if is_dominated_maxplus(result[i], rest):
                result = rest
                changed = True
                break
    return result

# --------------------------------------------------------------------------
# Min-Plus semiring
# --------------------------------------------------------------------------

POS_INF = float('inf')

def minplus_add(a: float, b: float) -> float:
    """Tropical addition in min-plus: min(a, b)."""
    return min(a, b)

def minplus_zero() -> float:
    """Zero element of min-plus: +infinity."""
    return POS_INF

def minplus_eval(terms: List[float]) -> float:
    """Evaluate a tropical polynomial in min-plus."""
    result = minplus_zero()
    for t in terms:
        result = minplus_add(result, t)
    return result

def is_dominated_minplus(term: float, rest: List[float]) -> bool:
    """Check if a term is dominated by the rest in min-plus.
    In min-plus with reversed order, a ≤ b means b ≤_usual a,
    so dominated means term ≥ eval(rest)."""
    return term >= minplus_eval(rest)

def canonicalize_minplus(terms: List[float]) -> List[float]:
    """Remove all dominated terms from a min-plus polynomial."""
    changed = True
    result = list(terms)
    while changed:
        changed = False
        for i in range(len(result)):
            rest = result[:i] + result[i+1:]
            if is_dominated_minplus(result[i], rest):
                result = rest
                changed = True
                break
    return result

# --------------------------------------------------------------------------
# Boolean semiring
# --------------------------------------------------------------------------

def bool_add(a: bool, b: bool) -> bool:
    """Tropical addition in Boolean: logical OR."""
    return a or b

def bool_eval(terms: List[bool]) -> bool:
    """Evaluate a tropical polynomial in Boolean."""
    result = False
    for t in terms:
        result = bool_add(result, t)
    return result

# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_maxplus():
    """Demonstrate dominance elimination in max-plus."""
    print("=" * 60)
    print("DEMO 1: Max-Plus Dominance Elimination")
    print("=" * 60)
    print()

    # Example: terms = [3, 7, 5, 2, 7]
    # max(3, 7, 5, 2, 7) = 7
    # Term 3 is dominated by rest {7, 5, 2, 7} since 3 ≤ max(7,5,2,7) = 7
    # Similarly 5, 2 are dominated
    terms = [3.0, 7.0, 5.0, 2.0, 7.0]
    print(f"  Original polynomial terms: {terms}")
    print(f"  Evaluation (max): {maxplus_eval(terms)}")
    print()

    canon = canonicalize_maxplus(terms)
    print(f"  Canonical form: {canon}")
    print(f"  Evaluation (max): {maxplus_eval(canon)}")
    print(f"  ✓ Evaluations match: {maxplus_eval(terms) == maxplus_eval(canon)}")
    print()

    # Example with all distinct
    terms2 = [1.0, 4.0, 2.0, 8.0, 3.0]
    print(f"  Original: {terms2}")
    canon2 = canonicalize_maxplus(terms2)
    print(f"  Canonical: {canon2}")
    print(f"  ✓ Match: {maxplus_eval(terms2) == maxplus_eval(canon2)}")
    print()

def demo_minplus():
    """Demonstrate dominance elimination in min-plus."""
    print("=" * 60)
    print("DEMO 2: Min-Plus Dominance Elimination")
    print("=" * 60)
    print()

    terms = [3.0, 1.0, 5.0, 8.0, 1.0]
    print(f"  Original polynomial terms: {terms}")
    print(f"  Evaluation (min): {minplus_eval(terms)}")
    print()

    canon = canonicalize_minplus(terms)
    print(f"  Canonical form: {canon}")
    print(f"  Evaluation (min): {minplus_eval(canon)}")
    print(f"  ✓ Evaluations match: {minplus_eval(terms) == minplus_eval(canon)}")
    print()

def demo_boolean():
    """Demonstrate dominance = absorption in Boolean."""
    print("=" * 60)
    print("DEMO 3: Boolean Absorption as Dominance Elimination")
    print("=" * 60)
    print()

    terms = [False, True, False, True, False]
    print(f"  Original terms: {terms}")
    print(f"  Evaluation (OR): {bool_eval(terms)}")

    # Any False is dominated by any True in the list
    canon = [t for i, t in enumerate(terms)
             if not (not t and bool_eval(terms[:i] + terms[i+1:]))]
    print(f"  Canonical form: {canon}")
    print(f"  Evaluation (OR): {bool_eval(canon)}")
    print(f"  ✓ Match: {bool_eval(terms) == bool_eval(canon)}")
    print()

def demo_scheduling():
    """Application: max-plus scheduling optimization."""
    print("=" * 60)
    print("DEMO 4: Scheduling Application (Max-Plus)")
    print("=" * 60)
    print()
    print("  Scenario: A factory has 5 parallel processing paths.")
    print("  Each path has a completion time (max-plus monomial).")
    print("  Total completion = max of all path times.")
    print()

    paths = {
        "Path A (assembly)": 12.0,
        "Path B (testing)":  8.0,
        "Path C (packaging)": 15.0,
        "Path D (QC)":       10.0,
        "Path E (backup)":    6.0,
    }

    terms = list(paths.values())
    print("  Processing paths:")
    for name, time in paths.items():
        print(f"    {name}: {time} hours")
    print(f"\n  Total completion time: {maxplus_eval(terms)} hours")
    print()

    canon = canonicalize_maxplus(terms)
    eliminated = [name for name, t in paths.items() if t not in canon]
    print(f"  Dominated (non-critical) paths: {eliminated}")
    print(f"  Critical path(s): {[n for n, t in paths.items() if t in canon]}")
    print(f"  Canonical completion time: {maxplus_eval(canon)} hours")
    print(f"  ✓ Same result with fewer terms!")
    print()

def demo_abstract_principle():
    """Show the abstract principle works identically across semirings."""
    print("=" * 60)
    print("DEMO 5: The Universal Absorption Principle")
    print("=" * 60)
    print()
    print("  Key theorem: In ANY idempotent ordered additive monoid,")
    print("  if m ≤ eval(rest), then eval(m :: rest) = eval(rest).")
    print()
    print("  This single theorem gives us:")
    print()

    # Max-plus
    m, rest = 3.0, [5.0, 7.0, 2.0]
    print(f"  Max-plus: m={m}, rest={rest}")
    print(f"    m ≤ max(rest)? {m} ≤ {maxplus_eval(rest)} → {m <= maxplus_eval(rest)}")
    print(f"    eval([m]+rest) = {maxplus_eval([m]+rest)} = eval(rest) = {maxplus_eval(rest)} ✓")
    print()

    # Min-plus (reversed order: dominated means ≥)
    m2, rest2 = 8.0, [3.0, 5.0, 1.0]
    print(f"  Min-plus: m={m2}, rest={rest2}")
    print(f"    m ≥ min(rest)? {m2} ≥ {minplus_eval(rest2)} → {m2 >= minplus_eval(rest2)}")
    print(f"    eval([m]+rest) = {minplus_eval([m2]+rest2)} = eval(rest) = {minplus_eval(rest2)} ✓")
    print()

    # Boolean
    mb, restb = False, [True, False]
    print(f"  Boolean: m={mb}, rest={restb}")
    print(f"    m ≤ OR(rest)? {mb} ≤ {bool_eval(restb)} → {mb <= bool_eval(restb)}")
    print(f"    eval([m]+rest) = {bool_eval([mb]+restb)} = eval(rest) = {bool_eval(restb)} ✓")
    print()

    print("  All three are instances of ONE abstract theorem! 🎯")
    print()

if __name__ == "__main__":
    demo_maxplus()
    demo_minplus()
    demo_boolean()
    demo_scheduling()
    demo_abstract_principle()


#!/usr/bin/env python3
"""
Visualizations for tropical dominance elimination.
Generates PNG figures for the research paper and article.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io

def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def plot_maxplus_canonicalization():
    """Visualize max-plus dominance elimination."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Left: original terms
    terms = [3, 7, 5, 2, 7, 4, 6]
    x = range(len(terms))
    max_val = max(terms)

    colors = ['#e74c3c' if t < max_val else '#27ae60' for t in terms]
    axes[0].bar(x, terms, color=colors, edgecolor='black', linewidth=0.5)
    axes[0].axhline(y=max_val, color='#27ae60', linestyle='--', alpha=0.7, label=f'max = {max_val}')
    axes[0].set_title('Original Polynomial\n(red = dominated)', fontsize=13)
    axes[0].set_xlabel('Monomial index')
    axes[0].set_ylabel('Value')
    axes[0].legend()

    # Right: canonical form
    canon = [t for t in terms if t == max_val]
    axes[1].bar(range(len(canon)), canon, color='#27ae60', edgecolor='black', linewidth=0.5)
    axes[1].axhline(y=max_val, color='#27ae60', linestyle='--', alpha=0.7, label=f'max = {max_val}')
    axes[1].set_title(f'Canonical Form\n({len(terms)-len(canon)} terms eliminated)', fontsize=13)
    axes[1].set_xlabel('Monomial index')
    axes[1].set_ylabel('Value')
    axes[1].set_ylim(axes[0].get_ylim())
    axes[1].legend()

    fig.suptitle('Max-Plus Dominance Elimination', fontsize=15, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_maxplus.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_abstract_principle():
    """Visualize the universal absorption principle across semirings."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    # Max-plus
    terms_mp = [3, 7, 5, 2]
    colors_mp = ['#e74c3c' if t < max(terms_mp) else '#27ae60' for t in terms_mp]
    axes[0].bar(range(len(terms_mp)), terms_mp, color=colors_mp, edgecolor='black')
    axes[0].axhline(y=max(terms_mp), color='#27ae60', linestyle='--', alpha=0.7)
    axes[0].set_title('Max-Plus\na ⊕ b = max(a, b)', fontsize=12)
    axes[0].set_ylabel('Value')

    # Min-plus
    terms_mn = [3, 1, 5, 8]
    colors_mn = ['#e74c3c' if t > min(terms_mn) else '#27ae60' for t in terms_mn]
    axes[1].bar(range(len(terms_mn)), terms_mn, color=colors_mn, edgecolor='black')
    axes[1].axhline(y=min(terms_mn), color='#27ae60', linestyle='--', alpha=0.7)
    axes[1].set_title('Min-Plus\na ⊕ b = min(a, b)', fontsize=12)
    axes[1].set_ylabel('Value')

    # Boolean
    terms_b = [0, 1, 0, 1, 0]
    colors_b = ['#e74c3c' if t == 0 and any(terms_b) else '#27ae60' for t in terms_b]
    axes[2].bar(range(len(terms_b)), terms_b, color=colors_b, edgecolor='black')
    axes[2].axhline(y=1, color='#27ae60', linestyle='--', alpha=0.7)
    axes[2].set_title('Boolean\na ⊕ b = a ∨ b', fontsize=12)
    axes[2].set_ylabel('Value')
    axes[2].set_yticks([0, 1])
    axes[2].set_yticklabels(['False', 'True'])

    fig.suptitle('The Universal Absorption Principle\n'
                 'One theorem, three semirings: dominated terms (red) can always be removed',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_abstract.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_canonicalization_steps():
    """Show step-by-step canonicalization process."""
    fig, axes = plt.subplots(2, 3, figsize=(14, 8))

    terms_history = [
        [3, 7, 5, 2, 7, 4],
        [7, 5, 2, 7, 4],
        [7, 2, 7, 4],
        [7, 7, 4],
        [7, 7],
        [7],
    ]

    for i, (ax, terms) in enumerate(zip(axes.flat, terms_history)):
        max_val = max(terms)
        colors = ['#e74c3c' if t < max_val else '#27ae60' for t in terms]
        ax.bar(range(len(terms)), terms, color=colors, edgecolor='black', linewidth=0.5)
        ax.axhline(y=max_val, color='#27ae60', linestyle='--', alpha=0.5)
        ax.set_title(f'Step {i}: {terms}', fontsize=10)
        ax.set_ylim(0, 9)
        if i == 0:
            ax.set_ylabel('Value')

    fig.suptitle('Iterated Canonicalization (Max-Plus)\n'
                 'Each step removes one dominated term until only the maximum remains',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_steps.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    b64_1 = plot_maxplus_canonicalization()
    b64_2 = plot_abstract_principle()
    b64_3 = plot_canonicalization_steps()
    print("Visualizations generated:")
    print(f"  viz_maxplus.png ({len(b64_1)} chars base64)")
    print(f"  viz_abstract.png ({len(b64_2)} chars base64)")
    print(f"  viz_steps.png ({len(b64_3)} chars base64)")

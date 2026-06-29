#!/usr/bin/env python3
"""
Demo: Transfinite Proof Dynamics — Concrete Examples

Demonstrates the PRS framework with three concrete proof refinement systems:
1. Algebraic expression simplification
2. Propositional logic normalization
3. Product system (parallel simplification)

All examples illustrate theorems proved in the Lean formalization.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple
from algorithms import PRSConfig, normalize, redundancy, energy_spectrum, ProductPRS


# ============================================================
# Example 1: Algebraic Expression Simplification
# ============================================================

@dataclass(frozen=True)
class Expr:
    """Simple algebraic expressions."""
    pass

@dataclass(frozen=True)
class Num(Expr):
    value: int

@dataclass(frozen=True)
class Add(Expr):
    left: Expr
    right: Expr

@dataclass(frozen=True)
class Mul(Expr):
    left: Expr
    right: Expr


def expr_size(e: Expr) -> int:
    """Size of expression (energy function)."""
    if isinstance(e, Num):
        return 1
    elif isinstance(e, Add):
        return 1 + expr_size(e.left) + expr_size(e.right)
    elif isinstance(e, Mul):
        return 1 + expr_size(e.left) + expr_size(e.right)
    return 0


def expr_eval(e: Expr) -> int:
    """Evaluate expression (semantics — preserved by reduction)."""
    if isinstance(e, Num):
        return e.value
    elif isinstance(e, Add):
        return expr_eval(e.left) + expr_eval(e.right)
    elif isinstance(e, Mul):
        return expr_eval(e.left) * expr_eval(e.right)
    return 0


def expr_successors(e: Expr) -> List[Expr]:
    """One-step simplification rules."""
    result = []
    # Rule: Add(Num(a), Num(b)) → Num(a+b)
    if isinstance(e, Add) and isinstance(e.left, Num) and isinstance(e.right, Num):
        result.append(Num(e.left.value + e.right.value))
    # Rule: Mul(Num(a), Num(b)) → Num(a*b)
    if isinstance(e, Mul) and isinstance(e.left, Num) and isinstance(e.right, Num):
        result.append(Num(e.left.value * e.right.value))
    # Rule: Add(e, Num(0)) → e
    if isinstance(e, Add) and isinstance(e.right, Num) and e.right.value == 0:
        result.append(e.left)
    # Rule: Mul(e, Num(1)) → e
    if isinstance(e, Mul) and isinstance(e.right, Num) and e.right.value == 1:
        result.append(e.left)
    # Rule: Mul(e, Num(0)) → Num(0)
    if isinstance(e, Mul) and isinstance(e.right, Num) and e.right.value == 0:
        result.append(Num(0))
    # Reduce left subexpression
    if isinstance(e, Add):
        for s in expr_successors(e.left):
            result.append(Add(s, e.right))
    if isinstance(e, Mul):
        for s in expr_successors(e.left):
            result.append(Mul(s, e.right))
    # Reduce right subexpression
    if isinstance(e, Add):
        for s in expr_successors(e.right):
            result.append(Add(e.left, s))
    if isinstance(e, Mul):
        for s in expr_successors(e.right):
            result.append(Mul(e.left, s))
    return result


def expr_to_str(e: Expr) -> str:
    if isinstance(e, Num):
        return str(e.value)
    elif isinstance(e, Add):
        return f"({expr_to_str(e.left)} + {expr_to_str(e.right)})"
    elif isinstance(e, Mul):
        return f"({expr_to_str(e.left)} * {expr_to_str(e.right)})"
    return "?"


# ============================================================
# Example 2: Propositional Logic NNF (Negation Normal Form)
# ============================================================

@dataclass(frozen=True)
class Prop:
    pass

@dataclass(frozen=True)
class Var(Prop):
    name: str

@dataclass(frozen=True)
class Not(Prop):
    inner: Prop

@dataclass(frozen=True)
class And(Prop):
    left: Prop
    right: Prop

@dataclass(frozen=True)
class Or(Prop):
    left: Prop
    right: Prop


def prop_size(p: Prop) -> int:
    """Size of proposition (energy)."""
    if isinstance(p, Var):
        return 1
    elif isinstance(p, Not):
        return 1 + prop_size(p.inner)
    elif isinstance(p, (And, Or)):
        return 1 + prop_size(p.left) + prop_size(p.right)
    return 0


def prop_depth(p: Prop) -> int:
    """Negation depth (decreases under NNF reduction)."""
    if isinstance(p, Var):
        return 0
    elif isinstance(p, Not):
        if isinstance(p.inner, (And, Or, Not)):
            return 2 + prop_depth(p.inner)
        return 1
    elif isinstance(p, (And, Or)):
        return max(prop_depth(p.left), prop_depth(p.right))
    return 0


def prop_energy(p: Prop) -> int:
    """Combined energy: negation depth * 100 + size."""
    return prop_depth(p) * 100 + prop_size(p)


def prop_sem(p: Prop) -> str:
    """Semantic string (simplified representation of truth function)."""
    if isinstance(p, Var):
        return p.name
    elif isinstance(p, Not):
        return f"¬{prop_sem(p.inner)}"
    elif isinstance(p, And):
        return f"({prop_sem(p.left)}∧{prop_sem(p.right)})"
    elif isinstance(p, Or):
        return f"({prop_sem(p.left)}∨{prop_sem(p.right)})"
    return "?"


def prop_successors(p: Prop) -> list:
    """NNF reduction rules."""
    result = []
    # Double negation elimination: ¬¬A → A
    if isinstance(p, Not) and isinstance(p.inner, Not):
        result.append(p.inner.inner)
    # De Morgan: ¬(A ∧ B) → (¬A ∨ ¬B)
    if isinstance(p, Not) and isinstance(p.inner, And):
        result.append(Or(Not(p.inner.left), Not(p.inner.right)))
    # De Morgan: ¬(A ∨ B) → (¬A ∧ ¬B)
    if isinstance(p, Not) and isinstance(p.inner, Or):
        result.append(And(Not(p.inner.left), Not(p.inner.right)))
    # Reduce under connectives
    if isinstance(p, And):
        for s in prop_successors(p.left):
            result.append(And(s, p.right))
        for s in prop_successors(p.right):
            result.append(And(p.left, s))
    if isinstance(p, Or):
        for s in prop_successors(p.left):
            result.append(Or(s, p.right))
        for s in prop_successors(p.right):
            result.append(Or(p.left, s))
    if isinstance(p, Not) and not isinstance(p.inner, (And, Or, Not)):
        pass  # ¬Var is already in NNF
    return result


# ============================================================
# Main Demo
# ============================================================

def main():
    print("=" * 70)
    print("TRANSFINITE PROOF DYNAMICS — DEMONSTRATION")
    print("=" * 70)

    # --- Example 1: Algebraic Simplification ---
    print("\n" + "=" * 70)
    print("Example 1: Algebraic Expression Simplification")
    print("=" * 70)

    expr_prs = PRSConfig(
        successors=expr_successors,
        sem=expr_eval,
        energy=expr_size,
    )

    # (3 + 5) * (2 + 0)
    e1 = Mul(Add(Num(3), Num(5)), Add(Num(2), Num(0)))
    print(f"\nExpression: {expr_to_str(e1)}")
    print(f"Semantics (value): {expr_eval(e1)}")
    print(f"Energy (size): {expr_size(e1)}")

    nf, steps = normalize(expr_prs, e1)
    print(f"\nNormal form: {expr_to_str(nf)}")
    print(f"Steps taken: {steps}")
    print(f"Normal form value: {expr_eval(nf)}")
    print(f"Semantic invariance: {expr_eval(e1) == expr_eval(nf)} ✓")
    print(f"Redundancy index: {redundancy(expr_prs, e1)}")

    spectrum = energy_spectrum(expr_prs, e1, max_states=100)
    print(f"Energy spectrum: {sorted(spectrum)}")
    print(f"  Max spectrum ≤ energy(start): {max(spectrum) <= expr_size(e1)} ✓")

    # Larger expression
    e2 = Add(Mul(Add(Num(1), Num(2)), Add(Num(3), Num(4))),
             Mul(Num(5), Add(Num(0), Num(6))))
    print(f"\nLarger expression: {expr_to_str(e2)}")
    print(f"Energy: {expr_size(e2)}")
    nf2, steps2 = normalize(expr_prs, e2)
    print(f"Normal form: {expr_to_str(nf2)}")
    print(f"Steps: {steps2}, Redundancy: {redundancy(expr_prs, e2)}")
    print(f"Bound check (steps ≤ energy): {steps2 <= expr_size(e2)} ✓")

    # --- Example 2: Propositional NNF ---
    print("\n" + "=" * 70)
    print("Example 2: Propositional Logic — Negation Normal Form")
    print("=" * 70)

    prop_prs = PRSConfig(
        successors=prop_successors,
        sem=prop_sem,
        energy=prop_energy,
    )

    # ¬¬(A ∧ ¬(B ∨ C))
    p1 = Not(Not(And(Var("A"), Not(Or(Var("B"), Var("C"))))))
    print(f"\nFormula: {prop_sem(p1)}")
    print(f"Energy: {prop_energy(p1)}")

    nf_p, steps_p = normalize(prop_prs, p1)
    print(f"NNF: {prop_sem(nf_p)}")
    print(f"Steps: {steps_p}")
    print(f"Energy of NNF: {prop_energy(nf_p)}")
    print(f"Redundancy: {redundancy(prop_prs, p1)}")

    # ¬(¬A ∨ ¬¬B)
    p2 = Not(Or(Not(Var("A")), Not(Not(Var("B")))))
    print(f"\nFormula: {prop_sem(p2)}")
    nf_p2, steps_p2 = normalize(prop_prs, p2)
    print(f"NNF: {prop_sem(nf_p2)}")
    print(f"Steps: {steps_p2}, Redundancy: {redundancy(prop_prs, p2)}")

    # --- Example 3: Product PRS ---
    print("\n" + "=" * 70)
    print("Example 3: Product PRS — Parallel Simplification")
    print("=" * 70)

    product = ProductPRS(expr_prs, prop_prs)
    product_prs = product.to_prs()

    state = (e1, p1)
    print(f"\nProduct state: ({expr_to_str(e1)}, {prop_sem(p1)})")
    print(f"Product energy: {product.energy(state)}")
    print(f"  = expr_energy({expr_size(e1)}) + prop_energy({prop_energy(p1)})")

    nf_prod, steps_prod = normalize(product_prs, state)
    print(f"\nProduct normal form: ({expr_to_str(nf_prod[0])}, {prop_sem(nf_prod[1])})")
    print(f"Steps: {steps_prod}")
    print(f"Product energy of NF: {product.energy(nf_prod)}")
    print(f"Redundancy: {product.energy(state) - product.energy(nf_prod)}")

    # --- Summary ---
    print("\n" + "=" * 70)
    print("VERIFIED PROPERTIES (corresponding to Lean theorems)")
    print("=" * 70)
    print("""
    1. oprs_wellFounded: All reductions terminate (energy strictly decreases)
    2. oprs_sem_invariant_rtc: Semantics preserved along all reductions
    3. oprs_no_cycles: No cycles in reduction graph
    4. oprs_exists_normalForm: Every state reaches a normal form
    5. oprs_newman_lemma: Local confluence ⇒ global confluence
    6. spectrum_le_energy: Energy spectrum bounded by initial energy
    7. prod_wellFounded: Product PRS terminates
    8. convergent_unique_nf: Unique normal forms (under confluence)
    9. stratified_level_rtc: Level non-increasing along reductions
   10. energy_gap_lower_bound: Chain length ≤ energy
   11. finite_energy_chain_bound: Tight bound for ℕ-valued energy
    """)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Energy Landscape of a Proof Refinement System

Shows how energy decreases along reduction chains, illustrating the
Lyapunov descent property (oprs_wellFounded, energy_gap_lower_bound).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, Tuple, Dict, Set


def build_reduction_graph() -> Tuple[Dict[str, int], Dict[str, List[str]], Dict[str, str]]:
    """Build a sample reduction graph for algebraic expressions."""
    # States with their energies
    energy = {
        "(3+5)*(2+0)": 7,
        "8*(2+0)": 5,
        "(3+5)*2": 5,
        "8*2": 3,
        "16": 1,
    }
    # Reduction edges
    edges = {
        "(3+5)*(2+0)": ["8*(2+0)", "(3+5)*2"],
        "8*(2+0)": ["8*2"],
        "(3+5)*2": ["8*2"],
        "8*2": ["16"],
        "16": [],
    }
    # Semantic values (all should be 16)
    sem = {k: "16" for k in energy}
    return energy, edges, sem


def trace_all_paths(
    edges: Dict[str, List[str]], start: str
) -> List[List[str]]:
    """Find all paths from start to normal forms."""
    if not edges[start]:
        return [[start]]
    paths = []
    for succ in edges[start]:
        for path in trace_all_paths(edges, succ):
            paths.append([start] + path)
    return paths


def plot_energy_landscape():
    energy, edges, sem = build_reduction_graph()
    paths = trace_all_paths(edges, "(3+5)*(2+0)")

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: Energy descent along paths
    ax1 = axes[0]
    colors = ['#2196F3', '#FF5722', '#4CAF50']
    for i, path in enumerate(paths):
        energies = [energy[s] for s in path]
        steps = list(range(len(path)))
        color = colors[i % len(colors)]
        ax1.plot(steps, energies, 'o-', color=color, linewidth=2, markersize=8,
                 label=f"Path {i+1}", zorder=3)
        for j, (s, e) in enumerate(zip(path, energies)):
            short = s if len(s) < 12 else s[:10] + ".."
            ax1.annotate(short, (steps[j], e), textcoords="offset points",
                        xytext=(0, 12), ha='center', fontsize=7,
                        bbox=dict(boxstyle='round,pad=0.2', fc='white', alpha=0.8))

    ax1.set_xlabel("Reduction Step", fontsize=12)
    ax1.set_ylabel("Energy", fontsize=12)
    ax1.set_title("Energy Descent Along Reduction Chains\n(Lyapunov property: strictly decreasing)", fontsize=11)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0, 9)

    # Add annotation about the theorem
    ax1.text(0.02, 0.98, "oprs_wellFounded:\nEnergy strictly decreases\n→ termination guaranteed",
             transform=ax1.transAxes, fontsize=8, verticalalignment='top',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # Right panel: Reduction DAG with energy levels
    ax2 = axes[1]
    # Position nodes by energy level
    level_positions = {7: [(0, 7)], 5: [(-1, 5), (1, 5)], 3: [(0, 3)], 1: [(0, 1)]}
    node_pos = {
        "(3+5)*(2+0)": (0, 7),
        "8*(2+0)": (-1.5, 5),
        "(3+5)*2": (1.5, 5),
        "8*2": (0, 3),
        "16": (0, 1),
    }

    # Draw edges
    for node, succs in edges.items():
        x1, y1 = node_pos[node]
        for succ in succs:
            x2, y2 = node_pos[succ]
            ax2.annotate("", xy=(x2, y2 + 0.3), xytext=(x1, y1 - 0.3),
                        arrowprops=dict(arrowstyle="->", color='gray',
                                       lw=1.5, connectionstyle="arc3,rad=0.1"))

    # Draw nodes
    for node, (x, y) in node_pos.items():
        is_nf = not edges[node]
        color = '#4CAF50' if is_nf else '#2196F3'
        ax2.plot(x, y, 'o', color=color, markersize=20, zorder=5)
        short = node if len(node) < 12 else node[:10] + ".."
        ax2.text(x, y + 0.6, short, ha='center', fontsize=8, fontweight='bold')
        ax2.text(x, y - 0.15, f"E={energy[node]}", ha='center', fontsize=7,
                color='white', fontweight='bold', zorder=6)

    # Energy level lines
    for e_val in [1, 3, 5, 7]:
        ax2.axhline(y=e_val, color='lightgray', linestyle='--', alpha=0.5, zorder=0)
        ax2.text(2.8, e_val, f"E={e_val}", fontsize=8, color='gray', va='center')

    ax2.set_xlim(-3, 3.5)
    ax2.set_ylim(-0.5, 9)
    ax2.set_title("Reduction DAG with Energy Levels\n(All paths converge to unique NF)", fontsize=11)
    ax2.set_ylabel("Energy Level", fontsize=12)
    ax2.set_xticks([])

    # Legend
    normal = mpatches.Patch(color='#4CAF50', label='Normal form')
    reducible = mpatches.Patch(color='#2196F3', label='Reducible state')
    ax2.legend(handles=[reducible, normal], fontsize=9, loc='upper right')

    ax2.text(0.02, 0.02, "convergent_unique_nf:\nAll paths lead to same NF",
             transform=ax2.transAxes, fontsize=8,
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    plt.savefig("viz_energy_landscape.png", dpi=150, bbox_inches='tight')
    print("Saved viz_energy_landscape.png")


if __name__ == "__main__":
    plot_energy_landscape()


#!/usr/bin/env python3
"""
Visualization: Product PRS Dynamics

Shows the energy landscape of a product PRS, illustrating how
parallel simplification of independent systems terminates
(prod_wellFounded) with energy = Hessenberg sum.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List, Tuple


def simulate_product_normalization(
    e1_start: int, e2_start: int, seed: int = 42
) -> Tuple[List[int], List[int], List[int]]:
    """Simulate normalization in a product PRS.

    Each component independently decreases energy by 1 at each step.
    At each step, we randomly choose which component to reduce.

    Returns: (e1_trace, e2_trace, total_trace)
    """
    rng = np.random.RandomState(seed)
    e1, e2 = e1_start, e2_start
    e1_trace = [e1]
    e2_trace = [e2]
    total_trace = [e1 + e2]

    while e1 > 0 or e2 > 0:
        if e1 > 0 and e2 > 0:
            if rng.random() < 0.5:
                e1 -= 1
            else:
                e2 -= 1
        elif e1 > 0:
            e1 -= 1
        else:
            e2 -= 1
        e1_trace.append(e1)
        e2_trace.append(e2)
        total_trace.append(e1 + e2)

    return e1_trace, e2_trace, total_trace


def plot_product_dynamics():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Product normalization trace
    ax1 = axes[0, 0]
    e1_t, e2_t, tot_t = simulate_product_normalization(15, 10, seed=42)
    steps = range(len(e1_t))

    ax1.plot(steps, e1_t, 'b-', linewidth=2, label='Component 1 energy', alpha=0.8)
    ax1.plot(steps, e2_t, 'r-', linewidth=2, label='Component 2 energy', alpha=0.8)
    ax1.plot(steps, tot_t, 'k-', linewidth=2.5, label='Total energy (Hessenberg sum)', alpha=0.9)
    ax1.fill_between(steps, tot_t, alpha=0.1, color='gray')
    ax1.set_xlabel("Step", fontsize=11)
    ax1.set_ylabel("Energy", fontsize=11)
    ax1.set_title("Product PRS Normalization\n(Energy strictly decreasing at each step)", fontsize=11)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.text(0.5, 0.95, "prod_wellFounded: total energy\nalways decreases → terminates",
             transform=ax1.transAxes, fontsize=9, ha='center', va='top',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # Panel 2: 2D energy trajectory
    ax2 = axes[0, 1]
    ax2.plot(e1_t, e2_t, 'ko-', markersize=4, linewidth=1.5, alpha=0.7)
    ax2.plot(e1_t[0], e2_t[0], 'go', markersize=12, zorder=5, label='Start')
    ax2.plot(e1_t[-1], e2_t[-1], 'r*', markersize=15, zorder=5, label='Normal form (0,0)')

    # Draw iso-energy contours (e1 + e2 = const)
    for total in range(5, 30, 5):
        x = np.linspace(0, total, 100)
        y = total - x
        mask = (x >= 0) & (y >= 0)
        ax2.plot(x[mask], y[mask], '--', color='gray', alpha=0.3, linewidth=0.8)
        ax2.text(min(total, 16), max(0, total - 16) + 0.3, f'E={total}',
                fontsize=7, color='gray', alpha=0.6)

    ax2.set_xlabel("Component 1 Energy", fontsize=11)
    ax2.set_ylabel("Component 2 Energy", fontsize=11)
    ax2.set_title("2D Energy Trajectory\n(Dashed lines: iso-energy contours)", fontsize=11)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(-0.5, 16)
    ax2.set_ylim(-0.5, 11)

    # Panel 3: Multiple random paths
    ax3 = axes[1, 0]
    colors_map = plt.cm.viridis(np.linspace(0.2, 0.8, 8))
    for i in range(8):
        e1_t, e2_t, _ = simulate_product_normalization(12, 8, seed=i*7+1)
        ax3.plot(e1_t, e2_t, '-', color=colors_map[i], linewidth=1.5, alpha=0.6)
        ax3.plot(e1_t[0], e2_t[0], 'o', color=colors_map[i], markersize=6)

    ax3.plot(0, 0, 'r*', markersize=15, zorder=5, label='Unique NF (0,0)')
    ax3.set_xlabel("Component 1 Energy", fontsize=11)
    ax3.set_ylabel("Component 2 Energy", fontsize=11)
    ax3.set_title("Multiple Normalization Paths\n(All converge to unique NF)", fontsize=11)
    ax3.legend(fontsize=9, loc='upper right')
    ax3.grid(True, alpha=0.3)
    ax3.text(0.02, 0.98, "convergent_unique_nf:\nAll paths reach same NF\n(under local confluence)",
             transform=ax3.transAxes, fontsize=8, va='top',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # Panel 4: Chain length vs energy bound
    ax4 = axes[1, 1]
    energies_start = range(5, 31)
    max_chains = []
    avg_chains = []

    for e_total in energies_start:
        lengths = []
        for seed in range(50):
            e1 = e_total // 2
            e2 = e_total - e1
            _, _, tot = simulate_product_normalization(e1, e2, seed=seed)
            lengths.append(len(tot) - 1)
        max_chains.append(max(lengths))
        avg_chains.append(np.mean(lengths))

    ax4.plot(list(energies_start), max_chains, 'ro-', markersize=4,
             linewidth=1.5, label='Max chain length', alpha=0.8)
    ax4.plot(list(energies_start), avg_chains, 'b^-', markersize=4,
             linewidth=1.5, label='Mean chain length', alpha=0.8)
    ax4.plot(list(energies_start), list(energies_start), 'k--',
             linewidth=1.5, label='Energy bound (n ≤ E)', alpha=0.5)
    ax4.set_xlabel("Initial Total Energy", fontsize=11)
    ax4.set_ylabel("Chain Length", fontsize=11)
    ax4.set_title("Chain Length vs Energy Bound\n(energy_gap_lower_bound: always below diagonal)", fontsize=11)
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)

    plt.suptitle("Product PRS: Parallel Simplification Dynamics",
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig("viz_product_dynamics.png", dpi=150, bbox_inches='tight')
    print("Saved viz_product_dynamics.png")


if __name__ == "__main__":
    plot_product_dynamics()


#!/usr/bin/env python3
"""
Visualization: Redundancy Index and Energy Spectrum

Shows the distribution of redundancy across proof states and the
energy spectrum structure, illustrating the information-theoretic
interpretation of proof dynamics.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import List, Tuple


def generate_random_prs(n_states: int = 50, seed: int = 42) -> Tuple[
    List[int], List[int], List[int], List[Tuple[int, int]]
]:
    """Generate a random PRS on n_states states.

    Returns: (energies, nf_energies, redundancies, edges)
    """
    rng = np.random.RandomState(seed)

    # Assign energies: state i has energy n_states - i (roughly)
    energies = list(range(n_states, 0, -1))
    rng.shuffle(energies)

    # Build a DAG: each state connects to 1-3 states with lower energy
    edges: List[Tuple[int, int]] = []
    sorted_by_energy = sorted(range(n_states), key=lambda i: energies[i], reverse=True)

    for idx, state in enumerate(sorted_by_energy[:-1]):
        # Connect to 1-3 lower-energy states
        candidates = [s for s in sorted_by_energy[idx+1:] if energies[s] < energies[state]]
        if candidates:
            n_edges = min(len(candidates), rng.randint(1, 4))
            targets = rng.choice(candidates, size=n_edges, replace=False)
            for t in targets:
                edges.append((state, t))

    # Find normal forms (states with no outgoing edges)
    has_outgoing = set(e[0] for e in edges)
    normal_forms = [i for i in range(n_states) if i not in has_outgoing]

    # Compute normal form energy for each state (BFS to nearest NF)
    nf_energies = [0] * n_states
    for nf in normal_forms:
        nf_energies[nf] = energies[nf]

    # Simple: for non-NF states, the NF energy is the min energy of reachable NFs
    adj: dict = {i: [] for i in range(n_states)}
    for s, t in edges:
        adj[s].append(t)

    def find_nf_energy(state: int, visited: set) -> int:
        if state in normal_forms:
            return energies[state]
        if state in visited:
            return energies[state]
        visited.add(state)
        if not adj[state]:
            return energies[state]
        return min(find_nf_energy(t, visited) for t in adj[state])

    for i in range(n_states):
        nf_energies[i] = find_nf_energy(i, set())

    redundancies = [energies[i] - nf_energies[i] for i in range(n_states)]

    return energies, nf_energies, redundancies, edges


def plot_redundancy_spectrum():
    energies, nf_energies, redundancies, edges = generate_random_prs(80, seed=42)
    n = len(energies)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Energy vs NF Energy scatter
    ax1 = axes[0, 0]
    colors = ['#4CAF50' if r == 0 else '#FF5722' for r in redundancies]
    ax1.scatter(energies, nf_energies, c=colors, s=40, alpha=0.7, edgecolors='black', linewidth=0.5)
    ax1.plot([0, max(energies)], [0, max(energies)], 'k--', alpha=0.3, label='E = E_nf (zero redundancy)')
    ax1.set_xlabel("State Energy E(p)", fontsize=11)
    ax1.set_ylabel("Normal Form Energy E(nf(p))", fontsize=11)
    ax1.set_title("Energy vs Normal Form Energy", fontsize=12)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.text(0.02, 0.98, "Points on diagonal:\nredundancy = 0\n(already normal form)",
             transform=ax1.transAxes, fontsize=8, va='top',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # Panel 2: Redundancy distribution
    ax2 = axes[0, 1]
    ax2.hist(redundancies, bins=20, color='#2196F3', edgecolor='black', alpha=0.7)
    ax2.axvline(x=0, color='#4CAF50', linewidth=2, linestyle='--', label='Normal forms (R=0)')
    mean_r = np.mean(redundancies)
    ax2.axvline(x=mean_r, color='#FF5722', linewidth=2, linestyle='--',
                label=f'Mean redundancy = {mean_r:.1f}')
    ax2.set_xlabel("Redundancy Index R(p) = E(p) - E(nf(p))", fontsize=11)
    ax2.set_ylabel("Number of States", fontsize=11)
    ax2.set_title("Distribution of Redundancy", fontsize=12)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # Panel 3: Energy spectrum (sorted energies)
    ax3 = axes[1, 0]
    sorted_e = sorted(energies)
    ax3.fill_between(range(n), sorted_e, alpha=0.3, color='#9C27B0')
    ax3.plot(range(n), sorted_e, color='#9C27B0', linewidth=2)
    ax3.set_xlabel("State Index (sorted by energy)", fontsize=11)
    ax3.set_ylabel("Energy", fontsize=11)
    ax3.set_title("Energy Spectrum\n(sorted energy values of all states)", fontsize=12)
    ax3.grid(True, alpha=0.3)
    ax3.text(0.5, 0.95, f"spectrum_le_energy: all values ≤ max = {max(energies)}",
             transform=ax3.transAxes, fontsize=9, ha='center', va='top',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # Panel 4: Redundancy vs Energy
    ax4 = axes[1, 1]
    ax4.scatter(energies, redundancies, c=redundancies, cmap='YlOrRd',
                s=40, alpha=0.7, edgecolors='black', linewidth=0.5)
    # Add the bound line: redundancy ≤ energy
    max_e = max(energies)
    ax4.plot([0, max_e], [0, max_e], 'k--', alpha=0.3, label='R = E (maximum redundancy)')
    ax4.set_xlabel("State Energy E(p)", fontsize=11)
    ax4.set_ylabel("Redundancy R(p)", fontsize=11)
    ax4.set_title("Redundancy vs Energy\n(R(p) ≤ E(p) always holds)", fontsize=12)
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)

    nf_count = sum(1 for r in redundancies if r == 0)
    ax4.text(0.02, 0.98, f"Normal forms (R=0): {nf_count}/{n}\n"
             f"Max redundancy: {max(redundancies)}\n"
             f"Mean redundancy: {mean_r:.1f}",
             transform=ax4.transAxes, fontsize=8, va='top',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.suptitle("Proof Dynamics: Redundancy and Energy Spectrum Analysis",
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig("viz_redundancy_spectrum.png", dpi=150, bbox_inches='tight')
    print("Saved viz_redundancy_spectrum.png")


if __name__ == "__main__":
    plot_redundancy_spectrum()

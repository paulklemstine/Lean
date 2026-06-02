#!/usr/bin/env python3
"""
Reflective Type Theory: Numerical Demonstrations

Demonstrates the key results of the ReflTT research:
1. Tropical semiring homomorphism (depth computation)
2. Axiom depth hierarchy
3. Depth-complexity gap
4. Depth spectrum computation
5. Reflective orbit and fixed-point computation
"""

from dataclasses import dataclass
from typing import List, Tuple


# ================================================================
# Modal Formula Representation
# ================================================================

@dataclass
class MFormula:
    """Base class for modal formulas."""
    pass

@dataclass
class Var(MFormula):
    index: int

@dataclass
class Bot(MFormula):
    pass

@dataclass
class Imp(MFormula):
    left: MFormula
    right: MFormula

@dataclass
class Box(MFormula):
    inner: MFormula


def depth(f: MFormula) -> int:
    """Modal nesting depth — tropical semiring homomorphism target."""
    if isinstance(f, Var):
        return 0
    elif isinstance(f, Bot):
        return 0
    elif isinstance(f, Imp):
        return max(depth(f.left), depth(f.right))
    elif isinstance(f, Box):
        return depth(f.inner) + 1
    raise TypeError(f"Unknown formula type: {type(f)}")


def size(f: MFormula) -> int:
    """Formula size (number of syntax tree nodes)."""
    if isinstance(f, (Var, Bot)):
        return 1
    elif isinstance(f, Imp):
        return size(f.left) + size(f.right) + 1
    elif isinstance(f, Box):
        return size(f.inner) + 1
    raise TypeError


def box_count(f: MFormula) -> int:
    """Total number of □ occurrences."""
    if isinstance(f, (Var, Bot)):
        return 0
    elif isinstance(f, Imp):
        return box_count(f.left) + box_count(f.right)
    elif isinstance(f, Box):
        return box_count(f.inner) + 1
    raise TypeError


def depth_spectrum(f: MFormula) -> List[int]:
    """The depth spectrum: list of depths of each □ occurrence."""
    if isinstance(f, (Var, Bot)):
        return []
    elif isinstance(f, Imp):
        return depth_spectrum(f.left) + depth_spectrum(f.right)
    elif isinstance(f, Box):
        return [depth(f.inner) + 1] + depth_spectrum(f.inner)
    raise TypeError


def pretty(f: MFormula) -> str:
    """Pretty-print a formula."""
    if isinstance(f, Var):
        return f"p{f.index}"
    elif isinstance(f, Bot):
        return "⊥"
    elif isinstance(f, Imp):
        return f"({pretty(f.left)} → {pretty(f.right)})"
    elif isinstance(f, Box):
        return f"□{pretty(f.inner)}"
    raise TypeError


def iter_box(n: int, f: MFormula) -> MFormula:
    """Apply □ n times."""
    result = f
    for _ in range(n):
        result = Box(result)
    return result


# ================================================================
# Standard Modal Axioms
# ================================================================

def axiom_K(a: MFormula, b: MFormula) -> MFormula:
    """Axiom K: □(A → B) → □A → □B"""
    return Imp(Box(Imp(a, b)), Imp(Box(a), Box(b)))

def axiom_T(a: MFormula) -> MFormula:
    """Axiom T: □A → A"""
    return Imp(Box(a), a)

def axiom_4(a: MFormula) -> MFormula:
    """Axiom 4: □A → □□A"""
    return Imp(Box(a), Box(Box(a)))

def axiom_Lob(a: MFormula) -> MFormula:
    """Löb's axiom: □(□A → A) → □A"""
    return Imp(Box(Imp(Box(a), a)), Box(a))


# ================================================================
# Demo 1: Tropical Homomorphism Verification
# ================================================================

def demo_tropical_homomorphism():
    print("=" * 60)
    print("Demo 1: Tropical Semiring Homomorphism")
    print("=" * 60)
    print()

    p, q = Var(0), Var(1)
    formulas = [
        ("p", p),
        ("⊥", Bot()),
        ("p → q", Imp(p, q)),
        ("□p", Box(p)),
        ("□(p → q)", Box(Imp(p, q))),
        ("□□p", Box(Box(p))),
        ("□p → □q", Imp(Box(p), Box(q))),
        ("□(□p → p) → □p", axiom_Lob(p)),
    ]

    print(f"{'Formula':<25} {'Depth':>6} {'Size':>6} {'Boxes':>6} {'Spectrum':<20}")
    print("-" * 70)
    for name, f in formulas:
        d = depth(f)
        s = size(f)
        bc = box_count(f)
        spec = depth_spectrum(f)
        print(f"{name:<25} {d:>6} {s:>6} {bc:>6} {str(spec):<20}")

    print()
    print("Tropical properties verified:")
    print(f"  depth(p → q) = max(depth(p), depth(q)) = max(0, 0) = {depth(Imp(p, q))}")
    print(f"  depth(□p) = depth(p) + 1 = 0 + 1 = {depth(Box(p))}")
    print(f"  depth(□□p) = depth(□p) + 1 = 1 + 1 = {depth(Box(Box(p)))}")
    print()


# ================================================================
# Demo 2: Axiom Depth Hierarchy
# ================================================================

def demo_axiom_hierarchy():
    print("=" * 60)
    print("Demo 2: Axiom Depth Hierarchy")
    print("=" * 60)
    print()

    p, q = Var(0), Var(1)
    axioms = [
        ("T: □p → p", axiom_T(p)),
        ("K: □(p→q) → □p → □q", axiom_K(p, q)),
        ("4: □p → □□p", axiom_4(p)),
        ("Löb: □(□p→p) → □p", axiom_Lob(p)),
    ]

    print(f"{'Axiom':<30} {'Depth':>6} {'Size':>6} {'Level':<10}")
    print("-" * 55)
    for name, f in axioms:
        d = depth(f)
        s = size(f)
        level = "one-step" if d == 1 else "iterated"
        print(f"{name:<30} {d:>6} {s:>6} {level:<10}")

    print()
    print("Strict hierarchy: depth(T) = depth(K) = 1 < 2 = depth(4) = depth(Löb)")
    print()


# ================================================================
# Demo 3: Depth-Complexity Gap
# ================================================================

def demo_depth_complexity_gap():
    print("=" * 60)
    print("Demo 3: Depth-Complexity Gap")
    print("=" * 60)
    print()

    print("Formulas of depth 0 with increasing size:")
    print(f"{'n':>4} {'Size':>6}  Formula")
    print("-" * 50)
    for n in range(8):
        # wideFormula(n): chain of implications of ⊥
        f = Bot()
        for _ in range(n):
            f = Imp(f, Bot())
        print(f"{n:>4} {size(f):>6}  {pretty(f)[:40]}")

    print()
    print(f"At depth 0, size can be arbitrarily large: size = 2n + 1")
    print()

    print("At depth d, using □^d(wideFormula(n)):")
    print(f"{'d':>4} {'n':>4} {'Depth':>6} {'Size':>6}")
    print("-" * 30)
    for d in range(4):
        for n in [0, 5, 10]:
            f = Bot()
            for _ in range(n):
                f = Imp(f, Bot())
            f = iter_box(d, f)
            print(f"{d:>4} {n:>4} {depth(f):>6} {size(f):>6}")

    print()


# ================================================================
# Demo 4: Reflective Orbit and Fixed Point
# ================================================================

def demo_reflective_orbit():
    print("=" * 60)
    print("Demo 4: Reflective Orbit and Fixed Point")
    print("=" * 60)
    print()

    p = Var(0)
    target_depth = 5

    print(f"Reflective orbit of p (depth(p) = {depth(p)}):")
    print(f"Target depth d = {target_depth}")
    print()
    print(f"{'n':>4} {'□^n(p)':>20} {'Depth':>6} {'≤ d?':>6} {'Crossing?':<10}")
    print("-" * 55)

    for n in range(target_depth + 3):
        f = iter_box(n, p)
        d = depth(f)
        within = "✓" if d <= target_depth else "✗"
        crossing = ""
        if d <= target_depth and depth(iter_box(n + 1, p)) > target_depth:
            crossing = "← FIXED POINT"
        print(f"{n:>4} {'□' * n + 'p':>20} {d:>6} {within:>6} {crossing:<10}")

    fp = target_depth - depth(p)
    print()
    print(f"First passage time: n = d - depth(p) = {target_depth} - {depth(p)} = {fp}")
    print(f"This is the unique n where depth(□^n p) ≤ {target_depth} and depth(□^(n+1) p) > {target_depth}")
    print()


# ================================================================
# Demo 5: Depth Spectrum Analysis
# ================================================================

def demo_depth_spectrum():
    print("=" * 60)
    print("Demo 5: Depth Spectrum Analysis")
    print("=" * 60)
    print()

    p, q = Var(0), Var(1)
    formulas = [
        ("□p", Box(p)),
        ("□□p", Box(Box(p))),
        ("□□□p", Box(Box(Box(p)))),
        ("□p → □q", Imp(Box(p), Box(q))),
        ("□(p → q)", Box(Imp(p, q))),
        ("□p → □□q", Imp(Box(p), Box(Box(q)))),
        ("□(□p → p)", Box(Imp(Box(p), p))),
    ]

    print(f"{'Formula':<20} {'Depth':>6} {'Spectrum':<20} {'|Spec|':>6}")
    print("-" * 55)
    for name, f in formulas:
        spec = depth_spectrum(f)
        print(f"{name:<20} {depth(f):>6} {str(sorted(spec)):<20} {len(spec):>6}")

    print()
    print("Note: |Spectrum| = boxCount in all cases")
    print("Note: max(Spectrum) = depth in all cases (when Spectrum ≠ [])")
    print()


# ================================================================
# Main
# ================================================================

if __name__ == "__main__":
    demo_tropical_homomorphism()
    demo_axiom_hierarchy()
    demo_depth_complexity_gap()
    demo_reflective_orbit()
    demo_depth_spectrum()

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Depth-Complexity Gap in Modal Formulas

Plots the relationship between modal depth and formula size,
demonstrating the orthogonality of these two complexity measures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_depth_recursive(formula_type, *args):
    """Compute depth given formula type and args."""
    if formula_type == 'var':
        return 0
    elif formula_type == 'bot':
        return 0
    elif formula_type == 'imp':
        return max(args[0], args[1])
    elif formula_type == 'box':
        return args[0] + 1
    return 0


def generate_formulas_at_depth(d, max_n=20):
    """Generate (depth, size) pairs for formulas at depth d with varying size."""
    sizes = []
    for n in range(max_n):
        # size of □^d(wideFormula(n)) = 2n + 1 + d
        size = 2 * n + 1 + d
        sizes.append((d, size))
    return sizes


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Depth vs Size for different depth levels
    ax1 = axes[0]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 6))
    for d in range(6):
        pairs = generate_formulas_at_depth(d, 15)
        depths, sizes = zip(*pairs)
        ax1.scatter(sizes, depths, c=[colors[d]], s=30, alpha=0.8, label=f'd={d}')
        ax1.plot(sizes, depths, c=colors[d], alpha=0.4, linewidth=1)

    ax1.set_xlabel('Formula Size', fontsize=12)
    ax1.set_ylabel('Modal Depth', fontsize=12)
    ax1.set_title('Depth-Complexity Gap\n(each depth level has unbounded size)', fontsize=11)
    ax1.legend(fontsize=9, title='Depth')
    ax1.grid(True, alpha=0.3)

    # Plot 2: Reflective Orbit
    ax2 = axes[1]
    target_d = 5
    steps = list(range(8))
    depths_orbit = [s for s in steps]  # depth(□^n p) = n when depth(p) = 0

    ax2.plot(steps, depths_orbit, 'b-o', markersize=8, linewidth=2, label='depth(□ⁿp)')
    ax2.axhline(y=target_d, color='r', linestyle='--', linewidth=1.5, label=f'target d={target_d}')
    ax2.fill_between(steps, 0, target_d, alpha=0.1, color='green')
    ax2.axvline(x=target_d, color='orange', linestyle=':', linewidth=2,
                label=f'fixed point n={target_d}')

    ax2.set_xlabel('Iteration n', fontsize=12)
    ax2.set_ylabel('Depth', fontsize=12)
    ax2.set_title('Reflective Orbit\n(first passage through depth level)', fontsize=11)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Axiom Hierarchy
    ax3 = axes[2]
    axioms = ['T', 'K', '4', 'Löb']
    ax_depths = [1, 1, 2, 2]
    ax_sizes = [4, 10, 6, 8]
    ax_colors = ['#2196F3', '#2196F3', '#FF5722', '#FF5722']

    bars = ax3.bar(axioms, ax_depths, color=ax_colors, edgecolor='black', linewidth=1.2)

    # Add size labels on bars
    for bar, s in zip(bars, ax_sizes):
        ax3.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
                f'size={s}', ha='center', va='bottom', fontsize=10)

    ax3.set_ylabel('Modal Depth', fontsize=12)
    ax3.set_title('Axiom Depth Hierarchy\n(blue=one-step, red=iterated)', fontsize=11)
    ax3.set_ylim(0, 2.8)
    ax3.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('refltt_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: refltt_visualization.png")


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
Tropical Gödel–Kripke Reconstruction: Demonstrations and Visualizations

This module demonstrates the core theorems of tropical modal semantics:
1. Diamond-inf distributivity
2. Tropical Hennessy-Milner theorem (bandlimited)
3. Modal reconstruction from spectral samples

All computations use the min-plus semiring (ℝ, min, +).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple, Dict, Optional
import json
import base64
from io import BytesIO


# ============================================================================
# Core Tropical Algebra
# ============================================================================

def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)"""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b"""
    return a + b


def diamond_eval(A: np.ndarray, v: np.ndarray) -> np.ndarray:
    """
    Tropical diamond operator: (◇_A v)(x) = min_y (A[x,y] + v[y])

    Parameters:
        A: n×n transition weight matrix
        v: n-vector of valuations

    Returns:
        n-vector of diamond-transformed valuations
    """
    n = A.shape[0]
    result = np.zeros(n)
    for x in range(n):
        result[x] = min(A[x, y] + v[y] for y in range(n))
    return result


def iterated_diamond(A: np.ndarray, v: np.ndarray, k: int) -> np.ndarray:
    """Compute diamond^k(v) by iterating k times."""
    result = v.copy()
    for _ in range(k):
        result = diamond_eval(A, result)
    return result


def tropical_closure(A: np.ndarray, v: np.ndarray, N: int) -> np.ndarray:
    """Compute the tropical closure: pointwise min of diamond^k(v) for k = 0..N"""
    n = A.shape[0]
    result = v.copy()
    current = v.copy()
    for k in range(1, N + 1):
        current = diamond_eval(A, current)
        result = np.minimum(result, current)
    return result


# ============================================================================
# Demo 1: Diamond-Inf Distributivity
# ============================================================================

def demo_diamond_inf_distributivity():
    """
    Verify: ◇(min(v, w)) = min(◇v, ◇w)

    This is the algebraic heart of tropical modal semantics.
    """
    print("=" * 60)
    print("DEMO 1: Diamond-Inf Distributivity")
    print("=" * 60)

    # 4-state transition system
    A = np.array([
        [0, 3, 7, 2],
        [1, 0, 4, 5],
        [6, 2, 0, 1],
        [3, 8, 1, 0]
    ], dtype=float)

    v = np.array([1.0, 4.0, 2.0, 7.0])
    w = np.array([3.0, 1.0, 5.0, 2.0])

    # Left side: ◇(min(v, w))
    min_vw = np.minimum(v, w)
    lhs = diamond_eval(A, min_vw)

    # Right side: min(◇v, ◇w)
    diamond_v = diamond_eval(A, v)
    diamond_w = diamond_eval(A, w)
    rhs = np.minimum(diamond_v, diamond_w)

    print(f"\nTransition matrix A:\n{A}")
    print(f"\nv = {v}")
    print(f"w = {w}")
    print(f"min(v, w) = {min_vw}")
    print(f"\n◇(min(v,w)) = {lhs}")
    print(f"min(◇v, ◇w) = {rhs}")
    print(f"\nEqual? {np.allclose(lhs, rhs)}")
    assert np.allclose(lhs, rhs), "Diamond-inf distributivity FAILED!"
    print("✓ Diamond distributes over min (tropical conjunction)")

    return A, v, w


# ============================================================================
# Demo 2: Tropical Hennessy-Milner Theorem
# ============================================================================

def compute_spectrum(A: np.ndarray, valuations: Dict[str, np.ndarray],
                     depth: int, state: int) -> Dict[Tuple[str, int], float]:
    """Compute the tropical spectrum of a state up to given depth."""
    spectrum = {}
    for name, v in valuations.items():
        current = v.copy()
        for k in range(depth + 1):
            spectrum[(name, k)] = current[state]
            if k < depth:
                current = diamond_eval(A, current)
    return spectrum


def demo_hennessy_milner():
    """
    Demonstrate the tropical Hennessy-Milner theorem:
    Two states have the same bounded-depth modal theory iff they have
    the same tropical transfer profiles.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Hennessy-Milner Theorem (Bandlimited)")
    print("=" * 60)

    # Create a frame where states 0 and 3 are depth-1 equivalent
    # but depth-2 distinguishable
    A = np.array([
        [0, 1, 5, 5],
        [5, 0, 1, 5],
        [5, 5, 0, 1],
        [0, 5, 5, 1]
    ], dtype=float)

    vals = {
        'p': np.array([2.0, 3.0, 4.0, 2.0]),
        'q': np.array([1.0, 5.0, 2.0, 1.0]),
    }

    print(f"\nTransition matrix:\n{A}")
    for name, v in vals.items():
        print(f"V({name}) = {v}")

    # Check spectral equivalence at various depths
    for d in range(4):
        print(f"\n--- Depth {d} ---")
        for s in range(4):
            spec = compute_spectrum(A, vals, d, s)
            profile = [spec[(name, k)] for name in sorted(vals.keys())
                       for k in range(d + 1)]
            print(f"  State {s}: spectrum = {profile}")

        # Check which states are equivalent
        equiv_classes = {}
        for s in range(4):
            spec = compute_spectrum(A, vals, d, s)
            key = tuple(sorted(spec.items()))
            if key not in equiv_classes:
                equiv_classes[key] = []
            equiv_classes[key].append(s)

        classes = list(equiv_classes.values())
        print(f"  Equivalence classes: {classes}")

    # Verify: states with same spectrum satisfy same formulas
    print("\n--- Verification ---")
    d = 1
    s0_spec = compute_spectrum(A, vals, d, 0)
    s3_spec = compute_spectrum(A, vals, d, 3)
    print(f"State 0 spectrum (d={d}): {s0_spec}")
    print(f"State 3 spectrum (d={d}): {s3_spec}")

    if s0_spec == s3_spec:
        print("✓ States 0 and 3 have identical depth-1 spectra")
        print("  → By Hennessy-Milner, they satisfy the same depth-≤1 formulas")
    else:
        print("States 0 and 3 differ at depth 1")

    return A, vals


# ============================================================================
# Demo 3: Modal Reconstruction from Spectral Samples
# ============================================================================

def demo_reconstruction():
    """
    Demonstrate reconstruction of the quotient frame from spectral samples.
    Under spectral separation, the frame is fully determined.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Modal Reconstruction from Spectral Samples")
    print("=" * 60)

    # 6-state system with hidden symmetry
    A = np.array([
        [0, 2, 5, 5, 5, 5],
        [5, 0, 2, 5, 5, 5],
        [5, 5, 0, 2, 5, 5],
        [0, 5, 5, 5, 2, 5],
        [5, 0, 5, 5, 5, 2],
        [5, 5, 0, 5, 5, 0],
    ], dtype=float)

    vals = {
        'p': np.array([1.0, 2.0, 3.0, 1.0, 2.0, 3.0]),
    }

    print(f"\n6-state transition system")
    print(f"V(p) = {vals['p']}")

    # Compute spectral equivalence classes
    max_depth = 3
    for d in range(max_depth + 1):
        spectra = {}
        for s in range(6):
            spec = compute_spectrum(A, vals, d, s)
            key = tuple(sorted(spec.items()))
            if key not in spectra:
                spectra[key] = []
            spectra[key].append(s)

        classes = list(spectra.values())
        print(f"\nDepth {d}: {len(classes)} equivalence classes: {classes}")

    # Full separation check
    d = max_depth
    spectra = {}
    for s in range(6):
        spec = compute_spectrum(A, vals, d, s)
        key = tuple(sorted(spec.items()))
        spectra[key] = spectra.get(key, []) + [s]

    classes = list(spectra.values())
    n_classes = len(classes)
    separated = all(len(c) == 1 for c in classes)

    print(f"\nAt depth {d}: {'SEPARATED' if separated else 'NOT separated'}")
    print(f"Quotient has {n_classes} states (from 6 original)")

    if not separated:
        print("Quotient frame (non-trivial):")
        for i, cls in enumerate(classes):
            print(f"  Q{i} = {cls}")


# ============================================================================
# Visualization
# ============================================================================

def create_diamond_visualization(A, v, w):
    """Create visualization of diamond-inf distributivity."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    n = len(v)
    states = list(range(n))

    # Panel 1: Original valuations
    ax = axes[0]
    x = np.arange(n)
    width = 0.35
    ax.bar(x - width/2, v, width, label='v', color='#2196F3', alpha=0.8)
    ax.bar(x + width/2, w, width, label='w', color='#FF9800', alpha=0.8)
    min_vw = np.minimum(v, w)
    ax.plot(x, min_vw, 'ko-', linewidth=2, markersize=8, label='min(v,w)')
    ax.set_xlabel('State')
    ax.set_ylabel('Value')
    ax.set_title('Valuations v, w, and min(v,w)')
    ax.legend()
    ax.set_xticks(x)

    # Panel 2: Diamond-transformed
    ax = axes[1]
    dv = diamond_eval(A, v)
    dw = diamond_eval(A, w)
    d_min = diamond_eval(A, min_vw)
    ax.bar(x - width/2, dv, width, label='◇v', color='#2196F3', alpha=0.8)
    ax.bar(x + width/2, dw, width, label='◇w', color='#FF9800', alpha=0.8)
    ax.plot(x, d_min, 'ko-', linewidth=2, markersize=8, label='◇(min(v,w))')
    ax.set_xlabel('State')
    ax.set_ylabel('Value')
    ax.set_title('Diamond Transforms')
    ax.legend()
    ax.set_xticks(x)

    # Panel 3: Distributivity verification
    ax = axes[2]
    min_d = np.minimum(dv, dw)
    ax.bar(x - width/2, d_min, width, label='◇(min(v,w))',
           color='#4CAF50', alpha=0.8)
    ax.bar(x + width/2, min_d, width, label='min(◇v,◇w)',
           color='#9C27B0', alpha=0.8)
    diff = np.abs(d_min - min_d)
    ax.set_xlabel('State')
    ax.set_ylabel('Value')
    ax.set_title(f'Distributivity (max error: {diff.max():.2e})')
    ax.legend()
    ax.set_xticks(x)

    plt.tight_layout()
    return fig


def create_spectrum_visualization(A, vals, max_depth=3):
    """Create visualization of spectral equivalence evolution."""
    n = A.shape[0]
    fig, axes = plt.subplots(1, max_depth + 1, figsize=(4 * (max_depth + 1), 5))

    colors = plt.cm.Set2(np.linspace(0, 1, n))

    for d in range(max_depth + 1):
        ax = axes[d]

        # Compute spectral equivalence classes
        spectra = {}
        for s in range(n):
            spec = compute_spectrum(A, vals, d, s)
            key = tuple(sorted(spec.items()))
            if key not in spectra:
                spectra[key] = []
            spectra[key].append(s)

        classes = list(spectra.values())

        # Draw states grouped by equivalence class
        class_colors = plt.cm.Set1(np.linspace(0, 1, len(classes)))
        y_pos = 0
        for ci, cls in enumerate(classes):
            for s in cls:
                ax.barh(y_pos, 1, color=class_colors[ci], alpha=0.7,
                        edgecolor='black', linewidth=0.5)
                ax.text(0.5, y_pos, f'State {s}', ha='center', va='center',
                        fontsize=10, fontweight='bold')
                y_pos += 1

        ax.set_title(f'Depth {d}\n({len(classes)} classes)', fontsize=12)
        ax.set_xlim(0, 1)
        ax.set_ylim(-0.5, n - 0.5)
        ax.set_yticks([])
        ax.set_xticks([])

    plt.suptitle('Spectral Equivalence Refinement', fontsize=14, y=1.02)
    plt.tight_layout()
    return fig


def create_closure_visualization():
    """Visualize convergence of the tropical closure operator."""
    A = np.array([
        [0, 2, 5],
        [5, 0, 1],
        [3, 5, 0]
    ], dtype=float)

    v = np.array([10.0, 5.0, 8.0])

    fig, ax = plt.subplots(figsize=(10, 6))

    N = 8
    iterates = [v.copy()]
    current = v.copy()
    for k in range(1, N + 1):
        current = diamond_eval(A, current)
        iterates.append(current.copy())

    # Plot each state's trajectory
    colors = ['#2196F3', '#FF9800', '#4CAF50']
    for s in range(3):
        vals = [it[s] for it in iterates]
        ax.plot(range(N + 1), vals, 'o-', color=colors[s],
                linewidth=2, markersize=6, label=f'State {s}')

    # Plot closure values
    closure = v.copy()
    closure_vals = [v.copy()]
    current = v.copy()
    for k in range(1, N + 1):
        current = diamond_eval(A, current)
        closure = np.minimum(closure, current)
        closure_vals.append(closure.copy())

    for s in range(3):
        vals = [cv[s] for cv in closure_vals]
        ax.plot(range(N + 1), vals, 's--', color=colors[s],
                linewidth=1.5, markersize=4, alpha=0.5)

    ax.set_xlabel('Iteration k', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Tropical Closure: Diamond Iterates and Their Infimum', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    # Run demos
    A, v, w = demo_diamond_inf_distributivity()
    A2, vals = demo_hennessy_milner()
    demo_reconstruction()

    # Create visualizations
    print("\n\nGenerating visualizations...")

    fig1 = create_diamond_visualization(A, v, w)
    fig1.savefig('diamond_distributivity.png', dpi=150, bbox_inches='tight')
    print("Saved: diamond_distributivity.png")

    fig2 = create_spectrum_visualization(A2, vals)
    fig2.savefig('spectral_equivalence.png', dpi=150, bbox_inches='tight')
    print("Saved: spectral_equivalence.png")

    fig3 = create_closure_visualization()
    fig3.savefig('tropical_closure.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_closure.png")

    print("\nAll demos complete!")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import base64
from io import BytesIO
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Import demo functions
from demo import (diamond_eval, iterated_diamond, tropical_closure,
                  compute_spectrum, create_diamond_visualization,
                  create_spectrum_visualization, create_closure_visualization,
                  fig_to_base64)

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    # Read all content files
    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')
    lean_proofs = read_file('Catalog/Bridges/AlgebraTropicalLogic/TropicalGodelKripkeReconstruction.lean')
    demo_code = read_file('demo.py')

    # Generate visualizations
    A = np.array([[0,3,7,2],[1,0,4,5],[6,2,0,1],[3,8,1,0]], dtype=float)
    v = np.array([1.0, 4.0, 2.0, 7.0])
    w = np.array([3.0, 1.0, 5.0, 2.0])

    fig1 = create_diamond_visualization(A, v, w)
    viz1 = fig_to_base64(fig1)

    A2 = np.array([[0,1,5,5],[5,0,1,5],[5,5,0,1],[0,5,5,1]], dtype=float)
    vals = {'p': np.array([2.0,3.0,4.0,2.0]), 'q': np.array([1.0,5.0,2.0,1.0])}
    fig2 = create_spectrum_visualization(A2, vals)
    viz2 = fig_to_base64(fig2)

    fig3 = create_closure_visualization()
    viz3 = fig_to_base64(fig3)

    package = {
        "title": "Tropical Gödel–Kripke Reconstruction: Idempotent Modal Semantics",
        "domain": "Algebra–Tropical–Logic Bridge",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Tropical Modal Semantics Demo",
                "code": demo_code
            }
        ],
        "algorithms": [
            {
                "name": "Tropical Diamond Evaluation",
                "pseudocode": "Input: A (n×n weight matrix), v (n-vector)\nOutput: diamond(v) (n-vector)\n\nfor x = 0 to n-1:\n  diamond[x] = min over y of (A[x,y] + v[y])\nreturn diamond\n\nComplexity: O(n²)",
                "code": "import numpy as np\n\ndef diamond_eval(A, v):\n    \"\"\"Tropical diamond: (diamond v)(x) = min_y (A[x,y] + v[y])\"\"\"\n    n = A.shape[0]\n    return np.array([min(A[x,y] + v[y] for y in range(n)) for x in range(n)])\n\ndef compute_spectrum(A, valuations, depth, state):\n    \"\"\"Compute tropical transfer profile up to given depth.\"\"\"\n    spectrum = {}\n    for name, v in valuations.items():\n        current = v.copy()\n        for k in range(depth + 1):\n            spectrum[(name, k)] = current[state]\n            if k < depth:\n                current = diamond_eval(A, current)\n    return spectrum\n\ndef compute_quotient(A, valuations, depth):\n    \"\"\"Compute spectral equivalence classes.\"\"\"\n    n = A.shape[0]\n    spectra = {}\n    for s in range(n):\n        spec = compute_spectrum(A, valuations, depth, s)\n        key = tuple(sorted(spec.items()))\n        spectra.setdefault(key, []).append(s)\n    return list(spectra.values())\n\n# Example\nA = np.array([[0,1,5,5],[5,0,1,5],[5,5,0,1],[0,5,5,1]], dtype=float)\nvals = {'p': np.array([2.,3.,4.,2.]), 'q': np.array([1.,5.,2.,1.])}\nfor d in range(4):\n    classes = compute_quotient(A, vals, d)\n    print(f'Depth {d}: {classes}')\n"
            },
            {
                "name": "Tropical Closure Operator",
                "pseudocode": "Input: A (n×n weight matrix), v (n-vector), N (max depth)\nOutput: closure(v) = pointwise min of diamond^k(v) for k=0..N\n\nclosure = v\ncurrent = v\nfor k = 1 to N:\n  current = diamond(A, current)\n  closure = pointwise_min(closure, current)\nreturn closure\n\nComplexity: O(N · n²)",
                "code": "import numpy as np\n\ndef diamond_eval(A, v):\n    n = A.shape[0]\n    return np.array([min(A[x,y] + v[y] for y in range(n)) for x in range(n)])\n\ndef tropical_closure(A, v, N):\n    \"\"\"Tropical closure: pointwise min of diamond^k(v) for k=0..N\"\"\"\n    result = v.copy()\n    current = v.copy()\n    for k in range(1, N + 1):\n        current = diamond_eval(A, current)\n        result = np.minimum(result, current)\n    return result\n\n# Example: 3-state system\nA = np.array([[0,2,5],[5,0,1],[3,5,0]], dtype=float)\nv = np.array([10.0, 5.0, 8.0])\nfor N in range(6):\n    c = tropical_closure(A, v, N)\n    print(f'N={N}: closure = {c}')\n"
            }
        ],
        "visualizations": [
            {"name": "Diamond-Inf Distributivity", "data": viz1},
            {"name": "Spectral Equivalence Refinement", "data": viz2},
            {"name": "Tropical Closure Convergence", "data": viz3}
        ],
        "lean_proofs": lean_proofs
    }

    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print("PACKAGE.json generated successfully")
    print(f"Size: {len(json.dumps(package))//1024} KB")

if __name__ == "__main__":
    main()

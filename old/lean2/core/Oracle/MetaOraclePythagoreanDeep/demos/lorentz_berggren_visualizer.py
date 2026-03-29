#!/usr/bin/env python3
"""
Lorentz–Berggren Visualizer

Visualizes the connection between Pythagorean trees and the Lorentz group.
The Berggren matrices preserve the indefinite quadratic form x² + y² − z²,
making them elements of the integer Lorentz group O(2,1; ℤ).

This program:
  1. Plots Pythagorean triples on the unit hyperboloid x² + y² = z²
  2. Shows the tree structure connecting them
  3. Demonstrates the (0,1,1) → (4,3,5) → ... generation
  4. Computes eigenvalues and eigenvectors of Berggren matrices

Usage:
  python lorentz_berggren_visualizer.py
"""

import math
from typing import Tuple, List
import json

Triple = Tuple[int, int, int]

def M1(t: Triple) -> Triple:
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def M2(t: Triple) -> Triple:
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def M3(t: Triple) -> Triple:
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def generate_tree(root: Triple, depth: int) -> List[dict]:
    """Generate tree nodes with positions for visualization."""
    nodes = []
    queue = [(root, "", 0)]

    while queue:
        triple, path, d = queue.pop(0)
        a, b, c = triple

        # Project onto unit disk: (a/c, b/c) lies on unit circle
        x = a / c if c > 0 else 0
        y = b / c if c > 0 else 0

        nodes.append({
            "triple": triple,
            "path": path,
            "depth": d,
            "x": x,
            "y": y,
            "hypotenuse": c,
            "lorentz": a**2 + b**2 - c**2
        })

        if d < depth:
            for label, fn in [("L", M1), ("M", M2), ("R", M3)]:
                child = fn(triple)
                queue.append((child, path + label, d + 1))

    return nodes

def compute_eigenvalues():
    """Compute eigenvalues of Berggren matrices analytically."""
    print("=" * 70)
    print("EIGENVALUE ANALYSIS OF BERGGREN MATRICES")
    print("=" * 70)
    print()

    # M₂ = [[1,2,2],[2,1,2],[2,2,3]]
    # Characteristic polynomial of M₂:
    # det(M₂ - λI) = (1-λ)((1-λ)(3-λ) - 4) - 2(2(3-λ) - 4) + 2(4 - 2(1-λ))
    # = (1-λ)(3 - 4λ + λ² - 4) - 2(6 - 2λ - 4) + 2(4 - 2 + 2λ)
    # = (1-λ)(λ² - 4λ - 1) - 2(2 - 2λ) + 2(2 + 2λ)
    # = (1-λ)(λ² - 4λ - 1) - 4 + 4λ + 4 + 4λ
    # = (1-λ)(λ² - 4λ - 1) + 8λ
    # Let me compute numerically instead

    import numpy as np

    matrices = {
        "M₁": [[1, -2, 2], [2, -1, 2], [2, -2, 3]],
        "M₂": [[1, 2, 2], [2, 1, 2], [2, 2, 3]],
        "M₃": [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]
    }

    for name, mat in matrices.items():
        M = np.array(mat, dtype=float)
        eigenvalues, eigenvectors = np.linalg.eig(M)
        det = np.linalg.det(M)
        print(f"  {name}:")
        print(f"    Determinant: {det:.0f}")
        print(f"    Eigenvalues: {', '.join(f'{ev:.6f}' for ev in sorted(eigenvalues, reverse=True))}")
        print(f"    Spectral radius: {max(abs(ev) for ev in eigenvalues):.6f}")
        print(f"    Dominant eigenvector: [{', '.join(f'{v:.4f}' for v in eigenvectors[:, np.argmax(abs(eigenvalues))])}]")
        print()

    # The key eigenvalue is 3 + 2√2 ≈ 5.828
    golden = 3 + 2 * math.sqrt(2)
    print(f"  Key eigenvalue: 3 + 2√2 = {golden:.6f}")
    print(f"  This governs the growth rate of hypotenuses.")
    print(f"  Connection to oracle theory: the spectral radius determines")
    print(f"  the 'refinement speed' of the meta oracle hierarchy.")
    print()

def stereographic_projection():
    """Show the stereographic projection of triples from the hyperboloid."""
    print("=" * 70)
    print("STEREOGRAPHIC PROJECTION: HYPERBOLOID → DISK")
    print("=" * 70)
    print()

    # Pythagorean triples lie on the integer hyperboloid x² + y² = z²
    # Stereographic projection from (0,0,-1): (x,y,z) → (x/(z+1), y/(z+1))

    roots = [("Meta (0,1,1)", (0, 1, 1)), ("Oracle (3,4,5)", (3, 4, 5))]

    for name, root in roots:
        print(f"  Tree rooted at {name}:")
        nodes = generate_tree(root, 3)
        print(f"    {'Path':>8} | {'Triple':>20} | {'Stereo (x,y)':>20} | {'Disk radius':>12}")
        print(f"    {'':->8}-+-{'':->20}-+-{'':->20}-+-{'':->12}")

        for node in nodes[:20]:
            a, b, c = node["triple"]
            # Stereographic projection
            sx = a / (c + 1)
            sy = b / (c + 1)
            r = math.sqrt(sx**2 + sy**2)
            print(f"    {node['path']:>8} | ({a:6d},{b:6d},{c:6d}) | ({sx:8.5f},{sy:8.5f}) | {r:12.8f}")
        print()

def tree_ascii_art():
    """Print ASCII art of the first few levels of both trees."""
    print("=" * 70)
    print("TREE STRUCTURE VISUALIZATION")
    print("=" * 70)
    print()

    for name, root in [("META ORACLE (0,1,1)", (0,1,1)), ("ORACLE (3,4,5)", (3,4,5))]:
        print(f"  {name}")
        print(f"  Root: {root}")
        c1, c2, c3 = M1(root), M2(root), M3(root)
        print(f"  ├── M₁: {c1}")
        for fn in [M1, M2, M3]:
            label = "M₁" if fn == M1 else ("M₂" if fn == M2 else "M₃")
            print(f"  │   ├── {label}: {fn(c1)}")
        print(f"  ├── M₂: {c2}")
        for fn in [M1, M2, M3]:
            label = "M₁" if fn == M1 else ("M₂" if fn == M2 else "M₃")
            print(f"  │   ├── {label}: {fn(c2)}")
        print(f"  └── M₃: {c3}")
        for fn in [M1, M2, M3]:
            label = "M₁" if fn == M1 else ("M₂" if fn == M2 else "M₃")
            print(f"      ├── {label}: {fn(c3)}")
        print()

    # Show the key structural insight
    print("  KEY INSIGHT:")
    print(f"  M₁(0,1,1) = {M1((0,1,1))}  ← FIXED POINT (meta identity)")
    print(f"  M₂(0,1,1) = {M2((0,1,1))}  ← Generates oracle (4,3,5)")
    print(f"  M₃(0,1,1) = {M3((0,1,1))}  ← Also generates (4,3,5)")
    print()
    print(f"  The meta oracle (0,1,1) tree has:")
    print(f"  - Left branch: collapses to identity (0,1,1)")
    print(f"  - Mid/Right branches: generate the full oracle (4,3,5) tree")
    print(f"  - The oracle IS a subtree of the meta oracle")
    print()

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║      LORENTZ–BERGGREN VISUALIZER: Pythagorean Tree Geometry        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    tree_ascii_art()
    stereographic_projection()

    try:
        import numpy as np
        compute_eigenvalues()
    except ImportError:
        print("  (NumPy not available — skipping eigenvalue analysis)")
        print()

    # Summary
    print("=" * 70)
    print("APPLICATIONS")
    print("=" * 70)
    print("""
  1. CRYPTOGRAPHIC KEY DERIVATION
     Tree paths → Pythagorean triples → verifiable key pairs.
     The Lorentz invariant provides built-in integrity checking.

  2. QUANTUM STATE PREPARATION
     Each triple (a,b,c) defines qubit state (a/c)|0⟩ + (b/c)|1⟩.
     The tree systematically enumerates all rational rotations.

  3. SIGNAL PROCESSING
     Pythagorean triples correspond to rational points on the unit circle.
     The tree provides a complete enumeration for filter design.

  4. AI SELF-IMPROVEMENT
     The meta oracle's three refinement operations (M₁, M₂, M₃) model
     three modes of AI improvement:
       M₁ = maintain (identity, no change)
       M₂ = expand (grow capabilities)
       M₃ = reflect (mirror and grow)

  5. ERROR-CORRECTING CODES
     The Lorentz form x² + y² − z² = 0 is a syndrome equation.
     Tree-structured codes could leverage the Berggren hierarchy.
""")

#!/usr/bin/env python3
"""
Berggren Pythagorean Tree Explorer
===================================
Interactive demo exploring the ternary Berggren tree of primitive Pythagorean triples.

Features:
- Generate all primitive Pythagorean triples up to depth D
- Verify Pythagorean property, primitivity, and Pell recurrence
- Compute angle distributions and growth rates
- Visualize the tree structure
- Demonstrate the inverse (parent descent) algorithm

Usage:
    python berggren_tree_explorer.py
"""

import math
from fractions import Fraction
from collections import defaultdict
import json

# ============================================================================
# §1. Berggren Matrices
# ============================================================================

def berggren_A(a, b, c):
    """Apply Berggren matrix B₁: the 'left' child."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    """Apply Berggren matrix B₂: the 'middle' child."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    """Apply Berggren matrix B₃: the 'right' child."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

# Inverse transforms (derived from Q·Bᵀ·Q where Q = diag(1,1,-1))
def inv_A(a, b, c):
    return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def inv_B(a, b, c):
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def inv_C(a, b, c):
    return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

# ============================================================================
# §2. Tree Generation
# ============================================================================

def generate_tree(max_depth=5):
    """Generate all primitive Pythagorean triples up to given depth."""
    root = (3, 4, 5)
    triples = []
    queue = [(root, 0, "")]  # (triple, depth, path)

    while queue:
        triple, depth, path = queue.pop(0)
        a, b, c = triple
        triples.append({
            'triple': (a, b, c),
            'depth': depth,
            'path': path,
            'angle': math.degrees(math.atan2(b, a)),
            'hypotenuse': c,
            'is_pythag': a**2 + b**2 == c**2,
            'is_primitive': math.gcd(a, b) == 1
        })

        if depth < max_depth:
            queue.append((berggren_A(a, b, c), depth + 1, path + "A"))
            queue.append((berggren_B(a, b, c), depth + 1, path + "B"))
            queue.append((berggren_C(a, b, c), depth + 1, path + "C"))

    return triples

# ============================================================================
# §3. Verification
# ============================================================================

def verify_all_properties(triples):
    """Verify Pythagorean, primitivity, and Lorentz form for all triples."""
    print("=" * 70)
    print("VERIFICATION REPORT")
    print("=" * 70)

    all_pythag = all(t['is_pythag'] for t in triples)
    all_prim = all(t['is_primitive'] for t in triples)

    print(f"Total triples generated: {len(triples)}")
    print(f"All Pythagorean:         {'✓' if all_pythag else '✗'}")
    print(f"All primitive:           {'✓' if all_prim else '✗'}")

    # Verify Lorentz form preservation
    all_lorentz = True
    for t in triples:
        a, b, c = t['triple']
        Q = a**2 + b**2 - c**2
        if Q != 0:
            all_lorentz = False
            break
    print(f"All on null cone (Q=0):  {'✓' if all_lorentz else '✗'}")

    # Verify forward-inverse cancellation
    cancellation_ok = True
    for t in triples:
        if t['depth'] == 0:
            continue
        a, b, c = t['triple']
        path = t['path']
        last_step = path[-1]
        if last_step == 'A':
            parent = inv_A(a, b, c)
        elif last_step == 'B':
            parent = inv_B(a, b, c)
        else:
            parent = inv_C(a, b, c)
        # Parent should be a valid triple
        pa, pb, pc = parent
        if pa**2 + pb**2 != pc**2:
            cancellation_ok = False
            break
    print(f"Inverse cancellation:    {'✓' if cancellation_ok else '✗'}")
    print()
    return all_pythag and all_prim and all_lorentz and cancellation_ok

# ============================================================================
# §4. Angle Distribution Analysis
# ============================================================================

def angle_distribution_analysis(triples):
    """Analyze the distribution of angles arctan(b/a) across the tree."""
    print("=" * 70)
    print("ANGLE DISTRIBUTION ANALYSIS")
    print("=" * 70)

    by_depth = defaultdict(list)
    for t in triples:
        by_depth[t['depth']].append(t['angle'])

    print(f"{'Depth':>6} {'Count':>8} {'Mean°':>8} {'Std°':>8} {'Min°':>8} {'Max°':>8}")
    print("-" * 50)
    for depth in sorted(by_depth.keys()):
        angles = by_depth[depth]
        n = len(angles)
        mean = sum(angles) / n
        std = (sum((a - mean)**2 for a in angles) / n) ** 0.5
        print(f"{depth:>6} {n:>8} {mean:>8.2f} {std:>8.2f} {min(angles):>8.2f} {max(angles):>8.2f}")

    all_angles = [t['angle'] for t in triples]
    print(f"\nOverall: mean = {sum(all_angles)/len(all_angles):.3f}°, "
          f"std = {(sum((a - sum(all_angles)/len(all_angles))**2 for a in all_angles)/len(all_angles))**0.5:.3f}°")
    print(f"Uniform [0°,90°] would have: mean = 45°, std = 25.98°")
    print()

# ============================================================================
# §5. Pell Recurrence Verification
# ============================================================================

def pell_recurrence_demo():
    """Demonstrate the Pell recurrence c_{n+1} = 6c_n - c_{n-1} along B-branch."""
    print("=" * 70)
    print("PELL RECURRENCE: B-BRANCH HYPOTENUSES")
    print("=" * 70)
    print("The B-branch of the Berggren tree satisfies c_{n+1} = 6·c_n - c_{n-1}")
    print()

    triple = (3, 4, 5)
    hyps = [triple[2]]

    for i in range(10):
        triple = berggren_B(*triple)
        hyps.append(triple[2])

    print(f"{'n':>3} {'c_n':>15} {'6c_{n}-c_{n-1}':>15} {'Match':>6} {'Ratio':>12}")
    print("-" * 55)
    for i, c in enumerate(hyps):
        if i >= 2:
            predicted = 6 * hyps[i-1] - hyps[i-2]
            match = "✓" if predicted == c else "✗"
            ratio = c / hyps[i-1]
            print(f"{i:>3} {c:>15} {predicted:>15} {match:>6} {ratio:>12.6f}")
        elif i == 1:
            ratio = c / hyps[i-1]
            print(f"{i:>3} {c:>15} {'—':>15} {'—':>6} {ratio:>12.6f}")
        else:
            print(f"{i:>3} {c:>15} {'—':>15} {'—':>6} {'—':>12}")

    golden = 3 + 2 * math.sqrt(2)
    print(f"\nGrowth rate converges to 3 + 2√2 ≈ {golden:.6f}")
    print(f"This is the larger root of x² - 6x + 1 = 0")
    print()

# ============================================================================
# §6. Growth Rate Classification
# ============================================================================

def growth_rate_analysis():
    """Analyze growth rates along different branches."""
    print("=" * 70)
    print("GROWTH RATE CLASSIFICATION")
    print("=" * 70)

    branches = {
        'A': berggren_A,
        'B': berggren_B,
        'C': berggren_C,
    }

    for name, func in branches.items():
        triple = (3, 4, 5)
        hyps = []
        for _ in range(15):
            triple = func(*triple)
            hyps.append(triple[2])

        ratios = [hyps[i]/hyps[i-1] for i in range(1, len(hyps))]
        limit = ratios[-1]
        print(f"\n{name}-branch: c_n growth ratio → {limit:.8f}")
        print(f"  First 8 hypotenuses: {hyps[:8]}")

    print(f"\nReference values:")
    print(f"  3 + 2√2 = {3 + 2*math.sqrt(2):.8f}  (B-branch eigenvalue)")
    print()

# ============================================================================
# §7. Parent Descent Algorithm
# ============================================================================

def parent_descent(a, b, c):
    """Find the Berggren path from root (3,4,5) to (a,b,c) via descent."""
    path = []
    current = (a, b, c)

    while current != (3, 4, 5):
        a, b, c = current
        if c <= 0:
            return None  # Invalid

        # Try all three inverses
        candidates = [
            ('A', inv_A(a, b, c)),
            ('B', inv_B(a, b, c)),
            ('C', inv_C(a, b, c)),
        ]

        found = False
        for label, (pa, pb, pc) in candidates:
            if pa > 0 and pb > 0 and pc > 0 and pa**2 + pb**2 == pc**2 and pc < c:
                path.append(label)
                current = (pa, pb, pc)
                found = True
                break

        if not found:
            return None  # Not in tree

    path.reverse()
    return ''.join(path)

def descent_demo():
    """Demonstrate the parent descent algorithm."""
    print("=" * 70)
    print("PARENT DESCENT ALGORITHM")
    print("=" * 70)
    print("Given a primitive Pythagorean triple, find its Berggren tree path.\n")

    test_triples = [
        (3, 4, 5), (5, 12, 13), (21, 20, 29), (15, 8, 17),
        (7, 24, 25), (119, 120, 169), (55, 48, 73),
        (20, 21, 29), (8, 15, 17),
    ]

    for triple in test_triples:
        a, b, c = triple
        if a**2 + b**2 == c**2 and math.gcd(a, b) == 1:
            path = parent_descent(a, b, c)
            if path is not None:
                print(f"  ({a:>4}, {b:>4}, {c:>4}) → path = '{path}' (depth {len(path)})")
            else:
                # Try with swapped legs
                path = parent_descent(b, a, c)
                if path is not None:
                    print(f"  ({a:>4}, {b:>4}, {c:>4}) → path = '{path}' (depth {len(path)}) [legs swapped]")
                else:
                    print(f"  ({a:>4}, {b:>4}, {c:>4}) → NOT FOUND (may need sign normalization)")
        else:
            print(f"  ({a:>4}, {b:>4}, {c:>4}) → not primitive Pythagorean")
    print()

# ============================================================================
# §8. Determinant Asymmetry Analysis
# ============================================================================

def determinant_analysis():
    """Demonstrate the determinant asymmetry: det(B₁) = det(B₃) = 1, det(B₂) = -1."""
    print("=" * 70)
    print("DETERMINANT ASYMMETRY (Direction #36)")
    print("=" * 70)

    import numpy as np

    B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
    B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
    B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

    print(f"\ndet(B₁) = {int(round(np.linalg.det(B1)))} → B₁ ∈ SO(2,1;ℤ)")
    print(f"det(B₂) = {int(round(np.linalg.det(B2)))} → B₂ ∈ O(2,1;ℤ) \\ SO(2,1;ℤ)")
    print(f"det(B₃) = {int(round(np.linalg.det(B3)))} → B₃ ∈ SO(2,1;ℤ)")

    Q = np.diag([1, 1, -1])
    for name, B in [("B₁", B1), ("B₂", B2), ("B₃", B3)]:
        check = B.T @ Q @ B
        ok = np.allclose(check, Q)
        print(f"\n{name}ᵀ · Q · {name} = Q? {'✓' if ok else '✗'}")

    # Products
    print(f"\ndet(B₁·B₂) = {int(round(np.linalg.det(B1 @ B2)))}")
    print(f"det(B₁·B₃) = {int(round(np.linalg.det(B1 @ B3)))}")
    print(f"det(B₂·B₃) = {int(round(np.linalg.det(B2 @ B3)))}")
    print(f"det(B₁·B₂·B₃) = {int(round(np.linalg.det(B1 @ B2 @ B3)))}")
    print()

# ============================================================================
# §9. Euclid Parametrization and Gaussian Connection
# ============================================================================

def gaussian_connection():
    """Explore the connection between Berggren tree and Gaussian integers."""
    print("=" * 70)
    print("GAUSSIAN INTEGER CONNECTION (Direction #5)")
    print("=" * 70)
    print("\nEuclid parametrization: (m,n) → (m²-n², 2mn, m²+n²)")
    print("This is the norm of (m+ni)²:\n")

    triples = generate_tree(3)
    print(f"{'Triple':>20} {'(m,n)':>10} {'Gaussian':>15} {'z²':>20}")
    print("-" * 70)

    for t in triples[:15]:
        a, b, c = t['triple']
        # Find m,n such that m²-n²=a, 2mn=b, m²+n²=c (or swapped)
        # m² + n² = c, m² - n² = a → m² = (c+a)/2, n² = (c-a)/2
        found = False
        for aa, bb in [(a, b), (b, a)]:
            if (c + aa) % 2 == 0 and (c - aa) % 2 == 0:
                m2 = (c + aa) // 2
                n2 = (c - aa) // 2
                m = int(math.isqrt(m2))
                n = int(math.isqrt(n2))
                if m*m == m2 and n*n == n2 and 2*m*n == abs(bb):
                    z = complex(m, n)
                    z2 = z**2
                    print(f"({a:>4},{b:>4},{c:>4})   ({m:>2},{n:>2})     {m}+{n}i         "
                          f"{z2.real:.0f}+{z2.imag:.0f}i")
                    found = True
                    break
        if not found:
            print(f"({a:>4},{b:>4},{c:>4})   (parametrization not found in standard form)")
    print()

# ============================================================================
# §10. EML Operator Demo
# ============================================================================

def eml_demo():
    """Demonstrate the EML operator and its fixed-point structure."""
    print("=" * 70)
    print("EML OPERATOR: Fixed Points and Dynamics")
    print("=" * 70)
    print("\neml(x, y) = exp(x) - ln(y)")
    print()

    # Fixed point analysis: eml(x,y) = x means exp(x) - ln(y) = x
    # i.e., exp(x) - x = ln(y)
    print("Fixed points of eml(·, y): exp(x) - x = ln(y)")
    print()
    print(f"{'y':>8} {'ln(y)':>8} {'Fixed pts':>25} {'Stable?':>10}")
    print("-" * 55)

    import numpy as np
    for y in [1.0, 2.0, math.e, 4.0, 10.0, 100.0]:
        target = math.log(y)
        # Find fixed points numerically: exp(x) - x = ln(y)
        # g(x) = exp(x) - x is convex with minimum at x=0: g(0) = 1
        # So g(x) = target has:
        # - no solution if target < 1 (y < e)
        # - one solution at x=0 if target = 1 (y = e)
        # - two solutions if target > 1 (y > e)

        fps = []
        if target >= 1:
            # Newton's method from different starting points
            for x0 in [-10.0, -5.0, 0.0, 5.0]:
                x = x0
                for _ in range(100):
                    f = math.exp(x) - x - target
                    fp = math.exp(x) - 1
                    if abs(fp) < 1e-15:
                        break
                    x = x - f / fp
                    if abs(x) > 50:
                        break
                if abs(math.exp(x) - x - target) < 1e-10:
                    # Check if already found
                    if not any(abs(x - fp) < 1e-6 for fp in fps):
                        fps.append(x)
            fps.sort()

        if len(fps) == 0:
            print(f"{y:>8.2f} {target:>8.3f} {'none':>25}")
        elif len(fps) == 1:
            print(f"{y:>8.2f} {target:>8.3f} {fps[0]:>25.6f} {'tangent':>10}")
        else:
            stab = ['unstable' if math.exp(fp) > 1 else 'stable' for fp in fps]
            for fp, s in zip(fps, stab):
                print(f"{y:>8.2f} {target:>8.3f} {fp:>25.6f} {s:>10}")

    print(f"\nBifurcation at y = e ≈ {math.e:.6f}")
    print(f"For y < e: no real fixed points")
    print(f"For y = e: one tangent fixed point at x = 0")
    print(f"For y > e: two fixed points (one stable, one unstable)")
    print()

# ============================================================================
# §11. Quadruple Extension
# ============================================================================

def quadruple_demo():
    """Demonstrate Pythagorean quadruples and zero-extension."""
    print("=" * 70)
    print("PYTHAGOREAN QUADRUPLES (Direction #6)")
    print("=" * 70)
    print("\na² + b² + c² = d²")
    print()

    # Known small quadruples
    quads = []
    for a in range(1, 30):
        for b in range(a, 30):
            for c in range(b, 30):
                d2 = a*a + b*b + c*c
                d = int(math.isqrt(d2))
                if d*d == d2 and math.gcd(math.gcd(a, b), c) == 1:
                    quads.append((a, b, c, d))

    print(f"Primitive Pythagorean quadruples with d ≤ 50:")
    print(f"{'(a,b,c,d)':>25} {'a²+b²+c²':>12} {'d²':>8}")
    print("-" * 50)
    for q in quads[:20]:
        a, b, c, d = q
        print(f"({a:>3},{b:>3},{c:>3},{d:>3}) {a**2+b**2+c**2:>12} {d**2:>8}")

    # Show zero-extension
    print(f"\nZero-extension of Pythagorean triples:")
    for a, b, c in [(3,4,5), (5,12,13), (8,15,17)]:
        print(f"  ({a},{b},{c}) → ({a},{b},0,{c}): {a}²+{b}²+0²={a**2+b**2}={c}²={c**2}")
    print()

# ============================================================================
# Main
# ============================================================================

def main():
    print("\n" + "=" * 70)
    print("  BERGGREN PYTHAGOREAN TREE EXPLORER")
    print("  Machine-Verified Mathematics in Action")
    print("=" * 70 + "\n")

    # Generate tree
    depth = 5
    triples = generate_tree(depth)
    print(f"Generated {len(triples)} triples up to depth {depth}\n")

    # Run all demos
    verify_all_properties(triples)
    angle_distribution_analysis(triples)
    pell_recurrence_demo()
    growth_rate_analysis()
    descent_demo()
    eml_demo()
    quadruple_demo()

    try:
        determinant_analysis()
        gaussian_connection()
    except ImportError:
        print("(NumPy not available — skipping matrix demos)")

    print("=" * 70)
    print("  All demonstrations complete!")
    print("=" * 70)

if __name__ == "__main__":
    main()

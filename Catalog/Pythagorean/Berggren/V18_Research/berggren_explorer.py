#!/usr/bin/env python3
"""
Berggren Tree Explorer — Interactive Visualization & Computation Suite
======================================================================
Part of EML–Pythagorean Bridge V18 Research

Features:
1. Berggren tree generation and traversal
2. Pell sequence computation with O(log n) doubling
3. Markoff tree generation
4. Deficit classification analysis
5. Spectral analysis of Berggren matrices
6. ASCII tree visualization
7. Statistical analysis of PPT distributions

Usage:
    python berggren_explorer.py
"""

import numpy as np
from collections import defaultdict
from itertools import product as iterproduct

# =============================================================================
# Part 1: Berggren Matrices & Tree Generation
# =============================================================================

# The three Berggren matrices
B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)

ROOT = np.array([3, 4, 5], dtype=np.int64)

MATRICES = [B1, B2, B3]
LABELS = ['A', 'B', 'C']

def berggren_tree(depth):
    """Generate all PPTs up to given depth, with path labels."""
    results = [(ROOT.tolist(), "")]
    queue = [(ROOT, "")]
    for d in range(depth):
        next_queue = []
        for triple, path in queue:
            for i, M in enumerate(MATRICES):
                child = M @ triple
                child_path = path + LABELS[i]
                results.append((child.tolist(), child_path))
                next_queue.append((child, child_path))
        queue = next_queue
    return results

def print_berggren_tree(depth=3):
    """Print the Berggren tree in a readable format."""
    print("=" * 70)
    print("BERGGREN TREE OF PRIMITIVE PYTHAGOREAN TRIPLES")
    print("=" * 70)
    tree = berggren_tree(depth)
    by_depth = defaultdict(list)
    for triple, path in tree:
        by_depth[len(path)].append((triple, path))
    
    for d in sorted(by_depth.keys()):
        print(f"\nDepth {d}: ({len(by_depth[d])} triples)")
        print("-" * 50)
        for triple, path in sorted(by_depth[d], key=lambda x: x[0][2]):
            a, b, c = triple
            deficit = c - b
            label = path if path else "ROOT"
            print(f"  {label:>6s}: ({a:>5d}, {b:>5d}, {c:>5d})  "
                  f"deficit={deficit:>3d}  area={a*b//2:>6d}")

# =============================================================================
# Part 2: Pell Sequences & Fast Computation
# =============================================================================

def pell_slow(n):
    """Compute (pellX(n), pellY(n)) via recurrence."""
    if n == 0:
        return (1, 0)
    if n == 1:
        return (3, 1)
    x_prev, y_prev = 1, 0
    x_curr, y_curr = 3, 1
    for _ in range(n - 1):
        x_prev, x_curr = x_curr, 6 * x_curr - x_prev
        y_prev, y_curr = y_curr, 6 * y_curr - y_prev
    return (x_curr, y_curr)

def pell_prod(p, q):
    """Multiply in Z[sqrt(8)]: (x1+y1*sqrt8)(x2+y2*sqrt8)."""
    return (p[0]*q[0] + 8*p[1]*q[1], p[0]*q[1] + p[1]*q[0])

def pell_fast(n):
    """Compute (pellX(n), pellY(n)) via O(log n) repeated squaring."""
    if n == 0:
        return (1, 0)
    result = (1, 0)  # identity
    base = (3, 1)    # fundamental solution
    while n > 0:
        if n % 2 == 1:
            result = pell_prod(result, base)
        base = pell_prod(base, base)
        n //= 2
    return result

def print_pell_analysis():
    """Print Pell sequence analysis."""
    print("\n" + "=" * 70)
    print("PELL SEQUENCES: x² - 8y² = 1")
    print("=" * 70)
    print(f"\n{'n':>3s} {'pellX(n)':>15s} {'pellY(n)':>15s} {'x²-8y²':>10s} {'tr(B₂ⁿ)':>15s}")
    print("-" * 65)
    for n in range(12):
        x, y = pell_fast(n)
        pell_check = x*x - 8*y*y
        trace = 2*x + (-1)**n
        print(f"{n:>3d} {x:>15d} {y:>15d} {pell_check:>10d} {trace:>15d}")
    
    # Verify addition formulas
    print("\n--- Addition Formula Verification ---")
    for m in range(5):
        for n in range(5):
            xm, ym = pell_fast(m)
            xn, yn = pell_fast(n)
            prod = pell_prod((xm, ym), (xn, yn))
            direct = pell_fast(m + n)
            assert prod == direct, f"Failed at m={m}, n={n}"
    print("✓ pellProd((pellX(m),pellY(m)), (pellX(n),pellY(n))) = (pellX(m+n),pellY(m+n))")
    print("  Verified for all 0 ≤ m, n ≤ 4")
    
    # Doubling formulas
    print("\n--- Doubling Formula Verification ---")
    for n in range(10):
        x, y = pell_fast(n)
        x2n, y2n = pell_fast(2*n)
        assert x2n == 2*x*x - 1, f"pellX doubling failed at n={n}"
        assert y2n == 2*x*y, f"pellY doubling failed at n={n}"
    print("✓ pellX(2n) = 2·pellX(n)² - 1  (verified for n=0..9)")
    print("✓ pellY(2n) = 2·pellX(n)·pellY(n)  (verified for n=0..9)")

# =============================================================================
# Part 3: Spectral Analysis
# =============================================================================

def print_spectral_analysis():
    """Analyze the spectral properties of Berggren matrices."""
    print("\n" + "=" * 70)
    print("SPECTRAL ANALYSIS OF BERGGREN MATRICES")
    print("=" * 70)
    
    for name, M in [("B₁", B1), ("B₂", B2), ("B₃", B3)]:
        det_val = int(round(np.linalg.det(M)))
        trace_val = int(np.trace(M))
        eigenvalues = np.linalg.eigvals(M)
        N = M - np.eye(3, dtype=np.int64)
        N2 = N @ N
        N3 = N2 @ N
        is_unipotent = np.allclose(N3, 0)
        
        print(f"\n{name}:")
        print(f"  det = {det_val}")
        print(f"  trace = {trace_val}")
        print(f"  eigenvalues ≈ {', '.join(f'{e.real:.6f}' for e in eigenvalues)}")
        print(f"  (M-I)³ = 0? {is_unipotent} {'(UNIPOTENT!)' if is_unipotent else ''}")
        
        # Trace powers
        traces = []
        Mn = np.eye(3, dtype=np.int64)
        for k in range(8):
            traces.append(int(np.trace(Mn)))
            Mn = Mn @ M
        print(f"  tr(M^k) for k=0..7: {traces}")
    
    # Commutator analysis
    print("\n--- Commutator Analysis ---")
    for i, (n1, M1) in enumerate([("B₁", B1), ("B₂", B2), ("B₃", B3)]):
        for j, (n2, M2) in enumerate([("B₁", B1), ("B₂", B2), ("B₃", B3)]):
            if i < j:
                comm = M1 @ M2 - M2 @ M1
                print(f"  [{n1},{n2}]: trace = {int(np.trace(comm))}, "
                      f"nonzero = {not np.allclose(comm, 0)}")

# =============================================================================
# Part 4: Deficit Classification
# =============================================================================

def print_deficit_analysis(depth=4):
    """Analyze deficit patterns in the Berggren tree."""
    print("\n" + "=" * 70)
    print("DEFICIT CLASSIFICATION: d = c - b")
    print("=" * 70)
    
    tree = berggren_tree(depth)
    deficit_families = defaultdict(list)
    
    for triple, path in tree:
        a, b, c = triple
        d = c - b
        deficit_families[d].append((a, b, c, path))
    
    for deficit in sorted(deficit_families.keys()):
        members = deficit_families[deficit]
        print(f"\nDeficit d = {deficit}:")
        for a, b, c, path in sorted(members, key=lambda x: x[2]):
            label = path if path else "ROOT"
            print(f"  {label:>8s}: ({a:>5d}, {b:>5d}, {c:>5d})")
    
    # Verify deficit-1 family = near-isosceles
    print("\n--- Near-Isosceles Family (d=1) ---")
    print("  These satisfy a = 2n+1, b = 2n²+2n, c = 2n²+2n+1")
    for n in range(1, 8):
        a = 2*n + 1
        b = 2*n*n + 2*n
        c = 2*n*n + 2*n + 1
        check = a*a + b*b == c*c
        print(f"  n={n}: ({a}, {b}, {c})  check: {check}  "
              f"inradius={n}  area={a*b//2}")
    
    # Deficit under Euclid parametrization
    print("\n--- Euclid Deficit = (m-n)² ---")
    print(f"  {'(m,n)':>8s} {'(a,b,c)':>20s} {'m-n':>5s} {'(m-n)²':>7s} {'c-b':>5s}")
    for m in range(2, 7):
        for n in range(1, m):
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            deficit = c - b
            print(f"  ({m},{n}): ({a:>5d},{b:>5d},{c:>5d}) "
                  f"{m-n:>5d} {(m-n)**2:>7d} {deficit:>5d}")

# =============================================================================
# Part 5: Markoff Tree
# =============================================================================

def markoff_vieta(x, y, z, coord):
    """Apply Vieta involution on the given coordinate."""
    if coord == 0:
        return (3*y*z - x, y, z)
    elif coord == 1:
        return (x, 3*x*z - y, z)
    else:
        return (x, y, 3*x*y - z)

def markoff_tree(depth):
    """Generate Markoff triples up to given depth."""
    results = [(1, 1, 1, "")]
    queue = [(1, 1, 1, "")]
    seen = {(1, 1, 1)}
    
    for d in range(depth):
        next_queue = []
        for x, y, z, path in queue:
            for coord in range(3):
                child = markoff_vieta(x, y, z, coord)
                key = tuple(sorted(child))
                if key not in seen and all(c > 0 for c in child):
                    seen.add(key)
                    child_path = path + str(coord + 1)
                    results.append((*child, child_path))
                    next_queue.append((*child, child_path))
        queue = next_queue
    return results

def print_markoff_analysis(depth=4):
    """Analyze Markoff tree."""
    print("\n" + "=" * 70)
    print("MARKOFF TREE: x² + y² + z² = 3xyz")
    print("=" * 70)
    
    tree = markoff_tree(depth)
    markoff_numbers = set()
    
    for entry in tree:
        x, y, z = entry[0], entry[1], entry[2]
        markoff_numbers.update([x, y, z])
        check = x*x + y*y + z*z == 3*x*y*z
        path = entry[3] if len(entry) > 3 else ""
        label = path if path else "ROOT"
        if len(path) <= 2:
            print(f"  {label:>6s}: ({x:>5d}, {y:>5d}, {z:>5d})  check={check}")
    
    mlist = sorted(markoff_numbers)
    print(f"\nMarkoff numbers up to depth {depth}: {mlist[:20]}")
    print(f"Count: {len(mlist)}")
    
    # Comparison table
    print("\n--- Berggren vs Markoff Comparison ---")
    print(f"  {'Feature':<25s} {'Berggren':>15s} {'Markoff':>15s}")
    print(f"  {'-'*25} {'-'*15} {'-'*15}")
    print(f"  {'Equation':<25s} {'a²+b²=c²':>15s} {'x²+y²+z²=3xyz':>15s}")
    print(f"  {'Root':<25s} {'(3,4,5)':>15s} {'(1,1,1)':>15s}")
    print(f"  {'Branching':<25s} {'3 matrices':>15s} {'3 involutions':>15s}")
    print(f"  {'det(generators)':<25s} {'1,-1,1':>15s} {'—':>15s}")
    print(f"  {'Involutive?':<25s} {'No':>15s} {'Yes':>15s}")
    print(f"  {'Free semigroup?':<25s} {'Proved':>15s} {'Conjectured':>15s}")
    print(f"  {'Unipotent branches':<25s} {'2 of 3':>15s} {'N/A':>15s}")

# =============================================================================
# Part 6: ASCII Tree Visualization
# =============================================================================

def print_tree_visual():
    """ASCII art tree visualization."""
    print("\n" + "=" * 70)
    print("BERGGREN TREE (First 3 Levels)")
    print("=" * 70)
    print("""
                            (3, 4, 5)
                          /     |     \\
                    A    /      B|      \\  C
                   /             |        \\
         (5,12,13)        (21,20,29)      (15,8,17)
         /  |  \\          /    |   \\       /  |  \\
       A   B    C       A    B    C     A   B    C
      /    |     \\     /     |    \\   /    |     \\
(7,   (55, (45, (39, (77, (119,(35, (65, (33,
 24,  48,  28,  80,  36,  120,  12,  72,  56,
 25)  73)  53)  89)  85)  169) 37)  97)  65)
    """)

# =============================================================================
# Part 7: Trace Analysis & Growth
# =============================================================================

def print_trace_growth():
    """Analyze trace growth for all three matrices."""
    print("\n" + "=" * 70)
    print("TRACE SEQUENCES AND GROWTH ANALYSIS")
    print("=" * 70)
    
    print(f"\n{'n':>3s} {'tr(B₁ⁿ)':>12s} {'tr(B₂ⁿ)':>12s} {'tr(B₃ⁿ)':>12s} "
          f"{'2·pX(n)+(-1)ⁿ':>15s} {'ratio B₂':>10s}")
    print("-" * 70)
    
    M1n = np.eye(3, dtype=np.int64)
    M2n = np.eye(3, dtype=np.int64)
    M3n = np.eye(3, dtype=np.int64)
    prev_t2 = None
    
    for n in range(12):
        t1 = int(np.trace(M1n))
        t2 = int(np.trace(M2n))
        t3 = int(np.trace(M3n))
        px, _ = pell_fast(n)
        formula = 2*px + (-1)**n
        ratio = f"{t2/prev_t2:.4f}" if prev_t2 and prev_t2 > 0 else "—"
        
        print(f"{n:>3d} {t1:>12d} {t2:>12d} {t3:>12d} {formula:>15d} {ratio:>10s}")
        
        prev_t2 = t2
        M1n = M1n @ B1
        M2n = M2n @ B2
        M3n = M3n @ B3
    
    print("\nKey observations:")
    print("  • tr(B₁ⁿ) = 3 for ALL n  (B₁ is unipotent, eigenvalue 1 only)")
    print("  • tr(B₃ⁿ) = 3 for ALL n  (B₃ is unipotent, eigenvalue 1 only)")
    print("  • tr(B₂ⁿ) = 2·pellX(n) + (-1)ⁿ  (PROVED FOR ALL n)")
    print("  • tr(B₂ⁿ)/tr(B₂ⁿ⁻¹) → 3 + 2√2 ≈ 5.8284  (spectral radius)")

# =============================================================================
# Part 8: New Discovery — Hypotenuse Growth Classification
# =============================================================================

def print_hypotenuse_growth():
    """Classify hypotenuse growth along different branches."""
    print("\n" + "=" * 70)
    print("HYPOTENUSE GROWTH ALONG PURE BRANCHES")
    print("=" * 70)
    
    branches = {
        'A-only': [B1],
        'B-only': [B2],
        'C-only': [B3],
    }
    
    for branch_name, matrices in branches.items():
        print(f"\n{branch_name} branch:")
        triple = ROOT.copy()
        for depth in range(8):
            a, b, c = triple
            d = c - b
            print(f"  depth {depth}: ({a:>8d}, {b:>8d}, {c:>8d})  "
                  f"deficit={d:>8d}  c/prev={'—':>8s}" if depth == 0 else
                  f"  depth {depth}: ({a:>8d}, {b:>8d}, {c:>8d})  "
                  f"deficit={d:>8d}  c/prev={c/prev_c:>8.4f}")
            prev_c = c
            triple = matrices[0] @ triple

# =============================================================================
# Part 9: New Discovery — Sum-of-Digits Patterns
# =============================================================================

def digital_root(n):
    """Compute digital root (iterated digit sum)."""
    while n >= 10:
        n = sum(int(d) for d in str(abs(n)))
    return n

def print_digital_patterns():
    """Analyze digital root patterns in PPTs."""
    print("\n" + "=" * 70)
    print("DIGITAL ROOT PATTERNS IN PYTHAGOREAN TRIPLES")
    print("=" * 70)
    
    tree = berggren_tree(4)
    print(f"\n{'Path':>8s} {'(a,b,c)':>20s} {'dr(a)':>6s} {'dr(b)':>6s} {'dr(c)':>6s} {'dr(c²)':>7s}")
    print("-" * 60)
    
    dr_patterns = defaultdict(int)
    for triple, path in tree[:30]:
        a, b, c = triple
        dra, drb, drc = digital_root(a), digital_root(b), digital_root(c)
        dr_patterns[(dra, drb, drc)] += 1
        label = path if path else "ROOT"
        print(f"{label:>8s} ({a:>5d},{b:>5d},{c:>5d}) {dra:>6d} {drb:>6d} {drc:>6d} {digital_root(c*c):>7d}")
    
    print("\nDigital root pattern frequencies:")
    for pattern, count in sorted(dr_patterns.items(), key=lambda x: -x[1]):
        print(f"  (dr(a),dr(b),dr(c)) = {pattern}: {count} occurrences")

# =============================================================================
# Main
# =============================================================================

def main():
    print("╔" + "═" * 68 + "╗")
    print("║" + " EML–PYTHAGOREAN BRIDGE V18 EXPLORER ".center(68) + "║")
    print("║" + " Machine-Verified Mathematics with Interactive Computation ".center(68) + "║")
    print("╚" + "═" * 68 + "╝")
    
    print_tree_visual()
    print_berggren_tree(depth=2)
    print_pell_analysis()
    print_spectral_analysis()
    print_deficit_analysis(depth=3)
    print_markoff_analysis(depth=3)
    print_trace_growth()
    print_hypotenuse_growth()
    print_digital_patterns()
    
    print("\n" + "=" * 70)
    print("SUMMARY OF V18 MACHINE-VERIFIED RESULTS")
    print("=" * 70)
    print("""
    New files (all 0 sorries):
    
    1. BerggrenTraceFormula.lean
       ★ tr(B₂ⁿ) = 2·pellX(n) + (-1)ⁿ  for ALL n  (PROVED)
       ★ Trace is always positive and always odd
    
    2. BerggrenSpectralGeometry.lean
       ★ B₁, B₃ are unipotent: (B-I)³ = 0
       ★ tr(B₁ⁿ) = tr(B₃ⁿ) = 3 for ALL n  (PROVED)
       ★ All commutators have trace 0
       ★ B₂ is the only non-unipotent matrix
    
    3. BerggrenPellSemigroup.lean
       ★ ℤ[√8] semigroup structure formalized
       ★ pellProd is associative, commutative, has identity
       ★ Norm is multiplicative: N(p·q) = N(p)·N(q)
       ★ pellPow(fund, n) = (pellX(n), pellY(n))  (PROVED)
       ★ Doubling formulas for O(log n) computation
    
    4. BerggrenDeficitClassification.lean
       ★ Deficit c-b classifies PPTs into shape families
       ★ A-branch preserves deficit (ring identity)
       ★ Euclid deficit = (m-n)² (always a perfect square)
       ★ Near-isosceles family fully characterized
       ★ Deficit divides a² for any PPT
    """)

if __name__ == "__main__":
    main()

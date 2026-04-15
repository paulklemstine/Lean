#!/usr/bin/env python3
"""
Berggren Tree Explorer — Interactive Demo

Generates and visualizes the Berggren tree of primitive Pythagorean triples.
Demonstrates key properties: tree structure, descent algorithm, angle
distribution, Pell recurrence, and growth rates.

Usage:
    python berggren_tree_explorer.py [--depth N] [--mode MODE]

Modes:
    tree     - Print the Berggren tree to given depth
    descent  - Interactive descent: enter a PPT, get its tree path
    angles   - Angle distribution analysis
    pell     - B₂-branch Pell sequence
    growth   - Growth rate comparison between branches
    all      - Run all demos
"""

from math import gcd, atan2, degrees, sqrt
import sys

# ═══════════════════════════════════════════════════════════════════════
# §1. BERGGREN MATRICES
# ═══════════════════════════════════════════════════════════════════════

# The Berggren matrices (as nested lists, no numpy needed)

def parent_A(triple):
    a, b, c = triple
    return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def parent_B(triple):
    a, b, c = triple
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def parent_C(triple):
    a, b, c = triple
    return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def child_A(triple):
    a, b, c = triple
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def child_B(triple):
    a, b, c = triple
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def child_C(triple):
    a, b, c = triple
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


# ═══════════════════════════════════════════════════════════════════════
# §2. TREE GENERATION
# ═══════════════════════════════════════════════════════════════════════

def generate_tree(depth):
    """Generate the Berggren tree to given depth. Returns list of (triple, path, depth)."""
    root = (3, 4, 5)
    nodes = [(root, "", 0)]
    result = [(root, "", 0)]

    for d in range(depth):
        new_nodes = []
        for triple, path, _ in nodes:
            for branch, child_fn, label in [(child_A, child_A, "A"),
                                             (child_B, child_B, "B"),
                                             (child_C, child_C, "C")]:
                child = child_fn(triple)
                new_path = path + label
                new_nodes.append((child, new_path, d + 1))
                result.append((child, new_path, d + 1))
        nodes = new_nodes

    return result


def print_tree(depth=4):
    """Print the Berggren tree."""
    print("=" * 70)
    print("  BERGGREN TREE OF PRIMITIVE PYTHAGOREAN TRIPLES")
    print("=" * 70)
    print(f"\n  Root: (3, 4, 5)  —  the fundamental triple")
    print(f"  Depth: {depth}")
    print()

    tree = generate_tree(depth)
    for d in range(depth + 1):
        nodes_at_d = [(t, p) for t, p, dd in tree if dd == d]
        print(f"  Depth {d}: ({len(nodes_at_d)} triples)")
        for triple, path in nodes_at_d[:12]:  # limit display
            a, b, c = triple
            angle = degrees(atan2(b, a))
            print(f"    ({a:>5}, {b:>5}, {c:>5})  path={path or 'root':>6}  "
                  f"θ={angle:5.1f}°  gcd(a,b)={gcd(a,b)}")
        if len(nodes_at_d) > 12:
            print(f"    ... and {len(nodes_at_d) - 12} more")
        print()


# ═══════════════════════════════════════════════════════════════════════
# §3. DESCENT ALGORITHM
# ═══════════════════════════════════════════════════════════════════════

def descent(triple):
    """
    Compute the Berggren tree path for a given PPT.
    Returns the path as a string of 'A', 'B', 'C' characters (reversed).
    """
    a, b, c = triple
    path = []

    while (a, b, c) != (3, 4, 5):
        # Try each parent
        pa = parent_A((a, b, c))
        pb = parent_B((a, b, c))
        pc = parent_C((a, b, c))

        if all(x > 0 for x in pa):
            path.append('A')
            a, b, c = pa
        elif all(x > 0 for x in pb):
            path.append('B')
            a, b, c = pb
        elif all(x > 0 for x in pc):
            path.append('C')
            a, b, c = pc
        else:
            print(f"  ERROR: No valid parent for ({a}, {b}, {c})")
            print(f"    parentA = {pa}")
            print(f"    parentB = {pb}")
            print(f"    parentC = {pc}")
            return None

    path.reverse()
    return ''.join(path)


def demo_descent():
    """Demonstrate the descent algorithm on several triples."""
    print("=" * 70)
    print("  BERGGREN DESCENT ALGORITHM")
    print("=" * 70)
    print()
    print("  Given a PPT (a,b,c), find its unique path in the Berggren tree.")
    print()

    test_triples = [
        (5, 12, 13),
        (21, 20, 29),
        (15, 8, 17),
        (7, 24, 25),
        (119, 120, 169),
        (20, 21, 29),
        (9, 40, 41),
        (11, 60, 61),
        (35, 12, 37),
        (45, 28, 53),
        (697, 696, 985),
    ]

    for triple in test_triples:
        path = descent(triple)
        a, b, c = triple
        angle = degrees(atan2(b, a))
        depth = len(path) if path else "?"
        print(f"  ({a:>5}, {b:>5}, {c:>5})  →  path = {path or 'ERROR':>10}  "
              f"depth = {depth}  θ = {angle:.1f}°")

    print()


# ═══════════════════════════════════════════════════════════════════════
# §4. ANGLE DISTRIBUTION
# ═══════════════════════════════════════════════════════════════════════

def angle_distribution(depth=10):
    """Analyze the distribution of angles in the Berggren tree."""
    print("=" * 70)
    print("  ANGLE DISTRIBUTION ON THE BERGGREN TREE")
    print("=" * 70)
    print()

    tree = generate_tree(depth)
    angles = [degrees(atan2(b, a)) for (a, b, c), _, _ in tree]

    mean_a = sum(angles) / len(angles)
    std_a = sqrt(sum((a - mean_a)**2 for a in angles) / len(angles))
    print(f"  Total triples at depth ≤ {depth}: {len(angles)}")
    print(f"  Mean angle: {mean_a:.4f}°  (theoretical: 45°)")
    print(f"  Std deviation: {std_a:.4f}°")
    print(f"  Min angle: {min(angles):.4f}°")
    print(f"  Max angle: {max(angles):.4f}°")
    print()

    # Histogram
    bins = [0, 10, 20, 30, 40, 45, 50, 60, 70, 80, 90]
    print("  Angle distribution:")
    hist = [0] * (len(bins) - 1)
    for a in angles:
        for i in range(len(bins) - 1):
            if bins[i] <= a < bins[i+1]:
                hist[i] += 1
                break
    max_h = max(hist) if max(hist) > 0 else 1
    for i in range(len(bins) - 1):
        bar = "█" * (hist[i] * 40 // max_h)
        print(f"    [{bins[i]:>2}°–{bins[i+1]:>2}°] {hist[i]:>5}  {bar}")

    print()

    # Per-depth statistics
    print("  Per-depth statistics:")
    print(f"  {'Depth':>5}  {'Count':>6}  {'Mean θ':>8}  {'Std θ':>8}")
    for d in range(depth + 1):
        d_angles = [degrees(atan2(b, a)) for (a, b, c), _, dd in tree if dd == d]
        if d_angles:
            dm = sum(d_angles) / len(d_angles)
            ds = sqrt(sum((a - dm)**2 for a in d_angles) / len(d_angles))
            print(f"  {d:>5}  {len(d_angles):>6}  {dm:>7.2f}°  {ds:>7.2f}°")
    print()


# ═══════════════════════════════════════════════════════════════════════
# §5. PELL RECURRENCE (B₂ BRANCH)
# ═══════════════════════════════════════════════════════════════════════

def pell_sequence(n_terms=15):
    """Compute and display the B₂-branch Pell sequence."""
    print("=" * 70)
    print("  B₂-BRANCH PELL RECURRENCE")
    print("=" * 70)
    print()
    print("  The B₂ branch produces triples with hypotenuses satisfying")
    print("  the Pell recurrence: c_{n+1} = 6·c_n - c_{n-1}")
    print()
    print("  The eigenvalues of B₂ are: -1, 3+2√2 ≈ 5.828, 3-2√2 ≈ 0.172")
    print("  Growth rate: (3+2√2)ⁿ ≈ 5.828ⁿ")
    print()

    triple = (3, 4, 5)
    print(f"  {'n':>3}  {'a':>12}  {'b':>12}  {'c':>12}  {'|a-b|':>6}  {'c/c_prev':>10}")
    c_prev = None
    for i in range(n_terms):
        a, b, c = triple
        ratio = f"{c / c_prev:.6f}" if c_prev else "—"
        print(f"  {i:>3}  {a:>12}  {b:>12}  {c:>12}  {abs(a-b):>6}  {ratio:>10}")
        c_prev = c
        triple = child_B(triple)

    print()
    print(f"  Limiting ratio c_{{n+1}}/c_n → 3+2√2 = {3 + 2*sqrt(2):.6f}")
    print(f"  Note: |a-b| = 1 always (alternating which is larger)")
    print()

    # Verify Pell recurrence
    print("  Pell recurrence verification:")
    triple = (3, 4, 5)
    hyps = []
    for i in range(n_terms):
        hyps.append(triple[2])
        triple = child_B(triple)
    for i in range(2, len(hyps)):
        expected = 6 * hyps[i-1] - hyps[i-2]
        match = "✓" if expected == hyps[i] else "✗"
        print(f"    c_{i} = 6·c_{i-1} - c_{i-2} = 6·{hyps[i-1]} - {hyps[i-2]} = {expected} {match}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# §6. GROWTH RATE COMPARISON
# ═══════════════════════════════════════════════════════════════════════

def growth_comparison(depth=12):
    """Compare growth rates of different branches."""
    print("=" * 70)
    print("  GROWTH RATE COMPARISON BETWEEN BRANCHES")
    print("=" * 70)
    print()

    # Pure A-branch (polynomial growth)
    triple_A = (3, 4, 5)
    a_hyps = []
    for _ in range(depth):
        a_hyps.append(triple_A[2])
        triple_A = child_A(triple_A)

    # Pure B-branch (exponential growth)
    triple_B = (3, 4, 5)
    b_hyps = []
    for _ in range(depth):
        b_hyps.append(triple_B[2])
        triple_B = child_B(triple_B)

    # Pure C-branch (polynomial growth)
    triple_C = (3, 4, 5)
    c_hyps = []
    for _ in range(depth):
        c_hyps.append(triple_C[2])
        triple_C = child_C(triple_C)

    print(f"  {'Depth':>5}  {'A-branch c':>15}  {'B-branch c':>15}  {'C-branch c':>15}")
    print(f"  {'':>5}  {'(polynomial)':>15}  {'(exponential)':>15}  {'(polynomial)':>15}")
    for i in range(depth):
        print(f"  {i:>5}  {a_hyps[i]:>15}  {b_hyps[i]:>15}  {c_hyps[i]:>15}")

    print()
    print("  A-branch: B₁ is unipotent, (B₁-I)²=0, so B₁ⁿ = I + n(B₁-I)")
    print("            ⟹ hypotenuses grow as O(n²)")
    print()
    print("  B-branch: B₂ has eigenvalue 3+2√2 ≈ 5.828")
    print("            ⟹ hypotenuses grow as O((3+2√2)ⁿ)")
    print()
    print("  C-branch: B₃ is conjugate to B₁ (via leg-swap S)")
    print("            ⟹ same polynomial growth O(n²)")
    print()


# ═══════════════════════════════════════════════════════════════════════
# §7. LORENTZ FORM VERIFICATION
# ═══════════════════════════════════════════════════════════════════════

def mat_mul(A, B):
    """3x3 integer matrix multiplication."""
    return [[sum(A[i][k]*B[k][j] for k in range(3)) for j in range(3)] for i in range(3)]

def mat_transpose(A):
    return [[A[j][i] for j in range(3)] for i in range(3)]

def mat_trace(A):
    return sum(A[i][i] for i in range(3))

def mat_det3(A):
    return (A[0][0]*(A[1][1]*A[2][2]-A[1][2]*A[2][1])
           -A[0][1]*(A[1][0]*A[2][2]-A[1][2]*A[2][0])
           +A[0][2]*(A[1][0]*A[2][1]-A[1][1]*A[2][0]))

def mat_eq(A, B):
    return all(A[i][j] == B[i][j] for i in range(3) for j in range(3))

def lorentz_verification():
    """Verify Lorentz form preservation computationally."""
    print("=" * 70)
    print("  LORENTZ FORM PRESERVATION")
    print("=" * 70)
    print()

    Q = [[1,0,0],[0,1,0],[0,0,-1]]
    B1m = [[1,-2,2],[2,-1,2],[2,-2,3]]
    B2m = [[1,2,2],[2,1,2],[2,2,3]]
    B3m = [[-1,2,2],[-2,1,2],[-2,2,3]]

    for name, M in [("B₁", B1m), ("B₂", B2m), ("B₃", B3m),
                     ("B₁B₂", mat_mul(B1m, B2m)),
                     ("B₁B₃", mat_mul(B1m, B3m)),
                     ("B₂B₃", mat_mul(B2m, B3m)),
                     ("B₁B₂B₃", mat_mul(B1m, mat_mul(B2m, B3m)))]:
        result = mat_mul(mat_mul(mat_transpose(M), Q), M)
        preserved = mat_eq(result, Q)
        det = mat_det3(M)
        tr = mat_trace(M)
        print(f"  {name:>8}:  MᵀQM = Q? {'✓' if preserved else '✗'}  "
              f"det = {det:>2}  tr = {tr:>3}")

    print()


# ═══════════════════════════════════════════════════════════════════════
# §8. HYPOTENUSE STATISTICS
# ═══════════════════════════════════════════════════════════════════════

def hypotenuse_statistics(depth=8):
    """Analyze the distribution of hypotenuses in the tree."""
    print("=" * 70)
    print("  HYPOTENUSE DISTRIBUTION")
    print("=" * 70)
    print()

    tree = generate_tree(depth)
    hyps = sorted(set(c for (a, b, c), _, _ in tree))

    print(f"  Distinct hypotenuses at depth ≤ {depth}: {len(hyps)}")
    print(f"  First 30: {hyps[:30]}")
    print()

    # Check which are sums of two squares
    def is_sum_of_two_squares(n):
        for a in range(int(sqrt(n)) + 1):
            b_sq = n - a*a
            b = int(sqrt(b_sq))
            if b*b == b_sq:
                return True
        return False

    all_sos = all(is_sum_of_two_squares(c) for c in hyps)
    print(f"  All hypotenuses are sums of two squares: {'✓' if all_sos else '✗'}")

    # Check which are prime
    def is_prime(n):
        if n < 2: return False
        for p in range(2, int(sqrt(n)) + 1):
            if n % p == 0: return False
        return True

    prime_hyps = [c for c in hyps if is_prime(c)]
    print(f"  Prime hypotenuses: {len(prime_hyps)} out of {len(hyps)}")
    print(f"  First prime hyps: {prime_hyps[:20]}")

    # These should all be ≡ 1 (mod 4) by Fermat's theorem
    all_1mod4 = all(c % 4 == 1 for c in prime_hyps)
    print(f"  All prime hyps ≡ 1 (mod 4): {'✓' if all_1mod4 else '✗'}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "all"
    depth = int(sys.argv[2]) if len(sys.argv) > 2 else 4

    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     BERGGREN TREE EXPLORER — EML–Pythagorean Bridge v8        ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    if mode in ("tree", "all"):
        print_tree(min(depth, 4))

    if mode in ("descent", "all"):
        demo_descent()

    if mode in ("pell", "all"):
        pell_sequence()

    if mode in ("growth", "all"):
        growth_comparison()

    if mode in ("angles", "all"):
        angle_distribution(min(depth, 10))

    if mode in ("lorentz", "all"):
        lorentz_verification()

    if mode in ("hyps", "all"):
        hypotenuse_statistics(min(depth, 8))

    print("═" * 70)
    print("  Demo complete.")
    print("═" * 70)

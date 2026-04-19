#!/usr/bin/env python3
"""
Ghost Structure Explorer for the Inverted Berggren Tree

Explores the Klein four-group action, fourth ghost triples,
syndrome error detection, branch statistics, and continued fraction
connections.

Author: Research Team, April 2026
"""

import math
from collections import defaultdict
from fractions import Fraction

# ═══════════════════════════════════════════════════════════════
# 1. Core Definitions
# ═══════════════════════════════════════════════════════════════

def p_param(a, b, c):
    """The p-parameter: a + 2b - 2c."""
    return a + 2*b - 2*c

def q_param(a, b, c):
    """The q-parameter: 2a + b - 2c."""
    return 2*a + b - 2*c

def h_param(a, b, c):
    """The universal parent hypotenuse: 3c - 2(a+b)."""
    return 3*c - 2*(a + b)

def invB1(a, b, c):
    """B₁⁻¹(a,b,c) = (p, -q, h)."""
    return (p_param(a,b,c), -q_param(a,b,c), h_param(a,b,c))

def invB2(a, b, c):
    """B₂⁻¹(a,b,c) = (p, q, h)."""
    return (p_param(a,b,c), q_param(a,b,c), h_param(a,b,c))

def invB3(a, b, c):
    """B₃⁻¹(a,b,c) = (-p, q, h)."""
    return (-p_param(a,b,c), q_param(a,b,c), h_param(a,b,c))

def fourth_ghost(a, b, c):
    """The fourth ghost: (-p, -q, h)."""
    return (-p_param(a,b,c), -q_param(a,b,c), h_param(a,b,c))

def fwdB1(a, b, c): return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def fwdB2(a, b, c): return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def fwdB3(a, b, c): return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

# ═══════════════════════════════════════════════════════════════
# 2. Generate all PPTs up to a given hypotenuse bound
# ═══════════════════════════════════════════════════════════════

def generate_ppts(max_c):
    """Generate all primitive Pythagorean triples with c ≤ max_c."""
    triples = []
    for m in range(2, int(math.isqrt(max_c)) + 2):
        for n in range(1, m):
            if (m - n) % 2 == 0:
                continue
            if math.gcd(m, n) != 1:
                continue
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            if c > max_c:
                break
            # Ensure a is odd (standard ordering)
            if a % 2 == 0:
                a, b = b, a
            triples.append((a, b, c, m, n))
    return sorted(triples, key=lambda t: t[4])  # sort by n, then implicitly m

# ═══════════════════════════════════════════════════════════════
# 3. Klein Four-Group Verification
# ═══════════════════════════════════════════════════════════════

def verify_klein_four():
    """Verify the Klein four-group structure on ghost triples."""
    print("=" * 60)
    print("Klein Four-Group Verification")
    print("=" * 60)
    
    test_triples = [(3,4,5), (5,12,13), (8,15,17), (7,24,25), (20,21,29)]
    
    for a, b, c in test_triples:
        pp, qq, hh = p_param(a,b,c), q_param(a,b,c), h_param(a,b,c)
        
        b1 = invB1(a, b, c)
        b2 = invB2(a, b, c)
        b3 = invB3(a, b, c)
        fg = fourth_ghost(a, b, c)
        
        print(f"\n({a},{b},{c}): p={pp}, q={qq}, h={hh}")
        print(f"  B₁⁻¹ = ({pp}, {-qq}, {hh}) = {b1}  [sign: (+,-)]")
        print(f"  B₂⁻¹ = ({pp}, {qq}, {hh})  = {b2}  [sign: (+,+)]")
        print(f"  B₃⁻¹ = ({-pp}, {qq}, {hh}) = {b3}  [sign: (-,+)]")
        print(f"  4th   = ({-pp}, {-qq}, {hh})= {fg}  [sign: (-,-)]")
        
        # Verify all are Pythagorean (if input is)
        assert a*a + b*b == c*c, f"Input not Pythagorean!"
        for name, (x, y, z) in [("B1", b1), ("B2", b2), ("B3", b3), ("4th", fg)]:
            assert x*x + y*y == z*z, f"{name} not Pythagorean for ({a},{b},{c})"
        
        # Verify syndrome = 0
        syn = pp*pp + qq*qq - hh*hh
        assert syn == 0, f"Syndrome nonzero: {syn}"
    
    print("\n✓ All Klein four-group properties verified!")

# ═══════════════════════════════════════════════════════════════
# 4. Branch Statistics
# ═══════════════════════════════════════════════════════════════

def branch_statistics(max_c=10000):
    """Compute branch frequency and descent ratio statistics."""
    print("\n" + "=" * 60)
    print(f"Branch Statistics (c ≤ {max_c})")
    print("=" * 60)
    
    ppts = generate_ppts(max_c)
    branch_counts = {1: 0, 2: 0, 3: 0}
    descent_ratios = {1: [], 2: [], 3: []}
    depths = []
    
    for a, b, c, m, n in ppts:
        pp = p_param(a, b, c)
        qq = q_param(a, b, c)
        
        if pp > 0 and qq < 0:
            branch = 1
        elif pp > 0 and qq > 0:
            branch = 2
        elif pp < 0 and qq > 0:
            branch = 3
        else:
            # Root or degenerate
            continue
        
        branch_counts[branch] += 1
        hh = h_param(a, b, c)
        if c > 0:
            descent_ratios[branch].append(hh / c)
        
        # Compute depth by descending to root
        depth = 0
        ca, cb, cc = a, b, c
        while cc > 5:
            pp_d = p_param(ca, cb, cc)
            qq_d = q_param(ca, cb, cc)
            hh_d = h_param(ca, cb, cc)
            if pp_d > 0 and qq_d < 0:
                ca, cb, cc = pp_d, -qq_d, hh_d
            elif pp_d > 0 and qq_d > 0:
                ca, cb, cc = pp_d, qq_d, hh_d
            elif pp_d < 0 and qq_d > 0:
                ca, cb, cc = -pp_d, qq_d, hh_d
            else:
                break
            depth += 1
            if depth > 200:
                break
        depths.append(depth)
    
    total = sum(branch_counts.values())
    print(f"\nTotal PPTs: {total}")
    for br in [1, 2, 3]:
        pct = 100 * branch_counts[br] / total if total > 0 else 0
        ratios = descent_ratios[br]
        if ratios:
            print(f"  Branch {br}: {branch_counts[br]:5d} ({pct:5.1f}%)  "
                  f"h/c: min={min(ratios):.4f}, max={max(ratios):.4f}, "
                  f"mean={sum(ratios)/len(ratios):.4f}")
        else:
            print(f"  Branch {br}: {branch_counts[br]:5d} ({pct:5.1f}%)")
    
    if depths:
        print(f"\nDepth: max={max(depths)}, mean={sum(depths)/len(depths):.1f}")
    
    # Theoretical limit for branch 2
    print(f"\nTheoretical branch 2 limit: 3 - 2√2 ≈ {3 - 2*math.sqrt(2):.6f}")

# ═══════════════════════════════════════════════════════════════
# 5. Continued Fraction Connection
# ═══════════════════════════════════════════════════════════════

def continued_fraction_connection():
    """Explore the m/n ratio and its CF expansion."""
    print("\n" + "=" * 60)
    print("Continued Fraction Connection")
    print("=" * 60)
    
    ppts = generate_ppts(200)
    
    print(f"\n{'Triple':>15s}  {'m':>3s}  {'n':>3s}  {'m/n':>6s}  {'⌊m/n⌋':>5s}  Branch")
    print("-" * 55)
    
    for a, b, c, m, n in ppts:
        ratio = Fraction(m, n)
        floor_ratio = m // n
        pp = p_param(a, b, c)
        qq = q_param(a, b, c)
        
        if pp > 0 and qq < 0:
            branch = 1
        elif pp > 0 and qq > 0:
            branch = 2
        elif pp < 0 and qq > 0:
            branch = 3
        else:
            branch = 0  # root
        
        print(f"({a:3d},{b:3d},{c:3d})  {m:3d}  {n:3d}  {float(ratio):6.3f}  {floor_ratio:5d}  {branch}")
    
    print("\nBranch 1: 1 < m/n < 2 (⌊m/n⌋ = 1)")
    print("Branch 2: 2 < m/n < 3 (⌊m/n⌋ = 2)")
    print("Branch 3: m/n > 3   (⌊m/n⌋ ≥ 3)")

# ═══════════════════════════════════════════════════════════════
# 6. Error Detection Demo
# ═══════════════════════════════════════════════════════════════

def error_detection_demo():
    """Demonstrate error detection using the syndrome."""
    print("\n" + "=" * 60)
    print("Error Detection via Ghost Syndrome")
    print("=" * 60)
    
    a, b, c = 5, 12, 13
    
    # Correct triple
    syn = p_param(a,b,c)**2 + q_param(a,b,c)**2 - h_param(a,b,c)**2
    print(f"\nCorrect triple ({a},{b},{c}): syndrome = {syn}")
    
    # Corrupted triples
    for da, db, dc in [(1,0,0), (0,1,0), (0,0,1), (2,0,0), (0,-1,0)]:
        a2, b2, c2 = a+da, b+db, c+dc
        syn = p_param(a2,b2,c2)**2 + q_param(a2,b2,c2)**2 - h_param(a2,b2,c2)**2
        pyth = a2*a2 + b2*b2 - c2*c2
        detected = "DETECTED ✓" if syn != 0 else "MISSED ✗"
        print(f"  ({a2},{b2},{c2}): syndrome = {syn:4d}, "
              f"a²+b²-c² = {pyth:4d}  [{detected}]")
    
    print("\nNote: syndrome = a²+b²-c² (Lorentz form preservation)")
    print("Any corruption that changes a²+b²-c² is detected.")

# ═══════════════════════════════════════════════════════════════
# 7. Descent Chain Visualization
# ═══════════════════════════════════════════════════════════════

def descent_chain(a, b, c, max_steps=50):
    """Trace the descent chain from (a,b,c) to (3,4,5)."""
    chain = [(a, b, c)]
    ca, cb, cc = a, b, c
    
    for _ in range(max_steps):
        if cc <= 5:
            break
        pp = p_param(ca, cb, cc)
        qq = q_param(ca, cb, cc)
        hh = h_param(ca, cb, cc)
        
        if pp > 0 and qq < 0:
            ca, cb, cc = pp, -qq, hh
            branch = 1
        elif pp > 0 and qq > 0:
            ca, cb, cc = pp, qq, hh
            branch = 2
        elif pp < 0 and qq > 0:
            ca, cb, cc = -pp, qq, hh
            branch = 3
        else:
            break
        chain.append((ca, cb, cc))
    
    return chain

def show_descent_chains():
    """Show descent chains for several interesting triples."""
    print("\n" + "=" * 60)
    print("Descent Chains")
    print("=" * 60)
    
    test_triples = [
        (9, 40, 41),
        (20, 21, 29),
        (119, 120, 169),
        (28, 45, 53),
    ]
    
    for a, b, c in test_triples:
        chain = descent_chain(a, b, c)
        print(f"\n({a},{b},{c}) → depth {len(chain)-1}:")
        for i, (ca, cb, cc) in enumerate(chain):
            pp = p_param(ca, cb, cc)
            qq = q_param(ca, cb, cc)
            br = ""
            if cc > 5:
                if pp > 0 and qq < 0: br = "→B₁"
                elif pp > 0 and qq > 0: br = "→B₂"
                elif pp < 0 and qq > 0: br = "→B₃"
            print(f"  {'  ' * i}({ca},{cb},{cc}) {br}")

# ═══════════════════════════════════════════════════════════════
# 8. Sum of Squares Witnesses
# ═══════════════════════════════════════════════════════════════

def sum_of_squares_witnesses():
    """Show the (m-2n)² + n² decomposition of parent hypotenuses."""
    print("\n" + "=" * 60)
    print("Parent Hypotenuse as Sum of Two Squares")
    print("=" * 60)
    
    ppts = generate_ppts(200)
    
    print(f"\n{'Triple':>15s}  {'m':>3s}  {'n':>3s}  {'h':>5s}  {'u=m-2n':>6s}  {'v=n':>4s}  {'u²+v²':>6s}")
    print("-" * 60)
    
    for a, b, c, m, n in ppts:
        hh = h_param(a, b, c)
        u = m - 2*n
        v = n
        check = u*u + v*v
        assert check == hh, f"Sum of squares mismatch! {u}²+{v}²={check} ≠ {hh}"
        print(f"({a:3d},{b:3d},{c:3d})  {m:3d}  {n:3d}  {hh:5d}  {u:6d}  {v:4d}  {check:6d}")
    
    print("\n✓ All parent hypotenuses verified as sums of two squares!")

# ═══════════════════════════════════════════════════════════════
# 9. Information Theory: Berggren Address Entropy
# ═══════════════════════════════════════════════════════════════

def berggren_entropy(max_c=50000):
    """Compute the Shannon entropy of Berggren branch frequencies."""
    print("\n" + "=" * 60)
    print(f"Berggren Address Entropy (c ≤ {max_c})")
    print("=" * 60)
    
    ppts = generate_ppts(max_c)
    branch_counts = {1: 0, 2: 0, 3: 0}
    
    for a, b, c, m, n in ppts:
        pp = p_param(a, b, c)
        qq = q_param(a, b, c)
        if pp > 0 and qq < 0:
            branch_counts[1] += 1
        elif pp > 0 and qq > 0:
            branch_counts[2] += 1
        elif pp < 0 and qq > 0:
            branch_counts[3] += 1
    
    total = sum(branch_counts.values())
    if total == 0:
        return
    
    entropy = 0
    for br in [1, 2, 3]:
        p_br = branch_counts[br] / total
        if p_br > 0:
            entropy -= p_br * math.log2(p_br)
        print(f"  Branch {br}: frequency = {p_br:.4f}")
    
    print(f"\n  Shannon entropy H = {entropy:.4f} bits/step")
    print(f"  Maximum (balanced): log₂(3) = {math.log2(3):.4f} bits/step")
    print(f"  Efficiency: {100*entropy/math.log2(3):.1f}%")

# ═══════════════════════════════════════════════════════════════
# 10. Double Descent Verification
# ═══════════════════════════════════════════════════════════════

def double_descent_verify():
    """Verify the M² formula: applying ghost map twice."""
    print("\n" + "=" * 60)
    print("Double Descent (M²) Verification")
    print("=" * 60)
    
    test_triples = [(3,4,5), (5,12,13), (8,15,17), (7,24,25), (20,21,29)]
    
    for a, b, c in test_triples:
        # First ghost map
        p1, q1, h1 = p_param(a,b,c), q_param(a,b,c), h_param(a,b,c)
        # Second ghost map
        p2, q2, h2 = p_param(p1,q1,h1), q_param(p1,q1,h1), h_param(p1,q1,h1)
        
        # Check M² formula
        expected_p2 = 9*a + 8*b - 12*c
        expected_q2 = 8*a + 9*b - 12*c
        expected_h2 = -12*a - 12*b + 17*c
        
        assert p2 == expected_p2, f"p2 mismatch for ({a},{b},{c})"
        assert q2 == expected_q2, f"q2 mismatch for ({a},{b},{c})"
        assert h2 == expected_h2, f"h2 mismatch for ({a},{b},{c})"
        
        # Check p2 - q2 = a - b (preserved through double descent!)
        assert p2 - q2 == a - b, f"leg difference not preserved!"
        
        print(f"({a},{b},{c}) → ({p1},{q1},{h1}) → ({p2},{q2},{h2})  "
              f"[p₂-q₂={p2-q2}, a-b={a-b}] ✓")
    
    print("\n✓ All double descent formulas verified!")
    print("  Note: p₂ - q₂ = a - b (leg difference preserved through M²)")

# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Ghost Structure Explorer — Inverted Berggren Tree      ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    verify_klein_four()
    branch_statistics(max_c=5000)
    continued_fraction_connection()
    error_detection_demo()
    show_descent_chains()
    sum_of_squares_witnesses()
    berggren_entropy(max_c=10000)
    double_descent_verify()
    
    print("\n" + "=" * 60)
    print("All explorations complete!")
    print("=" * 60)

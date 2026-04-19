#!/usr/bin/env python3
"""
ADVANCED APPLICATIONS OF THE INVERTED BERGGREN TREE
=====================================================

This module explores deeper applications:
  1. GPS-like coordinate system for PPTs
  2. Entropy and information content of PPTs
  3. The "anti-tree" — running all branches simultaneously
  4. Cryptographic hash from descent path
  5. Musical/acoustic applications (frequency ratios)
  6. Clustering and visualization in the hyperbolic plane
  7. Inverse tree sieve for primality testing
"""

import numpy as np
from math import gcd, isqrt, log2, log, pi, sqrt
from fractions import Fraction
from collections import defaultdict

# Berggren matrices
B = [
    np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64),  # B1
    np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]], dtype=np.int64),  # B2
    np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64),  # B3
]

B_inv = [
    np.array([[ 1,  2, -2], [-2, -1,  2], [-2, -2,  3]], dtype=np.int64),
    np.array([[ 1,  2, -2], [ 2,  1, -2], [-2, -2,  3]], dtype=np.int64),
    np.array([[-1, -2,  2], [ 2,  1, -2], [-2, -2,  3]], dtype=np.int64),
]


def normalize(a, b, c):
    if a % 2 == 0 and b % 2 == 1:
        a, b = b, a
    return (abs(a), abs(b), abs(c))


def descent(a, b, c):
    """Return (parent_triple, branch_index) or None if at root."""
    if (a, b, c) == (3, 4, 5):
        return None
    for i, M in enumerate(B_inv):
        r = M @ np.array([a, b, c], dtype=np.int64)
        ra, rb, rc = int(r[0]), int(r[1]), int(r[2])
        # Normalize: a odd, b even, but check raw signs first
        if ra % 2 == 0 and rb % 2 == 1:
            ra, rb = rb, ra
        if ra > 0 and rb > 0 and rc > 0:
            return (ra, rb, rc), i
    return None


def full_address(a, b, c):
    """Compute Berggren address string."""
    branches = []
    current = (a, b, c)
    while current != (3, 4, 5):
        result = descent(*current)
        if result is None:
            return None
        current, idx = result
        branches.append(str(idx + 1))
    branches.reverse()
    return ''.join(branches)


def gen_ppts(max_c):
    """Generate all PPTs with hypotenuse ≤ max_c."""
    ppts = []
    for m in range(2, max_c):
        for n in range(1, m):
            if (m - n) % 2 == 0 or gcd(m, n) != 1:
                continue
            c = m*m + n*n
            if c > max_c:
                break
            a = m*m - n*n
            b = 2*m*n
            if a % 2 == 0:
                a, b = b, a
            ppts.append((a, b, c))
    return ppts


# ═══════════════════════════════════════════════════════════════
# 1. GPS-LIKE COORDINATE SYSTEM FOR PPTs
# ═══════════════════════════════════════════════════════════════

def ppt_gps():
    """
    Each PPT has a unique "GPS coordinate" — its address in {1,2,3}*.
    
    We can define a METRIC on PPTs using addresses:
      d(T₁, T₂) = length of address(T₁) + length(address(T₂)) 
                   - 2 * length(common_prefix(address(T₁), address(T₂)))
    
    This is the tree distance: the number of edges in the unique
    path between T₁ and T₂ in the Berggren tree.
    """
    print("=" * 65)
    print("1. GPS COORDINATE SYSTEM FOR PPTs")
    print("=" * 65)
    
    ppts = gen_ppts(200)
    addresses = {}
    for t in ppts:
        addr = full_address(*t)
        if addr is not None:
            addresses[t] = addr
    
    def common_prefix_len(s1, s2):
        i = 0
        while i < len(s1) and i < len(s2) and s1[i] == s2[i]:
            i += 1
        return i
    
    def tree_distance(t1, t2):
        a1 = addresses.get(t1, '')
        a2 = addresses.get(t2, '')
        cp = common_prefix_len(a1, a2)
        return len(a1) + len(a2) - 2 * cp
    
    # Show some distances
    sample = sorted(ppts, key=lambda t: t[2])[:12]
    print(f"\n  Tree distances between small PPTs:")
    print(f"  {'':14s}", end='')
    for t in sample[:6]:
        print(f"  {t[2]:5d}", end='')
    print()
    
    for t1 in sample[:6]:
        print(f"  ({t1[0]:3d},{t1[1]:3d},{t1[2]:3d})", end='')
        for t2 in sample[:6]:
            d = tree_distance(t1, t2)
            print(f"  {d:5d}", end='')
        print()
    
    # Find closest PPTs (neighbors)
    print(f"\n  Nearest neighbors in tree metric:")
    for t in sample[:8]:
        distances = [(tree_distance(t, t2), t2) for t2 in ppts if t2 != t]
        distances.sort()
        nn = distances[0]
        print(f"    {t} → nearest: {nn[1]}, distance={nn[0]}")
    print()


# ═══════════════════════════════════════════════════════════════
# 2. INFORMATION CONTENT & ENTROPY
# ═══════════════════════════════════════════════════════════════

def entropy_analysis():
    """
    The address of a PPT encodes its "information content."
    
    THEOREM: The information content of PPT (a,b,c) is
        I(a,b,c) = len(address) · log₂(3) ≈ 1.585 · depth
    
    Since depth ≈ log(c), we get I ≈ 1.585 · log₂(c).
    
    But different branches have different growth rates:
    - B₁ (branch 1): c grows slowly (eigenvalue 1)
    - B₂ (branch 2): c grows as 3+2√2 ≈ 5.828 per step
    - B₃ (branch 3): c grows slowly (eigenvalue 1)
    
    This means PPTs reached via B₂ have lower information density
    (fewer bits per unit of log(c)) than those reached via B₁/B₃.
    """
    print("=" * 65)
    print("2. INFORMATION CONTENT & ENTROPY OF PPTs")
    print("=" * 65)
    
    ppts = gen_ppts(5000)
    
    branch_counts = defaultdict(int)
    info_data = []
    
    for t in ppts:
        addr = full_address(*t)
        if addr is None or addr == '':
            continue
        depth = len(addr)
        info_bits = depth * log2(3)
        hyp_bits = log2(t[2]) if t[2] > 1 else 0
        density = info_bits / hyp_bits if hyp_bits > 0 else 0
        
        for ch in addr:
            branch_counts[ch] += 1
        
        info_data.append((t, addr, depth, info_bits, density))
    
    total_branches = sum(branch_counts.values())
    print(f"\n  Branch frequency distribution (across {len(ppts)} PPTs):")
    for b in '123':
        count = branch_counts[b]
        freq = count / total_branches if total_branches > 0 else 0
        print(f"    Branch {b}: {count:5d} ({freq:.4f})")
    
    print(f"\n  Information density (bits per log₂(c)):")
    # Sort by density
    info_data.sort(key=lambda x: x[4])
    print(f"    Lowest density (most 'compressible'):")
    for t, addr, depth, bits, density in info_data[:5]:
        print(f"      {t}  addr={addr:<10s}  I={bits:.1f} bits  density={density:.3f}")
    print(f"    Highest density (most 'random'):")
    for t, addr, depth, bits, density in info_data[-5:]:
        print(f"      {t}  addr={addr:<10s}  I={bits:.1f} bits  density={density:.3f}")
    
    avg_density = sum(d[4] for d in info_data) / len(info_data)
    print(f"\n    Average density: {avg_density:.4f}")
    print(f"    Theoretical: log₂(3) / log₂(3+2√2) ≈ {log2(3)/log2(3+2*sqrt(2)):.4f} for B₂-heavy paths")
    print()


# ═══════════════════════════════════════════════════════════════
# 3. THE ANTI-TREE (Simultaneous Inverse Branches)
# ═══════════════════════════════════════════════════════════════

def anti_tree():
    """
    The "anti-tree" applies ALL THREE inverse branches simultaneously,
    creating a directed graph where each node has up to 3 incoming edges
    (from children) and up to 1 outgoing edge (to parent via correct branch).
    
    When we apply all 3 inverses to a PPT, exactly 1 gives a valid PPT,
    and the other 2 give non-PPT integer triples (which may still satisfy
    the Lorentz form Q=0 but with negative components).
    
    DISCOVERY: The "ghost triples" (invalid outputs) still carry 
    algebraic information about the tree structure.
    """
    print("=" * 65)
    print("3. THE ANTI-TREE (Ghost Triples)")
    print("=" * 65)
    
    test_triples = [(5, 12, 13), (21, 20, 29), (7, 24, 25), (9, 40, 41)]
    
    for a, b, c in test_triples:
        print(f"\n  Triple ({a}, {b}, {c}):")
        for i, M in enumerate(B_inv):
            r = M @ np.array([a, b, c], dtype=np.int64)
            ra, rb, rc = int(r[0]), int(r[1]), int(r[2])
            q = ra**2 + rb**2 - rc**2
            valid = ra > 0 and rb > 0 and rc > 0 and q == 0
            status = "✓ VALID PARENT" if valid else "✗ ghost"
            print(f"    B{i+1}⁻¹ → ({ra:4d}, {rb:4d}, {rc:4d})  "
                  f"Q={q:4d}  {status}")
    print()


# ═══════════════════════════════════════════════════════════════
# 4. CRYPTOGRAPHIC HASH FROM DESCENT
# ═══════════════════════════════════════════════════════════════

def descent_hash():
    """
    The descent path gives a natural hash function:
    
    H(a, b, c) = address string interpreted in base 3
    
    Properties:
    - Deterministic (same input → same output)
    - Hard to invert efficiently without matrix computation
    - Collision-free by the tree uniqueness theorem
    - Variable-length output encoding
    
    We can create a fixed-length hash by reducing mod p.
    """
    print("=" * 65)
    print("4. DESCENT-BASED HASH FUNCTION")
    print("=" * 65)
    
    ppts = gen_ppts(1000)
    
    print(f"\n  PPT hashes (address interpreted as ternary number):")
    for t in sorted(ppts, key=lambda x: x[2])[:15]:
        addr = full_address(*t)
        if addr is None:
            continue
        # Convert ternary address to integer
        hash_val = 0
        for ch in addr:
            hash_val = hash_val * 3 + (int(ch) - 1)
        hash_mod = hash_val % 997  # mod a prime
        print(f"    ({t[0]:3d},{t[1]:3d},{t[2]:3d})  addr={addr:<10s}  "
              f"hash={hash_val:8d}  hash mod 997 = {hash_mod:3d}")
    print()


# ═══════════════════════════════════════════════════════════════
# 5. MUSICAL APPLICATIONS (Frequency Ratios)
# ═══════════════════════════════════════════════════════════════

def musical_ratios():
    """
    PPTs define right triangles, which give angle ratios.
    The descent/address structure creates a natural hierarchy
    of "consonance" — simpler addresses = simpler ratios.
    
    Application: Generate musical scales from PPT ratios.
    The ratio a/b for each PPT defines a frequency ratio.
    Triples at shallow depth give "more consonant" ratios.
    """
    print("=" * 65)
    print("5. MUSICAL FREQUENCY RATIOS FROM PPTs")
    print("=" * 65)
    
    ppts = gen_ppts(500)
    
    print(f"\n  PPT ratios ordered by depth (simpler = more consonant):")
    ratio_data = []
    for t in ppts:
        addr = full_address(*t)
        if addr is None:
            addr = ''
        a, b, c = t
        ratio = Fraction(min(a, b), max(a, b))
        cents = 1200 * log2(max(a, b) / min(a, b)) if min(a, b) > 0 else 0
        ratio_data.append((len(addr), t, ratio, cents, addr))
    
    ratio_data.sort()
    
    for depth, t, ratio, cents, addr in ratio_data[:20]:
        note = ""
        if abs(cents - 0) < 50: note = "≈ unison"
        elif abs(cents - 100) < 30: note = "≈ semitone"
        elif abs(cents - 200) < 30: note = "≈ whole tone"
        elif abs(cents - 386) < 30: note = "≈ major 3rd"
        elif abs(cents - 498) < 30: note = "≈ perfect 4th"
        elif abs(cents - 702) < 30: note = "≈ perfect 5th"
        elif abs(cents - 884) < 30: note = "≈ major 6th"
        elif abs(cents - 1200) < 30: note = "≈ octave"
        
        print(f"    depth={depth}  ({t[0]:3d},{t[1]:3d},{t[2]:3d})  "
              f"ratio={str(ratio):<7s}  cents={cents:7.1f}  {note}")
    print()


# ═══════════════════════════════════════════════════════════════
# 6. HYPERBOLIC COORDINATES & POINCARÉ DISK
# ═══════════════════════════════════════════════════════════════

def hyperbolic_embedding():
    """
    PPTs live naturally in the hyperbolic plane (Lorentz model).
    
    The point (a, b, c) with a²+b²=c² maps to the point
    (a/c, b/c) on the unit disk — this IS the Poincaré disk model.
    
    The descent moves points TOWARD the center (3/5, 4/5).
    The forward tree expands outward toward the boundary.
    
    DISCOVERY: The three Berggren branches correspond to
    hyperbolic reflections, and the tree is a fundamental
    domain tiling of H².
    """
    print("=" * 65)
    print("6. HYPERBOLIC EMBEDDING (Poincaré Disk)")
    print("=" * 65)
    
    ppts = gen_ppts(500)
    
    print(f"\n  PPTs in Poincaré disk coordinates (x, y) = (a/c, b/c):")
    print(f"  {'Triple':>18s}  {'(x, y)':>20s}  {'|z|':>8s}  depth  addr")
    
    for t in sorted(ppts, key=lambda x: x[2])[:20]:
        a, b, c = t
        x, y = a/c, b/c
        r = sqrt(x**2 + y**2)
        addr = full_address(*t) or ''
        depth = len(addr)
        print(f"  ({a:3d},{b:3d},{c:3d})  ({x:.4f}, {y:.4f})  {r:.6f}  {depth:5d}  {addr}")
    
    # Hyperbolic distance from root
    print(f"\n  Hyperbolic distance from root (3/5, 4/5):")
    x0, y0 = 3/5, 4/5
    
    for t in sorted(ppts, key=lambda x: x[2])[:15]:
        a, b, c = t
        x, y = a/c, b/c
        # Poincaré disk distance
        # d(z1, z2) = arccosh(1 + 2|z1-z2|² / ((1-|z1|²)(1-|z2|²)))
        r1sq = x0**2 + y0**2
        r2sq = x**2 + y**2
        dsq = (x - x0)**2 + (y - y0)**2
        if (1 - r1sq) > 0 and (1 - r2sq) > 0:
            arg = 1 + 2 * dsq / ((1 - r1sq) * (1 - r2sq))
            if arg >= 1:
                hyp_dist = log(arg + sqrt(arg**2 - 1))  # arccosh
            else:
                hyp_dist = 0
        else:
            hyp_dist = float('inf')
        
        addr = full_address(*t) or ''
        print(f"    {t}  hyp_dist={hyp_dist:.4f}  depth={len(addr)}")
    print()


# ═══════════════════════════════════════════════════════════════
# 7. INVERSE SIEVE FOR PRIMALITY
# ═══════════════════════════════════════════════════════════════

def inverse_sieve():
    """
    APPLICATION: Primality test via the Berggren tree.
    
    THEOREM (Fermat): An odd prime p is the hypotenuse of a PPT
    iff p ≡ 1 (mod 4).
    
    The address of such a prime-hypotenuse PPT in the Berggren tree
    is uniquely determined. The ADDRESS LENGTH relates to the size
    of the prime.
    
    For composite hypotenuses, there may be MULTIPLE representations
    — the number of representations relates to the factorization.
    """
    print("=" * 65)
    print("7. INVERSE SIEVE — PRIMALITY AND FACTORING")
    print("=" * 65)
    
    def is_prime(n):
        if n < 2: return False
        if n < 4: return True
        if n % 2 == 0 or n % 3 == 0: return False
        i = 5
        while i*i <= n:
            if n % i == 0 or n % (i+2) == 0: return False
            i += 6
        return True
    
    def count_ppt_representations(c):
        """Count how many PPTs have hypotenuse c."""
        count = 0
        for a in range(1, c):
            b2 = c*c - a*a
            if b2 <= 0:
                break
            b = isqrt(b2)
            if b*b == b2 and gcd(gcd(a, b), c) == 1:
                if a % 2 == 1 and b % 2 == 0:
                    count += 1
        return count
    
    print(f"\n  Hypotenuse analysis (c ≤ 200):")
    print(f"  {'c':>5s}  {'prime?':>6s}  {'c mod 4':>7s}  {'#PPTs':>5s}  {'factorization':>20s}  addresses")
    
    for c in range(5, 201, 2):
        n_reps = count_ppt_representations(c)
        if n_reps == 0:
            continue
        
        pr = is_prime(c)
        mod4 = c % 4
        
        # Factorize
        factors = []
        n = c
        d = 2
        while d*d <= n:
            while n % d == 0:
                factors.append(d)
                n //= d
            d += 1
        if n > 1:
            factors.append(n)
        
        # Get addresses
        addrs = []
        for a in range(1, c):
            b2 = c*c - a*a
            if b2 <= 0:
                break
            b = isqrt(b2)
            if b*b == b2 and gcd(gcd(a, b), c) == 1:
                if a % 2 == 1 and b % 2 == 0:
                    try:
                        addr = full_address(a, b, c)
                        if addr is not None:
                            addrs.append(addr)
                    except:
                        pass
        
        fact_str = '×'.join(str(f) for f in factors) if len(factors) > 1 else str(c)
        addr_str = ', '.join(addrs) if addrs else '?'
        
        if n_reps > 1 or c < 100:
            print(f"  {c:5d}  {'yes' if pr else 'no':>6s}  {mod4:7d}  {n_reps:5d}  "
                  f"{fact_str:>20s}  {addr_str}")
    print()


# ═══════════════════════════════════════════════════════════════
# 8. DEPTH FORMULA AND ASYMPTOTICS
# ═══════════════════════════════════════════════════════════════

def depth_asymptotics():
    """
    Analyze the relationship between hypotenuse c and tree depth d.
    
    CONJECTURE: d(c) ~ α · log(c) for some constant α.
    
    The constant α depends on the "branch type":
    - Pure B₁ chains: d ∝ c (linear! since B₁ is unipotent)
    - Pure B₂ chains: d = log_{3+2√2}(c/5) + O(1)  
    - Pure B₃ chains: d ∝ c (linear! since B₃ is unipotent)
    - Mixed paths: intermediate behavior
    
    The AVERAGE depth over all PPTs with c ≤ N is what matters.
    """
    print("=" * 65)
    print("8. DEPTH ASYMPTOTICS")
    print("=" * 65)
    
    ppts = gen_ppts(5000)
    
    depth_data = []
    for t in ppts:
        addr = full_address(*t)
        if addr is None:
            continue
        depth = len(addr)
        if depth > 0:
            depth_data.append((t[2], depth, addr))
    
    # Fit log relationship
    print(f"\n  Depth vs log(c):")
    print(f"  {'c range':>15s}  {'avg depth':>10s}  {'avg log₂(c)':>12s}  {'ratio d/log₂(c)':>16s}")
    
    ranges = [(5, 50), (50, 200), (200, 500), (500, 1000), (1000, 2000), (2000, 5000)]
    for lo, hi in ranges:
        subset = [(c, d) for c, d, _ in depth_data if lo <= c < hi]
        if subset:
            avg_d = sum(d for _, d in subset) / len(subset)
            avg_logc = sum(log2(c) for c, _ in subset) / len(subset)
            ratio = avg_d / avg_logc if avg_logc > 0 else 0
            print(f"  [{lo:5d},{hi:5d})  {avg_d:10.2f}  {avg_logc:12.2f}  {ratio:16.4f}")
    
    # Maximum depth at each c level
    print(f"\n  Maximum depth at each hypotenuse level:")
    max_depth_by_c = defaultdict(int)
    for c, d, addr in depth_data:
        max_depth_by_c[c] = max(max_depth_by_c[c], d)
    
    # Show a few
    sorted_c = sorted(max_depth_by_c.keys())
    for c in sorted_c[-10:]:
        d = max_depth_by_c[c]
        print(f"    c={c:5d}  max_depth={d}  d/c={d/c:.6f}  d/√c={d/sqrt(c):.4f}")
    print()


# ═══════════════════════════════════════════════════════════════
# 9. THE INVERSE TREE AS ERROR-CORRECTION
# ═══════════════════════════════════════════════════════════════

def error_correction():
    """
    NOVEL APPLICATION: Error correction using the Berggren tree.
    
    If we transmit a PPT (a,b,c) and it gets corrupted to (a',b',c'),
    the descent algorithm can detect the error:
    - If (a',b',c') is not a PPT, the error is immediately detected
    - If it IS a PPT but different from (a,b,c), the address changes
    - The Hamming-like distance between addresses measures the error severity
    
    We can add redundancy by transmitting the address along with the triple.
    """
    print("=" * 65)
    print("9. ERROR DETECTION VIA BERGGREN DESCENT")
    print("=" * 65)
    
    # Original triple
    original = (5, 12, 13)
    orig_addr = full_address(*original)
    
    print(f"\n  Original: {original}  address={orig_addr}")
    print(f"\n  Perturbation analysis:")
    
    for da, db in [(-2, 0), (0, -2), (2, 0), (0, 2), (-2, 2), (2, -2)]:
        a2 = original[0] + da
        b2 = original[1] + db
        c2_sq = a2**2 + b2**2
        c2 = isqrt(c2_sq)
        is_pyth = c2*c2 == c2_sq and a2 > 0 and b2 > 0
        
        status = "DETECTED (not a PPT)"
        if is_pyth and gcd(gcd(a2, b2), c2) == 1:
            try:
                addr = full_address(a2, b2, c2)
                if addr == orig_addr:
                    status = f"UNDETECTED (same addr)"
                else:
                    status = f"DETECTED (addr={addr})"
            except:
                status = "DETECTED (descent failed)"
        
        print(f"    ({a2},{b2},?) → {status}")
    print()


# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   ADVANCED APPLICATIONS OF THE INVERTED BERGGREN TREE          ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    ppt_gps()
    entropy_analysis()
    anti_tree()
    descent_hash()
    musical_ratios()
    hyperbolic_embedding()
    inverse_sieve()
    depth_asymptotics()
    error_correction()
    
    print("=" * 65)
    print("ALL DEMOS COMPLETE")
    print("=" * 65)

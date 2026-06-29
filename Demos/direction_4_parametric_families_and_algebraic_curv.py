#!/usr/bin/env python3
"""
applications.py — Real-world applications of the diagonal collapse family theory.

Demonstrates:
1. Efficient search for three-cube representations
2. Density estimation and conjecture testing
3. Sieve-theoretic analysis of the value set
4. Comparison of naive vs parametric search strategies
"""

import math
import time
from collections import defaultdict
from typing import Optional


def diagonal_cubic(a: int, b: int) -> int:
    """F(a,b) = -3ab(a+b)."""
    return -3 * a * b * (a + b)


# ───────────────────────────────────────────────────────────
# Application 1: Efficient Three-Cube Search
# ───────────────────────────────────────────────────────────

def parametric_search(k: int, B: int) -> Optional[tuple[int, int, int]]:
    """
    Search for k = x³ + y³ + z³ via the parametric family.
    
    Complexity: O(B²) vs O(B³) for naive 3-variable search.
    This demonstrates the power of parametric families as a
    dimension-reduction technique.
    """
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            if diagonal_cubic(a, b) == k:
                return (a, b, -a - b)
    return None


def naive_search(k: int, B: int) -> Optional[tuple[int, int, int]]:
    """
    Naive search for k = x³ + y³ + z³.
    
    Complexity: O(B³) — much slower than parametric search.
    """
    for x in range(-B, B + 1):
        for y in range(-B, B + 1):
            for z in range(-B, B + 1):
                if x**3 + y**3 + z**3 == k:
                    return (x, y, z)
    return None


def compare_search_strategies():
    """Compare parametric vs naive search on sample targets."""
    print("=" * 70)
    print("APPLICATION 1: Parametric vs Naive Search")
    print("=" * 70)
    
    # Test values known to be in the family
    test_values = [-18, -120, -990, 6, 60, 504]
    B = 20
    
    print(f"\n  Searching with B={B}:")
    print(f"  {'k':>8s}  {'Parametric':>15s}  {'Time(μs)':>10s}  {'Naive':>15s}  {'Time(μs)':>10s}")
    
    for k in test_values:
        # Parametric search
        t0 = time.perf_counter()
        r1 = parametric_search(k, B)
        t1 = time.perf_counter()
        dt_param = (t1 - t0) * 1e6
        
        # Naive search (smaller B to keep tractable)
        t0 = time.perf_counter()
        r2 = naive_search(k, min(B, 15))
        t1 = time.perf_counter()
        dt_naive = (t1 - t0) * 1e6
        
        r1_str = f"({r1[0]},{r1[1]},{r1[2]})" if r1 else "None"
        r2_str = f"({r2[0]},{r2[1]},{r2[2]})" if r2 else "None"
        print(f"  {k:8d}  {r1_str:>15s}  {dt_param:10.0f}  {r2_str:>15s}  {dt_naive:10.0f}")
    
    print(f"\n  Parametric search is O(B²), naive is O(B³).")
    print(f"  At B={B}: parametric ≈ {(2*B+1)**2} ops, naive ≈ {(2*B+1)**3} ops")
    print(f"  Speedup factor: ≈ {(2*B+1):.0f}x")


# ───────────────────────────────────────────────────────────
# Application 2: Density Conjecture Testing
# ───────────────────────────────────────────────────────────

def density_test():
    """
    Test the conjecture V(N) ≥ c·N^(2/3).
    
    Enumerate values for increasing B and measure the ratio
    V(N)/N^(2/3).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Density Conjecture V(N) ~ c·N^(2/3)")
    print("=" * 70)
    
    print(f"\n  {'B':>5s}  {'N_max':>10s}  {'V(N)':>7s}  {'N^(2/3)':>10s}  {'Ratio':>8s}  {'log-log slope':>14s}")
    
    prev_log_V = None
    prev_log_N = None
    
    for B in [20, 40, 80, 160, 320]:
        values = set()
        for a in range(-B, B + 1):
            for b in range(-B, B + 1):
                v = abs(diagonal_cubic(a, b))
                if v > 0:
                    values.add(v)
        
        N = max(values) if values else 1
        V_N = len({v for v in values if v <= N})
        N_23 = N ** (2/3)
        ratio = V_N / N_23
        
        log_V = math.log(V_N) if V_N > 0 else 0
        log_N = math.log(N) if N > 0 else 0
        
        slope_str = ""
        if prev_log_V is not None and prev_log_N is not None:
            if log_N != prev_log_N:
                slope = (log_V - prev_log_V) / (log_N - prev_log_N)
                slope_str = f"{slope:.4f}"
        
        print(f"  {B:5d}  {N:10d}  {V_N:7d}  {N_23:10.1f}  {ratio:8.4f}  {slope_str:>14s}")
        
        prev_log_V = log_V
        prev_log_N = log_N
    
    print(f"\n  If slope ≈ 0.667, the N^(2/3) conjecture is supported.")
    print(f"  If slope drifts toward 0, the conjecture is threatened.")


# ───────────────────────────────────────────────────────────
# Application 3: Sieve-Theoretic Analysis
# ───────────────────────────────────────────────────────────

def sieve_analysis():
    """
    Analyze prime divisibility patterns in the value set.
    
    For primitive pairs (gcd(a,b) = 1), the factors a, b, a+b
    are pairwise coprime. This constrains which primes can divide
    F(a,b) = -3ab(a+b).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Sieve-Theoretic Analysis")
    print("=" * 70)
    
    B = 50
    prime_counts = defaultdict(int)
    total_primitive = 0
    
    for a in range(1, B + 1):
        for b in range(1, B + 1):
            if math.gcd(a, b) != 1:
                continue
            total_primitive += 1
            v = abs(diagonal_cubic(a, b))
            if v == 0:
                continue
            
            # Factor v and count prime factors
            temp = v
            for p in range(2, min(1000, v + 1)):
                if p * p > temp:
                    break
                while temp % p == 0:
                    prime_counts[p] += 1
                    temp //= p
            if temp > 1:
                prime_counts[temp] += 1
    
    print(f"\n  Primitive pairs analyzed: {total_primitive}")
    print(f"\n  Prime divisor frequency (top 15):")
    print(f"  {'Prime':>6s}  {'Count':>6s}  {'Freq':>8s}")
    for p, count in sorted(prime_counts.items(), key=lambda x: -x[1])[:15]:
        print(f"  {p:6d}  {count:6d}  {count/total_primitive:8.4f}")
    
    # Check: all values divisible by 3
    print(f"\n  Note: 3 always divides F(a,b) (proved formally).")
    
    # Residue classes modulo small primes
    print(f"\n  Value distribution mod small primes (B={B}):")
    values = set()
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            v = diagonal_cubic(a, b)
            if v != 0:
                values.add(v)
    
    for p in [2, 3, 5, 7, 9]:
        residues = defaultdict(int)
        for v in values:
            residues[v % p] += 1
        print(f"  mod {p}: {dict(sorted(residues.items()))}")


# ───────────────────────────────────────────────────────────
# Application 4: Representation Multiplicity
# ───────────────────────────────────────────────────────────

def multiplicity_analysis():
    """
    Study how many essentially different representations each
    value admits.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Representation Multiplicity")
    print("=" * 70)
    
    B = 30
    witnesses = defaultdict(set)
    
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            k = diagonal_cubic(a, b)
            if k == 0:
                continue
            # Canonical orbit representative
            c = -a - b
            orbit = [(a, b), (b, a), (c, a), (a, c), (b, c), (c, b)]
            rep = min(orbit)
            witnesses[k].add(rep)
    
    # Distribution of multiplicity
    mult_dist = defaultdict(int)
    for k, reps in witnesses.items():
        mult_dist[len(reps)] += 1
    
    print(f"\n  Multiplicity distribution (B={B}):")
    print(f"  {'#orbits':>8s}  {'#values':>8s}")
    for m in sorted(mult_dist.keys()):
        print(f"  {m:8d}  {mult_dist[m]:8d}")
    
    # Show some highly represented values
    print(f"\n  Values with most orbit-distinct representations:")
    top = sorted(witnesses.items(), key=lambda x: -len(x[1]))[:5]
    for k, reps in top:
        print(f"  k={k:8d}: {len(reps)} orbits, e.g. {list(reps)[:3]}")


def main():
    compare_search_strategies()
    density_test()
    sieve_analysis()
    multiplicity_analysis()
    
    print("\n" + "=" * 70)
    print("All applications complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of the diagonal collapse family
for the three-cubes problem.

Enumerates values of F(a,b) = -3ab(a+b) and studies coverage, symmetry orbits,
repeated representations, and primitive pairs.
"""

import math
from collections import defaultdict
from typing import Optional

# ───────────────────────────────────────────────────────────
# Core function: the binary cubic form
# ───────────────────────────────────────────────────────────

def diagonal_cubic(a: int, b: int) -> int:
    """Compute F(a,b) = -3ab(a+b)."""
    return -3 * a * b * (a + b)

def diagonal_triple(a: int, b: int) -> tuple[int, int, int]:
    """Return the triple (a, b, -a-b) on the cubic surface."""
    return (a, b, -a - b)

def verify_triple(x: int, y: int, z: int, k: int) -> bool:
    """Verify that x³ + y³ + z³ = k."""
    return x**3 + y**3 + z**3 == k

# ───────────────────────────────────────────────────────────
# Enumeration
# ───────────────────────────────────────────────────────────

def enumerate_diagonal_values(B: int) -> set[int]:
    """
    Enumerate all values of F(a,b) = -3ab(a+b) for |a|, |b| <= B.
    Returns the set of distinct values.
    """
    values = set()
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            values.add(diagonal_cubic(a, b))
    return values

def enumerate_with_witnesses(B: int) -> dict[int, list[tuple[int, int]]]:
    """
    Enumerate all values with their parameter witnesses.
    Returns dict: k -> [(a, b), ...].
    """
    witnesses = defaultdict(list)
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            k = diagonal_cubic(a, b)
            witnesses[k].append((a, b))
    return dict(witnesses)

# ───────────────────────────────────────────────────────────
# Coverage analysis
# ───────────────────────────────────────────────────────────

def coverage_in_range(B: int, N: int) -> dict:
    """
    Measure coverage of [1, N] by values of F(a,b) for |a|, |b| <= B.
    Returns statistics dict.
    """
    values = enumerate_diagonal_values(B)
    positive_values = {v for v in values if 0 < v <= N}
    count = len(positive_values)
    
    # Compare with N^(2/3) heuristic
    n_two_thirds = N ** (2/3)
    ratio = count / n_two_thirds if n_two_thirds > 0 else 0
    
    return {
        'B': B,
        'N': N,
        'count_in_range': count,
        'N_two_thirds': n_two_thirds,
        'ratio': ratio,
        'total_distinct': len(values),
    }

# ───────────────────────────────────────────────────────────
# S₃ symmetry orbits
# ───────────────────────────────────────────────────────────

def s3_orbit(a: int, b: int) -> set[tuple[int, int]]:
    """
    Compute the S₃ orbit of (a, b) under the symmetry group
    generated by permutations of {a, b, -a-b}.
    """
    c = -a - b
    return {
        (a, b), (b, a),
        (c, a), (a, c),
        (b, c), (c, b),
    }

def group_by_orbits(B: int) -> dict[int, list[set[tuple[int, int]]]]:
    """
    Group parameter pairs into S₃ orbits for |a|, |b| <= B.
    Returns dict: k -> [orbit1, orbit2, ...].
    """
    seen = set()
    orbits_by_value = defaultdict(list)
    
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            if (a, b) in seen:
                continue
            orbit = s3_orbit(a, b)
            seen.update(orbit)
            k = diagonal_cubic(a, b)
            orbits_by_value[k].append(orbit)
    
    return dict(orbits_by_value)

# ───────────────────────────────────────────────────────────
# Primitive pairs analysis
# ───────────────────────────────────────────────────────────

def is_primitive(a: int, b: int) -> bool:
    """Check if gcd(a, b) = 1 (primitive pair)."""
    return math.gcd(abs(a), abs(b)) == 1

def primitive_values(B: int) -> set[int]:
    """
    Enumerate values from primitive pairs only.
    """
    values = set()
    for a in range(-B, B + 1):
        for b in range(-B, B + 1):
            if is_primitive(a, b):
                values.add(diagonal_cubic(a, b))
    return values

# ───────────────────────────────────────────────────────────
# Repeated representations
# ───────────────────────────────────────────────────────────

def find_repeated_representations(B: int, min_reps: int = 2) -> dict[int, list[tuple[int, int]]]:
    """
    Find values with multiple essentially different representations.
    Filters to representations that are not S₃-related.
    """
    witnesses = enumerate_with_witnesses(B)
    repeated = {}
    
    for k, pairs in witnesses.items():
        if k == 0:
            continue
        # Group by orbits
        seen = set()
        distinct_orbits = []
        for (a, b) in pairs:
            if (a, b) not in seen:
                orbit = s3_orbit(a, b)
                seen.update(orbit)
                distinct_orbits.append((a, b))
        
        if len(distinct_orbits) >= min_reps:
            repeated[k] = distinct_orbits
    
    return repeated

# ───────────────────────────────────────────────────────────
# Main demonstration
# ───────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("PARAMETRIC FAMILIES ON CUBIC SURFACES")
    print("The Diagonal Collapse Family: F(a,b) = -3ab(a+b)")
    print("=" * 70)
    
    # Demo 1: Basic identity verification
    print("\n📐 Demo 1: Verifying the fundamental identity")
    print("-" * 50)
    for (a, b) in [(1, 2), (3, -1), (-2, 5), (7, 11)]:
        x, y, z = diagonal_triple(a, b)
        k = diagonal_cubic(a, b)
        check = verify_triple(x, y, z, k)
        print(f"  a={a:3d}, b={b:3d} → ({x}, {y}, {z}), "
              f"k={k:6d}, x³+y³+z³=k? {check}")
    
    # Demo 2: S₃ symmetry
    print("\n🔄 Demo 2: S₃ Symmetry verification")
    print("-" * 50)
    a, b = 3, 5
    c = -a - b
    print(f"  F({a},{b})    = {diagonal_cubic(a, b)}")
    print(f"  F({b},{a})    = {diagonal_cubic(b, a)}")
    print(f"  F({c},{a})  = {diagonal_cubic(c, a)}")
    print(f"  F({a},{c})  = {diagonal_cubic(a, c)}")
    print(f"  F({b},{c})  = {diagonal_cubic(b, c)}")
    print(f"  F({c},{b})  = {diagonal_cubic(c, b)}")
    print(f"  All equal? {len({diagonal_cubic(a,b), diagonal_cubic(b,a), diagonal_cubic(c,a), diagonal_cubic(a,c), diagonal_cubic(b,c), diagonal_cubic(c,b)}) == 1}")
    
    # Demo 3: Coverage analysis
    print("\n📊 Demo 3: Coverage of [1, N] — density analysis")
    print("-" * 50)
    print(f"  {'B':>5s}  {'N':>8s}  {'V(N)':>6s}  {'N^(2/3)':>8s}  {'Ratio':>8s}")
    for B in [50, 100, 200, 500]:
        N = 3 * B * B * (2 * B)  # rough max value
        if N > 10**7:
            N = 10**7
        stats = coverage_in_range(B, N)
        print(f"  {B:5d}  {N:8d}  {stats['count_in_range']:6d}  "
              f"{stats['N_two_thirds']:8.1f}  {stats['ratio']:8.4f}")
    
    # Demo 4: Primitive pairs
    print("\n🔢 Demo 4: Primitive vs all pairs")
    print("-" * 50)
    for B in [10, 20, 50]:
        all_vals = enumerate_diagonal_values(B)
        prim_vals = primitive_values(B)
        all_nonzero = {v for v in all_vals if v != 0}
        prim_nonzero = {v for v in prim_vals if v != 0}
        print(f"  B={B:3d}: all={len(all_nonzero):5d}, "
              f"primitive={len(prim_nonzero):5d}, "
              f"ratio={len(prim_nonzero)/max(len(all_nonzero),1):.3f}")
    
    # Demo 5: Repeated representations
    print("\n🔁 Demo 5: Values with multiple orbit-distinct representations (B=30)")
    print("-" * 50)
    repeated = find_repeated_representations(30, min_reps=2)
    # Show top 10 by number of orbits
    top = sorted(repeated.items(), key=lambda x: -len(x[1]))[:10]
    for k, orbits in top:
        print(f"  k={k:6d}: {len(orbits)} distinct orbits, "
              f"e.g. {orbits[:3]}")
    
    # Demo 6: Divisibility by 3
    print("\n➗ Demo 6: Every value is divisible by 3")
    print("-" * 50)
    vals = enumerate_diagonal_values(50)
    non_div3 = [v for v in vals if v != 0 and v % 3 != 0]
    print(f"  Out of {len(vals)} values, non-divisible-by-3: {len(non_div3)}")
    
    # Demo 7: Monotonicity check
    print("\n📈 Demo 7: Monotonicity of b ↦ 3ab(a+b) for a=1, b>0")
    print("-" * 50)
    a = 1
    prev = None
    for b in range(1, 11):
        val = 3 * a * b * (a + b)
        arrow = ""
        if prev is not None:
            arrow = " ↑" if val > prev else " ↓"
        print(f"  b={b:2d}: 3·{a}·{b}·{a+b} = {val:5d}{arrow}")
        prev = val
    
    # Demo 8: Hyperplane section connection
    print("\n🔗 Demo 8: Factorization identity x³+y³+z³-3xyz = (x+y+z)(x²+y²+z²-xy-yz-zx)")
    print("-" * 50)
    for (x, y, z) in [(2, 3, 5), (1, -1, 0), (3, 4, -7)]:
        lhs = x**3 + y**3 + z**3 - 3*x*y*z
        rhs = (x+y+z) * (x**2 + y**2 + z**2 - x*y - y*z - z*x)
        print(f"  ({x},{y},{z}): LHS={lhs}, RHS={rhs}, equal? {lhs==rhs}")
    # Hyperplane section x+y+z=0
    for (a, b) in [(2, 3), (1, 7), (-3, 5)]:
        z = -a - b
        cubes = a**3 + b**3 + z**3
        prod = 3 * a * b * z
        print(f"  x+y+z=0: ({a},{b},{z}): x³+y³+z³={cubes}, 3xyz={prod}, equal? {cubes==prod}")
    
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)

if __name__ == "__main__":
    main()

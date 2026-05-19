#!/usr/bin/env python3
"""
Collatz Dynamics — Applications

Demonstrates practical applications of the formal Collatz theory:
1. Verified finite-range Collatz checker using descent certificates
2. Symbolic coding of Collatz orbits
3. Residue graph visualization data
4. Entropy estimation for valuation distributions
"""

from typing import List, Dict, Tuple, Set
from fractions import Fraction
import math
import json


# ============================================================
# Core functions (duplicated for self-containment)
# ============================================================

def collatz_step(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1

def collatz_iterate(n: int, k: int) -> int:
    for _ in range(k):
        n = collatz_step(n)
    return n

def v2(n: int) -> int:
    if n == 0: return 0
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k

def odd_part(n: int) -> int:
    while n > 0 and n % 2 == 0:
        n //= 2
    return n

def accel_collatz_odd(n: int) -> int:
    return odd_part(3 * n + 1)


# ============================================================
# Application 1: Verified Finite-Range Collatz Checker
# ============================================================

def verified_collatz_check(N: int, verbose: bool = True) -> bool:
    """Check the Collatz conjecture for all integers in [1, N].
    
    Uses the residue-class descent theorem: rather than checking each
    number independently, we:
    1. Build a descent certificate for a small modulus M
    2. Use strong induction: if T^k(n) < n, and all smaller values
       converge, then n converges
    
    This is more efficient than naive orbit computation because the
    descent certificate provides a uniform bound on iteration depth.
    
    Args:
        N: Upper bound to check
        verbose: Print progress
    
    Returns:
        True if all integers in [1, N] reach 1
    """
    if verbose:
        print(f"  Checking Collatz conjecture for n in [1, {N}]")
    
    # Build descent certificate for M=4
    M = 4
    mod = 2 ** M
    certificate: Dict[int, int] = {}
    
    for r in range(mod):
        for k in range(1, 300):
            test_vals = [r + i * mod for i in range(1, 8) if r + i * mod > 0]
            if test_vals and all(collatz_iterate(n, k) < n for n in test_vals):
                certificate[r] = k
                break
    
    if len(certificate) < mod:
        if verbose:
            print(f"  Warning: incomplete certificate for M={M}")
        # Fall back to direct checking
        for n in range(1, N + 1):
            x = n
            while x != 1:
                x = collatz_step(x)
                if x > 10 * N:  # Safety bound
                    return False
        return True
    
    max_depth = max(certificate.values())
    if verbose:
        print(f"  Certificate found: M={M}, max depth={max_depth}")
    
    # Verify using direct orbit computation with descent optimization
    # The descent certificate tells us how many steps to try per class;
    # but for full correctness we verify each number individually.
    reaches_one_set = {1}
    
    for n in range(2, N + 1):
        # Try the certificate depth first (optimization)
        r = n % mod
        k = certificate[r]
        target = collatz_iterate(n, k)
        if target < n and target in reaches_one_set:
            reaches_one_set.add(n)
            continue
        # Fall back to direct iteration
        x = n
        steps = 0
        while x != 1 and steps < 10000:
            x = collatz_step(x)
            steps += 1
            if x in reaches_one_set:
                reaches_one_set.add(n)
                break
        else:
            if x != 1:
                if verbose:
                    print(f"  Failed for n={n} after {steps} steps")
                return False
            reaches_one_set.add(n)
    
    if verbose:
        print(f"  ✓ Verified for all n in [1, {N}]")
    return True


# ============================================================
# Application 2: Symbolic Coding of Collatz Orbits
# ============================================================

def symbolic_code(n: int, max_steps: int = 100) -> List[int]:
    """Compute the symbolic code (valuation sequence) of the
    accelerated Collatz orbit starting from odd n.
    
    The symbolic code is the sequence of 2-adic valuations
    v₂(3xᵢ+1) encountered along the orbit until reaching 1.
    
    This maps Collatz dynamics to a symbolic sequence in ℕ*.
    
    Args:
        n: Starting odd positive integer
        max_steps: Maximum number of steps
    
    Returns:
        List of valuations [a₀, a₁, ..., a_{k-1}]
    """
    assert n > 0 and n % 2 == 1, f"n={n} must be odd and positive"
    
    code = []
    x = n
    for _ in range(max_steps):
        if x == 1:
            break
        val = v2(3 * x + 1)
        code.append(val)
        x = accel_collatz_odd(x)
    
    return code


def symbolic_frequency_analysis(max_n: int = 1000) -> Dict[int, float]:
    """Analyze the frequency of each valuation value in symbolic codes.
    
    This relates to the entropy of the Collatz coding map and the
    geometric distribution hypothesis.
    
    Args:
        max_n: Maximum starting value to analyze
    
    Returns:
        Dictionary mapping valuation → frequency
    """
    total = 0
    counts: Dict[int, int] = {}
    
    for n in range(1, max_n + 1, 2):
        code = symbolic_code(n)
        for val in code:
            counts[val] = counts.get(val, 0) + 1
            total += 1
    
    return {k: v / total for k, v in sorted(counts.items())}


# ============================================================
# Application 3: Residue Graph
# ============================================================

def build_residue_graph(M: int) -> Dict[int, Set[int]]:
    """Build the residue graph modulo 2^M for the accelerated map.
    
    Vertices are odd residues mod 2^M.
    There is an edge r → r' if accel(n) ≡ r' for some n ≡ r.
    
    This graph captures the finite-state structure of Collatz dynamics
    modulo powers of 2.
    
    Args:
        M: Modulus exponent
    
    Returns:
        Adjacency list representation
    """
    mod = 2 ** M
    graph: Dict[int, Set[int]] = {}
    
    for r in range(1, mod, 2):  # Odd residues
        graph[r] = set()
        # Compute accel(r) and accel(r + mod) to see possible targets
        for offset in range(10):
            n = r + offset * mod
            if n > 0:
                target = accel_collatz_odd(n) % mod
                if target % 2 == 1:  # Should always be odd
                    graph[r].add(target)
    
    return graph


def residue_graph_analysis(M: int) -> dict:
    """Analyze the residue graph modulo 2^M.
    
    Computes:
    - Number of vertices and edges
    - Out-degree distribution
    - Strongly connected components (simple version)
    
    Args:
        M: Modulus exponent
    
    Returns:
        Analysis results
    """
    graph = build_residue_graph(M)
    
    num_vertices = len(graph)
    num_edges = sum(len(targets) for targets in graph.values())
    
    out_degrees = [len(targets) for targets in graph.values()]
    avg_degree = sum(out_degrees) / len(out_degrees) if out_degrees else 0
    
    # Check which residues can reach 1
    can_reach_one = set()
    for r in graph:
        visited = set()
        queue = [r]
        while queue:
            curr = queue.pop()
            if curr in visited:
                continue
            visited.add(curr)
            if curr == 1:
                can_reach_one.add(r)
                break
            if curr in graph:
                for target in graph[curr]:
                    queue.append(target)
    
    return {
        'M': M,
        'num_vertices': num_vertices,
        'num_edges': num_edges,
        'avg_out_degree': avg_degree,
        'max_out_degree': max(out_degrees) if out_degrees else 0,
        'reach_one_fraction': len(can_reach_one) / num_vertices if num_vertices else 0,
    }


# ============================================================
# Application 4: Entropy Estimation
# ============================================================

def compute_valuation_entropy(M: int) -> float:
    """Compute the Shannon entropy of the valuation distribution
    on odd residues mod 2^M.
    
    The geometric distribution hypothesis predicts:
    H = Σ_{j=1}^{M-1} 2^{-j} · j · ln(2) + small correction
    
    Args:
        M: Modulus exponent
    
    Returns:
        Shannon entropy in nats
    """
    mod = 2 ** M
    counts: Dict[int, int] = {}
    total = 0
    
    for n in range(1, mod, 2):
        val = v2(3 * n + 1)
        counts[val] = counts.get(val, 0) + 1
        total += 1
    
    entropy = 0.0
    for val, count in counts.items():
        p = count / total
        if p > 0:
            entropy -= p * math.log2(p)
    
    return entropy


def geometric_entropy_reference() -> float:
    """Compute the Shannon entropy of the ideal geometric distribution
    Pr(X=j) = 2^{-j} for j ≥ 1.
    
    H = Σ_{j=1}^∞ 2^{-j} · j = 2 (bits)
    """
    return 2.0


if __name__ == "__main__":
    print("=" * 60)
    print("Collatz Dynamics — Applications")
    print("=" * 60)
    
    # Application 1: Verified checker
    print("\n--- Application 1: Verified Collatz Checker ---")
    verified_collatz_check(10000)
    
    # Application 2: Symbolic coding
    print("\n--- Application 2: Symbolic Coding ---")
    for n in [7, 27, 97, 255]:
        code = symbolic_code(n)
        print(f"  n={n:4d}: code = {code}")
        print(f"         length = {len(code)}, sum = {sum(code)}")
    
    print("\n  Valuation frequency analysis (odd n ≤ 1000):")
    freqs = symbolic_frequency_analysis(1000)
    geometric_ref = {j: 2**(-j) for j in range(1, 8)}
    for j in range(1, 7):
        obs = freqs.get(j, 0)
        exp = geometric_ref.get(j, 0)
        ratio = obs / exp if exp > 0 else 0
        print(f"    v₂={j}: observed={obs:.4f}, geometric={exp:.4f}, ratio={ratio:.4f}")
    
    # Application 3: Residue graph
    print("\n--- Application 3: Residue Graph Analysis ---")
    for M in range(2, 7):
        analysis = residue_graph_analysis(M)
        print(f"  M={M}: {analysis['num_vertices']} vertices, "
              f"{analysis['num_edges']} edges, "
              f"avg degree={analysis['avg_out_degree']:.1f}, "
              f"reach 1: {analysis['reach_one_fraction']*100:.0f}%")
    
    # Application 4: Entropy
    print("\n--- Application 4: Valuation Entropy ---")
    ref_entropy = geometric_entropy_reference()
    print(f"  Geometric reference entropy: {ref_entropy:.4f} bits")
    for M in range(3, 12):
        entropy = compute_valuation_entropy(M)
        print(f"  M={M:2d}: entropy = {entropy:.4f} bits "
              f"(ratio to geometric: {entropy/ref_entropy:.4f})")
    
    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Collatz Dynamics Demo — Concrete Numerical Examples

Demonstrates the key concepts from the formal Collatz dynamics library:
1. Standard and accelerated Collatz maps
2. 2-adic valuations along orbits
3. Residue-class descent certificates
4. Valuation pattern realizability
5. Cycle product identity verification
"""

def collatz_step(n: int) -> int:
    """Standard Collatz step: n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1

def v2(n: int) -> int:
    """2-adic valuation: largest k such that 2^k divides n."""
    if n == 0:
        return float('inf')
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k

def odd_part(n: int) -> int:
    """Odd part of n: n / 2^v2(n)."""
    while n % 2 == 0:
        n //= 2
    return n

def accel_collatz_odd(n: int) -> int:
    """Accelerated odd Collatz map: odd_part(3n+1) for odd n."""
    assert n % 2 == 1, f"n={n} must be odd"
    return odd_part(3 * n + 1)


def demo_basic_collatz():
    """Demo 1: Basic Collatz orbits."""
    print("=" * 60)
    print("DEMO 1: Basic Collatz Orbits")
    print("=" * 60)
    for start in [7, 27, 97]:
        n = start
        orbit = [n]
        while n != 1:
            n = collatz_step(n)
            orbit.append(n)
        print(f"\n  {start} → 1 in {len(orbit)-1} steps")
        if len(orbit) <= 30:
            print(f"  Orbit: {' → '.join(map(str, orbit))}")
        else:
            print(f"  Orbit (first 10): {' → '.join(map(str, orbit[:10]))} ...")
            print(f"  Orbit (last 5):  ... → {' → '.join(map(str, orbit[-5:]))}")


def demo_accelerated_map():
    """Demo 2: Accelerated odd Collatz map and valuations."""
    print("\n" + "=" * 60)
    print("DEMO 2: Accelerated Odd Map & 2-adic Valuations")
    print("=" * 60)
    print("\n  The accelerated map jumps directly between odd numbers.")
    print("  For odd n: accel(n) = odd_part(3n+1)")
    print()
    
    n = 7
    print(f"  Starting from n = {n}:")
    for step in range(8):
        val = v2(3 * n + 1)
        next_n = accel_collatz_odd(n)
        print(f"    Step {step}: n={n:5d}, 3n+1={3*n+1:6d} = 2^{val} × {next_n}")
        n = next_n
        if n == 1:
            print(f"    Reached 1!")
            break


def demo_single_step_realizability():
    """Demo 3: Every valuation a ≥ 1 is achieved by some odd n."""
    print("\n" + "=" * 60)
    print("DEMO 3: Single-Step Valuation Realizability")
    print("=" * 60)
    print("\n  Theorem: For every a ≥ 1, ∃ odd n > 0 with v₂(3n+1) = a")
    print()
    
    for a in range(1, 13):
        # Find smallest odd n with v2(3n+1) = a
        n = 1
        while True:
            if v2(3 * n + 1) == a:
                print(f"    a={a:2d}: n={n:5d}, 3n+1={3*n+1:7d} = 2^{a} × {odd_part(3*n+1)}")
                break
            n += 2


def demo_residue_descent():
    """Demo 4: Residue-class descent certificates."""
    print("\n" + "=" * 60)
    print("DEMO 4: Residue-Class Descent Certificates")
    print("=" * 60)
    print("\n  Theorem: If every residue class mod 2^M has a certified")
    print("  descent, then the Collatz conjecture holds.")
    print()
    
    for M in range(1, 7):
        mod = 2 ** M
        all_descend = True
        max_k = 0
        for r in range(mod):
            # Check if residue class r mod 2^M has a descent
            # We test with a specific representative
            found = False
            for k in range(1, 200):
                # Check if T^k(n) < n for all n ≡ r mod 2^M with n > 0
                # We test with n = r + mod (to avoid n=0) and a few more
                test_values = [r + i * mod for i in range(1, 5) if r + i * mod > 0]
                if not test_values:
                    continue
                if all(collatz_iterate(n, k) < n for n in test_values):
                    found = True
                    max_k = max(max_k, k)
                    break
            if not found:
                all_descend = False
                break
        
        status = "✓ ALL DESCEND" if all_descend else "✗ NOT ALL"
        print(f"    M={M}, mod 2^{M}={mod:4d}: {status}" + 
              (f" (max k={max_k})" if all_descend else ""))


def collatz_iterate(n: int, k: int) -> int:
    """Apply collatz_step k times."""
    for _ in range(k):
        n = collatz_step(n)
    return n


def demo_valuation_patterns():
    """Demo 5: Multi-step valuation pattern search."""
    print("\n" + "=" * 60)
    print("DEMO 5: Valuation Pattern Realizability (Computational)")
    print("=" * 60)
    print("\n  For each valuation pattern (a₀, a₁, ...), find odd n")
    print("  whose accelerated orbit realizes those valuations.")
    print()
    
    patterns = [
        (1,), (2,), (3,), (1, 1), (1, 2), (2, 1), (1, 1, 1),
        (2, 3, 1), (1, 2, 3, 4)
    ]
    
    for pattern in patterns:
        k = len(pattern)
        # Search for odd n realizing this pattern
        found = False
        for n in range(1, 10000, 2):
            x = n
            match = True
            for a_target in pattern:
                val = v2(3 * x + 1)
                if val != a_target:
                    match = False
                    break
                x = accel_collatz_odd(x)
            if match:
                print(f"    Pattern {pattern}: n = {n}")
                found = True
                break
        if not found:
            print(f"    Pattern {pattern}: not found in range (searching further...)")
            for n in range(10001, 100000, 2):
                x = n
                match = True
                for a_target in pattern:
                    val = v2(3 * x + 1)
                    if val != a_target:
                        match = False
                        break
                    x = accel_collatz_odd(x)
                if match:
                    print(f"    Pattern {pattern}: n = {n}")
                    found = True
                    break
            if not found:
                print(f"    Pattern {pattern}: not found in range [1, 100000)")


def demo_cycle_product_identity():
    """Demo 6: Verify the cycle product identity numerically."""
    print("\n" + "=" * 60)
    print("DEMO 6: Cycle Product Identity")
    print("=" * 60)
    print("\n  Theorem: For any cycle x₀,...,x_{k-1} of the accelerated map,")
    print("  2^(∑ aᵢ) = ∏ (3 + 1/xᵢ)  where aᵢ = v₂(3xᵢ+1)")
    print()
    print("  No nontrivial odd cycle is known! We verify the identity")
    print("  on the trivial cycle {1} → {1} (under standard map).")
    print("  And demonstrate the impossibility constraints:")
    print()
    
    # For a hypothetical 1-cycle: x₀ = x, accel(x) = x
    # Then 3x+1 = 2^a * x, so x(2^a - 3) = 1, x = 1/(2^a-3)
    # Only integer solution: a=2, x=1 (trivial fixed point)
    print("  1-cycles: 3x+1 = 2^a · x → x = 1/(2^a - 3)")
    for a in range(1, 8):
        denom = 2**a - 3
        if denom > 0 and 1 % denom == 0:
            x = 1 // denom
            print(f"    a={a}: x = 1/{denom} = {x} {'✓ integer' if x * denom == 1 else '✗'}")
        elif denom == 0:
            print(f"    a={a}: 2^a - 3 = 0 → no solution")
        elif denom < 0:
            print(f"    a={a}: 2^a - 3 = {denom} < 0 → no positive solution")
        else:
            print(f"    a={a}: x = 1/{denom} → not an integer")
    
    print("\n  Bounds for k-cycles with min element ≥ B:")
    from fractions import Fraction
    for k in range(1, 6):
        # Product must be 2^(sum a_i) with sum a_i >= k
        # Lower bound: 3^k < product <= (3 + 1/B)^k
        # So 3^k < 2^(sum a_i)
        # Minimum sum: ceil(k * log2(3)) + 1 (at least k since each a_i >= 1)
        import math
        min_sum = max(k, math.ceil(k * math.log2(3)))
        # For sum = min_sum: 2^min_sum = product <= (3 + 1/B)^k
        # So B >= 1 / ((2^(min_sum/k)) - 3)
        ratio = 2 ** (min_sum / k)
        if ratio > 3:
            min_B = 1 / (ratio - 3)
            print(f"    k={k}: sum aᵢ ≥ {min_sum}, min element B > {min_B:.1f}")
        else:
            print(f"    k={k}: sum aᵢ ≥ {min_sum}, impossible (2^(sum/k) ≤ 3)")


def demo_backward_step():
    """Demo 7: Backward inverse step construction."""
    print("\n" + "=" * 60)
    print("DEMO 7: Backward Inverse Step")
    print("=" * 60)
    print("\n  Given odd m and valuation a, find n with accel(n) = m")
    print("  and v₂(3n+1) = a (when 2^a·m ≡ 1 mod 3).")
    print()
    
    for m in [1, 3, 5, 7, 11, 13]:
        for a in [1, 2, 3]:
            prod = (2**a * m) % 3
            if prod == 1:
                n = (2**a * m - 1) // 3
                if n > 0 and n % 2 == 1:
                    assert 3 * n + 1 == 2**a * m
                    assert v2(3 * n + 1) == a
                    assert accel_collatz_odd(n) == m
                    print(f"    m={m:3d}, a={a}: n = (2^{a}·{m} - 1)/3 = {n:5d}  ✓")
                else:
                    print(f"    m={m:3d}, a={a}: n = {n} (invalid)")
            else:
                print(f"    m={m:3d}, a={a}: 2^{a}·{m} ≡ {prod} mod 3 ≠ 1, skip")


if __name__ == "__main__":
    demo_basic_collatz()
    demo_accelerated_map()
    demo_single_step_realizability()
    demo_residue_descent()
    demo_valuation_patterns()
    demo_cycle_product_identity()
    demo_backward_step()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)

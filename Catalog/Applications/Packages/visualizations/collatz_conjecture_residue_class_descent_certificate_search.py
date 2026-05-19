#!/usr/bin/env python3
"""
Collatz Dynamics — Algorithms

Implements the core algorithms from the formal Collatz dynamics library:
1. Residue-class descent certificate search
2. Valuation pattern search and enumeration
3. Cycle obstruction analysis
4. Backward orbit construction
"""

from typing import Optional, Tuple, List, Dict
from fractions import Fraction
import math


# ============================================================
# Core Functions
# ============================================================

def collatz_step(n: int) -> int:
    """Standard Collatz step: n/2 if even, 3n+1 if odd.
    
    Time complexity: O(1)
    """
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_iterate(n: int, k: int) -> int:
    """Apply collatz_step k times.
    
    Time complexity: O(k)
    """
    for _ in range(k):
        n = collatz_step(n)
    return n


def v2(n: int) -> int:
    """2-adic valuation: largest k such that 2^k divides n.
    
    Returns 0 for n=0 (convention).
    Time complexity: O(log n)
    """
    if n == 0:
        return 0
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k


def odd_part(n: int) -> int:
    """Odd part of n: n / 2^v2(n).
    
    Time complexity: O(log n)
    """
    while n > 0 and n % 2 == 0:
        n //= 2
    return n


def accel_collatz_odd(n: int) -> int:
    """Accelerated odd Collatz map: odd_part(3n+1).
    
    Precondition: n is odd and positive.
    Time complexity: O(log n)
    """
    return odd_part(3 * n + 1)


# ============================================================
# Algorithm 1: Residue-Class Descent Certificate Search
# ============================================================

def find_descent_certificate(M: int, max_k: int = 500) -> Optional[Dict[int, int]]:
    """Search for a residue-class descent certificate modulo 2^M.
    
    For each residue r mod 2^M, finds the smallest k such that
    T^k(n) < n for all n ≡ r (mod 2^M) with n > 0.
    
    We test this on representative values n = r + i·2^M for small i.
    
    Args:
        M: The modulus exponent (certificate is mod 2^M)
        max_k: Maximum number of iterations to try
    
    Returns:
        Dictionary mapping residue r → descent depth k,
        or None if no certificate found.
    
    Time complexity: O(2^M · max_k · num_tests)
    
    Pseudocode:
        for each r in [0, 2^M):
            for k in [1, max_k]:
                if T^k(r + 2^M) < r + 2^M and T^k(r + 2·2^M) < r + 2·2^M:
                    record k for r; break
            else: return FAIL
        return certificate
    """
    mod = 2 ** M
    certificate = {}
    
    for r in range(mod):
        found = False
        for k in range(1, max_k + 1):
            # Test on several representatives
            test_vals = [r + i * mod for i in range(1, 6) if r + i * mod > 0]
            if not test_vals:
                continue
            if all(collatz_iterate(n, k) < n for n in test_vals):
                certificate[r] = k
                found = True
                break
        if not found:
            return None
    
    return certificate


def verify_descent_certificate(certificate: Dict[int, int], M: int, 
                                num_tests: int = 10) -> bool:
    """Verify a descent certificate by testing more representatives.
    
    Args:
        certificate: Dictionary mapping residue → descent depth
        M: Modulus exponent
        num_tests: Number of additional representatives to test per class
    
    Returns:
        True if all tests pass.
    """
    mod = 2 ** M
    for r, k in certificate.items():
        for i in range(1, num_tests + 1):
            n = r + i * mod
            if n > 0 and collatz_iterate(n, k) >= n:
                return False
    return True


# ============================================================
# Algorithm 2: Valuation Pattern Search
# ============================================================

def find_valuation_pattern_witness(pattern: Tuple[int, ...], 
                                    max_search: int = 100000) -> Optional[int]:
    """Find the smallest odd positive integer whose accelerated orbit
    realizes the given valuation pattern.
    
    Args:
        pattern: Tuple (a₀, a₁, ..., a_{k-1}) of target valuations
        max_search: Maximum value to search
    
    Returns:
        The smallest odd n realizing the pattern, or None.
    
    Time complexity: O(max_search · len(pattern))
    
    Pseudocode:
        for n = 1, 3, 5, ...:
            x = n
            match = True
            for a in pattern:
                if v₂(3x+1) ≠ a: match = False; break
                x = accel(x)
            if match: return n
        return None
    """
    for n in range(1, max_search, 2):
        x = n
        match = True
        for a in pattern:
            if v2(3 * x + 1) != a:
                match = False
                break
            x = accel_collatz_odd(x)
        if match:
            return n
    return None


def enumerate_valuation_patterns(max_length: int, max_val: int, 
                                  max_search: int = 50000) -> Dict[Tuple, int]:
    """Enumerate all valuation patterns up to given length and maximum valuation,
    finding witness integers for each.
    
    Args:
        max_length: Maximum pattern length
        max_val: Maximum valuation value in patterns
        max_search: Search bound for witnesses
    
    Returns:
        Dictionary mapping pattern → witness n
    """
    results = {}
    
    def generate(prefix: Tuple[int, ...]):
        if len(prefix) > 0:
            witness = find_valuation_pattern_witness(prefix, max_search)
            if witness is not None:
                results[prefix] = witness
        if len(prefix) < max_length:
            for a in range(1, max_val + 1):
                generate(prefix + (a,))
    
    generate(())
    return results


# ============================================================
# Algorithm 3: Cycle Obstruction Analysis
# ============================================================

def cycle_minimum_bound(k: int) -> float:
    """Compute the minimum element bound for a hypothetical k-cycle
    of the accelerated odd Collatz map.
    
    Uses the product identity: 2^(∑aᵢ) = ∏(3 + 1/xᵢ)
    with ∑aᵢ ≥ k·log₂(3) (rounded up).
    
    The bound comes from: (3 + 1/B)^k ≥ 2^(∑aᵢ)
    so B ≥ 1/(2^(∑aᵢ/k) - 3)
    
    Args:
        k: Cycle length
    
    Returns:
        Lower bound on the minimum cycle element
    """
    # Minimum possible sum of valuations
    min_sum = max(k, math.ceil(k * math.log2(3)))
    
    # From the product identity
    ratio = 2 ** (min_sum / k)
    if ratio <= 3:
        return float('inf')  # Impossible
    
    return 1.0 / (ratio - 3)


def analyze_cycle_obstruction(k: int, verbose: bool = True) -> dict:
    """Analyze cycle obstruction for length k.
    
    Computes:
    - Minimum sum of valuations
    - Lower bound on minimum element
    - Necessary conditions on the product
    
    Args:
        k: Cycle length
        verbose: Print analysis
    
    Returns:
        Dictionary with analysis results
    """
    min_sum = max(k, math.ceil(k * math.log2(3)))
    min_B = cycle_minimum_bound(k)
    
    # Check all possible sums
    feasible_sums = []
    for s in range(min_sum, min_sum + 10):
        power = 2 ** s
        # The product ∏(3 + 1/xᵢ) must equal exactly 2^s
        # Lower bound: 3^k < 2^s → s > k·log₂(3)
        # Upper bound: need elements small enough that product is large enough
        if 3 ** k < power:
            feasible_sums.append(s)
    
    result = {
        'k': k,
        'min_sum': min_sum,
        'min_element_bound': min_B,
        'feasible_sums': feasible_sums,
        'log2_3': math.log2(3),
    }
    
    if verbose:
        print(f"  k={k}: min ∑aᵢ = {min_sum}, min element > {min_B:.2f}")
        print(f"    Feasible sums: {feasible_sums[:5]}...")
        print(f"    Key ratio: k·log₂(3) = {k * math.log2(3):.4f}")
    
    return result


# ============================================================
# Algorithm 4: Backward Orbit Construction
# ============================================================

def backward_step(m: int, a: int) -> Optional[int]:
    """Construct n such that accel(n) = m with v₂(3n+1) = a.
    
    Requires: m odd, m > 0, a ≥ 1, (2^a · m) ≡ 1 (mod 3).
    Returns: n = (2^a · m - 1) / 3, or None if conditions fail.
    
    Time complexity: O(1)
    """
    if m <= 0 or m % 2 == 0 or a < 1:
        return None
    prod = (2**a) * m
    if prod % 3 != 1:
        return None
    n = (prod - 1) // 3
    if n <= 0 or n % 2 == 0:
        return None
    return n


def construct_backward_orbit(target_pattern: Tuple[int, ...]) -> Optional[List[int]]:
    """Construct an orbit realizing a target valuation pattern by backward steps.
    
    Starting from the last step, works backwards using backward_step.
    May need to adjust intermediate values for mod-3 compatibility.
    
    Args:
        target_pattern: Desired valuation sequence (a₀, ..., a_{k-1})
    
    Returns:
        List of orbit values [x₀, x₁, ..., x_k] or None
    
    Pseudocode:
        Start with x_k = 1 (or any small odd number)
        for i = k-1 down to 0:
            Try x_i = backward_step(x_{i+1}, a_i)
            If fails, try adjusting x_{i+1} by adding 6
        return [x_0, ..., x_k]
    """
    k = len(target_pattern)
    if k == 0:
        return [1]
    
    # Start with a small odd value for the end
    for start in range(1, 1000, 2):
        orbit = [0] * (k + 1)
        orbit[k] = start
        success = True
        
        for i in range(k - 1, -1, -1):
            a = target_pattern[i]
            # Try to find backward step
            x_next = orbit[i + 1]
            
            # Try adjusting x_next by multiples of 6 to satisfy mod-3
            found = False
            for adjust in range(100):
                candidate = x_next + 6 * adjust
                if candidate % 2 == 0:
                    continue
                n = backward_step(candidate, a)
                if n is not None:
                    orbit[i] = n
                    # Update later values if we adjusted
                    if adjust > 0:
                        orbit[i + 1] = candidate
                        # Recompute forward from i+1
                        for j in range(i + 1, k):
                            orbit[j + 1] = accel_collatz_odd(orbit[j])
                    found = True
                    break
            
            if not found:
                success = False
                break
        
        if success:
            # Verify forward
            valid = True
            x = orbit[0]
            for i, a in enumerate(target_pattern):
                if v2(3 * x + 1) != a:
                    valid = False
                    break
                x = accel_collatz_odd(x)
            if valid:
                return orbit
    
    return None


# ============================================================
# Algorithm 5: Valuation Distribution Statistics
# ============================================================

def valuation_distribution(M: int) -> Dict[int, int]:
    """Compute the distribution of v₂(3n+1) over odd residues mod 2^M.
    
    Args:
        M: Modulus exponent
    
    Returns:
        Dictionary mapping valuation → count
    """
    mod = 2 ** M
    counts: Dict[int, int] = {}
    
    for n in range(1, mod, 2):  # Odd residues
        val = v2(3 * n + 1)
        counts[val] = counts.get(val, 0) + 1
    
    return counts


def verify_geometric_distribution(M: int) -> dict:
    """Verify the geometric distribution hypothesis for v₂(3n+1).
    
    Hypothesis: Pr(v₂(3n+1) = j) = 2^{-j} for j ≥ 1.
    
    Args:
        M: Modulus exponent
    
    Returns:
        Dictionary with observed and expected distributions
    """
    dist = valuation_distribution(M)
    total = sum(dist.values())  # Should be 2^(M-1) (number of odd residues)
    
    result = {
        'M': M,
        'total_odd_residues': total,
        'distribution': {},
    }
    
    for j in sorted(dist.keys()):
        observed = dist[j] / total
        expected = 2 ** (-j) if j <= M - 1 else 0
        result['distribution'][j] = {
            'count': dist[j],
            'observed_freq': observed,
            'expected_freq': expected,
            'ratio': observed / expected if expected > 0 else None,
        }
    
    return result


if __name__ == "__main__":
    print("=" * 60)
    print("Collatz Dynamics — Algorithm Tests")
    print("=" * 60)
    
    # Test descent certificate search
    print("\n--- Descent Certificate Search ---")
    for M in range(1, 6):
        cert = find_descent_certificate(M)
        if cert:
            max_depth = max(cert.values())
            print(f"  M={M}: Certificate found (max depth={max_depth})")
        else:
            print(f"  M={M}: No certificate found")
    
    # Test valuation pattern search
    print("\n--- Valuation Pattern Search ---")
    patterns = [(1,), (2,), (1,1), (2,1,3), (1,1,1,1)]
    for p in patterns:
        w = find_valuation_pattern_witness(p)
        print(f"  Pattern {p}: witness n = {w}")
    
    # Test cycle obstruction
    print("\n--- Cycle Obstruction Analysis ---")
    for k in range(1, 8):
        analyze_cycle_obstruction(k)
    
    # Test backward construction
    print("\n--- Backward Orbit Construction ---")
    for pattern in [(1,), (2,), (1,2), (3,1,2)]:
        orbit = construct_backward_orbit(pattern)
        if orbit:
            print(f"  Pattern {pattern}: orbit = {orbit}")
        else:
            print(f"  Pattern {pattern}: construction failed")
    
    # Test valuation distribution
    print("\n--- Valuation Distribution ---")
    for M in range(3, 9):
        result = verify_geometric_distribution(M)
        print(f"  M={M} ({result['total_odd_residues']} odd residues):")
        for j, data in sorted(result['distribution'].items())[:5]:
            ratio_str = f"{data['ratio']:.4f}" if data['ratio'] else "N/A"
            print(f"    v₂={j}: count={data['count']:4d}, "
                  f"freq={data['observed_freq']:.4f}, "
                  f"expected={data['expected_freq']:.4f}, "
                  f"ratio={ratio_str}")

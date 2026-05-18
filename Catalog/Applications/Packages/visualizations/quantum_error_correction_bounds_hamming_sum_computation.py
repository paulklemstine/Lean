#!/usr/bin/env python3
"""
Algorithms for Quantum Stabilizer Code Analysis

Implements the key algorithms from the formal theory:
1. Hamming bound computation and verification
2. Singleton bound analysis
3. Perfect code search (Diophantine solver)
4. Toric code parameter computation
5. Symplectic form computation over F₂
"""

import math
from typing import List, Tuple, Optional, Dict
import itertools


# ============================================================
# Algorithm 1: Hamming Sum & Bound Verification
# ============================================================

def hamming_sum(n: int, t: int) -> int:
    """Compute Σ_{i=0}^{t} 3^i · C(n, i).
    
    Time complexity: O(t · n) for binomial coefficient computation.
    Space complexity: O(1).
    
    Args:
        n: Number of qubits.
        t: Error correction radius.
    
    Returns:
        The Hamming packing sum.
    
    Example:
        >>> hamming_sum(5, 1)
        16
        >>> hamming_sum(7, 1)
        22
    """
    return sum(3**i * math.comb(n, i) for i in range(t + 1))


def verify_hamming_bound(n: int, k: int, d: int) -> Dict:
    """Verify the quantum Hamming bound for given parameters.
    
    For a nondegenerate [[n, k, d]] stabilizer code:
        Σ_{i=0}^{t} 3^i · C(n, i) ≤ 2^{n-k}
    where t = ⌊(d-1)/2⌋.
    
    Time complexity: O(t · n).
    
    Returns:
        Dictionary with bound details and satisfaction status.
    """
    t = (d - 1) // 2
    hs = hamming_sum(n, t)
    ss = 2 ** (n - k)
    
    return {
        "parameters": f"[[{n},{k},{d}]]",
        "correction_radius": t,
        "hamming_sum": hs,
        "syndrome_size": ss,
        "satisfied": hs <= ss,
        "perfect": hs == ss,
        "packing_ratio": hs / ss if ss > 0 else float('inf'),
        "slack": ss - hs,
    }


# ============================================================
# Algorithm 2: Quantum Singleton Bound
# ============================================================

def verify_singleton_bound(n: int, k: int, d: int) -> Dict:
    """Verify the quantum Singleton bound: 2d + k ≤ n + 2.
    
    For any stabilizer code [[n, k, d]], this must hold.
    MDS codes achieve equality: 2d + k = n + 2.
    
    Time complexity: O(1).
    
    Returns:
        Dictionary with bound details.
    """
    lhs = 2 * d + k
    rhs = n + 2
    
    return {
        "parameters": f"[[{n},{k},{d}]]",
        "lhs": lhs,
        "rhs": rhs,
        "satisfied": lhs <= rhs,
        "mds": lhs == rhs,
        "slack": rhs - lhs,
        "max_distance": (n - k + 2) // 2,
        "max_k_for_d": n - 2 * d + 2 if 2 * d <= n + 2 else 0,
    }


# ============================================================
# Algorithm 3: Perfect Code Search
# ============================================================

def find_perfect_codes(d: int, n_max: int = 100, k_min: int = 1) -> List[Tuple[int, int, int]]:
    """Find all perfect quantum codes with distance d up to n_max qubits.
    
    A perfect code satisfies the Hamming bound with equality:
        Σ_{i=0}^{t} 3^i · C(n, i) = 2^{n-k}
    
    For d = 3 (t = 1), this becomes: 1 + 3n = 2^{n-k}.
    
    Algorithm:
        Iterate over possible values of m = n - k (syndrome dimension).
        For each m, compute n = (2^m - 1) / (Σ 3^i terms).
        Check if n is a non-negative integer and k ≥ k_min.
    
    Time complexity: O(n_max · log(n_max)).
    
    Args:
        d: Minimum distance.
        n_max: Maximum number of qubits to search.
        k_min: Minimum number of logical qubits.
    
    Returns:
        List of (n, k, d) tuples for perfect codes.
    
    Example:
        >>> find_perfect_codes(3, 100)
        [(5, 1, 3), (21, 15, 3)]
    """
    t = (d - 1) // 2
    results = []
    
    for m in range(1, n_max + 1):  # m = n - k
        target = 2 ** m
        # Search for n such that hamming_sum(n, t) = target
        for n in range(1, n_max + 1):
            hs = hamming_sum(n, t)
            if hs == target:
                k = n - m
                if k >= k_min and k <= n:
                    results.append((n, k, d))
            elif hs > target:
                break
    
    return results


def find_perfect_codes_d3(n_max: int = 1000) -> List[Tuple[int, int]]:
    """Specialized search for d=3 perfect codes using Diophantine analysis.
    
    Solves 1 + 3n = 2^m where m = n - k.
    
    Key insight: 2^m ≡ 1 (mod 3) requires m to be even.
    So we only check even m values.
    
    Time complexity: O(log(n_max)).
    """
    results = []
    for m in range(2, 100, 2):  # m must be even
        val = 2**m
        n = (val - 1) // 3
        if 1 + 3 * n == val and n <= n_max:
            k = n - m
            if k >= 1:
                results.append((n, k))
    return results


# ============================================================
# Algorithm 4: Toric Code Parameters
# ============================================================

def toric_code_params(L: int) -> Dict:
    """Compute toric code parameters [[2L², 2, L]] and verify bounds.
    
    Time complexity: O(1).
    
    Args:
        L: Linear dimension of the torus (L × L grid).
    
    Returns:
        Dictionary with all parameter details and bound verification.
    """
    n = 2 * L**2
    k = 2
    d = L
    t = (d - 1) // 2
    
    return {
        "L": L,
        "n": n,
        "k": k,
        "d": d,
        "t": t,
        "rate": k / n if n > 0 else 0,
        "distance_sq_over_n": d**2 / n if n > 0 else 0,
        "kd2": k * d**2,
        "kd2_equals_n": k * d**2 == n,
        "singleton_satisfied": 2 * d + k <= n + 2,
        "singleton_slack": (n + 2) - (2 * d + k),
        "hamming_sum": hamming_sum(n, t),
        "syndrome_size": 2 ** (n - k),
        "ground_space_dim": 2**k,
    }


# ============================================================
# Algorithm 5: Symplectic Form over F₂
# ============================================================

def symplectic_inner_product(a: Tuple[List[int], List[int]],
                              b: Tuple[List[int], List[int]]) -> int:
    """Compute symplectic inner product of two binary Pauli vectors.
    
    For a = (x_a, z_a) and b = (x_b, z_b), the symplectic product is:
        ⟨a, b⟩ = Σ_i (x_a[i] · z_b[i] + z_a[i] · x_b[i]) mod 2
    
    Two Pauli operators commute iff their symplectic product is 0.
    
    Time complexity: O(n).
    
    Args:
        a: Pauli vector (x_part, z_part), each a list of 0/1 values.
        b: Pauli vector (x_part, z_part).
    
    Returns:
        0 if the operators commute, 1 if they anticommute.
    """
    n = len(a[0])
    assert len(a[1]) == n and len(b[0]) == n and len(b[1]) == n
    
    result = 0
    for i in range(n):
        result ^= (a[0][i] & b[1][i]) ^ (a[1][i] & b[0][i])
    return result


def is_isotropic(vectors: List[Tuple[List[int], List[int]]]) -> bool:
    """Check if a set of binary Pauli vectors forms an isotropic subspace.
    
    An isotropic subspace has all pairwise symplectic products equal to 0.
    This is the necessary condition for a valid stabilizer group.
    
    Time complexity: O(|S|² · n).
    """
    for i in range(len(vectors)):
        for j in range(i, len(vectors)):
            if symplectic_inner_product(vectors[i], vectors[j]) != 0:
                return False
    return True


def pauli_weight(v: Tuple[List[int], List[int]]) -> int:
    """Compute the weight of a Pauli vector.
    
    Weight = number of positions where the operator is non-identity,
    i.e., where x[i] ≠ 0 or z[i] ≠ 0.
    """
    return sum(1 for x, z in zip(v[0], v[1]) if x != 0 or z != 0)


# ============================================================
# Algorithm 6: Code Parameter Feasibility
# ============================================================

def parameter_feasibility(n: int, k: int, d: int) -> Dict:
    """Comprehensive feasibility check for [[n, k, d]] parameters.
    
    Checks:
    - Basic validity (k ≤ n, d ≥ 1)
    - Singleton bound (2d + k ≤ n + 2)
    - Hamming bound (nondegenerate case)
    - Whether the code could be perfect
    - Whether it's MDS
    
    Time complexity: O(d · n) for Hamming sum computation.
    """
    t = (d - 1) // 2
    hs = hamming_sum(n, t)
    ss = 2 ** (n - k) if k <= n else 0
    
    return {
        "parameters": f"[[{n},{k},{d}]]",
        "valid_basic": k <= n and d >= 1,
        "singleton_ok": 2 * d + k <= n + 2,
        "hamming_ok": hs <= ss,
        "is_perfect": hs == ss,
        "is_mds": 2 * d + k == n + 2,
        "hamming_sum": hs,
        "syndrome_size": ss,
        "redundancy": n - k if k <= n else None,
        "correction_radius": t,
    }


# ============================================================
# Main: Run All Demonstrations
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===")
    print()
    
    # Hamming bound
    print("1. Hamming Bound Verification:")
    for params in [(5,1,3), (7,1,3), (9,1,3), (23,1,7)]:
        result = verify_hamming_bound(*params)
        status = "PERFECT" if result["perfect"] else (
            "OK" if result["satisfied"] else "VIOLATED")
        print(f"   {result['parameters']}: {status} "
              f"(sum={result['hamming_sum']}, space={result['syndrome_size']})")
    
    print()
    
    # Perfect codes
    print("2. Perfect Code Search (d=3):")
    perfect = find_perfect_codes_d3(10000)
    for n, k in perfect:
        print(f"   [[{n},{k},3]]: 1 + 3·{n} = {1+3*n} = 2^{n-k}")
    
    print()
    
    # Toric codes
    print("3. Toric Code Family:")
    for L in [2, 3, 5, 10, 20]:
        p = toric_code_params(L)
        print(f"   L={L}: [[{p['n']},{p['k']},{p['d']}]], "
              f"kd²=n: {p['kd2_equals_n']}, rate={p['rate']:.4f}")
    
    print()
    
    # Symplectic form
    print("4. Symplectic Form Examples (n=3):")
    # X₁ = (1,0,0 | 0,0,0)
    x1 = ([1,0,0], [0,0,0])
    # Z₁ = (0,0,0 | 1,0,0)
    z1 = ([0,0,0], [1,0,0])
    # X₂ = (0,1,0 | 0,0,0)
    x2 = ([0,1,0], [0,0,0])
    
    print(f"   ⟨X₁, Z₁⟩ = {symplectic_inner_product(x1, z1)} (anticommute)")
    print(f"   ⟨X₁, X₂⟩ = {symplectic_inner_product(x1, x2)} (commute)")
    print(f"   ⟨X₁, X₁⟩ = {symplectic_inner_product(x1, x1)} (self-orthogonal)")
    print(f"   Isotropic check {{X₁, X₂}}: {is_isotropic([x1, x2])}")
    print(f"   Isotropic check {{X₁, Z₁}}: {is_isotropic([x1, z1])}")
    
    print()
    
    # Feasibility
    print("5. Parameter Feasibility:")
    for params in [(5,1,3), (6,1,3), (7,1,3), (5,2,3), (5,1,5)]:
        f = parameter_feasibility(*params)
        print(f"   {f['parameters']}: basic={f['valid_basic']}, "
              f"singleton={f['singleton_ok']}, hamming={f['hamming_ok']}")
    
    print()
    print("All algorithms completed.")

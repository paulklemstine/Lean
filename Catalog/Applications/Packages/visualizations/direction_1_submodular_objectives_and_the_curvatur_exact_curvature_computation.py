#!/usr/bin/env python3
"""
Algorithms for Submodular Curvature-Gap Optimization
=====================================================

Certified algorithms for:
1. Exact curvature computation for finite submodular functions
2. Exact multilinear extension evaluation
3. Threshold rounding with approximation guarantees
4. Modular surrogate bound computation

All algorithms include complexity analysis and correctness certificates.
"""

from typing import List, Set, Callable, Tuple, Optional
import math


# ===========================================================================
# Algorithm 1: Exact Curvature Computation
# ===========================================================================

def compute_curvature(n: int, f: Callable[[Set[int]], float]) -> Tuple[float, dict]:
    """
    Compute the total curvature κ of a monotone submodular function f.

    κ = 1 - min_{v: f({v})>0} [f(V) - f(V\\{v})] / f({v})

    Args:
        n: Number of ground set elements (V = {0,...,n-1})
        f: Set function f: 2^V → ℝ

    Returns:
        (kappa, info) where info contains per-element marginal data

    Complexity: O(n) evaluations of f (on sets of size n and n-1)
    """
    V = set(range(n))
    fV = f(V)

    marginals = {}
    singletons = {}
    min_ratio = float('inf')
    witness_v = None

    for v in range(n):
        fv = f({v})
        singletons[v] = fv
        marginal_v = fV - f(V - {v})
        marginals[v] = marginal_v

        if fv > 1e-12:
            ratio = marginal_v / fv
            if ratio < min_ratio:
                min_ratio = ratio
                witness_v = v

    if min_ratio == float('inf'):
        kappa = 0.0
    else:
        kappa = max(0.0, 1.0 - min_ratio)

    info = {
        'kappa': kappa,
        'min_ratio': min_ratio if min_ratio < float('inf') else None,
        'witness': witness_v,
        'singletons': singletons,
        'marginals_at_V': marginals,
        'f_V': fV,
    }
    return kappa, info


# ===========================================================================
# Algorithm 2: Exact Multilinear Extension
# ===========================================================================

def multilinear_extension_exact(n: int,
                                 f: Callable[[Set[int]], float],
                                 x: List[float]) -> float:
    """
    Exact computation of the multilinear extension F(x).

    F(x) = Σ_{A ⊆ V} [Π_{v∈A} x_v · Π_{v∉A}(1-x_v)] · f(A)

    Args:
        n: Ground set size
        f: Set function
        x: Fractional point in [0,1]^n

    Returns:
        F(x), the multilinear extension value

    Complexity: O(2^n · n) time, O(1) extra space
    """
    total = 0.0
    for mask in range(1 << n):
        A = set()
        prob = 1.0
        for v in range(n):
            if mask & (1 << v):
                A.add(v)
                prob *= x[v]
            else:
                prob *= (1.0 - x[v])
        total += prob * f(A)
    return total


def multilinear_extension_mc(n: int,
                              f: Callable[[Set[int]], float],
                              x: List[float],
                              num_samples: int = 10000,
                              seed: Optional[int] = None) -> Tuple[float, float]:
    """
    Monte Carlo estimation of F(x) with confidence interval.

    Args:
        n, f, x: As above
        num_samples: Number of Bernoulli samples
        seed: Random seed for reproducibility

    Returns:
        (estimate, std_error)

    Complexity: O(num_samples · n) time
    """
    import random as rng
    if seed is not None:
        rng.seed(seed)

    values = []
    for _ in range(num_samples):
        R = {v for v in range(n) if rng.random() < x[v]}
        values.append(f(R))

    mean = sum(values) / len(values)
    if len(values) > 1:
        var = sum((v - mean)**2 for v in values) / (len(values) - 1)
        std_err = math.sqrt(var / len(values))
    else:
        std_err = 0.0

    return mean, std_err


# ===========================================================================
# Algorithm 3: Threshold Rounding with Certificate
# ===========================================================================

def threshold_round_certified(n: int, d: int,
                               x: List[float],
                               edges: List[List[int]],
                               f: Callable[[Set[int]], float],
                               kappa: float) -> dict:
    """
    Threshold rounding with full approximation certificate.

    Args:
        n: Ground set size
        d: Maximum edge size (hypergraph rank)
        x: Fractional transversal in [0,1]^n
        edges: Hypergraph edges
        f: Monotone submodular function
        kappa: Curvature parameter (< 1)

    Returns:
        Dictionary with:
        - S: rounded set
        - f_S: f(S)
        - modular_cost: Σ_{v∈S} f({v})
        - modular_bound: d · Σ_v x_v f({v})
        - curvature_bound: d/(1-κ) · F(x) [if computable]
        - is_transversal: whether S hits all edges
        - certificate: explanation of bound chain
    """
    threshold = 1.0 / d
    S = {v for v in range(n) if x[v] >= threshold}

    fS = f(S)
    modular_cost = sum(f({v}) for v in S)
    weighted_sum = sum(x[v] * f({v}) for v in range(n))

    # Check transversal property
    is_transversal = all(
        any(v in S for v in edge) for edge in edges
    )

    # Compute bounds
    modular_bound = d * weighted_sum
    if kappa < 1.0 - 1e-10:
        Fx = multilinear_extension_exact(n, f, x) if n <= 20 else \
             multilinear_extension_mc(n, f, x)[0]
        curvature_bound = d / (1 - kappa) * Fx
    else:
        Fx = None
        curvature_bound = float('inf')

    certificate = {
        'step1': f'f(S) = {fS:.4f} ≤ Σ_{{v∈S}} f({{v}}) = {modular_cost:.4f}  '
                  f'[submodular telescope]',
        'step2': f'Σ_{{v∈S}} f({{v}}) = {modular_cost:.4f} ≤ '
                  f'd·Σ x_v f({{v}}) = {modular_bound:.4f}  '
                  f'[weighted threshold bound]',
        'step3': f'd·Σ x_v f({{v}}) = {modular_bound:.4f} ≤ '
                  f'd/(1-κ)·F(x) = {curvature_bound:.4f}  '
                  f'[curvature lower bound on F(x)]' if curvature_bound < float('inf')
                  else 'κ ≈ 1, curvature bound is trivial',
    }

    return {
        'S': S,
        'f_S': fS,
        'modular_cost': modular_cost,
        'modular_bound': modular_bound,
        'curvature_bound': curvature_bound,
        'F_x': Fx,
        'is_transversal': is_transversal,
        'certificate': certificate,
    }


# ===========================================================================
# Algorithm 4: Verified Modular Domination Check
# ===========================================================================

def verify_modular_domination(n: int,
                                f: Callable[[Set[int]], float],
                                kappa: float,
                                max_subsets: int = 1000) -> dict:
    """
    Verify f(A) ≤ 1/(1-κ) · Σ_{v∈A} f({v}) for sampled subsets.

    Args:
        n: Ground set size
        f: Monotone submodular function
        kappa: Curvature
        max_subsets: Number of subsets to check

    Returns:
        Verification report
    """
    import random as rng

    max_ratio = 0.0
    worst_A = None
    violations = 0

    bound_factor = 1.0 / (1.0 - kappa) if kappa < 1 - 1e-10 else float('inf')

    checked = 0
    for mask in range(min(1 << n, max_subsets)):
        if n > 15:
            mask = rng.randint(0, (1 << n) - 1)
        A = {v for v in range(n) if mask & (1 << v)}
        if not A:
            continue

        fA = f(A)
        modular_sum = sum(f({v}) for v in A)
        scaled = bound_factor * modular_sum

        if modular_sum > 1e-12:
            ratio = fA / modular_sum
            if ratio > max_ratio:
                max_ratio = ratio
                worst_A = A

        if fA > scaled + 1e-9:
            violations += 1

        checked += 1

    return {
        'checked': checked,
        'violations': violations,
        'max_ratio': max_ratio,
        'bound_factor': bound_factor,
        'worst_subset': worst_A,
        'verified': violations == 0,
    }


# ===========================================================================
# Example Usage
# ===========================================================================

if __name__ == "__main__":
    import random

    random.seed(123)
    n = 10

    # Define a weighted coverage function
    items = [
        (2.0, [0, 1, 2]),
        (1.5, [1, 3, 4]),
        (3.0, [2, 5, 6]),
        (1.0, [3, 7]),
        (2.5, [0, 4, 8, 9]),
        (1.8, [5, 6, 7]),
        (0.7, [8, 9, 0]),
    ]

    def f(A):
        return sum(w for w, S in items if A & set(S))

    print("=== Curvature Computation ===")
    kappa, info = compute_curvature(n, f)
    print(f"  κ = {kappa:.4f}")
    print(f"  f(V) = {info['f_V']:.4f}")
    print(f"  Witness vertex: {info['witness']}")
    print()

    print("=== Multilinear Extension ===")
    x = [0.3] * n
    Fx = multilinear_extension_exact(n, f, x)
    Fx_mc, se = multilinear_extension_mc(n, f, x, 10000, seed=42)
    print(f"  F(x) exact = {Fx:.4f}")
    print(f"  F(x) MC    = {Fx_mc:.4f} ± {se:.4f}")
    print()

    print("=== Threshold Rounding ===")
    edges = [[0, 1, 2], [3, 4, 5], [6, 7, 8, 9], [0, 5, 9]]
    d = max(len(e) for e in edges)
    x_feas = [0.3, 0.4, 0.5, 0.3, 0.3, 0.5, 0.3, 0.3, 0.3, 0.4]
    result = threshold_round_certified(n, d, x_feas, edges, f, kappa)
    print(f"  S = {result['S']}")
    print(f"  f(S) = {result['f_S']:.4f}")
    print(f"  Is transversal: {result['is_transversal']}")
    for step, desc in result['certificate'].items():
        print(f"  {step}: {desc}")
    print()

    print("=== Modular Domination Check ===")
    vr = verify_modular_domination(n, f, kappa)
    print(f"  Checked {vr['checked']} subsets")
    print(f"  Violations: {vr['violations']}")
    print(f"  Max ratio f(A)/Σf({{v}}): {vr['max_ratio']:.4f}")
    print(f"  Bound factor 1/(1-κ): {vr['bound_factor']:.4f}")
    print(f"  Verified: {vr['verified']}")

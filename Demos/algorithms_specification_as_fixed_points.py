#!/usr/bin/env python3
"""
Algorithms for Specification-as-Fixed-Points Framework.

Implements the key algorithms derived from the theoretical framework:
1. Specification checking via preimage/image inclusion
2. Closure hull computation
3. Fixed-point detection and classification
4. Idempotency verification
5. Specification collapse detection
"""

import numpy as np
from typing import Callable, Set, List, Tuple, Optional, TypeVar, Generic
from dataclasses import dataclass

T = TypeVar('T')

# ============================================================
# Algorithm 1: Specification Checker
# ============================================================

@dataclass
class SpecResult:
    """Result of a specification check."""
    satisfies: bool
    witnesses: List  # counterexamples if fails
    image: Set
    preimage: Set

def check_specification(
    N: Callable,
    K: Set,
    S: Set,
    universe: Optional[Set] = None
) -> SpecResult:
    """
    Check whether ∀ x ∈ K, N(x) ∈ S.
    
    Uses three equivalent methods (Theorem forall_mem_iff_subset_preimage):
    1. Pointwise check
    2. Image inclusion: N(K) ⊆ S
    3. Preimage inclusion: K ⊆ N⁻¹(S) (requires universe)
    
    Time complexity: O(|K|) for methods 1-2, O(|universe|) for method 3
    Space complexity: O(|K|) for image, O(|universe|) for preimage
    
    Args:
        N: The map/network to verify
        K: Input domain (set)
        S: Safe output set
        universe: Full domain for preimage computation (optional)
    
    Returns:
        SpecResult with satisfaction status, counterexamples, image, and preimage
    """
    # Compute image
    image_K = {N(x) for x in K}
    
    # Check image inclusion
    satisfies = image_K.issubset(S)
    
    # Find counterexamples
    witnesses = [x for x in K if N(x) not in S]
    
    # Compute preimage if universe given
    if universe is not None:
        preimage_S = {x for x in universe if N(x) in S}
    else:
        preimage_S = set()
    
    return SpecResult(
        satisfies=satisfies,
        witnesses=witnesses,
        image=image_K,
        preimage=preimage_S
    )


# ============================================================
# Algorithm 2: Closure Hull Computation
# ============================================================

def compute_closure_hull(
    C: Callable[[Set], Set],
    K: Set,
    max_iter: int = 100
) -> Tuple[Set, int]:
    """
    Compute the closure hull C(K) by iterating C until fixpoint.
    
    For a true closure operator (idempotent), one application suffices.
    For approximate closure operators, iterates until convergence.
    
    Time complexity: O(max_iter * cost(C))
    Space complexity: O(|C(K)|)
    
    Pseudocode:
        result ← K
        for i = 1 to max_iter:
            next ← C(result)
            if next = result: return (result, i)
            result ← next
        return (result, max_iter)
    
    Args:
        C: Closure operator (or approximation)
        K: Input set
        max_iter: Maximum iterations
    
    Returns:
        (closure_hull, iterations_used)
    """
    result = frozenset(K)
    for i in range(1, max_iter + 1):
        next_result = frozenset(C(set(result)))
        if next_result == result:
            return set(result), i
        result = next_result
    return set(result), max_iter


def verify_closure_axioms(
    C: Callable[[Set], Set],
    test_sets: List[Set]
) -> dict:
    """
    Verify the three closure operator axioms on test sets.
    
    Checks:
    1. Extensive: A ⊆ C(A) for all test sets
    2. Monotone: A ⊆ B → C(A) ⊆ C(B) for all pairs
    3. Idempotent: C(C(A)) = C(A) for all test sets
    
    Args:
        C: Candidate closure operator
        test_sets: List of test sets
    
    Returns:
        Dictionary with verification results
    """
    results = {
        'extensive': True,
        'monotone': True,
        'idempotent': True,
        'extensive_failures': [],
        'monotone_failures': [],
        'idempotent_failures': [],
    }
    
    for A in test_sets:
        CA = C(A)
        CCA = C(CA)
        
        # Extensive
        if not A.issubset(CA):
            results['extensive'] = False
            results['extensive_failures'].append(A)
        
        # Idempotent
        if CCA != CA:
            results['idempotent'] = False
            results['idempotent_failures'].append(A)
    
    # Monotone
    for i, A in enumerate(test_sets):
        for B in test_sets[i+1:]:
            if A.issubset(B):
                if not C(A).issubset(C(B)):
                    results['monotone'] = False
                    results['monotone_failures'].append((A, B))
            if B.issubset(A):
                if not C(B).issubset(C(A)):
                    results['monotone'] = False
                    results['monotone_failures'].append((B, A))
    
    return results


# ============================================================
# Algorithm 3: Fixed Point Detection
# ============================================================

def find_fixed_points(
    N: Callable,
    domain: Set,
    tolerance: float = 0.0
) -> Set:
    """
    Find all fixed points of N in the given domain.
    
    A fixed point is x such that N(x) = x (or |N(x) - x| ≤ tolerance).
    
    Time complexity: O(|domain| * cost(N))
    Space complexity: O(|fixed_points|)
    
    Args:
        N: Endofunction
        domain: Set to search
        tolerance: Numerical tolerance for approximate fixed points
    
    Returns:
        Set of fixed points
    """
    if tolerance == 0:
        return {x for x in domain if N(x) == x}
    else:
        return {x for x in domain if abs(N(x) - x) <= tolerance}


def find_fixed_points_continuous(
    N: Callable[[float], float],
    lo: float,
    hi: float,
    n_samples: int = 1000,
    tolerance: float = 1e-8
) -> List[float]:
    """
    Find approximate fixed points of a continuous function on [lo, hi].
    
    Uses bisection on g(x) = N(x) - x to find zeros.
    
    Args:
        N: Continuous endofunction on reals
        lo, hi: Search interval
        n_samples: Number of sample points for sign-change detection
        tolerance: Convergence tolerance
    
    Returns:
        List of approximate fixed points
    """
    g = lambda x: N(x) - x
    xs = np.linspace(lo, hi, n_samples)
    gs = [g(x) for x in xs]
    
    fixed_points = []
    
    for i in range(len(xs) - 1):
        if gs[i] * gs[i+1] < 0:  # Sign change
            # Bisection
            a, b = xs[i], xs[i+1]
            for _ in range(100):
                mid = (a + b) / 2
                if g(mid) * g(a) < 0:
                    b = mid
                else:
                    a = mid
                if b - a < tolerance:
                    break
            fixed_points.append((a + b) / 2)
        elif abs(gs[i]) < tolerance:
            fixed_points.append(xs[i])
    
    return fixed_points


# ============================================================
# Algorithm 4: Idempotency Checker
# ============================================================

def check_idempotent(
    N: Callable,
    domain: Set,
    tolerance: float = 0.0
) -> Tuple[bool, List]:
    """
    Check if N is idempotent: N(N(x)) = N(x) for all x in domain.
    
    Time complexity: O(|domain| * cost(N))
    
    Args:
        N: Function to check
        domain: Test domain
        tolerance: Numerical tolerance
    
    Returns:
        (is_idempotent, counterexamples)
    """
    counterexamples = []
    for x in domain:
        nx = N(x)
        nnx = N(nx)
        if tolerance == 0:
            if nnx != nx:
                counterexamples.append((x, nx, nnx))
        else:
            if abs(nnx - nx) > tolerance:
                counterexamples.append((x, nx, nnx))
    
    return len(counterexamples) == 0, counterexamples


# ============================================================
# Algorithm 5: Specification Collapse Detector
# ============================================================

def detect_specification_collapse(
    N: Callable,
    K: Set,
    tolerance: float = 0.0
) -> dict:
    """
    Detect if a specification collapses to a singleton via unique fixed point.
    
    Algorithm:
    1. Compute outputs N(K) = {N(x) | x ∈ K}
    2. Check which outputs are fixed points
    3. If all outputs are fixed points, check if they're all equal
    
    This implements the chain:
      spec_to_fixPts_of_idempotent → outputs_eq_unique_fixed_point
    
    Args:
        N: Endofunction
        K: Input set
        tolerance: Numerical tolerance
    
    Returns:
        Dictionary with analysis results
    """
    outputs = {x: N(x) for x in K}
    
    # Check which outputs are fixed points
    fixed_outputs = {}
    for x, nx in outputs.items():
        try:
            nnx = N(nx)
            if tolerance == 0:
                is_fp = (nnx == nx)
            else:
                is_fp = abs(nnx - nx) <= tolerance
            fixed_outputs[x] = {
                'output': nx,
                'is_fixed_point': is_fp,
                'N_of_output': nnx
            }
        except Exception:
            fixed_outputs[x] = {
                'output': nx,
                'is_fixed_point': False,
                'N_of_output': None
            }
    
    all_fixed = all(v['is_fixed_point'] for v in fixed_outputs.values())
    unique_values = set(v['output'] for v in fixed_outputs.values())
    
    return {
        'all_outputs_are_fixed_points': all_fixed,
        'collapses_to_singleton': all_fixed and len(unique_values) == 1,
        'unique_output': unique_values.pop() if len(unique_values) == 1 else None,
        'num_distinct_outputs': len(unique_values),
        'details': fixed_outputs
    }


# ============================================================
# Main: Run all algorithms with examples
# ============================================================

if __name__ == "__main__":
    print("Specification-as-Fixed-Points: Algorithm Demonstrations\n")
    
    # Algorithm 1: Specification checking
    print("--- Algorithm 1: Specification Checker ---")
    result = check_specification(
        N=lambda x: x ** 2 % 10,
        K={1, 2, 3, 4, 5},
        S={0, 1, 4, 5, 6, 9},
        universe=set(range(10))
    )
    print(f"  Satisfies: {result.satisfies}")
    print(f"  Image: {sorted(result.image)}")
    print(f"  Preimage: {sorted(result.preimage)}")
    print()
    
    # Algorithm 2: Closure hull
    print("--- Algorithm 2: Closure Hull ---")
    def convex_closure_1d(s):
        if not s: return set()
        return set(range(min(s), max(s) + 1))
    
    hull, iters = compute_closure_hull(convex_closure_1d, {1, 5, 9})
    print(f"  Closure hull of {{1, 5, 9}}: {sorted(hull)} (in {iters} iteration(s))")
    
    axioms = verify_closure_axioms(convex_closure_1d, [
        {1, 3}, {2, 5, 8}, {1, 2, 3, 4, 5}, set()
    ])
    print(f"  Closure axioms: extensive={axioms['extensive']}, "
          f"monotone={axioms['monotone']}, idempotent={axioms['idempotent']}")
    print()
    
    # Algorithm 3: Fixed point detection
    print("--- Algorithm 3: Fixed Point Detection ---")
    oml = lambda x: 1.0 - np.log(x)
    fps = find_fixed_points_continuous(oml, 0.01, 10.0)
    print(f"  Fixed points of oml(x) = 1 - ln(x) on [0.01, 10]: {fps}")
    print(f"  (Expected: x = 1)")
    print()
    
    # Algorithm 4: Idempotency check
    print("--- Algorithm 4: Idempotency Checker ---")
    is_idem, failures = check_idempotent(
        N=lambda x: round(x),
        domain={0.3, 1.7, 2.5, -0.4, 3.0},
        tolerance=1e-10
    )
    print(f"  round(x) is idempotent: {is_idem}")
    
    is_idem2, failures2 = check_idempotent(
        N=oml,
        domain={0.5, 1.0, 2.0, 3.0},
        tolerance=1e-10
    )
    print(f"  oml(x) is idempotent: {is_idem2}")
    if failures2:
        print(f"  Counterexample: oml({failures2[0][0]}) = {failures2[0][1]:.4f}, "
              f"oml(oml({failures2[0][0]})) = {failures2[0][2]:.4f}")
    print()
    
    # Algorithm 5: Specification collapse
    print("--- Algorithm 5: Specification Collapse ---")
    # Constant function (trivially idempotent with unique FP)
    collapse = detect_specification_collapse(
        N=lambda x: 0,
        K={1, 2, 3, 4, 5}
    )
    print(f"  N(x) = 0: collapses = {collapse['collapses_to_singleton']}, "
          f"value = {collapse['unique_output']}")
    
    # Round function (idempotent, multiple fixed points)
    collapse2 = detect_specification_collapse(
        N=lambda x: round(x),
        K={0.3, 1.7, 2.5}
    )
    print(f"  round(x): collapses = {collapse2['collapses_to_singleton']}, "
          f"all_fixed = {collapse2['all_outputs_are_fixed_points']}, "
          f"distinct = {collapse2['num_distinct_outputs']}")

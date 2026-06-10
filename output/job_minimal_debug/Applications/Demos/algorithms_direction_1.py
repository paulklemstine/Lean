#!/usr/bin/env python3
"""
EML Closure Operator — Algorithms

Implements the closure operator, one-step generation, fixed-point iteration,
information decay computation, and penalty analysis as executable algorithms.
"""

import numpy as np
from typing import Callable, Set, List, Tuple, Optional
from dataclasses import dataclass, field


# =============================================================================
# Core Data Structures
# =============================================================================

@dataclass
class EMLFunction:
    """
    Represents a function in the EML closure, tracking its derivation depth
    and the operation that produced it.
    """
    name: str
    func: Callable[[float], float]
    depth: int = 0
    operation: str = "base"
    children: List['EMLFunction'] = field(default_factory=list)

    def __call__(self, x: float) -> float:
        return self.func(x)

    def __repr__(self) -> str:
        return f"EMLFunction({self.name}, depth={self.depth})"


# =============================================================================
# Algorithm 1: EML One-Step Generation
# =============================================================================

def eml_one_step(functions: List[EMLFunction],
                 max_constants: int = 3) -> List[EMLFunction]:
    """
    EML One-Step Operator: Given a set of functions, produce all functions
    obtainable by one application of EML operations.

    Operations:
    - Constants: fun _ => c for selected c values
    - Addition: fun x => f(x) + g(x)
    - Multiplication: fun x => f(x) * g(x)
    - Composition: fun x => f(g(x))

    Time complexity: O(n² + k) where n = |functions|, k = max_constants
    Space complexity: O(n²) for the generated functions

    Args:
        functions: Current set of EML functions
        max_constants: Number of constant functions to add

    Returns:
        List of newly generated functions (not including originals)
    """
    new_functions = []
    current_depth = max((f.depth for f in functions), default=0)

    # Add constants
    for c in np.linspace(-2, 2, max_constants):
        cf = EMLFunction(
            name=f"const({c:.1f})",
            func=lambda x, c=c: c,
            depth=0,
            operation="const"
        )
        new_functions.append(cf)

    # Pairwise operations
    for i, f in enumerate(functions):
        for j, g in enumerate(functions):
            # Addition
            new_functions.append(EMLFunction(
                name=f"({f.name}+{g.name})",
                func=lambda x, f=f, g=g: f(x) + g(x),
                depth=max(f.depth, g.depth) + 1,
                operation="add",
                children=[f, g]
            ))

            # Multiplication
            new_functions.append(EMLFunction(
                name=f"({f.name}*{g.name})",
                func=lambda x, f=f, g=g: f(x) * g(x),
                depth=max(f.depth, g.depth) + 1,
                operation="mul",
                children=[f, g]
            ))

            # Composition
            new_functions.append(EMLFunction(
                name=f"({f.name}∘{g.name})",
                func=lambda x, f=f, g=g: f(g(x)),
                depth=max(f.depth, g.depth) + 1,
                operation="comp",
                children=[f, g]
            ))

    return new_functions


# =============================================================================
# Algorithm 2: Iterated Closure Computation
# =============================================================================

def compute_eml_closure(generators: List[EMLFunction],
                        max_iterations: int = 3,
                        max_functions: int = 100) -> List[EMLFunction]:
    """
    Compute the EML closure by iterating the one-step operator.

    This implements the fixed-point characterization:
        EMLClosure(A) = ⋃_{n≥0} Step^n(A)

    The algorithm terminates when either:
    - No new functions are generated (fixed point reached)
    - max_iterations is exceeded
    - max_functions limit is reached

    Time complexity: O(max_iterations * n²) where n grows each iteration
    Space complexity: O(max_functions)

    Args:
        generators: Initial generator functions
        max_iterations: Maximum number of iteration steps
        max_functions: Maximum number of functions to track

    Returns:
        List of all generated functions (approximation of closure)
    """
    current = list(generators)
    all_functions = list(generators)

    for iteration in range(max_iterations):
        new = eml_one_step(current, max_constants=3)

        # Deduplicate by evaluating at test points
        test_points = np.array([0.0, 0.5, 1.0, -1.0, 2.0])
        existing_signatures = set()
        for f in all_functions:
            try:
                sig = tuple(round(f(x), 8) for x in test_points)
                existing_signatures.add(sig)
            except (OverflowError, ValueError):
                pass

        truly_new = []
        for f in new:
            try:
                sig = tuple(round(f(x), 8) for x in test_points)
                if sig not in existing_signatures:
                    existing_signatures.add(sig)
                    truly_new.append(f)
            except (OverflowError, ValueError):
                pass

        if not truly_new:
            print(f"    Fixed point reached at iteration {iteration}")
            break

        all_functions.extend(truly_new[:max_functions - len(all_functions)])
        current = truly_new[:50]  # Limit working set

        print(f"    Iteration {iteration}: {len(truly_new)} new functions, "
              f"{len(all_functions)} total")

        if len(all_functions) >= max_functions:
            print(f"    Function limit reached ({max_functions})")
            break

    return all_functions


# =============================================================================
# Algorithm 3: Information Decay Analysis
# =============================================================================

def analyze_info_decay(alpha: float,
                       max_depth: int = 20) -> List[Tuple[int, float]]:
    """
    Compute information retention at each closure depth.

    The retained information at depth n is alpha^n, which is
    monotonically decreasing for 0 ≤ alpha ≤ 1.

    This implements the quantitative invariant transport theorem:
        For m ≤ n: infoRetained(alpha, n) ≤ infoRetained(alpha, m)

    Time complexity: O(max_depth)
    Space complexity: O(max_depth)

    Args:
        alpha: Decay rate, must satisfy 0 ≤ alpha ≤ 1
        max_depth: Maximum depth to analyze

    Returns:
        List of (depth, retained_info) pairs
    """
    assert 0 <= alpha <= 1, f"alpha must be in [0,1], got {alpha}"

    results = []
    for depth in range(max_depth + 1):
        retained = alpha ** depth
        results.append((depth, retained))

    return results


def find_critical_depth(alpha: float, threshold: float = 0.01) -> int:
    """
    Find the depth at which information drops below a threshold.

    Uses the formula: depth = ceil(log(threshold) / log(alpha))

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        alpha: Decay rate
        threshold: Information threshold

    Returns:
        Critical depth where alpha^depth < threshold
    """
    if alpha <= 0:
        return 1
    if alpha >= 1:
        return float('inf')

    return int(np.ceil(np.log(threshold) / np.log(alpha)))


# =============================================================================
# Algorithm 4: Penalty Growth Analysis
# =============================================================================

def structural_penalty(k: int, n: int) -> float:
    """
    Compute structural risk penalty: sqrt(2k * log(n) / n).

    Time complexity: O(1)
    Space complexity: O(1)
    """
    if n <= 1:
        return 0.0
    return np.sqrt(2 * k * np.log(n) / n)


def optimal_complexity(n: int,
                       empirical_risk: Callable[[int], float],
                       max_k: int = 1000) -> Tuple[int, float]:
    """
    Find the optimal model complexity that minimizes total risk
    (empirical risk + structural penalty).

    This demonstrates the bias-variance tradeoff encoded in the
    penalty monotonicity theorem.

    Time complexity: O(max_k)
    Space complexity: O(1)

    Args:
        n: Number of samples
        empirical_risk: Function mapping complexity k to empirical risk
        max_k: Maximum complexity to search

    Returns:
        (optimal_k, minimum_total_risk)
    """
    best_k = 1
    best_risk = float('inf')

    for k in range(1, max_k + 1):
        total = empirical_risk(k) + structural_penalty(k, n)
        if total < best_risk:
            best_risk = total
            best_k = k

    return best_k, best_risk


# =============================================================================
# Algorithm 5: Grover Iteration Analysis
# =============================================================================

def grover_iterations(N: int, k: int) -> int:
    """
    Compute number of Grover iterations for k solutions in N candidates.

    Time complexity: O(1)
    Space complexity: O(1)
    """
    return int(np.sqrt(N / (k + 1)))


def grover_speedup_ratio(N: int, k: int) -> float:
    """
    Compute quantum speedup ratio: classical_cost / grover_cost.

    Time complexity: O(1)
    Space complexity: O(1)
    """
    classical = N
    quantum = grover_iterations(N, k) + 1  # +1 to avoid division by zero
    return classical / quantum


# =============================================================================
# Algorithm 6: Closure Monotonicity Verification
# =============================================================================

def verify_closure_monotonicity(
    generators_A: List[EMLFunction],
    generators_B: List[EMLFunction],
    test_points: np.ndarray = np.linspace(-2, 2, 50),
    max_iterations: int = 2
) -> bool:
    """
    Numerically verify that EMLClosure(A) ⊆ EMLClosure(B) when A ⊆ B.

    Tests by computing both closures and checking that every function
    value achievable from A is also achievable from B.

    Time complexity: O(max_iterations * n² * |test_points|)

    Args:
        generators_A: Generators for set A
        generators_B: Generators for set B (should be superset)
        test_points: Points at which to evaluate functions
        max_iterations: Closure iterations

    Returns:
        True if monotonicity holds numerically
    """
    closure_A = compute_eml_closure(generators_A, max_iterations, max_functions=50)
    closure_B = compute_eml_closure(generators_B, max_iterations, max_functions=50)

    # Check that every function value in closure_A appears in closure_B
    values_B = set()
    for f in closure_B:
        for x in test_points:
            try:
                values_B.add(round(f(x), 6))
            except (OverflowError, ValueError):
                pass

    for f in closure_A:
        for x in test_points:
            try:
                v = round(f(x), 6)
                if v not in values_B:
                    return False
            except (OverflowError, ValueError):
                pass

    return True


# =============================================================================
# Main Demonstration
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("  EML CLOSURE OPERATOR — ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Closure computation
    print("\n--- Algorithm: Iterated Closure Computation ---")
    identity = EMLFunction("id", lambda x: x, depth=0)
    closure = compute_eml_closure([identity], max_iterations=2, max_functions=30)
    print(f"  Starting from {{id}}, generated {len(closure)} functions")

    # Demo 2: Information decay
    print("\n--- Algorithm: Information Decay Analysis ---")
    for alpha in [0.9, 0.5, 0.1]:
        critical = find_critical_depth(alpha, threshold=0.01)
        print(f"  α = {alpha}: information < 1% at depth {critical}")

    # Demo 3: Optimal complexity
    print("\n--- Algorithm: Optimal Model Complexity ---")
    for n in [100, 1000, 10000]:
        emp_risk = lambda k: 1.0 / (1 + k)  # decreasing empirical risk
        k_opt, risk = optimal_complexity(n, emp_risk)
        print(f"  n = {n:>6}: optimal k = {k_opt:>4}, total risk = {risk:.4f}")

    # Demo 4: Grover speedup
    print("\n--- Algorithm: Grover Speedup Ratios ---")
    N = 1_000_000
    for k in [1, 10, 100, 1000]:
        ratio = grover_speedup_ratio(N, k)
        print(f"  N={N:>10}, k={k:>5}: speedup = {ratio:>8.1f}x")

    print("\n" + "=" * 70)
    print("  All algorithms demonstrated successfully.")
    print("=" * 70)

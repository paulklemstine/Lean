"""
Algorithms for Gravitational Code Geometry

Type-hinted implementations of the core algorithms from the
Einstein Decomposition Theorem framework.
"""
from typing import Callable, Dict, FrozenSet, List, Optional, Set, Tuple
import itertools
import math

# Type aliases
SetFn = Callable[[FrozenSet[int]], float]


def powerset(ground: Set[int]) -> List[FrozenSet[int]]:
    """Generate all subsets of a ground set as frozensets.
    
    Args:
        ground: The ground set of integers.
        
    Returns:
        List of all subsets as frozensets, ordered by size.
    """
    items = sorted(ground)
    result: List[FrozenSet[int]] = []
    for r in range(len(items) + 1):
        for combo in itertools.combinations(items, r):
            result.append(frozenset(combo))
    return result


def compute_defect(f: SetFn, X: FrozenSet[int], Y: FrozenSet[int]) -> float:
    """Compute the syndrome defect (discrete curvature).
    
    defect(f, X, Y) = f(X) + f(Y) - f(X ∩ Y) - f(X ∪ Y)
    
    Args:
        f: Set function mapping frozensets to reals.
        X, Y: Input sets.
        
    Returns:
        The defect value. Non-negative for submodular f.
    """
    return f(X) + f(Y) - f(X & Y) - f(X | Y)


def einstein_decomposition(
    S: SetFn,
    ground: Set[int]
) -> Tuple[SetFn, SetFn, bool]:
    """Compute the optimal Einstein decomposition S = T + L.
    
    Finds the modular function L that best approximates S,
    then sets T = S - L. The modular function is determined by
    the singleton values: L(X) = Σ_{x∈X} L({x}) where L({x}) = S({x}).
    
    Args:
        S: Entropy functional (should be submodular).
        ground: The ground set.
        
    Returns:
        Tuple (T, L, valid) where:
        - T: Matter entropy (S - L)
        - L: Vacuum entropy (modular approximation)
        - valid: Whether the decomposition gives valid CodeSpacetime
    """
    # Modular function determined by singletons
    singleton_vals: Dict[int, float] = {}
    for x in ground:
        singleton_vals[x] = S(frozenset({x}))
    
    def L(X: FrozenSet[int]) -> float:
        return sum(singleton_vals.get(x, 0.0) for x in X)
    
    def T(X: FrozenSet[int]) -> float:
        return S(X) - L(X)
    
    # Verify T(∅) = 0
    valid = abs(T(frozenset())) < 1e-10
    
    return T, L, valid


def compute_curvature_tensor(
    f: SetFn,
    ground: Set[int]
) -> Dict[Tuple[FrozenSet[int], FrozenSet[int]], float]:
    """Compute the full curvature tensor (all pairwise defects).
    
    Args:
        f: Set function.
        ground: Ground set.
        
    Returns:
        Dictionary mapping (X, Y) pairs to defect values.
    """
    subsets = powerset(ground)
    tensor: Dict[Tuple[FrozenSet[int], FrozenSet[int]], float] = {}
    for X in subsets:
        for Y in subsets:
            tensor[(X, Y)] = compute_defect(f, X, Y)
    return tensor


def total_curvature(f: SetFn, ground: Set[int]) -> float:
    """Compute total curvature (sum of all defects).
    
    Args:
        f: Set function (submodular for non-negative result).
        ground: Ground set.
        
    Returns:
        Sum of defect(f, X, Y) over all pairs (X, Y).
    """
    subsets = powerset(ground)
    return sum(compute_defect(f, X, Y) for X in subsets for Y in subsets)


def compute_mutual_info(
    f: SetFn, X: FrozenSet[int], Y: FrozenSet[int]
) -> float:
    """Compute mutual information I(X:Y) = f(X) + f(Y) - f(X ∪ Y).
    
    Args:
        f: Set function.
        X, Y: Disjoint sets for physical interpretation.
        
    Returns:
        Mutual information value.
    """
    return f(X) + f(Y) - f(X | Y)


def compute_tripartite_info(
    f: SetFn,
    X: FrozenSet[int],
    Y: FrozenSet[int],
    Z: FrozenSet[int]
) -> float:
    """Compute tripartite information I₃(X,Y,Z).
    
    I₃ = f(X) + f(Y) + f(Z) - f(X∪Y) - f(X∪Z) - f(Y∪Z) + f(X∪Y∪Z)
    
    Args:
        f: Set function.
        X, Y, Z: Three sets.
        
    Returns:
        Tripartite information. Can be negative for quantum systems.
    """
    return (f(X) + f(Y) + f(Z)
            - f(X | Y) - f(X | Z) - f(Y | Z)
            + f(X | Y | Z))


def verify_submodularity(f: SetFn, ground: Set[int], tol: float = 1e-10) -> Tuple[bool, float]:
    """Check if f is submodular and return the minimum defect.
    
    Args:
        f: Set function to check.
        ground: Ground set.
        tol: Numerical tolerance.
        
    Returns:
        Tuple (is_submodular, min_defect).
    """
    subsets = powerset(ground)
    min_defect = float('inf')
    for X in subsets:
        for Y in subsets:
            d = compute_defect(f, X, Y)
            min_defect = min(min_defect, d)
    return min_defect >= -tol, min_defect


def verify_modularity(f: SetFn, ground: Set[int], tol: float = 1e-10) -> Tuple[bool, float]:
    """Check if f is modular and return the maximum |defect|.
    
    Args:
        f: Set function to check.
        ground: Ground set.
        tol: Numerical tolerance.
        
    Returns:
        Tuple (is_modular, max_abs_defect).
    """
    subsets = powerset(ground)
    max_abs_defect = 0.0
    for X in subsets:
        for Y in subsets:
            d = abs(compute_defect(f, X, Y))
            max_abs_defect = max(max_abs_defect, d)
    return max_abs_defect <= tol, max_abs_defect


def binding_energy_analysis(
    f: SetFn,
    ground: Set[int]
) -> List[Dict]:
    """Analyze binding energies between all disjoint pairs.
    
    Args:
        f: Set function (should be submodular for non-negative binding).
        ground: Ground set.
        
    Returns:
        List of dicts with X, Y, binding_energy for each disjoint pair.
    """
    subsets = powerset(ground)
    results: List[Dict] = []
    for X in subsets:
        for Y in subsets:
            if X & Y:
                continue  # Skip non-disjoint
            if not X or not Y:
                continue  # Skip empty
            be = compute_mutual_info(f, X, Y)
            results.append({
                "X": set(X),
                "Y": set(Y),
                "binding_energy": be,
                "normalized": be / (len(X) * len(Y)) if len(X) * len(Y) > 0 else 0
            })
    return sorted(results, key=lambda r: -r["binding_energy"])


if __name__ == "__main__":
    # Quick demonstration
    ground = {1, 2, 3}
    
    # Cardinality spacetime
    S = lambda X: len(X) ** 2
    T, L, valid = einstein_decomposition(S, ground)
    
    print("Einstein Decomposition of S(X) = |X|²:")
    print(f"  Valid: {valid}")
    print(f"  S({{1,2,3}}) = {S(frozenset(ground))}")
    print(f"  T({{1,2,3}}) = {T(frozenset(ground))}")
    print(f"  L({{1,2,3}}) = {L(frozenset(ground))}")
    
    is_sub, min_d = verify_submodularity(S, ground)
    print(f"  S submodular: {is_sub} (min defect = {min_d})")
    
    is_mod, max_d = verify_modularity(L, ground)
    print(f"  L modular: {is_mod} (max |defect| = {max_d})")
    
    print(f"  Total curvature: {total_curvature(S, ground):.2f}")
    
    bindings = binding_energy_analysis(S, ground)
    print(f"  Top binding: {bindings[0]}")

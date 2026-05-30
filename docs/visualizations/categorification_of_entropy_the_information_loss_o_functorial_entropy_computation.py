"""
Algorithms for Functorial Entropy

Implements efficient computation of functorial entropy and related quantities.
"""

import math
from collections import Counter
from typing import Callable, Dict, List, Optional, Tuple


def functorial_entropy(
    f: Callable[[int], int],
    domain: List[int],
    codomain: Optional[List[int]] = None
) -> float:
    """
    Compute the functorial entropy H(f) = sum_b (|f^{-1}(b)|/|A|) * log(|f^{-1}(b)|).
    
    Time complexity: O(|domain| + |codomain|)
    Space complexity: O(|codomain|)
    
    Args:
        f: Function from domain elements to codomain elements.
        domain: List of domain elements.
        codomain: Optional list of codomain elements. If None, uses the image of f.
    
    Returns:
        The functorial entropy H(f) ≥ 0.
    
    Examples:
        >>> functorial_entropy(lambda x: x, [0,1,2])  # identity
        0.0
        >>> functorial_entropy(lambda x: 0, [0,1,2])  # constant
        1.0986122886681098
        >>> abs(functorial_entropy(lambda x: x % 2, [0,1,2,3]) - math.log(2)) < 1e-10
        True
    """
    n = len(domain)
    if n == 0:
        return 0.0
    
    # Count fiber sizes
    fiber_counts = Counter(f(a) for a in domain)
    
    # Compute entropy
    H = 0.0
    for b, count in fiber_counts.items():
        if count > 0:
            H += (count / n) * math.log(count)
    
    return H


def fiber_distribution(
    f: Callable[[int], int],
    domain: List[int]
) -> Dict[int, int]:
    """
    Compute the fiber size distribution {b: |f^{-1}(b)|}.
    
    Time complexity: O(|domain|)
    Space complexity: O(|image(f)|)
    """
    return dict(Counter(f(a) for a in domain))


def is_information_preserving(
    f: Callable[[int], int],
    domain: List[int],
    tol: float = 1e-10
) -> bool:
    """
    Check if f is information-preserving (H(f) = 0, equivalently f is injective).
    
    Time complexity: O(|domain|)
    Space complexity: O(|image(f)|)
    """
    return functorial_entropy(f, domain) < tol


def landauer_cost(
    f: Callable[[int], int],
    domain: List[int],
    temperature: float = 300.0,
    k_boltzmann: float = 1.380649e-23
) -> float:
    """
    Compute the Landauer thermodynamic cost of the computation f.
    
    Cost = kT * H(f)
    
    Args:
        f: The computation (function).
        domain: The state space.
        temperature: Temperature in Kelvin (default: room temperature).
        k_boltzmann: Boltzmann constant in J/K.
    
    Returns:
        Minimum energy dissipation in Joules.
    """
    kT = k_boltzmann * temperature
    return kT * functorial_entropy(f, domain)


def entropy_decomposition(
    f: Callable[[int], int],
    domain: List[int]
) -> Dict[str, float]:
    """
    Decompose the entropy into per-fiber contributions.
    
    Returns a dict with:
    - 'total': total functorial entropy
    - 'max_possible': log(|domain|)
    - 'efficiency': H(f) / log(|domain|), the "collapse fraction"
    - 'per_fiber': dict of {codomain_element: contribution_to_entropy}
    """
    n = len(domain)
    if n == 0:
        return {'total': 0.0, 'max_possible': 0.0, 'efficiency': 0.0, 'per_fiber': {}}
    
    fiber_counts = Counter(f(a) for a in domain)
    per_fiber = {}
    total = 0.0
    
    for b, count in fiber_counts.items():
        if count > 0:
            contrib = (count / n) * math.log(count)
            per_fiber[b] = contrib
            total += contrib
    
    max_H = math.log(n)
    efficiency = total / max_H if max_H > 0 else 0.0
    
    return {
        'total': total,
        'max_possible': max_H,
        'efficiency': efficiency,
        'per_fiber': per_fiber
    }


def verify_composition_conjecture(
    f: Callable[[int], int],
    g: Callable[[int], int],
    domain_a: List[int],
    domain_b: List[int],
    domain_c: List[int]
) -> Tuple[bool, float, float]:
    """
    Verify the composition superadditivity conjecture:
    If f: A → B is surjective, then H(g) ≤ H(g ∘ f).
    
    Returns:
        (conjecture_holds, H_g, H_gf)
    """
    # Check f is surjective
    image_f = set(f(a) for a in domain_a)
    is_surj = all(b in image_f for b in domain_b)
    
    gf = lambda x: g(f(x))
    H_g = functorial_entropy(g, domain_b, domain_c)
    H_gf = functorial_entropy(gf, domain_a, domain_c)
    
    return (H_g <= H_gf + 1e-10, H_g, H_gf)


def uniform_fiber_entropy(k: int) -> float:
    """
    Compute the functorial entropy for a function with uniform fibers of size k.
    By the uniform fiber theorem, this is exactly log(k).
    
    >>> abs(uniform_fiber_entropy(1)) < 1e-15
    True
    >>> abs(uniform_fiber_entropy(2) - math.log(2)) < 1e-15
    True
    """
    if k <= 0:
        return 0.0
    return math.log(k)


if __name__ == "__main__":
    print("=== Functorial Entropy Algorithms ===\n")
    
    # Example: entropy decomposition
    domain = list(range(12))
    f = lambda x: x % 4  # uniform fibers of size 3
    
    decomp = entropy_decomposition(f, domain)
    print(f"f(x) = x mod 4 on {{0,...,11}}")
    print(f"  Total entropy: {decomp['total']:.6f}")
    print(f"  log(3) = {math.log(3):.6f}")
    print(f"  Max possible: {decomp['max_possible']:.6f}")
    print(f"  Collapse efficiency: {decomp['efficiency']:.4f}")
    print(f"  Per-fiber contributions: {decomp['per_fiber']}")
    print()
    
    # Landauer cost
    f_erase = lambda x: 0  # total erasure
    cost = landauer_cost(f_erase, domain)
    print(f"Landauer cost of erasing 12-state system at 300K: {cost:.4e} J")
    print(f"  Compare to: kT * ln(12) = {1.380649e-23 * 300 * math.log(12):.4e} J")

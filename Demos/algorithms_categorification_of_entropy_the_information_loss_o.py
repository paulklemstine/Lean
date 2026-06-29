#!/usr/bin/env python3
"""
Functorial Entropy: Core Algorithms

Type-hinted implementations of the key algorithms for computing
and analyzing functorial entropy.
"""

import math
from collections import Counter
from typing import TypeVar, Callable, Sequence

T = TypeVar('T')
U = TypeVar('U')


def fiber_card(f: dict[T, U], b: U) -> int:
    """
    Compute the fiber cardinality |f⁻¹(b)|.
    
    Time: O(|domain|)
    Space: O(1)
    """
    return sum(1 for v in f.values() if v == b)


def fiber_sizes(f: dict[T, U]) -> dict[U, int]:
    """
    Compute all fiber sizes at once.
    
    Time: O(|domain|)
    Space: O(|codomain|)
    """
    return dict(Counter(f.values()))


def functorial_entropy(f: dict[T, U]) -> float:
    """
    Compute the functorial entropy H(f) = Σ_b (n_b/N) · log(n_b).
    
    Time: O(|domain|)
    Space: O(|codomain|)
    
    Properties:
    - H(f) ≥ 0
    - H(f) = 0 iff f is injective
    - H(f) ≤ log(|domain|)
    """
    n: int = len(f)
    if n == 0:
        return 0.0
    
    sizes: dict[U, int] = fiber_sizes(f)
    return sum(
        (s / n) * math.log(s)
        for s in sizes.values()
        if s > 0
    )


def shannon_entropy(probs: Sequence[float]) -> float:
    """
    Compute Shannon entropy H(p) = -Σ p_i · log(p_i).
    
    Time: O(|probs|)
    """
    return -sum(p * math.log(p) for p in probs if p > 0)


def fiber_distribution(f: dict[T, U], codomain: Sequence[U]) -> list[float]:
    """
    Compute the fiber distribution q(b) = |f⁻¹(b)| / |domain|.
    
    Time: O(|domain| + |codomain|)
    """
    n: int = len(f)
    if n == 0:
        return [0.0] * len(codomain)
    sizes: dict[U, int] = fiber_sizes(f)
    return [sizes.get(b, 0) / n for b in codomain]


def entropy_via_shannon_bridge(f: dict[T, U], codomain: Sequence[U]) -> float:
    """
    Compute H(f) using the Shannon bridge: H(f) = log|α| - H_Shannon(q).
    
    This is mathematically equivalent to functorial_entropy but
    demonstrates the bridge theorem.
    """
    n: int = len(f)
    if n == 0:
        return 0.0
    q: list[float] = fiber_distribution(f, codomain)
    return math.log(n) - shannon_entropy(q)


def landauer_cost(f: dict[T, T], kT: float) -> float:
    """
    Compute the Landauer cost of a computation: kT · H(f).
    
    Args:
        f: Function from a finite set to itself
        kT: Temperature parameter (Boltzmann constant × temperature)
    
    Returns:
        Minimum energy dissipation required by Landauer's principle
    """
    return kT * functorial_entropy(f)


def is_uniform_fiber(f: dict[T, U]) -> tuple[bool, int]:
    """
    Check if f has uniform fibers (all nonempty fibers have the same size).
    
    Returns:
        (is_uniform, fiber_size) — fiber_size is 0 if domain is empty
    """
    sizes: dict[U, int] = fiber_sizes(f)
    nonzero_sizes: set[int] = {s for s in sizes.values() if s > 0}
    if len(nonzero_sizes) <= 1:
        return True, (nonzero_sizes.pop() if nonzero_sizes else 0)
    return False, 0


def verify_composition_monotonicity(
    f: dict[T, U],
    g: dict[U, object]
) -> tuple[bool, float, float]:
    """
    Verify H(g∘f) ≥ H(f) for given f and g.
    
    Returns:
        (holds, H_f, H_gf)
    """
    gf: dict[T, object] = {a: g[f[a]] for a in f}
    h_f: float = functorial_entropy(f)
    h_gf: float = functorial_entropy(gf)
    return h_gf >= h_f - 1e-12, h_f, h_gf


def entropy_decomposition(
    f: dict[T, U],
    g: dict[U, object]
) -> dict[str, float]:
    """
    Decompose the entropy of a composition g∘f.
    
    Returns a dictionary with:
    - H_f: entropy of f
    - H_g: entropy of g
    - H_gf: entropy of g∘f
    - gain: H(g∘f) - H(f) (always ≥ 0)
    """
    gf: dict[T, object] = {a: g[f[a]] for a in f}
    h_f: float = functorial_entropy(f)
    h_g: float = functorial_entropy(g)
    h_gf: float = functorial_entropy(gf)
    
    return {
        "H_f": h_f,
        "H_g": h_g,
        "H_gf": h_gf,
        "gain": h_gf - h_f,
    }


if __name__ == "__main__":
    # Example usage
    f = {0: 0, 1: 0, 2: 1, 3: 1, 4: 2, 5: 2}
    print(f"f = {f}")
    print(f"H(f) = {functorial_entropy(f):.6f}")
    print(f"Uniform fibers: {is_uniform_fiber(f)}")
    
    g = {0: 0, 1: 0, 2: 1}
    print(f"\ng = {g}")
    print(f"H(g) = {functorial_entropy(g):.6f}")
    
    holds, h_f, h_gf = verify_composition_monotonicity(f, g)
    print(f"\nH(f) = {h_f:.6f}, H(g∘f) = {h_gf:.6f}")
    print(f"H(g∘f) ≥ H(f): {holds}")
    
    decomp = entropy_decomposition(f, g)
    print(f"\nDecomposition: {decomp}")

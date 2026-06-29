#!/usr/bin/env python3
"""
Functorial Entropy: Core Algorithms

Type-hinted implementations of functorial entropy computation,
composition analysis, and related quantities.
"""

import math
from typing import Callable, Dict, List, Optional, Sequence, Tuple


def fiber_cardinalities(
    f: Callable[[int], int],
    domain: Sequence[int],
    codomain: Sequence[int],
) -> Dict[int, int]:
    """
    Compute the fiber cardinality |f^{-1}(b)| for each b in codomain.

    Args:
        f: Function mapping domain elements to codomain elements.
        domain: The finite domain of f.
        codomain: The finite codomain of f.

    Returns:
        Dictionary mapping each b in codomain to |{a in domain : f(a) = b}|.

    Time complexity: O(|domain| + |codomain|)
    """
    counts: Dict[int, int] = {b: 0 for b in codomain}
    for a in domain:
        b = f(a)
        if b in counts:
            counts[b] += 1
    return counts


def xlog(x: float) -> float:
    """
    Compute x * log(x) for x > 0, and 0 for x <= 0.

    This function is superadditive: xlog(x + y) >= xlog(x) + xlog(y)
    for x, y >= 0.
    """
    if x > 0:
        return x * math.log(x)
    return 0.0


def functorial_entropy(
    f: Callable[[int], int],
    domain: Sequence[int],
    codomain: Sequence[int],
) -> float:
    """
    Compute the functorial entropy H(f).

    H(f) = sum_{b in codomain} (|f^{-1}(b)| / |domain|) * log(|f^{-1}(b)|)

    Args:
        f: Function mapping domain to codomain.
        domain: Finite domain of f.
        codomain: Finite codomain of f.

    Returns:
        The functorial entropy H(f) >= 0.

    Properties:
        - H(f) = 0 iff f is injective (on its domain)
        - H(f) = log|domain| for constant f
        - H(g o f) >= H(f) for any g (composition monotonicity)
    """
    N = len(domain)
    if N == 0:
        return 0.0
    fibers = fiber_cardinalities(f, domain, codomain)
    return sum(
        (fc / N) * math.log(fc)
        for fc in fibers.values()
        if fc > 0
    )


def landauer_cost(
    f: Callable[[int], int],
    domain: Sequence[int],
) -> float:
    """
    Compute the Landauer cost L(f) = log|domain| - log|range(f)|.

    This measures the minimum thermodynamic cost of implementing f.

    Properties:
        - L(f) >= 0 (Landauer's principle)
        - L(f) = 0 iff f is injective (reversible computation)
    """
    N = len(domain)
    if N == 0:
        return 0.0
    range_f = set(f(a) for a in domain)
    return math.log(N) - math.log(len(range_f))


def entropy_defect(
    f: Callable[[int], int],
    g: Callable[[int], int],
    domain_f: Sequence[int],
    codomain_f: Sequence[int],
    codomain_g: Sequence[int],
) -> float:
    """
    Compute the entropy defect delta(f, g) = H(g o f) - H(f).

    Measures the additional information loss introduced by g
    beyond what f already loses.

    Properties:
        - delta(f, g) >= 0 (by composition monotonicity)
        - delta(f, id) = 0
    """
    H_f = functorial_entropy(f, domain_f, codomain_f)
    gf = lambda a: g(f(a))
    H_gf = functorial_entropy(gf, domain_f, codomain_g)
    return H_gf - H_f


def entropy_rate(
    f: Callable[[int], int],
    domain: Sequence[int],
    n: int,
) -> float:
    """
    Compute the entropy rate h(f, n) = H(f^n) / n for an endomorphism.

    Args:
        f: Endomorphism on domain.
        domain: Finite set (both domain and codomain of f).
        n: Number of iterations.

    Returns:
        H(f^n) / n, or 0 if n = 0.
    """
    if n == 0:
        return 0.0

    def f_iter(a: int) -> int:
        x = a
        for _ in range(n):
            x = f(x)
        return x

    return functorial_entropy(f_iter, domain, list(domain)) / n


def fiber_distribution(
    f: Callable[[int], int],
    domain: Sequence[int],
    codomain: Sequence[int],
) -> Dict[int, float]:
    """
    Compute the fiber distribution p_b = |f^{-1}(b)| / |domain|.

    This is a valid probability distribution on codomain when domain is nonempty.
    """
    N = len(domain)
    fibers = fiber_cardinalities(f, domain, codomain)
    return {b: fc / N for b, fc in fibers.items()} if N > 0 else {b: 0.0 for b in codomain}


def shannon_entropy(probs: Dict[int, float]) -> float:
    """
    Compute Shannon entropy H = -sum p_i log(p_i).
    """
    return -sum(p * math.log(p) for p in probs.values() if p > 0)


def verify_shannon_bridge(
    f: Callable[[int], int],
    domain: Sequence[int],
    codomain: Sequence[int],
) -> Tuple[float, float, float]:
    """
    Verify the Entropy-Shannon Bridge: H(f) = log|domain| - H_Shannon(fiber dist).

    Returns:
        (H_f, bridge_value, error) where error should be ~0.
    """
    N = len(domain)
    H_f = functorial_entropy(f, domain, codomain)
    dist = fiber_distribution(f, domain, codomain)
    H_shannon = shannon_entropy(dist)
    bridge_value = math.log(N) - H_shannon if N > 0 else 0.0
    return H_f, bridge_value, abs(H_f - bridge_value)


def composition_monotonicity_check(
    f: Callable[[int], int],
    g: Callable[[int], int],
    domain_f: Sequence[int],
    codomain_f: Sequence[int],
    codomain_g: Sequence[int],
) -> Tuple[float, float, bool]:
    """
    Check H(g o f) >= H(f).

    Returns:
        (H_f, H_gf, holds) where holds indicates the inequality.
    """
    H_f = functorial_entropy(f, domain_f, codomain_f)
    gf = lambda a: g(f(a))
    H_gf = functorial_entropy(gf, domain_f, codomain_g)
    return H_f, H_gf, H_gf >= H_f - 1e-10

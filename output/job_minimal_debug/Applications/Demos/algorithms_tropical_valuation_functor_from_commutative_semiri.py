#!/usr/bin/env python3
"""
Algorithms for Tropical Valuation Closure Bridge

Type-hinted implementations of the core algorithms from the paper:
1. p-adic valuation computation
2. Level-set closure computation
3. Threshold probe evaluation
4. Closure equivalence testing
5. Closure rank computation
6. Defect profile computation
"""

from typing import Set, Dict, List, Callable, Tuple, FrozenSet
import math


def padic_valuation(p: int, n: int) -> float:
    """
    Compute the p-adic valuation v_p(n).

    The p-adic valuation counts the maximum power of p dividing n.
    Returns float('inf') for n = 0 (maps to tropical infinity).

    Args:
        p: A prime number
        n: An integer

    Returns:
        v_p(n) as a float (int-valued for n != 0, inf for n = 0)

    Examples:
        >>> padic_valuation(2, 12)
        2.0
        >>> padic_valuation(3, 27)
        3.0
        >>> padic_valuation(2, 0)
        inf
    """
    if n == 0:
        return float('inf')
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return float(v)


def level_set_closure(
    v: Callable[[int], float],
    seed: Set[int],
    domain: Set[int]
) -> Set[int]:
    """
    Compute the level-set closure cl_v(S) within a domain.

    cl_v(S) = {x ∈ domain | ∃ s ∈ S, v(x) = v(s)}

    The level-set closure adds to S all domain elements whose valuation
    matches that of some seed element.

    Complexity: O(|seed| + |domain|) assuming O(1) valuation.

    Args:
        v: Valuation function
        seed: The set S to close
        domain: The ambient set

    Returns:
        cl_v(S) ∩ domain
    """
    val_image: Set[float] = {v(s) for s in seed}
    return {x for x in domain if v(x) in val_image}


def threshold_probe(
    v: Callable[[int], float],
    threshold: float,
    x: int
) -> int:
    """
    Evaluate the threshold probe at level `threshold`.

    p_n(x) = 1 if v(x) ≤ n, else 0.

    Args:
        v: Valuation function
        threshold: The threshold level n
        x: The element to probe

    Returns:
        0 or 1
    """
    return 1 if v(x) <= threshold else 0


def threshold_probe_vector(
    v: Callable[[int], float],
    x: int,
    max_scale: int
) -> List[int]:
    """
    Compute the full threshold probe vector for element x.

    Returns [p_0(x), p_1(x), ..., p_max_scale(x)].

    Args:
        v: Valuation function
        x: The element
        max_scale: Maximum threshold level

    Returns:
        List of 0s and 1s
    """
    return [threshold_probe(v, n, x) for n in range(max_scale + 1)]


def is_closure_stable(
    v: Callable[[int], float],
    p: Callable[[int], int],
    domain: Set[int],
    num_tests: int = 100
) -> Tuple[bool, str]:
    """
    Test whether probe p is closure-stable for the level-set closure of v.

    Tests on random subsets of the domain. A probe is closure-stable if
    for every S and x ∈ cl_v(S), there exists y ∈ S with p(x) = p(y).

    By the characterization theorem, this is equivalent to p factoring
    through v (i.e., v(x) = v(y) ⟹ p(x) = p(y)).

    Args:
        v: Valuation function
        p: Probe function
        domain: Ambient set
        num_tests: Number of random subsets to test

    Returns:
        (is_stable, explanation)
    """
    import random
    domain_list = sorted(domain)

    # Direct check: does p factor through v?
    val_groups: Dict[float, Set[int]] = {}
    for x in domain:
        vx = v(x)
        if vx not in val_groups:
            val_groups[vx] = set()
        val_groups[vx].add(x)

    for vx, group in val_groups.items():
        probe_vals = {p(x) for x in group}
        if len(probe_vals) > 1:
            examples = sorted(group)[:2]
            return (False,
                    f"NOT stable: v({examples[0]})=v({examples[1]})={vx} "
                    f"but p({examples[0]})={p(examples[0])}, "
                    f"p({examples[1]})={p(examples[1])}")

    return (True, "Stable: p factors through v (constant on v-fibers)")


def closure_rank(
    v: Callable[[int], float],
    S: Set[int]
) -> int:
    """
    Compute the closure rank: number of distinct valuations in S.

    rank_v(S) = |{v(s) | s ∈ S}|

    Args:
        v: Valuation function
        S: A finite set

    Returns:
        The closure rank
    """
    return len({v(s) for s in S})


def are_closure_equivalent(
    v1: Callable[[int], float],
    v2: Callable[[int], float],
    domain: Set[int]
) -> Tuple[bool, str]:
    """
    Test whether v1 and v2 give the same closure operator on domain.

    By the characterization theorem, this holds iff v1 and v2 induce
    the same partition: v1(x) = v1(y) ↔ v2(x) = v2(y) for all x, y.

    Complexity: O(|domain|²) in the worst case, O(|domain| · log|domain|)
    with sorting.

    Args:
        v1, v2: Two valuation functions
        domain: Ambient set

    Returns:
        (are_equivalent, explanation)
    """
    domain_list = sorted(domain)

    # Build partition for v1 and v2
    def partition(v: Callable[[int], float]) -> Dict[float, FrozenSet[int]]:
        groups: Dict[float, Set[int]] = {}
        for x in domain:
            vx = v(x)
            if vx not in groups:
                groups[vx] = set()
            groups[vx].add(x)
        return {k: frozenset(v_set) for k, v_set in groups.items()}

    p1 = set(partition(v1).values())
    p2 = set(partition(v2).values())

    if p1 == p2:
        return (True, f"Equivalent: both have {len(p1)} partition classes")
    else:
        # Find a distinguishing pair
        for block in p1:
            if block not in p2:
                examples = sorted(block)[:2]
                if len(examples) >= 2:
                    return (False,
                            f"Not equivalent: v1({examples[0]})=v1({examples[1]}) "
                            f"but v2 separates them")
        return (False, "Not equivalent: different partition structures")


def defect_profile(
    v: Callable[[int], float],
    S: Set[int],
    domain: Set[int],
    max_scale: int
) -> Dict[int, Set[int]]:
    """
    Compute the defect profile D(n, n+1, S) for each scale n.

    D(n, n+1, S) = cl_{n+1}(S) \\ cl_n(S)

    This decomposes the closure growth into layers indexed by valuation.

    Args:
        v: Valuation function
        S: Seed set
        domain: Ambient set
        max_scale: Maximum scale

    Returns:
        Dictionary mapping scale n to the defect set D(n, n+1, S)
    """
    def threshold_closure(n: float) -> Set[int]:
        return {x for x in domain if v(x) <= n} | S

    profile: Dict[int, Set[int]] = {}
    prev = threshold_closure(-1)  # Just S (nothing has v(x) <= -1)
    prev = S.copy()

    for n in range(max_scale + 1):
        curr = threshold_closure(n)
        profile[n] = curr - prev
        prev = curr

    return profile


def valuation_closure_system(
    p: int,
    domain: Set[int]
) -> Dict[str, object]:
    """
    Construct the full closure system from a p-adic valuation.

    Returns a dictionary with all components of the bridge:
    - closure: the closure function
    - probes: the threshold probe family
    - partition: the valuation partition
    - rank: a function computing closure rank

    Args:
        p: A prime number
        domain: Ambient set

    Returns:
        Dictionary of bridge components
    """
    v = lambda n: padic_valuation(p, n)

    return {
        'prime': p,
        'valuation': v,
        'closure': lambda S: level_set_closure(v, S, domain),
        'threshold_probe': lambda n, x: threshold_probe(v, n, x),
        'probe_vector': lambda x, max_n=10: threshold_probe_vector(v, x, max_n),
        'closure_rank': lambda S: closure_rank(v, S),
        'defect_profile': lambda S, max_n=10: defect_profile(v, S, domain, max_n),
        'domain': domain,
    }


if __name__ == "__main__":
    # Quick self-test
    v2 = lambda n: padic_valuation(2, n)

    # Test valuation
    assert padic_valuation(2, 12) == 2
    assert padic_valuation(3, 27) == 3
    assert padic_valuation(2, 0) == float('inf')

    # Test closure
    domain = set(range(1, 50))
    cl = level_set_closure(v2, {4}, domain)
    assert all(v2(x) == v2(4) for x in cl)
    assert 4 in cl  # extensivity

    # Test probe
    assert threshold_probe(v2, 1, 2) == 1
    assert threshold_probe(v2, 0, 2) == 0

    # Test closure rank
    assert closure_rank(v2, {1, 2, 4, 8}) == 4

    # Test equivalence
    v2_scaled = lambda n: 2 * padic_valuation(2, n)
    eq, _ = are_closure_equivalent(v2, v2_scaled, domain)
    assert eq

    v3 = lambda n: padic_valuation(3, n)
    neq, _ = are_closure_equivalent(v2, v3, domain)
    assert not neq

    print("All self-tests passed.")

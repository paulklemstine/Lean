#!/usr/bin/env python3
"""
Reflective Algebra: Core Algorithms

Type-hinted implementations of the key algorithms from the
self-modeling framework.
"""

from typing import Callable, Dict, FrozenSet, List, Optional, Set, Tuple


# Type aliases
Endo = Tuple[int, ...]  # Endomorphism on Fin(n) represented as a tuple


def compose_endo(f: Endo, g: Endo) -> Endo:
    """Compose two endomorphisms: (f ∘ g)(x) = f(g(x))."""
    return tuple(f[g[i]] for i in range(len(f)))


def is_idempotent(f: Endo) -> bool:
    """Check whether f ∘ f = f (i.e., f is an observation)."""
    return compose_endo(f, f) == f


def fixed_point_set(f: Endo) -> FrozenSet[int]:
    """Compute the fixed point set {x | f(x) = x}."""
    return frozenset(x for x in range(len(f)) if f[x] == x)


def image_set(f: Endo) -> FrozenSet[int]:
    """Compute the image {f(x) | x ∈ domain}."""
    return frozenset(f)


def has_fixed_point(f: Endo) -> bool:
    """Check whether f has at least one fixed point."""
    return any(f[x] == x for x in range(len(f)))


# ============================================================
# Algorithm 1: Reflective Deficiency Computation
# ============================================================

def compute_reflective_deficiency(
    n: int,
    encode: Callable[[int], Endo]
) -> Set[Endo]:
    """
    Compute the reflective deficiency of a representation map.

    Args:
        n: Size of the finite type Fin(n)
        encode: The representation map x ↦ encode(x)

    Returns:
        The set of endomorphisms not in range(encode)

    Complexity: O(n^n · n) time, O(n^n) space
    """
    from itertools import product as cart_product

    represented: Set[Endo] = {encode(x) for x in range(n)}
    all_endos: Set[Endo] = set(cart_product(range(n), repeat=n))
    return all_endos - represented


def reflective_index(n: int, encode: Callable[[int], Endo]) -> int:
    """Compute the reflective index |deficiency|."""
    return len(compute_reflective_deficiency(n, encode))


# ============================================================
# Algorithm 2: Observation Enumeration
# ============================================================

def enumerate_observations(n: int) -> List[Endo]:
    """
    Enumerate all observations (idempotent endomorphisms) on Fin(n).

    The count satisfies: |Obs(n)| = sum_{k=0}^{n} C(n,k) * k^{n-k}

    Complexity: O(n^n · n) time
    """
    from itertools import product as cart_product

    return [f for f in cart_product(range(n), repeat=n) if is_idempotent(f)]


def observation_from_partition(
    n: int,
    partition: List[List[int]],
    representatives: List[int]
) -> Endo:
    """
    Construct an observation from a partition and representative choices.

    Each element maps to the representative of its block.

    Args:
        n: Size of Fin(n)
        partition: List of blocks (each block is a list of elements)
        representatives: For each block, which element is the representative

    Returns:
        The idempotent function mapping each element to its block's representative
    """
    result = list(range(n))
    for block, rep in zip(partition, representatives):
        for elem in block:
            result[elem] = rep
    return tuple(result)


# ============================================================
# Algorithm 3: Green's Preorder Decision
# ============================================================

def green_L_leq(a: Endo, b: Endo) -> bool:
    """
    Decide whether a ≤_L b in Green's L-preorder.

    a ≤_L b iff there exists f such that a = f ∘ b,
    which is equivalent to: b(x₁) = b(x₂) ⟹ a(x₁) = a(x₂).

    Complexity: O(n) time
    """
    n = len(a)
    seen: Dict[int, int] = {}
    for x in range(n):
        bx = b[x]
        ax = a[x]
        if bx in seen:
            if seen[bx] != ax:
                return False
        else:
            seen[bx] = ax
    return True


def green_R_leq(a: Endo, b: Endo) -> bool:
    """
    Decide whether a ≤_R b in Green's R-preorder.

    a ≤_R b iff there exists f such that a = b ∘ f,
    which is equivalent to: range(a) ⊆ range(b).

    Complexity: O(n) time
    """
    return image_set(a).issubset(image_set(b))


def green_L_classes(observations: List[Endo]) -> List[List[Endo]]:
    """
    Compute Green's L-equivalence classes on a set of observations.

    Two observations are L-equivalent iff a ≤_L b and b ≤_L a.

    Complexity: O(k² · n) where k = |observations|
    """
    classes: List[List[Endo]] = []
    classified: Set[Endo] = set()

    for a in observations:
        if a in classified:
            continue
        cls = [a]
        classified.add(a)
        for b in observations:
            if b not in classified:
                if green_L_leq(a, b) and green_L_leq(b, a):
                    cls.append(b)
                    classified.add(b)
        classes.append(cls)

    return classes


# ============================================================
# Algorithm 4: Diagonal Construction
# ============================================================

def diagonal_iterate(
    encode: Callable[[int], Endo],
    g: Endo,
    steps: int
) -> List[Endo]:
    """
    Iterate the diagonal construction starting from g.

    Given g, produce g₁ = g, g_{k+1}(x) = g_k(encode(x)(x)).
    This is the key construction for the Reflective Index Dichotomy Conjecture.

    Args:
        encode: The representation map
        g: Starting endomorphism (typically from the deficiency)
        steps: Number of iterations

    Returns:
        List of iterates [g₁, g₂, ..., g_{steps+1}]
    """
    n = len(g)
    iterates = [g]
    current = g

    for _ in range(steps):
        # g_{k+1}(x) = g_k(encode(x)(x))
        diag_values = tuple(encode(x)[x] for x in range(n))
        next_g = tuple(current[diag_values[x]] for x in range(n))
        iterates.append(next_g)
        current = next_g

    return iterates


def test_dichotomy_conjecture(
    n: int,
    encode: Callable[[int], Endo],
    max_steps: int = 20
) -> Dict[str, object]:
    """
    Test the reflective index dichotomy conjecture.

    Returns a report with:
    - deficiency_size: number of missing endomorphisms
    - distinct_iterates: how many distinct elements the diagonal produces
    - all_in_deficiency: whether all iterates stay in the deficiency
    - cycle_detected: whether the iterates eventually cycle
    """
    deficiency = compute_reflective_deficiency(n, encode)

    if not deficiency:
        return {
            "deficiency_size": 0,
            "message": "System is fully reflective (impossible for n≥2)"
        }

    g = sorted(deficiency)[0]
    iterates = diagonal_iterate(encode, g, max_steps)

    unique = set(iterates)
    all_in_def = all(it in deficiency for it in iterates)

    return {
        "deficiency_size": len(deficiency),
        "starting_element": g,
        "distinct_iterates": len(unique),
        "total_iterates": len(iterates),
        "all_in_deficiency": all_in_def,
        "cycle_detected": len(unique) < len(iterates),
    }


# ============================================================
# Algorithm 5: Knaster-Tarski Least Fixed Point
# ============================================================

def knaster_tarski_lfp(
    n: int,
    f: Callable[[FrozenSet[int]], FrozenSet[int]]
) -> FrozenSet[int]:
    """
    Compute the least fixed point of a monotone function on P(Fin(n)).

    Uses the iterative construction: x₀ = ∅, x_{k+1} = f(x_k),
    which converges in at most n+1 steps for finite lattices.

    Args:
        n: Size of the ground set
        f: Monotone function on subsets of {0,...,n-1}

    Returns:
        The least fixed point of f
    """
    current: FrozenSet[int] = frozenset()
    for _ in range(n + 2):
        next_val = f(current)
        if next_val == current:
            return current
        current = next_val
    return current  # Should have converged


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Reflective Algebra: Algorithm Demonstrations")
    print("=" * 50)

    # Demo: observations on Fin(4)
    n = 4
    obs = enumerate_observations(n)
    print(f"\nObservations on Fin({n}): {len(obs)}")
    print(f"  Verified range=fixed_points for all: "
          f"{all(image_set(o) == fixed_point_set(o) for o in obs)}")

    # Demo: Green's classes
    classes = green_L_classes(obs)
    print(f"  Green's L-classes: {len(classes)}")

    # Demo: dichotomy test
    encode = lambda x: tuple(x for _ in range(3))  # constant functions
    result = test_dichotomy_conjecture(3, encode, max_steps=10)
    print(f"\nDichotomy test (n=3, constant encoding):")
    for k, v in result.items():
        print(f"  {k}: {v}")

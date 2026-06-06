#!/usr/bin/env python3
"""
Algorithms for Self-Referential Type Theory

Implements the core mathematical algorithms from the formalization:
1. Lawvere diagonal construction
2. Predicate jump operator
3. Knaster-Tarski least/greatest fixed point computation
4. Fixed point spectrum analysis
5. Hierarchy level computation
"""

from typing import (
    TypeVar, Callable, Set, FrozenSet, Optional,
    List, Dict, Tuple, Generic, Any
)
from dataclasses import dataclass
from enum import Enum
import math
import functools

T = TypeVar('T')
S = TypeVar('S')


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Lawvere Diagonal Construction
# ─────────────────────────────────────────────────────────────

def lawvere_diagonal(
    phi: Callable[[T], Callable[[T], S]],
    f: Callable[[S], S],
    domain: List[T]
) -> Callable[[T], S]:
    """
    Construct the Lawvere diagonal: d(a) = f(φ(a)(a)).

    Given an enumeration φ : A → (A → B) and a transformation f : B → B,
    produces a function d : A → B that is NOT in the range of φ
    (provided f has no fixed point).

    Pseudocode:
        LAWVERE-DIAGONAL(φ, f, A):
            for each a ∈ A:
                d(a) ← f(φ(a)(a))
            return d

    Args:
        phi: Enumeration function A → (A → B)
        f: Endomorphism B → B (ideally fixed-point-free)
        domain: Elements of A

    Returns:
        The diagonal function d : A → B
    """
    values: Dict[Any, Any] = {}
    for a in domain:
        values[a] = f(phi(a)(a))
    return lambda x: values[x]


def verify_diagonal_escapes(
    phi: Callable[[T], Callable[[T], S]],
    diagonal: Callable[[T], S],
    domain: List[T]
) -> bool:
    """
    Verify that the diagonal function is not in the range of φ.

    Returns True if for every a ∈ domain, φ(a) ≠ diagonal.
    """
    for a in domain:
        if all(phi(a)(x) == diagonal(x) for x in domain):
            return False  # diagonal IS in range — should not happen!
    return True


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Predicate Jump Operator
# ─────────────────────────────────────────────────────────────

def predicate_jump(
    enum: Callable[[int], Callable[[int], bool]],
    n: int
) -> Callable[[int], bool]:
    """
    Compute the predicate jump of an enumeration.

    The jump J(k) = ¬enum(k)(k) is the simplest form of the
    diagonal construction. It always produces a predicate
    outside the enumeration.

    Pseudocode:
        PREDICATE-JUMP(enum, n):
            for k = 0 to n-1:
                J(k) ← NOT enum(k)(k)
            return J

    Args:
        enum: Enumeration of predicates on {0,...,n-1}
        n: Size of domain

    Returns:
        The jump predicate J : {0,...,n-1} → Bool
    """
    jump_values = {k: not enum(k)(k) for k in range(n)}
    return lambda k: jump_values[k]


def iterate_jump(
    initial_enum: Callable[[int], Callable[[int], bool]],
    n: int,
    levels: int
) -> List[Callable[[int], bool]]:
    """
    Iterate the predicate jump to generate hierarchy levels.

    Each level produces a predicate that escapes all previous levels.

    Returns:
        List of predicates, one per hierarchy level
    """
    hierarchy: List[Callable[[int], bool]] = []
    current_enum = initial_enum

    for level in range(levels):
        jump = predicate_jump(current_enum, n)
        hierarchy.append(jump)

        # Extend enumeration to include the jump at next level
        prev_enum = current_enum
        prev_jump = jump
        def new_enum(k: int, pe=prev_enum, pj=prev_jump, lv=level) -> Callable[[int], bool]:
            if k == lv:
                return pj
            return pe(k)
        current_enum = new_enum

    return hierarchy


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Knaster-Tarski Fixed Point Computation
# ─────────────────────────────────────────────────────────────

def knaster_tarski_lfp(
    f: Callable[[FrozenSet[T]], FrozenSet[T]],
    universe: FrozenSet[T]
) -> FrozenSet[T]:
    """
    Compute the least fixed point of a monotone map on P(universe).

    The lfp is computed as the intersection of all pre-fixed points:
    lfp(f) = ⋂ {S ⊆ universe | f(S) ⊆ S}

    Pseudocode:
        KNASTER-TARSKI-LFP(f, U):
            result ← U
            for each S ⊆ U:
                if f(S) ⊆ S:
                    result ← result ∩ S
            return result

    For large universes, use iterative refinement instead:
        KNASTER-TARSKI-LFP-ITERATIVE(f, U):
            x ← ∅
            repeat:
                x' ← f(x)
                if x' = x: return x
                x ← x'

    Args:
        f: Monotone function on subsets of universe
        universe: The ground set

    Returns:
        The least fixed point of f
    """
    # Iterative computation (works for continuous f)
    current = frozenset()
    while True:
        next_val = f(current)
        if next_val == current:
            return current
        current = next_val
        # Safety: on finite sets this always terminates
        if len(current) > len(universe):
            raise RuntimeError("f is not monotone or universe is wrong")


def knaster_tarski_gfp(
    f: Callable[[FrozenSet[T]], FrozenSet[T]],
    universe: FrozenSet[T]
) -> FrozenSet[T]:
    """
    Compute the greatest fixed point of a monotone map on P(universe).

    gfp(f) = ⋃ {S ⊆ universe | S ⊆ f(S)}

    Uses the dual iterative approach, starting from the universe.
    """
    current = universe
    while True:
        next_val = f(current)
        if next_val == current:
            return current
        current = next_val


def all_fixed_points(
    f: Callable[[FrozenSet[T]], FrozenSet[T]],
    universe: FrozenSet[T]
) -> List[FrozenSet[T]]:
    """
    Enumerate all fixed points of f on P(universe) by brute force.
    Only feasible for small universes (|universe| ≤ ~15).
    """
    from itertools import combinations
    elements = list(universe)
    fps: List[FrozenSet[T]] = []

    for r in range(len(elements) + 1):
        for combo in combinations(elements, r):
            s = frozenset(combo)
            if f(s) == s:
                fps.append(s)

    return fps


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Fixed Point Spectrum Analysis
# ─────────────────────────────────────────────────────────────

@dataclass
class FixedPointSpectrum:
    """Analysis of fixed point properties of an endomorphism."""
    domain_size: int
    total_endomorphisms: int
    with_fixed_points: int
    fixed_point_free: int
    max_fixed_points: int
    avg_fixed_points: float


def analyze_fixed_point_spectrum(n: int) -> FixedPointSpectrum:
    """
    Analyze the fixed point spectrum of all endomorphisms on {0,...,n-1}.

    Pseudocode:
        SPECTRUM(n):
            total ← n^n
            fp_free ← D(n) = Σ_{k=0}^{n} (-1)^k * C(n,k) * (n-k)^n
            with_fp ← total - fp_free
            return (total, with_fp, fp_free)

    Uses inclusion-exclusion for the count of fixed-point-free maps.
    """
    domain = list(range(n))
    total = n ** n

    # Count fixed-point-free maps by inclusion-exclusion
    # Number of maps f:{0,...,n-1}→{0,...,n-1} with no fixed point
    fp_free = 0
    for k in range(n + 1):
        sign = (-1) ** k
        binom = math.comb(n, k)
        fp_free += sign * binom * (n - k) ** n

    with_fp = total - fp_free

    # Average number of fixed points
    # E[|Fix(f)|] = Σ_i P(f(i)=i) = n * (1/n) = 1 for uniform random f
    avg_fp = 1.0  # Always exactly 1 by linearity of expectation

    return FixedPointSpectrum(
        domain_size=n,
        total_endomorphisms=total,
        with_fixed_points=with_fp,
        fixed_point_free=fp_free,
        max_fixed_points=n,
        avg_fixed_points=avg_fp
    )


def count_derangements(n: int) -> int:
    """
    Count derangements (fixed-point-free permutations) of n elements.
    D(n) = n! * Σ_{k=0}^{n} (-1)^k / k!
    """
    result = 0
    factorial_n = math.factorial(n)
    for k in range(n + 1):
        result += ((-1) ** k) * factorial_n // math.factorial(k)
    return result


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Self-Reference Hierarchy Level Computation
# ─────────────────────────────────────────────────────────────

def compute_hierarchy_level(
    predicate: Callable[[int], bool],
    oracle_levels: List[Callable[[int], Callable[[int], bool]]],
    n: int
) -> int:
    """
    Determine the hierarchy level of a predicate.

    A predicate is at level k if it can be defined using an oracle
    for level k-1 but not level k-2. Level 0 predicates are
    "computable" (decidable without oracles).

    This is a finite approximation of the arithmetical hierarchy.

    Pseudocode:
        HIERARCHY-LEVEL(P, oracles, n):
            for level = 0, 1, 2, ...:
                if P is in range of oracles[level]:
                    return level
            return ∞  (P transcends all levels)
    """
    pred_values = tuple(predicate(k) for k in range(n))

    for level, oracle_enum in enumerate(oracle_levels):
        for idx in range(n):
            oracle_values = tuple(oracle_enum(idx)(k) for k in range(n))
            if oracle_values == pred_values:
                return level

    return len(oracle_levels)  # Beyond all known levels


# ─────────────────────────────────────────────────────────────
# Algorithm 6: Fixed Point Transport
# ─────────────────────────────────────────────────────────────

def fixed_point_transport(
    f: Callable[[T], T],
    g: Callable[[T], T],
    domain: List[T]
) -> Tuple[Set[T], Set[T], Dict[T, T]]:
    """
    Compute fixed points of g∘f and f∘g, and verify the transport map.

    By our theorem, f maps Fix(g∘f) into Fix(f∘g).

    Pseudocode:
        TRANSPORT(f, g, domain):
            Fix_gf ← {x ∈ domain | g(f(x)) = x}
            Fix_fg ← {x ∈ domain | f(g(x)) = x}
            for x ∈ Fix_gf:
                assert f(x) ∈ Fix_fg
            return (Fix_gf, Fix_fg, transport_map)

    Returns:
        (Fix(g∘f), Fix(f∘g), transport_map: x ↦ f(x) for x ∈ Fix(g∘f))
    """
    fix_gf = {x for x in domain if g(f(x)) == x}
    fix_fg = {x for x in domain if f(g(x)) == x}

    transport = {}
    for x in fix_gf:
        fx = f(x)
        assert fx in fix_fg, f"Transport failed: f({x}) = {fx} ∉ Fix(f∘g)"
        transport[x] = fx

    return fix_gf, fix_fg, transport


if __name__ == "__main__":
    print("=== Fixed Point Spectrum Analysis ===")
    for n in range(1, 7):
        spec = analyze_fixed_point_spectrum(n)
        pct = spec.with_fixed_points / spec.total_endomorphisms * 100
        print(f"  |S|={n}: {spec.total_endomorphisms} endos, "
              f"{spec.with_fixed_points} with FP ({pct:.1f}%), "
              f"{spec.fixed_point_free} FP-free")

    print("\n=== Derangement Counts ===")
    for n in range(1, 11):
        d = count_derangements(n)
        ratio = d / math.factorial(n)
        print(f"  D({n}) = {d}, D({n})/{n}! = {ratio:.6f} → 1/e ≈ {1/math.e:.6f}")

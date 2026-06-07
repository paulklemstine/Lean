#!/usr/bin/env python3
"""
Algorithms for Convergent Self-Reference Theory

Type-hinted implementations of the core algorithms:
1. Kleene chain computation
2. Convergence index computation
3. Stratum partitioning
4. Tropical semiring operations
5. Horn clause proof system
"""

from typing import TypeVar, Callable, Optional, List, Tuple, Set, Dict
from dataclasses import dataclass
from math import inf

T = TypeVar('T')


# ============================================================
# Algorithm 1: Kleene Chain Computation
# ============================================================

def compute_kleene_chain(
    F: Callable[[T], T],
    bot: T,
    max_steps: int
) -> List[T]:
    """
    Compute the Kleene chain F^0(⊥), F^1(⊥), ..., F^n(⊥).

    Pseudocode:
        x ← ⊥
        chain ← [x]
        for i in 1..max_steps:
            x ← F(x)
            chain.append(x)
            if x = chain[-2]: break
        return chain

    Args:
        F: Monotone operator
        bot: Bottom element of the lattice
        max_steps: Maximum number of iterations

    Returns:
        List of Kleene chain values
    """
    chain: List[T] = [bot]
    x = bot
    for _ in range(max_steps):
        x = F(x)
        chain.append(x)
        if x == chain[-2]:
            break
    return chain


def find_fixed_point(
    F: Callable[[T], T],
    bot: T,
    max_steps: int = 1000
) -> Tuple[Optional[int], T]:
    """
    Find the least fixed point of F by Kleene iteration.

    Pseudocode:
        x ← ⊥; k ← 0
        repeat:
            x' ← F(x)
            if x' = x: return (k, x)
            x ← x'; k ← k + 1
        return (None, x)

    Returns:
        (stabilization_index, fixed_point) or (None, last_value) if doesn't converge
    """
    x = bot
    for k in range(max_steps):
        x_next = F(x)
        if x_next == x:
            return k, x
        x = x_next
    return None, x


# ============================================================
# Algorithm 2: Convergence Index Computation
# ============================================================

def convergence_index(
    F: Callable[[T], T],
    bot: T,
    le: Callable[[T, T], bool],
    target: T,
    max_steps: int = 1000
) -> Optional[int]:
    """
    Compute the convergence index of `target` under operator F.

    Pseudocode:
        x ← ⊥; k ← 0
        repeat:
            if target ≤ x: return k
            x ← F(x); k ← k + 1
        return ∞

    Args:
        F: Monotone operator
        bot: Bottom element
        le: Partial order comparison
        target: Element whose convergence index to compute
        max_steps: Maximum iterations

    Returns:
        Convergence index k, or None if not reached
    """
    x = bot
    for k in range(max_steps):
        if le(target, x):
            return k
        x = F(x)
    return None


# ============================================================
# Algorithm 3: Stratum Partitioning
# ============================================================

def compute_strata(
    F: Callable[[T], T],
    bot: T,
    elements: List[T],
    le: Callable[[T, T], bool],
    max_steps: int = 100
) -> Dict[int, List[T]]:
    """
    Partition elements into convergence strata.

    Returns dict mapping stratum index to list of elements in that stratum.
    Elements not reached within max_steps are placed in stratum -1.
    """
    strata: Dict[int, List[T]] = {}
    assigned: Set[int] = set()

    x = bot
    prev_x = None

    for k in range(max_steps):
        new_elements = []
        for i, elem in enumerate(elements):
            if i not in assigned and le(elem, x):
                new_elements.append(elem)
                assigned.add(i)

        if new_elements:
            strata[k] = new_elements

        x_next = F(x)
        if x_next == x:
            break
        prev_x = x
        x = x_next

    # Unassigned elements
    unassigned = [elements[i] for i in range(len(elements)) if i not in assigned]
    if unassigned:
        strata[-1] = unassigned

    return strata


# ============================================================
# Algorithm 4: Tropical Semiring
# ============================================================

@dataclass
class TropicalIndex:
    """Tropical convergence index: element of ℕ ∪ {∞}."""
    value: float  # Use float('inf') for ⊤

    @staticmethod
    def zero() -> 'TropicalIndex':
        """Additive identity (∞ = unreachable)."""
        return TropicalIndex(inf)

    @staticmethod
    def one() -> 'TropicalIndex':
        """Multiplicative identity (0 = axiom)."""
        return TropicalIndex(0)

    def __add__(self, other: 'TropicalIndex') -> 'TropicalIndex':
        """Tropical addition = min."""
        return TropicalIndex(min(self.value, other.value))

    def __mul__(self, other: 'TropicalIndex') -> 'TropicalIndex':
        """Tropical multiplication = +."""
        if self.value == inf or other.value == inf:
            return TropicalIndex(inf)
        return TropicalIndex(self.value + other.value)

    def __repr__(self) -> str:
        return "∞" if self.value == inf else str(int(self.value))


# ============================================================
# Algorithm 5: Horn Clause Proof System
# ============================================================

@dataclass
class HornClause:
    """A Horn clause: premises -> conclusion."""
    premises: List[int]  # Indices of premise propositions
    conclusion: int  # Index of conclusion proposition


def horn_clause_step(
    n: int,
    clauses: List[HornClause],
    state: Tuple[bool, ...]
) -> Tuple[bool, ...]:
    """
    One step of Horn clause closure.

    For each proposition p, p is true if:
    - p was already true, OR
    - some clause with conclusion p has all premises true

    This operator is monotone by construction.
    """
    result = list(state)
    for clause in clauses:
        if all(state[p] for p in clause.premises):
            result[clause.conclusion] = True
    return tuple(result)


def horn_clause_fixed_point(
    n: int,
    clauses: List[HornClause]
) -> Tuple[bool, ...]:
    """Compute the least fixed point of a Horn clause system."""
    step = lambda s: horn_clause_step(n, clauses, s)
    _, fp = find_fixed_point(step, tuple([False] * n), max_steps=n + 1)
    return fp


# ============================================================
# Algorithm 6: Convergence-Divergence Classifier
# ============================================================

def classify_self_reference(
    F: Callable[[T], T],
    bot: T,
    max_steps: int = 100
) -> str:
    """
    Classify a function as convergent or divergent.

    Returns:
        "convergent(N)" where N is the stabilization index, or
        "divergent" if no stabilization found
    """
    x = bot
    for k in range(max_steps):
        x_next = F(x)
        if x_next == x:
            return f"convergent({k})"
        x = x_next
    return "divergent"


if __name__ == "__main__":
    # Example: Horn clause system
    clauses = [
        HornClause([], 0),       # Axiom: P0
        HornClause([0], 1),      # P0 -> P1
        HornClause([1], 2),      # P1 -> P2
        HornClause([0, 2], 3),   # P0, P2 -> P3
    ]

    fp = horn_clause_fixed_point(4, clauses)
    print(f"Horn clause fixed point: {fp}")

    # Convergence indices
    step = lambda s: horn_clause_step(4, clauses, s)
    chain = compute_kleene_chain(step, (False,) * 4, 10)
    for i, c in enumerate(chain):
        print(f"  Step {i}: {c}")

    # Tropical arithmetic
    a = TropicalIndex(2)
    b = TropicalIndex(3)
    c = TropicalIndex(5)
    print(f"\nTropical: {a} ⊗ ({b} ⊕ {c}) = {a * (b + c)}")
    print(f"Tropical: ({a} ⊗ {b}) ⊕ ({a} ⊗ {c}) = {(a * b) + (a * c)}")

#!/usr/bin/env python3
"""
Algorithms for Reflective Type Algebras

Type-hinted implementations of the core computational procedures
for working with RTAs on finite lattices.
"""

from typing import TypeVar, Callable, Set, Optional, List, Tuple, Generic
from dataclasses import dataclass
from functools import reduce

T = TypeVar('T')


@dataclass
class ReflectiveTypeAlgebra(Generic[T]):
    """A Reflective Type Algebra on a finite lattice.
    
    Attributes:
        elements: All elements of the lattice
        le: Partial order relation
        bot: Bottom element
        top: Top element
        sup: Join operation
        inf: Meet operation
        phi: Type-forming operator (monotone)
        rho: Reflection operator (monotone, commutes with phi)
    """
    elements: List[T]
    le: Callable[[T, T], bool]
    bot: T
    top: T
    sup: Callable[[T, T], T]
    inf: Callable[[T, T], T]
    phi: Callable[[T, T], T]  # Actually T -> T but keeping generic
    rho: Callable[[T, T], T]


def kleene_chain(phi: Callable[[T], T], bot: T, max_steps: int = 100) -> List[T]:
    """Compute the Kleene chain: ⊥, Φ(⊥), Φ²(⊥), ...
    
    Terminates when a fixed point is reached or max_steps exceeded.
    
    Algorithm:
        x₀ = ⊥
        x_{n+1} = Φ(xₙ)
        Stop when x_{n+1} = xₙ
    
    Returns: List of chain elements [x₀, x₁, ..., x_fp]
    """
    chain: List[T] = [bot]
    for _ in range(max_steps):
        next_val = phi(chain[-1])
        chain.append(next_val)
        if next_val == chain[-2]:
            break
    return chain


def find_fixed_points(phi: Callable[[T], T], elements: List[T]) -> List[T]:
    """Find all fixed points of Φ in a finite lattice.
    
    Algorithm: Brute-force check Φ(x) = x for each element.
    
    Returns: List of fixed points
    """
    return [x for x in elements if phi(x) == x]


def lawvere_witness(
    encode: Callable[[T, T], T],
    f: Callable[[T], T],
    elements: List[T]
) -> Optional[T]:
    """Find the Lawvere fixed-point witness.
    
    Given e : α → (α → β) and f : β → β, find a such that f(e(a)(a)) = e(a)(a).
    
    Algorithm:
        1. Compute g(x) = f(e(x)(x)) for each x
        2. Find a such that e(a) = g (surjectivity witness)
        3. Return a
    
    Returns: The witness a, or None if e is not surjective enough
    """
    # Compute g
    g = {x: f(encode(x, x)) for x in elements}
    
    # Find a such that e(a) agrees with g on all inputs
    for a in elements:
        if all(encode(a, x) == g[x] for x in elements):
            return a
    return None


def cantor_anti_diagonal(
    encode: Callable[[int, int], bool],
    n: int
) -> Callable[[int], bool]:
    """Construct Cantor's anti-diagonal predicate.
    
    Given e : {0,...,n-1} → ({0,...,n-1} → Bool),
    returns D(i) = ¬e(i)(i).
    
    This predicate provably differs from e(a) for every a.
    
    Algorithm:
        D(i) = not e(i, i)
    """
    return lambda i: not encode(i, i)


def reflection_depth(
    phi: Callable[[T], T],
    bot: T,
    x: T,
    le: Callable[[T, T], bool],
    max_depth: int = 100
) -> Optional[int]:
    """Compute the reflection depth of an element.
    
    The reflection depth of x is the least n such that Φⁿ(⊥) ≥ x.
    
    Algorithm:
        Iterate the Kleene chain until Φⁿ(⊥) ≥ x or max_depth reached.
    
    Returns: The depth n, or None if not reached within max_depth
    """
    current = bot
    for n in range(max_depth + 1):
        if le(x, current):
            return n
        current = phi(current)
    return None


def strict_hierarchy_check(
    phi: Callable[[T], T],
    bot: T,
    lt: Callable[[T, T], bool],
    max_depth: int = 100
) -> Tuple[bool, int]:
    """Check if the Kleene chain is strictly increasing.
    
    Algorithm:
        Compute chain and verify chain[n] < chain[n+1] at each step.
    
    Returns: (is_strict, depth_where_equality_first_occurs)
    """
    chain = kleene_chain(phi, bot, max_depth)
    for i in range(len(chain) - 1):
        if not lt(chain[i], chain[i + 1]):
            return (False, i)
    return (True, len(chain) - 1)


def interval_fixed_point(
    phi: Callable[[T], T],
    le: Callable[[T, T], bool],
    elements: List[T],
    b: T,
    a: T
) -> Optional[T]:
    """Find a fixed point in the interval [b, a].
    
    Preconditions: Φ(a) ≤ a, b ≤ Φ(b), b ≤ a.
    
    Algorithm:
        Take the greatest post-fixed point in [b, a].
        By Knaster-Tarski, this is a fixed point.
    
    Returns: A fixed point in [b, a], or None
    """
    interval = [x for x in elements if le(b, x) and le(x, a)]
    fps = [x for x in interval if phi(x) == x]
    return fps[0] if fps else None


# ============================================================
# Demo: Power Set Lattice
# ============================================================

def demo_powerset_rta():
    """Demonstrate algorithms on the power set lattice P({0,1,2,3})."""
    U = frozenset({0, 1, 2, 3})
    elements = [frozenset(s) for i in range(2**len(U)) 
                for s in [frozenset(j for j in U if i & (1 << j))]]
    
    def phi(S: frozenset) -> frozenset:
        remaining = U - S
        return S | frozenset({min(remaining)}) if remaining else S
    
    # Kleene chain
    chain = kleene_chain(phi, frozenset(), 10)
    print("Kleene chain:")
    for i, s in enumerate(chain):
        print(f"  Step {i}: {set(s) if s else set()}")
    
    # Fixed points
    fps = find_fixed_points(phi, elements)
    print(f"\nFixed points: {[set(s) for s in fps]}")
    
    # Reflection depth
    for test in [frozenset(), frozenset({0}), frozenset({0, 1}), U]:
        d = reflection_depth(phi, frozenset(), test,
                            lambda a, b: a.issubset(b))
        print(f"  Depth of {set(test) if test else set()}: {d}")
    
    # Strict hierarchy
    is_strict, depth = strict_hierarchy_check(
        phi, frozenset(),
        lambda a, b: a.issubset(b) and a != b
    )
    print(f"\nStrict hierarchy: {is_strict} (up to depth {depth})")


if __name__ == "__main__":
    demo_powerset_rta()

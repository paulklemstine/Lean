"""
Algorithms for Arrow-Depth Exponential Complexity Analysis of Simple Types.

Implements the core type invariants and bounds from the formal verification:
- Type depth, size, complexity, arrow width
- typeStateBound computation
- Chain type detection
- Predicted bound computation
- Extremal family generators (bushy, chain)

All algorithms match the formally verified Lean 4 definitions.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class Ty:
    """Simple type: either base or arrow(domain, codomain)."""
    pass


@dataclass
class Base(Ty):
    """The base type."""
    def __repr__(self) -> str:
        return "o"


@dataclass
class Arrow(Ty):
    """Arrow (function) type: domain → codomain."""
    domain: Ty
    codomain: Ty

    def __repr__(self) -> str:
        d = repr(self.domain)
        c = repr(self.codomain)
        if isinstance(self.domain, Arrow):
            d = f"({d})"
        return f"{d} → {c}"


# ---------- Core Invariants ----------

def depth(ty: Ty) -> int:
    """Arrow nesting depth. O(size) time.

    >>> depth(Base())
    0
    >>> depth(Arrow(Base(), Base()))
    1
    """
    if isinstance(ty, Base):
        return 0
    assert isinstance(ty, Arrow)
    return 1 + max(depth(ty.domain), depth(ty.codomain))


def size(ty: Ty) -> int:
    """Number of type constructors. O(size) time.

    >>> size(Base())
    1
    >>> size(Arrow(Base(), Base()))
    3
    """
    if isinstance(ty, Base):
        return 1
    assert isinstance(ty, Arrow)
    return 1 + size(ty.domain) + size(ty.codomain)


def complexity(ty: Ty) -> int:
    """Multiplicative complexity measure. Equals typeStateBound.

    >>> complexity(Base())
    1
    >>> complexity(Arrow(Base(), Base()))
    4
    """
    if isinstance(ty, Base):
        return 1
    assert isinstance(ty, Arrow)
    return (complexity(ty.domain) + 1) * (complexity(ty.codomain) + 1)


def type_state_bound(ty: Ty) -> int:
    """Semantic state complexity bound. Identical to complexity.

    >>> type_state_bound(Base())
    1
    >>> type_state_bound(Arrow(Base(), Arrow(Base(), Base())))
    10
    """
    if isinstance(ty, Base):
        return 1
    assert isinstance(ty, Arrow)
    return (type_state_bound(ty.domain) + 1) * (type_state_bound(ty.codomain) + 1)


def arrow_width(ty: Ty) -> int:
    """Number of arrow constructors in the type.

    Satisfies: 2 * arrow_width(A) + 1 = size(A)

    >>> arrow_width(Base())
    0
    >>> arrow_width(Arrow(Base(), Base()))
    1
    """
    if isinstance(ty, Base):
        return 0
    assert isinstance(ty, Arrow)
    return 1 + arrow_width(ty.domain) + arrow_width(ty.codomain)


def is_chain_type(ty: Ty) -> bool:
    """Check if type is a chain type (right-spined with base arguments).

    >>> is_chain_type(Base())
    True
    >>> is_chain_type(Arrow(Base(), Arrow(Base(), Base())))
    True
    >>> is_chain_type(Arrow(Arrow(Base(), Base()), Base()))
    False
    """
    if isinstance(ty, Base):
        return True
    assert isinstance(ty, Arrow)
    return isinstance(ty.domain, Base) and is_chain_type(ty.codomain)


def depth_profile(ty: Ty, k: int) -> int:
    """Count type nodes at residual depth k.

    >>> depth_profile(Arrow(Base(), Base()), 0)
    1
    >>> depth_profile(Arrow(Base(), Base()), 1)
    2
    """
    if isinstance(ty, Base):
        return 1 if k == 0 else 0
    assert isinstance(ty, Arrow)
    if k == 0:
        return 1
    return depth_profile(ty.domain, k - 1) + depth_profile(ty.codomain, k - 1)


def predicted_bound(ty: Ty) -> int:
    """Certified upper bound: 2^size - 1.

    Theorem: type_state_bound(A) <= predicted_bound(A) for all A.

    >>> predicted_bound(Base())
    1
    >>> predicted_bound(Arrow(Base(), Base()))
    7
    """
    return 2 ** size(ty) - 1


# ---------- Extremal Families ----------

def bushy(n: int) -> Ty:
    """Balanced binary arrow tree of depth n.

    Maximizes typeStateBound at each depth level.
    Growth: typeStateBound(bushy(n)) + 1 >= 2^(2^n)

    >>> bushy(0)
    o
    >>> bushy(2)
    (o → o) → o → o
    """
    if n == 0:
        return Base()
    sub = bushy(n - 1)
    return Arrow(sub, sub)


def chain(n: int) -> Ty:
    """Right-spined chain type of depth n: base → base → ... → base.

    Minimizes typeStateBound among types of given depth.
    Growth: typeStateBound(chain(n)) = 3 * 2^n - 2

    >>> chain(0)
    o
    >>> chain(2)
    o → o → o
    """
    if n == 0:
        return Base()
    return Arrow(Base(), chain(n - 1))


# ---------- Analysis ----------

def analyze_type(ty: Ty) -> dict:
    """Compute all invariants for a given type.

    Returns dict with depth, size, complexity, arrow_width, type_state_bound,
    predicted_bound, is_chain, and bound verification.
    """
    tsb = type_state_bound(ty)
    pb = predicted_bound(ty)
    d = depth(ty)
    return {
        "type": repr(ty),
        "depth": d,
        "size": size(ty),
        "complexity": complexity(ty),
        "arrow_width": arrow_width(ty),
        "type_state_bound": tsb,
        "predicted_bound": pb,
        "is_chain": is_chain_type(ty),
        "bound_verified": tsb <= pb,
        "depth_profile": [depth_profile(ty, k) for k in range(d + 2)],
    }


def enumerate_types(max_depth: int) -> List[Ty]:
    """Enumerate all simple types up to a given depth.

    >>> len(enumerate_types(0))
    1
    >>> len(enumerate_types(1))
    2
    """
    if max_depth == 0:
        return [Base()]
    prev = enumerate_types(max_depth - 1)
    result = list(prev)
    for a in prev:
        for b in prev:
            result.append(Arrow(a, b))
    return result


def search_counterexample_depth_bound(c: int, max_n: int = 20) -> Optional[Tuple[Ty, int]]:
    """Search for a type A where typeStateBound(A) > c^(depth(A)+1).

    The impossibility theorem guarantees such a type exists for every c.

    Returns (type, n) where bushy(n) violates the bound, or None if not found
    within max_n.

    >>> result = search_counterexample_depth_bound(2)
    >>> result is not None
    True
    """
    for n in range(max_n):
        ty = bushy(n)
        tsb = type_state_bound(ty)
        bound = c ** (depth(ty) + 1)
        if tsb > bound:
            return (ty, n)
    return None


if __name__ == "__main__":
    import doctest
    doctest.testmod()

    print("=== Type Invariant Analysis ===\n")

    # Analyze bushy family
    print("Bushy types (maximally branching):")
    print(f"{'n':>3} {'depth':>5} {'size':>6} {'aw':>4} {'tsb':>15} {'2^(2^n)':>15}")
    for n in range(7):
        ty = bushy(n)
        info = analyze_type(ty)
        print(f"{n:>3} {info['depth']:>5} {info['size']:>6} {info['arrow_width']:>4} "
              f"{info['type_state_bound']:>15} {2**(2**n):>15}")

    print("\nChain types (minimally branching):")
    print(f"{'n':>3} {'depth':>5} {'size':>6} {'aw':>4} {'tsb':>10} {'3^(d+1)':>10}")
    for n in range(8):
        ty = chain(n)
        info = analyze_type(ty)
        print(f"{n:>3} {info['depth']:>5} {info['size']:>6} {info['arrow_width']:>4} "
              f"{info['type_state_bound']:>10} {3**(info['depth']+1):>10}")

    print("\n=== Counterexample Search ===")
    for c in [2, 3, 5, 10, 100]:
        result = search_counterexample_depth_bound(c)
        if result:
            ty, n = result
            print(f"c={c:>4}: bushy({n}) violates bound "
                  f"(tsb={type_state_bound(ty)}, bound={c**(depth(ty)+1)})")

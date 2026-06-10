#!/usr/bin/env python3
"""
algorithms.py - Core ACI normalization algorithms for tropical expressions.

Implements the flatten → sort → deduplicate → rebuild pipeline that
constitutes a certified decision procedure for ACI equivalence.
"""

from typing import List, Dict, Any, Tuple
from dataclasses import dataclass
from abc import ABC, abstractmethod


# --- Expression Types ---

class TropExpr(ABC):
    """Abstract base for tropical expressions."""
    @abstractmethod
    def eval(self, env: Dict[int, float]) -> float:
        pass

    @abstractmethod
    def _sort_key(self) -> Tuple:
        pass

    def __lt__(self, other):
        return self._sort_key() < other._sort_key()

    def __le__(self, other):
        return self._sort_key() <= other._sort_key()


@dataclass(frozen=True)
class Const(TropExpr):
    val: float
    def eval(self, env): return self.val
    def _sort_key(self): return (0, self.val)
    def __repr__(self): return str(self.val)


@dataclass(frozen=True)
class Var(TropExpr):
    name: int
    def eval(self, env): return env.get(self.name, 0.0)
    def _sort_key(self): return (1, self.name)
    def __repr__(self): return f"x{self.name}"


@dataclass(frozen=True)
class TMin(TropExpr):
    left: TropExpr
    right: TropExpr
    def eval(self, env): return min(self.left.eval(env), self.right.eval(env))
    def _sort_key(self): return (2, self.left._sort_key(), self.right._sort_key())
    def __repr__(self): return f"min({self.left}, {self.right})"


@dataclass(frozen=True)
class Add(TropExpr):
    left: TropExpr
    right: TropExpr
    def eval(self, env): return self.left.eval(env) + self.right.eval(env)
    def _sort_key(self): return (3, self.left._sort_key(), self.right._sort_key())
    def __repr__(self): return f"({self.left} + {self.right})"


# --- Flatten ---

def flatten_min(e: TropExpr) -> List[TropExpr]:
    """
    Flatten nested min-expressions into a list of children.
    
    Time: O(n) where n is the expression size.
    Space: O(n) for the output list.
    
    Invariant: All returned elements are NOT TMin nodes.
    
    >>> flatten_min(TMin(Var(0), TMin(Var(1), Var(2))))
    [x0, x1, x2]
    """
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]


def flatten_add(e: TropExpr) -> List[TropExpr]:
    """
    Flatten nested add-expressions into a list of children.
    
    Time: O(n), Space: O(n).
    """
    if isinstance(e, Add):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]


# --- Deduplication ---

def dedup_sorted(lst: List[TropExpr]) -> List[TropExpr]:
    """
    Remove adjacent duplicates from a sorted list.
    
    Time: O(n), Space: O(n).
    
    This is the key operation that distinguishes ACI from AC normalization.
    It implements the transition from multisets to finite sets.
    
    >>> dedup_sorted([Var(0), Var(0), Var(1), Var(1), Var(2)])
    [x0, x1, x2]
    """
    if not lst:
        return []
    result = [lst[0]]
    for item in lst[1:]:
        if item != result[-1]:
            result.append(item)
    return result


# --- Rebuild ---

def rebuild_min(children: List[TropExpr]) -> TropExpr:
    """
    Rebuild a right-associated min tree from a non-empty list.
    
    Time: O(n), Space: O(n) (for the tree structure).
    """
    assert children, "Cannot rebuild from empty list"
    if len(children) == 1:
        return children[0]
    return TMin(children[0], rebuild_min(children[1:]))


def rebuild_add(children: List[TropExpr]) -> TropExpr:
    """Rebuild a right-associated add tree from a non-empty list."""
    assert children, "Cannot rebuild from empty list"
    if len(children) == 1:
        return children[0]
    return Add(children[0], rebuild_add(children[1:]))


# --- Normalization ---

def normalize_ac(e: TropExpr) -> TropExpr:
    """
    AC normalization: flatten, sort, rebuild.
    
    Handles commutativity and associativity of both min and +.
    Does NOT handle idempotence of min.
    
    Time: O(n log n) due to sorting.
    Space: O(n).
    """
    if isinstance(e, (Const, Var)):
        return e
    if isinstance(e, TMin):
        ne1 = normalize_ac(e.left)
        ne2 = normalize_ac(e.right)
        children = flatten_min(TMin(ne1, ne2))
        children.sort()
        return rebuild_min(children)
    if isinstance(e, Add):
        ne1 = normalize_ac(e.left)
        ne2 = normalize_ac(e.right)
        children = flatten_add(Add(ne1, ne2))
        children.sort()
        return rebuild_add(children)
    return e


def normalize_aci(e: TropExpr) -> TropExpr:
    """
    ACI normalization: flatten, sort, DEDUPLICATE, rebuild.
    
    Handles commutativity, associativity, and IDEMPOTENCE of min.
    The deduplication step is the key difference from AC normalization.
    
    Time: O(n log n) due to sorting.
    Space: O(n).
    
    Properties (proved in the formal development):
    - Soundness: eval(normalize_aci(e)) = eval(e) for all environments
    - Completeness: normalize_aci(e1) = normalize_aci(e2) iff ACIEquiv(e1, e2)
    - Idempotence: normalize_aci(normalize_aci(e)) = normalize_aci(e)
    - Strict strengthening: identifies more equalities than AC
    """
    if isinstance(e, (Const, Var)):
        return e
    if isinstance(e, TMin):
        ne1 = normalize_aci(e.left)
        ne2 = normalize_aci(e.right)
        children = flatten_min(TMin(ne1, ne2))
        children.sort()
        children = dedup_sorted(children)  # Key ACI step
        return rebuild_min(children)
    if isinstance(e, Add):
        ne1 = normalize_aci(e.left)
        ne2 = normalize_aci(e.right)
        children = flatten_add(Add(ne1, ne2))
        children.sort()
        return rebuild_add(children)
    return e


def aci_equiv(e1: TropExpr, e2: TropExpr) -> bool:
    """
    Decision procedure: are two expressions ACI-equivalent?
    
    Time: O(n log n) where n = max(|e1|, |e2|).
    
    This is the main practical payoff of the ACI normalizer.
    """
    return normalize_aci(e1) == normalize_aci(e2)


if __name__ == "__main__":
    x, y, z = Var(0), Var(1), Var(2)
    
    # Idempotence
    assert aci_equiv(TMin(x, x), x)
    assert not (normalize_ac(TMin(x, x)) == normalize_ac(x))
    
    # Absorption of duplicates
    assert aci_equiv(TMin(x, TMin(x, y)), TMin(x, y))
    
    # Complex example
    assert aci_equiv(
        TMin(TMin(x, y), TMin(y, z)),
        TMin(x, TMin(y, z))
    )
    
    print("All algorithm tests passed!")

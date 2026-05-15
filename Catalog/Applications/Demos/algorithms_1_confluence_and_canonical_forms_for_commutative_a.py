#!/usr/bin/env python3
"""
Tropical AC Normalization — Algorithms

Complete implementations of the canonicalization algorithm and supporting
data structures for tropical (min-plus) expression normalization.

Algorithm complexity:
  - normalize_ca: O(n log n) per node, O(n² log n) total for expression of size n
  - AC equivalence check: O(n² log n) via normalization + structural equality
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, Callable, List, Tuple
from collections import Counter


# ─── Expression AST ──────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Const:
    """A real constant in a tropical expression."""
    value: float

@dataclass(frozen=True)
class Var:
    """A variable (indexed by natural number) in a tropical expression."""
    index: int

@dataclass(frozen=True)
class TMin:
    """Binary tropical minimum node."""
    left: 'TropExpr'
    right: 'TropExpr'

@dataclass(frozen=True)
class Add:
    """Binary tropical addition node."""
    left: 'TropExpr'
    right: 'TropExpr'

TropExpr = Union[Const, Var, TMin, Add]


# ─── Expression Utilities ────────────────────────────────────────────────────

def expr_size(e: TropExpr) -> int:
    """Count the number of nodes in an expression tree.
    
    Time complexity: O(n)
    Space complexity: O(depth) for recursion stack
    """
    if isinstance(e, (Const, Var)):
        return 1
    return 1 + expr_size(e.left) + expr_size(e.right)


def expr_depth(e: TropExpr) -> int:
    """Compute the depth of an expression tree.
    
    Time complexity: O(n)
    """
    if isinstance(e, (Const, Var)):
        return 0
    return 1 + max(expr_depth(e.left), expr_depth(e.right))


def expr_vars(e: TropExpr) -> set[int]:
    """Collect all variable indices appearing in an expression.
    
    Time complexity: O(n)
    """
    if isinstance(e, Const):
        return set()
    elif isinstance(e, Var):
        return {e.index}
    else:
        return expr_vars(e.left) | expr_vars(e.right)


# ─── Evaluation ──────────────────────────────────────────────────────────────

def eval_expr(sigma: Callable[[int], float], e: TropExpr) -> float:
    """Evaluate a tropical expression in environment sigma.
    
    Semantics:
      - const(r) ↦ r
      - var(n) ↦ σ(n)
      - tmin(a, b) ↦ min(eval(a), eval(b))
      - add(a, b) ↦ eval(a) + eval(b)
    
    Time complexity: O(n) where n = expr_size(e)
    """
    if isinstance(e, Const):
        return e.value
    elif isinstance(e, Var):
        return sigma(e.index)
    elif isinstance(e, TMin):
        return min(eval_expr(sigma, e.left), eval_expr(sigma, e.right))
    elif isinstance(e, Add):
        return eval_expr(sigma, e.left) + eval_expr(sigma, e.right)


# ─── Total Order on Expressions ─────────────────────────────────────────────

def expr_sort_key(e: TropExpr) -> tuple:
    """Compute a sort key for the total order on normalized expressions.
    
    Ordering: const < var < tmin < add
    Within same constructor: lexicographic on components.
    
    Time complexity: O(n) where n = expr_size(e)
    """
    if isinstance(e, Const):
        return (0, e.value)
    elif isinstance(e, Var):
        return (1, e.index)
    elif isinstance(e, TMin):
        return (2, expr_sort_key(e.left), expr_sort_key(e.right))
    elif isinstance(e, Add):
        return (3, expr_sort_key(e.left), expr_sort_key(e.right))


# ─── Flattening ──────────────────────────────────────────────────────────────

def flatten_min(e: TropExpr) -> List[TropExpr]:
    """Flatten nested tmin nodes into a list.
    
    Invariant: all elements of the result are non-tmin nodes.
    
    Time complexity: O(n)
    
    Example:
      flatten_min(tmin(tmin(x, y), z)) = [x, y, z]
      flatten_min(add(x, y)) = [add(x, y)]
    """
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]


def flatten_add(e: TropExpr) -> List[TropExpr]:
    """Flatten nested add nodes into a list.
    
    Invariant: all elements of the result are non-add nodes.
    
    Time complexity: O(n)
    """
    if isinstance(e, Add):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]


# ─── Rebuilding ──────────────────────────────────────────────────────────────

def rebuild_min(lst: List[TropExpr]) -> TropExpr:
    """Rebuild a right-associated tmin tree from a nonempty list.
    
    Precondition: lst is nonempty.
    
    Time complexity: O(k) where k = len(lst)
    
    Example:
      rebuild_min([x, y, z]) = tmin(x, tmin(y, z))
    """
    assert lst, "rebuild_min requires nonempty list"
    if len(lst) == 1:
        return lst[0]
    return TMin(lst[0], rebuild_min(lst[1:]))


def rebuild_add(lst: List[TropExpr]) -> TropExpr:
    """Rebuild a right-associated add tree from a nonempty list.
    
    Precondition: lst is nonempty.
    
    Time complexity: O(k) where k = len(lst)
    """
    assert lst, "rebuild_add requires nonempty list"
    if len(lst) == 1:
        return lst[0]
    return Add(lst[0], rebuild_add(lst[1:]))


# ─── The Canonical AC Normalizer ─────────────────────────────────────────────

def normalize_ca(e: TropExpr) -> TropExpr:
    """
    Canonical AC normalizer for tropical expressions.
    
    Algorithm:
      1. Recursively normalize all children
      2. Flatten same-operator chains (associativity normalization)
      3. Sort children by total order (commutativity normalization)
      4. Rebuild right-associated tree
    
    Properties (formally verified):
      - Soundness:    eval(σ, normalize_ca(e)) = eval(σ, e) for all σ
      - Completeness: ACEquiv(e₁, e₂) → normalize_ca(e₁) = normalize_ca(e₂)
      - Idempotence:  normalize_ca(normalize_ca(e)) = normalize_ca(e)
      - Decision:     ACEquiv(e₁, e₂) ↔ normalize_ca(e₁) = normalize_ca(e₂)
    
    Time complexity: O(n² log n) worst case for expression of size n
      - Each node triggers a flatten + sort of its children
      - Sorting is O(k log k) per node with k children
      - Total work is bounded by O(n² log n)
    
    Space complexity: O(n) for the normalized expression
    """
    if isinstance(e, (Const, Var)):
        return e
    elif isinstance(e, TMin):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        children = flatten_min(a) + flatten_min(b)
        children.sort(key=expr_sort_key)
        return rebuild_min(children)
    elif isinstance(e, Add):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        children = flatten_add(a) + flatten_add(b)
        children.sort(key=expr_sort_key)
        return rebuild_add(children)


# ─── AC Equivalence Decision Procedure ───────────────────────────────────────

def is_ac_equivalent(e1: TropExpr, e2: TropExpr) -> bool:
    """
    Decide whether two tropical expressions are AC-equivalent.
    
    This is the certified decision procedure: two expressions are
    AC-equivalent if and only if they have the same canonical form.
    
    Time complexity: O(n² log n) for expressions of total size n
    """
    return normalize_ca(e1) == normalize_ca(e2)


# ─── Multiset Representation ────────────────────────────────────────────────

def to_multiset_tree(e: TropExpr) -> dict:
    """
    Convert a normalized expression to a multiset-based representation.
    
    This reveals the algebraic structure: each operator node becomes
    a multiset of its children (recursively normalized).
    """
    e_norm = normalize_ca(e)
    return _to_multiset(e_norm)


def _to_multiset(e: TropExpr) -> dict:
    if isinstance(e, Const):
        return {"type": "const", "value": e.value}
    elif isinstance(e, Var):
        return {"type": "var", "index": e.index}
    elif isinstance(e, TMin):
        children = flatten_min(e)
        return {"type": "min", "children": [_to_multiset(c) for c in children]}
    elif isinstance(e, Add):
        children = flatten_add(e)
        return {"type": "add", "children": [_to_multiset(c) for c in children]}


# ─── Statistics ──────────────────────────────────────────────────────────────

def normalization_stats(e: TropExpr) -> dict:
    """Compute statistics about the normalization process."""
    n = normalize_ca(e)
    return {
        "original_size": expr_size(e),
        "normalized_size": expr_size(n),
        "original_depth": expr_depth(e),
        "normalized_depth": expr_depth(n),
        "variables": sorted(expr_vars(e)),
        "is_idempotent": normalize_ca(n) == n,
    }


# ─── Pseudocode ──────────────────────────────────────────────────────────────

PSEUDOCODE = """
ALGORITHM: Tropical AC Canonical Normalizer
============================================

INPUT:  A tropical expression e over {const, var, min, +}
OUTPUT: A canonical normal form normalize_ca(e)

PROCEDURE normalize_ca(e):
  CASE e = const(r):
    RETURN const(r)
  
  CASE e = var(n):
    RETURN var(n)
  
  CASE e = min(a, b):
    a' ← normalize_ca(a)
    b' ← normalize_ca(b)
    children ← flatten_min(a') ++ flatten_min(b')
    sorted_children ← SORT(children, by total_order)
    RETURN rebuild_min(sorted_children)
  
  CASE e = add(a, b):
    a' ← normalize_ca(a)
    b' ← normalize_ca(b)
    children ← flatten_add(a') ++ flatten_add(b')
    sorted_children ← SORT(children, by total_order)
    RETURN rebuild_add(sorted_children)

SUBROUTINE flatten_min(e):
  IF e = min(a, b) THEN
    RETURN flatten_min(a) ++ flatten_min(b)
  ELSE
    RETURN [e]

SUBROUTINE rebuild_min([x₁, ..., xₖ]):
  IF k = 1 THEN RETURN x₁
  ELSE RETURN min(x₁, rebuild_min([x₂, ..., xₖ]))

COMPLEXITY:
  Time:  O(n² log n) worst case
  Space: O(n) for the output

CORRECTNESS (formally verified):
  1. Soundness:    ∀σ. eval(σ, normalize_ca(e)) = eval(σ, e)
  2. Completeness: ACEquiv(e₁, e₂) → normalize_ca(e₁) = normalize_ca(e₂)
  3. Idempotence:  normalize_ca(normalize_ca(e)) = normalize_ca(e)
  4. Decision:     ACEquiv(e₁, e₂) ↔ normalize_ca(e₁) = normalize_ca(e₂)
"""


if __name__ == "__main__":
    # Quick self-test
    x, y, z = Var(0), Var(1), Var(2)
    
    # Test commutativity
    assert is_ac_equivalent(TMin(x, y), TMin(y, x))
    assert is_ac_equivalent(Add(x, y), Add(y, x))
    
    # Test associativity
    assert is_ac_equivalent(TMin(TMin(x, y), z), TMin(x, TMin(y, z)))
    assert is_ac_equivalent(Add(Add(x, y), z), Add(x, Add(y, z)))
    
    # Test non-equivalence
    assert not is_ac_equivalent(TMin(x, y), Add(x, y))
    
    # Test idempotence
    for e in [TMin(Add(x, y), z), Add(TMin(x, z), y)]:
        n = normalize_ca(e)
        assert normalize_ca(n) == n
    
    print("All self-tests passed!")
    print()
    print(PSEUDOCODE)

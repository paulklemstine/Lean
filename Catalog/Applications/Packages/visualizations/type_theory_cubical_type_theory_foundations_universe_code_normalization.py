#!/usr/bin/env python3
"""
Algorithms from the Cubical Semantics research paper.
Includes normalization, equivalence detection, and path construction algorithms.
"""
from typing import Union, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum, auto

# ============================================================
# Algorithm 1: Universe Code Normalization
# ============================================================

class CodeTag(Enum):
    ZERO = auto()
    ONE = auto()
    BOOL = auto()
    SUM = auto()
    PROD = auto()

@dataclass
class UCode:
    """Universe code for finite types."""
    tag: CodeTag
    children: Tuple['UCode', ...] = ()

    def __repr__(self):
        if self.tag == CodeTag.ZERO: return "∅"
        if self.tag == CodeTag.ONE: return "𝟏"
        if self.tag == CodeTag.BOOL: return "𝟐"
        if self.tag == CodeTag.SUM:
            return f"({self.children[0]} + {self.children[1]})"
        if self.tag == CodeTag.PROD:
            return f"({self.children[0]} × {self.children[1]})"
        return "?"

# Constructors
ZERO = UCode(CodeTag.ZERO)
ONE = UCode(CodeTag.ONE)
BOOL = UCode(CodeTag.BOOL)
def SUM(a: UCode, b: UCode) -> UCode:
    return UCode(CodeTag.SUM, (a, b))
def PROD(a: UCode, b: UCode) -> UCode:
    return UCode(CodeTag.PROD, (a, b))

def cardinality(c: UCode) -> int:
    """
    Compute the cardinality of a universe code.

    Time complexity: O(n) where n is the size of the code tree.
    Space complexity: O(d) where d is the depth (recursion stack).

    Examples:
        >>> cardinality(ZERO)
        0
        >>> cardinality(BOOL)
        2
        >>> cardinality(SUM(BOOL, ONE))
        3
        >>> cardinality(PROD(BOOL, BOOL))
        4
    """
    if c.tag == CodeTag.ZERO: return 0
    if c.tag == CodeTag.ONE: return 1
    if c.tag == CodeTag.BOOL: return 2
    if c.tag == CodeTag.SUM:
        return cardinality(c.children[0]) + cardinality(c.children[1])
    if c.tag == CodeTag.PROD:
        return cardinality(c.children[0]) * cardinality(c.children[1])
    raise ValueError(f"Unknown code tag: {c.tag}")

def canonical(n: int) -> UCode:
    """
    Construct the canonical code for a given cardinality.

    The canonical form uses unary representation:
        0 → ∅, 1 → 𝟏, n+2 → 𝟏 + canonical(n+1)

    Time complexity: O(n)
    Space complexity: O(n) for the constructed tree

    Examples:
        >>> canonical(0)
        ∅
        >>> canonical(1)
        𝟏
        >>> canonical(3)
        (𝟏 + (𝟏 + 𝟏))
    """
    if n == 0: return ZERO
    if n == 1: return ONE
    return SUM(ONE, canonical(n - 1))

def normalize(c: UCode) -> UCode:
    """
    Normalize a universe code to its canonical representative.

    This is the key operation for weak univalence: two codes normalize
    to the same form if and only if they represent equivalent types.

    Properties (proved formally):
        1. normalize(normalize(c)) = normalize(c)  [idempotent]
        2. |El(c)| = |El(normalize(c))|            [cardinality preserved]
        3. El(c) ≃ El(normalize(c))                [type equivalence]

    Time complexity: O(n) where n is the code tree size
    Space complexity: O(card(c)) for the canonical form

    Examples:
        >>> normalize(BOOL)
        (𝟏 + 𝟏)
        >>> normalize(PROD(BOOL, BOOL))
        (𝟏 + (𝟏 + (𝟏 + 𝟏)))
    """
    return canonical(cardinality(c))

def are_equivalent(a: UCode, b: UCode) -> bool:
    """
    Check whether two codes represent equivalent types.

    By weak univalence, this reduces to checking equal cardinality.

    Time complexity: O(|a| + |b|)

    Examples:
        >>> are_equivalent(BOOL, SUM(ONE, ONE))
        True
        >>> are_equivalent(PROD(BOOL, ONE), BOOL)
        True
        >>> are_equivalent(BOOL, SUM(BOOL, ONE))
        False
    """
    return cardinality(a) == cardinality(b)

# ============================================================
# Algorithm 2: Path Construction
# ============================================================

@dataclass
class Path:
    """A path between two values, represented as a function on Bool."""
    start: object
    end: object
    _func: object  # Bool → A

    def eval(self, i: bool):
        return self._func(i)

    def __repr__(self):
        return f"Path({self.start} ↝ {self.end})"

def make_path(a, b, f=None):
    """Construct a path from a to b."""
    if f is None:
        f = lambda i: b if i else a
    return Path(start=a, end=b, _func=f)

def refl(a):
    """Reflexivity path."""
    return Path(start=a, end=a, _func=lambda _: a)

def symm(p: Path) -> Path:
    """Path reversal."""
    return Path(start=p.end, end=p.start, _func=lambda i: p.eval(not i))

def ap_path(f, p: Path) -> Path:
    """Functorial action on paths."""
    return Path(start=f(p.start), end=f(p.end), _func=lambda i: f(p.eval(i)))

def funext_path(pointwise_paths: dict) -> Path:
    """
    Construct function extensionality path from pointwise paths.

    Given paths h(x): f(x) ↝ g(x) for each x, constructs a path f ↝ g
    in the function type.

    This implements the key construction:
        p(i)(x) = h(x)(i)

    Time complexity: O(1) for construction, O(|domain|) per evaluation
    """
    f = lambda x: pointwise_paths[x].start
    g = lambda x: pointwise_paths[x].end
    path_func = lambda i: (lambda x: pointwise_paths[x].eval(i))
    return Path(start=f, end=g, _func=path_func)

# ============================================================
# Algorithm 3: Suspension Recursion
# ============================================================

class SuspElement:
    """Abstract element of a suspension type."""
    pass

class SuspNorth(SuspElement):
    def __repr__(self): return "⊤"

class SuspSouth(SuspElement):
    def __repr__(self): return "⊥"

def susp_rec(north_val, south_val, meridian_map, elem: SuspElement):
    """
    Suspension recursion principle.

    Given:
        - north_val: target for north pole
        - south_val: target for south pole
        - meridian_map: A → (north_val = south_val)
    Returns the image of elem under the unique map.

    Time complexity: O(1) per element

    The key universal property:
        susp_rec(n, s, m)(north) = n
        susp_rec(n, s, m)(south) = s
        For any f with f(north)=n, f(south)=s: f = susp_rec(n, s, m)
    """
    if isinstance(elem, SuspNorth):
        return north_val
    elif isinstance(elem, SuspSouth):
        return south_val
    else:
        return north_val  # Meridian collapses to north


# ============================================================
# Demo
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Normalization
    print("\n--- Universe Code Normalization ---")
    codes = [ZERO, ONE, BOOL, SUM(ONE, ONE), PROD(BOOL, ONE),
             SUM(BOOL, ONE), PROD(BOOL, BOOL)]
    for c in codes:
        n = normalize(c)
        print(f"  {c!s:30s} → card={cardinality(c)}, norm={n}")

    # Equivalence checking
    print("\n--- Equivalence Checking (Weak Univalence) ---")
    pairs = [(BOOL, SUM(ONE, ONE)), (PROD(BOOL, ONE), BOOL),
             (BOOL, SUM(BOOL, ONE)), (PROD(BOOL, BOOL), SUM(ONE, SUM(ONE, SUM(ONE, ONE))))]
    for a, b in pairs:
        eq = are_equivalent(a, b)
        print(f"  {a} ≃ {b} ? {'✓' if eq else '✗'}")

    # Path construction
    print("\n--- Path Construction ---")
    p = make_path(3, 7)
    print(f"  {p}: eval(F)={p.eval(False)}, eval(T)={p.eval(True)}")
    p_r = symm(p)
    print(f"  symm: {p_r}: eval(F)={p_r.eval(False)}, eval(T)={p_r.eval(True)}")
    p_ap = ap_path(lambda x: x**2, p)
    print(f"  ap(x²): {p_ap}: eval(F)={p_ap.eval(False)}, eval(T)={p_ap.eval(True)}")

    # Function extensionality
    print("\n--- Function Extensionality ---")
    paths = {0: make_path(0, 10), 1: make_path(1, 11), 2: make_path(2, 12)}
    fe = funext_path(paths)
    print(f"  Pointwise: x=0: {paths[0]}, x=1: {paths[1]}, x=2: {paths[2]}")
    print(f"  funext(False) = {[fe.eval(False)(x) for x in range(3)]}")
    print(f"  funext(True)  = {[fe.eval(True)(x) for x in range(3)]}")

    # Suspension
    print("\n--- Suspension Recursion ---")
    print(f"  rec(0, 1, _)(north) = {susp_rec(0, 1, {}, SuspNorth())}")
    print(f"  rec(0, 1, _)(south) = {susp_rec(0, 1, {}, SuspSouth())}")

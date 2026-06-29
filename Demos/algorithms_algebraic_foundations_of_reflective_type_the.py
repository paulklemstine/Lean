#!/usr/bin/env python3
"""
Reflective Type Theory: Core Algorithms

Type-hinted implementations of the key algorithms from the ReflTT research.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Tuple


# ================================================================
# Core Data Types
# ================================================================

@dataclass(frozen=True)
class MFormula:
    """Base class for modal propositional formulas."""
    pass

@dataclass(frozen=True)
class Var(MFormula):
    """Propositional variable."""
    index: int

@dataclass(frozen=True)
class Bot(MFormula):
    """Falsum (⊥)."""
    pass

@dataclass(frozen=True)
class Imp(MFormula):
    """Implication (A → B)."""
    left: MFormula
    right: MFormula

@dataclass(frozen=True)
class Box(MFormula):
    """Box modality (□A) — provability operator."""
    inner: MFormula


# ================================================================
# Algorithm 1: Tropical Depth Computation
# ================================================================

def compute_depth(formula: MFormula) -> int:
    """
    Compute the modal nesting depth of a formula.

    This is the tropical semiring homomorphism target:
    - depth(A → B) = max(depth(A), depth(B))  [tropical addition]
    - depth(□A) = depth(A) + 1                [tropical multiplication]
    - depth(var), depth(⊥) = 0                [tropical zero]

    Time complexity: O(|formula|)
    Space complexity: O(depth of syntax tree)
    """
    if isinstance(formula, (Var, Bot)):
        return 0
    elif isinstance(formula, Imp):
        return max(compute_depth(formula.left), compute_depth(formula.right))
    elif isinstance(formula, Box):
        return compute_depth(formula.inner) + 1
    raise TypeError(f"Unknown formula type: {type(formula)}")


# ================================================================
# Algorithm 2: Depth Spectrum Extraction
# ================================================================

def extract_depth_spectrum(formula: MFormula) -> List[int]:
    """
    Extract the depth spectrum of a formula.

    The depth spectrum is the multiset of depths at which each □ occurrence
    lives. It captures finer structure than the max depth alone.

    Properties:
    - len(spectrum) == box_count(formula)
    - max(spectrum) == depth(formula) when spectrum is non-empty
    - spectrum == [] iff formula is boxless

    Time complexity: O(|formula|)
    """
    if isinstance(formula, (Var, Bot)):
        return []
    elif isinstance(formula, Imp):
        return extract_depth_spectrum(formula.left) + extract_depth_spectrum(formula.right)
    elif isinstance(formula, Box):
        return [compute_depth(formula.inner) + 1] + extract_depth_spectrum(formula.inner)
    raise TypeError


# ================================================================
# Algorithm 3: Substitution with Depth Tracking
# ================================================================

def substitute(
    formula: MFormula,
    sigma: Callable[[int], MFormula]
) -> MFormula:
    """
    Apply substitution σ to a formula, replacing each variable var(n) with σ(n).

    Properties (proven in Lean):
    - depth(substitute(A, σ)) ≤ depth(A) + max{depth(σ(n))}
    - If all σ(n) have depth 0, then depth(substitute(A, σ)) = depth(A)

    Time complexity: O(|formula| × max_size(σ))
    """
    if isinstance(formula, Var):
        return sigma(formula.index)
    elif isinstance(formula, Bot):
        return Bot()
    elif isinstance(formula, Imp):
        return Imp(substitute(formula.left, sigma), substitute(formula.right, sigma))
    elif isinstance(formula, Box):
        return Box(substitute(formula.inner, sigma))
    raise TypeError


def substitution_depth_bound(
    formula: MFormula,
    sigma: Callable[[int], MFormula],
    max_sigma_depth: int
) -> Tuple[int, int, bool]:
    """
    Compute the depth after substitution and verify the depth bound.

    Returns:
        (original_depth, substituted_depth, bound_holds)
    where bound_holds checks: substituted_depth ≤ original_depth + max_sigma_depth
    """
    original = compute_depth(formula)
    substituted = compute_depth(substitute(formula, sigma))
    return (original, substituted, substituted <= original + max_sigma_depth)


# ================================================================
# Algorithm 4: Reflective Orbit and Fixed-Point Computation
# ================================================================

def reflective_orbit(
    formula: MFormula,
    n_steps: int
) -> List[Tuple[int, MFormula, int]]:
    """
    Compute the reflective orbit: A, □A, □²A, ..., □ⁿA.

    Returns list of (step, formula, depth) tuples.

    Property: depth at step k = depth(formula) + k
    """
    result = []
    current = formula
    for k in range(n_steps + 1):
        result.append((k, current, compute_depth(current)))
        current = Box(current)
    return result


def first_passage_time(formula: MFormula, target_depth: int) -> Optional[int]:
    """
    Find the unique first-passage time: the last n where □ⁿA has depth ≤ target_depth.

    Returns None if depth(formula) > target_depth (no crossing exists).

    Property (proven in Lean): The result is always d - depth(A) when it exists,
    and it is the unique n satisfying depth(□ⁿA) ≤ d ∧ depth(□^(n+1)A) > d.
    """
    d0 = compute_depth(formula)
    if d0 > target_depth:
        return None
    return target_depth - d0


# ================================================================
# Algorithm 5: Depth Filtration Level Membership
# ================================================================

def depth_level_membership(formula: MFormula, level: int) -> bool:
    """Check if formula belongs to DepthLevel(level) = {A | depth(A) ≤ level}."""
    return compute_depth(formula) <= level


def classify_by_depth(formulas: List[MFormula]) -> Dict[int, List[MFormula]]:
    """Classify a list of formulas by their depth level."""
    result: Dict[int, List[MFormula]] = {}
    for f in formulas:
        d = compute_depth(f)
        if d not in result:
            result[d] = []
        result[d].append(f)
    return result


# ================================================================
# Algorithm 6: Boxless Check (Depth-0 Characterization)
# ================================================================

def is_boxless(formula: MFormula) -> bool:
    """
    Check if a formula contains no □ operators.

    Property (proven in Lean): is_boxless(A) ↔ depth(A) = 0
    """
    if isinstance(formula, (Var, Bot)):
        return True
    elif isinstance(formula, Imp):
        return is_boxless(formula.left) and is_boxless(formula.right)
    elif isinstance(formula, Box):
        return False
    raise TypeError


# ================================================================
# Algorithm 7: Formula Size and Gap Construction
# ================================================================

def compute_size(formula: MFormula) -> int:
    """Compute the formula size (number of syntax tree nodes)."""
    if isinstance(formula, (Var, Bot)):
        return 1
    elif isinstance(formula, Imp):
        return compute_size(formula.left) + compute_size(formula.right) + 1
    elif isinstance(formula, Box):
        return compute_size(formula.inner) + 1
    raise TypeError


def construct_gap_witness(target_depth: int, min_size: int) -> MFormula:
    """
    Construct a formula with exactly the given depth and size > min_size.

    Uses □^d(wideFormula(n)) where n is chosen to exceed the size bound.

    Property (proven in Lean): Such a witness always exists.
    """
    # Build wideFormula(min_size): chain of implications of ⊥
    f: MFormula = Bot()
    for _ in range(min_size):
        f = Imp(f, Bot())
    # Apply □^d
    for _ in range(target_depth):
        f = Box(f)
    return f


# ================================================================
# Self-test
# ================================================================

if __name__ == "__main__":
    p, q = Var(0), Var(1)

    # Test tropical homomorphism
    assert compute_depth(Imp(p, q)) == max(compute_depth(p), compute_depth(q))
    assert compute_depth(Box(p)) == compute_depth(p) + 1

    # Test substitution bound
    sigma = lambda n: Box(Var(n))  # depth-1 substitution
    orig, subst_d, holds = substitution_depth_bound(Box(Imp(p, q)), sigma, 1)
    assert holds, f"Bound violated: {subst_d} > {orig} + 1"

    # Test first passage
    assert first_passage_time(p, 5) == 5
    assert first_passage_time(Box(p), 5) == 4

    # Test boxless characterization
    assert is_boxless(p) == (compute_depth(p) == 0)
    assert is_boxless(Box(p)) == (compute_depth(Box(p)) == 0)

    # Test gap witness
    for d in range(4):
        for s in [10, 50, 100]:
            w = construct_gap_witness(d, s)
            assert compute_depth(w) == d
            assert compute_size(w) > s

    print("All algorithm self-tests passed.")

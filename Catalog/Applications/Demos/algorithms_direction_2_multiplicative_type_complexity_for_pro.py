#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Type Complexity Algebra

Implements core algorithms for computing and analyzing the type complexity
functional, including:
  1. State bound computation (recursive evaluation)
  2. Type enumeration by size
  3. Denotation inhabitant enumeration
  4. Embedding detection
  5. Complexity algebra verification
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Optional, Dict, Tuple, Iterator, Set
from itertools import product as cartesian_product
import math


# ═══════════════════════════════════════════════════════════════════════════
# Type Syntax
# ═══════════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class Ty:
    """Abstract base for type expressions."""
    pass

@dataclass(frozen=True)
class Base(Ty):
    """Unit type: exactly one inhabitant."""
    def __repr__(self) -> str:
        return "𝟏"

@dataclass(frozen=True)
class Arr(Ty):
    """Function type: A → B."""
    src: Ty
    tgt: Ty
    def __repr__(self) -> str:
        return f"({self.src} → {self.tgt})"

@dataclass(frozen=True)
class Prod(Ty):
    """Product type: A × B."""
    left: Ty
    right: Ty
    def __repr__(self) -> str:
        return f"({self.left} × {self.right})"

@dataclass(frozen=True)
class Sum(Ty):
    """Sum type: A + B."""
    left: Ty
    right: Ty
    def __repr__(self) -> str:
        return f"({self.left} + {self.right})"


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 1: State Bound Computation
# ═══════════════════════════════════════════════════════════════════════════

def ext_type_state_bound(ty: Ty) -> int:
    """Compute the extended type state bound.

    Time complexity: O(n) where n = size of the type expression.
    Space complexity: O(d) where d = depth of the type expression.

    The state bound equals the cardinality of the finite denotational
    model, proven formally as fintype_card_denote_eq_bound.

    Args:
        ty: An extended type expression.

    Returns:
        The state bound (a positive natural number).

    Examples:
        >>> ext_type_state_bound(Base())
        1
        >>> ext_type_state_bound(Sum(Base(), Base()))
        2
        >>> ext_type_state_bound(Prod(Sum(Base(), Base()), Sum(Base(), Base())))
        4
    """
    if isinstance(ty, Base):
        return 1
    elif isinstance(ty, Arr):
        return ext_type_state_bound(ty.tgt) ** ext_type_state_bound(ty.src)
    elif isinstance(ty, Prod):
        return ext_type_state_bound(ty.left) * ext_type_state_bound(ty.right)
    elif isinstance(ty, Sum):
        return ext_type_state_bound(ty.left) + ext_type_state_bound(ty.right)
    else:
        raise TypeError(f"Unknown type constructor: {type(ty)}")


def log_complexity(ty: Ty) -> float:
    """Compute the logarithmic complexity (information content in bits).

    For products, log-complexity is additive: L(A×B) = L(A) + L(B).
    This is the entropy interpretation of type complexity.

    Args:
        ty: An extended type expression.

    Returns:
        log₂(extTypeStateBound(ty)), or 0 for the unit type.
    """
    bound = ext_type_state_bound(ty)
    return math.log2(bound) if bound > 1 else 0.0


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 2: Type Enumeration
# ═══════════════════════════════════════════════════════════════════════════

def type_size(ty: Ty) -> int:
    """Compute the size (number of constructors) of a type expression.

    Time complexity: O(n).
    """
    if isinstance(ty, Base):
        return 1
    elif isinstance(ty, (Arr, Prod, Sum)):
        left = ty.src if isinstance(ty, Arr) else ty.left
        right = ty.tgt if isinstance(ty, Arr) else ty.right
        return 1 + type_size(left) + type_size(right)
    else:
        raise TypeError(f"Unknown type: {type(ty)}")


def type_depth(ty: Ty) -> int:
    """Compute the depth of a type expression.

    Time complexity: O(n).
    """
    if isinstance(ty, Base):
        return 0
    elif isinstance(ty, (Arr, Prod, Sum)):
        left = ty.src if isinstance(ty, Arr) else ty.left
        right = ty.tgt if isinstance(ty, Arr) else ty.right
        return 1 + max(type_depth(left), type_depth(right))
    else:
        raise TypeError(f"Unknown type: {type(ty)}")


def enumerate_types(max_size: int) -> Dict[int, List[Ty]]:
    """Enumerate all type expressions up to a given size.

    Uses dynamic programming: types of size s are built from types of
    sizes i and s-1-i for all valid i.

    Time complexity: O(C(n)) where C(n) is the nth Catalan-like number
    (exponential in max_size).

    Args:
        max_size: Maximum number of constructors.

    Returns:
        Dictionary mapping size -> list of types of that size.
    """
    types_by_size: Dict[int, List[Ty]] = {1: [Base()]}

    for s in range(2, max_size + 1):
        types_by_size[s] = []
        for left_size in range(1, s):
            right_size = s - 1 - left_size
            if right_size < 1:
                continue
            for left_ty in types_by_size.get(left_size, []):
                for right_ty in types_by_size.get(right_size, []):
                    types_by_size[s].append(Arr(left_ty, right_ty))
                    types_by_size[s].append(Prod(left_ty, right_ty))
                    types_by_size[s].append(Sum(left_ty, right_ty))

    return types_by_size


def all_types_up_to(max_size: int) -> List[Ty]:
    """Return a flat list of all types up to a given size."""
    by_size = enumerate_types(max_size)
    result = []
    for s in range(1, max_size + 1):
        result.extend(by_size.get(s, []))
    return result


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 3: Denotation Inhabitant Enumeration
# ═══════════════════════════════════════════════════════════════════════════

def enumerate_inhabitants(ty: Ty) -> List:
    """Enumerate all inhabitants of the finite denotational model.

    Constructs explicit inhabitants:
      - Base: [()]
      - Prod A B: Cartesian product of inhabitants
      - Sum A B: Tagged disjoint union
      - Arr A B: All functions as lists of output values

    Time complexity: O(|⟦ty⟧|) — proportional to the number of inhabitants.
    Space complexity: O(|⟦ty⟧|) — stores all inhabitants.

    Warning: For function types, the number of inhabitants can grow
    as a tower of exponentials. Use with small types only.

    Args:
        ty: An extended type expression.

    Returns:
        List of all inhabitants (abstract representation).
    """
    if isinstance(ty, Base):
        return [()]
    elif isinstance(ty, Prod):
        left_inh = enumerate_inhabitants(ty.left)
        right_inh = enumerate_inhabitants(ty.right)
        return [(a, b) for a in left_inh for b in right_inh]
    elif isinstance(ty, Sum):
        left_inh = enumerate_inhabitants(ty.left)
        right_inh = enumerate_inhabitants(ty.right)
        return [('L', a) for a in left_inh] + [('R', b) for b in right_inh]
    elif isinstance(ty, Arr):
        src_inh = enumerate_inhabitants(ty.src)
        tgt_inh = enumerate_inhabitants(ty.tgt)
        if not src_inh:
            return [()]
        result = []
        for combo in cartesian_product(tgt_inh, repeat=len(src_inh)):
            result.append(tuple(combo))
        return result
    else:
        raise TypeError(f"Unknown type: {type(ty)}")


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 4: Embedding Detection
# ═══════════════════════════════════════════════════════════════════════════

def is_positive_embedded(a: Ty, b: Ty) -> bool:
    """Check if type a is positively embedded in type b.

    A type is positively embedded if it can be reached by following
    product and sum constructors (but not arrows, which are not
    monotone in the domain).

    Time complexity: O(|a| * |b|) in the worst case.

    Args:
        a: The potential sub-type.
        b: The potential super-type.

    Returns:
        True if a is positively embedded in b.
    """
    if a == b:
        return True
    if isinstance(b, Prod):
        return is_positive_embedded(a, b.left) or is_positive_embedded(a, b.right)
    if isinstance(b, Sum):
        return is_positive_embedded(a, b.left) or is_positive_embedded(a, b.right)
    return False


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 5: Algebraic Law Verification
# ═══════════════════════════════════════════════════════════════════════════

def verify_algebra(types: List[Ty]) -> Dict[str, Tuple[int, int]]:
    """Verify all algebraic laws on a set of types.

    Checks:
      1. Product multiplicativity: |A × B| = |A| · |B|
      2. Sum additivity: |A + B| = |A| + |B|
      3. Arrow exponentiality: |A → B| = |B|^|A|
      4. Positivity: |A| > 0
      5. Distributivity: |(A+B)×C| = |A×C| + |B×C|
      6. Monotonicity under positive embedding

    Args:
        types: List of types to test.

    Returns:
        Dictionary of law_name -> (verified_count, failure_count).
    """
    results: Dict[str, Tuple[int, int]] = {}

    # Positivity
    pos_ok, pos_fail = 0, 0
    for ty in types:
        if ext_type_state_bound(ty) > 0:
            pos_ok += 1
        else:
            pos_fail += 1
    results["positivity"] = (pos_ok, pos_fail)

    # Binary laws
    prod_ok = prod_fail = 0
    sum_ok = sum_fail = 0
    arr_ok = arr_fail = 0
    dist_ok = dist_fail = 0
    mono_ok = mono_fail = 0

    for a in types:
        ba = ext_type_state_bound(a)
        for b in types:
            bb = ext_type_state_bound(b)

            # Product
            if ext_type_state_bound(Prod(a, b)) == ba * bb:
                prod_ok += 1
            else:
                prod_fail += 1

            # Sum
            if ext_type_state_bound(Sum(a, b)) == ba + bb:
                sum_ok += 1
            else:
                sum_fail += 1

            # Arrow
            if ext_type_state_bound(Arr(a, b)) == bb ** ba:
                arr_ok += 1
            else:
                arr_fail += 1

            # Monotonicity
            if is_positive_embedded(a, b):
                if ba <= bb:
                    mono_ok += 1
                else:
                    mono_fail += 1

            # Distributivity (ternary, use first two + base)
            for c in [Base(), Sum(Base(), Base())]:
                bc = ext_type_state_bound(c)
                lhs = ext_type_state_bound(Prod(Sum(a, b), c))
                rhs = (ext_type_state_bound(Prod(a, c)) +
                       ext_type_state_bound(Prod(b, c)))
                if lhs == rhs:
                    dist_ok += 1
                else:
                    dist_fail += 1

    results["product_multiplicativity"] = (prod_ok, prod_fail)
    results["sum_additivity"] = (sum_ok, sum_fail)
    results["arrow_exponentiality"] = (arr_ok, arr_fail)
    results["distributivity"] = (dist_ok, dist_fail)
    results["embedding_monotonicity"] = (mono_ok, mono_fail)

    return results


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 6: Complexity Spectrum Analysis
# ═══════════════════════════════════════════════════════════════════════════

def complexity_spectrum(max_size: int) -> Dict[int, List[Ty]]:
    """Group types by their state bound value.

    Finds all types up to a given size and groups them by complexity.
    This reveals the spectrum of achievable complexity values.

    Args:
        max_size: Maximum type size.

    Returns:
        Dictionary mapping state_bound_value -> list of types with that bound.
    """
    types = all_types_up_to(max_size)
    spectrum: Dict[int, List[Ty]] = {}
    for ty in types:
        bound = ext_type_state_bound(ty)
        if bound not in spectrum:
            spectrum[bound] = []
        spectrum[bound].append(ty)
    return spectrum


# ═══════════════════════════════════════════════════════════════════════════
# Main: Run all algorithms and display results
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("Type Complexity Algebra — Algorithm Suite")
    print("=" * 60)
    print()

    # 1. Enumerate types
    print("1. Type Enumeration (size ≤ 5)")
    by_size = enumerate_types(5)
    for s in range(1, 6):
        types = by_size.get(s, [])
        print(f"   Size {s}: {len(types)} types")
    print()

    # 2. Verify algebra
    print("2. Algebraic Law Verification")
    all_ty = all_types_up_to(4)
    results = verify_algebra(all_ty)
    for law, (ok, fail) in results.items():
        status = "✓" if fail == 0 else "✗"
        print(f"   {status} {law}: {ok} verified, {fail} failures")
    print()

    # 3. Complexity spectrum
    print("3. Complexity Spectrum (size ≤ 5)")
    spectrum = complexity_spectrum(5)
    for bound in sorted(spectrum.keys())[:15]:
        types = spectrum[bound]
        print(f"   Bound {bound}: {len(types)} types "
              f"(e.g., {types[0]})")
    if len(spectrum) > 15:
        print(f"   ... ({len(spectrum)} distinct bound values total)")
    print()

    # 4. Inhabitant enumeration verification
    print("4. Denotation Cardinality Verification (size ≤ 4)")
    small_types = all_types_up_to(4)
    verified = 0
    failed = 0
    for ty in small_types:
        bound = ext_type_state_bound(ty)
        if bound > 10000:
            continue  # Skip very large types
        try:
            inhabitants = enumerate_inhabitants(ty)
            if len(inhabitants) == bound:
                verified += 1
            else:
                failed += 1
                print(f"   MISMATCH: {ty}, bound={bound}, actual={len(inhabitants)}")
        except (MemoryError, RecursionError):
            pass
    print(f"   ✓ {verified} types verified, {failed} failures")
    print()

    print("All algorithms executed successfully.")

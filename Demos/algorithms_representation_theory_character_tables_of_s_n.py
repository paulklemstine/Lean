#!/usr/bin/env python3
"""
Certified Algorithms for Character-Theoretic Computation

Implements the algorithms described in the research paper:
1. Fixed-point counter (certified by trace–fixed-point theorem)
2. Character inner product calculator
3. Orthogonality checker for candidate character tables
4. Character table completeness verifier (sum-of-squares)
5. Class sum operator trace calculator

All algorithms use exact arithmetic (Fraction) for certified results.
"""

import itertools
import math
from fractions import Fraction
from typing import Callable, Dict, List, Optional, Tuple


# ============================================================
# Algorithm 1: Certified Fixed-Point Counter
# ============================================================

def fixed_point_count(sigma: Tuple[int, ...]) -> int:
    """
    Certified fixed-point counter.

    Given a permutation σ on {0, ..., n-1}, returns |Fix(σ)|.

    Certified by Theorem 3.1 (trace–fixed-point identity):
        tr(ρ(σ)) = |Fix(σ)|

    Time complexity: O(n)
    Space complexity: O(1)

    Examples:
        >>> fixed_point_count((0, 1, 2))  # identity on 3 elements
        3
        >>> fixed_point_count((1, 0, 2))  # swap 0 and 1
        1
        >>> fixed_point_count((1, 2, 0))  # 3-cycle
        0
    """
    return sum(1 for i, s in enumerate(sigma) if s == i)


# ============================================================
# Algorithm 2: Character Inner Product
# ============================================================

def character_inner_product(
    chi: Callable[[Tuple[int, ...]], Fraction],
    psi: Callable[[Tuple[int, ...]], Fraction],
    group: List[Tuple[int, ...]]
) -> Fraction:
    """
    Character inner product calculator.

    Computes ⟨χ, ψ⟩ = (1/|G|) Σ_{g ∈ G} χ(g) · ψ(g)

    Uses exact Fraction arithmetic for certified results.

    Time complexity: O(|G|)
    Space complexity: O(1)

    Args:
        chi: First character function
        psi: Second character function
        group: List of all group elements (as permutation tuples)

    Returns:
        Exact rational inner product value

    Examples:
        >>> G = list(itertools.permutations(range(3)))
        >>> triv = lambda s: Fraction(1)
        >>> character_inner_product(triv, triv, G)
        Fraction(1, 1)
    """
    n = len(group)
    if n == 0:
        return Fraction(0)
    total = sum(chi(g) * psi(g) for g in group)
    return Fraction(total, n)


# ============================================================
# Algorithm 3: Orthonormality Checker
# ============================================================

def check_orthonormality(
    characters: List[Callable[[Tuple[int, ...]], Fraction]],
    group: List[Tuple[int, ...]],
    names: Optional[List[str]] = None
) -> Tuple[bool, List[str]]:
    """
    Certified orthonormality checker for candidate character tables.

    Given a list of candidate characters, verifies:
    - ⟨χ_i, χ_i⟩ = 1 for all i (irreducibility)
    - ⟨χ_i, χ_j⟩ = 0 for all i ≠ j (orthogonality)

    Certified by first orthogonality relation of Frobenius.

    Time complexity: O(k² · |G|) where k = number of characters
    Space complexity: O(k²)

    Args:
        characters: List of character functions
        group: List of all group elements
        names: Optional names for characters

    Returns:
        (is_orthonormal, list_of_messages)

    Examples:
        >>> G = list(itertools.permutations(range(3)))
        >>> triv = lambda s: Fraction(1)
        >>> sgn = lambda s: Fraction(sign_perm(s))
        >>> std = lambda s: Fraction(fixed_point_count(s) - 1)
        >>> ok, msgs = check_orthonormality([triv, sgn, std], G)
        >>> ok
        True
    """
    k = len(characters)
    if names is None:
        names = [f"χ_{i}" for i in range(k)]

    messages = []
    is_orthonormal = True

    for i in range(k):
        for j in range(i, k):
            ip = character_inner_product(characters[i], characters[j], group)
            expected = Fraction(1) if i == j else Fraction(0)
            ok = (ip == expected)
            if not ok:
                is_orthonormal = False
            status = "✓" if ok else f"✗ (got {ip})"
            messages.append(f"⟨{names[i]}, {names[j]}⟩ = {ip} {status}")

    return is_orthonormal, messages


# ============================================================
# Algorithm 4: Sum-of-Squares Completeness Check
# ============================================================

def check_completeness(
    degrees: List[int],
    group_order: int
) -> Tuple[bool, str]:
    """
    Character table completeness checker via sum-of-squares.

    Verifies: Σ d_i² = |G|

    This is a necessary and sufficient condition for the given
    irreducible characters to form a complete set.

    Time complexity: O(k)
    Space complexity: O(1)

    Args:
        degrees: List of irreducible character degrees
        group_order: Order of the group

    Returns:
        (is_complete, message)

    Examples:
        >>> check_completeness([1, 1, 2], 6)  # S₃
        (True, 'Σ d² = 1+1+4 = 6 = |G| ✓')
        >>> check_completeness([1, 1, 2, 3, 3], 24)  # S₄
        (True, 'Σ d² = 1+1+4+9+9 = 24 = |G| ✓')
    """
    squares = [d ** 2 for d in degrees]
    sos = sum(squares)
    terms = "+".join(str(s) for s in squares)
    complete = (sos == group_order)
    status = "✓" if complete else f"✗ ({sos} ≠ {group_order})"
    message = f"Σ d² = {terms} = {sos} {'=' if complete else '≠'} |G| {status}"
    return complete, message


# ============================================================
# Algorithm 5: Class Sum Operator Trace
# ============================================================

def class_sum_trace(
    class_members: List[Tuple[int, ...]],
) -> int:
    """
    Class sum operator trace calculator.

    Computes tr(T_C) = Σ_{σ ∈ C} |Fix(σ)|.

    Certified by Theorem 6.1 (spectral cross-domain theorem):
    the trace of the class sum operator on the permutation representation
    equals the sum of fixed-point counts.

    Time complexity: O(|C| · n) where n is the degree
    Space complexity: O(1)

    Args:
        class_members: List of permutations in the conjugacy class

    Returns:
        Trace of the class sum operator

    Examples:
        >>> transpositions = [(1,0,2), (0,2,1), (2,1,0)]
        >>> class_sum_trace(transpositions)
        3
    """
    return sum(fixed_point_count(sigma) for sigma in class_members)


# ============================================================
# Helper: Permutation sign
# ============================================================

def sign_perm(sigma: Tuple[int, ...]) -> int:
    """Compute sign of a permutation."""
    n = len(sigma)
    inversions = sum(1 for i in range(n) for j in range(i + 1, n) if sigma[i] > sigma[j])
    return 1 if inversions % 2 == 0 else -1


# ============================================================
# Algorithm 6: Cycle type classifier
# ============================================================

def cycle_type(sigma: Tuple[int, ...]) -> Tuple[int, ...]:
    """
    Compute the cycle type of a permutation.

    Returns a tuple of cycle lengths in decreasing order.

    Time complexity: O(n)
    Space complexity: O(n)

    Examples:
        >>> cycle_type((0, 1, 2))
        (1, 1, 1)
        >>> cycle_type((1, 0, 2))
        (2, 1)
        >>> cycle_type((1, 2, 0))
        (3,)
    """
    n = len(sigma)
    visited = [False] * n
    cycles = []
    for i in range(n):
        if not visited[i]:
            length = 0
            j = i
            while not visited[j]:
                visited[j] = True
                j = sigma[j]
                length += 1
            cycles.append(length)
    return tuple(sorted(cycles, reverse=True))


# ============================================================
# Algorithm 7: Character Table Builder for S_n
# ============================================================

def build_sn_perm_characters(n: int) -> Dict[str, Callable]:
    """
    Build the standard character functions for S_n.

    Returns dict with at least: trivial, sign, standard, permutation.

    Examples:
        >>> chars = build_sn_perm_characters(3)
        >>> chars['trivial']((0,1,2))
        Fraction(1, 1)
    """
    return {
        'trivial': lambda s: Fraction(1),
        'sign': lambda s: Fraction(sign_perm(s)),
        'standard': lambda s: Fraction(fixed_point_count(s) - 1),
        'permutation': lambda s: Fraction(fixed_point_count(s)),
    }


# ============================================================
# Main: Run all algorithms with examples
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print(" CERTIFIED ALGORITHMS FOR CHARACTER COMPUTATION")
    print("=" * 60)

    for n in [3, 4, 5]:
        print(f"\n{'─'*60}")
        print(f" S_{n} (order {math.factorial(n)})")
        print(f"{'─'*60}")

        G = list(itertools.permutations(range(n)))

        # Algorithm 1: Fixed points
        print("\n  [Algorithm 1] Fixed-point counts by cycle type:")
        seen = set()
        for sigma in G:
            ct = cycle_type(sigma)
            if ct not in seen:
                seen.add(ct)
                print(f"    Cycle type {ct}: {fixed_point_count(sigma)} fixed points")

        # Characters
        chars = build_sn_perm_characters(n)

        # Algorithm 2 & 3: Inner products and orthonormality
        char_list = [chars['trivial'], chars['sign'], chars['standard']]
        char_names = ['trivial', 'sign', 'standard']

        print(f"\n  [Algorithm 3] Orthonormality check:")
        ok, msgs = check_orthonormality(char_list, G, char_names)
        for msg in msgs:
            print(f"    {msg}")
        print(f"    Result: {'PASS' if ok else 'FAIL'}")

        # Algorithm 4: Completeness
        identity = tuple(range(n))
        degrees = [int(chi(identity)) for chi in char_list]
        complete, msg = check_completeness(degrees, len(G))
        print(f"\n  [Algorithm 4] Completeness check:")
        print(f"    Degrees: {degrees}")
        print(f"    {msg}")

        # Algorithm 5: Class sum traces
        print(f"\n  [Algorithm 5] Class sum traces:")
        classes: Dict[Tuple[int, ...], List[Tuple[int, ...]]] = {}
        for p in G:
            ct = cycle_type(p)
            classes.setdefault(ct, []).append(p)

        for ct in sorted(classes.keys()):
            members = classes[ct]
            trace = class_sum_trace(members)
            print(f"    Class {ct} ({len(members)} elements): "
                  f"tr(T_C) = {trace}")

    print(f"\n{'='*60}")
    print("All algorithms completed with exact arithmetic.")

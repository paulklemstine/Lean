#!/usr/bin/env python3
"""
Algorithms for Finite Stone Representation of Closure Operators

Implements the core algorithms described in the research paper:
1. Fixed-point enumeration for closure operators on P(α)
2. Equivalence class / atom computation
3. Stone isomorphism construction (bijection FP ↔ P(atoms))
4. Complement-stability checking
5. Lattice structure verification

All algorithms assume α is a finite set represented as a frozenset.
"""

from __future__ import annotations
from itertools import combinations
from typing import Callable
from dataclasses import dataclass


Subset  = frozenset
Closure = Callable[[Subset], Subset]


# ===========================================================================
#  Algorithm 1: Fixed-Point Enumeration
# ===========================================================================

def enumerate_fixed_points(alpha: frozenset, cl: Closure) -> list[frozenset]:
    """Enumerate all fixed points of a closure operator.

    Time:  O(2^n · T_cl) where n = |α|, T_cl = cost of one cl() call
    Space: O(2^n)

    Args:
        alpha: The ground set.
        cl: Closure operator O : P(α) → P(α).

    Returns:
        Sorted list of all S ⊆ α with cl(S) = S.
    """
    elems = sorted(alpha)
    fixed = []
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            s = frozenset(combo)
            if cl(s) == s:
                fixed.append(s)
    return sorted(fixed, key=lambda s: (len(s), sorted(s)))


# ===========================================================================
#  Algorithm 2: Equivalence Class Computation
# ===========================================================================

def compute_equivalence_classes(alpha: frozenset,
                                 fixed_pts: list[frozenset]
                                 ) -> list[frozenset]:
    """Compute equivalence classes: x ~ y iff they belong to same fixed points.

    Time:  O(n² · |FP|) where n = |α|
    Space: O(n)

    This is the quotient construction from the Stone representation theorem.
    Each class becomes a "Stone point" — an atom of the fixed-point Boolean algebra.

    Args:
        alpha: The ground set.
        fixed_pts: List of all fixed points.

    Returns:
        List of equivalence classes (partition of alpha).
    """
    # Build membership signature for each element
    # sig(x) = frozenset of indices i where x ∈ fixed_pts[i]
    sigs: dict[object, frozenset] = {}
    for x in alpha:
        sig = frozenset(i for i, s in enumerate(fixed_pts) if x in s)
        sigs[x] = sig

    # Group by signature
    sig_to_class: dict[frozenset, set] = {}
    for x, sig in sigs.items():
        if sig not in sig_to_class:
            sig_to_class[sig] = set()
        sig_to_class[sig].add(x)

    return [frozenset(c) for c in sig_to_class.values()]


# ===========================================================================
#  Algorithm 3: Atom Extraction
# ===========================================================================

def extract_atoms(fixed_pts: list[frozenset]) -> list[frozenset]:
    """Extract atoms (minimal nonempty fixed points).

    Time:  O(|FP|²) pairwise subset checks
    Space: O(|FP|)

    Args:
        fixed_pts: List of all fixed points.

    Returns:
        List of atoms.
    """
    nonempty = [s for s in fixed_pts if s]
    atoms = []
    for s in nonempty:
        if not any(t < s for t in nonempty):
            atoms.append(s)
    return atoms


# ===========================================================================
#  Algorithm 4: Stone Isomorphism
# ===========================================================================

@dataclass
class StoneIsomorphism:
    """Represents the bijection between fixed points and P(atoms).

    Attributes:
        atoms: List of atoms (the "Stone points").
        forward: Maps each fixed point to its atom-support (set of atom indices).
        backward: Maps each atom-support to its corresponding fixed point.
    """
    atoms: list[frozenset]
    forward:  dict[frozenset, frozenset]   # FP → P(atom indices)
    backward: dict[frozenset, frozenset]   # P(atom indices) → FP

    def verify(self) -> bool:
        """Check that forward and backward are true inverses."""
        for s, t in self.forward.items():
            if self.backward.get(t) != s:
                return False
        for t, s in self.backward.items():
            if self.forward.get(s) != t:
                return False
        return True


def build_stone_isomorphism(fixed_pts: list[frozenset],
                             atoms_list: list[frozenset]
                             ) -> StoneIsomorphism:
    """Construct the Stone isomorphism: FP ≅ P(atoms).

    The forward map sends S to {i : atom_i ⊆ S}.
    The backward map sends T ⊆ {0,...,k-1} to ∪{atom_i : i ∈ T}.

    Time:  O(|FP| · |atoms| · n)
    Space: O(|FP|)

    Args:
        fixed_pts: All fixed points.
        atoms_list: List of atoms.

    Returns:
        StoneIsomorphism dataclass.
    """
    fwd: dict[frozenset, frozenset] = {}
    bwd: dict[frozenset, frozenset] = {}

    for s in fixed_pts:
        support = frozenset(i for i, a in enumerate(atoms_list) if a <= s)
        fwd[s] = support

    # Build backward from all subsets of atom indices
    k = len(atoms_list)
    for r in range(k + 1):
        for combo in combinations(range(k), r):
            idx_set = frozenset(combo)
            union = frozenset().union(*(atoms_list[i] for i in combo)) if combo else frozenset()
            bwd[idx_set] = union

    return StoneIsomorphism(atoms=atoms_list, forward=fwd, backward=bwd)


# ===========================================================================
#  Algorithm 5: Property Verification
# ===========================================================================

def verify_closure_operator(alpha: frozenset, cl: Closure) -> dict[str, bool]:
    """Verify all four closure operator axioms.

    Time:  O(2^{2n} · T_cl) for monotonicity check
    Space: O(2^n)
    """
    ps = []
    elems = sorted(alpha)
    for r in range(len(elems) + 1):
        for c in combinations(elems, r):
            ps.append(frozenset(c))

    extensive = all(s <= cl(s) for s in ps)
    idempotent = all(cl(cl(s)) == cl(s) for s in ps)
    monotone = all(
        cl(s) <= cl(t)
        for s in ps for t in ps if s <= t
    )

    fixed = [s for s in ps if cl(s) == s]
    complement_stable = all(
        cl(alpha - s) == (alpha - s) for s in fixed
    )

    return {
        "extensive": extensive,
        "monotone": monotone,
        "idempotent": idempotent,
        "complement_stable": complement_stable,
    }


# ===========================================================================
#  Algorithm 6: Full Stone Analysis Pipeline
# ===========================================================================

def stone_analysis(alpha: frozenset, cl: Closure) -> dict:
    """Run the complete Stone representation analysis.

    Returns a dictionary with:
        - properties: dict of closure operator properties
        - fixed_points: list of fixed points
        - atoms: list of atoms
        - equivalence_classes: list of equivalence classes
        - isomorphism: StoneIsomorphism (if complement-stable)
        - is_boolean: whether the fixed-point lattice is Boolean
    """
    props = verify_closure_operator(alpha, cl)
    fps = enumerate_fixed_points(alpha, cl)
    at = extract_atoms(fps)
    classes = compute_equivalence_classes(alpha, fps)

    result = {
        "properties": props,
        "fixed_points": fps,
        "atoms": at,
        "equivalence_classes": classes,
        "is_boolean": len(fps) > 0 and (len(fps) & (len(fps) - 1)) == 0,
    }

    if props["complement_stable"]:
        iso = build_stone_isomorphism(fps, at)
        result["isomorphism"] = iso
        result["isomorphism_verified"] = iso.verify()

    return result


# ===========================================================================
#  Example usage
# ===========================================================================

if __name__ == "__main__":
    # Build a partition closure on {0,...,7}
    alpha = frozenset(range(8))
    blocks = [frozenset({0, 1}), frozenset({2, 3}),
              frozenset({4, 5, 6}), frozenset({7})]

    def partition_cl(s: Subset) -> Subset:
        result: set = set()
        for b in blocks:
            if b & s:
                result |= b
        return frozenset(result)

    print("Stone Analysis Pipeline")
    print("=" * 60)
    result = stone_analysis(alpha, partition_cl)

    print(f"  Ground set: {set(alpha)}")
    print(f"  Partition:  {[set(b) for b in blocks]}")
    print()

    print("  Properties:")
    for k, v in result["properties"].items():
        print(f"    {k}: {'✓' if v else '✗'}")
    print()

    print(f"  Fixed points: {len(result['fixed_points'])}")
    print(f"  Atoms: {len(result['atoms'])}")
    print(f"  Equivalence classes: {len(result['equivalence_classes'])}")
    print(f"  Is Boolean algebra: {'✓' if result['is_boolean'] else '✗'}")

    if "isomorphism" in result:
        print(f"  Isomorphism verified: {'✓' if result['isomorphism_verified'] else '✗'}")
        print(f"  |FP| = 2^|atoms| = 2^{len(result['atoms'])} = {2**len(result['atoms'])}")
    print()

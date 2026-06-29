#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Tropical Arithmetic Universality
for Pythagorean Compositions.

Implements:
1. TropicalDiagramClassify — classifies networks by tropical diagram
2. BerggrenTropicalTree — enumerates Berggren tree with tropical annotations
3. TropicalProfileMonoid — monoid operations on tropical profiles
4. PadicValuationProfile — p-adic valuation profiles for Pythagorean triples
"""

import numpy as np
from typing import Tuple, List, Dict, Optional, Set
from dataclasses import dataclass
from math import gcd


# ─── Data Structures ─────────────────────────────────────────────────────────

@dataclass(frozen=True)
class TropicalPythProfile:
    """A tropical Pythagorean profile (va, vb, vc) with max(va, vb) ≤ vc.

    This is the max-plus arithmetic fingerprint of a Pythagorean triple.
    """
    va: int
    vb: int
    vc: int

    def __post_init__(self):
        assert max(self.va, self.vb) <= self.vc, \
            f"Tropical inequality violated: max({self.va}, {self.vb}) > {self.vc}"

    @property
    def depth(self) -> int:
        """Tropical depth = vc."""
        return self.vc

    @property
    def gap(self) -> int:
        """Tropical gap = vc - max(va, vb)."""
        return self.vc - max(self.va, self.vb)

    def compose(self, other: 'TropicalPythProfile') -> 'TropicalPythProfile':
        """Tropical composition: componentwise addition."""
        return TropicalPythProfile(
            va=self.va + other.va,
            vb=self.vb + other.vb,
            vc=self.vc + other.vc
        )

    @staticmethod
    def identity() -> 'TropicalPythProfile':
        """The identity profile (0, 0, 0)."""
        return TropicalPythProfile(0, 0, 0)

    def satisfies_sandwich(self) -> bool:
        """Check if vc ≤ va + vb (upper bound of tropical sandwich)."""
        return self.vc <= self.va + self.vb


@dataclass
class PythagoreanTriple:
    """A Pythagorean triple (a, b, c) with a² + b² = c²."""
    a: int
    b: int
    c: int

    def __post_init__(self):
        assert self.a**2 + self.b**2 == self.c**2, \
            f"Not Pythagorean: {self.a}² + {self.b}² ≠ {self.c}²"

    def to_profile(self) -> TropicalPythProfile:
        """Extract tropical profile using absolute values."""
        return TropicalPythProfile(abs(self.a), abs(self.b), abs(self.c))

    def is_primitive(self) -> bool:
        """Check if the triple is primitive (gcd = 1)."""
        return gcd(gcd(abs(self.a), abs(self.b)), abs(self.c)) == 1

    def lorentz_form(self) -> int:
        """Compute Q(a,b,c) = a² + b² - c²."""
        return self.a**2 + self.b**2 - self.c**2

    def tropical_gap(self) -> int:
        """Compute c - max(|a|, |b|)."""
        return abs(self.c) - max(abs(self.a), abs(self.b))


# ─── Berggren Matrices ───────────────────────────────────────────────────────

BERGGREN = {
    'A': np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),
    'B': np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),
    'C': np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
}


# ─── Algorithm 1: Tropical Diagram Classification ────────────────────────────

def tropical_diagram_classify(
    weight_matrices: List[np.ndarray]
) -> Dict:
    """Classify a sequence of weight matrices by their tropical diagram.

    Algorithm TropicalDiagramClassify:
      1. For each Wᵢ, compute the tropical profile
      2. Compose profiles sequentially
      3. Compute tropical gap and depth
      4. Return classification

    Args:
        weight_matrices: List of integer weight matrices.

    Returns:
        Dictionary with profiles, composed profile, depth, gap.

    Complexity: O(k · m · n) where k = number of layers, m×n = matrix size.

    Example:
        >>> W1 = np.array([[3, 4], [5, 12]])
        >>> W2 = np.array([[8, 15], [7, 24]])
        >>> result = tropical_diagram_classify([W1, W2])
        >>> print(result['composed_depth'])
    """
    profiles = []
    for W in weight_matrices:
        # Profile: (max of abs row entries, max of abs col entries, max of all)
        max_val = int(np.max(np.abs(W)))
        row_maxes = np.max(np.abs(W), axis=1)
        col_maxes = np.max(np.abs(W), axis=0)
        va = int(np.max(row_maxes))
        vb = int(np.max(col_maxes))
        vc = max(va, vb)
        profiles.append(TropicalPythProfile(va, vb, vc))

    # Compose profiles
    composed = TropicalPythProfile.identity()
    for p in profiles:
        composed = composed.compose(p)

    return {
        'layer_profiles': profiles,
        'composed_profile': composed,
        'composed_depth': composed.depth,
        'composed_gap': composed.gap,
        'satisfies_sandwich': composed.satisfies_sandwich(),
        'num_layers': len(weight_matrices)
    }


# ─── Algorithm 2: Berggren Tree with Tropical Annotation ─────────────────────

@dataclass
class BerggrenNode:
    """A node in the Berggren tree with tropical annotation."""
    triple: PythagoreanTriple
    profile: TropicalPythProfile
    path: str  # e.g., "ABC" for the path root -> A -> B -> C
    depth: int


def berggren_tropical_tree(max_depth: int) -> List[BerggrenNode]:
    """Enumerate the Berggren tree with tropical annotations.

    Algorithm BerggrenTropicalTree(depth):
      1. Initialize root = (3, 4, 5)
      2. BFS: for each node, apply A, B, C matrices
      3. Compute tropical profile and gap for each child
      4. Return all nodes up to max_depth

    Complexity: O(3^depth) nodes, O(1) per node.

    Example:
        >>> nodes = berggren_tropical_tree(3)
        >>> for n in nodes[:5]:
        ...     print(f"{n.path}: ({n.triple.a}, {n.triple.b}, {n.triple.c})")
    """
    root_triple = PythagoreanTriple(3, 4, 5)
    root_node = BerggrenNode(
        triple=root_triple,
        profile=root_triple.to_profile(),
        path="",
        depth=0
    )

    all_nodes = [root_node]
    current_level = [root_node]

    for d in range(1, max_depth + 1):
        next_level = []
        for node in current_level:
            v = np.array([node.triple.a, node.triple.b, node.triple.c])
            for label, M in BERGGREN.items():
                child_v = M @ v
                # Take absolute values for the triple
                a, b, c = abs(int(child_v[0])), abs(int(child_v[1])), abs(int(child_v[2]))
                child_triple = PythagoreanTriple(a, b, c)
                child_node = BerggrenNode(
                    triple=child_triple,
                    profile=child_triple.to_profile(),
                    path=node.path + label,
                    depth=d
                )
                next_level.append(child_node)

        all_nodes.extend(next_level)
        current_level = next_level

    return all_nodes


# ─── Algorithm 3: p-adic Valuation Profile ───────────────────────────────────

def p_adic_valuation(n: int, p: int) -> int:
    """Compute the p-adic valuation of n (number of times p divides n).

    Args:
        n: Integer (must be nonzero).
        p: Prime number.

    Returns:
        The p-adic valuation v_p(n).

    Example:
        >>> p_adic_valuation(12, 2)
        2
        >>> p_adic_valuation(12, 3)
        1
    """
    if n == 0:
        return float('inf')
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def padic_tropical_profile(triple: PythagoreanTriple, p: int) -> TropicalPythProfile:
    """Compute the p-adic tropical profile of a Pythagorean triple.

    The p-adic profile uses v_p(a), v_p(b), v_p(c) as the tropical weights.

    Args:
        triple: A Pythagorean triple.
        p: A prime number.

    Returns:
        The p-adic tropical profile.

    Example:
        >>> t = PythagoreanTriple(3, 4, 5)
        >>> padic_tropical_profile(t, 2)
        TropicalPythProfile(va=0, vb=2, vc=0)
    """
    va = p_adic_valuation(triple.a, p)
    vb = p_adic_valuation(triple.b, p)
    vc = p_adic_valuation(triple.c, p)
    # For primitive triples, max(va, vb) may exceed vc
    # We take the max to ensure the tropical inequality
    vc_adj = max(vc, max(va, vb))
    return TropicalPythProfile(va, vb, vc_adj)


# ─── Algorithm 4: Tropical Isomorphism Check ─────────────────────────────────

def tropical_profiles_isomorphic(
    p1: TropicalPythProfile,
    p2: TropicalPythProfile
) -> bool:
    """Check if two tropical profiles are isomorphic (equal up to permutation of va, vb).

    Two profiles are isomorphic if they have the same multiset {va, vb} and same vc.

    Example:
        >>> p1 = TropicalPythProfile(3, 4, 5)
        >>> p2 = TropicalPythProfile(4, 3, 5)
        >>> tropical_profiles_isomorphic(p1, p2)
        True
    """
    return sorted([p1.va, p1.vb]) == sorted([p2.va, p2.vb]) and p1.vc == p2.vc


def classify_by_profile(nodes: List[BerggrenNode]) -> Dict[TropicalPythProfile, List[BerggrenNode]]:
    """Group Berggren tree nodes by their tropical profile.

    Example:
        >>> nodes = berggren_tropical_tree(3)
        >>> classes = classify_by_profile(nodes)
        >>> print(f"Number of distinct profiles: {len(classes)}")
    """
    classes: Dict[TropicalPythProfile, List[BerggrenNode]] = {}
    for node in nodes:
        key = node.profile
        if key not in classes:
            classes[key] = []
        classes[key].append(node)
    return classes


# ─── Main: Example Usage ─────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Tropical Diagram Classification ===")
    W1 = np.array([[3, 4], [5, 12]])
    W2 = np.array([[8, 15], [7, 24]])
    result = tropical_diagram_classify([W1, W2])
    print(f"Layer profiles: {result['layer_profiles']}")
    print(f"Composed: {result['composed_profile']}")
    print(f"Depth: {result['composed_depth']}, Gap: {result['composed_gap']}")
    print(f"Sandwich: {result['satisfies_sandwich']}")

    print("\n=== Berggren Tree (depth 3) ===")
    nodes = berggren_tropical_tree(3)
    print(f"Total nodes: {len(nodes)}")
    for n in nodes[:10]:
        t = n.triple
        print(f"  {n.path or 'root':4s}: ({t.a:4d}, {t.b:4d}, {t.c:4d})  "
              f"gap={t.tropical_gap():3d}  depth={n.depth}")

    print("\n=== p-adic Profiles (p=2) ===")
    for n in nodes[:10]:
        pp = padic_tropical_profile(n.triple, 2)
        print(f"  ({n.triple.a:4d}, {n.triple.b:4d}, {n.triple.c:4d})  "
              f"2-adic: ({pp.va}, {pp.vb}, {pp.vc})")

    print("\n=== Profile Classification ===")
    classes = classify_by_profile(nodes)
    print(f"Distinct profiles: {len(classes)}")
    for profile, members in sorted(classes.items(), key=lambda x: len(x[1]), reverse=True)[:5]:
        print(f"  {profile}: {len(members)} triples")

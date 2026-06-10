#!/usr/bin/env python3
"""
Algorithms for Lorentzian Proof Complexity

Implements the core algorithms from the research paper:
1. Resolution-to-Certificate translation
2. Certificate-to-Resolution translation
3. Certificate size analysis
4. PHP formula construction
5. Multiindex enumeration

All algorithms have precise complexity analysis.
"""

from dataclasses import dataclass
from typing import Optional, List, Set, FrozenSet, Dict, Tuple
import math


# ============================================================
# Data Structures
# ============================================================

@dataclass(frozen=True)
class Literal:
    """A propositional literal: variable index + polarity.

    Examples:
        >>> Literal(0, True)   # x₀
        >>> Literal(1, False)  # ¬x₁
    """
    var: int
    positive: bool

    def negate(self) -> 'Literal':
        return Literal(self.var, not self.positive)

    def __repr__(self):
        return f"x{self.var}" if self.positive else f"¬x{self.var}"


Clause = FrozenSet[Literal]


class ResolutionNode:
    """A node in a tree-like resolution derivation.

    Time complexity of construction: O(1)
    Space complexity: O(|clause|) for axioms, O(1) for resolution nodes
    """

    def __init__(self, clause: Optional[Clause] = None,
                 resolve_var: Optional[int] = None,
                 left: Optional['ResolutionNode'] = None,
                 right: Optional['ResolutionNode'] = None):
        self.clause = clause
        self.resolve_var = resolve_var
        self.left = left
        self.right = right

    @property
    def is_axiom(self) -> bool:
        return self.left is None

    def derived_clause(self) -> Clause:
        """Compute the clause derived by this node.

        Time complexity: O(|left_clause| + |right_clause|)
        """
        if self.is_axiom:
            return self.clause
        left_c = self.left.derived_clause()
        right_c = self.right.derived_clause()
        v = self.resolve_var
        result: Set[Literal] = set()
        for lit in left_c:
            if not (lit.var == v and lit.positive):
                result.add(lit)
        for lit in right_c:
            if not (lit.var == v and not lit.positive):
                result.add(lit)
        return frozenset(result)

    def size(self) -> int:
        """Number of nodes in the derivation tree. O(size)."""
        if self.is_axiom:
            return 1
        return 1 + self.left.size() + self.right.size()

    def depth(self) -> int:
        """Depth of the derivation tree. O(size)."""
        if self.is_axiom:
            return 0
        return 1 + max(self.left.depth(), self.right.depth())

    def axiom_count(self) -> int:
        """Number of axiom (leaf) nodes. O(size)."""
        if self.is_axiom:
            return 1
        return self.left.axiom_count() + self.right.axiom_count()


class CertificateNode:
    """A node in a binary certificate tree.

    Leaves carry multiindices (derivative evaluation points).
    Internal nodes carry branch variables.
    """

    def __init__(self, multiindex: Optional[Dict[int, int]] = None,
                 branch_var: Optional[int] = None,
                 left: Optional['CertificateNode'] = None,
                 right: Optional['CertificateNode'] = None):
        self.multiindex = multiindex
        self.branch_var = branch_var
        self.left = left
        self.right = right

    @property
    def is_leaf(self) -> bool:
        return self.left is None

    def size(self) -> int:
        """Total number of nodes. O(size)."""
        if self.is_leaf:
            return 1
        return 1 + self.left.size() + self.right.size()

    def depth(self) -> int:
        """Tree depth. O(size)."""
        if self.is_leaf:
            return 0
        return 1 + max(self.left.depth(), self.right.depth())

    def leaf_count(self) -> int:
        """Number of leaves. O(size)."""
        if self.is_leaf:
            return 1
        return self.left.leaf_count() + self.right.leaf_count()

    def collect_leaves(self) -> List[Dict[int, int]]:
        """Collect all leaf multiindices. O(size)."""
        if self.is_leaf:
            return [self.multiindex or {}]
        return self.left.collect_leaves() + self.right.collect_leaves()


# ============================================================
# Algorithm 1: Resolution → Certificate Translation
# ============================================================

def resolution_to_certificate(node: ResolutionNode, n_vars: int) -> CertificateNode:
    """
    Translate a resolution derivation into a certificate tree.

    Algorithm:
        - Axiom clauses map to leaves with multiindices
        - Resolution steps map to branches

    Time complexity: O(size · n_vars) where size is the resolution size
    Space complexity: O(size · n_vars)

    Theorem (simulation_size_exact):
        certificateSize(translate(R)) = resolutionSize(R)

    Example:
        >>> c1 = frozenset([Literal(0, True)])
        >>> node = ResolutionNode(clause=c1)
        >>> cert = resolution_to_certificate(node, 2)
        >>> cert.size()
        1
    """
    if node.is_axiom:
        alpha: Dict[int, int] = {}
        for lit in node.clause:
            if lit.positive:
                alpha[lit.var] = alpha.get(lit.var, 0) + 1
        return CertificateNode(multiindex=alpha)

    return CertificateNode(
        branch_var=node.resolve_var,
        left=resolution_to_certificate(node.left, n_vars),
        right=resolution_to_certificate(node.right, n_vars)
    )


# ============================================================
# Algorithm 2: Certificate → Resolution Translation
# ============================================================

def certificate_to_resolution(node: CertificateNode) -> ResolutionNode:
    """
    Translate a certificate tree into a resolution derivation.

    Algorithm:
        - Leaves map to axiom clauses
        - Branches map to resolution steps

    Time complexity: O(size · n_vars)
    Space complexity: O(size · n_vars)

    Theorem (reverse_simulation_size_exact):
        resolutionSize(translate(C)) = certificateSize(C)

    Example:
        >>> cert = CertificateNode(multiindex={0: 1, 1: 0})
        >>> res = certificate_to_resolution(cert)
        >>> res.size()
        1
    """
    if node.is_leaf:
        alpha = node.multiindex or {}
        clause = frozenset(
            Literal(v, True) for v, c in alpha.items() if c > 0
        )
        return ResolutionNode(clause=clause)

    return ResolutionNode(
        resolve_var=node.branch_var,
        left=certificate_to_resolution(node.left),
        right=certificate_to_resolution(node.right)
    )


# ============================================================
# Algorithm 3: Certificate Size Analysis
# ============================================================

def analyze_certificate(cert: CertificateNode) -> Dict:
    """
    Comprehensive analysis of a certificate tree.

    Returns dictionary with:
        - size: total nodes
        - depth: tree depth
        - leaf_count: number of leaves
        - size_check: verifies size = 2·leaves - 1
        - depth_bound: verifies leaves ≤ 2^depth

    Time complexity: O(size)

    Example:
        >>> cert = CertificateNode(branch_var=0,
        ...     left=CertificateNode(multiindex={0: 1}),
        ...     right=CertificateNode(multiindex={1: 1}))
        >>> info = analyze_certificate(cert)
        >>> info['size']
        3
    """
    s = cert.size()
    d = cert.depth()
    lc = cert.leaf_count()

    return {
        'size': s,
        'depth': d,
        'leaf_count': lc,
        'size_check': s == 2 * lc - 1,  # Theorem: certificate_size_eq_two_leaves_minus_one
        'depth_bound': lc <= 2 ** d,     # Theorem: certificate_leaves_le_pow_depth
        'size_bound': s <= 2 ** (d + 1) - 1,  # Theorem: certificate_depth_controls_size
    }


# ============================================================
# Algorithm 4: PHP Construction
# ============================================================

def build_php_formula(n: int) -> Tuple[int, List[Clause], List[Clause]]:
    """
    Construct the Pigeonhole Principle formula PHP(n+1, n).

    n+1 pigeons must be placed into n holes, with at most one pigeon per hole.

    Args:
        n: number of holes (pigeons = n + 1)

    Returns:
        (n_vars, pigeon_clauses, hole_clauses)

    Time complexity: O(n³)
    Space complexity: O(n³)

    Example:
        >>> n_vars, pc, hc = build_php_formula(2)
        >>> len(pc)  # 3 pigeon clauses
        3
        >>> len(hc)  # 6 hole exclusion clauses
        6
    """
    n_pigeons = n + 1
    n_holes = n
    n_vars = n_pigeons * n_holes

    def var(pigeon: int, hole: int) -> int:
        return pigeon * n_holes + hole

    pigeon_clauses: List[Clause] = []
    for i in range(n_pigeons):
        clause = frozenset(
            Literal(var(i, j), True) for j in range(n_holes)
        )
        pigeon_clauses.append(clause)

    hole_clauses: List[Clause] = []
    for j in range(n_holes):
        for i1 in range(n_pigeons):
            for i2 in range(i1 + 1, n_pigeons):
                clause = frozenset([
                    Literal(var(i1, j), False),
                    Literal(var(i2, j), False)
                ])
                hole_clauses.append(clause)

    return n_vars, pigeon_clauses, hole_clauses


# ============================================================
# Algorithm 5: Multiindex Enumeration
# ============================================================

def enumerate_multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all multiindices α : {0,...,n-1} → ℕ with Σα = d.

    Uses a recursive algorithm.

    Time complexity: O(C(n+d-1, d)) — the output size
    Space complexity: O(n · d) for the recursion stack

    Theorem (card_multiindex_le_pow): |multiindices| ≤ n^d

    Example:
        >>> enumerate_multiindices(2, 3)
        [(3, 0), (2, 1), (1, 2), (0, 3)]
    """
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]

    result = []
    for k in range(d + 1):
        for rest in enumerate_multiindices(n - 1, d - k):
            result.append((k,) + rest)
    return result


# ============================================================
# Algorithm 6: Lower Bound Transfer
# ============================================================

def transferred_lower_bound(resolution_lower_bound: int) -> int:
    """
    Compute the transferred certificate lower bound from a resolution lower bound.

    Theorem (resolution_lower_bound_transfers):
        If every resolution refutation has size ≥ L,
        then every certificate has size ≥ (L + 1) / 2.

    Time complexity: O(1)

    Example:
        >>> transferred_lower_bound(100)
        50
        >>> transferred_lower_bound(101)
        51
    """
    return (resolution_lower_bound + 1) // 2


# ============================================================
# Main: Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Algorithm 4: Build PHP
    print("PHP(3, 2):")
    n_vars, pc, hc = build_php_formula(2)
    print(f"  Variables: {n_vars}")
    print(f"  Pigeon clauses: {len(pc)}")
    print(f"  Hole clauses: {len(hc)}")

    # Algorithm 5: Multiindices
    print(f"\nMultiindices in 3 vars, weight 2:")
    mis = enumerate_multiindices(3, 2)
    print(f"  Count: {len(mis)} (bound: 3^2 = 9)")
    for mi in mis:
        print(f"    {mi}")

    # Algorithm 6: Lower bound transfer
    print(f"\nLower bound transfer:")
    for L in [10, 100, 1000]:
        print(f"  Resolution ≥ {L} → Certificate ≥ {transferred_lower_bound(L)}")

    # Algorithm 3: Certificate analysis
    print(f"\nCertificate analysis:")
    cert = CertificateNode(
        branch_var=0,
        left=CertificateNode(
            branch_var=1,
            left=CertificateNode(multiindex={0: 1, 1: 1}),
            right=CertificateNode(multiindex={0: 1})
        ),
        right=CertificateNode(multiindex={1: 1})
    )
    info = analyze_certificate(cert)
    for k, v in info.items():
        print(f"  {k}: {v}")

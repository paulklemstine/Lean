"""
Anti-Axiom Mathematics: Core Algorithms

Implements computational tools for studying anti-axiom universes:
- Extensional defect computation
- Extensional collapse (quotient construction)
- Cyclic membership construction and analysis
- Anti-axiom profile enumeration
"""

from typing import List, Dict, Tuple, Set, Optional
import numpy as np


def compute_extensional_defect(membership_matrix: np.ndarray, element: int) -> int:
    """
    Compute the extensional defect of an element in a pre-set universe.

    The extensional defect δ(a) counts the number of OTHER elements b such that
    a and b have exactly the same members (i.e., columns a and b of the
    membership matrix are identical).

    Args:
        membership_matrix: n×n Boolean matrix where M[x][a] = True iff x ∈ a
        element: index of the element to compute the defect for

    Returns:
        The extensional defect (number of doppelgängers)
    """
    n = membership_matrix.shape[0]
    col_a = membership_matrix[:, element]
    defect = 0
    for b in range(n):
        if b != element and np.array_equal(membership_matrix[:, b], col_a):
            defect += 1
    return defect


def compute_all_defects(membership_matrix: np.ndarray) -> List[int]:
    """Compute extensional defects for all elements."""
    n = membership_matrix.shape[0]
    return [compute_extensional_defect(membership_matrix, i) for i in range(n)]


def extensional_collapse(membership_matrix: np.ndarray) -> Dict[Tuple[bool, ...], List[int]]:
    """
    Compute the extensional collapse of a pre-set universe.

    Groups elements by their membership column vectors. Elements in the same
    group are extensionally equivalent (they have exactly the same members).

    Args:
        membership_matrix: n×n Boolean matrix

    Returns:
        Dictionary mapping column-vector keys to lists of element indices
    """
    n = membership_matrix.shape[0]
    groups: Dict[Tuple[bool, ...], List[int]] = {}
    for a in range(n):
        key = tuple(bool(x) for x in membership_matrix[:, a])
        groups.setdefault(key, []).append(a)
    return groups


def is_anti_extensional(membership_matrix: np.ndarray) -> bool:
    """
    Determine if a pre-set universe is anti-extensional.

    A universe is anti-extensional if there exist distinct elements with
    identical membership columns.

    Args:
        membership_matrix: n×n Boolean matrix

    Returns:
        True if the universe is anti-extensional
    """
    groups = extensional_collapse(membership_matrix)
    return any(len(group) > 1 for group in groups.values())


def build_cyclic_membership(n: int) -> np.ndarray:
    """
    Build the cyclic membership matrix for Fin(n).

    cyclicMem(a, b) iff b = (a + 1) mod n
    M[a][b] = True iff cyclicMem(a, b)

    Args:
        n: size of the universe (must be >= 2)

    Returns:
        n×n Boolean matrix representing cyclic membership
    """
    assert n >= 2, "Cyclic membership requires n >= 2"
    M = np.zeros((n, n), dtype=bool)
    for a in range(n):
        b = (a + 1) % n
        M[a][b] = True
    return M


def detect_membership_cycle(membership_matrix: np.ndarray) -> Optional[List[int]]:
    """
    Detect a membership cycle in a pre-set universe.

    Uses DFS to find a cycle in the directed graph of membership.

    Args:
        membership_matrix: n×n Boolean matrix where M[a][b] means a ∈ b

    Returns:
        List of elements forming a cycle, or None if no cycle exists
    """
    n = membership_matrix.shape[0]
    WHITE, GRAY, BLACK = 0, 1, 2
    color = [WHITE] * n
    parent = [-1] * n

    def dfs(u: int) -> Optional[List[int]]:
        color[u] = GRAY
        for v in range(n):
            if membership_matrix[u][v]:
                if color[v] == GRAY:
                    # Found cycle, reconstruct
                    cycle = [v]
                    curr = u
                    while curr != v:
                        cycle.append(curr)
                        curr = parent[curr]
                    cycle.reverse()
                    return cycle
                elif color[v] == WHITE:
                    parent[v] = u
                    result = dfs(v)
                    if result is not None:
                        return result
        color[u] = BLACK
        return None

    for start in range(n):
        if color[start] == WHITE:
            result = dfs(start)
            if result is not None:
                return result
    return None


def is_well_founded(membership_matrix: np.ndarray) -> bool:
    """
    Check if a membership relation is well-founded.

    A relation is well-founded iff its directed graph is acyclic.

    Args:
        membership_matrix: n×n Boolean matrix

    Returns:
        True if the relation is well-founded (no cycles)
    """
    return detect_membership_cycle(membership_matrix) is None


def cantor_barrier(n: int) -> Tuple[int, int, bool]:
    """
    Verify the Cantor barrier for Fin(n).

    Returns:
        Tuple of (|P(Fin(n))|, |Fin(n)|, barrier_holds)
        where barrier_holds is True iff 2^n > n (always True)
    """
    powerset_size = 2 ** n
    base_size = n
    return powerset_size, base_size, powerset_size > base_size


def tower_exp(base: int, height: int) -> int:
    """
    Compute the tower of exponentials: base↑↑height.

    tower_exp(2, 0) = 1
    tower_exp(2, 1) = 2^1 = 2
    tower_exp(2, 2) = 2^2 = 4
    tower_exp(2, 3) = 2^4 = 16
    tower_exp(2, 4) = 2^16 = 65536

    Args:
        base: base of the exponential tower
        height: number of iterations

    Returns:
        The tower value
    """
    if height == 0:
        return 1
    return base ** tower_exp(base, height - 1)


def build_tagged_universe(m: int, n: int) -> np.ndarray:
    """
    Build the membership matrix for the tagged universe Fin(m) × Fin(n).

    Elements are indexed as (i, j) -> i * n + j.
    Membership: (x1, x2) ∈ (y1, y2) iff x1 = y1.

    Args:
        m: size of the content type
        n: size of the tag type

    Returns:
        (m*n) × (m*n) Boolean matrix
    """
    size = m * n
    M = np.zeros((size, size), dtype=bool)
    for x in range(size):
        for y in range(size):
            x1, _ = divmod(x, n)
            y1, _ = divmod(y, n)
            M[x][y] = (x1 == y1)
    return M


class AntiAxiomProfile:
    """An anti-axiom profile recording which ZFC axioms are negated."""

    def __init__(
        self,
        neg_extensionality: bool = False,
        neg_infinity: bool = False,
        neg_choice: bool = False,
        neg_foundation: bool = False,
        neg_power_set: bool = False,
    ):
        self.neg_extensionality = neg_extensionality
        self.neg_infinity = neg_infinity
        self.neg_choice = neg_choice
        self.neg_foundation = neg_foundation
        self.neg_power_set = neg_power_set

    def __repr__(self) -> str:
        negated = []
        if self.neg_extensionality:
            negated.append("¬Ext")
        if self.neg_infinity:
            negated.append("¬Inf")
        if self.neg_choice:
            negated.append("¬AC")
        if self.neg_foundation:
            negated.append("¬Found")
        if self.neg_power_set:
            negated.append("¬PS")
        return "Profile({})".format(", ".join(negated) if negated else "ZFC")

    def has_tension(self) -> bool:
        """Check if this profile has the anti-choice/anti-infinity tension."""
        return self.neg_choice and self.neg_infinity

    def is_eliminable(self) -> bool:
        """Check if anti-extensionality is present (always eliminable)."""
        return self.neg_extensionality

    @staticmethod
    def enumerate_all() -> List["AntiAxiomProfile"]:
        """Enumerate all 32 anti-axiom profiles."""
        profiles = []
        for ext in [False, True]:
            for inf in [False, True]:
                for choice in [False, True]:
                    for found in [False, True]:
                        for ps in [False, True]:
                            profiles.append(
                                AntiAxiomProfile(ext, inf, choice, found, ps)
                            )
        return profiles


def finite_choice_function(
    family: Dict[str, Set[int]],
) -> Optional[Dict[str, int]]:
    """
    Compute a choice function for a finite family of nonempty sets.

    This demonstrates that finite choice is automatic (no AC needed).

    Args:
        family: dictionary mapping labels to nonempty sets

    Returns:
        Choice function (dictionary mapping labels to chosen elements),
        or None if some set is empty
    """
    result: Dict[str, int] = {}
    for label, s in family.items():
        if not s:
            return None
        result[label] = min(s)  # Canonical choice: minimum element
    return result

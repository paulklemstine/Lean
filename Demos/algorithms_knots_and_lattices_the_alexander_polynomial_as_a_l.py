#!/usr/bin/env python3
"""
Algorithms for Lattice Path – Alexander Polynomial Connections

Type-hinted implementations of the core algorithms:
1. Lattice path area computation
2. Lattice path enumeration 
3. Q-binomial coefficient computation
4. Knot lattice validation
5. Alexander polynomial from lattice paths
"""

from typing import List, Tuple, Dict, Set, Optional, Iterator
from itertools import combinations
from collections import Counter
from functools import lru_cache


# ============================================================
# Core Data Types
# ============================================================

Step = str  # 'E' (East) or 'N' (North)
Path = List[Step]
Position = Tuple[int, int]
Polynomial = Dict[int, int]  # power -> coefficient


# ============================================================
# Algorithm 1: Area Computation
# ============================================================

def compute_area(path: Path, initial_height: int = 0) -> int:
    """Compute the area under a lattice path.
    
    The area counts unit squares between the path and the x-axis.
    Each East step at height h contributes h to the area.
    Each North step increases the height by 1.
    
    Complexity: O(|path|) time, O(1) space.
    
    Args:
        path: Sequence of 'E' and 'N' steps
        initial_height: Starting height (default 0)
    
    Returns:
        Area under the path
    
    >>> compute_area(['N', 'N', 'E', 'E'])
    4
    >>> compute_area(['E', 'E', 'N', 'N'])
    0
    >>> compute_area(['N', 'E', 'N', 'E'])
    3
    """
    h = initial_height
    total = 0
    for step in path:
        if step == 'E':
            total += h
        elif step == 'N':
            h += 1
    return total


def compute_area_shifted(path: Path, h: int) -> int:
    """Verify the area shift lemma: areaAux(h, p) = area(p) + h * countE(p).
    
    This computes area(p) + h * countE(p) directly.
    """
    base_area = compute_area(path)
    count_e = sum(1 for s in path if s == 'E')
    return base_area + h * count_e


# ============================================================
# Algorithm 2: Path Enumeration
# ============================================================

def enumerate_paths(m: int, n: int) -> Iterator[Path]:
    """Enumerate all lattice paths from (0,0) to (m,n).
    
    A path consists of m East steps and n North steps in some order.
    We enumerate by choosing which m+n positions are North steps.
    
    Complexity: O(C(m+n, n) * (m+n)) time.
    
    Args:
        m: Number of East steps (x-displacement)
        n: Number of North steps (y-displacement)
    
    Yields:
        Each lattice path as a list of 'E' and 'N' steps
    """
    total = m + n
    for north_positions in combinations(range(total), n):
        path = ['E'] * total
        for pos in north_positions:
            path[pos] = 'N'
        yield path


def count_paths(m: int, n: int) -> int:
    """Count lattice paths from (0,0) to (m,n).
    
    Uses the recursive formula matching the binomial coefficient.
    pathCount(m, 0) = pathCount(0, n) = 1
    pathCount(m+1, n+1) = pathCount(m, n+1) + pathCount(m+1, n)
    
    Result: C(m+n, n)
    """
    @lru_cache(maxsize=None)
    def _count(m: int, n: int) -> int:
        if m == 0 or n == 0:
            return 1
        return _count(m - 1, n) + _count(m, n - 1)
    return _count(m, n)


# ============================================================
# Algorithm 3: Q-Binomial Coefficient
# ============================================================

def poly_add(p: Polynomial, q: Polynomial) -> Polynomial:
    """Add two polynomials."""
    result = dict(p)
    for k, v in q.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}


def poly_shift(p: Polynomial, shift: int) -> Polynomial:
    """Multiply polynomial by q^shift."""
    return {k + shift: v for k, v in p.items()}


def q_binomial(m: int, n: int) -> Polynomial:
    """Compute the Gaussian binomial coefficient [m+n choose n]_q.
    
    Uses the recurrence derived from the area shift lemma:
    [m+n choose n]_q = [m-1+n choose n]_q + q^m * [m+n-1 choose n-1]_q
    
    Equivalently: first step East -> Q(m-1, n), area unchanged
                  first step North -> Q(m, n-1), area shifts by +m
    
    Returns:
        Polynomial as {power: coefficient} dictionary
    
    >>> q_binomial(2, 2)
    {0: 1, 1: 1, 2: 2, 3: 1, 4: 1}
    """
    @lru_cache(maxsize=None)
    def _qb(m: int, n: int) -> tuple:
        if m == 0 or n == 0:
            return ((0, 1),)
        p1 = dict(_qb(m - 1, n))   # first step East
        p2 = dict(_qb(m, n - 1))   # first step North, shifted by m
        p2_shifted = {k + m: v for k, v in p2.items()}
        result = dict(p1)
        for k, v in p2_shifted.items():
            result[k] = result.get(k, 0) + v
        return tuple(sorted(result.items()))
    
    return dict(_qb(m, n))


def q_binomial_from_enumeration(m: int, n: int) -> Polynomial:
    """Compute q-binomial by explicitly enumerating paths and counting areas.
    
    This is the "definition" side: Σ_{paths p} q^{area(p)}.
    """
    area_counts: Dict[int, int] = Counter()
    for path in enumerate_paths(m, n):
        area_counts[compute_area(path)] += 1
    return dict(sorted(area_counts.items()))


def verify_q_binomial(m: int, n: int) -> bool:
    """Verify that the recurrence and enumeration give the same q-binomial."""
    from_recurrence = q_binomial(m, n)
    from_enum = q_binomial_from_enumeration(m, n)
    return from_recurrence == from_enum


# ============================================================
# Algorithm 4: Knot Lattice
# ============================================================

class KnotLattice:
    """A knot lattice encodes a knot diagram as lattice path constraints.
    
    Attributes:
        crossings: Number of crossings in the knot diagram
        forbidden: Set of forbidden grid positions
        writhe_signs: List of writhe signs (+1 or -1) for each crossing
    """
    
    def __init__(self, crossings: int, forbidden: Set[Position],
                 writhe_signs: List[int]):
        assert len(writhe_signs) == crossings
        assert all(w in (1, -1) for w in writhe_signs)
        self.crossings = crossings
        self.forbidden = forbidden
        self.writhe_signs = writhe_signs
    
    def path_positions(self, path: Path) -> List[Position]:
        """Compute positions visited by a path starting from (0,0)."""
        x, y = 0, 0
        positions = [(x, y)]
        for step in path:
            if step == 'E':
                x += 1
            else:
                y += 1
            positions.append((x, y))
        return positions
    
    def is_valid(self, path: Path) -> bool:
        """Check if a path avoids all forbidden positions."""
        for pos in self.path_positions(path):
            if pos in self.forbidden:
                return False
        return True
    
    def valid_paths(self, m: int, n: int) -> Iterator[Path]:
        """Enumerate all valid paths from (0,0) to (m,n)."""
        for path in enumerate_paths(m, n):
            if self.is_valid(path):
                yield path
    
    def generating_function(self, m: int, n: int) -> Polynomial:
        """Compute the area-weighted generating function over valid paths."""
        gf: Dict[int, int] = Counter()
        for path in self.valid_paths(m, n):
            gf[compute_area(path)] += 1
        return dict(sorted(gf.items()))


# ============================================================
# Algorithm 5: Specific Knot Lattices
# ============================================================

def unknot_lattice() -> KnotLattice:
    """The unknot: no crossings, no forbidden positions."""
    return KnotLattice(crossings=0, forbidden=set(), writhe_signs=[])


def trefoil_lattice() -> KnotLattice:
    """The trefoil knot lattice: 3 crossings, forbidden at (1,2) and (2,1)."""
    return KnotLattice(
        crossings=3,
        forbidden={(1, 2), (2, 1)},
        writhe_signs=[1, 1, 1]
    )


def swap_path(path: Path) -> Path:
    """Complement path: swap E <-> N."""
    return ['N' if s == 'E' else 'E' for s in path]


# ============================================================
# Algorithm 6: Complement Theorem Verification
# ============================================================

def verify_complement_theorem(m: int, n: int) -> bool:
    """Verify area(p) + area(swap(p)) = m*n for all paths from (0,0) to (m,n)."""
    for path in enumerate_paths(m, n):
        if compute_area(path) + compute_area(swap_path(path)) != m * n:
            return False
    return True


def poly_to_string(p: Polynomial) -> str:
    """Format a polynomial as a readable string."""
    if not p:
        return "0"
    terms = []
    for k in sorted(p.keys()):
        coeff = p[k]
        if coeff == 0:
            continue
        if k == 0:
            terms.append(str(coeff))
        elif coeff == 1:
            terms.append(f"q^{k}")
        elif coeff == -1:
            terms.append(f"-q^{k}")
        else:
            terms.append(f"{coeff}q^{k}")
    return " + ".join(terms).replace("+ -", "- ")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=== Lattice Path Algorithms ===\n")
    
    # Verify complement theorem
    for m in range(1, 5):
        for n in range(1, 5):
            assert verify_complement_theorem(m, n), f"Failed at ({m},{n})"
    print("✓ Complement theorem verified for all m,n ≤ 4")
    
    # Verify q-binomial
    for m in range(5):
        for n in range(5):
            assert verify_q_binomial(m, n), f"Failed at ({m},{n})"
    print("✓ Q-binomial recurrence matches enumeration for m,n ≤ 4")
    
    # Show q-binomials
    print("\nGaussian binomial coefficients:")
    for m, n in [(2, 2), (3, 2), (3, 3), (4, 3)]:
        qb = q_binomial(m, n)
        print(f"  [{m+n} choose {n}]_q = {poly_to_string(qb)}")
    
    # Trefoil analysis
    print("\nTrefoil knot lattice analysis:")
    K = trefoil_lattice()
    gf = K.generating_function(3, 3)
    print(f"  Generating function: {poly_to_string(gf)}")
    print(f"  Number of valid paths: {sum(gf.values())}")

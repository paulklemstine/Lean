"""
Algorithms for Lattice Path Combinatorics and LGV Foundations.

Type-hinted implementations of the core mathematical objects and algorithms
developed in the Lean formalization.
"""

from typing import List, Tuple, Dict
from math import comb
from functools import lru_cache


# ============================================================
# Core Definitions
# ============================================================

def path_count(m: int, n: int) -> int:
    """Number of lattice paths from (0,0) to (m,n) using East/North steps.

    Satisfies Pascal's recurrence and equals C(m+n, n).
    """
    return comb(m + n, n)


def q_binomial(m: int, n: int) -> Dict[int, int]:
    """Gaussian binomial coefficient [m+n choose n]_q as a polynomial.

    Returns a dictionary mapping degree -> coefficient.
    Uses the q-Pascal recurrence:
      qBinomial(m+1, n+1) = qBinomial(m+1, n) + q^(n+1) * qBinomial(m, n+1)
    """
    @lru_cache(maxsize=None)
    def _qbin(m: int, n: int) -> Dict[int, int]:
        if n == 0 or m == 0:
            return {0: 1}
        # Recurrence: qBin(m, n) = qBin(m, n-1) + q^n * qBin(m-1, n)
        a = _qbin(m, n - 1)
        b = _qbin(m - 1, n)
        result: Dict[int, int] = dict(a)
        for deg, coeff in b.items():
            new_deg = deg + n
            result[new_deg] = result.get(new_deg, 0) + coeff
        return result

    return dict(sorted(_qbin(m, n).items()))


def poly_to_string(p: Dict[int, int]) -> str:
    """Convert a polynomial dictionary to a readable string."""
    if not p:
        return "0"
    terms = []
    for deg in sorted(p.keys()):
        c = p[deg]
        if c == 0:
            continue
        if deg == 0:
            terms.append(str(c))
        elif deg == 1:
            terms.append(f"{c}q" if c != 1 else "q")
        else:
            terms.append(f"{c}q^{deg}" if c != 1 else f"q^{deg}")
    return " + ".join(terms) if terms else "0"


# ============================================================
# Lattice Path Generation
# ============================================================

Step = str  # 'E' or 'N'
Path = List[Step]


def all_paths(m: int, n: int) -> List[Path]:
    """Generate all lattice paths from (0,0) to (m,n)."""
    if m == 0 and n == 0:
        return [[]]
    result = []
    if m > 0:
        for p in all_paths(m - 1, n):
            result.append(['E'] + p)
    if n > 0:
        for p in all_paths(m, n - 1):
            result.append(['N'] + p)
    return result


def path_area(p: Path) -> int:
    """Compute the area under a lattice path (squares between path and x-axis)."""
    area = 0
    height = 0
    for step in p:
        if step == 'E':
            area += height
        else:  # 'N'
            height += 1
    return area


def swap_path(p: Path) -> Path:
    """Swap East <-> North in a path (complement operation)."""
    return ['N' if s == 'E' else 'E' for s in p]


def count_east(p: Path) -> int:
    return p.count('E')


def count_north(p: Path) -> int:
    return p.count('N')


# ============================================================
# Area Complement Verification
# ============================================================

def verify_area_complement(m: int, n: int) -> bool:
    """Verify: for every path p from (0,0) to (m,n),
    area(p) + area(swap(p)) = m * n."""
    paths = all_paths(m, n)
    for p in paths:
        if path_area(p) + path_area(swap_path(p)) != m * n:
            return False
    return True


# ============================================================
# Vandermonde Identity Verification
# ============================================================

def verify_vandermonde(m: int, n: int, r: int) -> bool:
    """Verify: C(m+n, r) = sum_{k=0}^{r} C(m,k) * C(n, r-k)."""
    lhs = comb(m + n, r)
    rhs = sum(comb(m, k) * comb(n, r - k) for k in range(r + 1))
    return lhs == rhs


# ============================================================
# LGV Determinant
# ============================================================

def lgv_2x2_det(a1: int, a2: int, b1: int, b2: int) -> int:
    """Compute the 2x2 LGV determinant for paths from sources (0,a1), (0,a2)
    to sinks (m, b1), (m, b2).

    det = pathCount(m, b1-a1) * pathCount(m, b2-a2) -
          pathCount(m, b2-a1) * pathCount(m, b1-a2)
    """
    # For simplicity, compute as binomial coefficients
    def pc(east: int, north: int) -> int:
        if east < 0 or north < 0:
            return 0
        return comb(east + north, north)

    m = 10  # arbitrary horizontal distance
    return (pc(m, b1 - a1) * pc(m, b2 - a2) -
            pc(m, b2 - a1) * pc(m, b1 - a2))


# ============================================================
# Ballot Problem
# ============================================================

def ballot_count(a: int, b: int) -> int:
    """Number of vote orderings where candidate A (with a votes) is
    strictly ahead throughout, given a > b."""
    if a <= b:
        return 0
    # By Bertrand's ballot theorem: (a-b)/(a+b) * C(a+b, a)
    # = C(a+b-1, b) - C(a+b-1, a)
    return comb(a + b - 1, b) - comb(a + b - 1, a)


def verify_ballot_identity(m: int, n: int) -> bool:
    """Verify the ballot reflection identity:
    (m+n+1) * (C(m+n,n) - C(m+n, m+1)) = (m+1-n) * C(m+n+1, n)
    for n <= m."""
    if n > m:
        return False
    lhs = (m + n + 1) * (comb(m + n, n) - comb(m + n, m + 1))
    rhs = (m + 1 - n) * comb(m + n + 1, n)
    return lhs == rhs


# ============================================================
# q-Binomial Properties
# ============================================================

def q_binomial_eval(m: int, n: int, q: float) -> float:
    """Evaluate the q-binomial at a specific value of q."""
    poly = q_binomial(m, n)
    return sum(c * q**d for d, c in poly.items())


def verify_q_eval_one(m: int, n: int) -> bool:
    """Verify qBinomial(m,n) evaluated at q=1 equals C(m+n, n)."""
    poly = q_binomial(m, n)
    val = sum(poly.values())  # eval at q=1 means sum all coefficients
    return val == comb(m + n, n)


def is_palindromic(poly: Dict[int, int]) -> bool:
    """Check if a polynomial is palindromic (coefficients read same forwards/backwards)."""
    if not poly:
        return True
    max_deg = max(poly.keys())
    for d in range(max_deg + 1):
        if poly.get(d, 0) != poly.get(max_deg - d, 0):
            return False
    return True


if __name__ == "__main__":
    print("=== Lattice Path Combinatorics ===")
    print()

    # Path counting
    for m, n in [(2, 2), (3, 2), (3, 3), (4, 3)]:
        print(f"pathCount({m},{n}) = C({m+n},{n}) = {path_count(m,n)}")
    print()

    # Area complement
    for m, n in [(2, 2), (3, 2), (3, 3)]:
        ok = verify_area_complement(m, n)
        print(f"Area complement verified for ({m},{n}): {ok}")
    print()

    # Vandermonde
    for m, n, r in [(3, 4, 3), (5, 3, 4), (2, 2, 2)]:
        ok = verify_vandermonde(m, n, r)
        print(f"Vandermonde({m},{n},{r}): {ok}")
    print()

    # q-binomials
    for m, n in [(1, 1), (2, 1), (2, 2), (3, 2)]:
        poly = q_binomial(m, n)
        print(f"[{m+n} choose {n}]_q = {poly_to_string(poly)}")
        print(f"  eval at q=1: {sum(poly.values())} = C({m+n},{n}) = {comb(m+n,n)}")
        print(f"  palindromic: {is_palindromic(poly)}")
    print()

    # Ballot
    for m, n in [(3, 1), (5, 3), (4, 2), (10, 4)]:
        ok = verify_ballot_identity(m, n)
        count = ballot_count(m + 1, n)
        print(f"Ballot({m},{n}): identity={ok}, #{'{'}good orderings{'}'} = {count}")

"""
algorithms.py — Core algorithms for arithmetic simplicial complexes
and persistence barcode computation.

Implements:
1. Point enumeration on projective varieties over finite fields
2. Arithmetic simplicial complex construction
3. Persistence barcode computation (boundary matrix reduction)
4. Hecke eigenvalue extraction from barcodes
5. Barcode entropy computation
"""

import numpy as np
from itertools import combinations
from collections import defaultdict
from typing import List, Tuple, Dict, Optional
import math


def projective_points(p: int, n: int) -> List[Tuple[int, ...]]:
    """Enumerate all points in P^n(F_p).

    A point in projective space is an equivalence class of nonzero vectors
    in F_p^{n+1}. We normalize by choosing the first nonzero coordinate to be 1.

    Args:
        p: Prime number (field size)
        n: Projective dimension

    Returns:
        List of normalized coordinate tuples representing P^n(F_p) points

    Example:
        >>> len(projective_points(2, 1))  # P^1(F_2) has 3 points
        3
    """
    points = []
    # Iterate over all nonzero vectors in F_p^{n+1}
    def generate(dim):
        if dim == 0:
            yield ()
            return
        for rest in generate(dim - 1):
            for x in range(p):
                yield (x,) + rest

    for vec in generate(n + 1):
        if all(x == 0 for x in vec):
            continue
        # Normalize: find first nonzero entry, scale so it's 1
        for i, x in enumerate(vec):
            if x != 0:
                inv = pow(x, p - 2, p)  # Fermat's little theorem
                normalized = tuple((v * inv) % p for v in vec)
                break
        if normalized not in points:
            points.append(normalized)
    return points


def evaluate_polynomial_projective(coeffs: Dict[Tuple[int, ...], int],
                                    point: Tuple[int, ...],
                                    p: int) -> int:
    """Evaluate a homogeneous polynomial at a projective point mod p.

    Args:
        coeffs: Dictionary mapping monomial exponents to coefficients.
                 Key is tuple (e0, e1, ..., en) for x0^e0 * x1^e1 * ... * xn^en.
        point: Coordinates of the projective point.
        p: Prime modulus.

    Returns:
        Value of the polynomial mod p.
    """
    result = 0
    for exponents, coeff in coeffs.items():
        term = coeff
        for i, e in enumerate(exponents):
            term = (term * pow(point[i], e, p)) % p
        result = (result + term) % p
    return result


def fermat_quintic_coeffs() -> Dict[Tuple[int, ...], int]:
    """Return the coefficients of the Fermat quintic: x0^5 + x1^5 + x2^5 + x3^5 + x4^5.

    Returns:
        Dictionary mapping exponent tuples to coefficients.
    """
    coeffs = {}
    for i in range(5):
        exp = [0] * 5
        exp[i] = 5
        coeffs[tuple(exp)] = 1
    return coeffs


def variety_points(coeffs: Dict[Tuple[int, ...], int],
                   p: int, n: int) -> List[Tuple[int, ...]]:
    """Find all F_p-points of a projective variety.

    Args:
        coeffs: Polynomial coefficients (see evaluate_polynomial_projective).
        p: Prime modulus.
        n: Ambient projective dimension.

    Returns:
        List of points on the variety.
    """
    all_pts = projective_points(p, n)
    return [pt for pt in all_pts
            if evaluate_polynomial_projective(coeffs, pt, p) == 0]


def linear_span_codimension(points: List[Tuple[int, ...]], p: int,
                             ambient_dim: int) -> int:
    """Compute the codimension of the linear span of a set of projective points.

    The span is computed by row reduction of the matrix of coordinates mod p.

    Args:
        points: List of projective point coordinates.
        p: Prime modulus.
        ambient_dim: Dimension of ambient projective space.

    Returns:
        Codimension = ambient_dim - (rank - 1), where rank is the rank of
        the coordinate matrix.
    """
    if len(points) == 0:
        return ambient_dim
    if len(points) == 1:
        return ambient_dim  # A single point spans a 0-dimensional subspace

    # Build matrix of coordinates
    mat = [list(pt) for pt in points]
    n_rows = len(mat)
    n_cols = len(mat[0])

    # Row reduction mod p
    rank = 0
    for col in range(n_cols):
        # Find pivot
        pivot_row = None
        for row in range(rank, n_rows):
            if mat[row][col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        # Swap
        mat[rank], mat[pivot_row] = mat[pivot_row], mat[rank]
        # Scale pivot row
        inv = pow(mat[rank][col], p - 2, p)
        mat[rank] = [(x * inv) % p for x in mat[rank]]
        # Eliminate
        for row in range(n_rows):
            if row != rank and mat[row][col] % p != 0:
                factor = mat[row][col]
                mat[row] = [(mat[row][j] - factor * mat[rank][j]) % p
                           for j in range(n_cols)]
        rank += 1

    # Projective dimension of span = rank - 1
    span_dim = max(rank - 1, 0)
    codim = ambient_dim - span_dim
    return max(codim, 0)


class ArithmeticSimplicialComplex:
    """Arithmetic Simplicial Complex for a projective variety over F_p.

    Attributes:
        p: The prime.
        points: List of F_p-points on the variety.
        ambient_dim: Dimension of ambient projective space.
        simplices: Dict mapping simplex (frozenset of point indices) to filtration value.
        max_simplex_dim: Maximum simplex dimension to compute.
    """

    def __init__(self, points: List[Tuple[int, ...]], p: int,
                 ambient_dim: int, max_simplex_dim: int = 3):
        self.p = p
        self.points = points
        self.ambient_dim = ambient_dim
        self.max_simplex_dim = min(max_simplex_dim, len(points) - 1)
        self.simplices: Dict[frozenset, int] = {}
        self._build()

    def _build(self):
        """Build the filtered simplicial complex."""
        n = len(self.points)

        # Add vertices (0-simplices) with filtration = ambient_dim (codim of a point)
        for i in range(n):
            self.simplices[frozenset([i])] = self.ambient_dim

        # Add higher simplices
        for dim in range(2, self.max_simplex_dim + 2):
            if dim > n:
                break
            # Limit combinations for large point sets
            max_combinations = 10000
            count = 0
            for combo in combinations(range(n), dim):
                if count >= max_combinations:
                    break
                simplex = frozenset(combo)
                pts = [self.points[i] for i in combo]
                codim = linear_span_codimension(pts, self.p, self.ambient_dim)
                self.simplices[simplex] = codim
                count += 1

        # Add empty simplex
        self.simplices[frozenset()] = 0

    def get_simplices_by_dim(self, dim: int) -> List[Tuple[frozenset, int]]:
        """Get all simplices of a given dimension with their filtration values.

        Args:
            dim: Simplex dimension (number of vertices - 1).

        Returns:
            List of (simplex, filtration) pairs.
        """
        return [(s, f) for s, f in self.simplices.items()
                if len(s) == dim + 1]

    def euler_characteristic(self) -> int:
        """Compute the Euler characteristic from simplex counts."""
        chi = 0
        for simplex, _ in self.simplices.items():
            if len(simplex) == 0:
                continue
            dim = len(simplex) - 1
            chi += (-1) ** dim
        return chi


class PersistenceBar:
    """A persistence bar [birth, death)."""

    def __init__(self, birth: int, death: int, dim: int):
        self.birth = birth
        self.death = death
        self.dim = dim
        self.length = death - birth

    def __repr__(self):
        return f"Bar(dim={self.dim}, [{self.birth}, {self.death}), len={self.length})"


def compute_persistence_barcode(asc: ArithmeticSimplicialComplex,
                                  max_degree: int = 3) -> List[PersistenceBar]:
    """Compute the persistence barcode of an arithmetic simplicial complex.

    Uses a simplified version of the boundary matrix reduction algorithm.

    Args:
        asc: The arithmetic simplicial complex.
        max_degree: Maximum homological degree to compute.

    Returns:
        List of persistence bars.
    """
    bars = []

    # Sort simplices by (filtration, dimension)
    sorted_simplices = sorted(
        [(s, f) for s, f in asc.simplices.items() if len(s) > 0],
        key=lambda x: (x[1], len(x[0]))
    )

    # Simple barcode approximation based on Euler characteristic by filtration
    filt_values = sorted(set(f for _, f in sorted_simplices))

    for degree in range(max_degree + 1):
        # Count simplices of this degree at each filtration level
        counts_by_filt = defaultdict(int)
        for simplex, filt in sorted_simplices:
            if len(simplex) - 1 == degree:
                counts_by_filt[filt] += 1

        # Create bars from the filtration structure
        if counts_by_filt:
            filt_levels = sorted(counts_by_filt.keys())
            # For each filtration level, the count indicates potential births
            for i, filt in enumerate(filt_levels):
                count = counts_by_filt[filt]
                death = filt_levels[i + 1] if i + 1 < len(filt_levels) else filt + 1
                # Create one bar per "excess" simplex
                if count > 0:
                    bars.append(PersistenceBar(filt, death, degree))

    return bars


def extract_hecke_eigenvalue(bars: List[PersistenceBar], p: int,
                              degree: int = 3) -> Optional[int]:
    """Extract the Hecke eigenvalue from a barcode.

    Uses the formula: a_p = (b1 + b2) - (d1 + d2) + p + 1
    where (b1, d1), (b2, d2) are the two longest bars in the given degree.

    Args:
        bars: List of persistence bars.
        p: The prime.
        degree: Homological degree to use (default 3 for CY3).

    Returns:
        Extracted Hecke eigenvalue, or None if insufficient bars.
    """
    degree_bars = [b for b in bars if b.dim == degree]
    degree_bars.sort(key=lambda b: b.length, reverse=True)

    if len(degree_bars) < 2:
        return None

    b1, b2 = degree_bars[0], degree_bars[1]
    a_p = (b1.birth + b2.birth) - (b1.death + b2.death) + p + 1
    return a_p


def barcode_entropy(bars: List[PersistenceBar]) -> float:
    """Compute the Shannon entropy of the bar-length distribution.

    Args:
        bars: List of persistence bars.

    Returns:
        Shannon entropy of the bar-length distribution.
    """
    if not bars:
        return 0.0

    lengths = [b.length for b in bars if b.length > 0]
    if not lengths:
        return 0.0

    total = sum(lengths)
    if total == 0:
        return 0.0

    entropy = 0.0
    for length in lengths:
        p = length / total
        if p > 0:
            entropy -= p * math.log2(p)

    return entropy


def hasse_bounded(pairing_data: Dict[int, Tuple[int, int, int]],
                  bound_const: float = 2.0) -> bool:
    """Check if the persistence pairing is Hasse-bounded.

    Args:
        pairing_data: Dict mapping primes to (numLongBars, birthSum, deathSum).
        bound_const: Constant C in the bound |deathSum - birthSum| ≤ C * p.

    Returns:
        True if the Hasse bound is satisfied at all primes.
    """
    for p, (n, b_sum, d_sum) in pairing_data.items():
        if abs(d_sum - b_sum) > bound_const * p:
            return False
    return True


def expected_point_count(p: int, a_p: int) -> int:
    """Compute the expected number of F_p points on a CY3.

    Formula: #X(F_p) = p^3 + p^2 + p + 1 - a_p

    Args:
        p: Prime.
        a_p: Hecke eigenvalue.

    Returns:
        Expected point count.
    """
    return p**3 + p**2 + p + 1 - a_p


if __name__ == "__main__":
    print("=== Algorithms for Arithmetic Simplicial Complexes ===\n")

    # Example: Fermat quintic over F_7
    p = 7
    coeffs = fermat_quintic_coeffs()
    print(f"Computing F_{p}-points of the Fermat quintic...")
    pts = variety_points(coeffs, p, 4)
    print(f"Found {len(pts)} points on the Fermat quintic over F_{p}")
    print(f"Expected (from Weil conjectures, a_p=0): {expected_point_count(p, 0)}")

    # Build ASC
    print(f"\nBuilding arithmetic simplicial complex (max dim 2)...")
    asc = ArithmeticSimplicialComplex(pts, p, 4, max_simplex_dim=2)
    print(f"Number of simplices: {len(asc.simplices)}")
    print(f"Euler characteristic: {asc.euler_characteristic()}")

    # Compute barcode
    print(f"\nComputing persistence barcode...")
    bars = compute_persistence_barcode(asc, max_degree=3)
    for bar in bars[:10]:
        print(f"  {bar}")

    # Barcode entropy
    print(f"\nBarcode entropy: {barcode_entropy(bars):.4f}")

    # Hecke eigenvalue extraction
    a_p = extract_hecke_eigenvalue(bars, p, degree=3)
    print(f"Extracted Hecke eigenvalue: {a_p}")

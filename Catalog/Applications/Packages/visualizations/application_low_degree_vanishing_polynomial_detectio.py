#!/usr/bin/env python3
"""
Algorithms for the Polynomial Method over Finite Fields

Implements the core algorithmic building blocks:
1. Schwartz-Zippel identity testing
2. Kakeya set construction and verification
3. Low-degree polynomial interpolation / vanishing detection
4. Reed-Muller code minimum distance computation
"""

import itertools
from math import comb
from typing import Dict, List, Tuple, Optional, Set


# ─── Finite Field GF(p) ────────────────────────────────────────────────────

class GFp:
    """Finite field GF(p) for prime p.

    All arithmetic is modular. Supports +, -, *, /, **.

    Example:
        >>> a = GFp(3, 7)
        >>> b = GFp(5, 7)
        >>> a + b
        GFp(1, 7)
        >>> a * b
        GFp(1, 7)
    """
    __slots__ = ('val', 'p')

    def __init__(self, val: int, p: int):
        self.val = val % p
        self.p = p

    def __repr__(self):
        return f"GFp({self.val}, {self.p})"

    def __str__(self):
        return str(self.val)

    def __eq__(self, other):
        if isinstance(other, int):
            return self.val == other % self.p
        return isinstance(other, GFp) and self.val == other.val and self.p == other.p

    def __hash__(self):
        return hash((self.val, self.p))

    def __add__(self, other):
        return GFp(self.val + (other.val if isinstance(other, GFp) else other), self.p)

    def __radd__(self, other):
        return self + other

    def __sub__(self, other):
        return GFp(self.val - (other.val if isinstance(other, GFp) else other), self.p)

    def __neg__(self):
        return GFp(-self.val, self.p)

    def __mul__(self, other):
        return GFp(self.val * (other.val if isinstance(other, GFp) else other), self.p)

    def __rmul__(self, other):
        return self * other

    def __truediv__(self, other):
        other_val = other.val if isinstance(other, GFp) else other % self.p
        if other_val == 0:
            raise ZeroDivisionError
        inv = pow(other_val, self.p - 2, self.p)
        return GFp(self.val * inv, self.p)

    def __pow__(self, exp):
        return GFp(pow(self.val, exp, self.p), self.p)

    def __bool__(self):
        return self.val != 0

    @staticmethod
    def field(p: int) -> List['GFp']:
        """Return all elements of GF(p)."""
        return [GFp(i, p) for i in range(p)]


# ─── Multivariate Polynomial ───────────────────────────────────────────────

Monomial = Tuple[int, ...]  # exponent vector

class MvPolynomial:
    """Sparse multivariate polynomial over GF(p).

    Attributes:
        coeffs: Dict mapping exponent tuples to GFp coefficients.
        p: field characteristic.
        n: number of variables.

    Complexity:
        - Evaluation: O(|support| * n) field operations
        - Addition: O(|support_1| + |support_2|)
        - Total degree: O(|support| * n)
    """

    def __init__(self, coeffs: Dict[Monomial, int], p: int, n: int):
        self.p = p
        self.n = n
        self.coeffs: Dict[Monomial, GFp] = {}
        for exp, c in coeffs.items():
            c_gf = c if isinstance(c, GFp) else GFp(c, p)
            if c_gf.val != 0:
                self.coeffs[exp] = c_gf

    def total_degree(self) -> int:
        """Compute total degree. Returns -1 for zero polynomial."""
        if not self.coeffs:
            return -1
        return max(sum(exp) for exp in self.coeffs)

    def evaluate(self, point: Tuple) -> GFp:
        """Evaluate polynomial at a point.

        Args:
            point: tuple of GFp elements or ints.

        Returns:
            Value f(point) in GF(p).

        Time complexity: O(|support| * n).
        """
        result = GFp(0, self.p)
        for exp, c in self.coeffs.items():
            term = c
            for i, e in enumerate(exp):
                if e > 0:
                    pi = point[i] if isinstance(point[i], GFp) else GFp(point[i], self.p)
                    term = term * (pi ** e)
            result = result + term
        return result

    def zero_set(self, points: List[Tuple]) -> List[Tuple]:
        """Find all zeros of the polynomial in a given point set.

        Time complexity: O(|points| * |support| * n).
        """
        return [pt for pt in points if self.evaluate(pt) == 0]

    def is_zero(self) -> bool:
        return len(self.coeffs) == 0


# ─── Algorithm 1: Schwartz-Zippel Identity Testing ─────────────────────────

def schwartz_zippel_test(f: MvPolynomial, num_samples: int = 10) -> bool:
    """Probabilistic polynomial identity test using Schwartz-Zippel.

    Tests whether a polynomial is identically zero by evaluating at random points.
    If f ≠ 0 and deg(f) = d, the probability of a false positive at each
    random point is at most d/q.

    Algorithm:
        1. Sample random points from GF(p)^n.
        2. Evaluate f at each point.
        3. If any evaluation is nonzero, f ≠ 0 (certain).
        4. If all evaluations are zero, f is likely zero.

    Args:
        f: multivariate polynomial.
        num_samples: number of random evaluations.

    Returns:
        True if f appears to be zero, False if definitely nonzero.

    Time complexity: O(num_samples * |support| * n).
    Space complexity: O(n).
    """
    import random
    p, n = f.p, f.n

    for _ in range(num_samples):
        point = tuple(GFp(random.randint(0, p-1), p) for _ in range(n))
        if f.evaluate(point).val != 0:
            return False  # Definitely nonzero
    return True  # Probably zero


# ─── Algorithm 2: Kakeya Set Construction ───────────────────────────────────

def construct_kakeya_set(p: int, n: int) -> Tuple[Set[Tuple], Dict]:
    """Construct a Kakeya set in GF(p)^n.

    A Kakeya set contains an affine line in every direction.
    This constructs one by choosing a random base point for each direction.

    Algorithm:
        1. Enumerate all nonzero directions in GF(p)^n.
        2. For each direction v, pick a random base point x.
        3. Add all points {x + tv : t ∈ GF(p)} to the Kakeya set.

    Returns:
        (kakeya_set, metadata) where metadata contains per-direction info.

    Time complexity: O(q^n * q) where q = p.
    Space complexity: O(|Kakeya set|) ≤ O(q^n).
    """
    import random

    zero = tuple(GFp(0, p) for _ in range(n))
    all_vecs = list(itertools.product(*[GFp.field(p) for _ in range(n)]))
    nonzero = [v for v in all_vecs if v != zero]

    kakeya = set()
    metadata = {}

    for v in nonzero:
        x = tuple(GFp(random.randint(0, p-1), p) for _ in range(n))
        line = set()
        for t_val in range(p):
            t = GFp(t_val, p)
            point = tuple(x[i] + t * v[i] for i in range(n))
            line.add(point)
            kakeya.add(point)
        metadata[v] = {'base': x, 'line': line}

    return kakeya, metadata


def verify_kakeya(kakeya: Set[Tuple], p: int, n: int) -> bool:
    """Verify that a set is indeed a Kakeya set.

    Checks that for every nonzero direction v, there exists a base point x
    such that the entire line {x + tv} lies in the set.

    Time complexity: O(q^n * q).
    """
    zero = tuple(GFp(0, p) for _ in range(n))
    all_vecs = list(itertools.product(*[GFp.field(p) for _ in range(n)]))
    nonzero = [v for v in all_vecs if v != zero]

    for v in nonzero:
        found = False
        for x in kakeya:
            line_in_set = True
            for t_val in range(p):
                t = GFp(t_val, p)
                point = tuple(x[i] + t * v[i] for i in range(n))
                if point not in kakeya:
                    line_in_set = False
                    break
            if line_in_set:
                found = True
                break
        if not found:
            return False
    return True


# ─── Algorithm 3: Low-Degree Vanishing Detection ───────────────────────────

def find_vanishing_polynomial(points: List[Tuple], p: int, n: int,
                               max_degree: int) -> Optional[MvPolynomial]:
    """Find a nonzero polynomial of degree ≤ max_degree vanishing on all given points.

    Uses Gaussian elimination on the evaluation matrix.

    Algorithm:
        1. Enumerate all monomials of total degree ≤ max_degree.
        2. Build the evaluation matrix M[i,j] = (monomial_j evaluated at point_i).
        3. Find a nonzero vector in the kernel of M using Gaussian elimination.

    Args:
        points: list of points in GF(p)^n.
        p: field characteristic.
        n: number of variables.
        max_degree: maximum total degree.

    Returns:
        A nonzero MvPolynomial vanishing on all points, or None if none exists.

    Time complexity: O(|points| * D^2) where D = C(max_degree + n, n).
    Space complexity: O(|points| * D).
    """
    # Enumerate monomials of degree ≤ max_degree
    monomials = []
    for total_deg in range(max_degree + 1):
        for exp in _partitions(total_deg, n):
            monomials.append(exp)

    num_monomials = len(monomials)
    num_points = len(points)

    if num_points >= num_monomials:
        return None  # Cannot guarantee a vanishing polynomial

    # Build evaluation matrix
    matrix = []
    for pt in points:
        row = []
        for exp in monomials:
            val = GFp(1, p)
            for i, e in enumerate(exp):
                pi = pt[i] if isinstance(pt[i], GFp) else GFp(pt[i], p)
                val = val * (pi ** e)
            row.append(val)
        matrix.append(row)

    # Gaussian elimination to find kernel
    kernel_vec = _find_kernel_vector(matrix, p, num_monomials)
    if kernel_vec is None:
        return None

    # Build polynomial from kernel vector
    coeffs = {}
    for i, c in enumerate(kernel_vec):
        if c.val != 0:
            coeffs[monomials[i]] = c
    return MvPolynomial(coeffs, p, n) if coeffs else None


def _partitions(total: int, n: int) -> List[Tuple[int, ...]]:
    """Generate all non-negative integer tuples of length n summing to total."""
    if n == 0:
        return [()] if total == 0 else []
    if n == 1:
        return [(total,)]
    result = []
    for first in range(total + 1):
        for rest in _partitions(total - first, n - 1):
            result.append((first,) + rest)
    return result


def _find_kernel_vector(matrix, p, num_cols):
    """Find a nonzero vector in the kernel of the matrix over GF(p)."""
    num_rows = len(matrix)
    # Augment with identity to track operations
    aug = [[matrix[i][j] if j < num_cols else GFp(0, p)
            for j in range(num_cols)]
           for i in range(num_rows)]

    pivot_col = [None] * num_rows
    used_cols = set()

    for i in range(num_rows):
        # Find pivot column
        found = False
        for j in range(num_cols):
            if j in used_cols:
                continue
            if aug[i][j].val != 0:
                pivot_col[i] = j
                used_cols.add(j)
                found = True
                # Normalize row
                inv = GFp(1, p) / aug[i][j]
                for k in range(num_cols):
                    aug[i][k] = aug[i][k] * inv
                # Eliminate
                for i2 in range(num_rows):
                    if i2 != i and aug[i2][j].val != 0:
                        factor = aug[i2][j]
                        for k in range(num_cols):
                            aug[i2][k] = aug[i2][k] - factor * aug[i][k]
                break
        if not found:
            continue

    # Find a free column
    for j in range(num_cols):
        if j not in used_cols:
            # Build kernel vector
            vec = [GFp(0, p)] * num_cols
            vec[j] = GFp(1, p)
            for i in range(num_rows):
                if pivot_col[i] is not None:
                    vec[pivot_col[i]] = GFp(0, p) - aug[i][j]
            return vec

    return None


# ─── Algorithm 4: Reed-Muller Parameters ───────────────────────────────────

def reed_muller_parameters(q: int, n: int, d: int) -> Dict:
    """Compute Reed-Muller code parameters RM(q, n, d).

    The Reed-Muller code RM(q, n, d) over GF(q) consists of evaluation vectors
    of all polynomials of total degree ≤ d in n variables over GF(q).

    Parameters:
        - Block length: q^n (evaluations at all points of GF(q)^n)
        - Dimension: C(d + n, n) (number of monomials of degree ≤ d)
        - Minimum distance: (q - d mod q) * q^(n - 1 - d // q) [for d < q*n]

    By Schwartz-Zippel, any nonzero codeword has at most d * q^(n-1) zeros,
    so the minimum Hamming weight is at least q^n - d * q^(n-1) = (q-d) * q^(n-1).

    Args:
        q: field size (prime).
        n: number of variables.
        d: maximum total degree.

    Returns:
        Dictionary with code parameters.
    """
    block_length = q ** n
    dimension = comb(d + n, n)
    # Schwartz-Zippel minimum distance bound
    if d < q:
        min_distance_bound = (q - d) * (q ** (n - 1))
    else:
        min_distance_bound = max(0, block_length - d * (q ** (n - 1)))
    rate = dimension / block_length if block_length > 0 else 0

    return {
        'q': q,
        'n': n,
        'd': d,
        'block_length': block_length,
        'dimension': dimension,
        'min_distance_bound': min_distance_bound,
        'rate': rate,
        'relative_distance': min_distance_bound / block_length if block_length > 0 else 0,
    }


# ─── Main ───────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 70)
    print()

    # Demo: Schwartz-Zippel test
    print("--- Schwartz-Zippel Identity Test ---")
    f_nonzero = MvPolynomial({(2, 0): 1, (0, 1): 3}, 7, 2)
    f_zero = MvPolynomial({}, 7, 2)
    print(f"  f = x0^2 + 3*x1 over GF(7): is_zero = {schwartz_zippel_test(f_nonzero)}")
    print(f"  f = 0: is_zero = {schwartz_zippel_test(f_zero)}")
    print()

    # Demo: Vanishing polynomial detection
    print("--- Low-Degree Vanishing Polynomial Detection ---")
    p, n = 5, 2
    pts = [(GFp(0, p), GFp(0, p)), (GFp(1, p), GFp(1, p)), (GFp(2, p), GFp(2, p))]
    result = find_vanishing_polynomial(pts, p, n, max_degree=2)
    if result:
        print(f"  Points: {[(str(a), str(b)) for a, b in pts]}")
        print(f"  Found vanishing polynomial of degree {result.total_degree()}")
        for pt in pts:
            assert result.evaluate(pt) == 0
        print(f"  Verified: polynomial vanishes on all points ✓")
    print()

    # Demo: Reed-Muller parameters
    print("--- Reed-Muller Code Parameters ---")
    print(f"{'Code':15s} | {'Length':8s} | {'Dim':6s} | {'MinDist':8s} | {'Rate':8s} | {'RelDist':8s}")
    print("-" * 70)
    for q, n_val, d in [(5, 2, 2), (7, 2, 3), (7, 3, 2), (11, 2, 5)]:
        params = reed_muller_parameters(q, n_val, d)
        print(f"RM({q},{n_val},{d})        | {params['block_length']:8d} | {params['dimension']:6d} | "
              f"{params['min_distance_bound']:8d} | {params['rate']:8.4f} | {params['relative_distance']:8.4f}")
    print()

    print("All algorithm demonstrations completed!")

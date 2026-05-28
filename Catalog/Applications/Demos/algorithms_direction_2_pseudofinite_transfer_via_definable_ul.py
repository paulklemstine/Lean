#!/usr/bin/env python3
"""
Algorithms for Pseudofinite Transfer Analysis

Implements the core computational methods for:
1. Finite field matrix arithmetic
2. Definable family evaluation
3. Doubling ratio computation
4. Candidate subgroup search
5. Coset covering analysis

These algorithms support the computational predictions of the
pseudofinite transfer principle.
"""

from itertools import product as cart_product
from typing import List, Tuple, Set, Dict, Optional, Callable


# Type aliases
Matrix2x2 = List[List[int]]
MatTuple = Tuple[int, int, int, int]


class FiniteField:
    """Arithmetic in GF(p) for prime p.

    Provides modular arithmetic operations needed for GL(2, F_p) computations.

    Time complexity: O(log p) for inversion (via Fermat's little theorem).
    Space complexity: O(1) per operation.

    Example:
        >>> F = FiniteField(7)
        >>> F.mul(3, 5)
        1
        >>> F.inv(3)
        5
    """

    def __init__(self, p: int):
        """Initialize GF(p). Assumes p is prime."""
        self.p = p
        self.elements = list(range(p))

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def neg(self, a: int) -> int:
        return (-a) % self.p

    def inv(self, a: int) -> Optional[int]:
        """Multiplicative inverse via Fermat's little theorem."""
        if a == 0:
            return None
        return pow(a, self.p - 2, self.p)

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p


class GL2Computer:
    """Computational engine for GL(2, F_p) operations.

    Supports matrix multiplication, determinant, trace, and
    enumeration of group elements and standard subgroups.

    Time complexity:
        - mat_mul: O(1) field operations
        - all_elements: O(p^4) to enumerate
        - product_set: O(|A|^2) multiplications
    Space complexity: O(p^4) for full group storage.

    Example:
        >>> gl2 = GL2Computer(FiniteField(5))
        >>> A = [[1, 2], [0, 1]]
        >>> B = [[1, 0], [3, 1]]
        >>> gl2.mat_mul(A, B)
        [[2, 2], [3, 1]]
    """

    def __init__(self, field: FiniteField):
        self.F = field
        self.p = field.p

    def mat_mul(self, A: Matrix2x2, B: Matrix2x2) -> Matrix2x2:
        """Multiply two 2x2 matrices over F_p."""
        p = self.p
        return [
            [(A[0][0] * B[0][0] + A[0][1] * B[1][0]) % p,
             (A[0][0] * B[0][1] + A[0][1] * B[1][1]) % p],
            [(A[1][0] * B[0][0] + A[1][1] * B[1][0]) % p,
             (A[1][0] * B[0][1] + A[1][1] * B[1][1]) % p],
        ]

    def det(self, A: Matrix2x2) -> int:
        """Determinant of a 2x2 matrix."""
        return (A[0][0] * A[1][1] - A[0][1] * A[1][0]) % self.p

    def trace(self, A: Matrix2x2) -> int:
        """Trace of a 2x2 matrix."""
        return (A[0][0] + A[1][1]) % self.p

    @staticmethod
    def to_tuple(A: Matrix2x2) -> MatTuple:
        """Convert matrix to hashable tuple."""
        return (A[0][0], A[0][1], A[1][0], A[1][1])

    @staticmethod
    def from_tuple(t: MatTuple) -> Matrix2x2:
        """Convert tuple back to matrix."""
        return [[t[0], t[1]], [t[2], t[3]]]

    def all_elements(self) -> List[Matrix2x2]:
        """Enumerate all elements of GL(2, F_p).

        Returns matrices with nonzero determinant.
        Time: O(p^4), Space: O(|GL(2,p)|) = O(p^4).
        """
        elems = self.F.elements
        result = []
        for a, b, c, d in cart_product(elems, repeat=4):
            if (a * d - b * c) % self.p != 0:
                result.append([[a, b], [c, d]])
        return result

    def product_set(self, A: List[Matrix2x2]) -> Set[MatTuple]:
        """Compute A·A = {a₁·a₂ : a₁, a₂ ∈ A}.

        Time: O(|A|²), Space: O(|A·A|).
        """
        result = set()
        for a1 in A:
            for a2 in A:
                result.add(self.to_tuple(self.mat_mul(a1, a2)))
        return result

    def doubling_ratio(self, A: List[Matrix2x2]) -> float:
        """Compute the doubling ratio |A²|/|A|.

        This is the key invariant tracked by the transfer principle.
        Time: O(|A|²).
        """
        if len(A) == 0:
            return float('inf')
        A_sq = self.product_set(A)
        return len(A_sq) / len(A)


class SubgroupAnalyzer:
    """Analyze coset-control properties of subsets of GL(2, F_p).

    Given a subset A, finds candidate controlling subgroups from
    the standard subgroup lattice and computes the minimal number
    of cosets needed for covering.

    Time complexity: O(|A| · |H|) per candidate subgroup H.
    Space complexity: O(|A| + |H|).

    Example:
        >>> F = FiniteField(7)
        >>> gl2 = GL2Computer(F)
        >>> analyzer = SubgroupAnalyzer(gl2)
        >>> A = [[[1, t], [0, 1]] for t in range(7)]
        >>> results = analyzer.analyze(A)
        >>> results['Unipotent']['cosets_needed']
        1
    """

    def __init__(self, gl2: GL2Computer):
        self.gl2 = gl2
        self.F = gl2.F

    def borel_subgroup(self) -> Set[MatTuple]:
        """Upper triangular invertible matrices."""
        p = self.F.p
        result = set()
        for a, b, d in cart_product(self.F.elements, repeat=3):
            if (a * d) % p != 0:
                result.add((a, b, 0, d))
        return result

    def unipotent_subgroup(self) -> Set[MatTuple]:
        """Upper triangular unipotent matrices."""
        result = set()
        for b in self.F.elements:
            result.add((1, b, 0, 1))
        return result

    def diagonal_subgroup(self) -> Set[MatTuple]:
        """Diagonal invertible matrices (split torus)."""
        p = self.F.p
        result = set()
        for a, d in cart_product(self.F.elements, repeat=2):
            if (a * d) % p != 0:
                result.add((a, 0, 0, d))
        return result

    def scalar_subgroup(self) -> Set[MatTuple]:
        """Scalar matrices aI, a ≠ 0."""
        result = set()
        for a in self.F.elements:
            if a != 0:
                result.add((a, 0, 0, a))
        return result

    def coset_cover_count(self, A_set: Set[MatTuple],
                          H: Set[MatTuple]) -> int:
        """Compute minimum left cosets of H needed to cover A.

        Algorithm: greedy coset covering.
        Time: O(|A| · |H|).

        This is a key ingredient for checking whether a set is
        C-controlled by a subgroup — the transfer principle predicts
        C remains bounded in definable families.
        """
        uncovered = A_set.copy()
        count = 0
        while uncovered:
            rep_t = next(iter(uncovered))
            rep = self.gl2.from_tuple(rep_t)
            coset = set()
            for h_t in H:
                h = self.gl2.from_tuple(h_t)
                prod = self.gl2.mat_mul(rep, h)
                coset.add(self.gl2.to_tuple(prod))
            uncovered -= coset
            count += 1
        return count

    def analyze(self, A: List[Matrix2x2]) -> Dict[str, Dict]:
        """Full subgroup control analysis.

        Tests all standard subgroups and returns covering data.
        """
        A_set = set(self.gl2.to_tuple(m) for m in A)
        candidates = {
            'Borel': self.borel_subgroup(),
            'Unipotent': self.unipotent_subgroup(),
            'Diagonal': self.diagonal_subgroup(),
            'Scalar': self.scalar_subgroup(),
        }

        results = {}
        for name, H in candidates.items():
            cosets = self.coset_cover_count(A_set, H)
            results[name] = {
                'subgroup_size': len(H),
                'cosets_needed': cosets,
                'control_ratio': cosets / len(A) if len(A) > 0 else 0,
            }
        return results


def analyze_definable_family(
    family_func: Callable[[FiniteField], List[Matrix2x2]],
    primes: List[int],
    family_name: str = "Family"
) -> Dict[int, Dict]:
    """Complete analysis pipeline for a definable family.

    Args:
        family_func: Function mapping a finite field to a list of matrices
        primes: List of primes to test
        family_name: Human-readable name

    Returns:
        Dictionary mapping each prime to analysis results including
        set sizes, doubling ratios, and subgroup control data.

    Example:
        >>> def upper_unipotent(F):
        ...     return [[[1, t], [0, 1]] for t in F.elements]
        >>> results = analyze_definable_family(upper_unipotent, [3, 5, 7])
    """
    all_results = {}

    for p in primes:
        F = FiniteField(p)
        gl2 = GL2Computer(F)
        analyzer = SubgroupAnalyzer(gl2)

        A = family_func(F)
        if len(A) == 0:
            all_results[p] = {'empty': True}
            continue

        ratio = gl2.doubling_ratio(A)
        control = analyzer.analyze(A)
        best_name = min(control, key=lambda k: control[k]['cosets_needed'])

        all_results[p] = {
            'empty': False,
            'set_size': len(A),
            'product_set_size': len(gl2.product_set(A)),
            'doubling_ratio': ratio,
            'gl2_size': p * (p - 1) * (p**2 - 1),
            'control': control,
            'best_controller': best_name,
            'best_cosets': control[best_name]['cosets_needed'],
        }

    return all_results


if __name__ == "__main__":
    # Example usage
    def unipotent_family(F):
        return [[[1, t], [0, 1]] for t in F.elements]

    results = analyze_definable_family(unipotent_family, [3, 5, 7, 11, 13],
                                        "Unipotent matrices")
    for p, data in results.items():
        if not data.get('empty', False):
            print(f"p={p}: |A|={data['set_size']}, "
                  f"|A²|={data['product_set_size']}, "
                  f"ratio={data['doubling_ratio']:.3f}, "
                  f"controller={data['best_controller']} "
                  f"({data['best_cosets']} cosets)")

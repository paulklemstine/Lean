"""
Algorithms for Lorentzian Polynomial Recognition.

Implements the recursive spectral certificate algorithm for recognizing
Lorentzian polynomials, including:
- Degree-2 recognition via Hessian eigenvalue analysis
- Degree-3 recursive reduction to quadratic tests
- General fixed-degree recognition
- Certificate tree construction and analysis

Based on the theory of Brändén–Huh (2020) and the complexity analysis
in the accompanying Lean formalization.
"""

import numpy as np
from itertools import combinations_with_replacement
from typing import Dict, Tuple, List, Optional
from dataclasses import dataclass, field
import time


# ──────────────────────────────────────────────────────────────────────
# Core data structures
# ──────────────────────────────────────────────────────────────────────

@dataclass
class HomogeneousPolynomial:
    """A homogeneous polynomial in n variables of degree d.

    Represented as a dictionary mapping multiindices (tuples of ints
    summing to d) to real coefficients.

    Attributes:
        n: Number of variables.
        d: Degree.
        coeffs: Dictionary from multiindex tuples to float coefficients.
    """
    n: int
    d: int
    coeffs: Dict[Tuple[int, ...], float] = field(default_factory=dict)

    def evaluate(self, x: np.ndarray) -> float:
        """Evaluate the polynomial at a point x."""
        result = 0.0
        for mono, coeff in self.coeffs.items():
            term = coeff
            for i, exp in enumerate(mono):
                term *= x[i] ** exp
            result += term
        return result

    def partial_derivative(self, var: int) -> 'HomogeneousPolynomial':
        """Compute the partial derivative with respect to variable `var`.

        Returns a HomogeneousPolynomial of degree d-1.
        """
        if self.d == 0:
            return HomogeneousPolynomial(self.n, 0, {})
        new_coeffs = {}
        for mono, coeff in self.coeffs.items():
            if mono[var] > 0:
                new_mono = list(mono)
                new_coeff = coeff * mono[var]
                new_mono[var] -= 1
                new_mono = tuple(new_mono)
                new_coeffs[new_mono] = new_coeffs.get(new_mono, 0.0) + new_coeff
        return HomogeneousPolynomial(self.n, max(self.d - 1, 0), new_coeffs)

    def iterated_partial_derivative(self, alpha: Tuple[int, ...]) -> 'HomogeneousPolynomial':
        """Compute the iterated partial derivative ∂^α f.

        Args:
            alpha: Multiindex specifying how many times to differentiate
                   with respect to each variable.
        """
        result = self
        for var, count in enumerate(alpha):
            for _ in range(count):
                result = result.partial_derivative(var)
        return result

    def hessian_matrix(self) -> np.ndarray:
        """Compute the Hessian matrix (second partial derivatives evaluated at 0).

        For a degree-2 polynomial ∑ a_{ij} x_i x_j, the Hessian H_{ij} is
        the constant coefficient of ∂²f/∂x_i∂x_j.
        """
        H = np.zeros((self.n, self.n))
        for i in range(self.n):
            df_i = self.partial_derivative(i)
            for j in range(self.n):
                df_ij = df_i.partial_derivative(j)
                # Constant coefficient = coefficient of the zero multiindex
                zero_mono = tuple([0] * self.n)
                H[i, j] = df_ij.coeffs.get(zero_mono, 0.0)
        return H

    def has_nonneg_coefficients(self) -> bool:
        """Check if all coefficients are nonnegative."""
        return all(c >= -1e-12 for c in self.coeffs.values())

    @staticmethod
    def random_homogeneous(n: int, d: int, sparse: float = 1.0,
                           seed: Optional[int] = None) -> 'HomogeneousPolynomial':
        """Generate a random homogeneous polynomial with nonneg coefficients.

        Args:
            n: Number of variables.
            d: Degree.
            sparse: Fraction of monomials to include (0 to 1).
            seed: Random seed.
        """
        rng = np.random.default_rng(seed)
        coeffs = {}
        for mono in multiindices(n, d):
            if rng.random() < sparse:
                coeffs[mono] = rng.exponential(1.0)
        return HomogeneousPolynomial(n, d, coeffs)

    @staticmethod
    def elementary_symmetric(n: int, k: int) -> 'HomogeneousPolynomial':
        """The k-th elementary symmetric polynomial e_k(x_1, ..., x_n).

        This is the basis generating polynomial of the uniform matroid U_{k,n}.
        It is always Lorentzian (Brändén–Huh 2020).
        """
        coeffs = {}
        for subset in combinations_with_replacement(range(n), k):
            # Only include squarefree monomials
            if len(set(subset)) == k:
                mono = [0] * n
                for i in subset:
                    mono[i] += 1
                mono = tuple(mono)
                coeffs[mono] = 1.0
        # Fix: use actual combinations, not combinations_with_replacement
        coeffs = {}
        from itertools import combinations
        for subset in combinations(range(n), k):
            mono = [0] * n
            for i in subset:
                mono[i] = 1
            coeffs[tuple(mono)] = 1.0
        return HomogeneousPolynomial(n, k, coeffs)


# ──────────────────────────────────────────────────────────────────────
# Multiindex utilities
# ──────────────────────────────────────────────────────────────────────

def multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """Generate all multiindices of weight d in n variables.

    Returns list of tuples (α₁, ..., αₙ) with ∑ αᵢ = d.
    """
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in multiindices(n - 1, d - k):
            result.append((k,) + rest)
    return result


def count_multiindices(n: int, d: int) -> int:
    """Count the number of multiindices of weight d in n variables.

    This equals C(n + d - 1, d), the number of weak compositions.
    """
    return len(multiindices(n, d))


# ──────────────────────────────────────────────────────────────────────
# Spectral tests
# ──────────────────────────────────────────────────────────────────────

def has_at_most_one_positive_eigenvalue(A: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if a symmetric matrix has at most one positive eigenvalue.

    This is the spectral signature test for Lorentzianity at degree 2.

    Args:
        A: Symmetric matrix.
        tol: Numerical tolerance for eigenvalue sign.

    Returns:
        True if at most one eigenvalue is positive.
    """
    eigenvalues = np.linalg.eigvalsh(A)
    num_positive = np.sum(eigenvalues > tol)
    return num_positive <= 1


def eigenvalue_signature(A: np.ndarray, tol: float = 1e-10) -> Tuple[int, int, int]:
    """Compute the inertia (n_+, n_-, n_0) of a symmetric matrix.

    Args:
        A: Symmetric matrix.
        tol: Numerical tolerance.

    Returns:
        Tuple (num_positive, num_negative, num_zero).
    """
    eigenvalues = np.linalg.eigvalsh(A)
    n_pos = int(np.sum(eigenvalues > tol))
    n_neg = int(np.sum(eigenvalues < -tol))
    n_zero = len(eigenvalues) - n_pos - n_neg
    return (n_pos, n_neg, n_zero)


# ──────────────────────────────────────────────────────────────────────
# Recognition algorithms
# ──────────────────────────────────────────────────────────────────────

@dataclass
class RecognitionResult:
    """Result of a Lorentzian recognition test.

    Attributes:
        is_lorentzian: Whether the polynomial passes all tests.
        num_leaves_checked: Number of quadratic leaves examined.
        failing_leaf: The multiindex of a failing leaf, if any.
        eigenvalue_signatures: Dictionary from leaf multiindex to inertia.
        elapsed_time: Wall-clock time in seconds.
    """
    is_lorentzian: bool
    num_leaves_checked: int = 0
    failing_leaf: Optional[Tuple[int, ...]] = None
    eigenvalue_signatures: Dict[Tuple[int, ...], Tuple[int, int, int]] = field(
        default_factory=dict)
    elapsed_time: float = 0.0


def recognize_lorentzian_deg2(f: HomogeneousPolynomial) -> RecognitionResult:
    """Recognize a degree-2 Lorentzian polynomial via Hessian signature.

    Algorithm:
    1. Compute the Hessian matrix H.
    2. Check that H has at most one positive eigenvalue.

    Complexity: O(n³) for eigenvalue computation.
    """
    t0 = time.time()
    assert f.d == 2, f"Expected degree 2, got {f.d}"

    H = f.hessian_matrix()
    sig = eigenvalue_signature(H)
    is_lor = sig[0] <= 1

    return RecognitionResult(
        is_lorentzian=is_lor,
        num_leaves_checked=1,
        eigenvalue_signatures={tuple([0] * f.n): sig},
        elapsed_time=time.time() - t0
    )


def recognize_lorentzian(f: HomogeneousPolynomial,
                         verbose: bool = False) -> RecognitionResult:
    """Recognize a Lorentzian polynomial via recursive derivative descent.

    For a degree-d polynomial in n variables:
    1. Check nonneg coefficients.
    2. Enumerate all multiindices α with |α| = d - 2.
    3. For each α, compute ∂^α f (degree-2 polynomial).
    4. Check each quadratic leaf for Lorentzian Hessian signature.

    Complexity: O(n^(d-2) · n³) = O(n^(d+1)) for fixed d.
    """
    t0 = time.time()

    if not f.has_nonneg_coefficients():
        return RecognitionResult(is_lorentzian=False, elapsed_time=time.time() - t0)

    if f.d <= 1:
        return RecognitionResult(is_lorentzian=True, num_leaves_checked=0,
                                 elapsed_time=time.time() - t0)

    if f.d == 2:
        return recognize_lorentzian_deg2(f)

    # General case: check all quadratic leaves
    leaf_order = f.d - 2
    leaves = multiindices(f.n, leaf_order)
    signatures = {}
    num_checked = 0

    for alpha in leaves:
        g = f.iterated_partial_derivative(alpha)
        H = g.hessian_matrix()
        sig = eigenvalue_signature(H)
        signatures[alpha] = sig
        num_checked += 1

        if sig[0] > 1:
            if verbose:
                print(f"  FAIL at leaf α = {alpha}: signature = {sig}")
            return RecognitionResult(
                is_lorentzian=False,
                num_leaves_checked=num_checked,
                failing_leaf=alpha,
                eigenvalue_signatures=signatures,
                elapsed_time=time.time() - t0
            )

        if verbose and num_checked % 100 == 0:
            print(f"  Checked {num_checked}/{len(leaves)} leaves...")

    return RecognitionResult(
        is_lorentzian=True,
        num_leaves_checked=num_checked,
        eigenvalue_signatures=signatures,
        elapsed_time=time.time() - t0
    )


# ──────────────────────────────────────────────────────────────────────
# Tangent-space negativity verification
# ──────────────────────────────────────────────────────────────────────

def verify_tangent_negativity(A: np.ndarray, x: np.ndarray,
                               num_samples: int = 1000,
                               seed: int = 42) -> Tuple[bool, float]:
    """Numerically verify the tangent-space negativity theorem.

    For a symmetric matrix A with Lorentzian signature, checks that
    Q_A(v) ≤ 0 for random vectors v orthogonal to A·x.

    Args:
        A: Symmetric matrix.
        x: Point where Q_A(x) > 0.
        num_samples: Number of random tangent vectors to test.
        seed: Random seed.

    Returns:
        (all_negative, worst_violation): Whether all tests passed,
        and the largest Q_A(v) found (should be ≤ 0).
    """
    rng = np.random.default_rng(seed)
    n = A.shape[0]
    Ax = A @ x

    worst = -np.inf
    for _ in range(num_samples):
        # Generate random vector and project to orthogonal complement of Ax
        v = rng.standard_normal(n)
        v = v - (v @ Ax) / (Ax @ Ax + 1e-15) * Ax
        Qv = v @ A @ v
        worst = max(worst, Qv)

    return worst <= 1e-8, worst


# ──────────────────────────────────────────────────────────────────────
# Reversed Cauchy-Schwarz verification
# ──────────────────────────────────────────────────────────────────────

def verify_reversed_cauchy_schwarz(A: np.ndarray, x: np.ndarray,
                                    y: np.ndarray) -> Tuple[bool, float]:
    """Numerically verify the reversed Cauchy-Schwarz inequality.

    For a symmetric matrix A with Lorentzian signature and Q(x), Q(y) > 0,
    checks that B(x,y)² ≥ Q(x)·Q(y).

    Returns:
        (holds, ratio): Whether the inequality holds, and B(x,y)²/(Q(x)·Q(y)).
    """
    Qx = x @ A @ x
    Qy = y @ A @ y
    Bxy = x @ A @ y

    if Qx <= 0 or Qy <= 0:
        return True, float('inf')  # Hypotheses not satisfied

    ratio = Bxy**2 / (Qx * Qy)
    return ratio >= 1.0 - 1e-10, ratio


# ──────────────────────────────────────────────────────────────────────
# Certificate tree visualization
# ──────────────────────────────────────────────────────────────────────

def certificate_tree_summary(result: RecognitionResult, n: int, d: int) -> str:
    """Generate a text summary of the recognition certificate tree.

    Args:
        result: RecognitionResult from recognize_lorentzian.
        n: Number of variables.
        d: Degree.

    Returns:
        Multi-line string summary.
    """
    lines = [
        f"Lorentzian Recognition Certificate",
        f"  Variables: {n}, Degree: {d}",
        f"  Result: {'LORENTZIAN' if result.is_lorentzian else 'NOT LORENTZIAN'}",
        f"  Quadratic leaves checked: {result.num_leaves_checked}",
        f"  Theoretical max leaves: {count_multiindices(n, max(d-2, 0))}",
        f"  Upper bound n^(d-2): {n**(max(d-2, 0))}",
        f"  Time: {result.elapsed_time:.4f}s",
    ]
    if result.failing_leaf is not None:
        lines.append(f"  Failing leaf: α = {result.failing_leaf}")
        sig = result.eigenvalue_signatures.get(result.failing_leaf)
        if sig:
            lines.append(f"  Failing signature: (+{sig[0]}, -{sig[1]}, 0×{sig[2]})")

    # Signature distribution
    if result.eigenvalue_signatures:
        sigs = list(result.eigenvalue_signatures.values())
        sig_counts: Dict[Tuple[int, int, int], int] = {}
        for s in sigs:
            sig_counts[s] = sig_counts.get(s, 0) + 1
        lines.append(f"  Signature distribution:")
        for sig, count in sorted(sig_counts.items()):
            lines.append(f"    (+{sig[0]}, -{sig[1]}, 0×{sig[2]}): {count} leaves")

    return "\n".join(lines)


if __name__ == "__main__":
    # Quick demo
    print("=== Lorentzian Recognition Algorithms ===\n")

    # Test with elementary symmetric polynomial e_2(x1, ..., x5)
    e2 = HomogeneousPolynomial.elementary_symmetric(5, 2)
    result = recognize_lorentzian(e2, verbose=True)
    print(certificate_tree_summary(result, 5, 2))
    print()

    # Test with a random degree-3 polynomial
    f3 = HomogeneousPolynomial.random_homogeneous(4, 3, seed=42)
    result3 = recognize_lorentzian(f3, verbose=True)
    print(certificate_tree_summary(result3, 4, 3))

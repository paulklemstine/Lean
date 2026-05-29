#!/usr/bin/env python3
"""
Algorithms for Spectral Uncertainty Analysis of Class Functions

Provides:
- ClassFunctionAnalyzer: main analysis class for any finite group
- uncertainty_product: compute σ_cls · σ_spec
- spectral_decomposition: decompose class function into irreducible characters
- entropy_analysis: compute spectral and class entropies
- certify_uncertainty_bound: verify the uncertainty principle

Complexity analysis:
- spectral_decomposition: O(r²) where r = number of conjugacy classes
- uncertainty_product: O(r²) (dominated by spectral decomposition)
- entropy_analysis: O(r²)
"""

import numpy as np
from typing import Tuple, Optional, NamedTuple
from dataclasses import dataclass


@dataclass
class GroupData:
    """Data for a finite group sufficient for class function analysis.

    Attributes:
        name: Human-readable group name
        order: |G|
        class_sizes: Array of conjugacy class sizes |C_j|, length r
        char_table: Character table X[i,j] = χ_i(g_j), shape (r, r)
    """
    name: str
    order: int
    class_sizes: np.ndarray
    char_table: np.ndarray

    @property
    def num_classes(self) -> int:
        """Number of conjugacy classes r."""
        return len(self.class_sizes)

    def validate(self) -> bool:
        """Check consistency of group data.

        Verifies:
        1. Σ|C_j| = |G|
        2. First orthogonality: (1/|G|) Σ_j |C_j| χ_i(g_j) conj(χ_k(g_j)) = δ_{ik}
        """
        r = self.num_classes
        if self.char_table.shape != (r, r):
            return False
        if np.sum(self.class_sizes) != self.order:
            return False
        # Check orthogonality
        for i in range(r):
            for k in range(r):
                inner = np.sum(
                    self.class_sizes * self.char_table[i] *
                    np.conj(self.char_table[k])
                ) / self.order
                expected = 1.0 if i == k else 0.0
                if abs(inner - expected) > 1e-8:
                    return False
        return True


class UncertaintyResult(NamedTuple):
    """Result of uncertainty analysis for a class function."""
    class_sparsity: int
    spectral_sparsity: int
    uncertainty_product: int
    bound: int  # r = number of conjugacy classes
    is_tight: bool  # whether product == r
    spectral_entropy: float
    class_entropy: float
    entropy_sum: float
    entropy_bound: float  # log(r)


class ClassFunctionAnalyzer:
    """Analyzer for class functions on a finite group.

    Time complexity: O(r²) per analysis call.
    Space complexity: O(r²) for the character table.

    Example:
        >>> group = GroupData("S₃", 6, np.array([1,3,2]),
        ...     np.array([[1,1,1],[1,-1,1],[2,0,-1]], dtype=complex))
        >>> analyzer = ClassFunctionAnalyzer(group)
        >>> result = analyzer.analyze(np.array([1, 0, 1], dtype=complex))
        >>> print(f"Uncertainty product: {result.uncertainty_product}")
    """

    def __init__(self, group: GroupData):
        self.group = group
        self.r = group.num_classes

    def spectral_decomposition(self, f: np.ndarray) -> np.ndarray:
        """Decompose f into irreducible character basis.

        Returns array of Fourier coefficients a_i = ⟨f, χ_i⟩.

        Time: O(r²)
        """
        coeffs = np.zeros(self.r, dtype=complex)
        for i in range(self.r):
            coeffs[i] = np.sum(
                self.group.class_sizes * f *
                np.conj(self.group.char_table[i])
            ) / self.group.order
        return coeffs

    def class_sparsity(self, f: np.ndarray, tol: float = 1e-10) -> int:
        """Count nonzero conjugacy classes. Time: O(r)."""
        return int(np.sum(np.abs(f) > tol))

    def spectral_sparsity(self, f: np.ndarray, tol: float = 1e-10) -> int:
        """Count nonzero spectral coefficients. Time: O(r²)."""
        coeffs = self.spectral_decomposition(f)
        return int(np.sum(np.abs(coeffs) > tol))

    def spectral_entropy(self, f: np.ndarray) -> float:
        """Compute spectral entropy S_spec(f). Time: O(r²)."""
        coeffs = self.spectral_decomposition(f)
        p = np.abs(coeffs) ** 2
        total = np.sum(p)
        if total < 1e-15:
            return 0.0
        p = p / total
        p = p[p > 1e-15]
        return float(-np.sum(p * np.log(p)))

    def class_entropy(self, f: np.ndarray) -> float:
        """Compute class entropy S_cls(f). Time: O(r)."""
        q = self.group.class_sizes * np.abs(f) ** 2 / self.group.order
        total = np.sum(q)
        if total < 1e-15:
            return 0.0
        q = q / total
        q = q[q > 1e-15]
        return float(-np.sum(q * np.log(q)))

    def analyze(self, f: np.ndarray, tol: float = 1e-10) -> UncertaintyResult:
        """Full uncertainty analysis of a class function.

        Time: O(r²)
        """
        cs = self.class_sparsity(f, tol)
        ss = self.spectral_sparsity(f, tol)
        up = cs * ss
        s_spec = self.spectral_entropy(f)
        s_cls = self.class_entropy(f)

        return UncertaintyResult(
            class_sparsity=cs,
            spectral_sparsity=ss,
            uncertainty_product=up,
            bound=self.r,
            is_tight=(up == self.r),
            spectral_entropy=s_spec,
            class_entropy=s_cls,
            entropy_sum=s_spec + s_cls,
            entropy_bound=np.log(self.r),
        )

    def certify_uncertainty_bound(self, f: np.ndarray) -> Tuple[bool, str]:
        """Verify the uncertainty principle for a specific class function.

        Returns (is_valid, explanation).
        Time: O(r²)
        """
        if np.allclose(f, 0):
            return True, "Zero function (trivially satisfies bound)"

        result = self.analyze(f)

        if result.uncertainty_product >= result.bound:
            return True, (
                f"σ_cls={result.class_sparsity} × σ_spec={result.spectral_sparsity} "
                f"= {result.uncertainty_product} ≥ {result.bound} = r  ✓"
            )
        else:
            return False, (
                f"VIOLATION: σ_cls={result.class_sparsity} × σ_spec={result.spectral_sparsity} "
                f"= {result.uncertainty_product} < {result.bound} = r  ✗"
            )


def certify_group_uncertainty(group: GroupData, n_random: int = 10000) -> dict:
    """Comprehensive certification of uncertainty principle for a group.

    Tests all irreducible characters and n_random random class functions.

    Returns dict with certification results.
    """
    analyzer = ClassFunctionAnalyzer(group)
    results = {
        "group": group.name,
        "r": group.num_classes,
        "irr_chars": [],
        "all_extremal": True,
        "random_violations": 0,
        "random_trials": n_random,
        "min_uncertainty_product": float('inf'),
        "min_entropy_sum": float('inf'),
    }

    # Test irreducible characters
    for i in range(group.num_classes):
        chi = group.char_table[i]
        result = analyzer.analyze(chi)
        char_info = {
            "index": i,
            "class_sparsity": result.class_sparsity,
            "spectral_sparsity": result.spectral_sparsity,
            "product": result.uncertainty_product,
            "is_tight": result.is_tight,
        }
        results["irr_chars"].append(char_info)
        if not result.is_tight:
            results["all_extremal"] = False
        results["min_uncertainty_product"] = min(
            results["min_uncertainty_product"], result.uncertainty_product)

    # Test random class functions
    rng = np.random.default_rng(42)
    for _ in range(n_random):
        f = rng.standard_normal(group.num_classes) + \
            1j * rng.standard_normal(group.num_classes)
        result = analyzer.analyze(f)
        if result.uncertainty_product < group.num_classes:
            results["random_violations"] += 1
        results["min_uncertainty_product"] = min(
            results["min_uncertainty_product"], result.uncertainty_product)
        results["min_entropy_sum"] = min(
            results["min_entropy_sum"], result.entropy_sum)

    return results


# ─── Example Usage ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    # S₃ example
    S3 = GroupData(
        "S₃", 6,
        np.array([1, 3, 2]),
        np.array([[1,1,1],[1,-1,1],[2,0,-1]], dtype=complex)
    )

    print("Group data validation:", S3.validate())

    analyzer = ClassFunctionAnalyzer(S3)

    # Analyze the standard character
    chi_std = S3.char_table[2]  # [2, 0, -1]
    result = analyzer.analyze(chi_std)
    print(f"\nStandard character of S₃: {chi_std}")
    print(f"  Class sparsity: {result.class_sparsity}")
    print(f"  Spectral sparsity: {result.spectral_sparsity}")
    print(f"  Uncertainty product: {result.uncertainty_product} (bound: {result.bound})")
    print(f"  Tight: {result.is_tight}")

    # Certify the bound
    valid, explanation = analyzer.certify_uncertainty_bound(chi_std)
    print(f"  Certification: {explanation}")

    # Full group certification
    print("\n" + "="*60)
    cert = certify_group_uncertainty(S3)
    print(f"Group {cert['group']} (r={cert['r']}):")
    print(f"  All irreducible characters extremal: {cert['all_extremal']}")
    print(f"  Random violations: {cert['random_violations']}/{cert['random_trials']}")
    print(f"  Min uncertainty product: {cert['min_uncertainty_product']}")

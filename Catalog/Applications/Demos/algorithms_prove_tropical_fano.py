#!/usr/bin/env python3
"""
Tropical Fano Incidence Geometry — Algorithms

Core algorithms for tropical incidence computation, defect analysis,
and configuration rigidity testing.
"""

import numpy as np
from typing import List, Tuple, Optional
from itertools import combinations


class TropicalLine:
    """A tropical line in the min-plus plane ℝ³.

    A tropical line is defined by three coefficients (a, b, c).
    A point (x, y, z) is incident to this line when the minimum
    of {a+x, b+y, c+z} is attained at least twice.
    """

    def __init__(self, coeffs: np.ndarray):
        """Initialize with 3 coefficients.

        Args:
            coeffs: Array of shape (3,) with real coefficients.
        """
        assert len(coeffs) == 3, "Tropical line needs exactly 3 coefficients"
        self.coeffs = np.asarray(coeffs, dtype=float)

    def evaluate(self, point: np.ndarray) -> np.ndarray:
        """Evaluate the tropical functional at a point.

        Args:
            point: Array of shape (3,) with point coordinates.

        Returns:
            Array of shape (3,) with values ℓ_i + p_i.

        Complexity: O(1) — three additions.
        """
        return self.coeffs + point

    def is_incident(self, point: np.ndarray, tol: float = 1e-12) -> bool:
        """Check if a point is tropically incident to this line.

        A point lies on the tropical line when the minimum of the
        evaluation is attained at least twice.

        Args:
            point: Array of shape (3,).
            tol: Numerical tolerance for equality comparison.

        Returns:
            True if the point is incident.

        Complexity: O(1) — constant-time computation on 3 values.
        """
        vals = self.evaluate(point)
        m = vals.min()
        return int(np.sum(np.abs(vals - m) < tol)) >= 2

    def defect(self, point: np.ndarray) -> float:
        """Compute the tropical defect of a point with respect to this line.

        The defect is the gap between the second-smallest and smallest
        evaluation values. Zero defect ↔ incidence.

        Args:
            point: Array of shape (3,).

        Returns:
            Non-negative real number. Zero iff the point is incident.

        Complexity: O(1) — sorting 3 values.
        """
        vals = self.evaluate(point)
        s = np.sort(vals)
        return float(s[1] - s[0])


class TropicalIncidenceConfig:
    """A tropical incidence configuration over finite point and line sets.

    Packages a collection of tropical points and lines with their
    incidence relation determined by tropical evaluation.
    """

    def __init__(self, points: np.ndarray, lines: np.ndarray):
        """Initialize from arrays of points and lines.

        Args:
            points: Array of shape (n_points, 3).
            lines: Array of shape (n_lines, 3).
        """
        self.points = np.asarray(points, dtype=float)
        self.lines = np.asarray(lines, dtype=float)
        self.n_points = self.points.shape[0]
        self.n_lines = self.lines.shape[0]
        self._trop_lines = [TropicalLine(l) for l in self.lines]

    def defect_matrix(self) -> np.ndarray:
        """Compute the full defect matrix D[p, ℓ].

        Returns:
            Array of shape (n_points, n_lines) with defect values.

        Complexity: O(n_points × n_lines) — one defect per pair.
        """
        D = np.zeros((self.n_points, self.n_lines))
        for i in range(self.n_points):
            for j in range(self.n_lines):
                D[i, j] = self._trop_lines[j].defect(self.points[i])
        return D

    def incidence_matrix(self, tol: float = 1e-12) -> np.ndarray:
        """Compute the incidence matrix from defect data.

        Args:
            tol: Tolerance for zero-defect comparison.

        Returns:
            Boolean array of shape (n_points, n_lines).

        Complexity: O(n_points × n_lines).
        """
        D = self.defect_matrix()
        return D < tol

    def security_margin(self) -> float:
        """Compute the certified security margin γ.

        This is the minimum positive defect over all non-incident pairs.
        Returns inf if all pairs are incident (degenerate case).

        Returns:
            Positive real number γ such that all non-incident pairs
            have defect ≥ γ.

        Complexity: O(n_points × n_lines).
        """
        D = self.defect_matrix()
        positive = D[D > 1e-12]
        if len(positive) == 0:
            return float('inf')
        return float(positive.min())

    def verify_rigidity(self, other: 'TropicalIncidenceConfig',
                        tol: float = 1e-12) -> bool:
        """Verify that two configurations with the same defect profile
        have the same incidence relation.

        This is a computational check of the rigidity theorem.

        Args:
            other: Another configuration with same dimensions.
            tol: Tolerance for defect comparison.

        Returns:
            True if defect profiles match and incidences match.

        Complexity: O(n_points × n_lines).
        """
        D1 = self.defect_matrix()
        D2 = other.defect_matrix()
        if not np.allclose(D1, D2, atol=tol):
            return True  # Defects don't match, theorem doesn't apply
        I1 = D1 < tol
        I2 = D2 < tol
        return np.array_equal(I1, I2)


def check_fano_axioms(inc: np.ndarray) -> dict:
    """Check whether an incidence matrix satisfies Fano plane axioms.

    Args:
        inc: Boolean array of shape (7, 7).

    Returns:
        Dictionary with axiom verification results.

    Complexity: O(n²) for pairwise checks on 7 elements.
    """
    results = {}
    n_pts, n_lines = inc.shape
    results['card_points'] = (n_pts == 7)
    results['card_lines'] = (n_lines == 7)

    pts_per_line = inc.sum(axis=0)
    lines_per_pt = inc.sum(axis=1)
    results['three_points_per_line'] = bool(np.all(pts_per_line == 3))
    results['three_lines_per_point'] = bool(np.all(lines_per_pt == 3))

    # Unique line through two points
    unique_line = True
    for i, j in combinations(range(n_pts), 2):
        common = np.sum(inc[i] & inc[j])
        if common != 1:
            unique_line = False
            break
    results['unique_line_through_two_points'] = unique_line

    # Unique point on two lines
    unique_point = True
    for i, j in combinations(range(n_lines), 2):
        common = np.sum(inc[:, i] & inc[:, j])
        if common != 1:
            unique_point = False
            break
    results['unique_point_on_two_lines'] = unique_point

    results['is_fano'] = all(results.values())
    return results


def reconstruct_incidence_from_defect(D: np.ndarray, tol: float = 1e-12) -> np.ndarray:
    """Reconstruct the incidence relation from the defect matrix.

    Algorithm:
        For each entry D[p, ℓ]:
            - If D[p, ℓ] ≈ 0: point p is incident to line ℓ
            - If D[p, ℓ] > 0: point p is not incident to line ℓ

    This implements the reconstruction direction of the rigidity theorem.

    Args:
        D: Defect matrix of shape (n_points, n_lines).
        tol: Tolerance for zero comparison.

    Returns:
        Boolean incidence matrix.

    Complexity: O(n_points × n_lines) — one comparison per entry.
    """
    return D < tol


def tropical_gauge_transform(config: TropicalIncidenceConfig,
                              shift: float) -> TropicalIncidenceConfig:
    """Apply a tropical gauge transformation that preserves defect.

    A shift s applied as ℓ → ℓ + s, p → p - s preserves all
    evaluation differences and hence all defects.

    Args:
        config: Original configuration.
        shift: Scalar shift value.

    Returns:
        New configuration with same defect profile.

    Complexity: O(n_points + n_lines).
    """
    new_lines = config.lines + shift
    new_points = config.points - shift
    return TropicalIncidenceConfig(new_points, new_lines)


if __name__ == "__main__":
    # Example usage
    print("Tropical Incidence Algorithm Demo")
    print("-" * 40)

    # Create a small configuration
    points = np.array([[0, 0, 0], [1, -1, 0], [0, -1, 1]], dtype=float)
    lines = np.array([[0, 1, 3], [1, 0, 2], [2, 3, 0]], dtype=float)

    config = TropicalIncidenceConfig(points, lines)

    print("\nDefect matrix:")
    D = config.defect_matrix()
    print(D)

    print("\nIncidence matrix:")
    I = config.incidence_matrix()
    print(I.astype(int))

    print(f"\nSecurity margin: γ = {config.security_margin():.4f}")

    # Test rigidity via gauge transform
    config2 = tropical_gauge_transform(config, 7.0)
    rigid = config.verify_rigidity(config2)
    print(f"\nRigidity check (gauge transform): {rigid}")

    # Reconstruct from defect
    I_reconstructed = reconstruct_incidence_from_defect(D)
    print(f"\nReconstruction matches: {np.array_equal(I, I_reconstructed)}")

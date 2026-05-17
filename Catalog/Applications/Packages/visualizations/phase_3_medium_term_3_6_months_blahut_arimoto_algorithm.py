"""
Algorithms for Finite Rate-Distortion Theory and Voice-Leading Geometry

Implements:
1. Blahut-Arimoto algorithm for R(D) computation
2. Hungarian algorithm interface for optimal voice-leading
3. Tropical envelope computation
4. Voice-leading rate-distortion pipeline
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple, Optional, Dict


# ============================================================
# Algorithm 1: Blahut-Arimoto for Rate-Distortion
# ============================================================

class BlahutArimoto:
    """
    Blahut-Arimoto algorithm for computing the rate-distortion function.

    The algorithm iteratively optimizes the test channel K(y|x) and
    output distribution q(y) to find the minimum mutual information
    I(X;Y) subject to expected distortion E[d(X,Y)] <= D.

    Time Complexity: O(T * |X| * |Y|) per lambda value,
        where T is the number of iterations.
    Space Complexity: O(|X| * |Y|)

    Convergence: Guaranteed to converge to the global optimum
        since the optimization is convex.

    Parameters
    ----------
    p_x : np.ndarray
        Source distribution, shape (|X|,)
    d : np.ndarray
        Distortion matrix, shape (|X|, |Y|)
    """

    def __init__(self, p_x: np.ndarray, d: np.ndarray):
        self.p_x = p_x
        self.d = d
        self.n_x, self.n_y = d.shape

    def compute_channel(self, lam: float, max_iter: int = 1000,
                         tol: float = 1e-12) -> Tuple[np.ndarray, float, float]:
        """
        Compute the optimal channel for a given Lagrange multiplier.

        Parameters
        ----------
        lam : float
            Lagrange multiplier (>= 0). Larger lambda penalizes distortion more.
        max_iter : int
            Maximum number of iterations.
        tol : float
            Convergence tolerance.

        Returns
        -------
        kernel : np.ndarray
            Optimal test channel K(y|x), shape (|X|, |Y|)
        rate : float
            Achieved mutual information I(X;Y) in bits
        distortion : float
            Achieved expected distortion E[d(X,Y)]
        """
        q_y = np.ones(self.n_y) / self.n_y

        for _ in range(max_iter):
            # E-step: update kernel
            log_kernel = np.log(q_y[None, :] + 1e-300) - lam * self.d
            log_kernel -= log_kernel.max(axis=1, keepdims=True)
            kernel = np.exp(log_kernel)
            kernel /= kernel.sum(axis=1, keepdims=True)

            # M-step: update output distribution
            q_y_new = (self.p_x[:, None] * kernel).sum(axis=0)

            if np.max(np.abs(q_y_new - q_y)) < tol:
                break
            q_y = q_y_new

        p_xy = self.p_x[:, None] * kernel
        rate = self._mutual_info(p_xy)
        distortion = np.sum(self.p_x[:, None] * kernel * self.d)
        return kernel, rate, distortion

    def compute_rd_curve(self, n_points: int = 200) -> Dict:
        """
        Compute the full R(D) curve by sweeping lambda.

        Returns
        -------
        result : dict
            Contains 'D' (distortions), 'R' (rates), 'lambdas',
            and 'channels' (optimal channels at each point).
        """
        lambdas = np.logspace(-3, 4, n_points)
        results = {'D': [], 'R': [], 'lambdas': [], 'channels': []}

        for lam in lambdas:
            kernel, rate, dist = self.compute_channel(lam)
            results['D'].append(dist)
            results['R'].append(rate)
            results['lambdas'].append(lam)
            results['channels'].append(kernel)

        # Sort by distortion
        idx = np.argsort(results['D'])
        results['D'] = np.array(results['D'])[idx]
        results['R'] = np.array(results['R'])[idx]
        results['lambdas'] = np.array(results['lambdas'])[idx]
        results['channels'] = [results['channels'][i] for i in idx]

        return results

    def _mutual_info(self, p_xy: np.ndarray) -> float:
        """Compute mutual information from joint distribution."""
        p_x = p_xy.sum(axis=1)
        p_y = p_xy.sum(axis=0)
        mi = 0.0
        for i in range(p_xy.shape[0]):
            for j in range(p_xy.shape[1]):
                if p_xy[i, j] > 1e-15:
                    mi += p_xy[i, j] * np.log2(
                        p_xy[i, j] / (p_x[i] * p_y[j] + 1e-300))
        return mi


# ============================================================
# Algorithm 2: Voice-Leading Distance (Optimal Assignment)
# ============================================================

class VoiceLeadingSolver:
    """
    Solver for optimal voice-leading between chords.

    For small chord sizes (n <= 8), uses exhaustive permutation search.
    For larger chords, would use the Hungarian algorithm.

    Time Complexity: O(n! * n) for exhaustive search
    Space Complexity: O(n)
    """

    @staticmethod
    def min_distance(chord_a: List[int], chord_b: List[int]) -> Tuple[float, Tuple]:
        """
        Find the minimum L1 voice-leading distance and optimal assignment.

        Parameters
        ----------
        chord_a, chord_b : lists of integer pitches

        Returns
        -------
        min_cost : float
            Minimum total absolute displacement
        best_perm : tuple
            The permutation achieving the minimum
        """
        n = len(chord_a)
        assert len(chord_b) == n
        min_cost = float('inf')
        best_perm = tuple(range(n))

        for perm in permutations(range(n)):
            cost = sum(abs(chord_b[perm[i]] - chord_a[i]) for i in range(n))
            if cost < min_cost:
                min_cost = cost
                best_perm = perm

        return float(min_cost), best_perm

    @staticmethod
    def distance_matrix(chords: List[List[int]]) -> np.ndarray:
        """Compute pairwise voice-leading distance matrix."""
        n = len(chords)
        D = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                D[i, j], _ = VoiceLeadingSolver.min_distance(chords[i], chords[j])
        return D


# ============================================================
# Algorithm 3: Tropical Envelope Computation
# ============================================================

class TropicalEnvelope:
    """
    Compute the tropical (piecewise-linear) envelope of a convex function.

    Given a convex function f sampled at points, find a set of affine
    functions whose supremum approximates f.

    The key insight: a convex function on ℝ is the supremum of its
    supporting hyperplanes, which for 1D functions are tangent lines.
    For finite-dimensional rate-distortion, finitely many suffice.
    """

    @staticmethod
    def compute_envelope(D: np.ndarray, R: np.ndarray,
                          n_supports: int = 10) -> List[Tuple[float, float]]:
        """
        Compute supporting affine functionals for a convex curve.

        Parameters
        ----------
        D : np.ndarray
            x-coordinates (distortion values), sorted
        R : np.ndarray
            y-coordinates (rate values)
        n_supports : int
            Number of supporting lines to compute

        Returns
        -------
        affines : list of (slope, intercept) tuples
        """
        # Remove trivial tail
        valid = R > 1e-6
        if not np.any(valid):
            return [(0.0, 0.0)]
        D_v = D[valid]
        R_v = R[valid]

        # Sample points and compute tangent slopes
        indices = np.linspace(0, len(D_v) - 1, n_supports + 2, dtype=int)[1:-1]
        affines = []

        for idx in indices:
            if 0 < idx < len(D_v) - 1:
                slope = (R_v[idx + 1] - R_v[idx - 1]) / \
                        (D_v[idx + 1] - D_v[idx - 1] + 1e-15)
                intercept = R_v[idx] - slope * D_v[idx]
                affines.append((slope, intercept))

        return affines

    @staticmethod
    def evaluate_envelope(affines: List[Tuple[float, float]],
                           D: np.ndarray) -> np.ndarray:
        """Evaluate the tropical envelope (sup of affine functions)."""
        result = np.full_like(D, -np.inf)
        for m, b in affines:
            result = np.maximum(result, m * D + b)
        return np.maximum(result, 0)


# ============================================================
# Algorithm 4: Voice-Leading Rate-Distortion Pipeline
# ============================================================

class VoiceLeadingRD:
    """
    Complete pipeline: chord repertoire → voice-leading distortion → R(D).

    This implements the "grand bridge theorem" computationally:
    musical structure induces a rate-distortion problem whose
    solution characterizes optimal harmonic compression.
    """

    def __init__(self, repertoire: List[List[int]],
                 prototypes: List[List[int]],
                 source_dist: Optional[np.ndarray] = None):
        self.repertoire = repertoire
        self.prototypes = prototypes
        self.n_rep = len(repertoire)
        self.n_proto = len(prototypes)

        if source_dist is None:
            self.p_x = np.ones(self.n_rep) / self.n_rep
        else:
            self.p_x = source_dist / source_dist.sum()

        # Compute distortion matrix
        self.d = np.zeros((self.n_rep, self.n_proto))
        for i, chord in enumerate(repertoire):
            for j, proto in enumerate(prototypes):
                self.d[i, j], _ = VoiceLeadingSolver.min_distance(chord, proto)

    def compute_rd(self, n_points: int = 200) -> Dict:
        """Compute the voice-leading rate-distortion curve."""
        ba = BlahutArimoto(self.p_x, self.d)
        return ba.compute_rd_curve(n_points)

    def optimal_compression(self, target_rate: float) -> Dict:
        """
        Find the optimal compression scheme for a target rate.

        Returns the channel (assignment probabilities) and
        achieved distortion.
        """
        ba = BlahutArimoto(self.p_x, self.d)

        # Binary search for the right lambda
        lam_low, lam_high = 0.001, 100.0
        for _ in range(50):
            lam_mid = (lam_low + lam_high) / 2
            _, rate, dist = ba.compute_channel(lam_mid)
            if rate > target_rate:
                lam_low = lam_mid
            else:
                lam_high = lam_mid

        kernel, rate, dist = ba.compute_channel((lam_low + lam_high) / 2)
        return {
            'channel': kernel,
            'rate': rate,
            'distortion': dist,
            'lambda': (lam_low + lam_high) / 2
        }


# ============================================================
# Example Usage
# ============================================================

if __name__ == '__main__':
    # Example: Common chord repertoire
    repertoire = [
        [60, 64, 67],  # C major
        [60, 63, 67],  # C minor
        [65, 69, 72],  # F major
        [67, 71, 74],  # G major
        [69, 72, 76],  # A minor
    ]
    prototypes = [
        [60, 64, 67],  # C major
        [67, 71, 74],  # G major
    ]

    vlrd = VoiceLeadingRD(repertoire, prototypes)
    result = vlrd.compute_rd()

    print("Voice-Leading Rate-Distortion Curve:")
    print(f"  D range: [{result['D'].min():.2f}, {result['D'].max():.2f}]")
    print(f"  R range: [{result['R'].min():.4f}, {result['R'].max():.4f}]")

    # Find optimal compression at 0.5 bits
    comp = vlrd.optimal_compression(0.5)
    print(f"\nOptimal compression at ~0.5 bits:")
    print(f"  Achieved rate: {comp['rate']:.4f} bits")
    print(f"  Achieved distortion: {comp['distortion']:.2f} semitones")

#!/usr/bin/env python3
"""
Algorithms for Continued Fraction Dynamics and Spectral Mixing

Implements the core algorithms from the research:
1. CF expansion and matrix encoding
2. Transfer operator approximation
3. Correlation estimation
4. Spectral gap estimation
"""

import numpy as np
from typing import List, Tuple, Callable, Optional


# ============================================================
# Algorithm 1: Continued Fraction Expansion
# ============================================================
class ContinuedFraction:
    """
    Compute and manipulate continued fraction expansions.

    Algorithm:
        Given x ∈ (0,1), repeatedly apply:
            a_n = floor(1/x_n)
            x_{n+1} = 1/x_n - a_n

    Complexity: O(k) for k digits, O(1) per digit.
    """

    def __init__(self, x: float, max_digits: int = 50):
        self.original = x
        self.digits: List[int] = []
        self.remainders: List[float] = [x]

        val = x
        for _ in range(max_digits):
            if val <= 1e-15:
                break
            a = int(1.0 / val)
            self.digits.append(a)
            val = 1.0 / val - a
            self.remainders.append(val)

    def convergent(self, k: int) -> Tuple[int, int]:
        """
        Compute k-th convergent p_k/q_k using matrix product.

        Complexity: O(k) multiplications.
        """
        M = np.eye(2, dtype=np.int64)
        for i in range(min(k, len(self.digits))):
            A = np.array([[0, 1], [1, self.digits[i]]], dtype=np.int64)
            M = M @ A
        return int(M[0, 1]), int(M[1, 1])

    def convergents(self) -> List[Tuple[int, int]]:
        """All convergents."""
        return [self.convergent(k) for k in range(1, len(self.digits) + 1)]

    def __repr__(self) -> str:
        return f"CF({self.original}) = [{', '.join(map(str, self.digits[:10]))}{'...' if len(self.digits) > 10 else ''}]"


# ============================================================
# Algorithm 2: Transfer Operator Approximation
# ============================================================
class GaussTransferOperator:
    """
    Finite-rank approximation of the Gauss transfer operator.

    The operator is:
        Lf(x) = sum_{n>=1} 1/(x+n)^2 * f(1/(x+n))

    We truncate to n <= N_max and discretize on a grid.

    Algorithm:
        1. Choose grid points x_1, ..., x_M in [0,1]
        2. For each grid point, compute Lf(x_i) by summing
        3. Represent L as an M×M matrix

    Complexity: O(M * N_max) per matrix-vector product.
    """

    def __init__(self, grid_size: int = 100, n_max: int = 50):
        self.grid_size = grid_size
        self.n_max = n_max
        self.grid = np.linspace(0.01, 0.99, grid_size)
        self._build_matrix()

    def _build_matrix(self):
        """Build the discrete transfer operator matrix."""
        M = self.grid_size
        self.matrix = np.zeros((M, M))

        for i, x in enumerate(self.grid):
            for n in range(1, self.n_max + 1):
                y = 1.0 / (x + n)  # image point
                weight = 1.0 / (x + n) ** 2

                # Find nearest grid point to y
                j = np.argmin(np.abs(self.grid - y))
                self.matrix[i, j] += weight

        # Normalize columns for proper operator
        col_sums = self.matrix.sum(axis=0)
        col_sums[col_sums == 0] = 1
        self.matrix /= col_sums

    def apply(self, f_values: np.ndarray) -> np.ndarray:
        """Apply the transfer operator to discretized function values."""
        return self.matrix @ f_values

    def eigenvalues(self, k: int = 10) -> np.ndarray:
        """
        Compute the k largest eigenvalues.

        The leading eigenvalue should be 1 (Gauss measure is invariant).
        The spectral gap is 1 - |λ_2|.
        """
        vals = np.linalg.eigvals(self.matrix)
        idx = np.argsort(-np.abs(vals))
        return vals[idx[:k]]

    def spectral_gap(self) -> float:
        """
        Estimate the spectral gap: 1 - |λ_2|.

        This is the key quantity controlling mixing rate.
        The theoretical value for the Gauss map is related to
        the second eigenvalue of the Perron-Frobenius operator.
        """
        evals = self.eigenvalues(5)
        if len(evals) < 2:
            return 0.0
        return 1.0 - abs(evals[1])


# ============================================================
# Algorithm 3: Correlation Estimator
# ============================================================
class CorrelationEstimator:
    """
    Estimate time correlations under the Gauss map.

    Algorithm:
        1. Generate N sample points from Gauss measure
        2. For each lag n, compute:
           Corr(f,g,n) = (1/N) Σ f(x_i) g(T^n(x_i)) - mean(f) mean(g)

    Complexity: O(N * max_lag) for full correlation function.

    Convergence: Monte Carlo error ~ 1/√N.
    """

    def __init__(self, n_samples: int = 50000, burn_in: int = 200):
        self.n_samples = n_samples
        rng = np.random.default_rng(42)
        self.samples = rng.uniform(0.001, 0.999, n_samples)

        # Burn-in to reach Gauss measure equilibrium
        for _ in range(burn_in):
            self.samples = np.array([self._gauss_map(x) for x in self.samples])

    @staticmethod
    def _gauss_map(x: float) -> float:
        if x <= 0:
            return 0.0
        return 1.0 / x - int(1.0 / x)

    def correlations(
        self,
        f: Callable[[float], float],
        g: Callable[[float], float],
        max_lag: int = 30
    ) -> np.ndarray:
        """Compute correlation function for lags 0, 1, ..., max_lag."""
        f_vals = np.array([f(x) for x in self.samples])
        mean_f = np.mean(f_vals)

        g_vals_initial = np.array([g(x) for x in self.samples])
        mean_g = np.mean(g_vals_initial)

        corrs = np.zeros(max_lag + 1)
        current = self.samples.copy()

        for lag in range(max_lag + 1):
            if lag > 0:
                current = np.array([self._gauss_map(x) for x in current])
            g_shifted = np.array([g(x) for x in current])
            corrs[lag] = np.mean(f_vals * g_shifted) - mean_f * mean_g

        return corrs

    def fit_decay(
        self,
        correlations: np.ndarray,
        min_lag: int = 2
    ) -> Tuple[float, float]:
        """
        Fit exponential decay: |Corr(n)| ≈ C * ρ^n.

        Returns (C, ρ) estimated by least-squares on log|Corr|.
        """
        abs_corr = np.abs(correlations)
        valid = [(n, c) for n, c in enumerate(abs_corr) if c > 1e-12 and n >= min_lag]

        if len(valid) < 2:
            return 0.0, 0.0

        ns = np.array([v[0] for v in valid])
        log_c = np.array([np.log(v[1]) for v in valid])

        slope, intercept = np.polyfit(ns, log_c, 1)
        return np.exp(intercept), np.exp(slope)


# ============================================================
# Algorithm 4: Word Matrix Computation
# ============================================================
def word_matrix_fast(digits: List[int]) -> np.ndarray:
    """
    Compute the word matrix for a digit sequence.

    Uses the recurrence M_k = M_{k-1} * A_{a_k} to avoid
    recomputing from scratch.

    Complexity: O(k) matrix multiplications = O(k) arithmetic operations
    (since matrices are 2×2).

    Space: O(1) (only stores current matrix).
    """
    M = np.eye(2, dtype=np.int64)
    for a in digits:
        M = M @ np.array([[0, 1], [1, a]], dtype=np.int64)
    return M


def verify_det_theorem(digits: List[int]) -> bool:
    """
    Verify det(wordMatrix(digits)) = (-1)^len(digits).

    This is our formally proven theorem, verified numerically.
    """
    M = word_matrix_fast(digits)
    det = int(np.round(np.linalg.det(M)))
    expected = (-1) ** len(digits)
    return det == expected


# ============================================================
# Algorithm 5: Cylinder Set Probability
# ============================================================
def cylinder_probability_gauss(digits: List[int]) -> float:
    """
    Compute the Gauss measure of a cylinder set [a_1, ..., a_k].

    The cylinder set is the interval (p_{k-1}/q_{k-1}, p_k/q_k)
    (or reversed, depending on parity).

    The Gauss measure of (a, b) is:
        μ([a,b]) = log_2((1+a)/(1+b)) or log_2((1+b)/(1+a))

    For a cylinder [a_1, ..., a_k], endpoints are consecutive convergents.
    """
    # Compute convergents using matrix product
    M = word_matrix_fast(digits)
    # Previous convergent (drop last digit)
    if len(digits) <= 1:
        # Single digit a: cylinder is (1/(a+1), 1/a)
        a = digits[0]
        left = 1.0 / (a + 1)
        right = 1.0 / a
    else:
        M_prev = word_matrix_fast(digits[:-1])
        p_prev, q_prev = int(M_prev[0, 1]), int(M_prev[1, 1])
        p_curr, q_curr = int(M[0, 1]), int(M[1, 1])

        if q_prev == 0 or q_curr == 0:
            return 0.0

        left = min(p_prev / q_prev, p_curr / q_curr)
        right = max(p_prev / q_prev, p_curr / q_curr)

    # Gauss measure of interval
    return np.log2((1 + right) / (1 + left))


if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # CF expansion
    cf = ContinuedFraction(np.sqrt(2) - 1)
    print(f"1. {cf}")
    convs = cf.convergents()[:5]
    for i, (p, q) in enumerate(convs):
        print(f"   p_{i+1}/q_{i+1} = {p}/{q} = {p/q:.10f}")

    # Transfer operator
    print("\n2. Transfer Operator Spectral Gap")
    L = GaussTransferOperator(grid_size=80, n_max=30)
    gap = L.spectral_gap()
    evals = L.eigenvalues(5)
    print(f"   Top eigenvalues: {[f'{abs(e):.4f}' for e in evals]}")
    print(f"   Spectral gap: {gap:.4f}")
    print(f"   Mixing rate ρ = 1 - gap = {1 - gap:.4f}")

    # Correlation decay
    print("\n3. Correlation Decay Estimation")
    est = CorrelationEstimator(n_samples=30000)
    f_ind = lambda x: 1.0 if x > 0 and int(1/x) == 1 else 0.0
    g_ind = lambda x: 1.0 if x > 0 and int(1/x) == 2 else 0.0
    corrs = est.correlations(f_ind, g_ind, max_lag=15)
    C_est, rho_est = est.fit_decay(corrs)
    print(f"   Estimated C = {C_est:.4f}, ρ = {rho_est:.4f}")

    # Determinant verification
    print("\n4. Determinant Theorem Verification")
    test_words = [[1,2,3], [2,1,4,1,3], [1]*10, [3,7,15,1]]
    for w in test_words:
        ok = verify_det_theorem(w)
        print(f"   det(M_{w}) = (-1)^{len(w)} : {'✓' if ok else '✗'}")

    # Cylinder probabilities
    print("\n5. Cylinder Set Probabilities (Gauss Measure)")
    for digits in [[1], [2], [3], [1,1], [1,2], [2,1]]:
        prob = cylinder_probability_gauss(digits)
        print(f"   μ([{','.join(map(str,digits))}]) = {prob:.6f}")

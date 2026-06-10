#!/usr/bin/env python3
"""
Algorithms for Tropical Pseudorandom Dynamics

Implements the core algorithms from the research paper:
1. Tropical orbit computation
2. Birkhoff contraction coefficient estimation
3. Symbolic trace extraction
4. Spectral gap estimation via cycle means
5. Tropical PRG construction
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from itertools import product


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Tropical Matrix-Vector Multiplication
# ═══════════════════════════════════════════════════════════════

def tropical_mat_vec_mul(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Max-plus matrix-vector product.

    Computes (A ⊗ x)(i) = max_j (A[i,j] + x[j])

    Time complexity: O(n²) where n = dim(x)
    Space complexity: O(n)

    Args:
        A: n×n tropical matrix
        x: n-dimensional tropical vector

    Returns:
        n-dimensional result vector
    """
    return np.array([np.max(A[i, :] + x) for i in range(A.shape[0])])


def tropical_mat_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Max-plus matrix-matrix product.

    (A ⊗ B)[i,k] = max_j (A[i,j] + B[j,k])

    Time complexity: O(n³)
    """
    n = A.shape[0]
    C = np.full((n, n), -np.inf)
    for i in range(n):
        for k in range(n):
            C[i, k] = np.max(A[i, :] + B[:, k])
    return C


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Tropical Orbit and Projective Distance
# ═══════════════════════════════════════════════════════════════

def compute_orbit(A: np.ndarray, x0: np.ndarray, T: int) -> np.ndarray:
    """
    Compute the tropical orbit x_0, x_1, ..., x_T.

    x_{t+1} = A ⊗ x_t

    Time complexity: O(T · n²)
    Space complexity: O(T · n)
    """
    n = A.shape[0]
    orbit = np.zeros((T + 1, n))
    orbit[0] = x0
    for t in range(T):
        orbit[t + 1] = tropical_mat_vec_mul(A, orbit[t])
    return orbit


def hilbert_projective_distance(x: np.ndarray, y: np.ndarray) -> float:
    """
    Hilbert projective distance: d(x,y) = max(x-y) - min(x-y).

    This is the key metric for tropical dynamics. It is:
    - Nonnegative
    - Zero iff x - y is constant (projective equivalence)
    - Invariant under adding constants to x or y

    Time complexity: O(n)
    """
    diff = x - y
    return float(np.max(diff) - np.min(diff))


def projective_normalize(x: np.ndarray) -> np.ndarray:
    """Normalize to projective coordinates (subtract max)."""
    return x - np.max(x)


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Birkhoff Contraction Coefficient
# ═══════════════════════════════════════════════════════════════

def estimate_birkhoff_contraction(A: np.ndarray, num_samples: int = 1000,
                                   seed: int = 42) -> float:
    """
    Estimate the Birkhoff contraction coefficient κ of a tropical matrix.

    κ = sup_{x,y} d(Ax, Ay) / d(x, y)

    where the sup is over all projectively distinct x, y.

    For a matrix with spectral gap, κ < 1.

    Time complexity: O(num_samples · n²)
    """
    rng = np.random.RandomState(seed)
    n = A.shape[0]
    max_ratio = 0.0

    for _ in range(num_samples):
        x = rng.randn(n)
        y = rng.randn(n)

        d_in = hilbert_projective_distance(x, y)
        if d_in < 1e-12:
            continue

        Ax = tropical_mat_vec_mul(A, x)
        Ay = tropical_mat_vec_mul(A, y)
        d_out = hilbert_projective_distance(Ax, Ay)

        ratio = d_out / d_in
        max_ratio = max(max_ratio, ratio)

    return max_ratio


def birkhoff_contraction_exact_2x2(A: np.ndarray) -> float:
    """
    Exact Birkhoff contraction coefficient for 2×2 matrices.

    For a 2×2 matrix A = [[a, b], [c, d]], the contraction coefficient is:

    κ = tanh(δ/4) where δ = (a-b-c+d) is the spectral gap parameter.

    (This uses the classical Birkhoff-Hopf formula.)

    Time complexity: O(1)
    """
    assert A.shape == (2, 2)
    a, b, c, d = A[0, 0], A[0, 1], A[1, 0], A[1, 1]

    # The Hilbert metric contraction for positive matrices
    delta = (a + d) - (b + c)
    if abs(delta) < 1e-15:
        return 1.0  # No gap

    # Birkhoff formula: κ = tanh(Δ(A)/4) where Δ is the diameter
    # For tropical matrices, this becomes a ratio
    alpha = min(a - b, d - c) if a - b > 0 and d - c > 0 else 0
    beta = max(a - b, d - c)

    if beta <= 0:
        return 1.0

    kappa = (beta - alpha) / (beta + alpha) if beta + alpha > 0 else 1.0
    return min(kappa, 1.0)


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Spectral Gap Estimation via Cycle Means
# ═══════════════════════════════════════════════════════════════

def all_cycle_means(A: np.ndarray) -> List[float]:
    """
    Compute all cycle means of a tropical matrix.

    A cycle of length k through nodes i_1, ..., i_k has mean:
    (A[i_1,i_2] + A[i_2,i_3] + ... + A[i_k,i_1]) / k

    The maximum cycle mean is the tropical spectral radius.

    Time complexity: O(n! / (n-k)!) summed over k = exponential.
    For small n only.
    """
    n = A.shape[0]
    means = []

    for k in range(1, n + 1):
        # All k-tuples of distinct indices
        from itertools import permutations
        for perm in permutations(range(n), k):
            weight = sum(A[perm[i], perm[(i + 1) % k]] for i in range(k))
            means.append(weight / k)

    return sorted(means, reverse=True)


def tropical_spectral_radius(A: np.ndarray) -> float:
    """
    Compute the tropical spectral radius = maximum cycle mean.

    Uses Karp's algorithm for O(n³) complexity.
    """
    n = A.shape[0]
    # Karp's algorithm
    D = np.full((n + 1, n), -np.inf)
    D[0, :] = 0

    for k in range(1, n + 1):
        for j in range(n):
            D[k, j] = max(D[k - 1, i] + A[i, j] for i in range(n))

    # Maximum cycle mean
    result = -np.inf
    for j in range(n):
        min_val = np.inf
        for k in range(n):
            if D[n, j] > -np.inf and D[k, j] > -np.inf:
                min_val = min(min_val, (D[n, j] - D[k, j]) / (n - k))
        result = max(result, min_val)

    return result


def estimate_spectral_gap(A: np.ndarray) -> Tuple[float, float, float]:
    """
    Estimate the tropical spectral gap.

    Returns:
        (lambda_1, lambda_2, gap) where gap = lambda_1 - lambda_2
    """
    means = all_cycle_means(A)
    if len(means) < 2:
        return means[0], means[0], 0.0

    lambda_1 = means[0]
    # Find second distinct value
    lambda_2 = lambda_1
    for m in means[1:]:
        if abs(m - lambda_1) > 1e-10:
            lambda_2 = m
            break

    return lambda_1, lambda_2, lambda_1 - lambda_2


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Symbolic Trace Extraction
# ═══════════════════════════════════════════════════════════════

def extract_symbolic_trace(
    A: np.ndarray,
    x0: np.ndarray,
    T: int,
    obs: Callable[[np.ndarray], int] = None
) -> List[int]:
    """
    Extract symbolic trace from tropical orbit.

    Args:
        A: tropical transition matrix
        x0: initial state
        T: number of time steps
        obs: observable function (default: argmax)

    Returns:
        List of symbols y_0, y_1, ..., y_T
    """
    if obs is None:
        obs = lambda x: int(np.argmax(x))

    orbit = compute_orbit(A, x0, T)
    return [obs(orbit[t]) for t in range(T + 1)]


def symbolic_disagreement_rate(
    A: np.ndarray,
    x0: np.ndarray,
    x0p: np.ndarray,
    T: int,
    obs: Callable[[np.ndarray], int] = None
) -> np.ndarray:
    """
    Compute the symbolic disagreement indicator for each time step.

    Returns array of 0s and 1s: 1 if symbols differ, 0 if equal.
    """
    trace1 = extract_symbolic_trace(A, x0, T, obs)
    trace2 = extract_symbolic_trace(A, x0p, T, obs)
    return np.array([0 if s1 == s2 else 1 for s1, s2 in zip(trace1, trace2)])


def window_disagreement(
    A: np.ndarray,
    x0: np.ndarray,
    x0p: np.ndarray,
    T: int,
    k: int,
    obs: Callable[[np.ndarray], int] = None
) -> np.ndarray:
    """
    Compute window disagreement for k-windows starting at each time t.
    """
    trace1 = extract_symbolic_trace(A, x0, T + k, obs)
    trace2 = extract_symbolic_trace(A, x0p, T + k, obs)
    result = np.zeros(T + 1)
    for t in range(T + 1):
        window1 = tuple(trace1[t:t + k])
        window2 = tuple(trace2[t:t + k])
        result[t] = 0 if window1 == window2 else 1
    return result


# ═══════════════════════════════════════════════════════════════
# Algorithm 6: Tropical PRG Construction
# ═══════════════════════════════════════════════════════════════

class TropicalPRG:
    """
    Pseudorandom generator based on tropical spectral dynamics.

    Given a tropical matrix A with spectral gap and an observable obs,
    the PRG maps a seed x₀ to the symbolic trace (obs(x_t))_{t≥T₀}
    where T₀ is the mixing time.

    Security parameter: the contraction rate ρ determines how quickly
    the output becomes seed-independent.
    """

    def __init__(self, A: np.ndarray, obs: Callable = None,
                 mixing_time: Optional[int] = None):
        """
        Initialize the tropical PRG.

        Args:
            A: n×n tropical matrix with spectral gap
            obs: observable function (default: argmax)
            mixing_time: override automatic mixing time estimation
        """
        self.A = A
        self.n = A.shape[0]
        self.obs = obs or (lambda x: int(np.argmax(x)))

        # Estimate spectral gap and contraction
        self.kappa = estimate_birkhoff_contraction(A)
        self.lambda1, self.lambda2, self.gap = estimate_spectral_gap(A)

        # Estimate mixing time
        if mixing_time is not None:
            self.mixing_time = mixing_time
        else:
            if self.kappa < 1:
                # Time to reduce distance by factor 10^{-6}
                self.mixing_time = int(np.ceil(-6 * np.log(10) / np.log(self.kappa)))
            else:
                self.mixing_time = 100  # fallback

    def generate(self, seed: np.ndarray, length: int) -> List[int]:
        """
        Generate pseudorandom symbols.

        Args:
            seed: initial tropical state
            length: number of output symbols

        Returns:
            List of pseudorandom symbols
        """
        T = self.mixing_time + length
        trace = extract_symbolic_trace(self.A, seed, T, self.obs)
        return trace[self.mixing_time:]

    def info(self) -> dict:
        """Return PRG parameters."""
        return {
            'dimension': self.n,
            'spectral_radius': self.lambda1,
            'second_eigenvalue': self.lambda2,
            'spectral_gap': self.gap,
            'contraction_coeff': self.kappa,
            'mixing_time': self.mixing_time,
            'alphabet_size': self.n,
        }


# ═══════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Tropical Pseudorandom Dynamics - Algorithm Suite")
    print("=" * 55)

    # Example matrix
    A = np.array([
        [5.0, 1.0, 0.5],
        [0.5, 5.0, 1.0],
        [1.0, 0.5, 5.0]
    ])

    # Spectral analysis
    print("\n--- Spectral Analysis ---")
    l1, l2, gap = estimate_spectral_gap(A)
    print(f"Dominant eigenvalue λ₁ = {l1:.4f}")
    print(f"Second eigenvalue  λ₂ = {l2:.4f}")
    print(f"Spectral gap       Δ  = {gap:.4f}")

    kappa = estimate_birkhoff_contraction(A)
    print(f"Birkhoff coefficient κ = {kappa:.6f}")

    # PRG
    print("\n--- Tropical PRG ---")
    prg = TropicalPRG(A)
    info = prg.info()
    print(f"PRG parameters: {info}")

    seed1 = np.array([1.0, 0.0, 0.0])
    seed2 = np.array([0.0, 0.0, 1.0])

    out1 = prg.generate(seed1, 20)
    out2 = prg.generate(seed2, 20)
    print(f"\nOutput (seed 1): {out1}")
    print(f"Output (seed 2): {out2}")
    print(f"Outputs match:   {out1 == out2}")

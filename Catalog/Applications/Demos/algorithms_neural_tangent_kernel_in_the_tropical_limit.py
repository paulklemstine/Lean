"""
Tropical Neural Tangent Kernel — Algorithms

Implements the core algorithms from the tropical NTK theory:
1. Polyhedral cell decomposition of input space
2. Tropical NTK computation
3. Soft-min convergence to tropical network
4. Wall-crossing detection
"""

import numpy as np
from typing import List, Tuple, Dict, Optional


def affine_score(W: np.ndarray, b: np.ndarray, i: int, x: np.ndarray) -> float:
    """
    Compute affine score z_i(x) = W_i · x + b_i.

    Args:
        W: Weight matrix of shape (m, d)
        b: Bias vector of shape (m,)
        i: Hidden unit index
        x: Input vector of shape (d,)

    Returns:
        Scalar affine score

    Time complexity: O(d)
    Space complexity: O(1)
    """
    return float(np.dot(W[i], x) + b[i])


def tropical_network(W: np.ndarray, b: np.ndarray, S: List[int],
                     x: np.ndarray) -> float:
    """
    Compute tropical network output: f(x) = min_{i in S} z_i(x).

    This is the min-plus neural network with one hidden layer.

    Args:
        W: Weight matrix (m, d)
        b: Bias vector (m,)
        S: Nonempty subset of hidden unit indices
        x: Input vector (d,)

    Returns:
        Minimum affine score over S

    Time complexity: O(|S| * d)
    Space complexity: O(|S|)
    """
    scores = [affine_score(W, b, i, x) for i in S]
    return min(scores)


def find_argmin(W: np.ndarray, b: np.ndarray, S: List[int],
                x: np.ndarray) -> int:
    """
    Find the active hidden unit: argmin_{i in S} z_i(x).

    Args:
        W: Weight matrix (m, d)
        b: Bias vector (m,)
        S: Nonempty subset of hidden unit indices
        x: Input vector (d,)

    Returns:
        Index of the minimizing unit

    Time complexity: O(|S| * d)
    Space complexity: O(|S|)
    """
    scores = [(affine_score(W, b, i, x), i) for i in S]
    return min(scores, key=lambda t: t[0])[1]


def tropical_param_gradient(W: np.ndarray, b: np.ndarray, S: List[int],
                            x: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the tropical parameter gradient at input x.

    On a strict argmin cell for unit i0:
    - dW[i0] = x, dW[j] = 0 for j ≠ i0
    - db[i0] = 1, db[j] = 0 for j ≠ i0

    Args:
        W: Weight matrix (m, d)
        b: Bias vector (m,)
        S: Nonempty subset of hidden unit indices
        x: Input vector (d,)

    Returns:
        Tuple (dW, db) of gradient arrays

    Time complexity: O(|S| * d + m * d) = O(m * d)
    Space complexity: O(m * d)
    """
    m, d = W.shape
    i0 = find_argmin(W, b, S, x)
    dW = np.zeros((m, d))
    db = np.zeros(m)
    dW[i0] = x
    db[i0] = 1.0
    return dW, db


def tropical_ntk(W: np.ndarray, b: np.ndarray, S: List[int],
                 x: np.ndarray, y: np.ndarray) -> float:
    """
    Compute the tropical NTK: K(x, y) = ⟨∇_θ f(x), ∇_θ f(y)⟩.

    On a common strict argmin cell, this equals ⟨x, y⟩ + 1.

    Args:
        W: Weight matrix (m, d)
        b: Bias vector (m,)
        S: Nonempty subset of hidden unit indices
        x, y: Input vectors (d,)

    Returns:
        Tropical NTK value

    Time complexity: O(m * d)
    Space complexity: O(m * d)
    """
    dWx, dbx = tropical_param_gradient(W, b, S, x)
    dWy, dby = tropical_param_gradient(W, b, S, y)
    return float(np.sum(dWx * dWy) + np.sum(dbx * dby))


def tropical_ntk_matrix(W: np.ndarray, b: np.ndarray, S: List[int],
                        X: np.ndarray) -> np.ndarray:
    """
    Compute the full tropical NTK Gram matrix for a dataset.

    Args:
        W: Weight matrix (m, d)
        b: Bias vector (m,)
        S: Nonempty subset of hidden unit indices
        X: Data matrix (n, d)

    Returns:
        NTK Gram matrix of shape (n, n)

    Time complexity: O(n^2 * m * d)
    Space complexity: O(n^2 + n * m * d)
    """
    n = X.shape[0]
    K = np.zeros((n, n))
    grads = [tropical_param_gradient(W, b, S, X[i]) for i in range(n)]
    for i in range(n):
        for j in range(i, n):
            val = np.sum(grads[i][0] * grads[j][0]) + np.sum(grads[i][1] * grads[j][1])
            K[i, j] = val
            K[j, i] = val
    return K


def compute_cell_decomposition(W: np.ndarray, b: np.ndarray, S: List[int],
                               grid_points: np.ndarray) -> np.ndarray:
    """
    Compute the polyhedral cell decomposition on a grid.

    Each grid point is labeled by which hidden unit achieves the minimum.

    Args:
        W: Weight matrix (m, d)
        b: Bias vector (m,)
        S: Nonempty subset of hidden unit indices
        grid_points: Array of shape (n, d)

    Returns:
        Array of cell labels of shape (n,)

    Time complexity: O(n * |S| * d)
    """
    n = grid_points.shape[0]
    labels = np.zeros(n, dtype=int)
    for i in range(n):
        labels[i] = find_argmin(W, b, S, grid_points[i])
    return labels


def find_tropical_walls_2d(W: np.ndarray, b: np.ndarray, S: List[int],
                           bounds: Tuple[float, float, float, float],
                           resolution: int = 200) -> List[Tuple[np.ndarray, int, int]]:
    """
    Find tropical wall points in 2D (boundaries between cells).

    Args:
        W: Weight matrix (m, 2)
        b: Bias vector (m,)
        S: Nonempty subset of hidden unit indices
        bounds: (xmin, xmax, ymin, ymax)
        resolution: Grid resolution

    Returns:
        List of (point, cell1, cell2) triples at wall crossings

    Time complexity: O(resolution^2 * |S|)
    """
    xmin, xmax, ymin, ymax = bounds
    xs = np.linspace(xmin, xmax, resolution)
    ys = np.linspace(ymin, ymax, resolution)
    walls = []

    for i in range(resolution - 1):
        for j in range(resolution - 1):
            p1 = np.array([xs[i], ys[j]])
            p2 = np.array([xs[i+1], ys[j]])
            p3 = np.array([xs[i], ys[j+1]])
            c1 = find_argmin(W, b, S, p1)
            c2 = find_argmin(W, b, S, p2)
            c3 = find_argmin(W, b, S, p3)
            if c1 != c2:
                walls.append((0.5 * (p1 + p2), c1, c2))
            if c1 != c3:
                walls.append((0.5 * (p1 + p3), c1, c3))

    return walls


def soft_min_network(W: np.ndarray, b: np.ndarray, S: List[int],
                     x: np.ndarray, tau: float) -> float:
    """
    Soft-min approximation: f_τ(x) = -τ log Σ_i exp(-z_i(x)/τ).

    Converges to tropical_network as τ → 0⁺.

    Args:
        W: Weight matrix (m, d)
        b: Bias vector (m,)
        S: Nonempty subset of hidden unit indices
        x: Input vector (d,)
        tau: Temperature parameter (> 0)

    Returns:
        Soft-min value

    Time complexity: O(|S| * d)
    """
    scores = np.array([affine_score(W, b, i, x) for i in S])
    # Use logsumexp trick for numerical stability
    min_score = np.min(scores)
    shifted = -(scores - min_score) / tau
    return -tau * np.log(np.sum(np.exp(shifted))) + min_score


def find_flat_directions(W: np.ndarray, i0: int) -> np.ndarray:
    """
    Find flat directions for cell i0: orthogonal complement of W[i0].

    A flat direction v satisfies W[i0] · v = 0, meaning the tropical
    network output is constant along x + tv within the cell.

    Args:
        W: Weight matrix (m, d)
        i0: Active hidden unit index

    Returns:
        Matrix of shape (d-1, d) whose rows span ker(W[i0])

    Time complexity: O(d^2)
    """
    w = W[i0].reshape(1, -1)
    _, _, vh = np.linalg.svd(w)
    return vh[1:]  # All but the first singular vector


def detect_wall_crossing(W: np.ndarray, b: np.ndarray, S: List[int],
                         x: np.ndarray, v: np.ndarray,
                         t_max: float = 10.0,
                         n_steps: int = 1000) -> Optional[float]:
    """
    Detect the first wall crossing along direction v from x.

    Returns the smallest t > 0 where the active unit changes.

    Args:
        W: Weight matrix (m, d)
        b: Bias vector (m,)
        S: Nonempty subset of hidden unit indices
        x: Starting point (d,)
        v: Direction vector (d,)
        t_max: Maximum t to search
        n_steps: Number of steps for line search

    Returns:
        First wall-crossing time, or None if no crossing found

    Time complexity: O(n_steps * |S| * d)
    """
    i0 = find_argmin(W, b, S, x)
    ts = np.linspace(0, t_max, n_steps)
    for t in ts[1:]:
        xt = x + t * v
        if find_argmin(W, b, S, xt) != i0:
            # Binary search for precise crossing
            lo, hi = t - (ts[1] - ts[0]), t
            for _ in range(50):
                mid = (lo + hi) / 2
                if find_argmin(W, b, S, x + mid * v) != i0:
                    hi = mid
                else:
                    lo = mid
            return (lo + hi) / 2
    return None


if __name__ == "__main__":
    # Example usage
    np.random.seed(42)
    d, m = 3, 5
    W = np.random.randn(m, d)
    b = np.random.randn(m)
    S = list(range(m))

    x = np.array([1.0, -0.5, 0.3])
    y = np.array([0.8, 0.2, -0.1])

    print("Tropical Network Algorithms — Example")
    print("=" * 50)
    print(f"f(x) = {tropical_network(W, b, S, x):.6f}")
    print(f"Active unit: {find_argmin(W, b, S, x)}")
    print(f"K(x,y) = {tropical_ntk(W, b, S, x, y):.6f}")

    # Soft-min convergence
    print("\nSoft-min convergence:")
    for tau in [1.0, 0.1, 0.01, 0.001]:
        val = soft_min_network(W, b, S, x, tau)
        print(f"  τ = {tau:.3f}: f_τ(x) = {val:.6f}")
    print(f"  τ → 0:   f(x)   = {tropical_network(W, b, S, x):.6f}")

    # Wall crossing
    v = np.random.randn(d)
    t_wall = detect_wall_crossing(W, b, S, x, v)
    if t_wall is not None:
        print(f"\nFirst wall crossing at t = {t_wall:.4f}")
        print(f"  Before: active = {find_argmin(W, b, S, x + (t_wall - 0.01) * v)}")
        print(f"  After:  active = {find_argmin(W, b, S, x + (t_wall + 0.01) * v)}")

    # Flat directions
    i0 = find_argmin(W, b, S, x)
    flat_dirs = find_flat_directions(W, i0)
    print(f"\nFlat directions for cell {i0}:")
    for i, fd in enumerate(flat_dirs):
        print(f"  v_{i} = {fd}, W[{i0}]·v = {np.dot(W[i0], fd):.2e}")

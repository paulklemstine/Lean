"""
Ihara Zeta Function: Core Algorithms

Type-hinted implementations of the key algorithms for computing Ihara zeta functions,
closed walk counts, and Ramanujan graph properties.
"""

from typing import List, Tuple
import numpy as np
from numpy.typing import NDArray


def adjacency_matrix(edges: List[Tuple[int, int]], n: int) -> NDArray[np.float64]:
    """Construct the adjacency matrix for an undirected simple graph.

    Args:
        edges: List of (i, j) pairs representing undirected edges
        n: Number of vertices

    Returns:
        n×n symmetric adjacency matrix
    """
    A = np.zeros((n, n), dtype=np.float64)
    for i, j in edges:
        A[i, j] = 1.0
        A[j, i] = 1.0
    return A


def closed_walk_count(A: NDArray[np.float64], k: int) -> float:
    """Compute the total number of closed walks of length k.

    Uses the trace formula: total closed walks of length k = tr(A^k).

    Args:
        A: Adjacency matrix
        k: Walk length

    Returns:
        tr(A^k), the total closed walk count
    """
    return float(np.trace(np.linalg.matrix_power(A, k)))


def ihara_matrix(A: NDArray[np.float64], D: NDArray[np.float64], u: float) -> NDArray[np.float64]:
    """Compute the Ihara matrix I - u*A + u²*(D - I).

    Args:
        A: Adjacency matrix
        D: Degree matrix (diagonal)
        u: Complex variable parameter

    Returns:
        The Ihara matrix
    """
    n = A.shape[0]
    I = np.eye(n)
    return I - u * A + u**2 * (D - I)


def ihara_determinant(A: NDArray[np.float64], D: NDArray[np.float64], u: float) -> float:
    """Compute det(I - u*A + u²*(D - I)), the Ihara determinant.

    The zeros of this determinant (as a function of u) are related to the
    poles of the Ihara zeta function via the Ihara-Bass formula.

    Args:
        A: Adjacency matrix
        D: Degree matrix
        u: Parameter value

    Returns:
        The Ihara determinant value
    """
    return float(np.linalg.det(ihara_matrix(A, D, u)))


def ihara_determinant_regular(A: NDArray[np.float64], q: int, u: float) -> float:
    """Compute det((1+qu²)I - uA) for a (q+1)-regular graph.

    Args:
        A: Adjacency matrix of a (q+1)-regular graph
        q: Regularity parameter (degree = q+1)
        u: Parameter value

    Returns:
        The Ihara determinant for regular graphs
    """
    n = A.shape[0]
    I = np.eye(n)
    M = (1 + q * u**2) * I - u * A
    return float(np.linalg.det(M))


def is_ramanujan(A: NDArray[np.float64], q: int) -> Tuple[bool, List[float]]:
    """Check if a (q+1)-regular graph satisfies the Ramanujan bound.

    A (q+1)-regular graph is Ramanujan if all non-trivial eigenvalues λ
    satisfy |λ| ≤ 2√q. The trivial eigenvalues are ±(q+1).

    Args:
        A: Adjacency matrix of a (q+1)-regular graph
        q: Regularity parameter

    Returns:
        (is_ramanujan, eigenvalues) tuple
    """
    eigenvalues = sorted(np.linalg.eigvalsh(A), reverse=True)
    bound = 2 * np.sqrt(q)
    trivial = q + 1

    non_trivial = [ev for ev in eigenvalues if abs(abs(ev) - trivial) > 1e-10]
    is_ram = all(abs(ev) <= bound + 1e-10 for ev in non_trivial)

    return is_ram, eigenvalues


def spectral_gap(A: NDArray[np.float64]) -> float:
    """Compute the spectral gap of a symmetric matrix.

    The spectral gap is max|λ| - max{|λ| : |λ| < max|λ|}.

    Args:
        A: Symmetric matrix

    Returns:
        The spectral gap
    """
    eigenvalues = np.abs(np.linalg.eigvalsh(A))
    eigenvalues.sort()
    if len(eigenvalues) < 2:
        return 0.0
    return float(eigenvalues[-1] - eigenvalues[-2])


def ihara_zeta_inverse_polynomial(A: NDArray[np.float64], q: int,
                                   num_points: int = 100) -> Tuple[NDArray, NDArray]:
    """Sample the Ihara zeta function inverse on a grid.

    For a (q+1)-regular graph, ζ_G(u)⁻¹ = (1-u²)^{m-n} · det((1+qu²)I - uA).

    Args:
        A: Adjacency matrix
        q: Regularity parameter
        num_points: Number of sample points

    Returns:
        (u_values, zeta_inverse_values) arrays
    """
    n = A.shape[0]
    m = int(np.sum(A) / 2)  # number of edges
    beta = m - n  # first Betti number

    u_vals = np.linspace(-0.99, 0.99, num_points)
    zeta_inv = np.array([
        (1 - u**2)**beta * ihara_determinant_regular(A, q, u)
        for u in u_vals
    ])

    return u_vals, zeta_inv


def walk_count_spectrum(A: NDArray[np.float64], max_k: int = 20) -> List[float]:
    """Compute closed walk counts for k = 0, 1, ..., max_k.

    Args:
        A: Adjacency matrix
        max_k: Maximum walk length

    Returns:
        List of tr(A^k) values
    """
    eigenvalues = np.linalg.eigvalsh(A)
    return [float(sum(ev**k for ev in eigenvalues)) for k in range(max_k + 1)]


def ramanujan_walk_bound(n: int, q: int, k: int) -> float:
    """Compute the Ramanujan walk count bound n * (q+1)^k.

    For a Ramanujan graph, |tr(A^k)| ≤ n * (q+1)^k.

    Args:
        n: Number of vertices
        q: Regularity parameter
        k: Walk length

    Returns:
        The bound value
    """
    return n * (q + 1)**k


def complete_graph_adjacency(n: int) -> NDArray[np.float64]:
    """Adjacency matrix of the complete graph K_n.

    Args:
        n: Number of vertices

    Returns:
        n×n adjacency matrix with 1s off-diagonal, 0s on diagonal
    """
    return np.ones((n, n)) - np.eye(n)


def petersen_graph_adjacency() -> NDArray[np.float64]:
    """Adjacency matrix of the Petersen graph (10 vertices, 3-regular).

    The Petersen graph is the canonical example of a 3-regular graph
    that is NOT Ramanujan (its non-trivial eigenvalues include ±√5 ≈ ±2.236,
    while the Ramanujan bound is 2√2 ≈ 2.828, so it IS Ramanujan).

    Returns:
        10×10 adjacency matrix
    """
    edges = [
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 0),  # outer pentagon
        (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),  # inner pentagram
        (0, 5), (1, 6), (2, 7), (3, 8), (4, 9),  # spokes
    ]
    return adjacency_matrix(edges, 10)

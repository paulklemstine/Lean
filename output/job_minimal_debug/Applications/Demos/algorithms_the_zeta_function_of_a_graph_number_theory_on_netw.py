"""
Algorithms for Ihara Zeta Function Computation on Graphs.

Implements the core algorithms for computing the Ihara zeta function,
checking the Ramanujan property, and analyzing spectral properties
of finite regular graphs.
"""

from typing import List, Tuple, Optional
import numpy as np
from numpy.linalg import det, eigvalsh


def adjacency_matrix(edges: List[Tuple[int, int]], n: int) -> np.ndarray:
    """Construct the adjacency matrix of a simple graph.

    Args:
        edges: List of (i, j) edges (0-indexed).
        n: Number of vertices.

    Returns:
        n x n symmetric adjacency matrix.
    """
    A = np.zeros((n, n))
    for i, j in edges:
        A[i, j] = 1.0
        A[j, i] = 1.0
    return A


def complete_graph_adj(n: int) -> np.ndarray:
    """Adjacency matrix of the complete graph K_n."""
    return np.ones((n, n)) - np.eye(n)


def petersen_graph_adj() -> np.ndarray:
    """Adjacency matrix of the Petersen graph (10 vertices, 3-regular)."""
    edges = [
        (0,1),(1,2),(2,3),(3,4),(4,0),  # outer pentagon
        (5,7),(7,9),(9,6),(6,8),(8,5),  # inner pentagram
        (0,5),(1,6),(2,7),(3,8),(4,9),  # spokes
    ]
    return adjacency_matrix(edges, 10)


def cycle_graph_adj(n: int) -> np.ndarray:
    """Adjacency matrix of the cycle graph C_n."""
    edges = [(i, (i + 1) % n) for i in range(n)]
    return adjacency_matrix(edges, n)


def paley_graph_adj(p: int) -> np.ndarray:
    """Adjacency matrix of the Paley graph of order p (p ≡ 1 mod 4 prime).

    Vertices are elements of F_p. Two vertices are adjacent iff their
    difference is a quadratic residue mod p.

    The Paley graph is ((p-1)/2)-regular and is known to be Ramanujan.
    """
    qr = set()
    for x in range(1, p):
        qr.add((x * x) % p)
    A = np.zeros((p, p))
    for i in range(p):
        for j in range(p):
            if i != j and ((j - i) % p) in qr:
                A[i, j] = 1.0
    return A


def ihara_determinant(A: np.ndarray, q: int, u: float) -> float:
    """Compute det(I - uA + (q-1)u²I) for a (q+1)-regular graph.

    This is the reciprocal of the Ihara zeta function (up to a factor).

    Args:
        A: Adjacency matrix.
        q: Reduced degree (valency = q+1).
        u: Complex variable (real part).

    Returns:
        The determinant value.
    """
    n = A.shape[0]
    I = np.eye(n)
    H = (1 + (q - 1) * u**2) * I - u * A
    return det(H)


def ihara_zeta_poles(A: np.ndarray, q: int) -> np.ndarray:
    """Compute the poles of the Ihara zeta function.

    For a (q+1)-regular graph, the poles come from eigenvalues of A:
    for each eigenvalue λ, the poles are u = (λ ± √(λ² - 4(q-1))) / (2(q-1)).

    Here we return the reciprocal roots of 1 - λu + (q-1)u² = 0.

    Args:
        A: Adjacency matrix.
        q: Reduced degree.

    Returns:
        Array of pole locations (complex).
    """
    eigenvalues = eigvalsh(A)
    poles = []
    for lam in eigenvalues:
        disc = lam**2 - 4 * (q - 1)
        if disc >= 0:
            u1 = (lam + np.sqrt(disc)) / (2 * (q - 1)) if q > 1 else None
            u2 = (lam - np.sqrt(disc)) / (2 * (q - 1)) if q > 1 else None
        else:
            u1 = (lam + 1j * np.sqrt(-disc)) / (2 * (q - 1)) if q > 1 else None
            u2 = (lam - 1j * np.sqrt(-disc)) / (2 * (q - 1)) if q > 1 else None
        if u1 is not None:
            poles.extend([u1, u2])
    return np.array(poles)


def check_ramanujan(A: np.ndarray, q: int) -> Tuple[bool, float, List[float]]:
    """Check if a (q+1)-regular graph is Ramanujan.

    Args:
        A: Adjacency matrix.
        q: Reduced degree.

    Returns:
        (is_ramanujan, max_nontrivial_eigenvalue, all_eigenvalues)
    """
    eigenvalues = sorted(eigvalsh(A))
    bound = 2 * np.sqrt(q)
    trivial = q + 1

    nontrivial = [ev for ev in eigenvalues if abs(abs(ev) - trivial) > 1e-10]
    max_nt = max(abs(ev) for ev in nontrivial) if nontrivial else 0.0

    is_ram = max_nt <= bound + 1e-10
    return is_ram, max_nt, eigenvalues


def closed_walk_count(A: np.ndarray, k: int) -> float:
    """Count closed walks of length k: Tr(A^k)."""
    return np.trace(np.linalg.matrix_power(A, k))


def prime_cycle_count(A: np.ndarray, max_length: int) -> List[float]:
    """Estimate the number of prime cycles of each length using Möbius inversion.

    N_k = Tr(A^k) counts all closed walks of length k.
    Prime cycles P_k satisfy: N_k = Σ_{d|k} d · P_d
    So P_k = (1/k) Σ_{d|k} μ(k/d) · N_d  (Möbius inversion).

    Returns:
        List where index k gives the approximate count of prime cycles of length k.
    """
    N = [0.0] * (max_length + 1)
    for k in range(1, max_length + 1):
        N[k] = closed_walk_count(A, k)

    def mobius(n: int) -> int:
        if n == 1:
            return 1
        factors = []
        d = 2
        temp = n
        while d * d <= temp:
            if temp % d == 0:
                factors.append(d)
                while temp % d == 0:
                    temp //= d
            d += 1
        if temp > 1:
            factors.append(temp)
        # Check for squared factors
        temp2 = n
        for p in factors:
            count = 0
            while temp2 % p == 0:
                temp2 //= p
                count += 1
            if count > 1:
                return 0
        return (-1) ** len(factors)

    P = [0.0] * (max_length + 1)
    for k in range(1, max_length + 1):
        total = 0.0
        for d in range(1, k + 1):
            if k % d == 0:
                total += mobius(k // d) * N[d]
        P[k] = total / k

    return P


def spectral_gap(A: np.ndarray, q: int) -> float:
    """Compute the spectral gap: (q+1) - max non-trivial |eigenvalue|."""
    _, max_nt, _ = check_ramanujan(A, q)
    return (q + 1) - max_nt


def graph_rh_test(A: np.ndarray, q: int) -> Tuple[bool, str]:
    """Test the Graph Riemann Hypothesis for a regular graph.

    The GRH holds iff the graph is Ramanujan: all non-trivial eigenvalues
    satisfy |λ| ≤ 2√q.

    Returns:
        (passes, description)
    """
    is_ram, max_nt, evs = check_ramanujan(A, q)
    bound = 2 * np.sqrt(q)
    desc = (
        f"Eigenvalue bound: 2√{q} = {bound:.4f}\n"
        f"Max non-trivial |eigenvalue|: {max_nt:.4f}\n"
        f"Graph RH: {'SATISFIED' if is_ram else 'VIOLATED'}\n"
        f"All eigenvalues: {[f'{ev:.4f}' for ev in sorted(evs)]}"
    )
    return is_ram, desc

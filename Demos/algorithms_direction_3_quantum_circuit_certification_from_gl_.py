"""
Algorithms for Quantum Circuit Certification from GL₂ Spectral Gaps

Implements the spectral-gap-to-design-depth pipeline as computable functions.

Algorithms:
1. GL₂(𝔽_q) group generation and arithmetic
2. Cayley walk operator construction
3. Spectral gap computation
4. Design depth computation
5. Quantum channel construction and application
6. Convergence verification
"""

import numpy as np
from itertools import product
from typing import Tuple, List, Optional


class GL2Fq:
    """The general linear group GL₂(𝔽_q) for prime q.

    Provides group operations, element enumeration, and index mapping.

    Example:
        >>> G = GL2Fq(5)
        >>> len(G)
        480
        >>> g = G.element(0, 1, 4, 1)  # [[0,1],[4,1]]
        >>> G.det(g)
        1
    """

    def __init__(self, q: int):
        """Initialize GL₂(𝔽_q).

        Args:
            q: A prime number defining the base field.
        """
        self.q = q
        self._elements: List[np.ndarray] = []
        self._idx_map: dict = {}
        self._generate()

    def _generate(self):
        """Generate all elements and build index map."""
        q = self.q
        for a, b, c, d in product(range(q), repeat=4):
            det = (a * d - b * c) % q
            if det != 0:
                mat = np.array([[a, b], [c, d]], dtype=int)
                key = (a, b, c, d)
                self._idx_map[key] = len(self._elements)
                self._elements.append(mat)

    def __len__(self) -> int:
        return len(self._elements)

    @property
    def order(self) -> int:
        """Theoretical order: q(q+1)(q-1)²."""
        q = self.q
        return q * (q + 1) * (q - 1) ** 2

    def element(self, a: int, b: int, c: int, d: int) -> np.ndarray:
        """Create a group element from entries."""
        return np.array([[a % self.q, b % self.q],
                         [c % self.q, d % self.q]], dtype=int)

    def det(self, A: np.ndarray) -> int:
        """Compute determinant modulo q."""
        return int((A[0, 0] * A[1, 1] - A[0, 1] * A[1, 0]) % self.q)

    def mul(self, A: np.ndarray, B: np.ndarray) -> np.ndarray:
        """Multiply two group elements."""
        return (A @ B) % self.q

    def inv(self, A: np.ndarray) -> np.ndarray:
        """Compute the group inverse."""
        q = self.q
        det = self.det(A)
        det_inv = pow(det, q - 2, q)
        return (det_inv * np.array([[A[1, 1], -A[0, 1]],
                                     [-A[1, 0], A[0, 0]]])) % q

    def to_idx(self, A: np.ndarray) -> int:
        """Convert element to index."""
        key = tuple(int(A[i, j] % self.q) for i in range(2) for j in range(2))
        return self._idx_map[key]

    def from_idx(self, i: int) -> np.ndarray:
        """Get element by index."""
        return self._elements[i]

    def has_irreducible_charpoly(self, A: np.ndarray) -> bool:
        """Check if characteristic polynomial is irreducible over 𝔽_q.

        The charpoly x² - tr(A)x + det(A) is irreducible iff
        its discriminant tr² - 4·det is a quadratic non-residue mod q.
        """
        q = self.q
        tr_val = int((A[0, 0] + A[1, 1]) % q)
        det_val = self.det(A)
        disc = (tr_val * tr_val - 4 * det_val) % q
        if disc == 0:
            return False
        return pow(disc, (q - 1) // 2, q) == q - 1


def build_walk_operator(G: GL2Fq, g: np.ndarray, h: np.ndarray) -> np.ndarray:
    """Build the normalized Cayley walk operator.

    T(f)(x) = (1/4)(f(gx) + f(g⁻¹x) + f(hx) + f(h⁻¹x))

    Args:
        G: The GL₂(𝔽_q) group
        g, h: Generator matrices

    Returns:
        N×N walk operator matrix where N = |GL₂(𝔽_q)|

    Complexity: O(N) for construction, O(N²) storage
    """
    N = len(G)
    generators = [g, G.inv(g), h, G.inv(h)]
    T = np.zeros((N, N))

    for i in range(N):
        x = G.from_idx(i)
        for s in generators:
            sx = G.mul(s, x)
            j = G.to_idx(sx)
            T[j, i] += 0.25

    return T


def compute_spectral_gap(T: np.ndarray) -> Tuple[float, np.ndarray]:
    """Compute the spectral gap of a walk operator.

    The spectral gap is Δ = 1 - λ₂ where λ₂ is the second-largest
    eigenvalue.

    Args:
        T: Walk operator matrix (doubly stochastic)

    Returns:
        (gap, eigenvalues): Spectral gap and sorted eigenvalue array

    Complexity: O(N²) for eigenvalue computation
    """
    eigenvalues = np.sort(np.real(np.linalg.eigvals(T)))[::-1]
    gap = 1.0 - eigenvalues[1]
    return gap, eigenvalues


def design_depth(gap: float, epsilon: float) -> int:
    """Compute the certified design depth.

    t* = ⌈log(1/ε) / log(1/(1-Δ))⌉

    Args:
        gap: Spectral gap Δ ∈ (0, 1)
        epsilon: Target accuracy ε > 0

    Returns:
        Design depth (number of channel applications)

    Example:
        >>> design_depth(0.3, 0.01)
        13
    """
    if gap <= 0 or gap >= 1 or epsilon <= 0:
        raise ValueError("Need 0 < gap < 1 and epsilon > 0")
    return int(np.ceil(np.log(1 / epsilon) / np.log(1 / (1 - gap))))


def build_permutation_unitaries(G: GL2Fq, g: np.ndarray,
                                 h: np.ndarray) -> List[np.ndarray]:
    """Build permutation unitaries for the quantum channel.

    For each generator s, U_s is the permutation matrix where
    (U_s)_{j,i} = 1 iff j = s·i in the group.

    Args:
        G: The group
        g, h: Generators

    Returns:
        List of 4 unitary matrices [U_g, U_{g⁻¹}, U_h, U_{h⁻¹}]
    """
    N = len(G)
    generators = [g, G.inv(g), h, G.inv(h)]
    unitaries = []

    for s in generators:
        U = np.zeros((N, N), dtype=complex)
        for i in range(N):
            x = G.from_idx(i)
            sx = G.mul(s, x)
            j = G.to_idx(sx)
            U[j, i] = 1.0
        unitaries.append(U)

    return unitaries


def apply_quantum_channel(unitaries: List[np.ndarray],
                           X: np.ndarray) -> np.ndarray:
    """Apply the walk quantum channel.

    Φ(X) = (1/4) Σ_{s∈S} U_s X U_s†

    Args:
        unitaries: List of unitary matrices
        X: Input operator (matrix)

    Returns:
        Φ(X): Output operator

    Complexity: O(n³) per unitary application
    """
    result = np.zeros_like(X)
    for U in unitaries:
        result += U @ X @ U.conj().T
    return result / len(unitaries)


def verify_channel_properties(unitaries: List[np.ndarray],
                               N: int) -> dict:
    """Verify unitality and trace preservation.

    Returns:
        Dictionary with verification results
    """
    I = np.eye(N, dtype=complex)
    phi_I = apply_quantum_channel(unitaries, I)

    # Random test matrix
    np.random.seed(0)
    X = np.random.randn(N, N) + 1j * np.random.randn(N, N)
    phi_X = apply_quantum_channel(unitaries, X)

    return {
        'unital_error': float(np.linalg.norm(phi_I - I, 'fro')),
        'trace_error': float(abs(np.trace(phi_X) - np.trace(X))),
        'is_unital': np.linalg.norm(phi_I - I, 'fro') < 1e-10,
        'is_trace_preserving': abs(np.trace(phi_X) - np.trace(X)) < 1e-10,
    }


def convergence_data(unitaries: List[np.ndarray], gap: float,
                      max_iter: int = 20) -> dict:
    """Compute convergence data for the quantum channel.

    Args:
        unitaries: Channel unitaries
        gap: Spectral gap
        max_iter: Maximum iterations

    Returns:
        Dictionary with iteration data
    """
    N = unitaries[0].shape[0]
    np.random.seed(42)
    X = np.random.randn(N, N) + 1j * np.random.randn(N, N)
    X -= (np.trace(X) / N) * np.eye(N, dtype=complex)  # Make traceless
    X_norm0 = np.linalg.norm(X, 'fro')

    data = {'iterations': [], 'norms': [], 'bounds': [], 'ratios': []}
    X_current = X.copy()

    for t in range(1, max_iter + 1):
        X_current = apply_quantum_channel(unitaries, X_current)
        norm_t = np.linalg.norm(X_current, 'fro')
        bound_t = (1 - gap) ** t * X_norm0
        ratio = norm_t / bound_t if bound_t > 1e-15 else float('inf')

        data['iterations'].append(t)
        data['norms'].append(float(norm_t))
        data['bounds'].append(float(bound_t))
        data['ratios'].append(float(ratio))

    return data


# Example usage
if __name__ == "__main__":
    print("GL₂(𝔽₅) Quantum Channel Certification Pipeline")
    print("=" * 50)

    # Initialize group
    G = GL2Fq(5)
    print(f"|GL₂(𝔽₅)| = {len(G)} (expected {G.order})")

    # Choose generators
    g = G.element(0, 1, 4, 1)
    h = G.element(1, 1, 0, 1)
    print(f"g irreducible charpoly: {G.has_irreducible_charpoly(g)}")

    # Compute spectral gap
    T = build_walk_operator(G, g, h)
    gap, eigs = compute_spectral_gap(T)
    print(f"Spectral gap: Δ = {gap:.6f}")

    # Design depths
    for eps in [0.1, 0.01, 0.001]:
        print(f"Design depth for ε={eps}: t* = {design_depth(gap, eps)}")

    # Build quantum channel
    unitaries = build_permutation_unitaries(G, g, h)
    props = verify_channel_properties(unitaries, len(G))
    print(f"Unital: {props['is_unital']}, Trace-preserving: {props['is_trace_preserving']}")

    # Convergence
    conv = convergence_data(unitaries, gap)
    print(f"After 10 iterations: norm ratio = {conv['ratios'][9]:.4f}")

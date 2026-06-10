"""
Algorithms for Quantum Channel Mixing via Cayley Moment Bounds

Implements the core computational methods from the research:
1. Walk distribution computation via convolution
2. Purity and return probability computation
3. Spectral gap estimation
4. Quantum channel construction and iteration
5. Moment kernel computation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import Dict, List, Tuple, Optional
from itertools import permutations
from collections import defaultdict


# ============================================================
# Group Operations
# ============================================================

Perm = Tuple[int, ...]


def compose(p: Perm, q: Perm) -> Perm:
    """Compose permutations: (p∘q)(i) = p(q(i)).

    Time: O(n) where n = len(p).
    """
    return tuple(p[q[i]] for i in range(len(p)))


def inverse(p: Perm) -> Perm:
    """Inverse permutation.

    Time: O(n).
    """
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)


def identity(n: int) -> Perm:
    """Identity permutation on n elements."""
    return tuple(range(n))


def symmetric_group_elements(n: int) -> List[Perm]:
    """Generate all elements of S_n.

    Time: O(n! · n).
    Space: O(n! · n).
    """
    return [tuple(p) for p in permutations(range(n))]


# ============================================================
# Algorithm 1: Walk Distribution via Convolution
# ============================================================

def compute_walk_distribution(
    G: List[Perm],
    generators: List[Perm],
    k: int,
    initial: Optional[Dict[Perm, float]] = None
) -> Dict[Perm, float]:
    """
    Compute the walk distribution after k steps.

    The walk uses uniform measure on generators:
        μ(g) = 1/|generators| for g in generators, 0 otherwise.

    Args:
        G: Group elements (for validation).
        generators: Symmetric generating set {σ, σ⁻¹, τ, τ⁻¹}.
        k: Number of walk steps.
        initial: Initial distribution (default: point mass at identity).

    Returns:
        Distribution as dict mapping group elements to probabilities.

    Time complexity: O(k · |G| · |generators|).
    Space complexity: O(|G|).

    Example:
        >>> G = symmetric_group_elements(3)
        >>> sigma, tau = (1,0,2), (1,2,0)
        >>> gens = [sigma, inverse(sigma), tau, inverse(tau)]
        >>> dist = compute_walk_distribution(G, gens, 5)
        >>> abs(sum(dist.values()) - 1.0) < 1e-10
        True
    """
    n = len(G[0])
    weight = 1.0 / len(generators)

    if initial is None:
        dist = defaultdict(float)
        dist[identity(n)] = 1.0
    else:
        dist = defaultdict(float, initial)

    for _ in range(k):
        new_dist = defaultdict(float)
        for x, px in dist.items():
            if px == 0:
                continue
            for g in generators:
                gx = compose(g, x)
                new_dist[gx] += weight * px
        dist = new_dist

    return dict(dist)


# ============================================================
# Algorithm 2: Purity Computation
# ============================================================

def compute_purity(dist: Dict[Perm, float]) -> float:
    """
    Compute the purity (L² mass) of a distribution.

    purity(p) = Σ_x p(x)²

    This equals the Hilbert-Schmidt purity tr(ρ²) of the
    corresponding diagonal density matrix.

    Args:
        dist: Distribution as dict g -> probability.

    Returns:
        Purity value in [1/|G|, 1].

    Time: O(|support|).

    Example:
        >>> compute_purity({(0,1,2): 1.0})  # point mass
        1.0
        >>> abs(compute_purity({(0,1,2): 0.5, (1,0,2): 0.5}) - 0.5) < 1e-10
        True
    """
    return sum(p ** 2 for p in dist.values())


def compute_centered_purity(dist: Dict[Perm, float], group_size: int) -> float:
    """
    Compute centered purity: L² distance from uniform distribution.

    centered_purity(p) = Σ_x (p(x) - 1/|G|)²

    Args:
        dist: Distribution.
        group_size: |G|.

    Returns:
        Centered purity ≥ 0.

    Time: O(|G|).
    """
    uniform = 1.0 / group_size
    result = 0.0
    visited = set()
    for g, p in dist.items():
        result += (p - uniform) ** 2
        visited.add(g)
    # Elements not in dist have probability 0
    result += (group_size - len(visited)) * uniform ** 2
    return result


# ============================================================
# Algorithm 3: Return Probability (Moment Kernel)
# ============================================================

def compute_return_probability(
    G: List[Perm],
    generators: List[Perm],
    k: int
) -> float:
    """
    Compute the return probability after k steps.

    returnProb(k) = μ^{*k}(e) = Pr[walk returns to start after k steps]

    This equals the moment kernel: closedWordCount(k) / |generators|^k.

    Args:
        G: Group elements.
        generators: Symmetric generating set.
        k: Number of steps.

    Returns:
        Return probability in [0, 1].

    Time: O(k · |G| · |generators|).
    """
    dist = compute_walk_distribution(G, generators, k)
    e = identity(len(G[0]))
    return dist.get(e, 0.0)


# ============================================================
# Algorithm 4: Spectral Gap Estimation
# ============================================================

def compute_spectral_gap(
    G: List[Perm],
    generators: List[Perm]
) -> Tuple[float, np.ndarray]:
    """
    Compute the spectral gap of the normalized adjacency matrix.

    gap = 1 - max(|λ₂|, |λₙ|)

    where λ₁ ≥ λ₂ ≥ ... ≥ λₙ are eigenvalues of the normalized
    adjacency (Markov) matrix.

    Args:
        G: Group elements.
        generators: Symmetric generating set.

    Returns:
        (gap, eigenvalues) where eigenvalues are sorted descending.

    Time: O(|G|³) for eigendecomposition.
    Space: O(|G|²).

    Example:
        >>> G = symmetric_group_elements(3)
        >>> sigma, tau = (1,0,2), (1,2,0)
        >>> gens = [sigma, inverse(sigma), tau, inverse(tau)]
        >>> gap, eigs = compute_spectral_gap(G, gens)
        >>> 0 < gap < 1
        True
    """
    n = len(G)
    g_to_idx = {g: i for i, g in enumerate(G)}
    weight = 1.0 / len(generators)

    A = np.zeros((n, n))
    for i, g in enumerate(G):
        for s in generators:
            sg = compose(s, g)
            j = g_to_idx[sg]
            A[j, i] += weight

    eigenvalues = np.sort(np.linalg.eigvalsh(A))[::-1]
    second_max = max(abs(eigenvalues[1]), abs(eigenvalues[-1]))
    gap = 1.0 - second_max

    return gap, eigenvalues


# ============================================================
# Algorithm 5: Quantum Channel Superoperator
# ============================================================

def build_quantum_channel(
    G: List[Perm],
    generators: List[Perm]
) -> np.ndarray:
    """
    Build the quantum channel superoperator matrix.

    Φ_μ(ρ) = Σ_g μ(g) U_g ρ U_g†

    Represented as a |G|² × |G|² matrix acting on vec(ρ).

    Args:
        G: Group elements.
        generators: Symmetric generating set.

    Returns:
        Superoperator matrix Φ of shape (|G|², |G|²).

    Time: O(|generators| · |G|³).
    Space: O(|G|⁴).
    """
    n = len(G)
    g_to_idx = {g: i for i, g in enumerate(G)}
    weight = 1.0 / len(generators)

    Phi = np.zeros((n * n, n * n))

    for s in generators:
        # Build permutation matrix for s
        P = np.zeros((n, n))
        for k_idx, k in enumerate(G):
            sk = compose(s, k)
            h_idx = g_to_idx[sk]
            P[h_idx, k_idx] = 1.0

        # Φ += μ(s) · (P ⊗ P̄)
        # Since P is real, P̄ = P
        Phi += weight * np.kron(P, P)

    return Phi


def iterate_channel(
    Phi: np.ndarray,
    rho: np.ndarray,
    k: int
) -> np.ndarray:
    """
    Apply the quantum channel k times to a density matrix.

    Args:
        Phi: Superoperator matrix.
        rho: Initial density matrix.
        k: Number of iterations.

    Returns:
        Φ^k(ρ) as a density matrix.

    Time: O(k · |G|⁴).
    """
    n = int(np.sqrt(rho.size))
    rho_vec = rho.flatten()
    for _ in range(k):
        rho_vec = Phi @ rho_vec
    return rho_vec.reshape(n, n)


# ============================================================
# Algorithm 6: Verify Purity-Return Probability Identity
# ============================================================

def verify_purity_identity(
    G: List[Perm],
    generators: List[Perm],
    max_k: int = 10,
    tol: float = 1e-10
) -> bool:
    """
    Verify that walkPurity(k) = returnProbability(2k) for all k ≤ max_k.

    This is the main theorem: the quantum channel purity equals the
    classical return probability at double the step count.

    Args:
        G: Group elements.
        generators: Symmetric generating set.
        max_k: Maximum k to check.
        tol: Numerical tolerance.

    Returns:
        True if identity holds for all k ≤ max_k.

    Example:
        >>> G = symmetric_group_elements(3)
        >>> sigma, tau = (1,0,2), (1,2,0)
        >>> gens = [sigma, inverse(sigma), tau, inverse(tau)]
        >>> verify_purity_identity(G, gens, max_k=5)
        True
    """
    for k in range(max_k + 1):
        dist_k = compute_walk_distribution(G, generators, k)
        purity_k = compute_purity(dist_k)
        return_prob_2k = compute_return_probability(G, generators, 2 * k)

        if abs(purity_k - return_prob_2k) > tol:
            print(f"FAILED at k={k}: purity={purity_k}, return_prob={return_prob_2k}")
            return False

    return True


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithms for Quantum Channel Mixing")
    print("=" * 60)

    for n in [3, 4]:
        print(f"\n--- S_{n} ---")
        G = symmetric_group_elements(n)
        sigma = list(range(n))
        sigma[0], sigma[1] = sigma[1], sigma[0]
        sigma = tuple(sigma)
        tau = tuple((i + 1) % n for i in range(n))
        gens = [sigma, inverse(sigma), tau, inverse(tau)]

        # Verify purity identity
        verified = verify_purity_identity(G, gens, max_k=6)
        print(f"Purity-Return Probability Identity: {'VERIFIED ✓' if verified else 'FAILED ✗'}")

        # Compute spectral gap
        gap, eigs = compute_spectral_gap(G, gens)
        print(f"Spectral gap: {gap:.6f}")

        # Purity decay
        for k in [0, 1, 2, 5]:
            dist = compute_walk_distribution(G, gens, k)
            pur = compute_purity(dist)
            centered = compute_centered_purity(dist, len(G))
            decay_bound = (1 - gap) ** (2 * k) * (1.0 - 1.0 / len(G))
            print(f"  k={k}: purity={pur:.6f}, centered={centered:.6f}, "
                  f"bound={decay_bound:.6f}, "
                  f"{'≤ bound ✓' if centered <= decay_bound + 1e-10 else '> bound ✗'}")

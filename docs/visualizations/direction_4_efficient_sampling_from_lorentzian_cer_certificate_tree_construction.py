#!/usr/bin/env python3
"""
Algorithms for Certificate-Guided Sampling from Lorentzian Polynomials

Implements:
1. Certificate tree construction for Lorentzian quadratic forms
2. Certificate-guided Markov chain (Metropolis-Hastings)
3. Spectral gap estimation via power iteration
4. Tropical Newton subdivision and diameter computation
5. Ultra-log-concave rejection sampling

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass, field
import math


# =============================================================================
# Data Structures
# =============================================================================

@dataclass
class CertificateNode:
    """A node in the Lorentzian certificate tree.

    Each node stores a symmetric matrix (the Hessian of a partial derivative)
    and its Lorentzian signature verification result.

    Attributes:
        matrix: The symmetric matrix at this node
        eigenvalues: Computed eigenvalues (for verification)
        is_lorentzian: Whether the matrix has at most one positive eigenvalue
        children: Child nodes (partial derivatives)
        depth: Depth in the certificate tree
        derivative_index: Which variable was differentiated to reach this node
    """
    matrix: np.ndarray
    eigenvalues: np.ndarray = field(default_factory=lambda: np.array([]))
    is_lorentzian: bool = False
    children: List['CertificateNode'] = field(default_factory=list)
    depth: int = 0
    derivative_index: int = -1


@dataclass
class CertificateTree:
    """Complete certificate tree for a recursively Lorentzian polynomial.

    Attributes:
        root: Root node
        n_variables: Number of variables
        degree: Total degree of the polynomial
        n_leaves: Number of leaf nodes (quadratic checks)
        is_valid: Whether all leaves pass the Lorentzian signature test
    """
    root: CertificateNode
    n_variables: int
    degree: int
    n_leaves: int = 0
    is_valid: bool = False


@dataclass
class TropicalCell:
    """A cell in the tropical Newton subdivision.

    Attributes:
        vertices: Vertices of the tropical polytope cell
        dominant_monomial: Index of the dominating monomial
        dimension: Dimension of the cell
    """
    vertices: np.ndarray
    dominant_monomial: int
    dimension: int


# =============================================================================
# Algorithm 1: Certificate Tree Construction
# =============================================================================

def verify_lorentzian_signature(A: np.ndarray) -> Tuple[bool, np.ndarray]:
    """Check if a symmetric matrix has at most one positive eigenvalue.

    Time complexity: O(n³) for eigenvalue decomposition
    Space complexity: O(n²)

    Args:
        A: Symmetric n×n matrix

    Returns:
        (is_lorentzian, eigenvalues): Whether the matrix has Lorentzian
        signature, and the computed eigenvalues
    """
    eigenvalues = np.linalg.eigvalsh(A)
    n_positive = np.sum(eigenvalues > 1e-10)
    return n_positive <= 1, eigenvalues


def build_certificate_tree(
    coefficients: Dict[Tuple[int, ...], float],
    n: int,
    d: int,
    depth: int = 0
) -> CertificateNode:
    """Recursively build a Lorentzian certificate tree.

    For a degree-d polynomial in n variables, constructs the tree of
    partial derivatives down to degree 2, verifying Lorentzian signature
    at each leaf.

    Time complexity: O(n^(d-2) · n³) total
    Space complexity: O(n^(d-2) · n²) for storing all matrices

    Args:
        coefficients: Polynomial coefficients indexed by multi-indices
        n: Number of variables
        d: Current degree
        depth: Current depth in the tree

    Returns:
        Root node of the certificate subtree
    """
    if d <= 2:
        # Leaf node: construct Hessian and verify
        H = np.zeros((n, n))
        for alpha, coeff in coefficients.items():
            for i in range(n):
                for j in range(n):
                    # Coefficient of x_i x_j in the polynomial
                    beta = list(alpha)
                    if beta[i] >= 1 and beta[j] >= 1:
                        factor = beta[i] * (beta[j] - (1 if i == j else 0))
                        if i == j:
                            factor = beta[i] * (beta[i] - 1) if beta[i] >= 2 else 0
                            H[i, j] += coeff * factor
                        else:
                            H[i, j] += coeff * beta[i] * beta[j]
                    elif i == j and beta[i] >= 2:
                        H[i, j] += coeff * beta[i] * (beta[i] - 1)

        H = (H + H.T) / 2  # Symmetrize
        is_lor, eigvals = verify_lorentzian_signature(H)

        return CertificateNode(
            matrix=H,
            eigenvalues=eigvals,
            is_lorentzian=is_lor,
            depth=depth
        )

    # Internal node: differentiate with respect to each variable
    node = CertificateNode(
        matrix=np.zeros((n, n)),
        depth=depth
    )

    for i in range(n):
        # Compute partial derivative ∂f/∂x_i
        new_coeffs = {}
        for alpha, coeff in coefficients.items():
            if alpha[i] >= 1:
                new_alpha = list(alpha)
                new_alpha[i] -= 1
                new_alpha = tuple(new_alpha)
                new_coeffs[new_alpha] = new_coeffs.get(new_alpha, 0) + coeff * alpha[i]

        if new_coeffs:
            child = build_certificate_tree(new_coeffs, n, d - 1, depth + 1)
            child.derivative_index = i
            node.children.append(child)

    node.is_lorentzian = all(
        c.is_lorentzian for c in node.children
        if not c.children  # only check leaves
    ) if node.children else True

    return node


def construct_certificate(
    coefficients: Dict[Tuple[int, ...], float],
    n: int,
    d: int
) -> CertificateTree:
    """Construct a complete Lorentzian certificate tree.

    Args:
        coefficients: Polynomial coefficients
        n: Number of variables
        d: Total degree

    Returns:
        Complete certificate tree with validity flag
    """
    root = build_certificate_tree(coefficients, n, d)

    # Count leaves
    def count_leaves(node: CertificateNode) -> int:
        if not node.children:
            return 1
        return sum(count_leaves(c) for c in node.children)

    # Check all leaves
    def all_valid(node: CertificateNode) -> bool:
        if not node.children:
            return node.is_lorentzian
        return all(all_valid(c) for c in node.children)

    n_leaves = count_leaves(root)
    is_valid = all_valid(root)

    return CertificateTree(
        root=root,
        n_variables=n,
        degree=d,
        n_leaves=n_leaves,
        is_valid=is_valid
    )


# =============================================================================
# Algorithm 2: Certificate-Guided Markov Chain
# =============================================================================

def certificate_markov_chain(
    distribution: np.ndarray,
    lazy_param: float = 0.5
) -> np.ndarray:
    """Construct the certificate-guided Markov chain transition matrix.

    Uses Metropolis-Hastings with nearest-neighbor proposals on the
    state space {0, 1, ..., n}, targeting the given distribution.

    Time complexity: O(n²) for constructing the matrix
    Space complexity: O(n²)

    Args:
        distribution: Target probability distribution (nonneg, sums to 1)
        lazy_param: Probability of staying at current state (default 0.5)

    Returns:
        Transition matrix P where P[i,j] = Pr[X_{t+1}=j | X_t=i]
    """
    n = len(distribution) - 1
    pi = distribution / distribution.sum()
    P = np.zeros((n + 1, n + 1))

    for i in range(n + 1):
        # Proposal: uniform over neighbors
        neighbors = []
        if i > 0:
            neighbors.append(i - 1)
        if i < n:
            neighbors.append(i + 1)

        n_neighbors = len(neighbors)
        if n_neighbors == 0:
            P[i, i] = 1.0
            continue

        for j in neighbors:
            # Metropolis acceptance probability
            if pi[i] > 0:
                acceptance = min(1.0, pi[j] / pi[i])
            else:
                acceptance = 1.0

            P[i, j] = (1 - lazy_param) / n_neighbors * acceptance

        P[i, i] = 1.0 - sum(P[i, j] for j in range(n + 1) if j != i)

    return P


def estimate_spectral_gap(P: np.ndarray) -> float:
    """Estimate the spectral gap of a transition matrix.

    The spectral gap is 1 - λ₂, where λ₂ is the second largest
    eigenvalue in absolute value.

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        P: Transition matrix

    Returns:
        Spectral gap γ = 1 - |λ₂|
    """
    eigenvalues = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]
    if len(eigenvalues) < 2:
        return 1.0
    return float(1.0 - eigenvalues[1])


def estimate_mixing_time(P: np.ndarray, epsilon: float = 0.01) -> int:
    """Estimate the mixing time of a Markov chain.

    Uses the spectral bound: t_mix(ε) ≤ (1/γ) · log(n/ε)

    Time complexity: O(n³) for eigenvalue computation
    Space complexity: O(n²)

    Args:
        P: Transition matrix
        epsilon: Total variation distance threshold

    Returns:
        Upper bound on mixing time
    """
    gap = estimate_spectral_gap(P)
    n = P.shape[0]
    if gap <= 1e-15:
        return 10 ** 9  # Essentially infinite
    return math.ceil((1 / gap) * math.log(n / epsilon))


def run_markov_chain(
    P: np.ndarray,
    initial_state: int,
    n_steps: int
) -> List[int]:
    """Simulate the Markov chain for n_steps.

    Time complexity: O(n_steps · n) per sample
    Space complexity: O(n_steps)

    Args:
        P: Transition matrix
        initial_state: Starting state
        n_steps: Number of steps to simulate

    Returns:
        List of states visited
    """
    states = [initial_state]
    current = initial_state
    n = P.shape[0]

    for _ in range(n_steps):
        current = np.random.choice(n, p=P[current])
        states.append(current)

    return states


# =============================================================================
# Algorithm 3: Tropical Newton Subdivision
# =============================================================================

def tropicalize(coefficients: Dict[Tuple[int, ...], float]) -> Dict[Tuple[int, ...], float]:
    """Tropicalize a polynomial: replace coefficients with their logarithms.

    Time complexity: O(m) where m is the number of monomials
    Space complexity: O(m)

    Args:
        coefficients: Polynomial coefficients

    Returns:
        Tropicalized coefficients (log of absolute values)
    """
    trop = {}
    for alpha, coeff in coefficients.items():
        if abs(coeff) > 1e-15:
            trop[alpha] = math.log(abs(coeff))
    return trop


def tropical_distance(a: Tuple[int, ...], b: Tuple[int, ...]) -> float:
    """Compute tropical distance between two points.

    The tropical distance is max_i |a_i - b_i| in the tropical semiring.

    Time complexity: O(n)
    Space complexity: O(1)
    """
    return max(abs(ai - bi) for ai, bi in zip(a, b))


def tropical_diameter(
    points: List[Tuple[int, ...]]
) -> float:
    """Compute the tropical diameter of a set of points.

    Time complexity: O(m² · n) where m = |points|, n = dimension
    Space complexity: O(1)

    Args:
        points: List of points in tropical space

    Returns:
        Maximum tropical distance between any two points
    """
    if len(points) <= 1:
        return 0.0

    max_dist = 0.0
    for i in range(len(points)):
        for j in range(i + 1, len(points)):
            d = tropical_distance(points[i], points[j])
            max_dist = max(max_dist, d)

    return max_dist


def newton_polytope_vertices(
    coefficients: Dict[Tuple[int, ...], float]
) -> List[Tuple[int, ...]]:
    """Extract the vertices (support) of the Newton polytope.

    Time complexity: O(m) where m is the number of monomials
    Space complexity: O(m)
    """
    return [alpha for alpha, coeff in coefficients.items() if abs(coeff) > 1e-15]


# =============================================================================
# Algorithm 4: Ultra-Log-Concave Rejection Sampling
# =============================================================================

def rejection_sample(
    distribution: np.ndarray,
    n_samples: int = 1000
) -> Tuple[np.ndarray, float]:
    """Sample from an ultra-log-concave distribution using rejection sampling.

    Uses a uniform proposal distribution with acceptance probability
    proportional to the target density. For ultra-log-concave distributions,
    the acceptance rate is at least 1/(d+1) where d is the support size.

    Time complexity: O(n_samples · d) expected
    Space complexity: O(n_samples)

    Args:
        distribution: Target distribution (nonneg array)
        n_samples: Number of samples to generate

    Returns:
        (samples, acceptance_rate): Array of samples and the acceptance rate
    """
    dist = np.array(distribution, dtype=float)
    dist /= dist.sum()
    d = len(dist) - 1

    # Envelope: uniform scaled by (d+1) * max(dist)
    M = max(dist) * (d + 1)

    samples = []
    total_attempts = 0

    while len(samples) < n_samples:
        # Propose uniformly from {0, ..., d}
        k = np.random.randint(0, d + 1)
        u = np.random.random()
        total_attempts += 1

        # Accept with probability dist[k] / (M/(d+1))
        if u * M / (d + 1) <= dist[k]:
            samples.append(k)

    acceptance_rate = n_samples / total_attempts
    return np.array(samples), acceptance_rate


def verify_ultra_log_concavity(
    sequence: np.ndarray,
    order: Optional[int] = None
) -> bool:
    """Verify that a sequence is ultra-log-concave.

    A sequence (a_k) is ultra-log-concave of order n if
    a_k^2 * C(n,k-1)*C(n,k+1) >= a_{k-1}*a_{k+1} * C(n,k)^2

    Time complexity: O(d)
    Space complexity: O(1)

    Args:
        sequence: The sequence to check
        order: The order n for ultra-log-concavity (default: len-1)

    Returns:
        True if the sequence is ultra-log-concave
    """
    d = len(sequence) - 1
    if order is None:
        order = d

    for k in range(1, d):
        lhs = sequence[k] ** 2 * math.comb(order, k-1) * math.comb(order, k+1)
        rhs = sequence[k-1] * sequence[k+1] * math.comb(order, k) ** 2
        if lhs < rhs - 1e-10:
            return False

    return True


# =============================================================================
# Algorithm 5: Complete Sampling Pipeline
# =============================================================================

def certificate_guided_sample(
    distribution: np.ndarray,
    n_samples: int = 1000,
    method: str = "markov",
    burn_in: Optional[int] = None
) -> Tuple[np.ndarray, Dict]:
    """Complete certificate-guided sampling pipeline.

    Combines:
    1. Log-concavity verification
    2. Markov chain construction with spectral gap guarantee
    3. Burn-in period based on mixing time estimate
    4. Thinning based on autocorrelation

    Time complexity: O(n_samples · n² · d · log n)
    Space complexity: O(n_samples + n²)

    Args:
        distribution: Target distribution
        n_samples: Number of independent samples
        method: "markov" for MCMC, "rejection" for rejection sampling
        burn_in: Override burn-in period (default: auto from spectral gap)

    Returns:
        (samples, diagnostics): Samples and diagnostic information
    """
    dist = np.array(distribution, dtype=float)
    dist /= dist.sum()
    n = len(dist) - 1

    diagnostics = {
        "log_concave": is_log_concave_check(dist),
        "n_states": n + 1,
    }

    if method == "rejection":
        samples, acc_rate = rejection_sample(dist, n_samples)
        diagnostics["acceptance_rate"] = acc_rate
        diagnostics["method"] = "rejection"
        return samples, diagnostics

    # Markov chain method
    P = certificate_markov_chain(dist)
    gap = estimate_spectral_gap(P)
    t_mix = estimate_mixing_time(P)

    diagnostics["spectral_gap"] = gap
    diagnostics["mixing_time"] = t_mix
    diagnostics["method"] = "markov"

    if burn_in is None:
        burn_in = t_mix

    # Run chain with burn-in and thinning
    total_steps = burn_in + n_samples * max(1, int(1 / gap)) if gap > 0 else burn_in + n_samples * 100
    states = run_markov_chain(P, n // 2, total_steps)

    # Thin the chain
    thin = max(1, int(1 / gap)) if gap > 0 else 100
    samples = np.array(states[burn_in::thin][:n_samples])

    diagnostics["burn_in"] = burn_in
    diagnostics["thinning"] = thin

    return samples, diagnostics


def is_log_concave_check(seq: np.ndarray) -> bool:
    """Check log-concavity of a sequence."""
    for k in range(1, len(seq) - 1):
        if seq[k] ** 2 < seq[k-1] * seq[k+1] - 1e-12:
            return False
    return True


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("Certificate-Guided Sampling Algorithms")
    print("=" * 50)

    # Example 1: Verify certificate for a simple Lorentzian polynomial
    # f(x,y,z) = x² + y² + z² + xy + xz + yz (degree 2, 3 variables)
    print("\n1. Certificate construction for x² + y² + z² + xy + xz + yz")
    coeffs = {
        (2, 0, 0): 1.0,
        (0, 2, 0): 1.0,
        (0, 0, 2): 1.0,
        (1, 1, 0): 1.0,
        (1, 0, 1): 1.0,
        (0, 1, 1): 1.0,
    }
    cert = construct_certificate(coeffs, 3, 2)
    print(f"   Valid certificate: {cert.is_valid}")
    print(f"   Number of leaves: {cert.n_leaves}")

    # Example 2: Sampling from binomial distribution
    print("\n2. Sampling from Binomial(10, 0.5)")
    binom = np.array([math.comb(10, k) for k in range(11)], dtype=float)
    samples_mcmc, diag_mcmc = certificate_guided_sample(binom, 5000, method="markov")
    samples_rej, diag_rej = certificate_guided_sample(binom, 5000, method="rejection")

    print(f"   MCMC: mean={samples_mcmc.mean():.2f}, gap={diag_mcmc['spectral_gap']:.4f}")
    print(f"   Rejection: mean={samples_rej.mean():.2f}, "
          f"acc_rate={diag_rej['acceptance_rate']:.4f}")

    # Example 3: Tropical diameter
    print("\n3. Tropical diameter of Newton polytope")
    vertices = newton_polytope_vertices(coeffs)
    td = tropical_diameter(vertices)
    print(f"   Vertices: {vertices}")
    print(f"   Tropical diameter: {td}")

    # Example 4: Ultra-log-concavity verification
    print("\n4. Ultra-log-concavity check")
    for n in [5, 10, 20]:
        binom_n = [math.comb(n, k) for k in range(n + 1)]
        ulc = verify_ultra_log_concavity(np.array(binom_n))
        print(f"   Binomial({n}): ultra-log-concave = {ulc}")

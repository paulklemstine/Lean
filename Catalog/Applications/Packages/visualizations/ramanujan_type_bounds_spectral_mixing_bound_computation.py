"""
Algorithms for Berggren Expander Dynamics

Implements the key algorithms from the research paper:
1. Berggren tree generation with depth/size bounds
2. Spectral analysis of the sibling operator
3. Observable mixing simulation
4. Deterministic pseudorandom sampling
5. Discrepancy computation
"""

import numpy as np
from typing import List, Tuple, Optional, Dict, Callable
from dataclasses import dataclass

# ============================================================================
# Berggren Generators
# ============================================================================

B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)
GENERATORS = [B1, B2, B3]
ROOT = np.array([3, 4, 5], dtype=np.int64)
Q_MATRIX = np.diag([1, 1, -1]).astype(np.int64)


@dataclass
class BerggrenSpectralData:
    """Certified spectral parameters for the Berggren expander.
    
    These values are formally verified:
    - rho = 1/4 (l² norm squared contraction rate)
    - disc_const = 12 (discrepancy constant)
    - spectral_gap = 3/4 (1 - rho)
    - second_eigenvalue = 1/2 (|λ₂| of the sibling operator)
    """
    rho: float = 0.25
    disc_const: float = 12.0
    spectral_gap: float = 0.75
    second_eigenvalue: float = 0.5


CERTIFIED_DATA = BerggrenSpectralData()


# ============================================================================
# Algorithm 1: Berggren Tree Generation
# ============================================================================

def generate_berggren_tree(max_depth: int) -> Dict[int, List[np.ndarray]]:
    """Generate the Berggren tree up to max_depth.
    
    Args:
        max_depth: Maximum depth to generate.
        
    Returns:
        Dictionary mapping depth -> list of triples at that depth.
        
    Complexity: O(3^max_depth) time and space.
    
    Example:
        >>> tree = generate_berggren_tree(2)
        >>> len(tree[0])  # root
        1
        >>> len(tree[1])  # 3 children
        3
        >>> len(tree[2])  # 9 grandchildren
        9
    """
    tree: Dict[int, List[np.ndarray]] = {0: [ROOT.copy()]}
    
    for d in range(1, max_depth + 1):
        tree[d] = []
        for parent in tree[d - 1]:
            for B in GENERATORS:
                child = B @ parent
                tree[d].append(child)
    
    return tree


def berggren_word_to_triple(word: List[int]) -> np.ndarray:
    """Convert a word in {0,1,2} to the corresponding Pythagorean triple.
    
    Args:
        word: List of generator indices (0=B₁, 1=B₂, 2=B₃).
        
    Returns:
        The Pythagorean triple obtained by applying generators in order.
        
    Example:
        >>> berggren_word_to_triple([0])  # B₁ · (3,4,5)
        array([ 5, 12, 13])
    """
    v = ROOT.copy()
    for idx in word:
        v = GENERATORS[idx] @ v
    return v


# ============================================================================
# Algorithm 2: Spectral Analysis
# ============================================================================

def sibling_operator() -> np.ndarray:
    """Return the K₃ sibling transition matrix T.
    
    T(i,j) = 0 if i=j, 1/2 if i≠j.
    
    Returns:
        3×3 doubly stochastic matrix.
    """
    T = np.full((3, 3), 0.5)
    np.fill_diagonal(T, 0.0)
    return T


def compute_spectral_data(T: np.ndarray) -> Dict:
    """Compute full spectral data for a transition matrix.
    
    Args:
        T: Square transition matrix.
        
    Returns:
        Dictionary with eigenvalues, eigenvectors, spectral gap, etc.
    """
    eigenvalues, eigenvectors = np.linalg.eig(T)
    idx = np.argsort(-np.real(eigenvalues))
    eigenvalues = np.real(eigenvalues[idx])
    eigenvectors = np.real(eigenvectors[:, idx])
    
    lambda_1 = eigenvalues[0]
    lambda_2 = max(abs(eigenvalues[1:]))
    
    return {
        'eigenvalues': eigenvalues,
        'eigenvectors': eigenvectors,
        'lambda_1': lambda_1,
        'lambda_2': lambda_2,
        'spectral_gap': lambda_1 - lambda_2,
        'contraction_rate': lambda_2**2,
        'is_ramanujan': abs(lambda_2) <= 2 * np.sqrt(1) / 2  # Alon-Boppana for K₃
    }


# ============================================================================
# Algorithm 3: Observable Mixing Simulation
# ============================================================================

def simulate_mixing(f: np.ndarray, T: np.ndarray, steps: int) -> List[float]:
    """Simulate mixing of an observable under the sibling walk.
    
    Args:
        f: Initial observable (should be mean-zero for contraction).
        T: Transition matrix.
        steps: Number of iterations.
        
    Returns:
        List of l² norms squared at each step.
        
    Complexity: O(steps * n²) where n is the matrix dimension.
    """
    norms = []
    fk = f.copy()
    for _ in range(steps + 1):
        norms.append(float(np.sum(fk**2)))
        fk = T @ fk
    return norms


def theoretical_bound(f: np.ndarray, steps: int, rho: float = 0.25) -> List[float]:
    """Compute the theoretical upper bound for mixing.
    
    Args:
        f: Initial observable.
        steps: Number of iterations.
        rho: Spectral contraction rate (default 1/4 for Berggren).
        
    Returns:
        List of theoretical bounds at each step.
    """
    f_sq = float(np.sum(f**2))
    return [rho**k * f_sq for k in range(steps + 1)]


# ============================================================================
# Algorithm 4: Deterministic Pseudorandom Sampling
# ============================================================================

def deterministic_sample(n: int, num_samples: int,
                        observable: Optional[Callable] = None) -> Dict:
    """Generate a deterministic pseudorandom sample of Pythagorean triples.
    
    Uses the Berggren tree structure to generate triples that are
    pseudorandom for bounded observables, with mixing guaranteed by
    the spectral gap.
    
    Args:
        n: Depth (word length) for generation.
        num_samples: Number of triples to generate.
        observable: Optional function to evaluate on each triple.
        
    Returns:
        Dictionary with triples, observable values, and statistics.
        
    Complexity: O(num_samples * n) per triple.
    
    Example:
        >>> result = deterministic_sample(5, 10)
        >>> len(result['triples'])
        10
    """
    # Generate words using a deterministic low-discrepancy sequence
    # over {0,1,2}^n using van der Corput-style enumeration
    triples = []
    obs_values = []
    
    for i in range(num_samples):
        # Convert i to base 3, reversed (van der Corput style)
        word = []
        val = i
        for _ in range(n):
            word.append(val % 3)
            val //= 3
        
        triple = berggren_word_to_triple(word)
        triples.append(triple)
        
        if observable is not None:
            obs_values.append(observable(triple))
    
    result = {
        'triples': triples,
        'depth': n,
        'num_samples': num_samples,
    }
    
    if observable is not None:
        obs_values = np.array(obs_values)
        result['observable_values'] = obs_values
        result['mean'] = float(np.mean(obs_values))
        result['std'] = float(np.std(obs_values))
    
    return result


# ============================================================================
# Algorithm 5: Discrepancy Computation
# ============================================================================

def compute_discrepancy(triples: List[np.ndarray],
                       observable: Callable,
                       reference_mean: Optional[float] = None) -> float:
    """Compute the discrepancy of a collection of triples for an observable.
    
    Args:
        triples: List of Pythagorean triples.
        observable: Function mapping triple → real value.
        reference_mean: If known, the limiting mean. Otherwise estimated.
        
    Returns:
        Discrepancy value (deviation from mean).
    """
    values = np.array([observable(t) for t in triples])
    sample_mean = np.mean(values)
    
    if reference_mean is None:
        reference_mean = sample_mean
    
    return abs(sample_mean - reference_mean)


def mixing_time_bound(epsilon: float, B: float = 1.0,
                     data: BerggrenSpectralData = CERTIFIED_DATA) -> int:
    """Compute the number of steps needed for ε-mixing.
    
    Uses the certified bound: ‖T^k(f-μ)‖₂² ≤ disc_const · B² · ρ^k
    
    Args:
        epsilon: Target accuracy.
        B: Bound on the observable.
        data: Certified spectral parameters.
        
    Returns:
        Minimum k such that disc_const · B² · ρ^k ≤ ε.
        
    Example:
        >>> mixing_time_bound(0.01)
        6
    """
    if epsilon >= data.disc_const * B**2:
        return 0
    
    import math
    k = math.ceil(math.log(epsilon / (data.disc_const * B**2)) / math.log(data.rho))
    return max(0, k)


# ============================================================================
# Algorithm 6: Lorentz Form Analysis
# ============================================================================

def lorentz_form(v: np.ndarray) -> int:
    """Compute Q(v) = v₀² + v₁² - v₂²."""
    return int(v[0]**2 + v[1]**2 - v[2]**2)


def verify_lorentz_identity() -> bool:
    """Verify SᵀQS = diag(1,1,-9)."""
    S = B1 + B2 + B3
    result = S.T @ Q_MATRIX @ S
    expected = np.diag([1, 1, -9])
    return np.array_equal(result, expected)


def light_cone_amplification(v: np.ndarray) -> Tuple[int, int]:
    """Compute Q(Sv) and -8v₂² for a Pythagorean triple v.
    
    Returns:
        (Q(Sv), -8*v₂²) — should be equal for Pythagorean v.
    """
    S = B1 + B2 + B3
    Sv = S @ v
    return lorentz_form(Sv), -8 * int(v[2]**2)


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    print("=== Berggren Expander Algorithms ===\n")
    
    # Generate tree
    tree = generate_berggren_tree(3)
    for d in range(4):
        print(f"Depth {d}: {len(tree[d])} triples")
    
    # Spectral analysis
    T = sibling_operator()
    spec = compute_spectral_data(T)
    print(f"\nSpectral data:")
    print(f"  λ₁ = {spec['lambda_1']:.4f}")
    print(f"  |λ₂| = {spec['lambda_2']:.4f}")
    print(f"  Gap = {spec['spectral_gap']:.4f}")
    print(f"  Ramanujan: {spec['is_ramanujan']}")
    
    # Mixing simulation
    f = np.array([1, -1, 0], dtype=np.float64)
    norms = simulate_mixing(f, T, 10)
    bounds = theoretical_bound(f, 10)
    print(f"\nMixing of f = (1,-1,0):")
    for k in range(11):
        print(f"  k={k}: ‖T^k f‖₂² = {norms[k]:.10f}, bound = {bounds[k]:.10f}")
    
    # Mixing time
    print(f"\nMixing times:")
    for eps in [0.1, 0.01, 1e-6]:
        k = mixing_time_bound(eps)
        print(f"  ε = {eps}: k = {k} steps")
    
    # Verify Lorentz identity
    print(f"\nLorentz identity SᵀQS = diag(1,1,-9): {verify_lorentz_identity()}")
    
    # Light cone
    q, expected = light_cone_amplification(ROOT)
    print(f"Q(S·(3,4,5)) = {q}, -8·5² = {expected}, match: {q == expected}")

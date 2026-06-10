#!/usr/bin/env python3
"""
Algorithms for Spectral Pseudorandomness Analysis of Berggren Walks

Implements:
1. Berggren walk simulation with observable tracking
2. Spectral decay verification for graded test families
3. Bias estimation for product tests
4. General Markov operator spectral analysis
"""

import numpy as np
from typing import List, Tuple, Callable, Optional


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Berggren Walk Simulator
# ═══════════════════════════════════════════════════════════════════════

class BerggrenWalk:
    """Simulates random walks on the Berggren tree of Pythagorean triples.

    The Berggren tree generates all primitive Pythagorean triples from the
    root (3,4,5) using three integer matrix generators B₁, B₂, B₃ that
    preserve the Pythagorean relation a² + b² = c².

    Time complexity: O(n) per walk of length n
    Space complexity: O(1) per step (streaming)
    """

    B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
    B2 = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]], dtype=np.int64)
    B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)

    GENERATORS = [B1, B2, B3]
    ROOT = np.array([3, 4, 5], dtype=np.int64)

    def __init__(self, seed: Optional[int] = None):
        self.rng = np.random.RandomState(seed)
        self.state = self.ROOT.copy()
        self.history: List[np.ndarray] = [self.state.copy()]
        self.word: List[int] = []

    def step(self) -> np.ndarray:
        """Take one random step. Returns new Pythagorean triple."""
        idx = self.rng.randint(3)
        self.word.append(idx)
        self.state = self.GENERATORS[idx] @ self.state
        self.history.append(self.state.copy())
        return self.state.copy()

    def walk(self, n: int) -> List[np.ndarray]:
        """Take n random steps. Returns list of all triples visited."""
        for _ in range(n):
            self.step()
        return self.history.copy()

    def verify_pythagorean(self) -> bool:
        """Verify current state is a Pythagorean triple."""
        a, b, c = self.state
        return a*a + b*b == c*c


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Spectral Decay Verifier
# ═══════════════════════════════════════════════════════════════════════

def verify_spectral_decay(
    T: np.ndarray,
    test_functions: List[np.ndarray],
    rho: float,
    n_steps: int,
    tolerance: float = 1e-10
) -> dict:
    """Verify the spectral decay theorem computationally.

    Given a transition matrix T and a set of mean-zero test functions,
    checks that ‖T^n f‖ ≤ ρ^n · ‖f‖ for each test function.

    Args:
        T: Square transition matrix (doubly stochastic)
        test_functions: List of mean-zero test vectors
        rho: Expected spectral contraction rate
        n_steps: Number of iterations to verify
        tolerance: Numerical tolerance for bound verification

    Returns:
        Dictionary with verification results per test function

    Time complexity: O(n_steps × d² × |test_functions|) where d = dim
    """
    results = {}
    d = T.shape[0]

    for idx, f in enumerate(test_functions):
        f_norm = np.max(np.abs(f))
        norms = [f_norm]
        bounds = [f_norm]
        violations = []

        g = f.copy()
        for n in range(1, n_steps + 1):
            g = T @ g
            actual = np.max(np.abs(g))
            bound = (rho ** n) * f_norm
            norms.append(actual)
            bounds.append(bound)
            if actual > bound + tolerance:
                violations.append((n, actual, bound))

        results[idx] = {
            'initial_norm': f_norm,
            'norms': norms,
            'bounds': bounds,
            'violations': violations,
            'verified': len(violations) == 0,
            'tightest_ratio': max(a/b for a, b in zip(norms, bounds) if b > tolerance)
        }

    return results


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Graded Test Space Constructor
# ═══════════════════════════════════════════════════════════════════════

def construct_product_test_spaces(
    alphabet_size: int,
    word_length: int,
    max_degree: int
) -> dict:
    """Construct graded product test spaces for word-space walks.

    For words in {0,...,alphabet_size-1}^word_length, degree-k tests
    depend on at most k coordinates. This constructs orthogonal bases
    for each degree stratum.

    Args:
        alphabet_size: Size of alphabet (3 for Berggren)
        word_length: Length of words L
        max_degree: Maximum degree to compute

    Returns:
        Dictionary mapping degree k to list of basis functions

    Time complexity: O(alphabet_size^word_length × C(L,k) × alphabet_size^k)
    """
    from itertools import combinations, product as iterproduct

    dim = alphabet_size ** word_length
    spaces = {}

    for k in range(min(max_degree + 1, word_length + 1)):
        basis = []
        # For each subset of k coordinates
        for coords in combinations(range(word_length), k):
            # For each non-constant function on those k coordinates
            for values in iterproduct(range(alphabet_size), repeat=k):
                # Character: product of indicators
                vec = np.zeros(dim)
                for word_idx in range(dim):
                    # Decode word index
                    word = []
                    tmp = word_idx
                    for _ in range(word_length):
                        word.append(tmp % alphabet_size)
                        tmp //= alphabet_size

                    # Evaluate character
                    match = all(word[c] == v for c, v in zip(coords, values))
                    vec[word_idx] = 1.0 if match else 0.0

                # Center (subtract mean)
                vec -= np.mean(vec)
                if np.linalg.norm(vec) > 1e-12:
                    basis.append(vec / np.linalg.norm(vec))

        spaces[k] = basis

    return spaces


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Markov Operator Spectral Analyzer
# ═══════════════════════════════════════════════════════════════════════

def analyze_markov_spectrum(
    T: np.ndarray,
    graded_spaces: Optional[dict] = None
) -> dict:
    """Complete spectral analysis of a Markov operator.

    Computes eigenvalues, spectral gap, and (if graded spaces provided)
    the contraction rate on each degree stratum.

    Args:
        T: Transition matrix
        graded_spaces: Optional dict mapping degree to basis vectors

    Returns:
        Spectral analysis results

    Time complexity: O(d³) for eigendecomposition
    """
    d = T.shape[0]
    eigenvalues = np.linalg.eigvals(T)
    eigenvalues_sorted = sorted(eigenvalues, key=lambda x: -abs(x))

    result = {
        'dimension': d,
        'eigenvalues': eigenvalues_sorted,
        'spectral_gap': 1 - abs(eigenvalues_sorted[1]) if len(eigenvalues_sorted) > 1 else 1,
        'is_doubly_stochastic': (
            np.allclose(T.sum(axis=0), 1) and
            np.allclose(T.sum(axis=1), 1) and
            np.all(T >= -1e-12)
        )
    }

    if graded_spaces is not None:
        degree_contractions = {}
        for k, basis in graded_spaces.items():
            if len(basis) == 0:
                degree_contractions[k] = 0.0
                continue
            max_ratio = 0.0
            for b in basis:
                Tb = T @ b
                if np.linalg.norm(b) > 1e-12:
                    ratio = np.linalg.norm(Tb) / np.linalg.norm(b)
                    max_ratio = max(max_ratio, ratio)
            degree_contractions[k] = max_ratio
        result['degree_contractions'] = degree_contractions

    return result


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Bias Estimator for Product Tests
# ═══════════════════════════════════════════════════════════════════════

def estimate_bias(
    walk_simulator: BerggrenWalk,
    observable: Callable[[np.ndarray], float],
    n_steps: int,
    n_samples: int = 10000
) -> Tuple[float, float]:
    """Monte Carlo estimation of the bias of an observable under the walk.

    Estimates E[f(X_n)] where X_n is the state after n walk steps and
    f is the observable. For a centered observable, this should decay
    exponentially if the spectral decay theorem applies.

    Args:
        walk_simulator: BerggrenWalk instance (will be reset)
        observable: Function mapping states to reals
        n_steps: Number of walk steps
        n_samples: Number of independent samples

    Returns:
        (estimated_bias, standard_error)

    Time complexity: O(n_samples × n_steps)
    """
    values = []
    for _ in range(n_samples):
        walk = BerggrenWalk(seed=None)
        walk.walk(n_steps)
        values.append(observable(walk.state))

    values = np.array(values)
    mean = np.mean(values)
    se = np.std(values) / np.sqrt(n_samples)
    return mean, se


# ═══════════════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("Spectral Pseudorandomness Algorithms — Demo")
    print("=" * 60)

    # Demo 1: Berggren walk
    print("\n--- Berggren Walk ---")
    walk = BerggrenWalk(seed=42)
    triples = walk.walk(10)
    for i, t in enumerate(triples):
        a, b, c = t
        print(f"  Step {i}: ({a}, {b}, {c}), "
              f"Pythagorean: {a*a + b*b == c*c}")

    # Demo 2: Spectral decay verification
    print("\n--- Spectral Decay Verification (K₃ walk) ---")
    T = np.array([[0, 0.5, 0.5], [0.5, 0, 0.5], [0.5, 0.5, 0]])
    test_fns = [
        np.array([1.0, -0.5, -0.5]),
        np.array([0.0, 1.0, -1.0]),
        np.array([2.0, -1.0, -1.0])
    ]
    results = verify_spectral_decay(T, test_fns, rho=0.5, n_steps=20)
    for idx, r in results.items():
        print(f"  Test {idx}: verified={r['verified']}, "
              f"tightest_ratio={r['tightest_ratio']:.4f}")

    # Demo 3: Spectrum analysis
    print("\n--- Markov Spectrum Analysis ---")
    spectrum = analyze_markov_spectrum(T)
    print(f"  Eigenvalues: {[f'{e:.4f}' for e in spectrum['eigenvalues']]}")
    print(f"  Spectral gap: {spectrum['spectral_gap']:.4f}")
    print(f"  Doubly stochastic: {spectrum['is_doubly_stochastic']}")

    print("\nAll demos complete.")

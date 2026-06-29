#!/usr/bin/env python3
"""
Tropical Kernel Mean Duality — Applications

Real-world applications of tropical kernel prototype reconstruction:
1. Explainable classification via tropical prototype selection
2. Sparse tropical regression
3. Signal compression via tropical kernel support
4. Robust predictor certification
"""

import numpy as np
from algorithms import (
    TropicalKernel, certified_decomposition,
    compute_all_residuated_coefficients, reconstruct_from_support,
    greedy_minimal_support, estimate_feature_rank
)
from typing import List, Tuple


# ─────────────────────────────────────────────────────────────
# Application 1: Explainable Tropical Classification
# ─────────────────────────────────────────────────────────────

def tropical_prototype_classifier(
    X_train: np.ndarray,
    y_train: np.ndarray,
    X_test: np.ndarray,
    feature_dim: int = 3
) -> Tuple[np.ndarray, List[int], np.ndarray]:
    """
    Tropical prototype classifier with certified minimal support.
    
    Uses tropical kernel sections as class representatives and
    finds the minimal set of prototypes needed for classification.
    
    Parameters
    ----------
    X_train : np.ndarray of shape (n_train, d)
    y_train : np.ndarray of shape (n_train,) with integer labels
    X_test : np.ndarray of shape (n_test, d)
    feature_dim : int
        Number of tropical features (controls kernel rank).
    
    Returns
    -------
    predictions : np.ndarray
    prototypes : List[int]
    prototype_weights : np.ndarray
    """
    n_train = X_train.shape[0]
    n_test = X_test.shape[0]
    classes = np.unique(y_train)
    
    # Build tropical feature map via random projection
    np.random.seed(0)
    W = np.random.randn(X_train.shape[1], feature_dim)
    phi_train = X_train @ W
    phi_test = X_test @ W
    
    # Build tropical kernel on training data
    K = TropicalKernel.from_features(phi_train)
    
    predictions = np.zeros(n_test, dtype=int)
    all_prototypes = []
    
    for c in classes:
        # Build class indicator (tropical style)
        mask = (y_train == c).astype(float) * 10.0 - 5.0
        f = np.full(n_train, -np.inf)
        for x in range(n_train):
            f = np.maximum(f, mask[x] + K.matrix[x, :])
        
        # Find minimal prototype support
        decomp = certified_decomposition(K, f)
        all_prototypes.extend(decomp.support)
        
        # Predict on test data using prototypes
        coeffs = compute_all_residuated_coefficients(K, f)
        test_scores = np.full(n_test, -np.inf)
        for x in decomp.support:
            for j in range(n_test):
                # Cross-kernel evaluation via features
                k_val = np.max(phi_train[x, :] + phi_test[j, :])
                test_scores[j] = max(test_scores[j], coeffs[x] + k_val)
        
        if c == classes[0]:
            best_scores = test_scores.copy()
            predictions[:] = c
        else:
            better = test_scores > best_scores
            predictions[better] = c
            best_scores[better] = test_scores[better]
    
    unique_prototypes = sorted(set(all_prototypes))
    return predictions, unique_prototypes, np.array([])


# ─────────────────────────────────────────────────────────────
# Application 2: Sparse Tropical Regression
# ─────────────────────────────────────────────────────────────

def tropical_sparse_regression(
    K: TropicalKernel,
    y: np.ndarray,
    max_support: int = None
) -> Tuple[np.ndarray, List[int], float]:
    """
    Sparse tropical regression: find minimal prototype representation.
    
    Given kernel K and target y, find the smallest support set S
    such that y ≈ max_{x∈S} (c_x + K(x, ·)).
    
    Parameters
    ----------
    K : TropicalKernel
    y : np.ndarray
    max_support : int, optional
    
    Returns
    -------
    prediction : np.ndarray
    support : List[int]
    error : float
    """
    decomp = certified_decomposition(K, y)
    
    if max_support is not None and len(decomp.support) > max_support:
        # Rank prototypes by importance (tightness frequency)
        coeffs = compute_all_residuated_coefficients(K, y)
        importance = np.zeros(K.n)
        for x in decomp.support:
            contribution = coeffs[x] + K.matrix[x, :]
            importance[x] = np.sum(np.abs(y - contribution) < 1e-8)
        
        top_support = sorted(decomp.support,
                            key=lambda x: -importance[x])[:max_support]
        pred = reconstruct_from_support(K, y, top_support)
        error = float(np.max(np.abs(pred - y)))
        return pred, top_support, error
    
    pred = reconstruct_from_support(K, y, decomp.support)
    return pred, decomp.support, decomp.reconstruction_error


# ─────────────────────────────────────────────────────────────
# Application 3: Signal Compression
# ─────────────────────────────────────────────────────────────

def tropical_signal_compression(
    signal: np.ndarray,
    rank: int = 4
) -> Tuple[np.ndarray, List[int], float]:
    """
    Compress a signal using tropical kernel prototype selection.
    
    Build a tropical kernel from the signal structure and find
    the minimal prototype set for exact or near-exact reconstruction.
    
    Parameters
    ----------
    signal : np.ndarray of shape (n,)
    rank : int
        Feature rank for the tropical kernel.
    
    Returns
    -------
    reconstructed : np.ndarray
    prototypes : List[int]
    compression_ratio : float
    """
    n = len(signal)
    
    # Build features from signal windows
    features = np.zeros((n, rank))
    for k in range(rank):
        shift = k * n // rank
        for i in range(n):
            features[i, k] = signal[(i + shift) % n]
    
    K = TropicalKernel.from_features(features)
    
    # Find minimal support for the signal (viewed as kernel section)
    f = signal
    support = greedy_minimal_support(K, f)
    reconstructed = reconstruct_from_support(K, f, support)
    
    compression_ratio = len(support) / n
    
    return reconstructed, support, compression_ratio


# ─────────────────────────────────────────────────────────────
# Application 4: Robustness Certification
# ─────────────────────────────────────────────────────────────

def certify_predictor_robustness(
    K: TropicalKernel,
    f: np.ndarray,
    epsilon: float = 0.1
) -> Tuple[bool, float, List[int]]:
    """
    Certify that a tropical predictor is robust to kernel perturbations.
    
    If the residuation gap (f(y) - max_{x∈S} (c_x + K(x,y))) is 0
    on the minimal support, then the predictor is certified robust
    to perturbations of size up to the minimum non-support gap.
    
    Parameters
    ----------
    K : TropicalKernel
    f : np.ndarray
    epsilon : float
        Perturbation budget.
    
    Returns
    -------
    is_robust : bool
    margin : float
    support : List[int]
    """
    decomp = certified_decomposition(K, f)
    
    # Compute the "margin" — gap between f and next-best reconstruction
    coeffs = compute_all_residuated_coefficients(K, f)
    
    contributions = np.full((K.n, K.n), -np.inf)
    for x in range(K.n):
        contributions[x, :] = coeffs[x] + K.matrix[x, :]
    
    # For each y, compute gap between best and second-best contributor
    margins = np.zeros(K.n)
    for y in range(K.n):
        sorted_contribs = np.sort(contributions[:, y])[::-1]
        if len(sorted_contribs) >= 2:
            margins[y] = sorted_contribs[0] - sorted_contribs[1]
        else:
            margins[y] = np.inf
    
    min_margin = float(np.min(margins))
    is_robust = min_margin > 2 * epsilon
    
    return is_robust, min_margin, decomp.support


# ─────────────────────────────────────────────────────────────
# Main: Run all applications
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Tropical Prototype Classification")
    print("=" * 60)
    
    # Generate synthetic classification data
    np.random.seed(42)
    n_train = 30
    X_train = np.random.randn(n_train, 4)
    y_train = (X_train[:, 0] + X_train[:, 1] > 0).astype(int)
    X_test = np.random.randn(10, 4)
    y_test = (X_test[:, 0] + X_test[:, 1] > 0).astype(int)
    
    preds, prototypes, _ = tropical_prototype_classifier(
        X_train, y_train, X_test, feature_dim=3
    )
    accuracy = np.mean(preds == y_test)
    print(f"Accuracy: {accuracy:.1%}")
    print(f"Prototypes: {prototypes}")
    print(f"Compression: {len(prototypes)}/{n_train} = "
          f"{len(prototypes)/n_train:.1%} of training data")
    
    print("\n" + "=" * 60)
    print("APPLICATION 2: Sparse Tropical Regression")
    print("=" * 60)
    
    phi = np.random.randn(20, 3)
    K = TropicalKernel.from_features(phi)
    y = K.section(5)  # Target: kernel section at point 5
    
    pred, support, error = tropical_sparse_regression(K, y)
    print(f"Target: K_5")
    print(f"Support: {support} (size {len(support)})")
    print(f"Reconstruction error: {error:.2e}")
    print(f"Feature rank estimate: {estimate_feature_rank(K)}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 3: Signal Compression")
    print("=" * 60)
    
    t = np.linspace(0, 2*np.pi, 32)
    signal = np.sin(t) + 0.5 * np.cos(3*t)
    
    reconstructed, prototypes, ratio = tropical_signal_compression(signal, rank=4)
    print(f"Signal length: {len(signal)}")
    print(f"Prototypes: {len(prototypes)}")
    print(f"Compression ratio: {ratio:.1%}")
    print(f"Max reconstruction error: {np.max(np.abs(reconstructed - signal)):.4f}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 4: Robustness Certification")
    print("=" * 60)
    
    phi = np.array([[3, 1], [1, 4], [2.5, 2.5], [0, 3], [2, 0.5]])
    K = TropicalKernel.from_features(phi)
    f = K.section(0)
    
    for eps in [0.01, 0.1, 0.5, 1.0]:
        robust, margin, support = certify_predictor_robustness(K, f, eps)
        print(f"ε={eps:.2f}: robust={robust}, margin={margin:.4f}, "
              f"support={support}")
    
    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Kernel Mean Duality — Interactive Demonstrations

Demonstrates the core concepts of tropical kernel duality:
1. Rank-1 tropical kernel with unique prototype
2. Rank-2 kernel with minimal prototype set
3. Residuated coefficient computation and reconstruction
4. Support antichain verification
"""

import numpy as np
from typing import List, Tuple, Optional

def tropical_max(a: float, b: float) -> float:
    """Tropical addition (max)."""
    return max(a, b)

def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication (ordinary +)."""
    return a + b


# ─────────────────────────────────────────────────────────────
# §1. Tropical Feature Factorization
# ─────────────────────────────────────────────────────────────

def make_kernel_from_features(phi: np.ndarray) -> np.ndarray:
    """
    Given feature map φ : X → ℝ^r (as an n×r matrix),
    compute the tropical kernel K(x,y) = max_i (φ(x,i) + φ(y,i)).
    
    Parameters
    ----------
    phi : np.ndarray of shape (n, r)
    
    Returns
    -------
    K : np.ndarray of shape (n, n)
    """
    n, r = phi.shape
    K = np.full((n, n), -np.inf)
    for i in range(r):
        K = np.maximum(K, np.add.outer(phi[:, i], phi[:, i]))
    return K


def verify_symmetry(K: np.ndarray) -> bool:
    """Check that K is symmetric."""
    return np.allclose(K, K.T)


# ─────────────────────────────────────────────────────────────
# §2. Residuated Coefficients
# ─────────────────────────────────────────────────────────────

def residuated_coefficient(K: np.ndarray, f: np.ndarray, x: int) -> float:
    """
    Compute the residuated coefficient of x for representing f via K_x.
    
    res(K, f, x) = min_y (f(y) - K(x, y))
    
    This is the largest c such that c + K(x,y) ≤ f(y) for all y.
    """
    return np.min(f - K[x, :])


def residuated_coefficients(K: np.ndarray, f: np.ndarray) -> np.ndarray:
    """Compute all residuated coefficients."""
    n = K.shape[0]
    return np.array([residuated_coefficient(K, f, x) for x in range(n)])


# ─────────────────────────────────────────────────────────────
# §3. Tropical Prototype Predictor
# ─────────────────────────────────────────────────────────────

def tropical_predictor(K: np.ndarray, f: np.ndarray,
                       support: List[int]) -> np.ndarray:
    """
    Reconstruct f from support set S using residuated coefficients.
    
    pred(y) = max_{x ∈ S} (res(K, f, x) + K(x, y))
    """
    n = K.shape[0]
    coeffs = residuated_coefficients(K, f)
    pred = np.full(n, -np.inf)
    for x in support:
        pred = np.maximum(pred, coeffs[x] + K[x, :])
    return pred


def find_active_support(K: np.ndarray, f: np.ndarray) -> List[int]:
    """
    Find the active support: elements x where the residuated bound is tight.
    
    x is active if ∃ y: res(K,f,x) + K(x,y) = f(y).
    By the tightness theorem, every x is active, but some are more
    "useful" than others for reconstruction.
    """
    n = K.shape[0]
    coeffs = residuated_coefficients(K, f)
    active = []
    for x in range(n):
        gaps = f - (coeffs[x] + K[x, :])
        if np.min(np.abs(gaps)) < 1e-10:
            active.append(x)
    return active


def find_minimal_support(K: np.ndarray, f: np.ndarray) -> List[int]:
    """
    Find a minimal support set: greedily remove elements that don't
    affect the reconstruction.
    """
    n = K.shape[0]
    support = list(range(n))
    
    for x in range(n):
        candidate = [s for s in support if s != x]
        if len(candidate) == 0:
            continue
        pred = tropical_predictor(K, f, candidate)
        if np.allclose(pred, f):
            support = candidate
    
    return support


def is_antichain(K: np.ndarray, f: np.ndarray, support: List[int]) -> bool:
    """
    Check if support is an antichain: no element dominates another.
    
    x dominates z if res(K,f,x) + K(x,y) ≤ res(K,f,z) + K(z,y) for all y.
    """
    coeffs = residuated_coefficients(K, f)
    for x in support:
        for z in support:
            if x == z:
                continue
            # Check if x is dominated by z
            dominated = np.all(coeffs[x] + K[x, :] <= coeffs[z] + K[z, :] + 1e-10)
            if dominated:
                return False
    return True


# ─────────────────────────────────────────────────────────────
# §4. Demonstrations
# ─────────────────────────────────────────────────────────────

def demo_rank1_kernel():
    """
    Demo 1: Rank-1 tropical kernel.
    
    φ(x) = [v(x)] for a single feature, so K(x,y) = v(x) + v(y).
    This is a tropical "rank-1" kernel — all sections are parallel shifts.
    Any single point suffices as support.
    """
    print("=" * 60)
    print("DEMO 1: Rank-1 Tropical Kernel")
    print("=" * 60)
    
    n = 4
    v = np.array([1.0, 3.0, 2.0, 0.5])
    phi = v.reshape(-1, 1)
    K = make_kernel_from_features(phi)
    
    print(f"\nFeature vector v = {v}")
    print(f"Kernel K(x,y) = v(x) + v(y):")
    print(K)
    print(f"Symmetric: {verify_symmetry(K)}")
    
    # Take f = K_0 (kernel section at point 0)
    f = K[0, :]
    print(f"\nTarget f = K_0 = {f}")
    
    coeffs = residuated_coefficients(K, f)
    print(f"Residuated coefficients: {coeffs}")
    
    support = find_minimal_support(K, f)
    print(f"Minimal support: {support}")
    
    pred = tropical_predictor(K, f, support)
    print(f"Reconstructed: {pred}")
    print(f"Exact: {np.allclose(pred, f)}")
    print(f"Antichain: {is_antichain(K, f, support)}")


def demo_rank2_kernel():
    """
    Demo 2: Rank-2 tropical kernel.
    
    φ : X → ℝ² gives K(x,y) = max(φ₁(x)+φ₁(y), φ₂(x)+φ₂(y)).
    Different sections may require different support prototypes.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Rank-2 Tropical Kernel")
    print("=" * 60)
    
    n = 5
    phi = np.array([
        [3.0, 1.0],  # x=0: strong in feature 1
        [1.0, 4.0],  # x=1: strong in feature 2
        [2.5, 2.5],  # x=2: balanced
        [0.0, 3.0],  # x=3: feature 2 biased
        [2.0, 0.0],  # x=4: feature 1 biased
    ])
    K = make_kernel_from_features(phi)
    
    print(f"\nFeature map φ:")
    print(phi)
    print(f"\nTropical kernel K:")
    np.set_printoptions(precision=1)
    print(K)
    print(f"Symmetric: {verify_symmetry(K)}")
    
    # Construct a function in the kernel span
    c = np.array([0.0, -1.0, 0.0, 0.0, 0.0])
    f = np.full(n, -np.inf)
    for x in range(n):
        f = np.maximum(f, c[x] + K[x, :])
    
    print(f"\nTarget f (tropical combination with c={c}):")
    print(f)
    
    coeffs = residuated_coefficients(K, f)
    print(f"\nResiduated coefficients: {coeffs}")
    
    support = find_minimal_support(K, f)
    print(f"Minimal support: {support}")
    print(f"Support size: {len(support)} (≤ rank 2)")
    
    pred = tropical_predictor(K, f, support)
    print(f"Reconstructed: {pred}")
    print(f"Exact: {np.allclose(pred, f)}")
    print(f"Antichain: {is_antichain(K, f, support)}")


def demo_gram_reconstruction():
    """
    Demo 3: Reconstruction from tropical Gram matrix.
    
    Given only the Gram matrix (kernel evaluations), reconstruct
    minimal prototype predictors for various target functions.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Reconstruction from Gram Matrix")
    print("=" * 60)
    
    n = 6
    np.random.seed(42)
    phi = np.random.randn(n, 3) * 2  # rank-3 features
    K = make_kernel_from_features(phi)
    
    print(f"Kernel matrix (rank-3 features, n={n}):")
    np.set_printoptions(precision=2)
    print(K)
    
    # Test several kernel sections
    for target_x in [0, 2, 5]:
        f = K[target_x, :]
        support = find_minimal_support(K, f)
        pred = tropical_predictor(K, f, support)
        exact = np.allclose(pred, f)
        antichain = is_antichain(K, f, support)
        
        print(f"\n  K_{target_x}: support={support}, "
              f"|support|={len(support)}, "
              f"exact={exact}, antichain={antichain}")
    
    # Test a general function in the span
    c = np.array([1.0, 0.0, -0.5, 0.5, -1.0, 0.0])
    f = np.full(n, -np.inf)
    for x in range(n):
        f = np.maximum(f, c[x] + K[x, :])
    
    support = find_minimal_support(K, f)
    pred = tropical_predictor(K, f, support)
    exact = np.allclose(pred, f)
    antichain = is_antichain(K, f, support)
    
    print(f"\n  General f: support={support}, "
          f"|support|={len(support)} ≤ rank=3, "
          f"exact={exact}, antichain={antichain}")


def demo_residuation_optimality():
    """
    Demo 4: Residuation optimality — the residuated coefficient is
    the BEST possible coefficient.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Residuation Optimality")
    print("=" * 60)
    
    n = 4
    phi = np.array([[2.0, 1.0], [1.0, 3.0], [2.5, 2.0], [0.5, 2.5]])
    K = make_kernel_from_features(phi)
    f = K[0, :]  # Target: kernel section at 0
    
    print(f"K = {K}")
    print(f"f = K_0 = {f}")
    
    for x in range(n):
        res_c = residuated_coefficient(K, f, x)
        print(f"\n  x={x}: residuated coeff = {res_c:.4f}")
        
        # Verify it's a valid lower bound
        gaps = f - (res_c + K[x, :])
        print(f"    Lower bound gaps (all ≥ 0): {gaps}")
        assert np.all(gaps >= -1e-10), "Lower bound violated!"
        
        # Verify it's tight somewhere
        tight_at = np.argmin(gaps)
        print(f"    Tight at y={tight_at}: gap = {gaps[tight_at]:.6f}")
        
        # Verify optimality: any larger c violates the bound
        test_c = res_c + 0.1
        violations = f - (test_c + K[x, :])
        violated = np.any(violations < -1e-10)
        print(f"    c+0.1 = {test_c:.4f} violates bound: {violated}")


if __name__ == "__main__":
    demo_rank1_kernel()
    demo_rank2_kernel()
    demo_gram_reconstruction()
    demo_residuation_optimality()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import base64
from pathlib import Path

# Read all markdown files
article = Path('/workspace/request-project/ARTICLE.md').read_text()
research_paper = Path('/workspace/request-project/RESEARCH_PAPER.md').read_text()
future_directions = Path('/workspace/request-project/FUTURE_DIRECTIONS.md').read_text()

# Read code files
demo_code = Path('/workspace/request-project/demo.py').read_text()
algorithms_code = Path('/workspace/request-project/algorithms.py').read_text()
applications_code = Path('/workspace/request-project/applications.py').read_text()

# Read Lean file
lean_code = Path('/workspace/request-project/Bridges/AlgebraTropicalMachineLearning/TropicalKernelMeanDuality.lean').read_text()

# Read visualization base64 data
def img_to_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

viz1 = img_to_base64('/workspace/request-project/viz_kernel_residuation.png')
viz2 = img_to_base64('/workspace/request-project/viz_support_selection.png')
viz3 = img_to_base64('/workspace/request-project/viz_rank_support.png')
viz4 = img_to_base64('/workspace/request-project/viz_residuation.png')

package = {
    "title": "Tropical Kernel Mean Duality via Idempotent RKHS Semimodules and Certified Support Prototype Reconstruction",
    "domain": "Algebra–Tropical–MachineLearning (Bridges)",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Kernel Duality Demonstrations",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Residuated Coefficient Computation",
            "pseudocode": "res(K, f, x) = min_{y in X} (f(y) - K(x, y))\n\nFor each y in X:\n  c = min(c, f[y] - K[x, y])\nreturn c\n\nTime: O(n), Space: O(1)",
            "code": algorithms_code
        },
        {
            "name": "Greedy Minimal Support Extraction",
            "pseudocode": "S = {0, ..., n-1}\nfor x = 0 to n-1:\n  S' = S \\ {x}\n  if reconstruct(K, f, S') ≈ f:\n    S = S'\nreturn S\n\nTime: O(n^3), Space: O(n^2)",
            "code": "# See algorithms.py for full implementation"
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Kernel Matrix and Residuated Coefficients",
            "data": viz1
        },
        {
            "name": "Support Prototype Selection Across Kernel Sections",
            "data": viz2
        },
        {
            "name": "Feature Rank vs Support Size Analysis",
            "data": viz3
        },
        {
            "name": "Residuation Landscape and Galois Connection",
            "data": viz4
        }
    ],
    "lean_proofs": lean_code
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated: {Path('/workspace/request-project/PACKAGE.json').stat().st_size / 1024:.0f} KB")


#!/usr/bin/env python3
"""
Tropical Kernel Mean Duality — Visualizations

Generates publication-quality figures illustrating:
1. Tropical kernel matrix heatmaps
2. Residuated coefficient landscapes
3. Support prototype selection
4. Feature rank decomposition
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from algorithms import (
    TropicalKernel, certified_decomposition,
    compute_all_residuated_coefficients, reconstruct_from_support,
    greedy_minimal_support, estimate_feature_rank
)
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_kernel_and_residuation():
    """
    Visualization 1: Tropical kernel matrix and residuated coefficients.
    """
    np.random.seed(42)
    phi = np.array([
        [3.0, 1.0],
        [1.0, 4.0],
        [2.5, 2.5],
        [0.0, 3.0],
        [2.0, 0.5],
        [1.5, 3.5],
    ])
    K = TropicalKernel.from_features(phi)
    f = K.section(0)
    coeffs = compute_all_residuated_coefficients(K, f)
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    
    # Kernel matrix
    im0 = axes[0].imshow(K.matrix, cmap='YlOrRd', aspect='equal')
    axes[0].set_title('Tropical Kernel Matrix K', fontsize=13, fontweight='bold')
    axes[0].set_xlabel('y')
    axes[0].set_ylabel('x')
    plt.colorbar(im0, ax=axes[0], shrink=0.8)
    for i in range(K.n):
        for j in range(K.n):
            axes[0].text(j, i, f'{K.matrix[i,j]:.1f}',
                        ha='center', va='center', fontsize=8)
    
    # Residuated coefficients
    colors = ['#e74c3c' if c == max(coeffs) else '#3498db' for c in coeffs]
    axes[1].bar(range(K.n), coeffs, color=colors, edgecolor='black', linewidth=0.5)
    axes[1].set_title('Residuated Coefficients for K₀', fontsize=13, fontweight='bold')
    axes[1].set_xlabel('Support element x')
    axes[1].set_ylabel('res(K, K₀, x)')
    axes[1].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    
    # Reconstruction quality
    support = greedy_minimal_support(K, f)
    pred = reconstruct_from_support(K, f, support)
    
    x_pos = np.arange(K.n)
    width = 0.35
    axes[2].bar(x_pos - width/2, f, width, label='Original f = K₀',
               color='#2ecc71', edgecolor='black', linewidth=0.5)
    axes[2].bar(x_pos + width/2, pred, width, label=f'Reconstructed (|S|={len(support)})',
               color='#e67e22', edgecolor='black', linewidth=0.5)
    axes[2].set_title('Prototype Reconstruction', fontsize=13, fontweight='bold')
    axes[2].set_xlabel('Point y')
    axes[2].set_ylabel('Function value')
    axes[2].legend(fontsize=9)
    
    fig.suptitle('Tropical Kernel Mean Duality — Core Objects',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_kernel_residuation.png',
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_support_selection():
    """
    Visualization 2: Support prototype selection across different targets.
    """
    np.random.seed(42)
    phi = np.random.randn(10, 3) * 1.5
    K = TropicalKernel.from_features(phi)
    
    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    
    targets = [0, 2, 5, 7, 9]
    
    for idx, target in enumerate(targets):
        ax = axes[idx // 3][idx % 3]
        f = K.section(target)
        decomp = certified_decomposition(K, f)
        pred = reconstruct_from_support(K, f, decomp.support)
        
        x_pos = np.arange(K.n)
        ax.bar(x_pos, f, alpha=0.6, color='#3498db', label='Target',
              edgecolor='black', linewidth=0.5)
        ax.bar(x_pos, pred, alpha=0.4, color='#e74c3c', label='Reconstruction',
              edgecolor='black', linewidth=0.5)
        
        for s in decomp.support:
            ax.axvline(x=s, color='#2ecc71', linestyle='--', alpha=0.7, linewidth=2)
        
        ax.set_title(f'K_{target}: support={decomp.support}\n'
                    f'|S|={len(decomp.support)}, '
                    f'antichain={decomp.is_antichain}',
                    fontsize=10)
        ax.set_xlabel('Point')
        ax.set_ylabel('Value')
        if idx == 0:
            ax.legend(fontsize=8)
    
    # Summary statistics in last subplot
    ax = axes[1][2]
    support_sizes = []
    for x in range(K.n):
        f = K.section(x)
        decomp = certified_decomposition(K, f)
        support_sizes.append(len(decomp.support))
    
    ax.bar(range(K.n), support_sizes, color='#9b59b6',
          edgecolor='black', linewidth=0.5)
    ax.axhline(y=K.rank, color='red', linestyle='--', linewidth=2,
              label=f'Feature rank = {K.rank}')
    ax.set_title('Support Size per Section', fontsize=10)
    ax.set_xlabel('Section index')
    ax.set_ylabel('|Support|')
    ax.legend(fontsize=9)
    
    fig.suptitle('Tropical Prototype Selection Across Kernel Sections',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_support_selection.png',
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_rank_vs_support():
    """
    Visualization 3: Feature rank vs average support size.
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    n = 15
    ranks = list(range(1, 8))
    avg_supports = []
    max_supports = []
    
    for r in ranks:
        np.random.seed(42)
        phi = np.random.randn(n, r)
        K = TropicalKernel.from_features(phi)
        
        sizes = []
        for x in range(n):
            f = K.section(x)
            support = greedy_minimal_support(K, f)
            sizes.append(len(support))
        
        avg_supports.append(np.mean(sizes))
        max_supports.append(np.max(sizes))
    
    axes[0].plot(ranks, avg_supports, 'o-', color='#3498db',
                linewidth=2, markersize=8, label='Avg support size')
    axes[0].plot(ranks, max_supports, 's--', color='#e74c3c',
                linewidth=2, markersize=8, label='Max support size')
    axes[0].plot(ranks, ranks, ':', color='gray', linewidth=1.5,
                label='y = rank (upper bound)')
    axes[0].set_xlabel('Feature Rank r', fontsize=12)
    axes[0].set_ylabel('Support Size |S|', fontsize=12)
    axes[0].set_title('Support Size vs Feature Rank', fontsize=13, fontweight='bold')
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3)
    
    # Antichain verification rate
    antichain_rates = []
    for r in ranks:
        np.random.seed(42)
        phi = np.random.randn(n, r)
        K = TropicalKernel.from_features(phi)
        
        total = 0
        antichain_count = 0
        for x in range(n):
            f = K.section(x)
            decomp = certified_decomposition(K, f)
            total += 1
            if decomp.is_antichain:
                antichain_count += 1
        
        antichain_rates.append(antichain_count / total)
    
    axes[1].bar(ranks, antichain_rates, color='#2ecc71',
               edgecolor='black', linewidth=0.5)
    axes[1].set_xlabel('Feature Rank r', fontsize=12)
    axes[1].set_ylabel('Antichain Rate', fontsize=12)
    axes[1].set_title('Fraction of Supports that are Antichains',
                      fontsize=13, fontweight='bold')
    axes[1].set_ylim(0, 1.1)
    axes[1].grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Feature Rank Duality — Empirical Analysis',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_rank_support.png',
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_residuation_landscape():
    """
    Visualization 4: Residuation landscape showing the Galois connection.
    """
    np.random.seed(42)
    phi = np.array([[3, 1], [1, 4], [2.5, 2.5], [0, 3], [2, 0.5]])
    K = TropicalKernel.from_features(phi)
    f = K.section(0)
    
    fig, axes = plt.subplots(1, 2, figsize=(13, 5))
    
    # Show contribution of each element
    coeffs = compute_all_residuated_coefficients(K, f)
    
    x_pos = np.arange(K.n)
    for xi in range(K.n):
        contribution = coeffs[xi] + K.matrix[xi, :]
        axes[0].plot(x_pos, contribution, 'o--', label=f'x={xi} (c={coeffs[xi]:.1f})',
                    alpha=0.7, markersize=6)
    
    axes[0].plot(x_pos, f, 'ks-', linewidth=2.5, markersize=10,
                label='Target f', zorder=10)
    axes[0].set_xlabel('Point y', fontsize=12)
    axes[0].set_ylabel('Value', fontsize=12)
    axes[0].set_title('Residuated Contributions\n(f bounds each contribution from above)',
                      fontsize=12, fontweight='bold')
    axes[0].legend(fontsize=8, loc='lower left')
    axes[0].grid(True, alpha=0.3)
    
    # Show the "gap" landscape
    gaps = np.zeros((K.n, K.n))
    for xi in range(K.n):
        gaps[xi, :] = f - (coeffs[xi] + K.matrix[xi, :])
    
    im = axes[1].imshow(gaps, cmap='RdYlGn_r', aspect='auto')
    axes[1].set_xlabel('Point y', fontsize=12)
    axes[1].set_ylabel('Support element x', fontsize=12)
    axes[1].set_title('Residuation Gap\n(green = 0 = tight; red = loose)',
                      fontsize=12, fontweight='bold')
    plt.colorbar(im, ax=axes[1], shrink=0.8, label='f(y) - (c_x + K(x,y))')
    
    for i in range(K.n):
        for j in range(K.n):
            axes[1].text(j, i, f'{gaps[i,j]:.1f}',
                        ha='center', va='center', fontsize=8,
                        color='white' if gaps[i,j] > 1 else 'black')
    
    fig.suptitle('Tropical Residuation: The Galois Connection at Work',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_residuation.png',
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = viz_kernel_and_residuation()
    print(f"  1. Kernel & residuation: {len(b64_1)} chars")
    
    b64_2 = viz_support_selection()
    print(f"  2. Support selection: {len(b64_2)} chars")
    
    b64_3 = viz_rank_vs_support()
    print(f"  3. Rank vs support: {len(b64_3)} chars")
    
    b64_4 = viz_residuation_landscape()
    print(f"  4. Residuation landscape: {len(b64_4)} chars")
    
    print("\nAll visualizations saved to PNG files.")
    print("Base64 data URIs available for JSON packaging.")

#!/usr/bin/env python3
"""
Tropical Polynomial Pruning: Algorithms

Implements the core algorithms from the tropical pruning framework,
including canonical pruning, active template extraction, and compression
analysis.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass, field


@dataclass
class AffineTemplate:
    """An affine function template: x ↦ bias + weight · x

    Attributes:
        bias: Constant offset
        weight: Linear coefficients
        label: Optional human-readable name
    """
    bias: float
    weight: np.ndarray
    label: str = ""

    def eval(self, x: np.ndarray) -> float:
        """Evaluate the affine template at point x."""
        return self.bias + np.dot(self.weight, x)

    def eval_batch(self, X: np.ndarray) -> np.ndarray:
        """Evaluate on a batch of points (rows of X).

        Args:
            X: Array of shape (N, n) where n is the dimension

        Returns:
            Array of shape (N,) with evaluations
        """
        return self.bias + X @ self.weight


@dataclass
class TropicalPolynomial:
    """A tropical polynomial: max over affine templates.

    Represents f(x) = max_{m ∈ support} m(x) where each m is affine.

    Attributes:
        templates: List of affine templates
    """
    templates: List[AffineTemplate]

    def eval(self, x: np.ndarray) -> float:
        """Evaluate the tropical polynomial at a single point."""
        return max(t.eval(x) for t in self.templates)

    def eval_batch(self, X: np.ndarray) -> np.ndarray:
        """Evaluate on a batch of points.

        Args:
            X: Array of shape (N, n)

        Returns:
            Array of shape (N,) with max evaluations
        """
        vals = np.stack([t.eval_batch(X) for t in self.templates], axis=1)
        return np.max(vals, axis=1)

    def active_template_indices(self, x: np.ndarray, tol: float = 1e-12) -> List[int]:
        """Return indices of templates achieving the max at x."""
        v = self.eval(x)
        return [i for i, t in enumerate(self.templates)
                if abs(t.eval(x) - v) < tol]

    @property
    def size(self) -> int:
        return len(self.templates)


def strictly_dominates(m: AffineTemplate, m_prime: AffineTemplate,
                       domain: np.ndarray, tol: float = 1e-12) -> bool:
    """Check if m is strictly dominated by m_prime on domain.

    Strict domination: m ≤ m' everywhere, m < m' somewhere.

    Args:
        m: Potentially dominated template
        m_prime: Potential dominator
        domain: Array of shape (N, n) with domain points as rows
        tol: Numerical tolerance

    Returns:
        True if m_prime strictly dominates m on the domain

    Time complexity: O(N * n) where N = |domain|, n = dimension
    """
    diffs = m_prime.eval_batch(domain) - m.eval_batch(domain)
    return np.all(diffs >= -tol) and np.any(diffs > tol)


def canonical_pruning(poly: TropicalPolynomial,
                      domain: np.ndarray) -> TropicalPolynomial:
    """Algorithm 1: Canonical Pruning

    Remove all strictly dominated templates from the polynomial.

    Args:
        poly: Input tropical polynomial
        domain: Array of shape (N, n) with domain points

    Returns:
        Pruned tropical polynomial with same evaluation on domain

    Time complexity: O(k² * N * n) where k = |support|
    Space complexity: O(k * N)

    Correctness: Guaranteed by Theorem A (canonicalOn_eval_eq)
    """
    survivors = []
    for i, m in enumerate(poly.templates):
        dominated = False
        for j, m_prime in enumerate(poly.templates):
            if i == j:
                continue
            if strictly_dominates(m, m_prime, domain):
                dominated = True
                break
        if not dominated:
            survivors.append(m)

    if not survivors:
        return poly  # fallback for degenerate case
    return TropicalPolynomial(survivors)


def extract_active_regions(poly: TropicalPolynomial,
                           domain: np.ndarray,
                           tol: float = 1e-12) -> Dict[int, List[int]]:
    """Algorithm 2: Active Region Extraction

    For each template, find the domain points where it achieves the max.

    Args:
        poly: Tropical polynomial
        domain: Array of shape (N, n)
        tol: Numerical tolerance

    Returns:
        Dictionary mapping template index → list of domain point indices
        where that template is active (achieves the max)

    Time complexity: O(k * N * n)
    """
    all_vals = np.stack([t.eval_batch(domain) for t in poly.templates], axis=1)
    max_vals = np.max(all_vals, axis=1, keepdims=True)
    is_active = np.abs(all_vals - max_vals) < tol

    regions = {}
    for i in range(len(poly.templates)):
        active_points = list(np.where(is_active[:, i])[0])
        if active_points:
            regions[i] = active_points
    return regions


def compute_compression_ratio(poly: TropicalPolynomial,
                              domain: np.ndarray) -> float:
    """Compute the compression ratio achieved by canonical pruning.

    Returns:
        Ratio canonical_size / original_size (smaller = more compression)
    """
    pruned = canonical_pruning(poly, domain)
    return pruned.size / poly.size


def greedy_essential_extraction(poly: TropicalPolynomial,
                                domain: np.ndarray,
                                tol: float = 1e-12) -> TropicalPolynomial:
    """Algorithm 3: Greedy Essential Template Extraction

    Iteratively select templates that cover the most uncovered domain points.
    This finds a minimal (or near-minimal) set of essential templates.

    Args:
        poly: Tropical polynomial
        domain: Array of shape (N, n)
        tol: Numerical tolerance

    Returns:
        Reduced polynomial covering all domain points

    Time complexity: O(k * N * n * k) worst case
    """
    N = domain.shape[0]
    all_vals = np.stack([t.eval_batch(domain) for t in poly.templates], axis=1)
    max_vals = np.max(all_vals, axis=1)

    uncovered = set(range(N))
    selected = []

    while uncovered:
        best_idx = -1
        best_coverage = -1

        for i, t in enumerate(poly.templates):
            if i in [s[0] for s in selected]:
                continue
            coverage = sum(1 for j in uncovered
                          if abs(t.eval(domain[j]) - max_vals[j]) < tol)
            if coverage > best_coverage:
                best_coverage = coverage
                best_idx = i

        if best_idx < 0 or best_coverage == 0:
            break

        selected.append((best_idx, poly.templates[best_idx]))
        # Remove covered points
        uncovered = {j for j in uncovered
                     if abs(poly.templates[best_idx].eval(domain[j]) - max_vals[j]) >= tol}

    return TropicalPolynomial([t for _, t in selected])


def relu_to_tropical(weights: np.ndarray, biases: np.ndarray) -> TropicalPolynomial:
    """Convert a single-layer ReLU/max-affine network to a tropical polynomial.

    A single-layer max-affine network computes:
        f(x) = max_i (w_i · x + b_i)

    This is exactly a tropical polynomial.

    Args:
        weights: Array of shape (k, n) — weight vectors
        biases: Array of shape (k,) — bias terms

    Returns:
        Equivalent tropical polynomial
    """
    templates = []
    for i in range(weights.shape[0]):
        templates.append(AffineTemplate(
            bias=float(biases[i]),
            weight=weights[i].copy(),
            label=f"neuron_{i}"
        ))
    return TropicalPolynomial(templates)


def tropical_complexity(poly: TropicalPolynomial,
                        domain: np.ndarray) -> int:
    """Compute the tropical explanation complexity of a polynomial on a domain.

    This is the size of the canonical support — the minimum number of
    affine templates needed to represent the function exactly on the domain.

    Args:
        poly: Tropical polynomial
        domain: Array of shape (N, n)

    Returns:
        Number of canonical (non-dominated) templates
    """
    return canonical_pruning(poly, domain).size


# ============================================================
# Example usage and verification
# ============================================================

if __name__ == "__main__":
    np.random.seed(42)

    print("Tropical Pruning Algorithms — Example Usage")
    print("=" * 60)

    # Create a max-affine network
    n_dim = 3
    k_neurons = 10
    weights = np.random.randn(k_neurons, n_dim)
    biases = np.random.randn(k_neurons)

    poly = relu_to_tropical(weights, biases)
    domain = np.random.randn(100, n_dim)

    print(f"\nInput: {poly.size}-template tropical polynomial in {n_dim}D")
    print(f"Domain: {domain.shape[0]} points")

    # Canonical pruning
    pruned = canonical_pruning(poly, domain)
    print(f"\nCanonical pruning: {poly.size} → {pruned.size} templates")
    print(f"Compression ratio: {pruned.size/poly.size:.1%}")

    # Verify preservation
    orig_vals = poly.eval_batch(domain)
    pruned_vals = pruned.eval_batch(domain)
    max_error = np.max(np.abs(orig_vals - pruned_vals))
    print(f"Max evaluation error: {max_error:.2e}")

    # Active regions
    regions = extract_active_regions(pruned, domain)
    print(f"\nActive regions for {len(regions)} surviving templates:")
    for idx, points in sorted(regions.items()):
        print(f"  Template {idx}: active at {len(points)} domain points")

    # Tropical complexity
    tc = tropical_complexity(poly, domain)
    print(f"\nTropical explanation complexity: {tc}")

    # Greedy extraction
    greedy = greedy_essential_extraction(poly, domain)
    print(f"Greedy essential extraction: {greedy.size} templates")

    print("\n✓ All algorithms completed successfully")

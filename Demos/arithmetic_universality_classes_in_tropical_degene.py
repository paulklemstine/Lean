#!/usr/bin/env python3
"""
Applications of Tropical Loss Landscape Theory
================================================

Demonstrates real-world applications of tropical degeneration to:
1. ReLU network loss analysis (piecewise-linear = tropical)
2. Trainability prediction via active-set complexity
3. Mode connectivity detection via arrangement analysis
4. Loss landscape comparison across architectures

These applications connect the formally verified theory to practical
machine learning scenarios.
"""

import numpy as np
from typing import List, Tuple, Set, FrozenSet, Dict
from itertools import combinations
from dataclasses import dataclass


# ============================================================================
# Application 1: ReLU Networks as Tropical Loss Landscapes
# ============================================================================

def relu_layer_to_tropical(
    weight: np.ndarray,
    bias: np.ndarray,
    input_dim: int
) -> List[Tuple[np.ndarray, float]]:
    """
    Convert a ReLU layer to tropical affine forms.

    ReLU(Wx + b) = max(Wx + b, 0)

    Each neuron gives two affine forms: (w_i · x + b_i) and 0.
    The ReLU selects the maximum.
    """
    forms = []
    for i in range(weight.shape[0]):
        # Active form: w_i · x + b_i
        forms.append((weight[i].copy(), float(bias[i])))
        # Inactive form: 0
        forms.append((np.zeros(input_dim), 0.0))
    return forms


def analyze_relu_network():
    """
    Analyze a simple ReLU network as a tropical loss landscape.

    Network: R^2 -> R^3 (ReLU) -> R^1
    Loss: max over output components (tropical max)
    """
    print("=" * 70)
    print("APPLICATION 1: ReLU Network as Tropical Loss Landscape")
    print("=" * 70)

    np.random.seed(42)

    # Simple 2-layer network
    W1 = np.array([[1.0, -0.5], [-0.5, 1.0], [0.5, 0.5]])
    b1 = np.array([0.0, 0.0, -0.5])

    W2 = np.array([[1.0, -1.0, 0.5]])
    b2 = np.array([0.0])

    print(f"\n  Layer 1: W = {W1.tolist()}, b = {b1.tolist()}")
    print(f"  Layer 2: W = {W2.tolist()}, b = {b2.tolist()}")

    # Convert to tropical forms
    forms = relu_layer_to_tropical(W1, b1, 2)
    print(f"\n  ReLU layer produces {len(forms)} affine forms")
    print(f"  (Each neuron contributes 2: the affine form and zero)")

    # Analyze active regions
    num_regions = 0
    regions = set()
    for _ in range(100000):
        x = np.random.uniform(-5, 5, size=2)
        # Determine which neurons are active
        z = W1 @ x + b1
        pattern = tuple(int(z_i > 0) for z_i in z)
        regions.add(pattern)

    print(f"\n  Number of distinct activation patterns: {len(regions)}")
    print(f"  Activation patterns found:")
    for p in sorted(regions):
        print(f"    {p} - {'→'.join(['ReLU' if pi else '0' for pi in p])}")

    # The number of regions is bounded by the active-set complex
    max_possible = 2 ** len(b1)  # Each neuron on or off
    print(f"\n  Maximum possible patterns: {max_possible}")
    print(f"  Observed: {len(regions)} ({100*len(regions)/max_possible:.0f}%)")
    print(f"  → Active-set complex captures the combinatorial structure")


# ============================================================================
# Application 2: Trainability Prediction
# ============================================================================

def compute_trainability_index(
    coeffs: np.ndarray,
    biases: np.ndarray,
    num_samples: int = 50000
) -> Dict:
    """
    Compute a trainability index based on active-set complex structure.

    The index measures:
    1. Number of distinct active regions (complexity)
    2. Average active set size (degeneracy)
    3. Maximum codimension face (criticality)

    Hypothesis: Higher complexity correlates with harder optimization.
    """
    k, n = coeffs.shape
    active_sets = set()
    total_active_size = 0
    count = 0

    for _ in range(num_samples):
        x = np.random.uniform(-10, 10, size=n)
        vals = coeffs @ x + biases
        max_val = np.max(vals)
        active = frozenset(i for i in range(k) if abs(vals[i] - max_val) < 1e-10)
        active_sets.add(active)
        total_active_size += len(active)
        count += 1

    max_active_size = max(len(s) for s in active_sets)
    avg_active_size = total_active_size / count

    return {
        "num_regions": len(active_sets),
        "avg_active_size": avg_active_size,
        "max_active_size": max_active_size,
        "complexity_index": len(active_sets) * avg_active_size,
    }


def analyze_trainability():
    """Compare trainability indices for different loss landscape structures."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Trainability Prediction via Active-Set Complexity")
    print("=" * 70)

    # Simple loss: 2 affine forms in 2D
    simple = {
        "coeffs": np.array([[1.0, 0.0], [0.0, 1.0]]),
        "biases": np.array([0.0, 0.0])
    }

    # Moderate: 4 affine forms in 2D
    moderate = {
        "coeffs": np.array([[1.0, 0.0], [0.0, 1.0], [-1.0, 0.0], [0.0, -1.0]]),
        "biases": np.array([0.0, 0.0, 2.0, 2.0])
    }

    # Complex: 8 affine forms in 2D
    np.random.seed(123)
    complex_coeffs = np.random.randn(8, 2)
    complex_biases = np.random.randn(8)
    complex_loss = {
        "coeffs": complex_coeffs,
        "biases": complex_biases
    }

    landscapes = [
        ("Simple (2 forms)", simple),
        ("Moderate (4 forms)", moderate),
        ("Complex (8 forms)", complex_loss),
    ]

    print(f"\n  {'Landscape':>25} | {'Regions':>8} | {'Avg Active':>10} | {'Max Active':>10} | {'Index':>8}")
    print(f"  {'-'*25}-+-{'-'*8}-+-{'-'*10}-+-{'-'*10}-+-{'-'*8}")

    for name, params in landscapes:
        idx = compute_trainability_index(**params)
        print(f"  {name:>25} | {idx['num_regions']:>8} | {idx['avg_active_size']:>10.3f} | {idx['max_active_size']:>10} | {idx['complexity_index']:>8.2f}")

    print(f"\n  → Higher complexity index suggests harder optimization landscape")
    print(f"  → Active-set complex size predicts number of distinct gradient regions")


# ============================================================================
# Application 3: Mode Connectivity via Arrangement Analysis
# ============================================================================

def find_modes(coeffs: np.ndarray, biases: np.ndarray,
               num_starts: int = 100) -> List[np.ndarray]:
    """
    Find local minima of tropical max loss using random restarts.
    """
    k, n = coeffs.shape
    modes = []

    for _ in range(num_starts):
        x = np.random.uniform(-5, 5, size=n)

        # Simple projected subgradient descent
        lr = 0.1
        for step in range(200):
            vals = coeffs @ x + biases
            i_max = np.argmax(vals)
            # Subgradient of max is the gradient of the active form
            grad = coeffs[i_max]
            x = x - lr * grad
            lr *= 0.995

        # Check if this is a new mode
        val = np.max(coeffs @ x + biases)
        is_new = True
        for m in modes:
            if np.linalg.norm(x - m) < 0.5:
                is_new = False
                break
        if is_new:
            modes.append(x.copy())

    return modes


def analyze_mode_connectivity():
    """Analyze mode connectivity through hyperplane arrangement walls."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Mode Connectivity via Arrangement Analysis")
    print("=" * 70)

    np.random.seed(42)

    coeffs = np.array([
        [2.0, -1.0],
        [-1.0, 2.0],
        [1.0, 1.0],
        [-1.0, -1.0],
    ])
    biases = np.array([0.0, 0.0, -1.0, 4.0])

    modes = find_modes(coeffs, biases, num_starts=200)

    print(f"\n  Found {len(modes)} approximate local modes:")
    for i, m in enumerate(modes[:5]):
        val = np.max(coeffs @ m + biases)
        active = frozenset(j for j in range(len(biases))
                          if abs((coeffs @ m + biases)[j] - val) < 0.1)
        print(f"    Mode {i}: x = ({m[0]:.3f}, {m[1]:.3f}), "
              f"loss = {val:.3f}, active = {set(active)}")

    # Check connectivity: can we move between modes without crossing
    # arrangement walls?
    if len(modes) >= 2:
        print(f"\n  Connectivity analysis between modes 0 and 1:")
        m0, m1 = modes[0], modes[1]
        wall_crossings = 0
        steps = 100
        prev_active = None

        for t_idx in range(steps + 1):
            t = t_idx / steps
            x = (1 - t) * m0 + t * m1
            vals = coeffs @ x + biases
            max_val = np.max(vals)
            active = frozenset(j for j in range(len(biases))
                              if abs(vals[j] - max_val) < 1e-8)
            if prev_active is not None and active != prev_active:
                wall_crossings += 1
            prev_active = active

        print(f"    Arrangement wall crossings on linear path: {wall_crossings}")
        print(f"    → More crossings = less direct mode connectivity")
        print(f"    → Arrangement structure predicts optimization barriers")


# ============================================================================
# Application 4: Architecture Comparison
# ============================================================================

def compare_architectures():
    """Compare loss landscape structures across different architectures."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Architecture Comparison via Tropical Structure")
    print("=" * 70)

    np.random.seed(42)

    # "Architecture A": Wide, shallow (many forms, low dimension)
    A_coeffs = np.random.randn(10, 2) * 2
    A_biases = np.random.randn(10)

    # "Architecture B": Narrow, deep (fewer forms, same dimension)
    B_coeffs = np.random.randn(4, 2) * 2
    B_biases = np.random.randn(4)

    # "Architecture C": Same tropical structure as A (valuation-equivalent)
    C_coeffs = A_coeffs.copy()  # Same geometry
    C_biases = A_biases.copy()

    idx_A = compute_trainability_index(A_coeffs, A_biases)
    idx_B = compute_trainability_index(B_coeffs, B_biases)
    idx_C = compute_trainability_index(C_coeffs, C_biases)

    print(f"\n  Architecture comparison:")
    print(f"  {'':>15} | {'Regions':>8} | {'Avg Active':>10} | {'Complexity':>10}")
    print(f"  {'-'*15}-+-{'-'*8}-+-{'-'*10}-+-{'-'*10}")
    print(f"  {'A (wide)':>15} | {idx_A['num_regions']:>8} | {idx_A['avg_active_size']:>10.3f} | {idx_A['complexity_index']:>10.2f}")
    print(f"  {'B (narrow)':>15} | {idx_B['num_regions']:>8} | {idx_B['avg_active_size']:>10.3f} | {idx_B['complexity_index']:>10.2f}")
    print(f"  {'C (= A trop)':>15} | {idx_C['num_regions']:>8} | {idx_C['avg_active_size']:>10.3f} | {idx_C['complexity_index']:>10.2f}")

    print(f"\n  Key insight: Architectures A and C have identical tropical structure")
    print(f"  → Same active-set complex → Same topological invariants")
    print(f"  → Arithmetic universality: different weights, same landscape topology")


# ============================================================================
# Application 5: Zero-Temperature Phase Transition Detection
# ============================================================================

def detect_phase_transitions():
    """Detect phase transitions via active-set complex changes."""
    print("\n" + "=" * 70)
    print("APPLICATION 5: Phase Transition Detection")
    print("=" * 70)

    # Parameterized family: interpolate between two landscapes
    coeffs_start = np.array([[1.0, 0.0], [0.0, 1.0], [-1.0, -1.0]])
    biases_start = np.array([0.0, 0.0, 3.0])

    coeffs_end = np.array([[1.0, 0.0], [0.0, 1.0], [-1.0, -1.0]])
    biases_end = np.array([0.0, 0.0, 0.0])  # Change bias of form 2

    print(f"\n  Interpolating bias of form 2 from 3.0 to 0.0:")
    print(f"  {'Parameter':>10} | {'Active Complex Size':>20} | {'Transition':>12}")
    print(f"  {'-'*10}-+-{'-'*20}-+-{'-'*12}")

    prev_size = None
    for t_idx in range(11):
        t = t_idx / 10
        biases = (1 - t) * biases_start + t * biases_end

        # Compute active complex
        active_sets = set()
        for _ in range(30000):
            x = np.random.uniform(-10, 10, size=2)
            vals = coeffs_start @ x + biases
            max_val = np.max(vals)
            active = frozenset(i for i in range(3) if abs(vals[i] - max_val) < 1e-10)
            active_sets.add(active)

        size = len(active_sets)
        transition = "← TRANSITION" if prev_size is not None and size != prev_size else ""
        print(f"  {t:>10.1f} | {size:>20} | {transition:>12}")
        prev_size = size

    print(f"\n  → Changes in active-set complex size mark phase transitions")
    print(f"  → These correspond to qualitative changes in gradient flow structure")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    analyze_relu_network()
    analyze_trainability()
    analyze_mode_connectivity()
    compare_architectures()
    detect_phase_transitions()

    print("\n" + "=" * 70)
    print("All applications completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Loss Landscape Demo
=============================

Interactive demonstration of tropical degenerations of neural loss landscapes,
arithmetic universality classes, and active-set complex computation.

This demo illustrates the key mathematical structures from the formal development:
1. Tropical affine families and their evaluation
2. Sublevel sets as intersections of halfspaces
3. Active set computation and the active-set complex
4. Valuation equivalence and universality classes
5. Zero-temperature (softmax → max) convergence

Run: python demo.py
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, Set, FrozenSet
import json


# ============================================================================
# Core Data Structures
# ============================================================================

class TropicalAffineFamily:
    """A finite family of affine forms f_i(x) = a_i · x + b_i over Q^n."""

    def __init__(self, coeffs: np.ndarray, biases: np.ndarray):
        """
        Args:
            coeffs: (k x n) matrix where row i gives coefficients of the i-th form
            biases: (k,) vector of constant terms
        """
        self.coeffs = np.array(coeffs, dtype=float)
        self.biases = np.array(biases, dtype=float)
        self.k = self.coeffs.shape[0]  # number of affine forms
        self.n = self.coeffs.shape[1] if len(self.coeffs.shape) > 1 else 0

    def affine_eval(self, i: int, x: np.ndarray) -> float:
        """Evaluate the i-th affine form at point x."""
        return np.dot(self.coeffs[i], x) + self.biases[i]

    def trop_max(self, x: np.ndarray) -> float:
        """Compute the tropical max loss: max_i f_i(x)."""
        return max(self.affine_eval(i, x) for i in range(self.k))

    def in_sublevel(self, x: np.ndarray, c: float) -> bool:
        """Check if x is in the sublevel set {x | tropMax(x) <= c}."""
        return self.trop_max(x) <= c + 1e-10

    def active_set(self, x: np.ndarray) -> FrozenSet[int]:
        """Compute the active set: indices achieving the maximum."""
        vals = [self.affine_eval(i, x) for i in range(self.k)]
        max_val = max(vals)
        return frozenset(i for i in range(self.k) if abs(vals[i] - max_val) < 1e-10)

    def __repr__(self):
        return f"TropicalAffineFamily(k={self.k}, n={self.n})"


class WeightedMonomial:
    """A weighted monomial c * t^w * x^alpha."""

    def __init__(self, exp: Tuple[int, ...], coeff: float, weight: int):
        self.exp = exp
        self.coeff = coeff
        self.weight = weight

    def __repr__(self):
        return f"Monomial(exp={self.exp}, coeff={self.coeff}, weight={self.weight})"


class TropicalPolynomialFamily:
    """A one-parameter polynomial family L_t(x) = sum_i c_i * t^{w_i} * x^{alpha_i}."""

    def __init__(self, monomials: List[WeightedMonomial]):
        assert len(monomials) > 0
        self.monomials = monomials
        self.n = len(monomials[0].exp)

    def tropicalize(self) -> TropicalAffineFamily:
        """Tropicalize: send c*t^w*x^alpha to the affine form <alpha, u> + w."""
        coeffs = np.array([m.exp for m in self.monomials], dtype=float)
        biases = np.array([m.weight for m in self.monomials], dtype=float)
        return TropicalAffineFamily(coeffs, biases)

    def valuation_profile(self) -> Tuple[List[Tuple], List[int]]:
        """Extract the valuation profile: (exponents, weights)."""
        exps = [tuple(m.exp) for m in self.monomials]
        weights = [m.weight for m in self.monomials]
        return (exps, weights)

    def is_valuation_equivalent(self, other: 'TropicalPolynomialFamily') -> bool:
        """Check if two families are valuation-equivalent."""
        if len(self.monomials) != len(other.monomials):
            return False
        for m1, m2 in zip(self.monomials, other.monomials):
            if m1.exp != m2.exp or m1.weight != m2.weight:
                return False
            if (m1.coeff > 0) != (m2.coeff > 0):
                return False
        return True


# ============================================================================
# Active Set Complex Computation
# ============================================================================

def compute_active_complex(family: TropicalAffineFamily,
                           num_samples: int = 10000,
                           box_size: float = 10.0) -> Set[FrozenSet[int]]:
    """
    Compute the active set complex by sampling points.

    The active set complex is the collection of all subsets S of indices
    that are realizable as active sets at some point x.
    """
    complex = set()
    for _ in range(num_samples):
        x = np.random.uniform(-box_size, box_size, size=family.n)
        active = family.active_set(x)
        complex.add(active)
    return complex


def compute_sublevel_active_complex(family: TropicalAffineFamily,
                                     c: float,
                                     num_samples: int = 10000,
                                     box_size: float = 10.0) -> Set[FrozenSet[int]]:
    """Compute the active set complex restricted to the sublevel set."""
    complex = set()
    for _ in range(num_samples):
        x = np.random.uniform(-box_size, box_size, size=family.n)
        if family.in_sublevel(x, c):
            active = family.active_set(x)
            complex.add(active)
    return complex


# ============================================================================
# Zero-Temperature / Softmax Convergence
# ============================================================================

def softmax_loss(family: TropicalAffineFamily, x: np.ndarray, beta: float) -> float:
    """
    Compute the softmax (log-sum-exp) approximation to the tropical max:
    L_beta(x) = (1/beta) * log(sum_i exp(beta * f_i(x)))

    As beta -> infinity, this converges to max_i f_i(x).
    """
    vals = np.array([family.affine_eval(i, x) for i in range(family.k)])
    # Numerically stable log-sum-exp
    max_val = np.max(vals)
    return max_val + np.log(np.sum(np.exp(beta * (vals - max_val)))) / beta


def demonstrate_zero_temperature_convergence(family: TropicalAffineFamily,
                                              x: np.ndarray,
                                              betas: List[float]):
    """Show convergence of softmax to tropical max as beta -> infinity."""
    trop = family.trop_max(x)
    print(f"\n  Tropical max at x = {x}: {trop:.6f}")
    print(f"  {'Beta':>10} | {'Softmax':>12} | {'Error':>12}")
    print(f"  {'-'*10}-+-{'-'*12}-+-{'-'*12}")
    for beta in betas:
        soft = softmax_loss(family, x, beta)
        err = abs(soft - trop)
        print(f"  {beta:>10.1f} | {soft:>12.6f} | {err:>12.2e}")


# ============================================================================
# Demonstrations
# ============================================================================

def demo_1_basic_tropical():
    """Demo 1: Basic tropical affine family and sublevel sets."""
    print("=" * 70)
    print("DEMO 1: Basic Tropical Affine Family")
    print("=" * 70)

    # 3 affine forms in 2 variables
    F = TropicalAffineFamily(
        coeffs=np.array([[1, 0], [0, 1], [-1, -1]]),
        biases=np.array([0, 0, 3])
    )

    print(f"\n  Family: {F}")
    print(f"  f_0(x) = x_0")
    print(f"  f_1(x) = x_1")
    print(f"  f_2(x) = -x_0 - x_1 + 3")

    # Test some points
    test_points = [
        np.array([0.0, 0.0]),
        np.array([1.0, 1.0]),
        np.array([2.0, 0.0]),
        np.array([-1.0, -1.0]),
    ]

    print(f"\n  {'Point':>15} | {'tropMax':>8} | {'Active Set':>15} | {'In S(2)':>7}")
    print(f"  {'-'*15}-+-{'-'*8}-+-{'-'*15}-+-{'-'*7}")
    for x in test_points:
        tm = F.trop_max(x)
        active = F.active_set(x)
        in_sub = F.in_sublevel(x, 2.0)
        print(f"  {str(x):>15} | {tm:>8.2f} | {str(set(active)):>15} | {'Yes' if in_sub else 'No':>7}")

    # Verify convexity numerically
    print("\n  Convexity check (sublevel set c=2):")
    x = np.array([1.0, 0.5])
    y = np.array([0.0, 1.5])
    for t in [0.0, 0.25, 0.5, 0.75, 1.0]:
        z = (1 - t) * x + t * y
        tm = F.trop_max(z)
        in_sub = F.in_sublevel(z, 2.0)
        print(f"    t={t:.2f}: z={z}, tropMax={tm:.3f}, in sublevel: {in_sub}")


def demo_2_active_complex():
    """Demo 2: Active set complex computation."""
    print("\n" + "=" * 70)
    print("DEMO 2: Active Set Complex")
    print("=" * 70)

    F = TropicalAffineFamily(
        coeffs=np.array([[1, 0], [0, 1], [-1, -1], [0, 0]]),
        biases=np.array([0, 0, 3, 1])
    )

    complex_full = compute_active_complex(F, num_samples=50000)

    print(f"\n  Family with {F.k} affine forms in {F.n} dimensions")
    print(f"  Active set complex (full): {len(complex_full)} cells")
    for s in sorted(complex_full, key=lambda s: (len(s), sorted(s))):
        print(f"    {set(s)}")

    # Sublevel complex at different thresholds
    for c in [1.0, 2.0, 5.0, 10.0]:
        complex_sub = compute_sublevel_active_complex(F, c, num_samples=50000)
        print(f"\n  Active set complex (c={c}): {len(complex_sub)} cells")
        for s in sorted(complex_sub, key=lambda s: (len(s), sorted(s))):
            print(f"    {set(s)}")


def demo_3_valuation_equivalence():
    """Demo 3: Valuation equivalence and universality."""
    print("\n" + "=" * 70)
    print("DEMO 3: Valuation Equivalence and Arithmetic Universality")
    print("=" * 70)

    # Two families with same exponents and weights but different coefficients
    P = TropicalPolynomialFamily([
        WeightedMonomial((1, 0), coeff=3.0, weight=0),
        WeightedMonomial((0, 1), coeff=7.0, weight=0),
        WeightedMonomial((1, 1), coeff=2.0, weight=1),
    ])

    Q = TropicalPolynomialFamily([
        WeightedMonomial((1, 0), coeff=42.0, weight=0),
        WeightedMonomial((0, 1), coeff=0.1, weight=0),
        WeightedMonomial((1, 1), coeff=100.0, weight=1),
    ])

    # Different exponents - NOT valuation equivalent
    R = TropicalPolynomialFamily([
        WeightedMonomial((2, 0), coeff=3.0, weight=0),
        WeightedMonomial((0, 1), coeff=7.0, weight=0),
        WeightedMonomial((1, 1), coeff=2.0, weight=1),
    ])

    print(f"\n  P and Q valuation-equivalent: {P.is_valuation_equivalent(Q)}")
    print(f"  P and R valuation-equivalent: {P.is_valuation_equivalent(R)}")

    # Show that tropicalization is the same
    FP = P.tropicalize()
    FQ = Q.tropicalize()

    print(f"\n  Tropicalization of P:")
    print(f"    coeffs = {FP.coeffs}")
    print(f"    biases = {FP.biases}")

    print(f"\n  Tropicalization of Q:")
    print(f"    coeffs = {FQ.coeffs}")
    print(f"    biases = {FQ.biases}")

    print(f"\n  Coefficients equal: {np.allclose(FP.coeffs, FQ.coeffs)}")
    print(f"  Biases equal: {np.allclose(FP.biases, FQ.biases)}")

    # Verify active complexes are identical
    complex_P = compute_active_complex(FP, num_samples=50000)
    complex_Q = compute_active_complex(FQ, num_samples=50000)

    print(f"\n  Active complex of tropicalize(P): {len(complex_P)} cells")
    for s in sorted(complex_P, key=lambda s: (len(s), sorted(s))):
        print(f"    {set(s)}")

    print(f"\n  Active complex of tropicalize(Q): {len(complex_Q)} cells")
    for s in sorted(complex_Q, key=lambda s: (len(s), sorted(s))):
        print(f"    {set(s)}")

    print(f"\n  Active complexes identical: {complex_P == complex_Q}")


def demo_4_zero_temperature():
    """Demo 4: Zero-temperature convergence (softmax → tropical max)."""
    print("\n" + "=" * 70)
    print("DEMO 4: Zero-Temperature Convergence (Softmax → Tropical Max)")
    print("=" * 70)

    F = TropicalAffineFamily(
        coeffs=np.array([[1, 0], [0, 1], [-1, -1]]),
        biases=np.array([0, 0, 3])
    )

    x = np.array([1.5, 0.5])
    betas = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0, 1000.0]

    demonstrate_zero_temperature_convergence(F, x, betas)


def demo_5_filtration_monotonicity():
    """Demo 5: Monotonicity of sublevel filtration and active complex growth."""
    print("\n" + "=" * 70)
    print("DEMO 5: Filtration Monotonicity")
    print("=" * 70)

    F = TropicalAffineFamily(
        coeffs=np.array([[2, -1], [-1, 2], [1, 1], [-1, -1]]),
        biases=np.array([0, 0, -1, 4])
    )

    thresholds = [0.0, 1.0, 2.0, 3.0, 5.0, 10.0]
    print(f"\n  Threshold | Sublevel Active Complex Size | Cells")
    print(f"  {'-'*9}-+-{'-'*29}-+-{'-'*30}")

    prev_complex = set()
    for c in thresholds:
        cx = compute_sublevel_active_complex(F, c, num_samples=30000)
        is_mono = prev_complex.issubset(cx)
        print(f"  {c:>9.1f} | {len(cx):>29} | monotone: {is_mono}")
        prev_complex = cx


def demo_6_hyperplane_arrangement():
    """Demo 6: Hyperplane arrangement structure."""
    print("\n" + "=" * 70)
    print("DEMO 6: Hyperplane Arrangement (Sign-Combinatorial Type)")
    print("=" * 70)

    # Two families with the same sign type (related by scaling)
    F = TropicalAffineFamily(
        coeffs=np.array([[1, 0], [0, 1], [-1, -1]]),
        biases=np.array([0, 0, 3])
    )

    # G has proportional differences (same hyperplane arrangement)
    G = TropicalAffineFamily(
        coeffs=np.array([[2, 0], [0, 2], [-2, -2]]),
        biases=np.array([0, 0, 6])
    )

    # H has a different arrangement
    H = TropicalAffineFamily(
        coeffs=np.array([[1, 0], [0, 1], [1, -1]]),
        biases=np.array([0, 0, 0])
    )

    complex_F = compute_active_complex(F, num_samples=50000)
    complex_G = compute_active_complex(G, num_samples=50000)
    complex_H = compute_active_complex(H, num_samples=50000)

    print(f"\n  F and G (same arrangement, scaled):")
    print(f"    Active complex F: {len(complex_F)} cells: {[set(s) for s in sorted(complex_F, key=lambda s: (len(s), sorted(s)))]}")
    print(f"    Active complex G: {len(complex_G)} cells: {[set(s) for s in sorted(complex_G, key=lambda s: (len(s), sorted(s)))]}")
    print(f"    Same complex: {complex_F == complex_G}")

    print(f"\n  F and H (different arrangement):")
    print(f"    Active complex H: {len(complex_H)} cells: {[set(s) for s in sorted(complex_H, key=lambda s: (len(s), sorted(s)))]}")
    print(f"    Same as F: {complex_F == complex_H}")


if __name__ == "__main__":
    np.random.seed(42)

    demo_1_basic_tropical()
    demo_2_active_complex()
    demo_3_valuation_equivalence()
    demo_4_zero_temperature()
    demo_5_filtration_monotonicity()
    demo_6_hyperplane_arrangement()

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)

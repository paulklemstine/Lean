#!/usr/bin/env python3
"""
Applications of Product Noise Spectral Calculus

1. Pseudorandomness testing on Berggren-encoded Pythagorean triples
2. Noise sensitivity of arithmetic observables
3. Coordinate influence analysis
4. Spectral gap and mixing time estimation
"""

import numpy as np
from itertools import product as cart_product
from typing import List, Tuple

# Import the spectral engine
from algorithms import TernaryCubeSpectral


# ============================================================
# Application 1: Berggren Tree Encoding
# ============================================================

def berggren_matrices():
    """The three Berggren matrices for generating Pythagorean triples."""
    A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
    B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
    C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
    return [A, B, C]


def berggren_triple(word: Tuple[int, ...]) -> np.ndarray:
    """
    Compute the Pythagorean triple encoded by a Berggren word.

    Starting from (3, 4, 5), apply the sequence of matrices
    indexed by the word (0→A, 1→B, 2→C).

    Parameters
    ----------
    word : tuple of int
        Each element is 0, 1, or 2.

    Returns
    -------
    ndarray of shape (3,)
        The Pythagorean triple (a, b, c).
    """
    matrices = berggren_matrices()
    triple = np.array([3, 4, 5])
    for letter in word:
        triple = matrices[letter] @ triple
    return triple


def demo_berggren_encoding():
    """Demonstrate Berggren tree encoding and spectral analysis of arithmetic properties."""
    print("=" * 60)
    print("Application 1: Berggren-Encoded Pythagorean Triples")
    print("=" * 60)

    L = 4
    engine = TernaryCubeSpectral(L)
    words = engine.words

    # Compute all triples at depth L
    triples = [berggren_triple(w) for w in words]

    print(f"\nDepth L = {L}: {len(triples)} Pythagorean triples generated")
    print(f"Examples:")
    for i in range(min(5, len(words))):
        a, b, c = triples[i]
        print(f"  word {words[i]} → ({a}, {b}, {c}), "
              f"check: {a}² + {b}² = {a**2 + b**2}, {c}² = {c**2}")

    # Observable: parity of hypotenuse
    print("\n--- Parity of Hypotenuse ---")
    f_parity = np.array([(-1.0) ** (t[2] % 2) for t in triples])
    spectrum = engine.degree_spectrum(f_parity)
    print(f"Degree spectrum of hypotenuse parity:")
    for d, s in enumerate(spectrum):
        print(f"  degree {d}: {s:.6f}")

    # Observable: divisibility by small primes
    for p in [3, 5, 7]:
        print(f"\n--- Divisibility of hypotenuse by {p} ---")
        f_div = np.array([1.0 if t[2] % p == 0 else 0.0 for t in triples])
        spectrum = engine.degree_spectrum(f_div)
        mean_val = np.mean(f_div)
        print(f"  Fraction divisible: {mean_val:.4f}")
        print(f"  Degree spectrum: {[f'{s:.4f}' for s in spectrum]}")

    # Noise sensitivity
    print("\n--- Noise Sensitivity of Hypotenuse Parity ---")
    rhos = [0.1, 0.3, 0.5, 0.7, 0.9, 0.99]
    for rho in rhos:
        noised = engine.apply_product_noise_fast(rho, f_parity)
        correlation = np.mean(f_parity * noised)
        print(f"  ρ = {rho:.2f}: correlation = {correlation:.6f}")


# ============================================================
# Application 2: Coordinate Influence Analysis
# ============================================================

def compute_influences(engine: TernaryCubeSpectral, f: np.ndarray) -> np.ndarray:
    """
    Compute the influence of each coordinate on f.

    Inf_i(f) = E_x[Var_{x_i}(f(x))]

    The influence measures how much coordinate i affects the function value.

    Time: O(L · 3^L)

    Parameters
    ----------
    engine : TernaryCubeSpectral
    f : ndarray of shape (3^L,)

    Returns
    -------
    ndarray of shape (L,)
        Influence of each coordinate.
    """
    L = engine.L
    influences = np.zeros(L)

    for coord in range(L):
        # For each word, compute variance over the coordinate
        total_var = 0.0
        count = 0
        # Group words by all coordinates except `coord`
        groups = {}
        for i, w in enumerate(engine.words):
            key = tuple(w[c] for c in range(L) if c != coord)
            if key not in groups:
                groups[key] = []
            groups[key].append(f[i])

        for key, vals in groups.items():
            vals = np.array(vals)
            mean = np.mean(vals)
            var = np.mean((vals - mean) ** 2)
            total_var += var
            count += 1

        influences[coord] = total_var / count if count > 0 else 0.0

    return influences


def demo_influence_analysis():
    """Demonstrate coordinate influence analysis."""
    print("\n" + "=" * 60)
    print("Application 2: Coordinate Influence Analysis")
    print("=" * 60)

    L = 4
    engine = TernaryCubeSpectral(L)
    words = engine.words
    triples = [berggren_triple(w) for w in words]

    # Hypotenuse magnitude (normalized)
    f_hyp = np.array([float(t[2]) for t in triples])
    f_hyp_centered = f_hyp - np.mean(f_hyp)

    influences = compute_influences(engine, f_hyp_centered)
    print(f"\nInfluences on hypotenuse value (L={L}):")
    for i, inf in enumerate(influences):
        print(f"  Coordinate {i}: influence = {inf:.4f}")
    print(f"  Total influence = {sum(influences):.4f}")
    print(f"  Max influence = {max(influences):.4f} (coordinate {np.argmax(influences)})")

    # Compare with a "junta" function that depends on only 1 coordinate
    f_junta = np.array([float(w[0]) for w in words])
    f_junta_centered = f_junta - np.mean(f_junta)
    influences_junta = compute_influences(engine, f_junta_centered)
    print(f"\nInfluences on 1-junta (depends only on coord 0):")
    for i, inf in enumerate(influences_junta):
        print(f"  Coordinate {i}: influence = {inf:.6f}")


# ============================================================
# Application 3: Spectral Gap and Mixing
# ============================================================

def demo_mixing_time():
    """Demonstrate spectral gap and mixing time estimation."""
    print("\n" + "=" * 60)
    print("Application 3: Spectral Gap and Mixing Time")
    print("=" * 60)

    L = 3
    engine = TernaryCubeSpectral(L)

    print(f"\nL = {L}, state space size = {engine.n}")

    # The spectral gap of the product noise operator T_ρ
    # is 1 - ρ (the gap between eigenvalue 1 and eigenvalue ρ)
    print("\nSpectral gaps for various ρ:")
    print(f"{'ρ':>6} | {'gap':>8} | {'mixing time':>12} | {'ρ^L':>10}")
    print("-" * 50)

    for rho in [0.1, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99]:
        gap = 1 - rho
        # Mixing time ≈ 1/gap · log(n) for convergence to uniform
        mixing_time = np.log(engine.n) / gap if gap > 0 else float('inf')
        print(f"{rho:6.2f} | {gap:8.4f} | {mixing_time:12.2f} | {rho**L:10.6f}")

    # Demonstrate actual convergence
    print("\n--- Convergence of T_ρ^t δ_0 to uniform ---")
    rho = 0.7
    # Start with delta function at first word
    f = np.zeros(engine.n)
    f[0] = engine.n  # Scaled so expectation = 1

    print(f"ρ = {rho}")
    uniform = np.ones(engine.n)
    for t in range(1, 8):
        f = engine.apply_product_noise_fast(rho, f)
        tv_dist = 0.5 * np.sum(np.abs(f / engine.n - 1.0 / engine.n))
        l2_dist = np.sqrt(np.sum((f / engine.n - 1.0 / engine.n) ** 2))
        print(f"  t={t}: TV distance = {tv_dist:.6f}, L2 distance = {l2_dist:.6f}")


# ============================================================
# Application 4: Property Testing via Low-Degree Approximation
# ============================================================

def demo_property_testing():
    """Demonstrate property testing using spectral truncation."""
    print("\n" + "=" * 60)
    print("Application 4: Low-Degree Approximation for Property Testing")
    print("=" * 60)

    L = 4
    engine = TernaryCubeSpectral(L)
    words = engine.words
    triples = [berggren_triple(w) for w in words]

    # Target property: hypotenuse > median
    hypotenuses = [float(t[2]) for t in triples]
    median_hyp = np.median(hypotenuses)
    f_property = np.array([1.0 if h > median_hyp else -1.0 for h in hypotenuses])

    print(f"\nTarget: Is hypotenuse > median ({median_hyp})?")
    print(f"L = {L}, |Ω| = {engine.n}")

    # Approximate with low-degree functions
    for k in range(L + 1):
        f_approx = engine.spectral_truncation(f_property, k)
        # Measure approximation quality
        error = np.sqrt(np.mean((f_property - f_approx) ** 2))
        agreement = np.mean(np.sign(f_approx) == f_property)
        print(f"  Degree ≤ {k}: L2 error = {error:.4f}, "
              f"classification accuracy = {agreement:.4f}")


if __name__ == "__main__":
    demo_berggren_encoding()
    demo_influence_analysis()
    demo_mixing_time()
    demo_property_testing()
    print("\n" + "=" * 60)
    print("All application demos completed!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Product Noise Spectral Calculus on Ternary Cubes

Demonstrates the core theorems with concrete numerical examples:
1. Single-site noise operator eigenspaces
2. Product noise kernel and eigenvalue decomposition
3. Homogeneous degree eigenvalue theorem: T_ρ f = ρ^d f
4. Degree filtration and spectral decay
"""

import numpy as np
from itertools import product as cart_product

# ============================================================
# Core Definitions
# ============================================================

def noise_kernel(rho, a, b):
    """Transition probability from symbol a to symbol b under noise parameter rho."""
    if a == b:
        return rho + (1 - rho) / 3
    else:
        return (1 - rho) / 3

def single_site_noise(rho, f):
    """Apply single-site noise operator T_ρ to f : Fin 3 → ℝ."""
    mean_f = np.mean(f)
    return np.array([rho * f[x] + (1 - rho) * mean_f for x in range(3)])

def product_noise(L, rho, f_values, words):
    """Apply product noise operator to f on (Fin 3)^L."""
    n = len(words)
    result = np.zeros(n)
    for i, x in enumerate(words):
        total = 0.0
        for j, y in enumerate(words):
            kernel = 1.0
            for coord in range(L):
                kernel *= noise_kernel(rho, x[coord], y[coord])
            total += kernel * f_values[j]
        result[i] = total
    return result

def generate_words(L):
    """Generate all words in (Fin 3)^L."""
    return list(cart_product(range(3), repeat=L))

# ============================================================
# Demo 1: Single-Site Spectral Split
# ============================================================

print("=" * 60)
print("DEMO 1: Single-Site Noise Operator Eigenspaces")
print("=" * 60)

rho = 0.7
print(f"\nNoise parameter ρ = {rho}")

# Constant function
f_const = np.array([5.0, 5.0, 5.0])
result = single_site_noise(rho, f_const)
print(f"\nConstant f = {f_const}")
print(f"T_ρ f      = {result}")
print(f"Eigenvalue = 1 (expected: f unchanged)")
print(f"Check: max|T_ρ f - f| = {np.max(np.abs(result - f_const)):.2e}")

# Mean-zero function
f_mz = np.array([1.0, -1.0, 0.0])
assert abs(sum(f_mz)) < 1e-10, "f must be mean-zero"
result = single_site_noise(rho, f_mz)
expected = rho * f_mz
print(f"\nMean-zero f = {f_mz}")
print(f"T_ρ f       = {result}")
print(f"ρ · f       = {expected}")
print(f"Eigenvalue  = ρ = {rho}")
print(f"Check: max|T_ρ f - ρf| = {np.max(np.abs(result - expected)):.2e}")

# Another mean-zero function
f_mz2 = np.array([1.0, 1.0, -2.0])
assert abs(sum(f_mz2)) < 1e-10
result = single_site_noise(rho, f_mz2)
expected = rho * f_mz2
print(f"\nMean-zero f = {f_mz2}")
print(f"T_ρ f       = {result}")
print(f"ρ · f       = {expected}")
print(f"Check: max|T_ρ f - ρf| = {np.max(np.abs(result - expected)):.2e}")

# ============================================================
# Demo 2: Product Noise Eigenvalue ρ^d
# ============================================================

print("\n" + "=" * 60)
print("DEMO 2: Product Noise Eigenvalue Theorem: T_ρ f = ρ^d · f")
print("=" * 60)

L = 3
rho = 0.6
words = generate_words(L)
print(f"\nL = {L}, ρ = {rho}, total words = {len(words)}")

# Degree 0: constant function
f_deg0 = np.array([3.0] * len(words))
result = product_noise(L, rho, f_deg0, words)
expected_eigenvalue = rho ** 0
print(f"\nDegree 0 (constant): eigenvalue = ρ^0 = {expected_eigenvalue}")
print(f"  max|T_ρ f - ρ^0 · f| = {np.max(np.abs(result - expected_eigenvalue * f_deg0)):.2e}")

# Degree 1: mean-zero at coordinate 0, constant at coords 1,2
# f(x) depends only on x[0] and is mean-zero: e.g., f(x) = e1(x[0]) where e1 = (1,-1,0)
e1 = np.array([1.0, -1.0, 0.0])
f_deg1 = np.array([e1[w[0]] for w in words])
result = product_noise(L, rho, f_deg1, words)
expected_eigenvalue = rho ** 1
print(f"\nDegree 1 (mean-zero at coord 0): eigenvalue = ρ^1 = {expected_eigenvalue}")
print(f"  max|T_ρ f - ρ^1 · f| = {np.max(np.abs(result - expected_eigenvalue * f_deg1)):.2e}")

# Degree 2: mean-zero at coordinates 0 and 1, constant at coord 2
# f(x) = e1(x[0]) * e1(x[1])
f_deg2 = np.array([e1[w[0]] * e1[w[1]] for w in words])
result = product_noise(L, rho, f_deg2, words)
expected_eigenvalue = rho ** 2
print(f"\nDegree 2 (mean-zero at coords 0,1): eigenvalue = ρ^2 = {expected_eigenvalue}")
print(f"  max|T_ρ f - ρ^2 · f| = {np.max(np.abs(result - expected_eigenvalue * f_deg2)):.2e}")

# Degree 3: mean-zero at all coordinates
# f(x) = e1(x[0]) * e1(x[1]) * e1(x[2])
f_deg3 = np.array([e1[w[0]] * e1[w[1]] * e1[w[2]] for w in words])
result = product_noise(L, rho, f_deg3, words)
expected_eigenvalue = rho ** 3
print(f"\nDegree 3 (mean-zero at all coords): eigenvalue = ρ^3 = {expected_eigenvalue}")
print(f"  max|T_ρ f - ρ^3 · f| = {np.max(np.abs(result - expected_eigenvalue * f_deg3)):.2e}")

# ============================================================
# Demo 3: Spectral Decay and Bias
# ============================================================

print("\n" + "=" * 60)
print("DEMO 3: Spectral Decay — High-Degree Functions Are Damped")
print("=" * 60)

L = 4
words = generate_words(L)
n = len(words)

# Build basis: for each coordinate and each mean-zero basis vector
e1 = np.array([1.0, -1.0, 0.0])
e2 = np.array([1.0, 1.0, -2.0])
mean_zero_basis = [e1, e2]

print(f"\nL = {L}, |Ω| = {n}")
print("\nSpectral decay for ρ ∈ {0.3, 0.5, 0.7, 0.9}:")
print(f"{'ρ':>6} | {'degree 0':>10} | {'degree 1':>10} | {'degree 2':>10} | {'degree 3':>10} | {'degree 4':>10}")
print("-" * 72)

for rho in [0.3, 0.5, 0.7, 0.9]:
    eigenvalues = [rho ** d for d in range(L + 1)]
    print(f"{rho:6.1f} | {eigenvalues[0]:10.6f} | {eigenvalues[1]:10.6f} | {eigenvalues[2]:10.6f} | {eigenvalues[3]:10.6f} | {eigenvalues[4]:10.6f}")

# Demonstrate actual damping on a random function
print("\n\nNumerical verification with random degree-d functions:")
rho = 0.5
for d in range(L + 1):
    # Create a degree-d function: product of d mean-zero basis vectors
    if d == 0:
        f_vals = np.ones(n)
    else:
        f_vals = np.ones(n)
        for coord in range(d):
            basis = mean_zero_basis[coord % 2]
            f_vals = np.array([f_vals[j] * basis[w[coord]] for j, w in enumerate(words)])

    result = product_noise(L, rho, f_vals, words)
    expected = (rho ** d) * f_vals
    error = np.max(np.abs(result - expected))
    print(f"  degree {d}: ρ^d = {rho**d:.6f}, max error = {error:.2e}")

# ============================================================
# Demo 4: Degree Filtration Preservation
# ============================================================

print("\n" + "=" * 60)
print("DEMO 4: Product Noise Preserves Degree Filtration")
print("=" * 60)

L = 3
words = generate_words(L)
rho = 0.4

# A function depending on coordinates {0, 1} (degree ≤ 2)
f_dep01 = np.array([float(w[0] + 2 * w[1]) for w in words])

# Check it's constant when coords 0,1 are fixed
print(f"\nFunction f depends on coords 0, 1 (degree ≤ 2)")
print(f"f values: {f_dep01[:9]} (first 9 of {len(f_dep01)})")

result = product_noise(L, rho, f_dep01, words)

# Verify T_ρ f still depends only on coords 0, 1
depends_on_01 = True
for i, w1 in enumerate(words):
    for j, w2 in enumerate(words):
        if w1[0] == w2[0] and w1[1] == w2[1]:
            if abs(result[i] - result[j]) > 1e-10:
                depends_on_01 = False
                break

print(f"T_ρ f still depends only on coords 0, 1: {depends_on_01}")
print(f"T_ρ f values: {np.round(result[:9], 6)} (first 9)")

# ============================================================
# Demo 5: Full Eigenvalue Decomposition
# ============================================================

print("\n" + "=" * 60)
print("DEMO 5: Full Eigenvalue Decomposition of a Random Function")
print("=" * 60)

L = 2
words = generate_words(L)
n = len(words)
rho = 0.7

# Random function
np.random.seed(42)
f_random = np.random.randn(n)

# Build the complete orthogonal basis
# For Fin 3: constant = [1,1,1]/√3, e1 = [1,-1,0]/√2, e2 = [1,1,-2]/√6
c_basis = np.array([1, 1, 1]) / np.sqrt(3)
e1_basis = np.array([1, -1, 0]) / np.sqrt(2)
e2_basis = np.array([1, 1, -2]) / np.sqrt(6)

# For L=2, basis functions are tensor products
# Degree 0: c ⊗ c
# Degree 1: e1 ⊗ c, e2 ⊗ c, c ⊗ e1, c ⊗ e2
# Degree 2: e1 ⊗ e1, e1 ⊗ e2, e2 ⊗ e1, e2 ⊗ e2

single_bases = [c_basis, e1_basis, e2_basis]
# Tag: 0 = constant, 1 or 2 = mean-zero (degree contribution 1)

basis_functions = []
degrees = []
for b1_idx in range(3):
    for b2_idx in range(3):
        b = np.array([single_bases[b1_idx][w[0]] * single_bases[b2_idx][w[1]] for w in words])
        basis_functions.append(b)
        deg = (1 if b1_idx > 0 else 0) + (1 if b2_idx > 0 else 0)
        degrees.append(deg)

basis_functions = np.array(basis_functions)

# Project f_random onto basis
coeffs = np.array([np.dot(basis_functions[k], f_random) for k in range(n)])

# Verify reconstruction
f_reconstructed = sum(coeffs[k] * basis_functions[k] for k in range(n))
print(f"\nL = {L}, ρ = {rho}")
print(f"Random f = {np.round(f_random, 4)}")
print(f"Reconstruction error: {np.max(np.abs(f_random - f_reconstructed)):.2e}")

# Apply product noise
result = product_noise(L, rho, f_random, words)

# Compute expected result using spectral theorem
expected = sum(rho ** degrees[k] * coeffs[k] * basis_functions[k] for k in range(n))
print(f"\nT_ρ f (computed):  {np.round(result, 6)}")
print(f"T_ρ f (spectral):  {np.round(expected, 6)}")
print(f"Agreement error:   {np.max(np.abs(result - expected)):.2e}")

print("\nDecomposition by degree:")
for d in range(L + 1):
    mass = sum(coeffs[k] ** 2 for k in range(n) if degrees[k] == d)
    print(f"  Degree {d}: ‖f_d‖² = {mass:.6f}, eigenvalue = ρ^{d} = {rho**d:.6f}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables embedded."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_binary_base64(path):
    with open(path, 'rb') as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode('utf-8')

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Pythagorean/BerggrenWordCubeSpectral.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualizations
viz_files = {
    'eigenvalue_decay': 'eigenvalue_decay.png',
    'noise_kernel': 'noise_kernel.png',
    'spectral_decomposition': 'spectral_decomposition.png',
    'noise_convergence': 'noise_convergence.png',
    'degree_spectrum': 'degree_spectrum.png',
}

visualizations = []
for name, filename in viz_files.items():
    if os.path.exists(filename):
        visualizations.append({
            "name": name.replace('_', ' ').title(),
            "data": read_binary_base64(filename)
        })

package = {
    "title": "Product Noise, Low-Degree Structure, and Spectral Bias on Berggren Word Cubes",
    "domain": "Discrete Harmonic Analysis / Arithmetic Combinatorics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Product Noise Spectral Calculus Demo",
            "code": demo_code
        },
        {
            "name": "Berggren Tree Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Fast Product Noise via Coordinate Factorization",
            "pseudocode": """Algorithm: FastProductNoise(L, rho, f)
Input: L (word length), rho (noise parameter), f : Omega_L -> R
Output: T_rho f

1. result <- f
2. for coord = 0 to L-1:
3.    result <- ApplyCoordNoise(rho, coord, result)
4. return result

Complexity: O(L * 3^L) time, O(3^L) space
(vs O(9^L) for direct kernel computation)""",
            "code": algorithms_code
        }
    ],
    "visualizations": visualizations,
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Visualizations for Product Noise Spectral Calculus on Ternary Cubes.
Generates PNG figures for inclusion in the research package.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cart_product
import base64
import io
import json

# Inline the spectral engine to be self-contained
class TernaryCubeSpectral:
    def __init__(self, L):
        self.L = L
        self.words = list(cart_product(range(3), repeat=L))
        self.n = 3 ** L
        self.ternary_basis = np.array([
            [1, 1, 1], [1, -1, 0], [1, 1, -2]
        ], dtype=float)
        for i in range(3):
            self.ternary_basis[i] /= np.linalg.norm(self.ternary_basis[i])
        self._word_to_idx = {w: i for i, w in enumerate(self.words)}

    def apply_coord_noise(self, rho, coord, f):
        result = np.zeros(self.n)
        p_same = rho + (1 - rho) / 3
        p_diff = (1 - rho) / 3
        for i, x in enumerate(self.words):
            total = 0.0
            for v in range(3):
                kv = p_same if x[coord] == v else p_diff
                y = list(x); y[coord] = v
                j = self._word_to_idx[tuple(y)]
                total += kv * f[j]
            result[i] = total
        return result

    def apply_product_noise_fast(self, rho, f):
        result = f.copy()
        for c in range(self.L):
            result = self.apply_coord_noise(rho, c, result)
        return result

    def fourier_decompose(self, f):
        components = {d: np.zeros(self.n) for d in range(self.L + 1)}
        for basis_indices in cart_product(range(3), repeat=self.L):
            degree = sum(1 for b in basis_indices if b > 0)
            basis_vals = np.array([
                np.prod([self.ternary_basis[basis_indices[c]][w[c]] for c in range(self.L)])
                for w in self.words
            ])
            coeff = np.dot(f, basis_vals)
            components[degree] += coeff * basis_vals
        return components

    def degree_spectrum(self, f):
        components = self.fourier_decompose(f)
        return [np.mean(components[d] ** 2) for d in range(self.L + 1)]


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_eigenvalue_decay():
    """Plot eigenvalue ρ^d as function of degree for various ρ."""
    fig, ax = plt.subplots(figsize=(8, 5))

    L = 8
    degrees = np.arange(L + 1)

    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 5))
    for idx, rho in enumerate([0.3, 0.5, 0.7, 0.85, 0.95]):
        eigenvalues = [rho ** d for d in degrees]
        ax.plot(degrees, eigenvalues, 'o-', color=colors[idx],
                label=f'ρ = {rho}', markersize=6, linewidth=2)

    ax.set_xlabel('Degree d', fontsize=13)
    ax.set_ylabel('Eigenvalue ρ^d', fontsize=13)
    ax.set_title('Spectral Decay: Eigenvalues of Product Noise Operator', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')
    ax.set_ylim(1e-5, 2)
    return fig_to_base64(fig)


def plot_noise_kernel_heatmap():
    """Visualize the noise kernel K_ρ(a, b) for different ρ."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 3.5))

    for idx, rho in enumerate([0.0, 0.3, 0.7, 1.0]):
        K = np.zeros((3, 3))
        for a in range(3):
            for b in range(3):
                K[a, b] = rho + (1 - rho) / 3 if a == b else (1 - rho) / 3

        im = axes[idx].imshow(K, cmap='YlOrRd', vmin=0, vmax=1, aspect='equal')
        axes[idx].set_title(f'ρ = {rho}', fontsize=12)
        axes[idx].set_xlabel('Target b')
        axes[idx].set_ylabel('Source a')
        axes[idx].set_xticks([0, 1, 2])
        axes[idx].set_yticks([0, 1, 2])

        for a in range(3):
            for b in range(3):
                axes[idx].text(b, a, f'{K[a,b]:.2f}', ha='center', va='center',
                             fontsize=10, color='black' if K[a,b] < 0.6 else 'white')

    fig.colorbar(im, ax=axes, shrink=0.8, label='Transition probability')
    fig.suptitle('Noise Kernel K_ρ(a, b): From Uniform to Identity', fontsize=14, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def plot_spectral_decomposition():
    """Visualize spectral decomposition of a random function."""
    L = 3
    engine = TernaryCubeSpectral(L)

    np.random.seed(42)
    f = np.random.randn(engine.n)

    components = engine.fourier_decompose(f)

    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    axes_flat = axes.flatten()

    x_indices = range(engine.n)

    axes_flat[0].bar(x_indices, f, color='steelblue', alpha=0.8)
    axes_flat[0].set_title('Original function f', fontsize=12)
    axes_flat[0].set_xlabel('Word index')
    axes_flat[0].set_ylabel('Value')

    colors = ['#2ecc71', '#e74c3c', '#3498db', '#f39c12']
    for d in range(min(L + 1, 3)):  # Show up to 3 degree components
        ax = axes_flat[d + 1]
        ax.bar(x_indices, components[d], color=colors[d], alpha=0.8)
        mass = np.mean(components[d] ** 2)
        ax.set_title(f'Degree-{d} component (‖f_{d}‖² = {mass:.3f})', fontsize=11)
        ax.set_xlabel('Word index')
        ax.set_ylabel('Value')

    fig.suptitle(f'Fourier Decomposition on (Fin 3)^{L}', fontsize=14)
    plt.tight_layout()
    return fig_to_base64(fig)


def plot_noise_convergence():
    """Plot convergence of iterated noise application."""
    L = 3
    engine = TernaryCubeSpectral(L)

    np.random.seed(123)
    f = np.random.randn(engine.n)
    f_mean = np.mean(f)

    fig, ax = plt.subplots(figsize=(8, 5))

    rhos = [0.3, 0.5, 0.7, 0.9]
    colors = plt.cm.plasma(np.linspace(0.2, 0.8, len(rhos)))

    for idx, rho in enumerate(rhos):
        distances = []
        g = f.copy()
        for t in range(15):
            dist = np.sqrt(np.mean((g - f_mean) ** 2))
            distances.append(dist)
            g = engine.apply_product_noise_fast(rho, g)

        ax.plot(range(15), distances, 'o-', color=colors[idx],
                label=f'ρ = {rho}', markersize=5, linewidth=2)

    ax.set_xlabel('Number of noise applications t', fontsize=13)
    ax.set_ylabel('L² distance from mean', fontsize=13)
    ax.set_title('Convergence Under Iterated Noise', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')
    return fig_to_base64(fig)


def plot_degree_spectrum_comparison():
    """Compare degree spectra of different types of functions."""
    L = 4
    engine = TernaryCubeSpectral(L)
    words = engine.words

    fig, ax = plt.subplots(figsize=(8, 5))

    # Function 1: Random
    np.random.seed(42)
    f_random = np.random.randn(engine.n)
    spec_random = engine.degree_spectrum(f_random)

    # Function 2: Depends on 1 coordinate
    f_junta = np.array([float(w[0]) for w in words])
    f_junta -= np.mean(f_junta)
    spec_junta = engine.degree_spectrum(f_junta)

    # Function 3: Depends on all coordinates
    f_all = np.array([float(sum(w)) for w in words])
    f_all -= np.mean(f_all)
    spec_all = engine.degree_spectrum(f_all)

    degrees = range(L + 1)
    width = 0.25

    ax.bar([d - width for d in degrees], spec_random, width, label='Random', color='#3498db', alpha=0.8)
    ax.bar(list(degrees), spec_junta, width, label='1-junta', color='#e74c3c', alpha=0.8)
    ax.bar([d + width for d in degrees], spec_all, width, label='All coords', color='#2ecc71', alpha=0.8)

    ax.set_xlabel('Degree d', fontsize=13)
    ax.set_ylabel('Spectral mass ‖f_d‖²', fontsize=13)
    ax.set_title(f'Degree Spectra of Different Functions (L={L})', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return as dict of base64 images."""
    print("Generating visualizations...")

    visuals = {}

    print("  1/5: Eigenvalue decay...")
    visuals['eigenvalue_decay'] = plot_eigenvalue_decay()

    print("  2/5: Noise kernel heatmap...")
    visuals['noise_kernel'] = plot_noise_kernel_heatmap()

    print("  3/5: Spectral decomposition...")
    visuals['spectral_decomposition'] = plot_spectral_decomposition()

    print("  4/5: Noise convergence...")
    visuals['noise_convergence'] = plot_noise_convergence()

    print("  5/5: Degree spectrum comparison...")
    visuals['degree_spectrum'] = plot_degree_spectrum_comparison()

    print("All visualizations generated.")
    return visuals


if __name__ == "__main__":
    visuals = generate_all_visualizations()

    # Save individual PNGs
    for name, data_uri in visuals.items():
        # Extract base64 data
        b64_data = data_uri.split(",", 1)[1]
        img_bytes = base64.b64decode(b64_data)
        filename = f"{name}.png"
        with open(filename, 'wb') as f:
            f.write(img_bytes)
        print(f"Saved {filename}")

    print("Done!")

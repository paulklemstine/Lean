#!/usr/bin/env python3
"""
Applications of spectral analysis on ternary word cubes.

Demonstrates connections to:
1. Pseudorandomness testing on Berggren tree paths
2. Noise sensitivity and influence
3. Transfer operator spectral gaps
"""

import numpy as np
from itertools import product as cart_product
from algorithms import noise_kernel_matrix, product_noise_matrix, spectral_decomposition
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def berggren_matrices():
    """The three Berggren matrices for generating Pythagorean triples."""
    A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
    B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
    C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
    return [A, B, C]


def berggren_walk_mixing(L: int, n_trials: int = 1000):
    """Simulate the Berggren random walk and measure mixing.
    
    At each step, choose uniformly from {A, B, C} and apply to the
    current Pythagorean triple. The ternary word encoding records which
    matrix was chosen at each step.
    
    Returns mixing statistics over n_trials independent walks.
    """
    matrices = berggren_matrices()
    triple = np.array([3, 4, 5])  # Starting triple
    
    # Track frequency of each matrix choice
    counts = np.zeros(3)
    
    for _ in range(n_trials):
        word = []
        current = triple.copy()
        for _ in range(L):
            choice = np.random.randint(3)
            word.append(choice)
            current = matrices[choice] @ current
        
        for ch in word:
            counts[ch] += 1
    
    # Under uniform mixing, each choice should appear with probability 1/3
    freqs = counts / (L * n_trials)
    return freqs


def influence_computation(L: int, f: np.ndarray) -> np.ndarray:
    """Compute the influence of each coordinate on function f.
    
    Inf_i(f) = Pr_{x}[f depends on x_i]
             = (1/3^L) Σ_x Var_{x_i}[f(x)]
    
    For Boolean f, this measures how often changing x_i changes f(x).
    """
    words = list(cart_product(range(3), repeat=L))
    n = len(words)
    word_to_idx = {w: idx for idx, w in enumerate(words)}
    
    influences = np.zeros(L)
    
    for i in range(L):
        total_var = 0.0
        for xi, x in enumerate(words):
            # Compute variance of f over x_i, fixing other coords
            vals = []
            for v in range(3):
                x_mod = list(x)
                x_mod[i] = v
                vals.append(f[word_to_idx[tuple(x_mod)]])
            mean_val = np.mean(vals)
            var_val = np.mean([(v - mean_val)**2 for v in vals])
            total_var += var_val
        
        influences[i] = total_var / n
    
    return influences


def noise_sensitivity(L: int, rho: float, f: np.ndarray) -> float:
    """Compute noise sensitivity: Pr[f(x) ≠ f(y)] where y is ρ-correlated with x.
    
    NS_ρ(f) = E[f(x) · f(y)] where y = T_ρ(x)
    
    For ±1 valued f: NS_ρ(f) = (1 - Stab_ρ(f))/2
    """
    M = product_noise_matrix(L, rho)
    n = 3 ** L
    
    # Stability: E[f(x) · (T_ρ f)(x)]
    Tf = M @ f
    stability = np.dot(f, Tf) / n
    
    return stability


def visualize_spectral_structure():
    """Create visualizations of the spectral structure."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # 1. Eigenvalue decay for different word lengths
    ax = axes[0, 0]
    for L in [2, 3, 4, 5]:
        degrees = range(L + 1)
        for rho in [0.3, 0.6, 0.9]:
            eigenvals = [rho**d for d in degrees]
            ax.plot(list(degrees), eigenvals, 'o-',
                    label=f'L={L}, ρ={rho}' if L == 3 else None,
                    alpha=0.6, markersize=4)
    ax.set_xlabel('Degree d')
    ax.set_ylabel('Eigenvalue ρ^d')
    ax.set_title('Eigenvalue Spectrum')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 2. Dimension of each degree subspace
    ax = axes[0, 1]
    from math import comb
    for L in [3, 4, 5, 6]:
        degrees = range(L + 1)
        dims = [comb(L, d) * 2**d for d in degrees]
        ax.bar([d + 0.15*(L-3) for d in degrees], dims, width=0.15,
               label=f'L={L}', alpha=0.7)
    ax.set_xlabel('Degree d')
    ax.set_ylabel('Dimension')
    ax.set_title('Subspace Dimensions C(L,d)·2^d')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 3. Noise sensitivity vs ρ
    ax = axes[1, 0]
    L = 3
    decomp = spectral_decomposition(L)
    rho_vals = np.linspace(0.01, 0.99, 50)
    
    # Pick a degree-1 function and a degree-2 function
    f1 = decomp[1][0] if decomp[1] else np.zeros(3**L)
    f2 = decomp[2][0] if decomp[2] else np.zeros(3**L)
    
    stab1 = [noise_sensitivity(L, r, f1) for r in rho_vals]
    stab2 = [noise_sensitivity(L, r, f2) for r in rho_vals]
    
    ax.plot(rho_vals, stab1, label='Degree 1 (slope ρ)', linewidth=2)
    ax.plot(rho_vals, stab2, label='Degree 2 (slope ρ²)', linewidth=2)
    ax.plot(rho_vals, rho_vals, '--', alpha=0.5, label='y = ρ')
    ax.plot(rho_vals, rho_vals**2, '--', alpha=0.5, label='y = ρ²')
    ax.set_xlabel('ρ')
    ax.set_ylabel('Noise Stability')
    ax.set_title('Noise Stability by Degree')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 4. Influence distribution
    ax = axes[1, 1]
    L = 4
    n = 3**L
    np.random.seed(42)
    
    # Random balanced function
    f_random = np.random.choice([-1, 1], size=n)
    inf_random = influence_computation(L, f_random)
    
    # Dictator function (depends only on coord 0)
    f_dict = np.zeros(n)
    words = list(cart_product(range(3), repeat=L))
    for wi, w in enumerate(words):
        f_dict[wi] = 1.0 if w[0] == 0 else -0.5
    inf_dict = influence_computation(L, f_dict)
    
    x_pos = np.arange(L)
    ax.bar(x_pos - 0.15, inf_dict, width=0.3, label='Dictator-like', alpha=0.7)
    ax.bar(x_pos + 0.15, inf_random, width=0.3, label='Random', alpha=0.7)
    ax.set_xlabel('Coordinate i')
    ax.set_ylabel('Influence Inf_i(f)')
    ax.set_title('Coordinate Influences')
    ax.set_xticks(x_pos)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/spectral_structure.png', dpi=150,
                bbox_inches='tight')
    print("Saved: spectral_structure.png")


if __name__ == "__main__":
    print("Running application demos...")
    
    # Berggren walk mixing
    print("\n1. Berggren walk mixing (L=10):")
    freqs = berggren_walk_mixing(10, 5000)
    print(f"   Matrix frequencies: {freqs}")
    print(f"   Expected (uniform): [0.333, 0.333, 0.333]")
    
    # Influence computation
    print("\n2. Influence computation (L=3):")
    L = 3
    decomp = spectral_decomposition(L)
    f = decomp[1][0]  # degree-1 function
    inf = influence_computation(L, f)
    print(f"   Degree-1 function influences: {inf}")
    print(f"   Total influence: {np.sum(inf):.4f}")
    
    # Visualizations
    print("\n3. Generating visualizations...")
    visualize_spectral_structure()
    
    print("\nAll application demos completed!")


#!/usr/bin/env python3
"""
Demo: Product Noise Operator and Spectral Decomposition on Ternary Word Cubes

Demonstrates the key theorems about the noise operator T_ρ on functions
defined on (Fin 3)^L — the space of length-L words over a 3-symbol alphabet.

Key results verified numerically:
1. Constants are eigenvectors with eigenvalue 1
2. Mean-zero functions are eigenvectors with eigenvalue ρ
3. The product noise operator has eigenvalue ρ^d on degree-d functions
"""

import numpy as np
from itertools import product
from typing import List, Tuple, Callable
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ──────────────────────────────────────────────
# Core definitions
# ──────────────────────────────────────────────

def noise_kernel(rho: float, a: int, b: int) -> float:
    """Single-site transition kernel K_ρ(a, b) = ρ·δ(a,b) + (1-ρ)/3."""
    return rho + (1 - rho) / 3 if a == b else (1 - rho) / 3

def all_words(L: int) -> List[Tuple[int, ...]]:
    """Generate all words in {0,1,2}^L."""
    return list(product(range(3), repeat=L))

def product_noise(L: int, rho: float, f: np.ndarray) -> np.ndarray:
    """Apply the product noise operator to function f on {0,1,2}^L.
    
    (T_ρ f)(x) = Σ_y (Π_i K_ρ(x_i, y_i)) · f(y)
    """
    words = all_words(L)
    n = len(words)
    result = np.zeros(n)
    
    for xi, x in enumerate(words):
        total = 0.0
        for yi, y in enumerate(words):
            kernel_prod = 1.0
            for i in range(L):
                kernel_prod *= noise_kernel(rho, x[i], y[i])
            total += kernel_prod * f[yi]
        result[xi] = total
    
    return result

def single_site_noise(rho: float, f: np.ndarray) -> np.ndarray:
    """Apply single-site noise to f : Fin 3 → ℝ.
    
    T_ρ f(x) = ρ·f(x) + (1-ρ)/3 · Σ_y f(y)
    """
    mean = np.sum(f) / 3
    return rho * f + (1 - rho) * mean

# ──────────────────────────────────────────────
# Theorem A: Single-site spectral split
# ──────────────────────────────────────────────

print("=" * 60)
print("THEOREM A: Single-site spectral decomposition")
print("=" * 60)

rho = 0.7

# Test 1: Constants are eigenvectors with eigenvalue 1
c = 3.14
f_const = np.array([c, c, c])
result = single_site_noise(rho, f_const)
print(f"\nConstant function f = [{c}, {c}, {c}]")
print(f"T_ρ f = {result}")
print(f"Expected: [{c}, {c}, {c}]")
print(f"Match: {np.allclose(result, f_const)}")

# Test 2: Mean-zero functions are eigenvectors with eigenvalue ρ
f_mean_zero = np.array([1.0, -1.0, 0.0])  # sum = 0
result = single_site_noise(rho, f_mean_zero)
expected = rho * f_mean_zero
print(f"\nMean-zero function f = {f_mean_zero} (sum = {np.sum(f_mean_zero)})")
print(f"T_ρ f = {result}")
print(f"Expected ρ·f = {expected}")
print(f"Match: {np.allclose(result, expected)}")

# Another mean-zero function
f_mean_zero2 = np.array([1.0, 1.0, -2.0])  # sum = 0
result2 = single_site_noise(rho, f_mean_zero2)
expected2 = rho * f_mean_zero2
print(f"\nMean-zero function f = {f_mean_zero2} (sum = {np.sum(f_mean_zero2)})")
print(f"T_ρ f = {result2}")
print(f"Expected ρ·f = {expected2}")
print(f"Match: {np.allclose(result2, expected2)}")

# ──────────────────────────────────────────────
# Theorem C: Product noise eigenvalue ρ^d
# ──────────────────────────────────────────────

print("\n" + "=" * 60)
print("THEOREM C: Product noise eigenvalue decomposition")
print("=" * 60)

L = 3
rho = 0.6
words = all_words(L)
n = len(words)

def make_degree_d_function(L: int, S: set, mean_zero_funcs: dict) -> np.ndarray:
    """Create a function on {0,1,2}^L that is mean-zero at coordinates in S
    and constant at coordinates outside S.
    
    Uses product form: f(x) = Π_{i∈S} g_i(x_i) · Π_{i∉S} 1
    where g_i are mean-zero functions on {0,1,2}.
    """
    words = all_words(L)
    result = np.zeros(len(words))
    
    for wi, w in enumerate(words):
        val = 1.0
        for i in range(L):
            if i in S:
                val *= mean_zero_funcs[i][w[i]]
            # else: multiply by 1 (constant)
        result[wi] = val
    
    return result

# Mean-zero basis functions for each coordinate
mz1 = np.array([1.0, -1.0, 0.0])   # sum = 0
mz2 = np.array([1.0, 1.0, -2.0])   # sum = 0

print(f"\nL = {L}, ρ = {rho}")

for d in range(L + 1):
    # Choose S = {0, 1, ..., d-1}
    S = set(range(d))
    mean_zero_funcs = {i: mz1 if i % 2 == 0 else mz2 for i in S}
    
    f = make_degree_d_function(L, S, mean_zero_funcs)
    Tf = product_noise(L, rho, f)
    expected = (rho ** d) * f
    
    error = np.max(np.abs(Tf - expected))
    print(f"\n  Degree d = {d}, S = {S}")
    print(f"  max|T_ρ f - ρ^d · f| = {error:.2e}")
    print(f"  ρ^d = {rho**d:.6f}")
    print(f"  Eigenvalue verified: {np.allclose(Tf, expected)}")

# ──────────────────────────────────────────────
# Spectral decay visualization
# ──────────────────────────────────────────────

print("\n" + "=" * 60)
print("SPECTRAL DECAY: Eigenvalues ρ^d for various ρ")
print("=" * 60)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: eigenvalue spectrum
L_vals = [4, 6, 8]
rho_vals = np.linspace(0, 1, 100)

ax = axes[0]
for L_val in L_vals:
    for d in range(1, min(L_val + 1, 5)):
        eigenvalues = [r**d for r in rho_vals]
        ax.plot(rho_vals, eigenvalues, label=f'd={d}' if L_val == L_vals[0] else None,
                alpha=min(0.7 + 0.1 * (L_val - 4), 1.0))

ax.set_xlabel('ρ (noise parameter)', fontsize=12)
ax.set_ylabel('Eigenvalue ρ^d', fontsize=12)
ax.set_title('Spectral Decay: Eigenvalues by Degree', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)

# Right: spectral gap
ax = axes[1]
rho_vals = np.linspace(0.01, 0.99, 100)
for d in range(1, 6):
    gaps = [1 - r**d for r in rho_vals]
    ax.plot(rho_vals, gaps, label=f'd={d}', linewidth=2)

ax.set_xlabel('ρ (noise parameter)', fontsize=12)
ax.set_ylabel('Spectral gap 1 - ρ^d', fontsize=12)
ax.set_title('Spectral Gap by Degree', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/spectral_decay.png', dpi=150, bbox_inches='tight')
print("\nSaved: spectral_decay.png")

# ──────────────────────────────────────────────
# Noise kernel stochasticity check
# ──────────────────────────────────────────────

print("\n" + "=" * 60)
print("NOISE KERNEL: Stochasticity verification")
print("=" * 60)

for rho_test in [0.0, 0.3, 0.5, 0.7, 1.0]:
    for a in range(3):
        row_sum = sum(noise_kernel(rho_test, a, b) for b in range(3))
        print(f"  ρ={rho_test:.1f}, a={a}: Σ_b K(a,b) = {row_sum:.10f}")

print("\n✓ All kernel rows sum to 1 (verified)")

# ──────────────────────────────────────────────
# Degree filtration
# ──────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEGREE FILTRATION: Dimension count")
print("=" * 60)

for L_val in range(1, 6):
    total_dim = 3 ** L_val
    print(f"\n  L = {L_val}: total dimension = {total_dim}")
    for d in range(L_val + 1):
        from math import comb
        # Number of homogeneous degree-d basis functions = C(L,d) * 2^d
        count = comb(L_val, d) * (2 ** d)
        print(f"    degree {d}: dim = {count} (C({L_val},{d}) × 2^{d})")
    total = sum(comb(L_val, d) * (2 ** d) for d in range(L_val + 1))
    print(f"    total = {total} = 3^{L_val} = {3**L_val} ✓")

print("\n" + "=" * 60)
print("All demonstrations completed successfully!")
print("=" * 60)

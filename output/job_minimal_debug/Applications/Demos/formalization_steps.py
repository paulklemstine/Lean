#!/usr/bin/env python3
"""
Applications of Product Noise Spectral Calculus to Berggren-Generated
Pythagorean Triples and Related Structures.

Demonstrates:
1. Pseudorandomness testing of Berggren random walks
2. Mixing time estimation for arithmetic statistics
3. Property testing / junta detection on ternary cubes
4. Parity statistics of Pythagorean triples
"""

import numpy as np
from itertools import product as iterproduct
from typing import List, Tuple
from algorithms import (
    product_noise_fast, homogeneous_decomposition,
    noise_sensitivity, total_influence, BerggrenWordCube
)


# ============================================================
# Berggren Matrices
# ============================================================

# The three Berggren matrices that generate all primitive Pythagorean triples
BERGGREN_A = np.array([[ 1, -2,  2],
                        [ 2, -1,  2],
                        [ 2, -2,  3]])

BERGGREN_B = np.array([[ 1,  2,  2],
                        [ 2,  1,  2],
                        [ 2,  2,  3]])

BERGGREN_C = np.array([[-1,  2,  2],
                        [-2,  1,  2],
                        [-2,  2,  3]])

BERGGREN_MATRICES = [BERGGREN_A, BERGGREN_B, BERGGREN_C]


def berggren_walk(start: np.ndarray, word: tuple) -> np.ndarray:
    """Apply a Berggren word to a starting triple.
    
    Each letter 0, 1, 2 corresponds to matrix A, B, C respectively.
    
    Args:
        start: Initial Pythagorean triple (a, b, c) as numpy array
        word: Tuple of letters from {0, 1, 2}
    
    Returns:
        Resulting Pythagorean triple
    """
    result = start.copy()
    for letter in word:
        result = BERGGREN_MATRICES[letter] @ result
    return result


# ============================================================
# Application 1: Pseudorandomness of Berggren Statistics
# ============================================================

def app_pseudorandomness():
    """Test pseudorandomness of Berggren-generated triples.
    
    We define several statistics on Pythagorean triples and measure
    how quickly they equilibrate under the Berggren random walk.
    """
    print("=" * 60)
    print("APPLICATION 1: Pseudorandomness of Berggren Statistics")
    print("=" * 60)
    
    start = np.array([3, 4, 5])  # The fundamental triple
    
    # Statistics to test
    def parity_a(triple):
        """Parity of the first element."""
        return triple[0] % 2
    
    def residue_c_mod5(triple):
        """Residue of hypotenuse mod 5."""
        return triple[2] % 5
    
    def ratio_ab(triple):
        """Whether a > b."""
        return 1 if triple[0] > triple[1] else 0
    
    statistics = [
        ("parity(a)", parity_a),
        ("c mod 5", residue_c_mod5),
        ("a > b", ratio_ab),
    ]
    
    # For each word length, sample all 3^L words and compute statistics
    for L in range(1, 6):
        words = list(iterproduct(range(3), repeat=L))
        n_words = len(words)
        
        print(f"\n--- Word length L = {L} (3^L = {n_words} words) ---")
        
        for stat_name, stat_fn in statistics:
            values = [stat_fn(berggren_walk(start, w)) for w in words]
            mean_val = np.mean(values)
            std_val = np.std(values)
            print(f"  {stat_name:15s}: mean = {mean_val:.4f}, std = {std_val:.4f}")


# ============================================================
# Application 2: Mixing Time Estimation
# ============================================================

def app_mixing_time():
    """Estimate mixing time from spectral gap analysis.
    
    Using the noise operator framework, we estimate how many steps
    of the Berggren random walk are needed before a given statistic
    is essentially indistinguishable from its equilibrium value.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Mixing Time from Spectral Analysis")
    print("=" * 60)
    
    L = 4
    cube = BerggrenWordCube(L)
    
    # Create a test function: indicator of words starting with 0
    f = np.zeros(3**L)
    for idx, w in enumerate(cube.words):
        if w[0] == 0:
            f[idx] = 1.0
    
    # Center it (subtract mean)
    f_centered = f - np.mean(f)
    
    # Decompose into degrees
    components = homogeneous_decomposition(L, f_centered)
    
    print(f"\nTest function: indicator of words starting with 0 (L={L})")
    print(f"  Mean: {np.mean(f):.4f}")
    print(f"\nDegree decomposition of centered function:")
    for d, comp in enumerate(components):
        energy = np.sum(comp**2) / 3**L
        print(f"  Degree {d}: energy = {energy:.6f}")
    
    # Estimate mixing time for different ρ values
    epsilon = 0.01  # target bias
    print(f"\nMixing time estimates (bias ≤ {epsilon}):")
    for rho in [0.9, 0.7, 0.5, 0.3, 0.1]:
        # Find minimum n such that ρ^n * ‖f‖ < epsilon
        norm_f = np.max(np.abs(f_centered))
        if rho > 0:
            n_mix = int(np.ceil(np.log(epsilon / norm_f) / np.log(rho)))
            n_mix = max(n_mix, 0)
        else:
            n_mix = 1
        
        # Verify by iteration
        current = f_centered.copy()
        for _ in range(n_mix):
            current = product_noise_fast(L, rho, current)
        actual_bias = np.max(np.abs(current))
        
        print(f"  ρ={rho:.1f}: t_mix = {n_mix:3d}, "
              f"actual max|bias| = {actual_bias:.2e}")


# ============================================================
# Application 3: Junta Detection on Ternary Cubes
# ============================================================

def app_junta_detection():
    """Detect whether a function on the ternary cube is a junta.
    
    A k-junta depends on at most k coordinates. We use the spectral
    decomposition to detect this: a k-junta has zero energy at degrees > k.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Junta Detection via Spectral Analysis")
    print("=" * 60)
    
    L = 4
    cube = BerggrenWordCube(L)
    
    # Function 1: Depends on coordinate 0 only (1-junta)
    f1 = np.array([w[0] for w in cube.words], dtype=float)
    
    # Function 2: Depends on coordinates 0 and 2 (2-junta)
    f2 = np.array([w[0] * w[2] for w in cube.words], dtype=float)
    
    # Function 3: Depends on all coordinates (not a low-degree junta)
    np.random.seed(123)
    f3 = np.random.randn(3**L)
    
    functions = [
        ("1-junta (coord 0)", f1),
        ("2-junta (coords 0,2)", f2),
        ("Random (all coords)", f3),
    ]
    
    for name, f in functions:
        components = homogeneous_decomposition(L, f)
        energies = [np.sum(c**2) / 3**L for c in components]
        total_energy = sum(energies)
        
        # Find effective degree (where 99% of energy is)
        cumulative = 0
        effective_degree = L
        for d, e in enumerate(energies):
            cumulative += e
            if cumulative >= 0.99 * total_energy:
                effective_degree = d
                break
        
        # Compute influences
        _, influences = total_influence(L, f)
        
        print(f"\n{name}:")
        print(f"  Degree energies: {[f'{e:.4f}' for e in energies]}")
        print(f"  Effective degree (99% energy): {effective_degree}")
        print(f"  Influences: {[f'{inf:.4f}' for inf in influences]}")


# ============================================================
# Application 4: Parity Statistics of Pythagorean Triples
# ============================================================

def app_parity_statistics():
    """Analyze parity patterns in Berggren-generated Pythagorean triples.
    
    We study how the parity of (a mod 2, b mod 2) distributes
    across the Berggren tree, using spectral methods.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Parity Patterns in Pythagorean Triples")
    print("=" * 60)
    
    start = np.array([3, 4, 5])
    
    for L in range(1, 7):
        words = list(iterproduct(range(3), repeat=L))
        n_words = len(words)
        
        # Compute (a mod 2, b mod 2) for each generated triple
        parity_counts = {}
        for w in words:
            triple = berggren_walk(start, w)
            key = (triple[0] % 2, triple[1] % 2)
            parity_counts[key] = parity_counts.get(key, 0) + 1
        
        print(f"\nL={L} ({n_words} triples):")
        for key in sorted(parity_counts.keys()):
            frac = parity_counts[key] / n_words
            print(f"  (a≡{key[0]}, b≡{key[1]}) mod 2: "
                  f"{parity_counts[key]:5d} ({frac:.4f})")


# ============================================================
# Application 5: Noise Stability Phase Diagram
# ============================================================

def app_noise_stability():
    """Compute noise stability for various function classes.
    
    The noise stability Stab_ρ(f) = E[f(x)·f(y)] where (x,y) are ρ-correlated
    measures how robust f is to random perturbation.
    
    By the spectral theorem: Stab_ρ(f) = Σ_d ρ^(2d) · ‖f_d‖²_2
    """
    print("\n" + "=" * 60)
    print("APPLICATION 5: Noise Stability Analysis")
    print("=" * 60)
    
    L = 3
    cube = BerggrenWordCube(L)
    n = 3**L
    
    # Define various functions
    # Dictator (depends on coord 0)
    f_dict = np.array([1 if w[0] == 0 else -1 for w in cube.words], dtype=float)
    
    # Majority-like (depends on all coords)
    f_maj = np.array([1 if sum(w) >= (3*L)//2 else -1 for w in cube.words], dtype=float)
    
    # Random balanced
    np.random.seed(42)
    perm = np.random.permutation(n)
    f_rand = np.ones(n)
    f_rand[perm[:n//2]] = -1
    
    functions = [
        ("Dictator", f_dict),
        ("Majority-like", f_maj),
        ("Random balanced", f_rand),
    ]
    
    rho_values = np.linspace(0, 1, 21)
    
    for name, f in functions:
        components = homogeneous_decomposition(L, f)
        l2_norms_sq = [np.sum(c**2) / n for c in components]
        
        stabilities = []
        for rho in rho_values:
            stab = sum(rho**(2*d) * e for d, e in enumerate(l2_norms_sq))
            stabilities.append(stab)
        
        ns_values = [noise_sensitivity(L, rho, f) for rho in rho_values]
        
        print(f"\n{name}:")
        print(f"  Degree energies: {[f'{e:.4f}' for e in l2_norms_sq]}")
        print(f"  Stability at ρ=0.99: {stabilities[-2]:.4f}")
        print(f"  Stability at ρ=0.50: {stabilities[10]:.4f}")
        print(f"  Sensitivity at ρ=0.50: {ns_values[10]:.4f}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    app_pseudorandomness()
    app_mixing_time()
    app_junta_detection()
    app_parity_statistics()
    app_noise_stability()
    
    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demonstration of Product Noise and Spectral Structure on Berggren Word Cubes.

This script provides concrete numerical examples illustrating the key theorems:
1. Single-site noise operator eigenvalues
2. Product noise eigenvalue decomposition
3. Spectral decay / bias bound
4. Convergence visualization
"""

import numpy as np
from itertools import product as iterproduct
import json

# ============================================================
# 1. Single-Site Noise Operator
# ============================================================

def single_site_noise(rho: float, f: np.ndarray) -> np.ndarray:
    """Apply the single-site noise operator T_rho to f : Fin 3 -> R.
    
    T_rho f(x) = rho * f(x) + (1 - rho)/3 * sum_y f(y)
    
    Args:
        rho: Noise parameter in [0, 1]
        f: Array of length 3
    
    Returns:
        T_rho f as array of length 3
    """
    mean = np.sum(f) / 3.0
    return rho * f + (1 - rho) * mean


def noise_kernel(rho: float, a: int, b: int) -> float:
    """Noise kernel K_rho(a, b) for a, b in {0, 1, 2}."""
    if a == b:
        return rho + (1 - rho) / 3
    else:
        return (1 - rho) / 3


def demo_single_site():
    """Demonstrate Theorem A: Single-site spectral decomposition."""
    print("=" * 60)
    print("THEOREM A: Single-Site Noise Operator Eigenvalues")
    print("=" * 60)
    
    rho = 0.7
    
    # Test 1: Constants are eigenvectors with eigenvalue 1
    c = 5.0
    f_const = np.array([c, c, c])
    result = single_site_noise(rho, f_const)
    print(f"\nρ = {rho}")
    print(f"Constant function f = [{c}, {c}, {c}]")
    print(f"T_ρ f = {result}")
    print(f"Eigenvalue 1: T_ρ f == f? {np.allclose(result, f_const)}")
    
    # Test 2: Mean-zero functions are eigenvectors with eigenvalue ρ
    f_mz = np.array([1.0, -1.0, 0.0])
    assert abs(np.sum(f_mz)) < 1e-12, "f should be mean-zero"
    result = single_site_noise(rho, f_mz)
    expected = rho * f_mz
    print(f"\nMean-zero function f = {f_mz}")
    print(f"T_ρ f = {result}")
    print(f"ρ·f   = {expected}")
    print(f"Eigenvalue ρ: T_ρ f == ρ·f? {np.allclose(result, expected)}")
    
    # Test 3: Another mean-zero function
    f_mz2 = np.array([1.0, 1.0, -2.0])
    result2 = single_site_noise(rho, f_mz2)
    expected2 = rho * f_mz2
    print(f"\nMean-zero function f = {f_mz2}")
    print(f"T_ρ f = {result2}")
    print(f"ρ·f   = {expected2}")
    print(f"Eigenvalue ρ: T_ρ f == ρ·f? {np.allclose(result2, expected2)}")


# ============================================================
# 2. Product Noise Operator
# ============================================================

def enumerate_words(L: int):
    """Enumerate all words in (Fin 3)^L."""
    return list(iterproduct(range(3), repeat=L))


def product_noise(L: int, rho: float, f: np.ndarray) -> np.ndarray:
    """Apply the product noise operator to f : (Fin 3)^L -> R.
    
    (T_ρ f)(w) = Σ_{w'} Π_i K_ρ(w_i, w'_i) * f(w')
    
    Args:
        L: Word length
        rho: Noise parameter
        f: Array indexed by words (length 3^L)
    
    Returns:
        T_ρ f as array of same length
    """
    words = enumerate_words(L)
    n = len(words)
    result = np.zeros(n)
    
    for idx_x, w_x in enumerate(words):
        for idx_y, w_y in enumerate(words):
            kernel = 1.0
            for i in range(L):
                kernel *= noise_kernel(rho, w_x[i], w_y[i])
            result[idx_x] += kernel * f[idx_y]
    
    return result


def make_homogeneous_function(L: int, S: set, basis_choices: dict = None):
    """Create a function in homogeneousDegreeSubmodule L |S|.
    
    The function is mean-zero at coordinates in S and constant elsewhere.
    We use simple mean-zero basis vectors: e1 = (1, -1, 0) for each coordinate in S.
    
    Args:
        L: Word length
        S: Set of coordinates where function is mean-zero
        basis_choices: Optional dict mapping coord -> mean-zero vector
    
    Returns:
        Function as numpy array indexed by words
    """
    if basis_choices is None:
        basis_choices = {i: np.array([1.0, -1.0, 0.0]) for i in S}
    
    words = enumerate_words(L)
    f = np.zeros(len(words))
    
    for idx, w in enumerate(words):
        val = 1.0
        for i in range(L):
            if i in S:
                val *= basis_choices[i][w[i]]
            # else: constant factor 1
        f[idx] = val
    
    return f


def demo_product_noise():
    """Demonstrate Theorem C: Product noise eigenvalue decomposition."""
    print("\n" + "=" * 60)
    print("THEOREM C: Product Noise Eigenvalue Decomposition")
    print("=" * 60)
    
    L = 3
    rho = 0.6
    
    for d in range(L + 1):
        # Create functions of homogeneous degree d
        if d == 0:
            S = set()
        elif d == 1:
            S = {0}
        elif d == 2:
            S = {0, 2}
        else:
            S = {0, 1, 2}
        
        f = make_homogeneous_function(L, S)
        Tf = product_noise(L, rho, f)
        expected = (rho ** d) * f
        
        is_eigen = np.allclose(Tf, expected)
        print(f"\nDegree d={d}, S={S}")
        print(f"  ‖f‖ = {np.max(np.abs(f)):.4f}")
        print(f"  ‖T_ρ f - ρ^d · f‖_∞ = {np.max(np.abs(Tf - expected)):.2e}")
        print(f"  Eigenvalue ρ^{d} = {rho**d:.4f}")
        print(f"  T_ρ f == ρ^{d} · f? {is_eigen}")


# ============================================================
# 3. Spectral Decay / Bias Bound
# ============================================================

def demo_spectral_decay():
    """Demonstrate Theorem D: Spectral decay implies bias bound."""
    print("\n" + "=" * 60)
    print("THEOREM D: Spectral Bias Bound (Exponential Decay)")
    print("=" * 60)
    
    L = 3
    rho = 0.5
    
    for d in [1, 2, 3]:
        if d == 1:
            S = {1}
        elif d == 2:
            S = {0, 2}
        else:
            S = {0, 1, 2}
        
        f = make_homogeneous_function(L, S)
        norm_f = np.max(np.abs(f))
        
        print(f"\n--- Degree d={d}, ρ={rho} ---")
        print(f"  Predicted decay rate: (ρ^d)^n = ({rho**d:.4f})^n")
        
        current = f.copy()
        for n in range(8):
            norm_current = np.max(np.abs(current))
            bound = (rho ** d) ** n * norm_f
            print(f"  n={n}: ‖T^n f‖ = {norm_current:.6f}, "
                  f"bound (ρ^d)^n ‖f‖ = {bound:.6f}, "
                  f"ratio = {norm_current / max(bound, 1e-15):.4f}")
            current = product_noise(L, rho, current)


# ============================================================
# 4. Degree Submodule Verification
# ============================================================

def demo_degree_submodule():
    """Demonstrate Theorem B: Degree submodule properties."""
    print("\n" + "=" * 60)
    print("THEOREM B: Degree Submodule & Preservation")
    print("=" * 60)
    
    L = 2
    rho = 0.8
    
    # A function depending on coordinate 0 only
    words = enumerate_words(L)
    f = np.zeros(len(words))
    for idx, w in enumerate(words):
        f[idx] = w[0]  # Depends on first coordinate only
    
    # Apply product noise
    Tf = product_noise(L, rho, f)
    
    # Check that Tf also depends on coordinate 0 only
    depends_on_0_only = True
    for idx1, w1 in enumerate(words):
        for idx2, w2 in enumerate(words):
            if w1[0] == w2[0] and abs(Tf[idx1] - Tf[idx2]) > 1e-10:
                depends_on_0_only = False
                break
    
    print(f"\nL={L}, ρ={rho}")
    print(f"f depends on coordinate 0 only (degree ≤ 1)")
    print(f"T_ρ f also depends on coordinate 0 only? {depends_on_0_only}")
    
    # Decompose f into constant + mean-zero at coord 0
    mean_f = np.mean(f)  # over all words
    f_const = np.full(len(words), mean_f)
    f_mz = f - f_const
    
    # Check: is f_mz mean-zero at coordinate 0?
    for w_base in enumerate_words(L - 1):
        s = 0
        for v in range(3):
            w_full = (v,) + tuple(w_base)
            idx = words.index(w_full)
            s += f_mz[idx]
        # Actually we need mean-zero at coord 0 for each fixed other coord
    
    print(f"\nf = {f}")
    print(f"T_ρ f = {Tf}")
    print(f"Constant part: {f_const}")


# ============================================================
# 5. Convergence to Uniform
# ============================================================

def demo_convergence():
    """Show convergence of iterated noise to the uniform distribution."""
    print("\n" + "=" * 60)
    print("CONVERGENCE: Iterated Noise → Uniform")
    print("=" * 60)
    
    L = 2
    rho = 0.5
    words = enumerate_words(L)
    n_words = len(words)
    
    # Start with a delta function at word (0, 0)
    f = np.zeros(n_words)
    f[0] = 1.0
    uniform = np.ones(n_words) / n_words
    
    print(f"\nL={L}, ρ={rho}, starting from δ_(0,0)")
    print(f"Uniform = {1/n_words:.4f} at each word")
    
    current = f.copy()
    for n in range(10):
        dist = np.max(np.abs(current - uniform * np.sum(current)))
        print(f"  n={n}: max|f - uniform| = {dist:.8f}, "
              f"predicted bound ~ ρ^n = {rho**n:.8f}")
        current = product_noise(L, rho, current)


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_single_site()
    demo_product_noise()
    demo_spectral_decay()
    demo_degree_submodule()
    demo_convergence()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Product Noise Spectral Calculus on Berggren Word Cubes.

Generates publication-quality figures showing:
1. Eigenvalue decay spectrum
2. Spectral decomposition energy distribution
3. Noise stability phase diagram
4. Mixing convergence curves
5. Influence distribution
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as iterproduct
import base64
from io import BytesIO

from algorithms import (
    product_noise_fast, homogeneous_decomposition,
    noise_sensitivity, total_influence, BerggrenWordCube
)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_eigenvalue_spectrum():
    """Visualize the eigenvalue spectrum ρ^d for various ρ."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    L = 8
    degrees = np.arange(L + 1)
    
    # Left: eigenvalues vs degree
    for rho in [0.9, 0.7, 0.5, 0.3, 0.1]:
        eigenvalues = rho ** degrees
        ax1.plot(degrees, eigenvalues, 'o-', label=f'ρ = {rho}', markersize=6)
    
    ax1.set_xlabel('Degree d', fontsize=13)
    ax1.set_ylabel('Eigenvalue ρ^d', fontsize=13)
    ax1.set_title('Eigenvalue Spectrum of Product Noise', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.set_yscale('log')
    ax1.set_ylim(1e-8, 2)
    ax1.grid(True, alpha=0.3)
    
    # Right: spectral gap visualization
    rho_values = np.linspace(0.01, 0.99, 100)
    for d in [1, 2, 3, 4, 5]:
        gaps = 1 - rho_values**d
        ax2.plot(rho_values, gaps, label=f'd = {d}', linewidth=2)
    
    ax2.set_xlabel('Noise parameter ρ', fontsize=13)
    ax2.set_ylabel('Spectral gap 1 - ρ^d', fontsize=13)
    ax2.set_title('Spectral Gap by Degree', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    fig.tight_layout()
    return fig_to_base64(fig), fig


def viz_decomposition_energy():
    """Visualize energy distribution across degrees."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    L = 4
    cube = BerggrenWordCube(L)
    n = 3**L
    
    # Three different function types
    np.random.seed(42)
    
    # 1. Dictator (1-junta)
    f1 = np.array([1 if w[0] == 0 else -1 for w in cube.words], dtype=float)
    
    # 2. AND-like (depends on 2 coords)
    f2 = np.array([1 if w[0] == w[1] else -1 for w in cube.words], dtype=float)
    
    # 3. Random function
    f3 = np.random.randn(n)
    
    functions = [
        ("Dictator (1-junta)", f1),
        ("Equality (2-junta)", f2),
        ("Random function", f3),
    ]
    
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, L + 1))
    
    for ax, (name, f) in zip(axes, functions):
        components = homogeneous_decomposition(L, f)
        energies = [np.sum(c**2) / n for c in components]
        total = sum(energies)
        fractions = [e / total if total > 0 else 0 for e in energies]
        
        bars = ax.bar(range(L + 1), fractions, color=colors, edgecolor='black', linewidth=0.5)
        ax.set_xlabel('Degree d', fontsize=12)
        ax.set_ylabel('Energy fraction', fontsize=12)
        ax.set_title(name, fontsize=13)
        ax.set_xticks(range(L + 1))
        ax.set_ylim(0, 1.1)
        ax.grid(True, alpha=0.3, axis='y')
    
    fig.suptitle('Spectral Energy Distribution (L=4)', fontsize=15, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig), fig


def viz_mixing_convergence():
    """Visualize convergence under iterated noise."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    L = 3
    
    # Create a mean-zero function
    cube = BerggrenWordCube(L)
    n = 3**L
    np.random.seed(42)
    f = np.random.randn(n)
    f -= np.mean(f)  # center
    
    # Left: sup-norm decay
    for rho in [0.9, 0.7, 0.5, 0.3]:
        norms = []
        current = f.copy()
        for step in range(20):
            norms.append(np.max(np.abs(current)))
            current = product_noise_fast(L, rho, current)
        ax1.semilogy(range(20), norms, 'o-', label=f'ρ = {rho}', markersize=4)
    
    ax1.set_xlabel('Iterations n', fontsize=13)
    ax1.set_ylabel('‖T^n f‖_∞', fontsize=13)
    ax1.set_title('Norm Decay Under Iterated Noise', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    # Right: per-degree decay
    rho = 0.5
    components = homogeneous_decomposition(L, f)
    
    for d in range(1, L + 1):
        if np.max(np.abs(components[d])) < 1e-10:
            continue
        norms = []
        current = components[d].copy()
        for step in range(15):
            norms.append(np.max(np.abs(current)))
            current = product_noise_fast(L, rho, current)
        
        # Theoretical line
        theory = [norms[0] * (rho**d)**step for step in range(15)]
        
        ax2.semilogy(range(15), norms, 'o', label=f'd={d} (actual)', markersize=5)
        ax2.semilogy(range(15), theory, '--', label=f'd={d} (theory ρ^{{{d}n}})', alpha=0.7)
    
    ax2.set_xlabel('Iterations n', fontsize=13)
    ax2.set_ylabel('‖T^n f_d‖_∞', fontsize=13)
    ax2.set_title(f'Per-Degree Decay (ρ = {rho})', fontsize=14)
    ax2.legend(fontsize=10, ncol=2)
    ax2.grid(True, alpha=0.3)
    
    fig.tight_layout()
    return fig_to_base64(fig), fig


def viz_noise_stability_phase():
    """Visualize noise stability as a function of ρ."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    L = 4
    cube = BerggrenWordCube(L)
    n = 3**L
    
    # Different function types
    f_dict = np.array([1 if w[0] == 0 else -1 for w in cube.words], dtype=float)
    
    np.random.seed(42)
    f_rand = np.random.randn(n)
    f_rand -= np.mean(f_rand)
    f_rand /= np.sqrt(np.sum(f_rand**2) / n)
    
    f_high = np.zeros(n)
    for idx, w in enumerate(cube.words):
        f_high[idx] = np.prod([w[i] - 1 for i in range(L)])
    f_high -= np.mean(f_high)
    if np.sum(f_high**2) > 0:
        f_high /= np.sqrt(np.sum(f_high**2) / n)
    
    functions = [
        ("Dictator (low degree)", f_dict, 'blue'),
        ("Random", f_rand, 'green'),
        ("High-degree", f_high, 'red'),
    ]
    
    rho_values = np.linspace(0, 1, 50)
    
    for name, f, color in functions:
        components = homogeneous_decomposition(L, f)
        l2_norms = [np.sum(c**2) / n for c in components]
        
        stabilities = []
        for rho in rho_values:
            stab = sum(rho**(2*d) * e for d, e in enumerate(l2_norms))
            stabilities.append(stab)
        
        ax.plot(rho_values, stabilities, label=name, color=color, linewidth=2.5)
    
    ax.set_xlabel('Correlation ρ', fontsize=13)
    ax.set_ylabel('Noise Stability Stab_ρ(f)', fontsize=13)
    ax.set_title('Noise Stability Phase Diagram (L=4)', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    return fig_to_base64(fig), fig


def viz_influence_distribution():
    """Visualize coordinate influence distribution."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    L = 5
    cube = BerggrenWordCube(L)
    n = 3**L
    
    # Function depending mainly on first 2 coordinates
    f1 = np.zeros(n)
    for idx, w in enumerate(cube.words):
        f1[idx] = 3 * w[0] + 2 * w[1] + 0.1 * w[2] + 0.01 * (w[3] if L > 3 else 0)
    
    _, influences1 = total_influence(L, f1)
    
    # Random function
    np.random.seed(42)
    f2 = np.random.randn(n)
    _, influences2 = total_influence(L, f2)
    
    # Plot influences
    x = np.arange(L)
    width = 0.35
    
    ax1.bar(x, influences1, width=0.6, color='steelblue', edgecolor='black')
    ax1.set_xlabel('Coordinate i', fontsize=13)
    ax1.set_ylabel('Influence Inf_i(f)', fontsize=13)
    ax1.set_title('Near-Junta Function', fontsize=14)
    ax1.set_xticks(x)
    ax1.grid(True, alpha=0.3, axis='y')
    
    ax2.bar(x, influences2, width=0.6, color='coral', edgecolor='black')
    ax2.set_xlabel('Coordinate i', fontsize=13)
    ax2.set_ylabel('Influence Inf_i(f)', fontsize=13)
    ax2.set_title('Random Function', fontsize=14)
    ax2.set_xticks(x)
    ax2.grid(True, alpha=0.3, axis='y')
    
    fig.suptitle('Coordinate Influence Distribution (L=5)', fontsize=15, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig), fig


def generate_all_visualizations():
    """Generate all visualizations and return as dict of base64 images."""
    print("Generating visualizations...")
    
    results = {}
    
    b64, _ = viz_eigenvalue_spectrum()
    results['eigenvalue_spectrum'] = b64
    print("  ✓ Eigenvalue spectrum")
    
    b64, _ = viz_decomposition_energy()
    results['decomposition_energy'] = b64
    print("  ✓ Decomposition energy")
    
    b64, _ = viz_mixing_convergence()
    results['mixing_convergence'] = b64
    print("  ✓ Mixing convergence")
    
    b64, _ = viz_noise_stability_phase()
    results['noise_stability'] = b64
    print("  ✓ Noise stability")
    
    b64, _ = viz_influence_distribution()
    results['influence_distribution'] = b64
    print("  ✓ Influence distribution")
    
    print(f"Generated {len(results)} visualizations.")
    return results


if __name__ == "__main__":
    results = generate_all_visualizations()
    
    # Save as individual PNGs for inspection
    for name, data_uri in results.items():
        # Extract base64 data
        b64_data = data_uri.split(",")[1]
        img_data = base64.b64decode(b64_data)
        filename = f"{name}.png"
        with open(filename, 'wb') as f:
            f.write(img_data)
        print(f"Saved {filename}")

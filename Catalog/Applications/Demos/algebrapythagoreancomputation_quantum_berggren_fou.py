#!/usr/bin/env python3
"""
Applications of Berggren Fourier Analysis

Demonstrates practical applications of the multiresolution analysis:
1. Efficient search for triples with specific hypotenuse properties
2. Compression of arithmetic signals on the Berggren tree
3. Anomaly detection in Pythagorean triple distributions
4. Period detection in modular arithmetic observables
"""

import numpy as np
from collections import defaultdict, Counter
from algorithms import (
    berggren_evaluate, berggren_layer, BerggrenWaveletTransform,
    detect_prefix_depth, energy_spectrum, ROOT_TRIPLE
)

GEN_NAMES = ['A', 'B', 'C']


# ==============================================================================
# Application 1: Arithmetic Signal Compression
# ==============================================================================

def demo_signal_compression():
    """
    Compress arithmetic signals on the Berggren tree using wavelet sparsity.

    If a signal is approximately prefix-constant, most of its wavelet
    coefficients are near zero. We can achieve lossy compression by
    keeping only the significant coefficients.
    """
    print("=" * 70)
    print("APPLICATION 1: Arithmetic Signal Compression")
    print("=" * 70)

    depth = 4
    words = berggren_layer(depth)
    N = len(words)
    transform = BerggrenWaveletTransform(depth)

    # Test signal: hypotenuse values
    hyp = np.array([berggren_evaluate(w)[2] for w in words], dtype=float)

    coeffs = transform.forward(hyp)
    total_coeffs = len(coeffs)

    # Sort coefficients by magnitude
    coeff_list = [(k, abs(v)) for k, v in coeffs.items()]
    coeff_list.sort(key=lambda x: -x[1])

    print(f"\n  Signal: hypotenuse values at depth {depth} ({N} nodes)")
    print(f"  Total coefficients: {total_coeffs}")
    print(f"  Signal range: [{int(min(hyp))}, {int(max(hyp))}]")

    # Compression at different levels
    for keep_frac in [1.0, 0.5, 0.25, 0.1]:
        n_keep = max(1, int(keep_frac * total_coeffs))
        kept_keys = set(k for k, _ in coeff_list[:n_keep])
        sparse_coeffs = {k: v for k, v in coeffs.items() if k in kept_keys}

        f_rec = transform.inverse(sparse_coeffs)
        error = np.max(np.abs(hyp - f_rec))
        rel_error = error / np.max(np.abs(hyp))
        ratio = n_keep / total_coeffs

        print(f"  Keep {100*keep_frac:5.1f}% ({n_keep:3d}/{total_coeffs}): "
              f"max error = {error:8.2f}, relative = {rel_error:.4f}")

    print()


# ==============================================================================
# Application 2: Period Detection in Modular Observables
# ==============================================================================

def demo_period_detection():
    """
    Detect hidden periodicity in modular arithmetic observables.

    The Berggren tree has interesting modular structure: hypotenuse values
    modulo small primes exhibit patterns related to the tree structure.
    The wavelet transform can detect these patterns.
    """
    print("=" * 70)
    print("APPLICATION 2: Period Detection in Modular Observables")
    print("=" * 70)

    depth = 4
    words = berggren_layer(depth)
    N = len(words)
    transform = BerggrenWaveletTransform(depth)

    for q in [2, 3, 4, 5, 6, 7, 8, 12]:
        hyp_mod = np.array([berggren_evaluate(w)[2] % q for w in words], dtype=float)
        coeffs = transform.forward(hyp_mod)

        # Analyze sparsity
        prefix_depth = detect_prefix_depth(coeffs, threshold=1e-10)

        # Count nonzero coefficients per level
        level_stats = {}
        for k in range(depth):
            level_coeffs = [(key, v) for key, v in coeffs.items()
                          if isinstance(key, tuple) and key[0] == k]
            n_nonzero = sum(1 for _, v in level_coeffs if abs(v) > 1e-10)
            n_total = len(level_coeffs)
            level_stats[k] = (n_nonzero, n_total)

        total_nonzero = sum(nz for nz, _ in level_stats.values())
        total = sum(t for _, t in level_stats.values())
        sparsity = 1 - total_nonzero / total if total > 0 else 0

        # Distribution of residues
        residue_counts = Counter(int(x) for x in hyp_mod)

        print(f"\n  Hypotenuse mod {q}:")
        print(f"    Residue distribution: {dict(sorted(residue_counts.items()))}")
        print(f"    Detected prefix depth: {prefix_depth}")
        print(f"    Sparsity: {sparsity:.2%} ({total - total_nonzero}/{total} zero coefficients)")

    print()


# ==============================================================================
# Application 3: Anomaly Detection
# ==============================================================================

def demo_anomaly_detection():
    """
    Detect anomalous triples by looking for unexpected wavelet energy.

    If a function on the Berggren tree has most of its energy at coarse
    scales, fine-scale energy indicates local anomalies.
    """
    print("=" * 70)
    print("APPLICATION 3: Anomaly Detection in Triple Distributions")
    print("=" * 70)

    depth = 4
    words = berggren_layer(depth)
    N = len(words)
    transform = BerggrenWaveletTransform(depth)

    # Signal: log(hypotenuse) - measures growth rate
    log_hyp = np.array([np.log(berggren_evaluate(w)[2]) for w in words])

    coeffs = transform.forward(log_hyp)

    # Find triples with highest fine-scale wavelet energy
    fine_energy = np.zeros(N)
    for k in range(depth):
        prefixes = sorted(set(w[:k] for w in words))
        for u in prefixes:
            for j in range(2):
                c = coeffs.get((k, u, j), 0)
                if abs(c) > 0:
                    psi = transform._wavelet(k, u, j)
                    fine_energy += abs(c * psi)**2

    # Top anomalous triples (highest fine-scale energy)
    anomaly_idx = np.argsort(-fine_energy)
    print(f"\n  Signal: log(hypotenuse) at depth {depth}")
    print(f"\n  Top 10 triples by fine-scale wavelet energy:")
    for rank, idx in enumerate(anomaly_idx[:10]):
        w = words[idx]
        triple = berggren_evaluate(w)
        gen_str = ''.join(GEN_NAMES[g] for g in w)
        print(f"    {rank+1:2d}. {gen_str:>5s} → ({triple[0]:>5}, {triple[1]:>5}, {triple[2]:>5})"
              f"  energy = {fine_energy[idx]:.4f}")

    print()


# ==============================================================================
# Application 4: Structural Analysis of the Berggren Tree
# ==============================================================================

def demo_structural_analysis():
    """
    Use the wavelet transform to analyze structural properties of the tree.
    """
    print("=" * 70)
    print("APPLICATION 4: Structural Analysis of Berggren Tree")
    print("=" * 70)

    depth = 4
    words = berggren_layer(depth)
    N = len(words)

    # Compare energy spectra of different observables
    observables = {
        'hypotenuse c': lambda w: berggren_evaluate(w)[2],
        'side a': lambda w: berggren_evaluate(w)[0],
        'side b': lambda w: berggren_evaluate(w)[1],
        'a + b': lambda w: berggren_evaluate(w)[0] + berggren_evaluate(w)[1],
        'a - b': lambda w: berggren_evaluate(w)[0] - berggren_evaluate(w)[1],
        'c - a': lambda w: berggren_evaluate(w)[2] - berggren_evaluate(w)[0],
    }

    print(f"\n  Energy spectrum comparison (depth {depth}, {N} nodes):")
    print(f"  {'Observable':<15s}  {'Scaling':>8s}", end='')
    for k in range(depth):
        print(f"  {'Level '+str(k):>8s}", end='')
    print()
    print("  " + "-" * (15 + 9 + depth * 10))

    for name, obs_fn in observables.items():
        signal = np.array([obs_fn(w) for w in words], dtype=float)
        spectrum = energy_spectrum(signal, words, depth)

        print(f"  {name:<15s}  {spectrum['scaling']:8.4f}", end='')
        for k in range(depth):
            print(f"  {spectrum[k]:8.4f}", end='')
        print()

    # Verify all triples are Pythagorean
    print(f"\n  Pythagorean verification:")
    all_pyth = True
    for w in words:
        t = berggren_evaluate(w)
        if t[0]**2 + t[1]**2 != t[2]**2:
            print(f"    FAILED: {''.join(GEN_NAMES[g] for g in w)} → {tuple(t)}")
            all_pyth = False
    print(f"    All {N} triples verified: {'✓' if all_pyth else '✗'}")

    # GCD analysis (primitivity)
    from math import gcd
    all_primitive = True
    for w in words:
        t = berggren_evaluate(w)
        g = gcd(gcd(abs(int(t[0])), abs(int(t[1]))), abs(int(t[2])))
        if g != 1:
            print(f"    NOT PRIMITIVE: {''.join(GEN_NAMES[g] for g in w)} → {tuple(t)}, gcd={g}")
            all_primitive = False
    print(f"    All {N} triples primitive: {'✓' if all_primitive else '✗'}")

    print()


# ==============================================================================
# Main
# ==============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   BERGGREN FOURIER ANALYSIS - APPLICATIONS SUITE                   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_signal_compression()
    demo_period_detection()
    demo_anomaly_detection()
    demo_structural_analysis()

    print("All applications demonstrated.")


#!/usr/bin/env python3
"""
Quantum Berggren Fourier Duality - Interactive Demonstration

This script demonstrates the multiresolution analysis on the Berggren tree
of primitive Pythagorean triples, including:
- Berggren tree generation and triple evaluation
- Haar wavelet decomposition on the ternary tree
- Forward/inverse wavelet transforms with exact reconstruction
- Spectral sparsity for prefix-constant observables
- Certified robust recovery under perturbation

Author: Generated as companion to formal Lean 4 proofs
"""

import numpy as np
from itertools import product

# ==============================================================================
# Section 1: Berggren Tree Core
# ==============================================================================

# Berggren generator matrices
BERG_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
BERG_B = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]])
BERG_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
GENERATORS = [BERG_A, BERG_B, BERG_C]
GEN_NAMES = ['A', 'B', 'C']

ROOT = np.array([3, 4, 5])

def berggren_eval(word):
    """Evaluate a Berggren word to get the corresponding Pythagorean triple."""
    v = ROOT.copy()
    for letter in word:
        v = GENERATORS[letter] @ v
    return v

def generate_layer(n):
    """Generate all 3^n words of length n."""
    if n == 0:
        return [()]
    return list(product(range(3), repeat=n))

def verify_pythagorean(triple):
    """Verify that a triple satisfies a² + b² = c²."""
    a, b, c = triple
    return a**2 + b**2 == c**2

# ==============================================================================
# Section 2: Wavelet Basis on Ternary Tree
# ==============================================================================

def word_prefix(w, k):
    """Return the first k letters of word w."""
    return w[:k]

def is_prefix_constant(f, words, k):
    """Check if f is constant on k-prefix cylinders."""
    from collections import defaultdict
    groups = defaultdict(set)
    for i, w in enumerate(words):
        groups[word_prefix(w, k)].add(f[i])
    return all(len(vals) == 1 for vals in groups.values())

def detail_wavelet_0(words, k, prefix_u):
    """Detail wavelet flavor 0: distinguishes child 0 from child 1."""
    n = len(words[0]) if words else 0
    psi = np.zeros(len(words), dtype=complex)
    for i, w in enumerate(words):
        if word_prefix(w, k) == prefix_u:
            if w[k] == 0:
                psi[i] = 1.0
            elif w[k] == 1:
                psi[i] = -1.0
    return psi

def detail_wavelet_1(words, k, prefix_u):
    """Detail wavelet flavor 1: distinguishes children {0,1} from child 2."""
    psi = np.zeros(len(words), dtype=complex)
    for i, w in enumerate(words):
        if word_prefix(w, k) == prefix_u:
            if w[k] == 0:
                psi[i] = 1.0
            elif w[k] == 1:
                psi[i] = 1.0
            else:
                psi[i] = -2.0
    return psi

def scaling_wavelet(n_words):
    """The global scaling wavelet: constant 1."""
    return np.ones(n_words, dtype=complex)

# ==============================================================================
# Section 3: Forward and Inverse Wavelet Transform
# ==============================================================================

def forward_transform(f, words):
    """Compute all wavelet coefficients of f."""
    n = len(words[0]) if words else 0
    N = len(words)
    coeffs = {}

    # Scaling coefficient
    coeffs['scaling'] = np.sum(f) / N

    # Detail coefficients
    for k in range(n):
        prefixes = set(word_prefix(w, k) for w in words)
        for u in sorted(prefixes):
            psi0 = detail_wavelet_0(words, k, u)
            psi1 = detail_wavelet_1(words, k, u)
            norm0_sq = np.sum(np.abs(psi0)**2)
            norm1_sq = np.sum(np.abs(psi1)**2)
            if norm0_sq > 0:
                coeffs[('detail0', k, u)] = np.vdot(psi0, f) / norm0_sq
            if norm1_sq > 0:
                coeffs[('detail1', k, u)] = np.vdot(psi1, f) / norm1_sq
    return coeffs

def inverse_transform(coeffs, words):
    """Reconstruct f from wavelet coefficients."""
    n = len(words[0]) if words else 0
    N = len(words)
    f_rec = np.zeros(N, dtype=complex)

    # Scaling contribution
    f_rec += coeffs.get('scaling', 0) * scaling_wavelet(N)

    # Detail contributions
    for k in range(n):
        prefixes = set(word_prefix(w, k) for w in words)
        for u in sorted(prefixes):
            psi0 = detail_wavelet_0(words, k, u)
            psi1 = detail_wavelet_1(words, k, u)
            c0 = coeffs.get(('detail0', k, u), 0)
            c1 = coeffs.get(('detail1', k, u), 0)
            f_rec += c0 * psi0 + c1 * psi1
    return f_rec

# ==============================================================================
# Section 4: Conditional Expectation
# ==============================================================================

def conditional_expectation(f, words, k):
    """Compute conditional expectation at level k."""
    from collections import defaultdict
    n = len(words[0]) if words else 0
    groups = defaultdict(list)
    for i, w in enumerate(words):
        groups[word_prefix(w, k)].append(i)

    result = np.zeros(len(words), dtype=complex)
    for indices in groups.values():
        avg = np.mean([f[i] for i in indices])
        for i in indices:
            result[i] = avg
    return result

# ==============================================================================
# Section 5: Demonstrations
# ==============================================================================

def demo_berggren_tree():
    """Demonstrate Berggren tree generation."""
    print("=" * 70)
    print("DEMO 1: Berggren Tree of Primitive Pythagorean Triples")
    print("=" * 70)
    print(f"\nRoot triple: {ROOT}")
    print(f"Pythagorean check: {ROOT[0]}² + {ROOT[1]}² = {ROOT[0]**2 + ROOT[1]**2} = {ROOT[2]}² = {ROOT[2]**2} ✓")
    print()

    for depth in range(1, 4):
        words = generate_layer(depth)
        print(f"Depth {depth}: {len(words)} triples")
        for w in words[:min(9, len(words))]:
            triple = berggren_eval(w)
            gen_str = ''.join(GEN_NAMES[i] for i in w)
            check = "✓" if verify_pythagorean(triple) else "✗"
            print(f"  {gen_str:>4s} → ({triple[0]:>5}, {triple[1]:>5}, {triple[2]:>5})  "
                  f"  {triple[0]}² + {triple[1]}² = {triple[0]**2 + triple[1]**2}  {check}")
        if len(words) > 9:
            print(f"  ... ({len(words) - 9} more)")
        print()

def demo_wavelet_reconstruction():
    """Demonstrate exact wavelet reconstruction."""
    print("=" * 70)
    print("DEMO 2: Wavelet Perfect Reconstruction")
    print("=" * 70)

    for depth in range(1, 5):
        words = generate_layer(depth)
        N = len(words)

        # Random complex signal
        np.random.seed(42 + depth)
        f = np.random.randn(N) + 1j * np.random.randn(N)

        # Forward → Inverse
        coeffs = forward_transform(f, words)
        f_rec = inverse_transform(coeffs, words)

        error = np.max(np.abs(f - f_rec))
        print(f"  Depth {depth}: {N:>4d} nodes, "
              f"max reconstruction error = {error:.2e}  "
              f"{'✓ EXACT' if error < 1e-10 else '✗ ERROR'}")

    print()

def demo_telescoping_reconstruction():
    """Demonstrate telescoping reconstruction via conditional expectations."""
    print("=" * 70)
    print("DEMO 3: Telescoping Reconstruction (condExp)")
    print("=" * 70)

    depth = 3
    words = generate_layer(depth)
    N = len(words)
    np.random.seed(123)
    f = np.random.randn(N)

    # Compute condExp at each level
    condexps = [conditional_expectation(f, words, k) for k in range(depth + 1)]

    # Verify telescoping: f = condExp(0) + sum of (condExp(k+1) - condExp(k))
    f_tele = condexps[0].copy()
    for k in range(depth):
        f_tele += condexps[k + 1] - condexps[k]

    error = np.max(np.abs(f - f_tele))
    print(f"  Telescoping reconstruction error: {error:.2e}  "
          f"{'✓ EXACT' if error < 1e-10 else '✗ ERROR'}")

    # Show condExp converges to f
    for k in range(depth + 1):
        ce_error = np.max(np.abs(f - condexps[k]))
        print(f"  condExp({k}) approximation error: {ce_error:.6f}")
    print()

def demo_spectral_sparsity():
    """Demonstrate spectral sparsity for prefix-constant functions."""
    print("=" * 70)
    print("DEMO 4: Spectral Sparsity for Prefix-Constant Observables")
    print("=" * 70)

    depth = 3
    words = generate_layer(depth)
    N = len(words)

    for const_depth in range(depth + 1):
        # Create a function constant on const_depth-prefix cylinders
        np.random.seed(const_depth)
        prefix_values = {}
        f = np.zeros(N, dtype=complex)
        for i, w in enumerate(words):
            pfx = word_prefix(w, const_depth)
            if pfx not in prefix_values:
                prefix_values[pfx] = np.random.randn() + 1j * np.random.randn()
            f[i] = prefix_values[pfx]

        coeffs = forward_transform(f, words)

        # Count nonzero detail coefficients at each level
        nonzero_counts = {}
        for k in range(depth):
            count = 0
            total = 0
            for key, val in coeffs.items():
                if isinstance(key, tuple) and key[1] == k:
                    total += 1
                    if abs(val) > 1e-10:
                        count += 1
            nonzero_counts[k] = (count, total)

        print(f"\n  Function constant on depth-{const_depth} cylinders:")
        print(f"    Prefix-constant check: {is_prefix_constant(f, words, const_depth)}")
        for k in range(depth):
            nz, total = nonzero_counts[k]
            vanish = "✓ vanishes" if nz == 0 and k >= const_depth else ""
            print(f"    Detail level {k}: {nz}/{total} nonzero coefficients  {vanish}")
    print()

def demo_hypotenuse_signal():
    """Demonstrate hypotenuse as an arithmetic signal on the Berggren tree."""
    print("=" * 70)
    print("DEMO 5: Hypotenuse as Arithmetic Signal")
    print("=" * 70)

    depth = 3
    words = generate_layer(depth)
    N = len(words)

    # Hypotenuse values
    hyp = np.array([berggren_eval(w)[2] for w in words], dtype=float)
    print(f"\n  Depth {depth}: {N} triples")
    print(f"  Hypotenuse range: [{int(min(hyp))}, {int(max(hyp))}]")
    print(f"  Mean hypotenuse: {np.mean(hyp):.1f}")

    # Wavelet transform of hypotenuse
    coeffs = forward_transform(hyp, words)
    print(f"\n  Scaling coefficient (global avg): {coeffs['scaling']:.2f}")

    # Show coefficient magnitudes by level
    for k in range(depth):
        level_coeffs = [(key, val) for key, val in coeffs.items()
                       if isinstance(key, tuple) and key[1] == k]
        mags = [abs(v) for _, v in level_coeffs]
        print(f"  Detail level {k}: max |coeff| = {max(mags):.2f}, "
              f"mean |coeff| = {np.mean(mags):.2f}, "
              f"count = {len(mags)}")

    # Hypotenuse mod q
    for q in [3, 5, 7]:
        hyp_mod = np.array([berggren_eval(w)[2] % q for w in words], dtype=float)
        coeffs_mod = forward_transform(hyp_mod, words)
        nonzero = sum(1 for k, v in coeffs_mod.items()
                     if isinstance(k, tuple) and abs(v) > 1e-10)
        total = sum(1 for k in coeffs_mod if isinstance(k, tuple))
        print(f"\n  Hypotenuse mod {q}: {nonzero}/{total} nonzero detail coefficients")
    print()

def demo_certified_recovery():
    """Demonstrate certified robust recovery under perturbation."""
    print("=" * 70)
    print("DEMO 6: Certified Robust Recovery")
    print("=" * 70)

    depth = 3
    words = generate_layer(depth)
    N = len(words)

    # Create a prefix-constant signal (sparse in wavelet basis)
    const_depth = 1
    np.random.seed(42)
    prefix_values = {}
    f = np.zeros(N, dtype=complex)
    for i, w in enumerate(words):
        pfx = word_prefix(w, const_depth)
        if pfx not in prefix_values:
            prefix_values[pfx] = np.random.randn() + 1j * np.random.randn()
        f[i] = prefix_values[pfx]

    # Add perturbation
    for eps in [0.0, 0.01, 0.1, 0.5, 1.0]:
        noise = eps * (np.random.randn(N) + 1j * np.random.randn(N))
        g = f + noise

        coeffs_f = forward_transform(f, words)
        coeffs_g = forward_transform(g, words)

        # Detail coefficients at fine levels (≥ const_depth) should be noise only
        fine_coeffs_f = {k: v for k, v in coeffs_f.items()
                        if isinstance(k, tuple) and k[1] >= const_depth}
        fine_coeffs_g = {k: v for k, v in coeffs_g.items()
                        if isinstance(k, tuple) and k[1] >= const_depth}

        max_signal = max(abs(v) for v in fine_coeffs_f.values()) if fine_coeffs_f else 0
        max_noise = max(abs(v) for v in fine_coeffs_g.values()) if fine_coeffs_g else 0

        print(f"  ε = {eps:.2f}: signal fine coeffs max = {max_signal:.2e}, "
              f"noisy fine coeffs max = {max_noise:.2e}")

    print()

# ==============================================================================
# Main
# ==============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   QUANTUM BERGGREN FOURIER DUALITY - DEMONSTRATION SUITE           ║")
    print("║   Multiresolution Analysis on the Primitive Pythagorean Triple Tree ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_berggren_tree()
    demo_wavelet_reconstruction()
    demo_telescoping_reconstruction()
    demo_spectral_sparsity()
    demo_hypotenuse_signal()
    demo_certified_recovery()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import base64
import io
import os

# Read text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read lean file
lean_code = read_file('Bridges/AutoResearch/QuantumBerggrenFourier.lean')
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Generate visualizations as base64
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

from visualizations import (
    plot_berggren_tree, plot_wavelet_basis, plot_spectral_sparsity,
    plot_energy_spectrum, plot_recovery_noise, fig_to_base64
)

viz_data = {}
for name, fig_func in [
    ('berggren_tree', plot_berggren_tree),
    ('wavelet_basis', plot_wavelet_basis),
    ('spectral_sparsity', plot_spectral_sparsity),
    ('energy_spectrum', plot_energy_spectrum),
    ('recovery_noise', plot_recovery_noise),
]:
    fig = fig_func()
    viz_data[name] = fig_to_base64(fig)
    plt.close(fig)

# Build package
package = {
    "title": "Quantum Berggren Fourier Duality via Primitive Triple Wavelets and Certified Period-Finding",
    "domain": "Number Theory / Harmonic Analysis / Signal Processing",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Berggren Tree and Wavelet Transform Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Compression, Period Detection, Anomaly Detection",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Forward Wavelet Transform",
            "pseudocode": """FORWARD-TRANSFORM(f, n):
    c_scaling ← mean(f)
    for k = 0 to n-1:
        for each prefix u of length k:
            for j ∈ {0, 1}:
                ψ ← WAVELET(k, u, j)
                c_{k,u,j} ← ⟨f, ψ⟩ / ‖ψ‖²
    return all coefficients

Complexity: O(3^n · n) time, O(3^n) space"""
        },
        {
            "name": "Inverse Transform (Reconstruction)",
            "pseudocode": """INVERSE-TRANSFORM(coefficients, n):
    f ← c_scaling · 1
    for k = 0 to n-1:
        for each prefix u of length k:
            for j ∈ {0, 1}:
                f ← f + c_{k,u,j} · WAVELET(k, u, j)
    return f

Complexity: O(3^n · n) time, O(3^n) space
Correctness: Formally verified (berggren_wavelet_perfect_reconstruction)"""
        },
        {
            "name": "Sparse Recovery",
            "pseudocode": """SPARSE-RECOVERY(g, k, n):
    coefficients ← FORWARD-TRANSFORM(g, n)
    for each (level, u, j) with level ≥ k:
        coefficients[level, u, j] ← 0
    return INVERSE-TRANSFORM(coefficients, n)

Certified by: detail_vanishes_of_prefix_constant theorem"""
        },
        {
            "name": "Period Detection",
            "pseudocode": """DETECT-PREFIX-DEPTH(g, ε, n):
    coefficients ← FORWARD-TRANSFORM(g, n)
    for k = n-1 down to 0:
        max_coeff ← max |c_{k,u,j}| over all u, j
        if max_coeff > ε · √2:
            return k + 1
    return 0

Certified by: certified_robust_recovery theorem"""
        }
    ],
    "visualizations": [
        {"name": "Berggren Tree Structure", "data": viz_data['berggren_tree']},
        {"name": "Wavelet Basis Functions", "data": viz_data['wavelet_basis']},
        {"name": "Spectral Sparsity Heatmap", "data": viz_data['spectral_sparsity']},
        {"name": "Energy Spectrum of Observables", "data": viz_data['energy_spectrum']},
        {"name": "Certified Recovery Under Noise", "data": viz_data['recovery_noise']},
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json') / 1024:.1f} KB)")


#!/usr/bin/env python3
"""
Visualizations for Berggren Fourier Analysis

Generates publication-quality figures showing:
1. Berggren tree structure with Pythagorean triples
2. Wavelet basis functions on the ternary tree
3. Spectral sparsity heatmap
4. Energy spectrum across scales
5. Certified recovery under noise
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
from itertools import product
from collections import defaultdict
import base64
import io

# Import from our algorithms
from algorithms import (
    berggren_evaluate, berggren_layer, BerggrenWaveletTransform,
    conditional_expectation_cascade, energy_spectrum, ROOT_TRIPLE
)

GEN_NAMES = ['A', 'B', 'C']
COLORS = ['#2196F3', '#FF5722', '#4CAF50']  # Blue, Orange, Green for A, B, C

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    return 'data:image/png;base64,' + base64.b64encode(buf.read()).decode()


def plot_berggren_tree():
    """Visualize the first 3 levels of the Berggren tree."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    ax.set_xlim(-1, 13)
    ax.set_ylim(-0.5, 4.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Berggren Tree of Primitive Pythagorean Triples', fontsize=16, fontweight='bold')

    def draw_node(x, y, triple, label, depth):
        color = '#E3F2FD' if depth == 0 else ('#FFF3E0' if depth == 1 else '#E8F5E9')
        box = FancyBboxPatch((x-0.9, y-0.25), 1.8, 0.5, boxstyle="round,pad=0.1",
                            facecolor=color, edgecolor='#333', linewidth=1.5)
        ax.add_patch(box)
        a, b, c = triple
        ax.text(x, y+0.05, f'({a},{b},{c})', ha='center', va='center', fontsize=7, fontweight='bold')
        ax.text(x, y-0.15, label, ha='center', va='center', fontsize=6, color='#666')

    # Root
    root_x, root_y = 6, 4
    draw_node(root_x, root_y, ROOT_TRIPLE, 'root', 0)

    # Level 1
    level1_x = [2, 6, 10]
    level1_y = 2.5
    for i, x in enumerate(level1_x):
        triple = berggren_evaluate((i,))
        label = GEN_NAMES[i]
        draw_node(x, level1_y, triple, label, 1)
        ax.annotate('', xy=(x, level1_y+0.25), xytext=(root_x, root_y-0.25),
                   arrowprops=dict(arrowstyle='->', color=COLORS[i], lw=1.5))

    # Level 2
    level2_positions = []
    for i in range(3):
        base_x = level1_x[i]
        for j in range(3):
            x = base_x + (j-1) * 1.3
            y = 1.0
            triple = berggren_evaluate((i, j))
            label = GEN_NAMES[i] + GEN_NAMES[j]
            draw_node(x, y, triple, label, 2)
            ax.annotate('', xy=(x, y+0.25), xytext=(base_x, level1_y-0.25),
                       arrowprops=dict(arrowstyle='->', color=COLORS[j], lw=1, alpha=0.7))
            level2_positions.append((x, y))

    fig.tight_layout()
    return fig


def plot_wavelet_basis():
    """Visualize wavelet basis functions at depth 2."""
    depth = 2
    words = berggren_layer(depth)
    N = len(words)
    transform = BerggrenWaveletTransform(depth)

    fig, axes = plt.subplots(3, 3, figsize=(14, 10))
    fig.suptitle('Haar Wavelet Basis on Berggren Tree (depth 2)', fontsize=16, fontweight='bold')

    word_labels = [''.join(GEN_NAMES[g] for g in w) for w in words]

    # Scaling function
    ax = axes[0, 0]
    psi = np.ones(N)
    ax.bar(range(N), psi.real, color='#607D8B', alpha=0.8)
    ax.set_title('Scaling φ', fontsize=11)
    ax.set_xticks(range(N))
    ax.set_xticklabels(word_labels, rotation=45, fontsize=7)
    ax.set_ylim(-2.5, 2.5)

    # Detail wavelets at level 0
    for j in range(2):
        ax = axes[0, j+1]
        psi = transform._wavelet(0, (), j)
        colors = ['#4CAF50' if v > 0 else '#F44336' if v < 0 else '#9E9E9E' for v in psi.real]
        ax.bar(range(N), psi.real, color=colors, alpha=0.8)
        ax.set_title(f'Detail ψ₀,∅,{j}', fontsize=11)
        ax.set_xticks(range(N))
        ax.set_xticklabels(word_labels, rotation=45, fontsize=7)
        ax.set_ylim(-2.5, 2.5)

    # Detail wavelets at level 1
    prefixes_1 = [(0,), (1,), (2,)]
    for idx, u in enumerate(prefixes_1):
        for j in range(2):
            row = 1 + idx // 2
            col = (idx * 2 + j) % 3
            if row < 3 and col < 3:
                ax = axes[row, col]
                psi = transform._wavelet(1, u, j)
                colors = ['#4CAF50' if v > 0 else '#F44336' if v < 0 else '#9E9E9E' for v in psi.real]
                ax.bar(range(N), psi.real, color=colors, alpha=0.8)
                prefix_name = GEN_NAMES[u[0]]
                ax.set_title(f'Detail ψ₁,{prefix_name},{j}', fontsize=11)
                ax.set_xticks(range(N))
                ax.set_xticklabels(word_labels, rotation=45, fontsize=7)
                ax.set_ylim(-2.5, 2.5)

    fig.tight_layout()
    return fig


def plot_spectral_sparsity():
    """Heatmap of wavelet coefficient magnitudes for signals with different prefix depths."""
    depth = 3
    words = berggren_layer(depth)
    N = len(words)
    transform = BerggrenWaveletTransform(depth)

    fig, axes = plt.subplots(1, 4, figsize=(16, 5))
    fig.suptitle('Spectral Sparsity: Coefficient Magnitudes by Prefix Depth', fontsize=14, fontweight='bold')

    for const_depth in range(4):
        ax = axes[const_depth]
        np.random.seed(const_depth + 10)

        # Create prefix-constant signal
        prefix_values = {}
        f = np.zeros(N, dtype=complex)
        for i, w in enumerate(words):
            pfx = w[:const_depth]
            if pfx not in prefix_values:
                prefix_values[pfx] = np.random.randn() + 1j * np.random.randn()
            f[i] = prefix_values[pfx]

        coeffs = transform.forward(f)

        # Build coefficient magnitude matrix
        coeff_mags = []
        for k in range(depth):
            prefixes = sorted(set(w[:k] for w in words))
            level_mags = []
            for u in prefixes:
                for j in range(2):
                    level_mags.append(abs(coeffs.get((k, u, j), 0)))
            coeff_mags.append(level_mags)

        # Normalize
        max_val = max(max(row) for row in coeff_mags if row) if coeff_mags else 1
        if max_val == 0:
            max_val = 1

        # Plot
        max_width = max(len(row) for row in coeff_mags)
        img = np.zeros((depth, max_width))
        for k, row in enumerate(coeff_mags):
            for j, v in enumerate(row):
                img[k, j] = v / max_val

        im = ax.imshow(img, aspect='auto', cmap='YlOrRd', vmin=0, vmax=1)
        ax.set_xlabel('Coefficient index')
        ax.set_ylabel('Scale level')
        ax.set_yticks(range(depth))
        ax.set_title(f'Prefix depth = {const_depth}')

        # Mark zero regions
        for k in range(depth):
            if k >= const_depth:
                ax.axhline(y=k, color='blue', linestyle='--', alpha=0.5, linewidth=2)

    plt.colorbar(im, ax=axes, label='|coefficient| / max', shrink=0.8)
    fig.tight_layout()
    return fig


def plot_energy_spectrum():
    """Bar chart of energy distribution across scales."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 5))
    fig.suptitle('Energy Spectrum of Arithmetic Observables on Berggren Tree', fontsize=14, fontweight='bold')

    depth = 4
    words = berggren_layer(depth)
    N = len(words)

    signals = {
        'Hypotenuse c': np.array([berggren_evaluate(w)[2] for w in words], dtype=float),
        'Side a': np.array([berggren_evaluate(w)[0] for w in words], dtype=float),
        'Hypotenuse mod 5': np.array([berggren_evaluate(w)[2] % 5 for w in words], dtype=float),
    }

    for idx, (name, signal) in enumerate(signals.items()):
        ax = axes[idx]
        spectrum = energy_spectrum(signal, words, depth)

        labels = ['Global\navg'] + [f'Level {k}' for k in range(depth)]
        values = [spectrum['scaling']] + [spectrum[k] for k in range(depth)]
        colors = ['#607D8B'] + [COLORS[k % 3] for k in range(depth)]

        bars = ax.bar(labels, values, color=colors, alpha=0.8, edgecolor='#333', linewidth=0.5)
        ax.set_ylabel('Energy fraction')
        ax.set_title(name, fontsize=12)
        ax.set_ylim(0, 1)

        for bar, val in zip(bars, values):
            if val > 0.01:
                ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02,
                       f'{val:.3f}', ha='center', va='bottom', fontsize=8)

    fig.tight_layout()
    return fig


def plot_recovery_noise():
    """Show certified recovery performance under increasing noise."""
    depth = 3
    words = berggren_layer(depth)
    N = len(words)
    transform = BerggrenWaveletTransform(depth)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle('Certified Recovery Under Noise', fontsize=14, fontweight='bold')

    # Create 1-prefix-constant signal
    np.random.seed(42)
    prefix_values = {(0,): 3+2j, (1,): -1+4j, (2,): 2-3j}
    f = np.zeros(N, dtype=complex)
    for i, w in enumerate(words):
        f[i] = prefix_values[w[:1]]

    # Test recovery
    epsilons = np.linspace(0, 2, 50)
    max_fine_coeffs = []
    reconstruction_errors = []

    for eps in epsilons:
        np.random.seed(0)
        noise = eps * (np.random.randn(N) + 1j * np.random.randn(N))
        g = f + noise

        coeffs_g = transform.forward(g)

        # Max fine coefficient (should be zero for clean signal)
        fine_max = max(abs(coeffs_g.get((k, u, j), 0))
                      for k in range(1, depth)
                      for u in sorted(set(w[:k] for w in words))
                      for j in range(2))
        max_fine_coeffs.append(fine_max)

        # Reconstruction using only coarse coefficients
        sparse_coeffs = {k: v for k, v in coeffs_g.items()
                        if k == 'scaling' or (isinstance(k, tuple) and k[0] < 1)}
        f_rec = transform.inverse(sparse_coeffs)
        reconstruction_errors.append(np.max(np.abs(f - f_rec)))

    # Plot 1: Fine coefficient magnitude vs noise
    ax = axes[0]
    ax.plot(epsilons, max_fine_coeffs, 'b-', linewidth=2, label='Max |detail coeff| (levels ≥ 1)')
    ax.plot(epsilons, epsilons * np.sqrt(2), 'r--', linewidth=1.5, label='Noise bound (ε√2)')
    ax.set_xlabel('Noise level ε')
    ax.set_ylabel('Max fine coefficient magnitude')
    ax.set_title('Fine Coefficient Behavior Under Noise')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Reconstruction error
    ax = axes[1]
    ax.plot(epsilons, reconstruction_errors, 'g-', linewidth=2, label='Reconstruction error')
    ax.plot(epsilons, epsilons * np.sqrt(N), 'r--', linewidth=1.5, label='ε√N bound')
    ax.set_xlabel('Noise level ε')
    ax.set_ylabel('Max |f - f_recovered|')
    ax.set_title('Sparse Recovery Error')
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig


# ==============================================================================
# Generate all figures
# ==============================================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    figs = {
        'berggren_tree': plot_berggren_tree(),
        'wavelet_basis': plot_wavelet_basis(),
        'spectral_sparsity': plot_spectral_sparsity(),
        'energy_spectrum': plot_energy_spectrum(),
        'recovery_noise': plot_recovery_noise(),
    }

    for name, fig in figs.items():
        filename = f'{name}.png'
        fig.savefig(filename, dpi=150, bbox_inches='tight', facecolor='white')
        print(f"  Saved {filename}")
        plt.close(fig)

    # Save base64 versions for JSON package
    base64_images = {}
    for name, fig_func in [
        ('berggren_tree', plot_berggren_tree),
        ('wavelet_basis', plot_wavelet_basis),
        ('spectral_sparsity', plot_spectral_sparsity),
        ('energy_spectrum', plot_energy_spectrum),
        ('recovery_noise', plot_recovery_noise),
    ]:
        fig = fig_func()
        base64_images[name] = fig_to_base64(fig)
        plt.close(fig)

    print("All visualizations generated.")

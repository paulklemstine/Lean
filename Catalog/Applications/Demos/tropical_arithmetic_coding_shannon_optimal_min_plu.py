#!/usr/bin/env python3
"""
Tropical Source Coding: Applications

Real-world applications of the tropical source coding theory:
1. Text compression analysis
2. Image histogram coding
3. Network packet encoding
4. Statistical mechanics connection
"""

import numpy as np
from algorithms import (
    entropy_base2, shannon_code, huffman_code, gibbs_source,
    kraft_sum_integer, product_source_code, verify_kraft
)


def application_text_compression():
    """Application 1: English text character frequency coding.

    Demonstrates Shannon and Huffman coding applied to character
    frequencies from natural English text.
    """
    print("=" * 70)
    print("APPLICATION 1: English Text Compression")
    print("=" * 70)

    # Approximate English letter frequencies (including space)
    chars = list(" etaoinsrhldcumfpgwybvkxjqz")
    freqs = np.array([
        18.29, 12.70, 9.06, 8.17, 7.51, 6.97, 6.75, 6.33, 5.99,
        4.25, 4.03, 3.86, 2.78, 2.76, 2.41, 2.29, 2.02, 1.97,
        1.53, 1.49, 0.97, 0.77, 0.15, 0.15, 0.10, 0.05
    ])
    freqs = freqs / freqs.sum()

    H = entropy_base2(freqs)
    ell_sh, _ = shannon_code(freqs)
    ell_hf, _ = huffman_code(freqs)

    E_sh = np.sum(freqs * ell_sh)
    E_hf = np.sum(freqs * ell_hf)

    print(f"\nAlphabet size: {len(chars)}")
    print(f"Fixed-length code: {int(np.ceil(np.log2(len(chars))))} bits/symbol")
    print(f"Entropy: {H:.4f} bits/symbol")
    print(f"Shannon code E[ℓ]: {E_sh:.4f} bits/symbol")
    print(f"Huffman code E[ℓ]: {E_hf:.4f} bits/symbol")
    print(f"Shannon gap: {E_sh - H:.4f} < 1 ✓")
    print(f"Huffman gap: {E_hf - H:.4f}")
    print(f"Compression ratio (vs fixed): {E_hf / np.ceil(np.log2(len(chars))):.2%}")

    # Top 5 most common
    print(f"\nTop 5 most common characters:")
    order = np.argsort(-freqs)
    for i in range(5):
        idx = order[i]
        ch = repr(chars[idx])
        print(f"  {ch:>5}: freq={freqs[idx]:.3f}, "
              f"Shannon ℓ={ell_sh[idx]}, Huffman ℓ={ell_hf[idx]}")
    print()


def application_boltzmann_machine():
    """Application 2: Boltzmann machine / statistical mechanics.

    Shows the duality between energy landscapes and optimal codes.
    The Gibbs distribution connects tropical weights to probabilities,
    and the entropy equals the expected code length at the optimum.
    """
    print("=" * 70)
    print("APPLICATION 2: Boltzmann Machine / Statistical Mechanics")
    print("=" * 70)

    # Energy levels of a simple system
    energies = np.array([0.0, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 8.0])
    states = [f"E={e}" for e in energies]

    # Different temperatures
    temperatures = [0.5, 1.0, 2.0, 5.0]

    print(f"\nEnergy levels: {energies}")
    print(f"\n{'T':>5} {'H₂ (bits)':>10} {'E[ℓ_sh]':>10} {'Gap':>8} {'p(ground)':>10}")
    print("-" * 50)

    for T in temperatures:
        beta = 1.0 / T
        p = gibbs_source(beta * energies)
        H = entropy_base2(p)
        ell, _ = shannon_code(p)
        E_ell = np.sum(p * ell)
        gap = E_ell - H

        print(f"{T:>5.1f} {H:>10.4f} {E_ell:>10.4f} {gap:>8.4f} {p[0]:>10.4f}")

    print(f"\nAs T → 0: entropy → 0 (ground state dominates, 0 bits needed)")
    print(f"As T → ∞: entropy → log₂(n) = {np.log2(len(energies)):.4f} (uniform)")
    print()


def application_sensor_network():
    """Application 3: Sensor network data encoding.

    Multiple independent sensors with different value distributions.
    Product source coding gives additive code lengths.
    """
    print("=" * 70)
    print("APPLICATION 3: Sensor Network Encoding")
    print("=" * 70)

    # Temperature sensor (discrete bins)
    p_temp = np.array([0.05, 0.10, 0.20, 0.30, 0.20, 0.10, 0.05])
    labels_temp = ["cold", "cool", "mild-", "mild+", "warm", "hot", "v.hot"]

    # Humidity sensor
    p_hum = np.array([0.15, 0.35, 0.35, 0.15])
    labels_hum = ["dry", "normal-", "normal+", "humid"]

    H_temp = entropy_base2(p_temp)
    H_hum = entropy_base2(p_hum)

    ell_temp, _ = shannon_code(p_temp)
    ell_hum, _ = shannon_code(p_hum)

    # Joint encoding
    ell_joint, E_joint, H_joint = product_source_code(p_temp, p_hum)

    print(f"\nTemperature sensor: {len(p_temp)} levels")
    print(f"  Entropy: {H_temp:.4f} bits, Shannon E[ℓ]: {np.sum(p_temp * ell_temp):.4f}")
    print(f"Humidity sensor: {len(p_hum)} levels")
    print(f"  Entropy: {H_hum:.4f} bits, Shannon E[ℓ]: {np.sum(p_hum * ell_hum):.4f}")

    print(f"\nJoint (product) encoding:")
    print(f"  Alphabet size: {len(p_temp) * len(p_hum)}")
    print(f"  H₂(joint) = {H_joint:.4f} = {H_temp:.4f} + {H_hum:.4f} (additive ✓)")
    print(f"  E[ℓ₁+ℓ₂] = {E_joint:.4f}")

    # Compare with naive fixed-length
    naive_bits = int(np.ceil(np.log2(len(p_temp) * len(p_hum))))
    print(f"\nFixed-length encoding: {naive_bits} bits/reading")
    print(f"Product Shannon code: {E_joint:.2f} bits/reading")
    print(f"Savings: {(1 - E_joint/naive_bits)*100:.1f}%")
    print()


def application_dna_coding():
    """Application 4: DNA sequence compression.

    Demonstrates coding efficiency for non-uniform nucleotide distributions.
    """
    print("=" * 70)
    print("APPLICATION 4: DNA Sequence Compression")
    print("=" * 70)

    # Human genome approximate frequencies
    p_dna = np.array([0.295, 0.205, 0.205, 0.295])  # A, C, G, T
    nucleotides = ['A', 'C', 'G', 'T']

    H = entropy_base2(p_dna)
    ell_sh, codes_sh = shannon_code(p_dna)
    ell_hf, codes_hf = huffman_code(p_dna)

    print(f"\nNucleotide frequencies:")
    for i, nt in enumerate(nucleotides):
        print(f"  {nt}: {p_dna[i]:.3f}")

    print(f"\nEntropy: {H:.4f} bits/nucleotide")
    print(f"Fixed-length: 2 bits/nucleotide")
    print(f"Shannon code: {np.sum(p_dna * ell_sh):.4f} bits/nucleotide")
    print(f"Huffman code: {np.sum(p_dna * ell_hf):.4f} bits/nucleotide")

    # Dinucleotide (product source for independent model)
    p_di = np.outer(p_dna, p_dna).flatten()
    H_di = entropy_base2(p_di)
    ell_di, _ = shannon_code(p_di)

    print(f"\nDinucleotide (independent model):")
    print(f"  H₂ = {H_di:.4f} = 2 × {H:.4f} (additive ✓)")
    print(f"  Shannon E[ℓ] = {np.sum(p_di * ell_di):.4f}")
    print(f"  Fixed-length: 4 bits/dinucleotide")

    # Genome savings at scale
    genome_size = 3.2e9  # base pairs
    fixed_bits = genome_size * 2
    optimal_bits = genome_size * H
    print(f"\nHuman genome ({genome_size/1e9:.1f} Gbp):")
    print(f"  Fixed-length: {fixed_bits/8/1e9:.2f} GB")
    print(f"  Entropy limit: {optimal_bits/8/1e9:.2f} GB")
    print(f"  Potential savings: {(1 - H/2)*100:.1f}%")
    print()


if __name__ == "__main__":
    application_text_compression()
    application_boltzmann_machine()
    application_sensor_network()
    application_dna_coding()


#!/usr/bin/env python3
"""
Tropical Source Coding: Demonstrations

Concrete numerical examples illustrating the main theorems:
1. Shannon ceiling lengths satisfy the Kraft inequality
2. Expected code length is sandwiched between entropy and entropy + 1
3. The relaxed optimizer achieves entropy exactly
4. Entropy is additive for product sources
"""

import numpy as np
from typing import Dict, List, Tuple

def entropy_base2(p: np.ndarray) -> float:
    """Shannon entropy in bits: H₂(p) = -∑ p(a) log₂(p(a))."""
    return -np.sum(p * np.log2(p))

def kraft_sum(lengths: np.ndarray) -> float:
    """Kraft sum: ∑ 2^(-ℓ(a))."""
    return np.sum(2.0 ** (-lengths.astype(float)))

def shannon_lengths(p: np.ndarray) -> np.ndarray:
    """Shannon code lengths: ℓ(a) = ⌈log₂(1/p(a))⌉."""
    return np.ceil(np.log2(1.0 / p)).astype(int)

def ideal_lengths(p: np.ndarray) -> np.ndarray:
    """Ideal (real-valued) code lengths: L(a) = log₂(1/p(a))."""
    return np.log2(1.0 / p)

def gibbs_prob(w: np.ndarray) -> np.ndarray:
    """Gibbs/Boltzmann probability from weights: p(a) = exp(-w(a)) / Z."""
    exp_neg_w = np.exp(-w)
    return exp_neg_w / np.sum(exp_neg_w)


def demo_basic_shannon_coding():
    """Demo 1: Basic Shannon coding for a simple distribution."""
    print("=" * 70)
    print("DEMO 1: Shannon Coding for a Simple Distribution")
    print("=" * 70)

    # A simple 4-symbol distribution
    p = np.array([0.5, 0.25, 0.125, 0.125])
    alphabet = ['A', 'B', 'C', 'D']

    H = entropy_base2(p)
    ell = shannon_lengths(p)
    K = kraft_sum(ell)
    E_ell = np.sum(p * ell)
    L_star = ideal_lengths(p)

    print(f"\nAlphabet: {alphabet}")
    print(f"Probabilities: {p}")
    print(f"Entropy H₂(p) = {H:.4f} bits")
    print(f"\nIdeal (real) lengths L⋆(a) = log₂(1/p(a)):")
    for i, s in enumerate(alphabet):
        print(f"  L⋆({s}) = {L_star[i]:.4f}")
    print(f"Kraft sum (ideal): ∑ 2^(-L⋆) = {np.sum(2**(-L_star)):.4f} (= 1 exactly)")

    print(f"\nShannon ceiling lengths ℓ(a) = ⌈log₂(1/p(a))⌉:")
    for i, s in enumerate(alphabet):
        print(f"  ℓ({s}) = {ell[i]}")
    print(f"Kraft sum: ∑ 2^(-ℓ) = {K:.4f} ≤ 1 ✓")
    print(f"Expected length E[ℓ] = {E_ell:.4f}")
    print(f"Entropy H₂ = {H:.4f}")
    print(f"H₂ ≤ E[ℓ] < H₂ + 1: {H:.4f} ≤ {E_ell:.4f} < {H+1:.4f} ✓")
    print()


def demo_gibbs_source():
    """Demo 2: Gibbs/Boltzmann source from tropical weights."""
    print("=" * 70)
    print("DEMO 2: Gibbs Source from Tropical Weights")
    print("=" * 70)

    # Weights (tropical energies)
    w = np.array([0.5, 1.0, 2.0, 3.0, 0.1])
    alphabet = ['a', 'b', 'c', 'd', 'e']

    p = gibbs_prob(w)
    Z = np.sum(np.exp(-w))
    H = entropy_base2(p)
    ell = shannon_lengths(p)
    K = kraft_sum(ell)
    E_ell = np.sum(p * ell)

    print(f"\nWeights w: {w}")
    print(f"Partition function Z = {Z:.4f}")
    print(f"Gibbs probabilities p(a) = exp(-w(a))/Z:")
    for i, s in enumerate(alphabet):
        print(f"  p({s}) = {p[i]:.4f}")
    print(f"Sum of probabilities: {np.sum(p):.6f}")
    print(f"\nEntropy H₂(p) = {H:.4f} bits")
    print(f"Shannon lengths: {ell}")
    print(f"Kraft sum: {K:.4f} ≤ 1 ✓")
    print(f"Expected length: {E_ell:.4f}")
    print(f"Sandwich: {H:.4f} ≤ {E_ell:.4f} < {H+1:.4f} ✓")
    print()


def demo_product_source():
    """Demo 3: Product source and entropy additivity."""
    print("=" * 70)
    print("DEMO 3: Product Source - Entropy Additivity")
    print("=" * 70)

    p1 = np.array([0.7, 0.3])
    p2 = np.array([0.6, 0.3, 0.1])

    H1 = entropy_base2(p1)
    H2 = entropy_base2(p2)

    # Product distribution
    p_prod = np.outer(p1, p2).flatten()
    H_prod = entropy_base2(p_prod)

    print(f"\nSource 1: p₁ = {p1}, H₂(p₁) = {H1:.4f}")
    print(f"Source 2: p₂ = {p2}, H₂(p₂) = {H2:.4f}")
    print(f"\nProduct distribution p₁⊗p₂:")
    for i in range(len(p1)):
        for j in range(len(p2)):
            print(f"  p({i},{j}) = {p1[i]:.2f} × {p2[j]:.2f} = {p1[i]*p2[j]:.4f}")
    print(f"\nH₂(p₁⊗p₂) = {H_prod:.6f}")
    print(f"H₂(p₁) + H₂(p₂) = {H1+H2:.6f}")
    print(f"Difference: {abs(H_prod - (H1 + H2)):.2e} (≈ 0, additivity ✓)")

    # Shannon lengths for product vs component
    ell1 = shannon_lengths(p1)
    ell2 = shannon_lengths(p2)
    ell_prod = shannon_lengths(p_prod)
    ell_sum = np.array([ell1[i] + ell2[j] for i in range(len(p1)) for j in range(len(p2))])

    K1 = kraft_sum(ell1)
    K2 = kraft_sum(ell2)
    K_prod = kraft_sum(ell_prod)
    K_sum = kraft_sum(ell_sum)

    print(f"\nKraft sums:")
    print(f"  Component 1: {K1:.4f}")
    print(f"  Component 2: {K2:.4f}")
    print(f"  Product (direct ceiling): {K_prod:.4f}")
    print(f"  Product (sum of ceilings): {K_sum:.4f}")
    print(f"  Both ≤ 1 ✓")
    print()


def demo_relaxed_optimizer():
    """Demo 4: The relaxed optimizer and the optimality gap."""
    print("=" * 70)
    print("DEMO 4: Relaxed Optimizer - Tropical Potential")
    print("=" * 70)

    p = np.array([0.4, 0.3, 0.2, 0.1])
    H = entropy_base2(p)
    L_star = ideal_lengths(p)
    ell = shannon_lengths(p)

    print(f"\nDistribution: {p}")
    print(f"Entropy: {H:.4f} bits")
    print(f"\nIdeal lengths (tropical potential):")
    print(f"  L⋆ = {L_star}")
    print(f"  Kraft sum = {np.sum(2**(-L_star)):.6f} (= 1 exactly)")
    print(f"  E[L⋆] = {np.sum(p * L_star):.6f} = H₂ = {H:.6f} ✓")

    print(f"\nShannon ceiling lengths:")
    print(f"  ℓ = {ell}")
    print(f"  Kraft sum = {kraft_sum(ell):.4f} ≤ 1 ✓")
    print(f"  E[ℓ] = {np.sum(p * ell):.4f}")
    print(f"  Gap = E[ℓ] - H = {np.sum(p * ell) - H:.4f} < 1 ✓")

    # Try suboptimal lengths
    print(f"\nComparison with suboptimal lengths:")
    ell_bad = np.array([1, 2, 3, 3])
    K_bad = kraft_sum(ell_bad)
    E_bad = np.sum(p * ell_bad)
    print(f"  ℓ_alt = {ell_bad}")
    print(f"  Kraft sum = {K_bad:.4f} {'≤ 1 ✓' if K_bad <= 1 else '> 1 ✗'}")
    print(f"  E[ℓ_alt] = {E_bad:.4f} {'≥ H ✓' if E_bad >= H - 1e-10 else '< H ✗'}")
    print()


def demo_convergence_to_entropy():
    """Demo 5: As alphabet grows, the gap E[ℓ]-H shrinks towards 0 (for uniform)."""
    print("=" * 70)
    print("DEMO 5: Coding Gap for Uniform Distributions")
    print("=" * 70)

    print(f"\n{'n':>6} {'H₂':>10} {'E[ℓ]':>10} {'Gap':>10} {'Kraft':>10}")
    print("-" * 50)
    for k in range(1, 11):
        n = 2**k
        p = np.ones(n) / n
        H = entropy_base2(p)
        ell = shannon_lengths(p)
        E_ell = np.sum(p * ell)
        K = kraft_sum(ell)
        gap = E_ell - H
        print(f"{n:>6} {H:>10.4f} {E_ell:>10.4f} {gap:>10.4f} {K:>10.4f}")

    print("\nFor powers of 2, the gap is exactly 0 (no rounding needed).")
    print("For non-powers-of-2, the gap is between 0 and 1.")
    print()


if __name__ == "__main__":
    demo_basic_shannon_coding()
    demo_gibbs_source()
    demo_product_source()
    demo_relaxed_optimizer()
    demo_convergence_to_entropy()


#!/usr/bin/env python3
"""
Tropical Source Coding: Visualizations

Generate figures illustrating the key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import base64
from io import BytesIO
from algorithms import entropy_base2, shannon_code, huffman_code, gibbs_source, kraft_sum_integer

def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_entropy_sandwich():
    """Visualize the entropy sandwich: H ≤ E[ℓ] < H+1."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Generate distributions with varying entropy
    n_points = 50
    alphas = np.linspace(0.01, 5.0, n_points)
    entropies = []
    expected_lengths_sh = []
    expected_lengths_hf = []

    for alpha in alphas:
        # Dirichlet-like distribution on 8 symbols
        p = np.random.default_rng(42).dirichlet(np.ones(8) * alpha)
        p = np.sort(p)[::-1]
        H = entropy_base2(p)
        ell_sh, _ = shannon_code(p)
        ell_hf, _ = huffman_code(p)
        entropies.append(H)
        expected_lengths_sh.append(np.sum(p * ell_sh))
        expected_lengths_hf.append(np.sum(p * ell_hf))

    entropies = np.array(entropies)
    expected_lengths_sh = np.array(expected_lengths_sh)
    expected_lengths_hf = np.array(expected_lengths_hf)

    order = np.argsort(entropies)
    H_sorted = entropies[order]

    ax.fill_between(H_sorted, H_sorted, H_sorted + 1,
                     alpha=0.15, color='steelblue', label='Feasible region [H, H+1)')
    ax.plot(H_sorted, H_sorted, 'b-', linewidth=2, label='H₂(p) (lower bound)')
    ax.plot(H_sorted, H_sorted + 1, 'b--', linewidth=1.5, label='H₂(p) + 1 (upper bound)')
    ax.scatter(entropies, expected_lengths_sh, c='crimson', s=25, zorder=5,
               alpha=0.7, label='Shannon code E[ℓ]')
    ax.scatter(entropies, expected_lengths_hf, c='darkgreen', s=25, zorder=5,
               alpha=0.7, marker='^', label='Huffman code E[ℓ]')

    ax.set_xlabel('Entropy H₂(p) [bits]', fontsize=13)
    ax.set_ylabel('Expected Code Length E[ℓ] [bits]', fontsize=13)
    ax.set_title('Source Coding Sandwich Theorem: H₂ ≤ E[ℓ] < H₂ + 1', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 3.5)
    ax.set_ylim(0, 4.5)

    return fig_to_base64(fig)


def viz_kraft_inequality():
    """Visualize Kraft inequality satisfaction."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Kraft sum components for different distributions
    distributions = {
        'Uniform (n=4)': np.ones(4) / 4,
        'Skewed': np.array([0.5, 0.25, 0.15, 0.1]),
        'Very skewed': np.array([0.8, 0.1, 0.05, 0.05]),
        'Extreme': np.array([0.97, 0.01, 0.01, 0.01]),
    }

    x_pos = np.arange(len(distributions))
    width = 0.6

    for i, (name, p) in enumerate(distributions.items()):
        ell, _ = shannon_code(p)
        kraft_components = 2.0 ** (-ell.astype(float))
        bottom = 0
        for j, kc in enumerate(kraft_components):
            color = plt.cm.Set2(j / len(p))
            ax1.bar(i, kc, width, bottom=bottom, color=color,
                    edgecolor='white', linewidth=0.5)
            bottom += kc

    ax1.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Kraft bound = 1')
    ax1.set_xticks(x_pos)
    ax1.set_xticklabels(distributions.keys(), fontsize=10, rotation=15)
    ax1.set_ylabel('Kraft sum components 2^(-ℓᵢ)', fontsize=12)
    ax1.set_title('Kraft Inequality: ∑ 2^(-ℓᵢ) ≤ 1', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_ylim(0, 1.3)
    ax1.grid(True, alpha=0.3, axis='y')

    # Right: Ideal vs ceiling lengths
    p = np.array([0.4, 0.25, 0.2, 0.1, 0.05])
    L_ideal = np.log2(1.0 / p)
    ell_ceil = np.ceil(L_ideal).astype(int)

    symbols = np.arange(len(p))
    bar_width = 0.35

    bars1 = ax2.bar(symbols - bar_width/2, L_ideal, bar_width,
                     color='steelblue', alpha=0.8, label='Ideal L⋆ = log₂(1/p)')
    bars2 = ax2.bar(symbols + bar_width/2, ell_ceil, bar_width,
                     color='coral', alpha=0.8, label='Shannon ℓ = ⌈L⋆⌉')

    ax2.set_xlabel('Symbol index', fontsize=12)
    ax2.set_ylabel('Code length', fontsize=12)
    ax2.set_title('Ideal vs. Shannon Ceiling Lengths', fontsize=13)
    ax2.set_xticks(symbols)
    ax2.set_xticklabels([f'a{i+1}\n(p={p[i]})' for i in range(len(p))], fontsize=9)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_gibbs_landscape():
    """Visualize the Gibbs distribution as a function of temperature."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    energies = np.array([0.0, 0.5, 1.0, 2.0, 3.0, 5.0])
    n = len(energies)
    temperatures = np.linspace(0.1, 10.0, 200)

    # Left: probability vs temperature
    for i in range(n):
        probs = []
        for T in temperatures:
            p = gibbs_source(energies / T)
            probs.append(p[i])
        ax1.plot(temperatures, probs, linewidth=2, label=f'E={energies[i]}')

    ax1.set_xlabel('Temperature T', fontsize=12)
    ax1.set_ylabel('Probability p(state)', fontsize=12)
    ax1.set_title('Gibbs Distribution vs. Temperature', fontsize=13)
    ax1.legend(fontsize=10, ncol=2)
    ax1.grid(True, alpha=0.3)

    # Right: entropy vs temperature
    entropies = []
    for T in temperatures:
        p = gibbs_source(energies / T)
        entropies.append(entropy_base2(p))

    ax2.plot(temperatures, entropies, 'b-', linewidth=2)
    ax2.axhline(y=np.log2(n), color='red', linestyle='--', alpha=0.7,
                label=f'max entropy = log₂({n}) = {np.log2(n):.2f}')
    ax2.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    ax2.set_xlabel('Temperature T', fontsize=12)
    ax2.set_ylabel('Entropy H₂ [bits]', fontsize=12)
    ax2.set_title('Entropy of Gibbs Distribution', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_product_additivity():
    """Visualize entropy additivity for product sources."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Sweep p₁ parameter for binary source
    ps = np.linspace(0.01, 0.99, 100)
    H1s = []
    H2_fixed = entropy_base2(np.array([0.6, 0.3, 0.1]))

    for pp in ps:
        p1 = np.array([pp, 1 - pp])
        H1s.append(entropy_base2(p1))

    H1s = np.array(H1s)
    H_products = H1s + H2_fixed

    ax1.plot(ps, H1s, 'b-', linewidth=2, label='H₂(p₁)')
    ax1.axhline(y=H2_fixed, color='green', linestyle='--', linewidth=1.5,
                label=f'H₂(p₂) = {H2_fixed:.3f}')
    ax1.plot(ps, H_products, 'r-', linewidth=2, label='H₂(p₁⊗p₂) = H₂(p₁)+H₂(p₂)')
    ax1.set_xlabel('p₁(0)', fontsize=12)
    ax1.set_ylabel('Entropy [bits]', fontsize=12)
    ax1.set_title('Entropy Additivity for Product Sources', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: verify additivity numerically
    n_samples = 50
    H_sum = []
    H_prod = []
    rng = np.random.default_rng(123)

    for _ in range(n_samples):
        p1 = rng.dirichlet(np.ones(3))
        p2 = rng.dirichlet(np.ones(4))
        H1 = entropy_base2(p1)
        H2 = entropy_base2(p2)
        p_joint = np.outer(p1, p2).flatten()
        H_joint = entropy_base2(p_joint)
        H_sum.append(H1 + H2)
        H_prod.append(H_joint)

    ax2.scatter(H_sum, H_prod, c='steelblue', s=40, alpha=0.7, zorder=5)
    lims = [0, max(max(H_sum), max(H_prod)) * 1.05]
    ax2.plot(lims, lims, 'r--', linewidth=2, label='y = x (perfect additivity)')
    ax2.set_xlabel('H₂(p₁) + H₂(p₂) [bits]', fontsize=12)
    ax2.set_ylabel('H₂(p₁⊗p₂) [bits]', fontsize=12)
    ax2.set_title('Numerical Verification of Additivity', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(lims)
    ax2.set_ylim(lims)
    ax2.set_aspect('equal')

    plt.tight_layout()
    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and save as files."""
    print("Generating visualizations...")

    viz_funcs = {
        'entropy_sandwich': viz_entropy_sandwich,
        'kraft_inequality': viz_kraft_inequality,
        'gibbs_landscape': viz_gibbs_landscape,
        'product_additivity': viz_product_additivity,
    }

    results = {}
    for name, func in viz_funcs.items():
        print(f"  Generating {name}...")
        data_uri = func()
        results[name] = data_uri
        # Also save as PNG
        b64_data = data_uri.split(',')[1]
        with open(f'{name}.png', 'wb') as f:
            f.write(base64.b64decode(b64_data))
        print(f"  Saved {name}.png")

    return results


if __name__ == "__main__":
    results = generate_all_visualizations()
    print(f"\nGenerated {len(results)} visualizations.")

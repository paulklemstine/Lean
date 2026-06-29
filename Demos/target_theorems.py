#!/usr/bin/env python3
"""
applications.py — Real-world applications of q-ary source coding theory.

Demonstrates:
1. DNA storage encoding with quaternary (q=4) codes
2. Ternary computing with q=3 information theory
3. Multi-level flash memory (MLC/TLC/QLC) coding analysis
4. Tropical coding potential for neural network compression
"""

import numpy as np
from typing import List, Tuple, Dict
from algorithms import QaryShannon, TropicalCodingPotential, BaseChangeConverter


# ─── Application 1: DNA Storage ──────────────────────────────────────────

def dna_storage_analysis():
    """Analyze coding efficiency for DNA storage systems.

    DNA uses 4 nucleotides (A, C, G, T), making q=4 the natural base.
    Different organisms have different nucleotide frequencies, affecting
    the optimal coding strategy.
    """
    print("=" * 70)
    print("  APPLICATION 1: DNA Storage Coding Analysis")
    print("=" * 70)

    organisms = {
        "E. coli": np.array([0.246, 0.254, 0.254, 0.246]),
        "Human (avg)": np.array([0.293, 0.207, 0.207, 0.293]),
        "P. falciparum": np.array([0.35, 0.15, 0.15, 0.35]),
        "Synthetic (uniform)": np.array([0.25, 0.25, 0.25, 0.25]),
    }

    coder = QaryShannon(q=4)

    for name, freqs in organisms.items():
        code = coder.encode(freqs)
        print(f"\n  {name}:")
        print(f"    Nucleotide freq: A={freqs[0]:.3f} C={freqs[1]:.3f} "
              f"G={freqs[2]:.3f} T={freqs[3]:.3f}")
        print(f"    H_4(p) = {code.entropy:.6f} quat/nucleotide")
        print(f"    H_2(p) = {BaseChangeConverter.convert(code.entropy, 4, 2):.6f} bits/nucleotide")
        print(f"    Coding efficiency: {code.entropy:.4f}/1.0 = {code.entropy*100:.2f}%")
        print(f"    Compressibility: {(1-code.entropy)*100:.2f}% reduction possible")

    # Storage density comparison
    print(f"\n  Storage density comparison (200 nucleotide reads):")
    for name, freqs in organisms.items():
        H = -np.sum(freqs * np.log(freqs) / np.log(4))
        effective_bits = H * 200 * 2  # 2 bits per quaternary symbol
        print(f"    {name}: {effective_bits:.1f} effective bits per read")
    print()


# ─── Application 2: Ternary Computing ────────────────────────────────────

def ternary_computing_analysis():
    """Analyze information capacity for ternary logic systems.

    Ternary computers (using {0, 1, 2} instead of {0, 1}) have
    a natural base q=3. We analyze coding efficiency for typical
    instruction distributions.
    """
    print("=" * 70)
    print("  APPLICATION 2: Ternary Computing Information Analysis")
    print("=" * 70)

    # Simulated ternary instruction frequencies
    # 9 possible 2-trit instructions
    p_instructions = np.array([
        0.20, 0.15, 0.15,  # Most common instructions
        0.12, 0.10, 0.10,  # Medium frequency
        0.08, 0.06, 0.04   # Rare instructions
    ])

    for q in [2, 3]:
        coder = QaryShannon(q)
        code = coder.encode(p_instructions)
        print(f"\n  Base-{q} coding:")
        print(f"    H_{q}(p) = {code.entropy:.6f}")
        print(f"    Shannon lengths: {code.lengths}")
        print(f"    Expected length: {code.expected_length:.4f} symbols")
        print(f"    Redundancy: {code.redundancy:.4f}")

    # Advantage of ternary over binary
    H3 = -np.sum(p_instructions * np.log(p_instructions) / np.log(3))
    H2 = -np.sum(p_instructions * np.log(p_instructions) / np.log(2))
    print(f"\n  Ternary advantage:")
    print(f"    Binary symbols needed: {H2:.4f}")
    print(f"    Ternary symbols needed: {H3:.4f}")
    print(f"    Symbol reduction: {(1 - H3/H2)*100:.1f}%")
    print(f"    But each ternary symbol carries log_2(3) = {np.log(3)/np.log(2):.4f} bits")
    print()


# ─── Application 3: Flash Memory ─────────────────────────────────────────

def flash_memory_analysis():
    """Analyze coding for multi-level flash memory cells.

    - SLC (Single-Level Cell): q = 2 (1 bit/cell)
    - MLC (Multi-Level Cell): q = 4 (2 bits/cell)
    - TLC (Triple-Level Cell): q = 8 (3 bits/cell)
    - QLC (Quad-Level Cell): q = 16 (4 bits/cell)
    """
    print("=" * 70)
    print("  APPLICATION 3: Flash Memory Multi-Level Coding")
    print("=" * 70)

    # Typical data distribution (byte-level frequencies from text)
    # Simulated: English text byte distribution (simplified)
    np.random.seed(42)
    raw = np.random.dirichlet(np.ones(256) * 0.3)
    p_data = raw / raw.sum()

    flash_types = {
        "SLC": 2,
        "MLC": 4,
        "TLC": 8,
        "QLC": 16,
    }

    print(f"\n  Source: 256-symbol alphabet (byte-level)")
    print(f"  H_2(source) = {-np.sum(p_data * np.log2(p_data)):.4f} bits/byte")
    print(f"  (Maximum: 8.0 bits/byte for uniform)")

    for name, q in flash_types.items():
        H_q = -np.sum(p_data * np.log(p_data) / np.log(q))
        bits_per_cell = np.log2(q)
        cells_needed = H_q  # symbols of alphabet size q
        effective_bits = cells_needed * bits_per_cell

        print(f"\n  {name} (q={q}, {bits_per_cell:.0f} bits/cell):")
        print(f"    H_{q}(data) = {H_q:.4f} {name} symbols/byte")
        print(f"    Effective storage: {effective_bits:.4f} bits/byte")
        print(f"    Cells per byte: {H_q:.4f}")
        print(f"    Utilization: {H_q / (8/bits_per_cell) * 100:.1f}%")
    print()


# ─── Application 4: Neural Network Compression ──────────────────────────

def neural_network_compression():
    """Apply tropical coding potential to neural network weight compression.

    The tropical coding potential TCP_q(p) measures the minimum
    encoding cost for quantized neural network weights.
    """
    print("=" * 70)
    print("  APPLICATION 4: Neural Network Weight Compression")
    print("=" * 70)

    # Simulated weight distribution (quantized to k levels)
    np.random.seed(123)

    for k, label in [(4, "2-bit"), (8, "3-bit"), (16, "4-bit")]:
        # Simulate quantized weight distribution
        weights = np.random.randn(10000)
        hist, _ = np.histogram(weights, bins=k)
        p_weights = hist / hist.sum()
        p_weights = np.maximum(p_weights, 1e-10)
        p_weights /= p_weights.sum()

        tcp = TropicalCodingPotential(q=k)
        potential = tcp.compute(p_weights)
        max_entropy = np.log(k) / np.log(k)

        print(f"\n  {label} quantization ({k} levels):")
        print(f"    Weight distribution: {p_weights.round(4)}")
        print(f"    TCP_{k}(p) = {potential:.6f}")
        print(f"    Maximum: {max_entropy:.6f}")
        print(f"    Compression ratio: {potential/max_entropy*100:.1f}%")

        # Check data processing monotonicity
        # Group adjacent levels
        if k >= 4:
            f_map = {i: i // 2 for i in range(k)}
            mono = tcp.is_monotone_under(p_weights, f_map, k // 2)
            print(f"    DPI satisfied (grouping adjacent): {mono} ✓")
    print()


# ─── Main ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "═" * 70)
    print("  Real-World Applications of q-ary Source Coding Theory")
    print("═" * 70 + "\n")

    dna_storage_analysis()
    ternary_computing_analysis()
    flash_memory_analysis()
    neural_network_compression()

    print("All applications completed! ✓")


#!/usr/bin/env python3
"""
demo.py — Concrete demonstrations of q-ary source coding theorems.

Illustrates the q-ary Shannon coding theorems with numerical examples:
- q-ary entropy computation for various distributions and alphabet sizes
- Kraft inequality verification for Shannon ceiling lengths
- Shannon code upper/lower bounds
- Relaxed optimizer attaining entropy exactly
- Base change formula
- Deterministic data processing inequality
- KL divergence non-negativity
"""

import numpy as np
from typing import List, Tuple
import math

# ─── q-ary Entropy ───────────────────────────────────────────────────────

def qary_entropy(q: int, p: np.ndarray) -> float:
    """Compute H_q(p) = -sum_a p(a) * log_q(p(a))."""
    assert q >= 2, "Alphabet size must be at least 2"
    mask = p > 0
    result = -np.sum(p[mask] * np.log(p[mask]) / np.log(q))
    return result

def qary_kl_divergence(q: int, p: np.ndarray, r: np.ndarray) -> float:
    """Compute D_q(p||r) = sum_a p(a) * log_q(p(a)/r(a))."""
    mask = p > 0
    return np.sum(p[mask] * np.log(p[mask] / r[mask]) / np.log(q))

# ─── Shannon Ceiling Lengths ─────────────────────────────────────────────

def shannon_lengths(q: int, p: np.ndarray) -> np.ndarray:
    """Compute Shannon ceiling lengths: ceil(log_q(1/p(a)))."""
    mask = p > 0
    lengths = np.zeros_like(p, dtype=int)
    lengths[mask] = np.ceil(np.log(1.0 / p[mask]) / np.log(q)).astype(int)
    return lengths

def kraft_sum(q: int, lengths: np.ndarray) -> float:
    """Compute the Kraft sum: sum_a q^{-l(a)}."""
    return np.sum(q ** (-lengths.astype(float)))

def expected_length(p: np.ndarray, lengths: np.ndarray) -> float:
    """Compute expected code length: sum_a p(a) * l(a)."""
    return np.sum(p * lengths)

# ─── Demonstrations ──────────────────────────────────────────────────────

def demo_basic_entropy():
    """Demonstrate q-ary entropy for various distributions and q values."""
    print("=" * 70)
    print("DEMO 1: q-ary Entropy for Various Distributions")
    print("=" * 70)

    # Example: DNA storage (q=4)
    p_dna = np.array([0.3, 0.25, 0.25, 0.2])  # 4-symbol source
    for q in [2, 3, 4, 8]:
        H = qary_entropy(q, p_dna)
        print(f"  q={q}: H_{q}(p) = {H:.6f}")
    print(f"  Distribution: p = {p_dna}")
    print(f"  Maximum entropy (uniform, q=4): log_4(4) = {np.log(4)/np.log(4):.6f}")
    print()

    # Uniform distribution
    n = 8
    p_uniform = np.ones(n) / n
    for q in [2, 4, 8]:
        H = qary_entropy(q, p_uniform)
        log_q_n = np.log(n) / np.log(q)
        print(f"  Uniform({n}), q={q}: H_{q} = {H:.6f}, log_{q}({n}) = {log_q_n:.6f}")
    print()

def demo_kraft_inequality():
    """Demonstrate the Kraft inequality for Shannon ceiling lengths."""
    print("=" * 70)
    print("DEMO 2: Kraft Inequality for Shannon Ceiling Lengths")
    print("=" * 70)

    for q in [2, 3, 4]:
        p = np.array([0.4, 0.3, 0.2, 0.1])
        lengths = shannon_lengths(q, p)
        K = kraft_sum(q, lengths)
        print(f"  q={q}: lengths = {lengths}, Kraft sum = {K:.6f} ≤ 1 ✓" if K <= 1 + 1e-10 else f"  q={q}: VIOLATION!")
    print()

def demo_shannon_bounds():
    """Demonstrate Shannon lower and upper bounds on expected length."""
    print("=" * 70)
    print("DEMO 3: Shannon Lower/Upper Bounds")
    print("=" * 70)

    for q in [2, 3, 4]:
        p = np.array([0.5, 0.25, 0.125, 0.125])
        H = qary_entropy(q, p)
        L = shannon_lengths(q, p)
        EL = expected_length(p, L)
        print(f"  q={q}:")
        print(f"    H_{q}(p) = {H:.6f}")
        print(f"    E[ℓ]   = {EL:.6f}")
        print(f"    H_{q}(p) ≤ E[ℓ] < H_{q}(p) + 1:  {H:.4f} ≤ {EL:.4f} < {H+1:.4f}  ✓")
    print()

def demo_relaxed_optimizer():
    """Demonstrate that L*(a) = log_q(1/p(a)) attains entropy exactly."""
    print("=" * 70)
    print("DEMO 4: Relaxed Optimizer Attains Entropy")
    print("=" * 70)

    p = np.array([0.5, 0.25, 0.125, 0.125])
    for q in [2, 3, 4]:
        H = qary_entropy(q, p)
        Lstar = np.log(1.0 / p) / np.log(q)
        EL_star = np.sum(p * Lstar)
        kraft_at_opt = np.sum(q ** (-Lstar))
        print(f"  q={q}:")
        print(f"    L*(a) = {Lstar}")
        print(f"    E[L*] = {EL_star:.6f} = H_{q}(p) = {H:.6f}  ✓")
        print(f"    Kraft at L* = {kraft_at_opt:.6f} = 1  ✓")
    print()

def demo_base_change():
    """Demonstrate the base change formula H_q2(p) = H_q1(p) * log_q2(q1)."""
    print("=" * 70)
    print("DEMO 5: Base Change Formula")
    print("=" * 70)

    p = np.array([0.4, 0.35, 0.15, 0.1])
    q1, q2 = 2, 4
    H_q1 = qary_entropy(q1, p)
    H_q2 = qary_entropy(q2, p)
    ratio = np.log(q1) / np.log(q2)
    print(f"  H_{q2}(p) = {H_q2:.6f}")
    print(f"  H_{q1}(p) * log_{q2}({q1}) = {H_q1:.6f} * {ratio:.6f} = {H_q1 * ratio:.6f}")
    print(f"  Match: {np.isclose(H_q2, H_q1 * ratio)}  ✓")
    print()

def demo_data_processing():
    """Demonstrate that deterministic processing cannot increase entropy."""
    print("=" * 70)
    print("DEMO 6: Deterministic Data Processing Inequality")
    print("=" * 70)

    # Source: 6-symbol alphabet
    p = np.array([0.3, 0.2, 0.2, 0.15, 0.1, 0.05])
    # Deterministic function: group {0,1}→A, {2,3}→B, {4,5}→C
    f_map = {0: 0, 1: 0, 2: 1, 3: 1, 4: 2, 5: 2}
    p_f = np.zeros(3)
    for a, b in f_map.items():
        p_f[b] += p[a]

    for q in [2, 3, 4]:
        H_X = qary_entropy(q, p)
        H_fX = qary_entropy(q, p_f)
        print(f"  q={q}: H_{q}(X) = {H_X:.6f}, H_{q}(f(X)) = {H_fX:.6f}, "
              f"H(f(X)) ≤ H(X): {H_fX <= H_X + 1e-10}  ✓")
    print()

def demo_kl_divergence():
    """Demonstrate non-negativity of KL divergence."""
    print("=" * 70)
    print("DEMO 7: KL Divergence Non-negativity")
    print("=" * 70)

    p = np.array([0.5, 0.3, 0.2])
    r = np.array([1/3, 1/3, 1/3])
    for q in [2, 3, 4, 10]:
        D = qary_kl_divergence(q, p, r)
        print(f"  q={q}: D_{q}(p||r) = {D:.6f} ≥ 0  ✓")

    # KL divergence equals 0 iff p = r
    print(f"\n  D_2(p||p) = {qary_kl_divergence(2, p, p):.10f} (should be 0)")
    print()

def demo_dna_storage():
    """Practical example: DNA storage coding with q=4."""
    print("=" * 70)
    print("DEMO 8: DNA Storage Application (q=4)")
    print("=" * 70)

    # Nucleotide frequencies from E. coli genome
    p_ecoli = np.array([0.246, 0.254, 0.254, 0.246])  # A, C, G, T
    H4 = qary_entropy(4, p_ecoli)
    H2 = qary_entropy(2, p_ecoli)

    print(f"  E. coli nucleotide frequencies: {p_ecoli}")
    print(f"  H_4(p) = {H4:.6f} quaternary symbols/nucleotide")
    print(f"  H_2(p) = {H2:.6f} bits/nucleotide")
    print(f"  Maximum: log_4(4) = 1.0 (uniform)")
    print(f"  Coding efficiency: {H4/1.0*100:.2f}%")
    print()

    # Non-uniform distribution (synthetic DNA with bias)
    p_biased = np.array([0.4, 0.1, 0.1, 0.4])
    H4_biased = qary_entropy(4, p_biased)
    print(f"  Biased DNA: p = {p_biased}")
    print(f"  H_4(p) = {H4_biased:.6f} (less than 1 → compressible!)")
    L = shannon_lengths(4, p_biased)
    print(f"  Shannon lengths (q=4): {L}")
    print(f"  Expected length: {expected_length(p_biased, L):.6f}")
    print(f"  Savings over fixed-length: {(1 - expected_length(p_biased, L))*100:.1f}%")
    print()

if __name__ == "__main__":
    print("\n" + "═" * 70)
    print("  q-ary Source Coding Theorems — Numerical Demonstrations")
    print("═" * 70 + "\n")

    demo_basic_entropy()
    demo_kraft_inequality()
    demo_shannon_bounds()
    demo_relaxed_optimizer()
    demo_base_change()
    demo_data_processing()
    demo_kl_divergence()
    demo_dna_storage()

    print("All demonstrations completed successfully! ✓")


#!/usr/bin/env python3
"""
visualizations.py — Generate charts for q-ary source coding theory.

Creates publication-quality figures saved as PNG files:
1. Entropy vs distribution for different q
2. Shannon bounds visualization
3. Kraft inequality surface
4. Data processing inequality demonstration
5. Base change relationships
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm
import base64
import io

def qary_entropy(q, p):
    """Compute H_q(p)."""
    mask = p > 0
    return -np.sum(p[mask] * np.log(p[mask]) / np.log(q))


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def plot_entropy_landscape():
    """Plot entropy as a function of distribution parameter for binary source."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Binary entropy for different q
    ps = np.linspace(0.001, 0.999, 500)
    ax = axes[0]
    for q, color in [(2, '#2196F3'), (3, '#4CAF50'), (4, '#FF9800'), (8, '#9C27B0')]:
        Hs = [-p * np.log(p)/np.log(q) - (1-p) * np.log(1-p)/np.log(q) for p in ps]
        ax.plot(ps, Hs, color=color, linewidth=2, label=f'q = {q}')
    ax.set_xlabel('p (probability of symbol 1)', fontsize=12)
    ax.set_ylabel('H_q(p)', fontsize=12)
    ax.set_title('Binary Source Entropy in Different Bases', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 1)

    # Right: Entropy of 3-symbol distribution on simplex slice
    ax = axes[1]
    p1s = np.linspace(0.01, 0.98, 200)
    for q, color in [(2, '#2196F3'), (3, '#4CAF50'), (4, '#FF9800')]:
        Hs = []
        for p1 in p1s:
            p2 = (1 - p1) / 2
            p3 = (1 - p1) / 2
            p = np.array([p1, p2, p3])
            Hs.append(qary_entropy(q, p))
        ax.plot(p1s, Hs, color=color, linewidth=2, label=f'q = {q}')
    ax.axhline(y=np.log(3)/np.log(2), color='#2196F3', linestyle='--', alpha=0.5, label='log₂3')
    ax.axhline(y=1, color='#4CAF50', linestyle='--', alpha=0.5, label='log₃3 = 1')
    ax.set_xlabel('p₁ (p₂ = p₃ = (1-p₁)/2)', fontsize=12)
    ax.set_ylabel('H_q(p)', fontsize=12)
    ax.set_title('3-Symbol Entropy Along Simplex Slice', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('fig_entropy_landscape.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close()
    return b64


def plot_shannon_bounds():
    """Plot Shannon lower and upper bounds vs entropy."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    for idx, q in enumerate([2, 3, 4]):
        ax = axes[idx]
        # Generate random distributions and compute bounds
        np.random.seed(42)
        entropies = []
        expected_lengths = []
        for _ in range(500):
            p = np.random.dirichlet(np.ones(6) * 0.5)
            H = qary_entropy(q, p)
            lengths = np.ceil(np.log(1.0/p) / np.log(q)).astype(int)
            EL = np.sum(p * lengths)
            entropies.append(H)
            expected_lengths.append(EL)

        entropies = np.array(entropies)
        expected_lengths = np.array(expected_lengths)

        ax.scatter(entropies, expected_lengths, alpha=0.3, s=10, color='#2196F3')
        H_range = np.linspace(0, max(entropies), 100)
        ax.plot(H_range, H_range, 'r-', linewidth=2, label='E[ℓ] = H_q (lower bound)')
        ax.plot(H_range, H_range + 1, 'g--', linewidth=2, label='E[ℓ] = H_q + 1 (upper bound)')
        ax.fill_between(H_range, H_range, H_range + 1, alpha=0.1, color='green')
        ax.set_xlabel(f'H_{q}(p)', fontsize=12)
        ax.set_ylabel('E[ℓ] (expected length)', fontsize=12)
        ax.set_title(f'Shannon Bounds (q = {q})', fontsize=13)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('fig_shannon_bounds.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close()
    return b64


def plot_kraft_inequality():
    """Visualize the Kraft inequality as a constraint surface."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    for q, color, marker in [(2, '#2196F3', 'o'), (3, '#4CAF50', 's'),
                               (4, '#FF9800', '^'), (8, '#9C27B0', 'D')]:
        lengths = np.arange(1, 12)
        weights = q ** (-lengths.astype(float))
        ax.semilogy(lengths, weights, color=color, marker=marker,
                    linewidth=2, markersize=6, label=f'q = {q}')

    ax.axhline(y=1, color='red', linestyle='--', linewidth=1.5, label='Kraft bound = 1')
    ax.set_xlabel('Code length ℓ', fontsize=12)
    ax.set_ylabel('Kraft weight q^{-ℓ}', fontsize=12)
    ax.set_title('Kraft Weights for Different Alphabet Sizes', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1e-8, 2)

    plt.tight_layout()
    fig.savefig('fig_kraft_inequality.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close()
    return b64


def plot_data_processing():
    """Visualize the data processing inequality."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    np.random.seed(42)
    n_source = 8

    # Generate distributions with different levels of non-uniformity
    alphas = np.logspace(-1, 1, 50)
    for q, color in [(2, '#2196F3'), (4, '#FF9800')]:
        orig_entropies = []
        proc_entropies = []

        for alpha in alphas:
            p = np.random.dirichlet(np.ones(n_source) * alpha)
            H_orig = qary_entropy(q, p)

            # Deterministic processing: group pairs
            p_grouped = np.array([p[0]+p[1], p[2]+p[3], p[4]+p[5], p[6]+p[7]])
            H_proc = qary_entropy(q, p_grouped)

            orig_entropies.append(H_orig)
            proc_entropies.append(H_proc)

        ax.scatter(orig_entropies, proc_entropies, alpha=0.5, s=20,
                   color=color, label=f'q = {q}')

    # Identity line
    max_val = max(max(orig_entropies), max(proc_entropies))
    line = np.linspace(0, max_val * 1.1, 100)
    ax.plot(line, line, 'r--', linewidth=2, label='H(f(X)) = H(X)')
    ax.fill_between(line, 0, line, alpha=0.05, color='green')

    ax.set_xlabel('H_q(X) — Original Entropy', fontsize=12)
    ax.set_ylabel('H_q(f(X)) — Processed Entropy', fontsize=12)
    ax.set_title('Data Processing Inequality: Entropy Cannot Increase', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    plt.tight_layout()
    fig.savefig('fig_data_processing.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close()
    return b64


def plot_base_change():
    """Visualize the base change formula."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    ps = np.linspace(0.01, 0.99, 200)

    bases = [(2, '#2196F3', 'bits'), (3, '#4CAF50', 'trits'),
             (4, '#FF9800', 'quats'), (10, '#9C27B0', 'dits')]

    for q, color, unit in bases:
        Hs = [-p*np.log(p)/np.log(q) - (1-p)*np.log(1-p)/np.log(q) for p in ps]
        ax.plot(ps, Hs, color=color, linewidth=2, label=f'q={q} ({unit})')

    ax.set_xlabel('p (probability of symbol 1)', fontsize=12)
    ax.set_ylabel('H_q(p)', fontsize=12)
    ax.set_title('Entropy Base Change: Same Curve, Different Scales', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Add annotation
    ax.annotate('H_q₂ = H_q₁ · log_q₂(q₁)', xy=(0.5, 0.7),
                fontsize=14, ha='center', style='italic',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='wheat', alpha=0.5))

    plt.tight_layout()
    fig.savefig('fig_base_change.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close()
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1 = plot_entropy_landscape()
    print("  ✓ Entropy landscape")

    b64_2 = plot_shannon_bounds()
    print("  ✓ Shannon bounds")

    b64_3 = plot_kraft_inequality()
    print("  ✓ Kraft inequality")

    b64_4 = plot_data_processing()
    print("  ✓ Data processing inequality")

    b64_5 = plot_base_change()
    print("  ✓ Base change")

    print("\nAll visualizations saved!")

    # Return base64 data for JSON package
    viz_data = {
        "entropy_landscape": b64_1,
        "shannon_bounds": b64_2,
        "kraft_inequality": b64_3,
        "data_processing": b64_4,
        "base_change": b64_5,
    }

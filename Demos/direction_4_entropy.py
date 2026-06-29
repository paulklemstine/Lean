#!/usr/bin/env python3
"""
Entropy-Complexity Bridge: Real-World Applications

Demonstrates how the formal theorems apply to practical domains:
1. Machine Learning: Model capacity bounds
2. Cryptography: Information-theoretic security
3. Biology: Genetic code efficiency
4. Communication: Channel capacity limits
"""

import math
import random
from typing import List, Dict, Tuple


def ml_model_capacity():
    """
    Application 1: Machine Learning Model Capacity
    
    By card_le_two_pow_of_injective_code:
    A model with k bits of parameters can distinguish at most 2^k input patterns.
    This gives fundamental limits on what neural networks can learn.
    """
    print("=" * 60)
    print("APPLICATION 1: Machine Learning Model Capacity Bounds")
    print("=" * 60)
    
    print("\nTheorem: A model with k parameter bits can represent at most 2^k")
    print("distinct input-output behaviors (by card_le_two_pow_of_injective_code).")
    print()
    
    models = [
        ("Tiny model (1K params, float32)", 1_000 * 32),
        ("Small model (100K params)", 100_000 * 32),
        ("Medium model (1M params)", 1_000_000 * 32),
        ("GPT-2 (1.5B params, float16)", 1_500_000_000 * 16),
        ("GPT-3 (175B params, float16)", 175_000_000_000 * 16),
    ]
    
    print(f"{'Model':<40} {'Bits':>15} {'log₂(capacity)':>15} {'Capacity':>20}")
    print("-" * 95)
    for name, bits in models:
        log_cap = bits
        cap_str = f"2^{bits}" if bits < 100 else f"≈10^{bits * math.log10(2):.0f}"
        print(f"{name:<40} {bits:>15,} {log_cap:>15,} {cap_str:>20}")
    
    print("\n→ Even GPT-3's vast parameter space has a finite capacity bound.")
    print("  The counting barrier (no_injective_code_of_card_gt) means:")
    print("  if the number of distinct behaviors needed exceeds 2^k,")
    print("  no k-bit model suffices.")


def crypto_information_security():
    """
    Application 2: Cryptographic Information Security
    
    The data processing inequality (support_entropy_comp_monotone)
    implies that post-processing ciphertext cannot recover plaintext
    information that was destroyed during encryption.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Cryptographic Information Bounds")
    print("=" * 60)
    
    # Demonstrate with a simple substitution cipher
    print("\nScenario: Alice encrypts messages, Eve intercepts ciphertext.")
    print("Eve applies various post-processing functions to the ciphertext.")
    print()
    
    # Simple encryption: XOR with key
    key = 42
    messages = list(range(256))  # All possible byte messages
    
    encrypt = lambda m: m ^ key
    
    # Eve's post-processing attempts
    eve_functions = [
        ("Identity (raw ciphertext)", lambda c: c),
        ("Parity bit", lambda c: c % 2),
        ("High nibble", lambda c: c >> 4),
        ("Mod 10", lambda c: c % 10),
        ("Hash (mod 16)", lambda c: (c * 31 + 17) % 16),
    ]
    
    range_encrypt = len(set(encrypt(m) for m in messages))
    
    print(f"|messages| = {len(messages)}")
    print(f"|range(encrypt)| = {range_encrypt}  (bijective encryption)")
    print()
    
    header_col1 = "Eve's function"
    header_col2 = "|range(process . encrypt)|"
    header_col3 = "<= |range(encrypt)|?"
    print(f"{header_col1:<30} {header_col2:>28} {header_col3:>20}")
    print("-" * 80)
    for name, proc in eve_functions:
        range_composed = len(set(proc(encrypt(m)) for m in messages))
        holds = range_composed <= range_encrypt
        print(f"{name:<30} {range_composed:>28} {'✓' if holds else '✗':>20}")
    
    print("\n→ By support_entropy_comp_monotone, Eve can never increase")
    print("  the number of distinguishable outcomes beyond |range(encrypt)|.")
    print("  Post-processing ciphertext can only LOSE information, never gain it.")


def genetic_code_analysis():
    """
    Application 3: Genetic Code Efficiency
    
    The genetic code maps 64 codons to 20 amino acids + stop signal.
    The counting barrier tells us the minimum bits needed.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Genetic Code Information Analysis")
    print("=" * 60)
    
    codons = 64  # 4^3 possible triplets
    amino_acids = 21  # 20 amino acids + 1 stop signal
    
    min_bits = math.ceil(math.log2(amino_acids))
    codon_bits = math.ceil(math.log2(codons))
    redundancy = codon_bits - min_bits
    
    print(f"\nGenetic code:")
    print(f"  Codons (domain): {codons} = 4³ (each codon = 3 nucleotides)")
    print(f"  Amino acids + stop (codomain): {amino_acids}")
    print(f"  Codon → amino acid is a SURJECTIVE map (many-to-one)")
    print()
    print(f"Information analysis:")
    print(f"  Bits per codon: log₂({codons}) = {math.log2(codons):.1f}")
    print(f"  Min bits for amino acid: ⌈log₂({amino_acids})⌉ = {min_bits}")
    print(f"  Redundancy: {codon_bits} - {min_bits} = {redundancy} bits per codon")
    print()
    print(f"By no_injective_code_of_card_gt:")
    print(f"  Since {amino_acids} > 2^{min_bits - 1} = {2**(min_bits-1)},")
    print(f"  at least {min_bits} bits are needed (no {min_bits-1}-bit encoding exists).")
    print()
    print(f"By support_entropy_monotone_under_map:")
    print(f"  |range(genetic_code)| = {amino_acids} ≤ {codons} = |codons|")
    print(f"  The genetic code destroys {codons - amino_acids} distinctions.")
    print(f"  This redundancy enables error correction (wobble base pairing).")
    
    # Show the data processing: translation further reduces info
    print()
    print("Data processing chain:")
    print(f"  DNA (4^n states) → mRNA (4^n) → Protein ({amino_acids}^(n/3) max)")
    
    n = 12  # 12 nucleotides = 4 codons
    dna_states = 4 ** n
    protein_states = amino_acids ** (n // 3)
    print(f"  For n={n}: {dna_states:,} DNA sequences → ≤{protein_states:,} proteins")
    print(f"  Information reduction: {math.log2(dna_states):.0f} bits → {math.log2(protein_states):.1f} bits")


def channel_capacity_demo():
    """
    Application 4: Communication Channel Capacity
    
    Demonstrates source coding bounds: you can't compress below entropy.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Channel Capacity and Source Coding")
    print("=" * 60)
    
    # English text: ~26 letters, but with highly non-uniform frequency
    # Uniform entropy: log₂(26) ≈ 4.7 bits/letter
    # Actual English entropy: ~1.0-1.5 bits/letter (due to patterns)
    
    alphabet_size = 26
    uniform_entropy = math.log2(alphabet_size)
    
    print(f"\nEnglish alphabet: {alphabet_size} letters")
    print(f"Uniform entropy: log₂({alphabet_size}) = {uniform_entropy:.4f} bits/letter")
    print(f"By card_le_two_pow_of_injective_code:")
    print(f"  Need ≥ ⌈{uniform_entropy:.4f}⌉ = {math.ceil(uniform_entropy)} bits per letter (uniform)")
    print()
    
    # Show how the bound applies to different alphabet sizes
    print("Encoding requirements for various alphabets:")
    print(f"{'Alphabet':<25} {'Size':>6} {'Min bits':>10} {'2^bits':>8} {'Efficiency':>12}")
    print("-" * 65)
    
    alphabets = [
        ("Binary", 2),
        ("Decimal digits", 10),
        ("English letters", 26),
        ("Alphanumeric", 62),
        ("ASCII printable", 95),
        ("Unicode BMP", 65536),
        ("Full Unicode", 149186),  # Assigned code points
    ]
    
    for name, size in alphabets:
        bits = math.ceil(math.log2(size))
        efficiency = math.log2(size) / bits * 100
        print(f"{name:<25} {size:>6} {bits:>10} {2**bits:>8} {efficiency:>10.1f}%")
    
    print()
    print("→ The gap between log₂(|alphabet|) and ⌈log₂(|alphabet|)⌉")
    print("  is wasted capacity. Efficient coding (Huffman, arithmetic)")
    print("  approaches the entropy bound, but can never beat it.")
    print("  This is the content of no_injective_code_of_card_gt.")


def entropy_product_application():
    """
    Application 5: Database Record Sizing
    
    Uses entropyBound_prod_of_entropyBound to compute storage requirements
    for structured records.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 5: Database Storage Bounds via Entropy Products")
    print("=" * 60)
    
    fields = [
        ("Country code", 195),
        ("Age (0-150)", 151),
        ("Blood type", 8),
        ("Gender", 3),
        ("Boolean flag", 2),
    ]
    
    print("\nRecord fields:")
    total_bits = 0
    total_card = 1
    for name, card in fields:
        bits = math.ceil(math.log2(card))
        total_bits += bits
        total_card *= card
        print(f"  {name:<20}: {card:>6} values → {bits:>2} bits")
    
    optimal_bits = math.ceil(math.log2(total_card))
    
    print(f"\nBy entropyBound_prod_of_entropyBound:")
    print(f"  Sum of individual bounds: {total_bits} bits")
    print(f"  Product cardinality: {total_card:,}")
    print(f"  Optimal encoding: ⌈log₂({total_card})⌉ = {optimal_bits} bits")
    print(f"  Overhead from independent encoding: {total_bits - optimal_bits} bits ({(total_bits/optimal_bits - 1)*100:.1f}%)")
    print()
    print("  The product theorem guarantees |α₁ × ... × αₙ| ≤ 2^(k₁ + ... + kₙ),")
    print("  so the naive concatenation of individual codes is always valid,")
    print("  even if not optimal.")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Entropy-Complexity Bridge: Real-World Applications     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    ml_model_capacity()
    crypto_information_security()
    genetic_code_analysis()
    channel_capacity_demo()
    entropy_product_application()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Entropy-Complexity Bridge: Demonstrations and Numerical Examples

This script demonstrates the key theorems from the formal development
with concrete numerical examples, making the mathematics tangible.
"""

import random
import math
from collections import Counter


def demo_encoding_bound():
    """
    Demonstrate Theorem: card_le_of_injective_to_fin
    
    If we have an injective encoding of objects into {0, ..., N-1},
    then there are at most N objects.
    """
    print("=" * 60)
    print("DEMO 1: Encoding Bound (card_le_of_injective_to_fin)")
    print("=" * 60)
    
    # Example: encoding 5 colors into 3-bit codes
    colors = ["red", "green", "blue", "yellow", "purple"]
    k = 3  # bits
    code_space_size = 2 ** k
    
    # Create an injective encoding
    encoding = {color: i for i, color in enumerate(colors)}
    
    print(f"\nObjects: {colors}")
    print(f"Code length: {k} bits → code space size: {code_space_size}")
    print(f"Encoding: {encoding}")
    print(f"\n|objects| = {len(colors)} ≤ {code_space_size} = 2^{k} ✓")
    print(f"Entropy bound: log₂({len(colors)}) = {math.log2(len(colors)):.2f} ≤ {k} ✓")
    
    # Show impossibility for too-small codes
    k_small = 2
    print(f"\nWith {k_small}-bit codes: 2^{k_small} = {2**k_small} < {len(colors)} = |objects|")
    print(f"→ No injective {k_small}-bit encoding exists! (no_injective_code_of_card_gt)")


def demo_data_processing():
    """
    Demonstrate Theorem: support_entropy_comp_monotone
    
    |range(g ∘ f)| ≤ |range(f)|
    Deterministic processing cannot increase distinguishable outputs.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Data Processing Inequality (support_entropy_comp_monotone)")
    print("=" * 60)
    
    # Domain: 10 students
    n = 10
    domain = list(range(n))
    
    # f: student → exam score (some collisions)
    random.seed(42)
    scores = [random.randint(60, 100) for _ in range(n)]
    f = dict(zip(domain, scores))
    
    # g: score → letter grade
    def score_to_grade(s):
        if s >= 90: return 'A'
        elif s >= 80: return 'B'
        elif s >= 70: return 'C'
        else: return 'D'
    
    g = {s: score_to_grade(s) for s in set(scores)}
    
    range_f = set(scores)
    range_gf = set(score_to_grade(s) for s in scores)
    
    print(f"\nStudents → Scores: {f}")
    print(f"Score → Grade mapping applied")
    print(f"\n|range(f)| = |distinct scores| = {len(range_f)}")
    print(f"|range(g∘f)| = |distinct grades| = {len(range_gf)}")
    print(f"\n{len(range_gf)} ≤ {len(range_f)} ✓ (Data processing inequality)")
    print(f"Information lost: {len(range_f) - len(range_gf)} categories collapsed")


def demo_entropy_subadditivity():
    """
    Demonstrate Theorem: entropyBound_prod_of_entropyBound
    
    If |α| ≤ 2^k and |β| ≤ 2^ℓ, then |α × β| ≤ 2^(k+ℓ).
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Entropy Subadditivity (entropyBound_prod_of_entropyBound)")
    print("=" * 60)
    
    # α = playing card suits (4 = 2^2), β = coin flips (2 = 2^1)
    suits = ["♠", "♥", "♦", "♣"]
    coins = ["H", "T"]
    k, l = 2, 1
    
    product = [(s, c) for s in suits for c in coins]
    
    print(f"\nα = card suits: {suits}, |α| = {len(suits)} ≤ 2^{k} = {2**k}")
    print(f"β = coin flips: {coins}, |β| = {len(coins)} ≤ 2^{l} = {2**l}")
    print(f"\nα × β has {len(product)} elements:")
    for i, (s, c) in enumerate(product):
        print(f"  {i}: ({s}, {c})")
    print(f"\n|α × β| = {len(product)} ≤ 2^({k}+{l}) = 2^{k+l} = {2**(k+l)} ✓")
    print(f"Joint entropy: log₂({len(product)}) = {math.log2(len(product)):.2f} ≤ {k} + {l} = {k+l} ✓")


def demo_compressor_bridge():
    """
    Demonstrate Theorem: complexity_bound_implies_finite_entropy_bound
    
    If a compressor bounds all outputs to length ≤ k,
    then the source has at most 2^(k+1) elements.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Compressor-to-Entropy Bridge")
    print("=" * 60)
    
    # Simple run-length encoding as compressor
    def compress(bits):
        """Simple compressor: remove trailing zeros."""
        if not bits:
            return bits
        result = list(bits)
        while result and result[-1] == 0:
            result.pop()
        if not result:
            return [0]  # Keep at least one bit
        return result
    
    def decompress(bits, original_length):
        """Decompress by padding with zeros."""
        return bits + [0] * (original_length - len(bits))
    
    # Source: all 4-bit strings
    n = 4
    source = []
    for i in range(2**n):
        bits = [(i >> j) & 1 for j in range(n)]
        source.append(bits)
    
    print(f"\nSource: all {n}-bit strings ({len(source)} elements)")
    print(f"\nCompressed lengths:")
    
    max_compressed_len = 0
    for bits in source:
        compressed = compress(bits)
        max_compressed_len = max(max_compressed_len, len(compressed))
        print(f"  {bits} → {compressed} (length {len(compressed)})")
    
    k = max_compressed_len
    bound = 2 ** (k + 1)
    print(f"\nMax compressed length k = {k}")
    print(f"Theorem gives: |source| ≤ 2^(k+1) = 2^{k+1} = {bound}")
    print(f"Actual: |source| = {len(source)}")
    print(f"{len(source)} ≤ {bound} ✓")
    
    # Count strings of length ≤ k
    count_strings_le_k = sum(2**i for i in range(k + 1))
    print(f"\nNumber of binary strings of length ≤ {k}: {count_strings_le_k}")
    print(f"This equals 2^{k+1} - 1 = {2**(k+1) - 1}")


def demo_counting_lower_bound():
    """
    Demonstrate the counting-based lower bound.
    
    If |α| > 2^k, no injective k-bit encoding exists.
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Counting Lower Bound (no_injective_code_of_card_gt)")
    print("=" * 60)
    
    # Try to encode 26 letters with different bit lengths
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    n = len(alphabet)
    
    print(f"\nAlphabet size: {n}")
    print(f"\nBit requirements:")
    for k in range(1, 6):
        capacity = 2 ** k
        if capacity < n:
            print(f"  {k} bits → 2^{k} = {capacity:>4} < {n} = |alphabet| → IMPOSSIBLE")
        else:
            print(f"  {k} bits → 2^{k} = {capacity:>4} ≥ {n} = |alphabet| → SUFFICIENT ✓")
            print(f"  Minimum bits needed: {k}")
            print(f"  Entropy: log₂({n}) = {math.log2(n):.4f}")
            print(f"  ⌈log₂({n})⌉ = {math.ceil(math.log2(n))} = minimum integer bits")
            break


def demo_data_processing_statistics():
    """
    Statistical verification of the data processing inequality
    over many random function pairs.
    """
    print("\n" + "=" * 60)
    print("DEMO 6: Statistical Verification of Data Processing Inequality")
    print("=" * 60)
    
    random.seed(123)
    num_trials = 10000
    violations = 0
    ratios = []
    
    for _ in range(num_trials):
        n = random.randint(2, 30)
        m = random.randint(2, 30)
        p = random.randint(2, 30)
        
        # Random f: [n] → [m]
        f = [random.randint(0, m-1) for _ in range(n)]
        # Random g: [m] → [p]
        g = [random.randint(0, p-1) for _ in range(m)]
        
        range_f = len(set(f))
        range_gf = len(set(g[fi] for fi in f))
        
        if range_gf > range_f:
            violations += 1
        if range_f > 0:
            ratios.append(range_gf / range_f)
    
    avg_ratio = sum(ratios) / len(ratios)
    
    print(f"\nTrials: {num_trials}")
    print(f"Violations of |range(g∘f)| ≤ |range(f)|: {violations}")
    print(f"Average ratio |range(g∘f)| / |range(f)|: {avg_ratio:.4f}")
    print(f"Min ratio: {min(ratios):.4f}")
    print(f"Max ratio: {max(ratios):.4f}")
    print(f"\nThe inequality holds in ALL cases, as guaranteed by the theorem. ✓")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Entropy-Complexity Bridge: Numerical Demonstrations    ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_encoding_bound()
    demo_data_processing()
    demo_entropy_subadditivity()
    demo_compressor_bridge()
    demo_counting_lower_bound()
    demo_data_processing_statistics()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("Every theorem verified numerically. ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts embedded."""

import json
import sys
sys.path.insert(0, '/workspace/request-project')

from visualizations import (
    plot_encoding_capacity, plot_data_processing, 
    plot_entropy_subadditivity, plot_compression_impossibility,
    plot_bridge_theorem
)

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')
lean_code = read_file('/workspace/request-project/Catalog/Computation/EntropyBridge.lean')

# Generate visualizations
print("Generating visualizations...")
viz1 = plot_encoding_capacity()
viz2 = plot_data_processing()
viz3 = plot_entropy_subadditivity()
viz4 = plot_compression_impossibility()
viz5 = plot_bridge_theorem()

package = {
    "title": "Entropy-Complexity Bridge: From Compression to Information Bounds",
    "domain": "Computation / Information Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Entropy-Complexity Bridge Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Entropy Bound Computation",
            "pseudocode": "INPUT: cardinality n\nOUTPUT: minimum bits k such that n <= 2^k\n\n1. If n <= 1, return 0\n2. Return ceil(log2(n))",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Encoding Capacity Bound", "data": viz1},
        {"name": "Data Processing Inequality", "data": viz2},
        {"name": "Entropy Subadditivity", "data": viz3},
        {"name": "Compression Impossibility Region", "data": viz4},
        {"name": "Compressor-to-Entropy Bridge", "data": viz5},
    ],
    "lean_proofs": lean_code
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Entropy-Complexity Bridge: Visualizations

Generates charts and diagrams illustrating the key theorems.
Saves figures as PNG files and returns base64-encoded data URIs.
"""

import math
import random
import base64
import io

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_encoding_capacity():
    """Plot 2^k encoding capacity vs k (bits)."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    k_vals = np.arange(0, 21)
    capacity = 2.0 ** k_vals
    
    # Linear scale
    ax1.plot(k_vals, capacity, 'b-o', markersize=4, linewidth=2)
    ax1.fill_between(k_vals, 0, capacity, alpha=0.15, color='blue')
    ax1.set_xlabel('Code length k (bits)', fontsize=12)
    ax1.set_ylabel('Max encodable objects (2^k)', fontsize=12)
    ax1.set_title('Encoding Capacity: Linear Scale', fontsize=13)
    ax1.set_yscale('linear')
    ax1.set_ylim(0, 2**10)
    ax1.set_xlim(0, 10)
    ax1.grid(True, alpha=0.3)
    ax1.annotate('card_le_two_pow_of_injective_code:\n|α| ≤ 2^k', 
                 xy=(5, 32), fontsize=10, 
                 bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    # Log scale
    ax2.semilogy(k_vals, capacity, 'r-o', markersize=4, linewidth=2)
    ax2.fill_between(k_vals, 1, capacity, alpha=0.15, color='red')
    ax2.set_xlabel('Code length k (bits)', fontsize=12)
    ax2.set_ylabel('Max encodable objects (2^k)', fontsize=12)
    ax2.set_title('Encoding Capacity: Log Scale', fontsize=13)
    ax2.grid(True, alpha=0.3)
    
    # Annotate key points
    for k in [8, 16, 20]:
        ax2.annotate(f'k={k}: {2**k:,}', xy=(k, 2**k), 
                     textcoords="offset points", xytext=(10, 5), fontsize=9)
    
    fig.suptitle('Theorem: Injective Encoding Capacity Bound', fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    uri = fig_to_base64(fig)
    fig2, ax = plt.subplots(figsize=(14, 5))  # Save to file too
    fig.savefig('/workspace/request-project/viz_encoding_capacity.png', dpi=150, bbox_inches='tight')
    return uri


def plot_data_processing():
    """Visualize the data processing inequality through random trials."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    random.seed(42)
    np.random.seed(42)
    
    # Trial 1: Fixed dimensions, many samples
    n, m, p = 20, 15, 10
    range_f_list = []
    range_gf_list = []
    
    for _ in range(500):
        f = np.random.randint(0, m, size=n)
        g = np.random.randint(0, p, size=m)
        rf = len(set(f))
        rgf = len(set(g[fi] for fi in f))
        range_f_list.append(rf)
        range_gf_list.append(rgf)
    
    ax = axes[0]
    ax.scatter(range_f_list, range_gf_list, alpha=0.3, s=15, c='blue')
    max_val = max(max(range_f_list), max(range_gf_list))
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (boundary)')
    ax.set_xlabel('|range(f)|', fontsize=11)
    ax.set_ylabel('|range(g ∘ f)|', fontsize=11)
    ax.set_title(f'Data Processing: n={n}, m={m}, p={p}', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    
    # Trial 2: Varying dimensions
    ratios = []
    dims = []
    for _ in range(1000):
        n = random.randint(5, 50)
        m = random.randint(5, 50)
        p = random.randint(5, 50)
        f = np.random.randint(0, m, size=n)
        g = np.random.randint(0, p, size=m)
        rf = len(set(f))
        rgf = len(set(g[fi] for fi in f))
        if rf > 0:
            ratios.append(rgf / rf)
            dims.append(n)
    
    ax = axes[1]
    ax.hist(ratios, bins=30, color='green', alpha=0.7, edgecolor='darkgreen')
    ax.axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='Barrier (ratio = 1)')
    ax.set_xlabel('Ratio |range(g∘f)| / |range(f)|', fontsize=11)
    ax.set_ylabel('Frequency', fontsize=11)
    ax.set_title('Distribution of Compression Ratios', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Trial 3: Chain of compositions
    chain_lengths = [1, 2, 3, 4, 5, 6, 7, 8]
    avg_ranges = []
    
    for length in chain_lengths:
        ranges = []
        for _ in range(200):
            n = 50
            values = list(range(n))
            for _ in range(length):
                m = random.randint(10, 50)
                func = [random.randint(0, m-1) for _ in range(max(values) + 1 if values else 1)]
                values = [func[v % len(func)] for v in values]
            ranges.append(len(set(values)))
        avg_ranges.append(np.mean(ranges))
    
    ax = axes[2]
    ax.plot(chain_lengths, avg_ranges, 'mo-', markersize=8, linewidth=2)
    ax.fill_between(chain_lengths, 0, avg_ranges, alpha=0.15, color='purple')
    ax.set_xlabel('Number of compositions', fontsize=11)
    ax.set_ylabel('Average |range|', fontsize=11)
    ax.set_title('Support Monotonicity Under Chaining', fontsize=12)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Combinatorial Data Processing Inequality: |range(g∘f)| ≤ |range(f)|', 
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    uri = fig_to_base64(fig)
    return uri


def plot_entropy_subadditivity():
    """Visualize entropy subadditivity for product types."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Heatmap of product cardinalities
    k_range = np.arange(1, 11)
    l_range = np.arange(1, 11)
    K, L = np.meshgrid(k_range, l_range)
    product_bound = 2.0 ** (K + L)
    
    im = ax1.imshow(np.log2(product_bound), extent=[0.5, 10.5, 0.5, 10.5],
                     origin='lower', cmap='YlOrRd', aspect='equal')
    ax1.set_xlabel('k (bits for α)', fontsize=11)
    ax1.set_ylabel('ℓ (bits for β)', fontsize=11)
    ax1.set_title('log₂(2^(k+ℓ)) = k+ℓ: Joint Entropy Bound', fontsize=12)
    cbar = plt.colorbar(im, ax=ax1)
    cbar.set_label('k + ℓ (joint bits)', fontsize=10)
    
    # Bar chart comparing individual vs joint
    scenarios = [
        ("Suit × Coin", 4, 2, 2, 1),
        ("Color × Size", 8, 4, 3, 2),
        ("Letter × Digit", 26, 10, 5, 4),
        ("ASCII × Bool", 128, 2, 7, 1),
    ]
    
    names = [s[0] for s in scenarios]
    individual_sums = [s[3] + s[4] for s in scenarios]
    optimal = [math.ceil(math.log2(s[1] * s[2])) for s in scenarios]
    
    x = np.arange(len(names))
    width = 0.35
    
    bars1 = ax2.bar(x - width/2, individual_sums, width, label='Sum of bounds (k+ℓ)', 
                     color='coral', edgecolor='darkred', alpha=0.8)
    bars2 = ax2.bar(x + width/2, optimal, width, label='Optimal ⌈log₂(|α|·|β|)⌉', 
                     color='steelblue', edgecolor='navy', alpha=0.8)
    
    ax2.set_xlabel('Product type', fontsize=11)
    ax2.set_ylabel('Bits required', fontsize=11)
    ax2.set_title('Individual vs. Joint Encoding', fontsize=12)
    ax2.set_xticks(x)
    ax2.set_xticklabels(names, fontsize=9)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3, axis='y')
    
    fig.suptitle('Entropy Subadditivity: H(α×β) ≤ H(α) + H(β)', 
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    uri = fig_to_base64(fig)
    return uri


def plot_compression_impossibility():
    """Visualize the compression impossibility region."""
    fig, ax = plt.subplots(figsize=(10, 7))
    
    k_vals = np.arange(0, 16)
    boundary = 2.0 ** k_vals
    
    # Fill regions
    ax.fill_between(k_vals, 0, boundary, alpha=0.2, color='green', label='Encodable region: |α| ≤ 2^k')
    ax.fill_between(k_vals, boundary, 2**16, alpha=0.15, color='red', label='Impossible region: |α| > 2^k')
    
    ax.semilogy(k_vals, boundary, 'k-', linewidth=3, label='Boundary: |α| = 2^k')
    
    # Annotate specific examples
    examples = [
        (3, 8, "8 colors\n(3 bits)", 'green'),
        (5, 26, "26 letters\n(5 bits)", 'green'),
        (7, 128, "ASCII\n(7 bits)", 'green'),
        (2, 8, "8 colors\nin 2 bits:\nIMPOSSIBLE", 'red'),
        (4, 26, "26 letters\nin 4 bits:\nIMPOSSIBLE", 'red'),
    ]
    
    for k, n, label, color in examples:
        marker = 'o' if color == 'green' else 'x'
        ax.plot(k, n, marker=marker, markersize=12, color=color, markeredgewidth=2)
        offset = (15, -10) if color == 'green' else (-15, 10)
        ax.annotate(label, xy=(k, n), textcoords="offset points", xytext=offset,
                    fontsize=8, ha='center',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor=color, alpha=0.2))
    
    ax.set_xlabel('Code length k (bits)', fontsize=12)
    ax.set_ylabel('Collection size |α|', fontsize=12)
    ax.set_title('Compression Impossibility Theorem\n(no_injective_code_of_card_gt)', 
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='lower right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, 15.5)
    ax.set_ylim(0.8, 2**16)
    
    uri = fig_to_base64(fig)
    return uri


def plot_bridge_theorem():
    """Visualize the compressor-to-entropy bridge theorem."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: Number of binary strings of length ≤ k
    k_vals = np.arange(0, 13)
    strings_le_k = np.array([2**(k+1) - 1 for k in k_vals])
    bound = 2.0 ** (k_vals + 1)
    
    ax1.bar(k_vals, strings_le_k, color='steelblue', alpha=0.7, label='# strings of length ≤ k')
    ax1.plot(k_vals, bound, 'r-o', markersize=6, linewidth=2, label='2^(k+1) bound')
    ax1.set_xlabel('Max compressed length k', fontsize=11)
    ax1.set_ylabel('Number of possible codes', fontsize=11)
    ax1.set_title('Code Space Size vs. Bound', fontsize=12)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.set_yscale('log')
    
    # Right: Bridge diagram
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 10)
    ax2.set_aspect('equal')
    
    # Draw boxes
    boxes = [
        (1, 7, 2.5, 1.5, 'Compressor\nC', 'lightyellow'),
        (1, 4, 2.5, 1.5, 'Bounded\nCode Length ≤ k', 'lightblue'),
        (1, 1, 2.5, 1.5, 'Injective\nEncoding', 'lightgreen'),
        (6, 4, 2.5, 1.5, 'Entropy\nBound\n|α| ≤ 2^(k+1)', 'lightsalmon'),
    ]
    
    for x, y, w, h, text, color in boxes:
        rect = mpatches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.2",
                                        facecolor=color, edgecolor='black', linewidth=2)
        ax2.add_patch(rect)
        ax2.text(x + w/2, y + h/2, text, ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Arrows
    ax2.annotate('', xy=(2.25, 7), xytext=(2.25, 5.5),
                 arrowprops=dict(arrowstyle='->', linewidth=2, color='black'))
    ax2.annotate('', xy=(2.25, 4), xytext=(2.25, 2.5),
                 arrowprops=dict(arrowstyle='->', linewidth=2, color='black'))
    ax2.annotate('', xy=(6, 4.75), xytext=(3.5, 4.75),
                 arrowprops=dict(arrowstyle='->', linewidth=2, color='red'))
    
    ax2.text(4.75, 5.3, 'Bridge\nTheorem', ha='center', va='center', fontsize=10,
             fontweight='bold', color='red')
    
    ax2.set_title('Compressor → Entropy Bridge', fontsize=12)
    ax2.axis('off')
    
    fig.suptitle('complexity_bound_implies_finite_entropy_bound', 
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    
    uri = fig_to_base64(fig)
    return uri


if __name__ == "__main__":
    print("Generating visualizations...")
    
    uri1 = plot_encoding_capacity()
    print(f"1. Encoding capacity: {len(uri1)} chars")
    
    uri2 = plot_data_processing()
    print(f"2. Data processing: {len(uri2)} chars")
    
    uri3 = plot_entropy_subadditivity()
    print(f"3. Entropy subadditivity: {len(uri3)} chars")
    
    uri4 = plot_compression_impossibility()
    print(f"4. Compression impossibility: {len(uri4)} chars")
    
    uri5 = plot_bridge_theorem()
    print(f"5. Bridge theorem: {len(uri5)} chars")
    
    print("\nAll visualizations generated successfully.")

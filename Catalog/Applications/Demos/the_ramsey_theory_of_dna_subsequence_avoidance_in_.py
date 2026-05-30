#!/usr/bin/env python3
"""
Applications of k-Mer Ramsey Theory to Real-World Problems

Demonstrates practical applications of the pigeonhole and birthday paradox
bounds for k-mer repetition in:
1. Genome assembly — estimating read length requirements
2. Sequence compression — k-mer diversity as compressibility predictor
3. Forensic DNA — uniqueness guarantees for short tandem repeat analysis
"""

import random
import math
from collections import Counter, defaultdict
from typing import List, Dict, Tuple


DNA = ['A', 'C', 'G', 'T']


def generate_random_dna(length: int) -> str:
    return ''.join(random.choice(DNA) for _ in range(length))


def generate_repeat_rich(length: int, repeat_fraction: float = 0.5) -> str:
    """Generate sequence with repeat elements (like a real genome)."""
    seq = list(generate_random_dna(length))
    # Insert Alu-like repeats (~300bp elements)
    alu_length = min(50, length // 4)
    alu_template = generate_random_dna(alu_length)
    n_copies = int(length * repeat_fraction / alu_length)
    for _ in range(n_copies):
        pos = random.randint(0, length - alu_length)
        # Insert with ~10% mutation rate
        for j in range(alu_length):
            if random.random() > 0.1:
                seq[pos + j] = alu_template[j]
    return ''.join(seq)


def extract_kmers(seq: str, k: int) -> List[str]:
    return [seq[i:i+k] for i in range(len(seq) - k + 1)]


def kmer_diversity(seq: str, k: int) -> float:
    return len(set(extract_kmers(seq, k))) / (4 ** k)


def first_repeat_pos(seq: str, k: int) -> int:
    seen = set()
    for i in range(len(seq) - k + 1):
        kmer = seq[i:i+k]
        if kmer in seen:
            return i + k
        seen.add(kmer)
    return len(seq)


# ---- Application 1: Genome Assembly ----

def app_genome_assembly():
    """
    Application: Estimating minimum read length for unique k-mer anchoring.
    
    In genome assembly, reads must be long enough that their k-mers provide
    unique anchoring points. The pigeonhole bound tells us the maximum
    repeat-free length; the birthday paradox tells us the expected length.
    
    For a genome with diversity index δ, the effective k-mer space is δ·4^k,
    and the birthday paradox gives expected unique anchoring at:
        L ≈ sqrt(π/2 · δ · 4^k) + k
    """
    print("=" * 60)
    print("APPLICATION 1: Genome Assembly — Read Length Requirements")
    print("=" * 60)
    
    genome_length = 10000
    
    for genome_type, gen_fn in [
        ("Random genome", lambda: generate_random_dna(genome_length)),
        ("Repeat-rich genome (50%)", lambda: generate_repeat_rich(genome_length, 0.5)),
        ("Repeat-rich genome (80%)", lambda: generate_repeat_rich(genome_length, 0.8)),
    ]:
        genome = gen_fn()
        print(f"\n{genome_type} (length {genome_length}):")
        
        for k in [4, 6, 8]:
            di = kmer_diversity(genome, k)
            effective_space = di * (4 ** k)
            expected_unique = math.sqrt(math.pi / 2 * effective_space) + k
            pigeonhole = 4 ** k + k - 1
            
            print(f"  k={k}: diversity={di:.4f}, effective space={effective_space:.0f}")
            print(f"        Expected unique anchor: {expected_unique:.0f}bp")
            print(f"        Pigeonhole guarantee:   {pigeonhole}bp")
            print(f"        Recommended read length: ≥{int(expected_unique * 1.5)}bp")


# ---- Application 2: Sequence Compression ----

def app_compression():
    """
    Application: k-mer diversity predicts sequence compressibility.
    
    A sequence with diversity index δ can potentially be compressed to
    ~δ fraction of its naive encoding size, since only δ·4^k of the
    4^k possible k-mers actually appear.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Sequence Compression via k-Mer Diversity")
    print("=" * 60)
    
    length = 5000
    
    for name, seq in [
        ("Random DNA", generate_random_dna(length)),
        ("Low-complexity (ATAT...)", ('ATAT' * (length // 4 + 1))[:length]),
        ("Repeat-rich (50%)", generate_repeat_rich(length, 0.5)),
        ("Homopolymer (AAAA...)", 'A' * length),
    ]:
        print(f"\n{name} (length {length}):")
        
        for k in [3, 4, 5]:
            kmers = extract_kmers(seq, k)
            distinct = len(set(kmers))
            total_possible = 4 ** k
            di = distinct / total_possible
            
            # Naive encoding: 2 bits per nucleotide
            naive_bits = 2 * length
            # k-mer encoding: ceil(log2(distinct)) bits per window + overhead
            if distinct > 1:
                compressed_bits = math.ceil(math.log2(distinct)) * (length - k + 1) + k * 2
            else:
                compressed_bits = length - k + 1 + k * 2
            
            ratio = compressed_bits / naive_bits
            print(f"  k={k}: {distinct}/{total_possible} k-mers, "
                  f"diversity={di:.4f}, compression≈{ratio:.3f}")


# ---- Application 3: Forensic DNA ----

def app_forensic():
    """
    Application: Short Tandem Repeat (STR) analysis uniqueness.
    
    Forensic DNA profiling uses STR loci — regions with repeated short motifs.
    The pigeonhole principle guarantees that within any window of length 4^k + k,
    some k-mer must repeat. For forensic markers (k≈4), this means STR regions
    of length ≥260 are guaranteed to have repeated 4-mers.
    
    The birthday paradox gives the expected number of loci needed for
    a unique profile: with d distinct k-mers per locus and L loci,
    the probability of a random match is approximately 1/d^L.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Forensic DNA — STR Uniqueness Guarantees")
    print("=" * 60)
    
    k = 4
    max_kmers = 4 ** k
    
    print(f"\nk = {k} (4-mers): {max_kmers} possible patterns")
    print(f"Pigeonhole: any sequence ≥ {max_kmers + k} bp has a repeated 4-mer")
    
    # Simulate STR loci
    n_loci = 13  # FBI CODIS uses 13 STR loci
    locus_lengths = [random.randint(100, 300) for _ in range(n_loci)]
    
    print(f"\nSimulated {n_loci} STR loci (CODIS-like):")
    total_distinct = 1
    for i, ll in enumerate(locus_lengths):
        locus_seq = generate_repeat_rich(ll, 0.7)  # STR loci are repeat-rich
        di = kmer_diversity(locus_seq, k)
        distinct = len(set(extract_kmers(locus_seq, k)))
        total_distinct *= distinct
        print(f"  Locus {i+1}: {ll}bp, {distinct} distinct 4-mers, diversity={di:.3f}")
    
    discriminating_power = total_distinct
    print(f"\nTotal discriminating power: {discriminating_power:.2e}")
    print(f"  = 1 in {discriminating_power:.2e} chance of random match")
    print(f"  World population: ~8e9")
    print(f"  Sufficient for unique ID: {'YES' if discriminating_power > 8e9 else 'NO'}")


if __name__ == "__main__":
    random.seed(42)
    app_genome_assembly()
    app_compression()
    app_forensic()
    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Ramsey Theory of DNA — k-Mer Repetition in Genetic Sequences

Demonstrates the pigeonhole principle for k-mers: any DNA sequence of length
≥ α^k + k must contain a repeated k-mer. Compares theoretical bounds with
empirical measurements on random and structured sequences.
"""

import random
import math
from collections import Counter
from typing import List, Tuple, Optional

# DNA alphabet
DNA = ['A', 'C', 'G', 'T']
ALPHA = len(DNA)  # 4


def extract_kmers(seq: str, k: int) -> List[str]:
    """Extract all contiguous k-mers from a sequence."""
    return [seq[i:i+k] for i in range(len(seq) - k + 1)]


def first_repeat_position(seq: str, k: int) -> Optional[int]:
    """Find the first window index where a repeated k-mer occurs.
    Returns the length of prefix needed to see the first repeat."""
    seen = set()
    for i in range(len(seq) - k + 1):
        kmer = seq[i:i+k]
        if kmer in seen:
            return i + k  # length of sequence up to (and including) repeat
        seen.add(kmer)
    return None  # no repeat found


def distinct_kmer_count(seq: str, k: int) -> int:
    """Count distinct k-mers in a sequence."""
    return len(set(extract_kmers(seq, k)))


def kmer_diversity_index(seq: str, k: int) -> float:
    """Compute the k-mer diversity index: distinct k-mers / α^k."""
    return distinct_kmer_count(seq, k) / (ALPHA ** k)


def generate_random_dna(length: int) -> str:
    """Generate a random DNA sequence."""
    return ''.join(random.choice(DNA) for _ in range(length))


def generate_low_complexity(length: int, repeat_unit: str = "ATAT") -> str:
    """Generate a low-complexity (microsatellite-like) DNA sequence."""
    repeats = (length // len(repeat_unit)) + 1
    return (repeat_unit * repeats)[:length]


def generate_mixed_complexity(length: int, low_frac: float = 0.3) -> str:
    """Generate a mixed sequence: some random, some low-complexity regions."""
    seq = list(generate_random_dna(length))
    # Insert low-complexity blocks
    block_size = max(10, length // 20)
    num_blocks = int(length * low_frac / block_size)
    for _ in range(num_blocks):
        start = random.randint(0, length - block_size)
        unit = random.choice(['AT', 'CG', 'ATAT', 'GCGC', 'AAAA', 'TTTT'])
        for j in range(block_size):
            seq[start + j] = unit[j % len(unit)]
    return ''.join(seq)


def demo_pigeonhole_bound():
    """Demonstrate the pigeonhole bound for k-mers."""
    print("=" * 60)
    print("DEMO 1: Pigeonhole Bound for k-Mers")
    print("=" * 60)
    
    for k in range(2, 7):
        max_kmers = ALPHA ** k
        max_repeat_free = max_kmers + k - 1
        print(f"\nk = {k}:")
        print(f"  Possible k-mers: 4^{k} = {max_kmers}")
        print(f"  Max repeat-free length: {max_kmers} + {k} - 1 = {max_repeat_free}")
        print(f"  Any sequence of length ≥ {max_repeat_free + 1} MUST have a repeated {k}-mer")
        
        # Verify empirically
        trials = 1000
        all_have_repeat = True
        for _ in range(trials):
            seq = generate_random_dna(max_repeat_free + 1)
            if first_repeat_position(seq, k) is None:
                all_have_repeat = False
                break
        print(f"  Empirical verification ({trials} trials): {'CONFIRMED' if all_have_repeat else 'FAILED'}")


def demo_birthday_paradox():
    """Demonstrate the birthday paradox for k-mers:
    expected first repeat occurs much earlier than the pigeonhole bound."""
    print("\n" + "=" * 60)
    print("DEMO 2: Birthday Paradox for k-Mers")
    print("=" * 60)
    
    for k in [3, 4, 5]:
        max_kmers = ALPHA ** k
        # Birthday paradox predicts first repeat around sqrt(π/2 * N) ≈ 1.25 * sqrt(N)
        birthday_prediction = 1.25 * math.sqrt(max_kmers) + k
        
        trials = 5000
        first_repeats = []
        for _ in range(trials):
            seq = generate_random_dna(max_kmers + k)
            pos = first_repeat_position(seq, k)
            if pos is not None:
                first_repeats.append(pos)
        
        avg_first = sum(first_repeats) / len(first_repeats) if first_repeats else float('inf')
        
        print(f"\nk = {k} (k-mer space = {max_kmers}):")
        print(f"  Pigeonhole bound: {max_kmers + k}")
        print(f"  Birthday prediction: ~{birthday_prediction:.1f}")
        print(f"  Empirical average first repeat: {avg_first:.1f}")
        print(f"  Ratio (empirical/pigeonhole): {avg_first/(max_kmers+k):.3f}")


def demo_diversity_index():
    """Demonstrate the k-mer diversity index for different sequence types."""
    print("\n" + "=" * 60)
    print("DEMO 3: k-Mer Diversity Index")
    print("=" * 60)
    
    k = 4
    length = 1000
    
    random_seq = generate_random_dna(length)
    low_seq = generate_low_complexity(length)
    mixed_seq = generate_mixed_complexity(length)
    
    for name, seq in [("Random", random_seq), ("Low-complexity", low_seq), ("Mixed", mixed_seq)]:
        di = kmer_diversity_index(seq, k)
        dc = distinct_kmer_count(seq, k)
        print(f"\n{name} sequence (length {length}, k={k}):")
        print(f"  Distinct {k}-mers: {dc} / {ALPHA**k} = {dc}/{ALPHA**k}")
        print(f"  Diversity index: {di:.4f}")
        print(f"  Repeat-free? {dc == len(seq) - k + 1}")


def demo_compression_ratio():
    """Demonstrate how k-mer diversity connects to sequence compressibility."""
    print("\n" + "=" * 60)
    print("DEMO 4: Compression and k-Mer Diversity (Cross-Domain)")
    print("=" * 60)
    
    k = 4
    for length in [100, 500, 1000, 5000]:
        random_di = sum(kmer_diversity_index(generate_random_dna(length), k) for _ in range(100)) / 100
        low_di = kmer_diversity_index(generate_low_complexity(length), k)
        mixed_di = sum(kmer_diversity_index(generate_mixed_complexity(length), k) for _ in range(100)) / 100
        
        print(f"\nLength {length}:")
        print(f"  Random diversity:        {random_di:.4f}")
        print(f"  Low-complexity diversity: {low_di:.4f}")
        print(f"  Mixed diversity:         {mixed_di:.4f}")
        print(f"  Compression potential:   random={1-random_di:.2%}, mixed={1-mixed_di:.2%}")


def demo_conjecture_test():
    """Test the falsifiable conjecture about repeat forcing in random vs structured sequences."""
    print("\n" + "=" * 60)
    print("DEMO 5: Conjecture Test — Random vs Structured Repeat Forcing")
    print("=" * 60)
    
    k = 4
    trials = 5000
    
    # Random sequences
    random_repeats = []
    for _ in range(trials):
        seq = generate_random_dna(300)
        pos = first_repeat_position(seq, k)
        if pos:
            random_repeats.append(pos)
    
    # Mixed (genome-like) sequences
    mixed_repeats = []
    for _ in range(trials):
        seq = generate_mixed_complexity(300, low_frac=0.3)
        pos = first_repeat_position(seq, k)
        if pos:
            mixed_repeats.append(pos)
    
    # Low complexity
    low_repeats = []
    for _ in range(trials):
        seq = generate_low_complexity(300)
        pos = first_repeat_position(seq, k)
        if pos:
            low_repeats.append(pos)
    
    avg_random = sum(random_repeats) / len(random_repeats) if random_repeats else 0
    avg_mixed = sum(mixed_repeats) / len(mixed_repeats) if mixed_repeats else 0
    avg_low = sum(low_repeats) / len(low_repeats) if low_repeats else 0
    
    print(f"\nk = {k} (4-mers), {trials} trials each:")
    print(f"  Random DNA — avg first repeat at position: {avg_random:.1f}")
    print(f"  Mixed DNA  — avg first repeat at position: {avg_mixed:.1f}")
    print(f"  Low-complexity — avg first repeat at position: {avg_low:.1f}")
    print(f"\n  Compression ratio (random/mixed): {avg_random/avg_mixed:.2f}x")
    print(f"  Compression ratio (random/low):   {avg_random/avg_low:.2f}x")
    print(f"\n  Conjecture predicts ratio > 2 for random/low-complexity:")
    print(f"  Result: {'SUPPORTED' if avg_random/avg_low > 2 else 'NOT SUPPORTED'}")


if __name__ == "__main__":
    random.seed(42)
    demo_pigeonhole_bound()
    demo_birthday_paradox()
    demo_diversity_index()
    demo_compression_ratio()
    demo_conjecture_test()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Birthday Paradox for k-Mers

Shows the distribution of first k-mer repeat positions for random DNA
sequences, compared to the birthday paradox prediction and the pigeonhole
upper bound. Demonstrates that repeats occur much earlier than the
worst-case pigeonhole bound predicts.
"""

import numpy as np
import matplotlib.pyplot as plt
import random
import math

DNA = ['A', 'C', 'G', 'T']

def generate_random_dna(length):
    return ''.join(random.choice(DNA) for _ in range(length))

def first_repeat_position(seq, k):
    seen = set()
    for i in range(len(seq) - k + 1):
        kmer = seq[i:i+k]
        if kmer in seen:
            return i + k
        seen.add(kmer)
    return None

random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
axes = axes.flatten()

for idx, k in enumerate([3, 4, 5, 6]):
    ax = axes[idx]
    space = 4 ** k
    pigeonhole = space + k
    birthday = math.sqrt(math.pi / 2 * space) + k
    
    # Generate empirical distribution
    n_trials = 10000
    max_len = min(pigeonhole + 10, 10000)
    positions = []
    for _ in range(n_trials):
        seq = generate_random_dna(max_len)
        pos = first_repeat_position(seq, k)
        if pos is not None:
            positions.append(pos)
    
    # Histogram
    bins = min(50, max(10, len(set(positions)) // 5))
    ax.hist(positions, bins=bins, density=True, alpha=0.7,
            color='steelblue', edgecolor='white', label='Empirical')
    
    # Mark birthday prediction
    ax.axvline(birthday, color='red', linewidth=2, linestyle='--',
               label=f'Birthday: {birthday:.0f}')
    
    # Mark pigeonhole bound
    if pigeonhole <= max_len * 1.5:
        ax.axvline(pigeonhole, color='darkgreen', linewidth=2, linestyle=':',
                   label=f'Pigeonhole: {pigeonhole}')
    
    # Mark empirical mean
    emp_mean = np.mean(positions)
    ax.axvline(emp_mean, color='orange', linewidth=2,
               label=f'Mean: {emp_mean:.0f}')
    
    ax.set_xlabel('Position of First Repeated k-mer', fontsize=10)
    ax.set_ylabel('Density', fontsize=10)
    ax.set_title(f'k = {k}  (space = 4^{k} = {space})', fontsize=12)
    ax.legend(fontsize=8, loc='upper right')
    
    # Add statistics text
    stats_text = (f'Median: {np.median(positions):.0f}\n'
                  f'Std: {np.std(positions):.0f}\n'
                  f'Min: {min(positions)}\n'
                  f'Max: {max(positions)}')
    ax.text(0.98, 0.55, stats_text, transform=ax.transAxes,
            fontsize=8, verticalalignment='top', horizontalalignment='right',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

fig.suptitle('Birthday Paradox for DNA k-Mers\n'
             'First repeat occurs much earlier than the pigeonhole bound',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_birthday_paradox.png', dpi=150, bbox_inches='tight')
print("Saved viz_birthday_paradox.png")


#!/usr/bin/env python3
"""
Visualization: Compression Ratio — Random vs Structured DNA

Compares the k-mer diversity (and hence compressibility) of random,
repeat-rich, and low-complexity DNA sequences. Demonstrates the
conjecture that real genomes are 2-5x more 'compressed' than random
sequences due to repeat elements.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

DNA = ['A', 'C', 'G', 'T']

def generate_random_dna(length):
    return ''.join(random.choice(DNA) for _ in range(length))

def generate_repeat_rich(length, repeat_frac=0.5):
    seq = list(generate_random_dna(length))
    unit_len = 20
    template = generate_random_dna(unit_len)
    n_copies = int(length * repeat_frac / unit_len)
    for _ in range(n_copies):
        pos = random.randint(0, length - unit_len)
        for j in range(unit_len):
            if random.random() > 0.1:
                seq[pos + j] = template[j]
    return ''.join(seq)

def generate_low_complexity(length):
    units = ['AT', 'CG', 'ATAT', 'GCGC']
    unit = random.choice(units)
    return (unit * (length // len(unit) + 1))[:length]

def first_repeat_pos(seq, k):
    seen = set()
    for i in range(len(seq) - k + 1):
        kmer = seq[i:i+k]
        if kmer in seen:
            return i + k
        seen.add(kmer)
    return len(seq)

def kmer_diversity(seq, k):
    if len(seq) < k:
        return 0.0
    kmers = set()
    for i in range(len(seq) - k + 1):
        kmers.add(seq[i:i+k])
    return len(kmers) / (4 ** k)

random.seed(42)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# ---- Left panel: First repeat position distribution ----
k = 4
n_trials = 5000
seq_length = 300

types = {
    'Random': lambda: generate_random_dna(seq_length),
    'Repeat-rich (50%)': lambda: generate_repeat_rich(seq_length, 0.5),
    'Low-complexity': lambda: generate_low_complexity(seq_length),
}
colors = {'Random': 'steelblue', 'Repeat-rich (50%)': 'coral', 'Low-complexity': 'seagreen'}

means = {}
for name, gen_fn in types.items():
    positions = []
    for _ in range(n_trials):
        seq = gen_fn()
        pos = first_repeat_pos(seq, k)
        positions.append(pos)
    means[name] = np.mean(positions)
    ax1.hist(positions, bins=40, density=True, alpha=0.6,
             color=colors[name], label=f'{name} (μ={means[name]:.0f})')

ax1.axvline(4**k + k, color='black', linewidth=2, linestyle='--',
            label=f'Pigeonhole: {4**k + k}')
ax1.set_xlabel('Position of First Repeated 4-mer', fontsize=11)
ax1.set_ylabel('Density', fontsize=11)
ax1.set_title('First k-Mer Repeat: Random vs Structured DNA', fontsize=12)
ax1.legend(fontsize=9)

# Compression ratio annotation
if means['Low-complexity'] > 0:
    ratio = means['Random'] / means['Low-complexity']
    ax1.text(0.5, 0.95, f'Compression ratio\n(random/low): {ratio:.1f}x',
             transform=ax1.transAxes, fontsize=10, verticalalignment='top',
             horizontalalignment='center',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# ---- Right panel: Diversity profile ----
lengths = list(range(20, 2001, 20))
n_avg = 30

for name, gen_fn in types.items():
    diversities = []
    for n in lengths:
        gen_specific = {
            'Random': lambda n=n: generate_random_dna(n),
            'Repeat-rich (50%)': lambda n=n: generate_repeat_rich(n, 0.5),
            'Low-complexity': lambda n=n: generate_low_complexity(n),
        }[name]
        divs = [kmer_diversity(gen_specific(), k) for _ in range(n_avg)]
        diversities.append(np.mean(divs))
    ax2.plot(lengths, diversities, color=colors[name], linewidth=2, label=name)

ax2.axhline(1.0, color='gray', linewidth=1, linestyle=':', alpha=0.5)
ax2.set_xlabel('Sequence Length (bp)', fontsize=11)
ax2.set_ylabel(f'{k}-Mer Diversity Index', fontsize=11)
ax2.set_title(f'Diversity Index vs Sequence Length (k={k})', fontsize=12)
ax2.legend(fontsize=9)
ax2.set_ylim(-0.05, 1.1)

fig.suptitle('The Ramsey Theory of DNA: Pattern Repetition in Genetic Codes',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_compression_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_compression_comparison.png")


#!/usr/bin/env python3
"""
Visualization: k-Mer Diversity Heatmap

Shows how k-mer diversity index varies with sequence length (x-axis) and
k-mer size (y-axis) for random DNA sequences. The heatmap reveals the
phase transition: for each k, there is a critical length where diversity
drops below 1 (all k-mers seen) — this is the pigeonhole boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

DNA = ['A', 'C', 'G', 'T']

def generate_random_dna(length):
    return ''.join(random.choice(DNA) for _ in range(length))

def kmer_diversity(seq, k):
    if len(seq) < k:
        return 0.0
    kmers = set()
    for i in range(len(seq) - k + 1):
        kmers.add(seq[i:i+k])
    return len(kmers) / (4 ** k)

random.seed(42)

# Parameters
k_values = list(range(1, 9))
lengths = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000]

# Compute diversity matrix (averaged over trials)
n_trials = 20
diversity_matrix = np.zeros((len(k_values), len(lengths)))

for i, k in enumerate(k_values):
    for j, n in enumerate(lengths):
        divs = []
        for _ in range(n_trials):
            seq = generate_random_dna(n)
            divs.append(kmer_diversity(seq, k))
        diversity_matrix[i, j] = np.mean(divs)

# Plot
fig, ax = plt.subplots(figsize=(10, 6))
im = ax.imshow(diversity_matrix, aspect='auto', cmap='YlOrRd_r',
               vmin=0, vmax=1, origin='lower')

ax.set_xticks(range(len(lengths)))
ax.set_xticklabels(lengths)
ax.set_yticks(range(len(k_values)))
ax.set_yticklabels(k_values)

ax.set_xlabel('Sequence Length (bp)', fontsize=12)
ax.set_ylabel('k-mer Size (k)', fontsize=12)
ax.set_title('k-Mer Diversity Index: Random DNA Sequences\n'
             '(1.0 = all possible k-mers observed, 0 = none)',
             fontsize=14)

# Add text annotations
for i in range(len(k_values)):
    for j in range(len(lengths)):
        val = diversity_matrix[i, j]
        color = 'white' if val < 0.5 else 'black'
        ax.text(j, i, f'{val:.2f}', ha='center', va='center',
                color=color, fontsize=8)

# Add pigeonhole boundary line
pigeonhole_lengths = [4**k + k - 1 for k in k_values]
for i, (k, pb) in enumerate(zip(k_values, pigeonhole_lengths)):
    # Find where pb falls in the length axis
    for j in range(len(lengths) - 1):
        if lengths[j] <= pb <= lengths[j+1]:
            frac = (np.log(pb) - np.log(lengths[j])) / (np.log(lengths[j+1]) - np.log(lengths[j]))
            ax.plot(j + frac, i, 'k*', markersize=12)
            break

cbar = plt.colorbar(im, ax=ax, label='Diversity Index')
ax.text(len(lengths) - 0.5, len(k_values) - 0.5,
        '★ = Pigeonhole\n     boundary', fontsize=9,
        ha='right', va='top', style='italic')

plt.tight_layout()
plt.savefig('viz_diversity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_diversity_heatmap.png")

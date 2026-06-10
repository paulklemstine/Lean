#!/usr/bin/env python3
"""
Demo: Ramsey Theory of DNA — K-mer Avoidance in Genetic Codes
=============================================================

Numerical demonstrations of the pigeonhole principle for k-mers,
subword complexity profiles, composition bias effects, and
de Bruijn sequence construction.
"""

import random
import math
from collections import Counter
from typing import List, Tuple, Dict, Optional

# ============================================================
# Core Functions (inlined for standalone operation)
# ============================================================

BASES = ['A', 'C', 'G', 'T']


def kmer_at(seq: List[str], k: int, i: int) -> Tuple[str, ...]:
    return tuple(seq[i:i + k])


def all_kmers(seq: List[str], k: int) -> List[Tuple[str, ...]]:
    if k <= 0 or len(seq) < k:
        return []
    return [kmer_at(seq, k, i) for i in range(len(seq) - k + 1)]


def subword_complexity(seq: List[str], k: int) -> int:
    return len(set(all_kmers(seq, k)))


def is_repeat_free(seq: List[str], k: int) -> bool:
    kmers = all_kmers(seq, k)
    return len(kmers) == len(set(kmers))


def find_first_repeat(seq: List[str], k: int) -> Optional[Tuple[int, int, Tuple[str, ...]]]:
    seen: Dict[Tuple[str, ...], int] = {}
    for i in range(len(seq) - k + 1):
        kmer = kmer_at(seq, k, i)
        if kmer in seen:
            return (seen[kmer], i, kmer)
        seen[kmer] = i
    return None


def compositional_entropy(seq: List[str]) -> float:
    if not seq:
        return 0.0
    counts = Counter(seq)
    n = len(seq)
    return -sum((c / n) * math.log2(c / n) for c in counts.values() if c > 0)


def generate_de_bruijn(alpha: int, k: int) -> List[int]:
    sequence: List[int] = []
    a = [0] * (alpha * k)
    def db(t: int, p: int) -> None:
        if t > k:
            if k % p == 0:
                sequence.extend(a[1:p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for j in range(a[t - p] + 1, alpha):
                a[t] = j
                db(t + 1, t)
    db(1, 1)
    sequence.extend(sequence[:k - 1])
    return sequence


# ============================================================
# DEMO 1: Pigeonhole Principle Verification
# ============================================================

def demo_pigeonhole():
    print("=" * 70)
    print("DEMO 1: Pigeonhole Principle for DNA K-mers")
    print("=" * 70)
    print()
    
    for k in [2, 3, 4, 5]:
        threshold = 4**k + k
        max_free = 4**k + k - 1
        print(f"  k = {k}: 4^{k} = {4**k} possible {k}-mers")
        print(f"    Ramsey threshold: {threshold}")
        print(f"    Max repeat-free length: {max_free}")
        
        # Generate random sequences and find where first repeat occurs
        first_repeats = []
        for _ in range(1000):
            seq = [random.choice(BASES) for _ in range(max_free + 10)]
            result = find_first_repeat(seq, k)
            if result:
                first_repeats.append(result[1])
        
        if first_repeats:
            avg = sum(first_repeats) / len(first_repeats)
            print(f"    Average first repeat position (random): {avg:.1f}")
            print(f"    Ratio to threshold: {avg / threshold:.3f}")
        print()
    
    # Verify the theorem: sequence of length 260 always has repeated 4-mer
    print("  Verification: 10000 random DNA sequences of length 260...")
    all_have_repeat = True
    for _ in range(10000):
        seq = [random.choice(BASES) for _ in range(260)]
        if is_repeat_free(seq, 4):
            all_have_repeat = False
            break
    print(f"    All have repeated 4-mer: {all_have_repeat} ✓")
    print()


# ============================================================
# DEMO 2: De Bruijn Sequences — Optimal Repeat-Free Sequences
# ============================================================

def demo_de_bruijn():
    print("=" * 70)
    print("DEMO 2: De Bruijn Sequences — Optimal K-mer Coverage")
    print("=" * 70)
    print()
    
    for k in [2, 3, 4]:
        db_seq = generate_de_bruijn(4, k)
        dna_seq = [BASES[x] for x in db_seq]
        n = len(dna_seq)
        c = subword_complexity(dna_seq, k)
        is_free = is_repeat_free(dna_seq, k)
        
        print(f"  De Bruijn sequence (k={k}):")
        print(f"    Length: {n} (= 4^{k} + {k} - 1 = {4**k + k - 1})")
        print(f"    Distinct {k}-mers: {c} (= 4^{k} = {4**k})")
        print(f"    Is {k}-repeat-free: {is_free}")
        if n <= 30:
            print(f"    Sequence: {''.join(dna_seq)}")
        else:
            print(f"    First 30 bases: {''.join(dna_seq[:30])}...")
        print()


# ============================================================
# DEMO 3: Subword Complexity Profiles
# ============================================================

def demo_complexity_profiles():
    print("=" * 70)
    print("DEMO 3: Subword Complexity Profiles")
    print("=" * 70)
    print()
    
    n = 500
    
    # Random uniform DNA
    random_seq = [random.choice(BASES) for _ in range(n)]
    
    # AT-biased DNA (70% AT, 30% GC — like some organisms)
    biased_weights = [0.35, 0.15, 0.15, 0.35]  # A, C, G, T
    biased_seq = random.choices(BASES, weights=biased_weights, k=n)
    
    # Periodic DNA (microsatellite-like: ATATATAT...)
    periodic_seq = [BASES[i % 2 * 3] for i in range(n)]  # AT repeat
    
    sequences = {
        "Random uniform": random_seq,
        "AT-biased (70%)": biased_seq,
        "Periodic (AT)n": periodic_seq,
    }
    
    for name, seq in sequences.items():
        h = compositional_entropy(seq)
        print(f"  {name}:")
        print(f"    Entropy: {h:.3f} bits (max = {math.log2(4):.3f})")
        print(f"    Complexity profile C(k):")
        for k in [1, 2, 3, 4, 5, 6]:
            c = subword_complexity(seq, k)
            max_c = min(n - k + 1, 4**k)
            ratio = c / max_c if max_c > 0 else 0
            print(f"      C({k}) = {c:6d} / {max_c:6d} = {ratio:.3f}")
        
        # Find first repeat
        for k in [3, 4, 5, 6]:
            result = find_first_repeat(seq, k)
            if result:
                pos = result[1]
                print(f"    First {k}-mer repeat at position {pos} "
                      f"(threshold = {4**k + k})")
        print()


# ============================================================
# DEMO 4: Composition Bias Effect on Repeat Distance
# ============================================================

def demo_composition_bias():
    print("=" * 70)
    print("DEMO 4: Composition Bias and K-mer Repeat Forcing")
    print("=" * 70)
    print()
    
    k = 4
    n = 1000
    num_trials = 1000
    
    bias_levels = [
        ("Uniform (25% each)", [0.25, 0.25, 0.25, 0.25]),
        ("Mild bias (30/20/30/20)", [0.30, 0.20, 0.30, 0.20]),
        ("Strong bias (40/10/40/10)", [0.40, 0.10, 0.40, 0.10]),
        ("Extreme bias (45/5/45/5)", [0.45, 0.05, 0.45, 0.05]),
        ("Binary (50/0/50/0)", [0.50, 0.00, 0.50, 0.00]),
    ]
    
    for name, weights in bias_levels:
        # Fix zero weights
        adj_weights = [max(w, 0.001) for w in weights]
        
        first_repeats = []
        for _ in range(num_trials):
            if sum(w > 0.01 for w in weights) <= 2:
                bases_used = [b for b, w in zip(BASES, weights) if w > 0.01]
                seq = [random.choice(bases_used) for _ in range(n)]
            else:
                seq = random.choices(BASES, weights=adj_weights, k=n)
            result = find_first_repeat(seq, k)
            if result:
                first_repeats.append(result[1])
        
        if first_repeats:
            avg = sum(first_repeats) / len(first_repeats)
            eff_alpha = len([w for w in weights if w > 0.01])
            theory_threshold = eff_alpha ** k + k
            print(f"  {name}:")
            print(f"    Effective alphabet: {eff_alpha}")
            print(f"    Theoretical threshold: {theory_threshold}")
            print(f"    Avg first repeat: {avg:.1f}")
            print(f"    Compression ratio: {avg / (4**k + k):.3f}")
    print()


# ============================================================
# DEMO 5: Ramsey Threshold Table
# ============================================================

def demo_threshold_table():
    print("=" * 70)
    print("DEMO 5: Ramsey Thresholds for Various Alphabets and K-mer Lengths")
    print("=" * 70)
    print()
    
    alphas = [2, 3, 4, 5, 10, 20]
    ks = [1, 2, 3, 4, 5, 6, 8, 10]
    
    header = 'a\\k'
    print(f"  {header:>6}", end="")
    for k in ks:
        print(f"  {k:>10}", end="")
    print()
    print("  " + "-" * (6 + 12 * len(ks)))
    
    for alpha in alphas:
        print(f"  {alpha:>6}", end="")
        for k in ks:
            threshold = alpha ** k + k
            if threshold > 10**9:
                print(f"  {'> 10^9':>10}", end="")
            else:
                print(f"  {threshold:>10}", end="")
        print()
    
    print()
    print("  Table shows α^k + k: minimum sequence length guaranteeing")
    print("  a repeated k-mer over alphabet of size α.")
    print()


# ============================================================
# RUN ALL DEMOS
# ============================================================

if __name__ == "__main__":
    random.seed(42)
    
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  RAMSEY THEORY OF DNA: K-MER AVOIDANCE IN GENETIC CODES           ║")
    print("║  Numerical Demonstrations                                          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_pigeonhole()
    demo_de_bruijn()
    demo_complexity_profiles()
    demo_composition_bias()
    demo_threshold_table()
    
    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Subword Complexity Profiles for DNA Sequences

Compares complexity profiles C(k) for random, biased, and periodic
DNA sequences against theoretical bounds.
"""

import random
import math
from collections import Counter
from typing import List, Tuple

# Try matplotlib, fall back gracefully
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; generating text output instead.")


BASES = ['A', 'C', 'G', 'T']


def kmer_at(seq: List[str], k: int, i: int) -> Tuple[str, ...]:
    return tuple(seq[i:i + k])


def subword_complexity(seq: List[str], k: int) -> int:
    if k <= 0 or len(seq) < k:
        return 0
    kmers = set()
    for i in range(len(seq) - k + 1):
        kmers.add(kmer_at(seq, k, i))
    return len(kmers)


def compositional_entropy(seq: List[str]) -> float:
    if not seq:
        return 0.0
    counts = Counter(seq)
    n = len(seq)
    return -sum((c / n) * math.log2(c / n) for c in counts.values() if c > 0)


def main():
    random.seed(42)
    n = 2000
    max_k = 10
    
    # Generate sequences
    random_seq = [random.choice(BASES) for _ in range(n)]
    biased_seq = random.choices(BASES, weights=[0.4, 0.1, 0.1, 0.4], k=n)
    periodic_seq = ['A' if i % 4 < 2 else ('C' if i % 4 == 2 else 'G')
                    for i in range(n)]
    
    sequences = {
        "Random uniform (H=2.0)": random_seq,
        "AT-biased 80% (H≈1.5)": biased_seq,
        "Periodic ACG (H=1.58)": periodic_seq,
    }
    
    ks = list(range(1, max_k + 1))
    
    # Compute profiles
    profiles = {}
    for name, seq in sequences.items():
        h = compositional_entropy(seq)
        profiles[name] = [subword_complexity(seq, k) for k in ks]
    
    # Theoretical bound
    theory_bound = [min(n - k + 1, 4**k) for k in ks]
    
    if HAS_MPL:
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
        
        # Plot 1: Absolute complexity
        colors = ['#2196F3', '#FF5722', '#4CAF50']
        for (name, profile), color in zip(profiles.items(), colors):
            ax1.plot(ks, profile, 'o-', label=name, color=color, linewidth=2)
        ax1.plot(ks, theory_bound, 'k--', label='Theoretical max (4^k)',
                 linewidth=1.5, alpha=0.5)
        ax1.set_xlabel('k-mer length k', fontsize=12)
        ax1.set_ylabel('Distinct k-mers C(k)', fontsize=12)
        ax1.set_title('Subword Complexity Profiles', fontsize=14)
        ax1.set_yscale('log')
        ax1.legend(fontsize=9)
        ax1.grid(True, alpha=0.3)
        
        # Plot 2: Normalized complexity (C(k) / 4^k)
        for (name, profile), color in zip(profiles.items(), colors):
            normalized = [c / (4**k) for c, k in zip(profile, ks)]
            ax2.plot(ks, normalized, 'o-', label=name, color=color, linewidth=2)
        ax2.axhline(y=1.0, color='k', linestyle='--', alpha=0.3,
                     label='Maximum (de Bruijn)')
        ax2.set_xlabel('k-mer length k', fontsize=12)
        ax2.set_ylabel('C(k) / 4^k (normalized)', fontsize=12)
        ax2.set_title('Normalized Complexity (Saturation)', fontsize=14)
        ax2.legend(fontsize=9)
        ax2.grid(True, alpha=0.3)
        ax2.set_ylim(0, 1.1)
        
        plt.tight_layout()
        plt.savefig('complexity_profiles.png', dpi=150, bbox_inches='tight')
        print("Saved complexity_profiles.png")
    else:
        print("\nSubword Complexity Profiles:")
        print(f"{'k':>4} {'Theory':>10}", end="")
        for name in profiles:
            print(f" {name[:15]:>16}", end="")
        print()
        for i, k in enumerate(ks):
            print(f"{k:>4} {theory_bound[i]:>10}", end="")
            for profile in profiles.values():
                print(f" {profile[i]:>16}", end="")
            print()


if __name__ == "__main__":
    main()

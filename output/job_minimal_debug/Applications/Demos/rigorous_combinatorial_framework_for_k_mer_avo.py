#!/usr/bin/env python3
"""
K-Mer Avoidance Framework: Demonstrations

Numerical examples illustrating the Ramsey threshold, subword complexity,
bias detection, and de Bruijn sequence construction.
"""

from algorithms import (
    extract_kmer, all_kmers, subword_complexity, is_kmer_repeat_free,
    ramsey_threshold, composition_bias, detect_bias, kmer_frequency_profile,
    subword_complexity_profile, find_repeated_kmer, generate_de_bruijn,
)


def demo_ramsey_threshold():
    """Demonstrate the Ramsey threshold for k-mer repetition."""
    print("=" * 60)
    print("DEMO 1: Ramsey Threshold for K-Mer Repetition")
    print("=" * 60)

    for alpha in [2, 4, 26]:
        name = {2: "binary", 4: "DNA", 26: "English"}[alpha]
        print(f"\nAlphabet: {name} (size {alpha})")
        for k in [1, 2, 3, 5]:
            threshold = ramsey_threshold(alpha, k)
            print(f"  k={k}: threshold = {alpha}^{k} + {k} = {threshold}")

    print("\n--- Verification with DNA (alpha=4, k=2) ---")
    threshold = ramsey_threshold(4, 2)
    print(f"Threshold: {threshold} (= 4^2 + 2 = 18)")

    # Sequence of length 17 = threshold - 1: can be repeat-free
    db = generate_de_bruijn(4, 2)
    print(f"De Bruijn sequence (length {len(db)}): {db}")
    print(f"  Repeat-free? {is_kmer_repeat_free(db, 2)}")
    print(f"  Distinct 2-mers: {subword_complexity(db, 2)} (max possible: {4**2})")

    # Extend by one symbol: must have repeat
    extended = db + [0]
    result = find_repeated_kmer(extended, 2)
    print(f"\nExtended (length {len(extended)}): ...{extended[-5:]}")
    if result:
        i, j, km = result
        print(f"  Repeated 2-mer found: positions {i} and {j}, k-mer = {km}")


def demo_subword_complexity():
    """Demonstrate subword complexity for various sequences."""
    print("\n" + "=" * 60)
    print("DEMO 2: Subword Complexity")
    print("=" * 60)

    sequences = {
        "Constant (AAAA...)": [0] * 20,
        "Alternating (ABAB...)": [i % 2 for i in range(20)],
        "Periodic (ABCABC...)": [i % 3 for i in range(20)],
        "Random-like": [0, 1, 3, 2, 0, 3, 1, 2, 3, 0, 1, 2, 0, 3, 2, 1, 0, 2, 3, 1],
    }

    for name, seq in sequences.items():
        print(f"\n{name}: {seq[:10]}...")
        profile = subword_complexity_profile(seq, min(6, len(seq)))
        for k, sc in enumerate(profile, 1):
            max_sc = min(len(seq) - k + 1, 4 ** k)
            print(f"  SC(k={k}) = {sc:4d}  (max = {max_sc})")


def demo_bias_detection():
    """Demonstrate bias detection using k-mer analysis."""
    print("\n" + "=" * 60)
    print("DEMO 3: Composition Bias Detection")
    print("=" * 60)

    import random
    random.seed(42)

    # Unbiased: uniform over {0,1,2,3}
    unbiased = [random.randint(0, 3) for _ in range(100)]

    # Biased: only uses {0,1}
    biased = [random.randint(0, 1) for _ in range(100)]

    # Severely biased: 90% symbol 0
    severe = [0 if random.random() < 0.9 else random.randint(1, 3)
              for _ in range(100)]

    for name, seq, alpha in [("Unbiased", unbiased, 4),
                              ("Biased (2/4 symbols)", biased, 4),
                              ("Severe bias (90% one symbol)", severe, 4)]:
        print(f"\n{name}:")
        for k in [2, 3, 4]:
            result = detect_bias(seq, k, alpha)
            print(f"  k={k}: SC={result['subword_complexity']:4d}, "
                  f"max={result['max_possible']:4d}, "
                  f"symbols={result['symbols_used']}, "
                  f"ratio={result['bias_ratio']:.3f}, "
                  f"biased={result['is_biased']}")


def demo_de_bruijn():
    """Demonstrate de Bruijn sequence construction and verification."""
    print("\n" + "=" * 60)
    print("DEMO 4: De Bruijn Sequences")
    print("=" * 60)

    for alpha in [2, 3, 4]:
        for k in [1, 2, 3]:
            db = generate_de_bruijn(alpha, k)
            expected_len = alpha ** k + k - 1
            sc = subword_complexity(db, k)
            repeat_free = is_kmer_repeat_free(db, k)
            print(f"  alpha={alpha}, k={k}: len={len(db):5d} "
                  f"(expected {expected_len:5d}), "
                  f"SC={sc:4d} (expected {alpha**k:4d}), "
                  f"repeat-free={repeat_free}")


def demo_overlap():
    """Demonstrate the k-mer overlap property."""
    print("\n" + "=" * 60)
    print("DEMO 5: K-Mer Overlap Property")
    print("=" * 60)

    seq = [0, 1, 2, 3, 0, 1, 2]
    k = 3
    print(f"Sequence: {seq}")
    print(f"Window size: k={k}")
    print()

    kmers = all_kmers(seq, k)
    for i, km in enumerate(kmers):
        print(f"  Position {i}: k-mer = {km}")

    print("\nOverlap verification:")
    for i in range(len(kmers) - 1):
        suffix = kmers[i][1:]
        prefix = kmers[i + 1][:-1]
        print(f"  k-mer[{i}] suffix = {suffix}, k-mer[{i+1}] prefix = {prefix}, "
              f"match = {suffix == prefix}")


def demo_dna_thresholds():
    """Compute DNA-specific thresholds for bioinformatics-relevant k values."""
    print("\n" + "=" * 60)
    print("DEMO 6: DNA K-Mer Thresholds")
    print("=" * 60)

    print(f"\n{'k':>4} {'4^k':>15} {'threshold':>15} {'note':>30}")
    print("-" * 70)
    for k in range(1, 17):
        t = ramsey_threshold(4, k)
        note = ""
        if t < 3_200_000_000:
            note = "< human genome (3.2B bp)"
        else:
            note = "> human genome (3.2B bp)"
        print(f"{k:4d} {4**k:15,d} {t:15,d}  {note}")


if __name__ == "__main__":
    demo_ramsey_threshold()
    demo_subword_complexity()
    demo_bias_detection()
    demo_de_bruijn()
    demo_overlap()
    demo_dna_thresholds()


#!/usr/bin/env python3
"""
Visualization: Subword Complexity Profiles

Plots the subword complexity SC(k) for various sequence types,
illustrating the exponential gap between biased and unbiased sequences.
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def extract_kmer(seq, k, i):
    return tuple(seq[i:i + k])

def subword_complexity(seq, k):
    n = len(seq)
    if k > n or k <= 0:
        return 0
    return len(set(extract_kmer(seq, k, i) for i in range(n - k + 1)))

def main():
    random.seed(42)
    n = 200
    max_k = 8

    # Generate sequences
    unbiased = [random.randint(0, 3) for _ in range(n)]
    biased_2 = [random.randint(0, 1) for _ in range(n)]
    biased_3 = [random.randint(0, 2) for _ in range(n)]
    constant = [0] * n
    periodic = [i % 4 for i in range(n)]

    ks = list(range(1, max_k + 1))
    max_vals = [4 ** k for k in ks]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Subword complexity profiles
    for name, seq, color, marker in [
        ("Maximum (4^k)", None, '#333333', 's'),
        ("Random (4 symbols)", unbiased, '#2196F3', 'o'),
        ("Random (3 symbols)", biased_3, '#FF9800', '^'),
        ("Random (2 symbols)", biased_2, '#F44336', 'D'),
        ("Periodic (period 4)", periodic, '#4CAF50', 'v'),
        ("Constant", constant, '#9C27B0', 'x'),
    ]:
        if seq is None:
            vals = max_vals
        else:
            vals = [subword_complexity(seq, k) for k in ks]
        ax1.semilogy(ks, vals, marker=marker, label=name, color=color,
                     linewidth=2, markersize=8)

    ax1.set_xlabel('Window size k', fontsize=13)
    ax1.set_ylabel('Subword complexity SC(k)', fontsize=13)
    ax1.set_title('Subword Complexity: Bias Creates Exponential Gaps', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xticks(ks)

    # Plot 2: Bias ratio (SC / max)
    for name, seq, color in [
        ("Random (4 symbols)", unbiased, '#2196F3'),
        ("Random (3 symbols)", biased_3, '#FF9800'),
        ("Random (2 symbols)", biased_2, '#F44336'),
        ("Periodic (period 4)", periodic, '#4CAF50'),
    ]:
        vals = [subword_complexity(seq, k) for k in ks]
        ratios = [v / m for v, m in zip(vals, max_vals)]
        ax2.plot(ks, ratios, marker='o', label=name, color=color,
                 linewidth=2, markersize=8)

    ax2.set_xlabel('Window size k', fontsize=13)
    ax2.set_ylabel('Bias ratio SC(k) / 4^k', fontsize=13)
    ax2.set_title('Bias Detection: Ratio Drops Exponentially', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_xticks(ks)
    ax2.set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('viz_complexity.png', dpi=150, bbox_inches='tight')
    print("Saved viz_complexity.png")

if __name__ == "__main__":
    main()

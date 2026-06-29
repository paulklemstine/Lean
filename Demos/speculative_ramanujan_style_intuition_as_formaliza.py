#!/usr/bin/env python3
"""
Ramanujan Oracle Non-Computability: Numerical Demonstrations

This script demonstrates the key quantitative results from the Ramanujan Oracle
theory, showing how the oracle space (3^N) exponentially exceeds the program
space (b^k) for various parameters.
"""

import math


def oracle_space(N: int) -> int:
    """Number of possible oracles on N statements: 3^N."""
    return 3 ** N


def program_space(b: int, k: int) -> int:
    """Number of possible programs of length k over alphabet b: b^k."""
    return b ** k


def information_content_oracle(N: int) -> float:
    """Information content of an oracle on N statements in bits: N * log2(3)."""
    return N * math.log2(3)


def information_content_program(b: int, k: int) -> float:
    """Information content of a program of length k over alphabet b in bits."""
    return k * math.log2(b)


def min_program_length(b: int, N: int) -> int:
    """Minimum program length k such that b^k >= 3^N."""
    if b <= 1:
        return float('inf')
    return math.ceil(N * math.log(3) / math.log(b))


def gap_ratio(b: int, k: int, N: int) -> float:
    """Ratio of oracle space to program space: 3^N / b^k."""
    return (3 ** N) / (b ** k)


def threshold_N(b: int, k: int) -> int:
    """Minimum N such that 3^N > b^k."""
    if b <= 0 or k <= 0:
        return 1
    return math.ceil(k * math.log(b) / math.log(3))


def main():
    print("=" * 70)
    print("RAMANUJAN ORACLE NON-COMPUTABILITY: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Oracle space vs program space
    print("\n--- Demo 1: Oracle Space vs Program Space ---")
    print(f"{'N':>4} {'3^N (oracles)':>20} {'2^N (binary progs)':>20} {'Gap ratio':>12}")
    print("-" * 60)
    for N in [1, 5, 10, 20, 50, 100]:
        oracles = oracle_space(N)
        programs = program_space(2, N)
        ratio = oracles / programs
        print(f"{N:>4} {oracles:>20,} {programs:>20,} {ratio:>12.2f}")

    # Demo 2: Minimum program length
    print("\n--- Demo 2: Minimum Program Length for Full Oracle Coverage ---")
    print(f"{'N':>4} {'Min k (b=2)':>12} {'Min k (b=10)':>12} {'Min k (b=256)':>14}")
    print("-" * 50)
    for N in [1, 5, 10, 20, 50, 100, 1000]:
        k2 = min_program_length(2, N)
        k10 = min_program_length(10, N)
        k256 = min_program_length(256, N)
        print(f"{N:>4} {k2:>12} {k10:>12} {k256:>14}")

    # Demo 3: Information deficit
    print("\n--- Demo 3: Information Deficit (bits) ---")
    print(f"{'N':>4} {'Oracle info':>14} {'Program info':>14} {'Deficit':>10} {'Deficit %':>10}")
    print("-" * 56)
    for N in [1, 10, 100, 1000]:
        oracle_info = information_content_oracle(N)
        prog_info = information_content_program(2, N)
        deficit = oracle_info - prog_info
        pct = (deficit / oracle_info) * 100
        print(f"{N:>4} {oracle_info:>14.2f} {prog_info:>14.2f} {deficit:>10.2f} {pct:>9.1f}%")

    # Demo 4: Threshold values
    print("\n--- Demo 4: Threshold N for 3^N > b^k ---")
    print(f"{'b':>4} {'k':>6} {'Threshold N':>12} {'3^N':>20} {'b^k':>20}")
    print("-" * 66)
    for b, k in [(2, 10), (2, 100), (10, 10), (10, 100), (256, 10), (256, 100)]:
        N = threshold_N(b, k)
        print(f"{b:>4} {k:>6} {N:>12} {3**N:>20,} {b**k:>20,}")

    # Demo 5: The Ramanujan Oracle Theorem in action
    print("\n--- Demo 5: Ramanujan Oracle Theorem ---")
    print("For each (b, k), showing the N where programs fail to cover all oracles:")
    print(f"{'b':>4} {'k':>6} {'b^k (programs)':>20} {'N chosen':>10} {'3^N (oracles)':>20}")
    print("-" * 66)
    for b in [2, 3, 10, 256]:
        for k in [1, 5, 10]:
            N = threshold_N(b, k) + 1
            print(f"{b:>4} {k:>6} {b**k:>20,} {N:>10} {3**N:>20,}")

    # Demo 6: Cantor's diagonal in action
    print("\n--- Demo 6: Cantor Diagonal Construction (first 10 entries) ---")
    print("Given enumeration f(n)(m) = (n + m) mod 3:")
    print("Diagonal: f(n)(n) = 2n mod 3")
    print("Anti-diagonal g(n) = 1 if f(n)(n) = 0, else 0")
    print()
    print(f"{'n':>4} {'f(n)(n)':>8} {'g(n)':>6}")
    for n in range(10):
        fnn = (2 * n) % 3
        gn = 1 if fnn == 0 else 0
        print(f"{n:>4} {fnn:>8} {gn:>6}")
    print("\ng differs from f(n) at position n for every n → g ∉ range(f)")

    print("\n" + "=" * 70)
    print("All demonstrations complete. Key result: for any finite program")
    print("length k, the oracle space 3^N exceeds the program space b^k")
    print("for sufficiently large N, proving non-computability of oracles.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Accuracy Distribution of Random Oracles

Shows how oracle accuracy is distributed across all possible oracles,
demonstrating that perfectly accurate oracles are exponentially rare.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math
from itertools import product


def accuracy_distribution(N: int) -> dict:
    """Compute accuracy distribution for all 3^N oracles relative to truth = (0,0,...,0)."""
    truth = (0,) * N
    dist = {i: 0 for i in range(N + 1)}
    for oracle in product(range(3), repeat=N):
        acc = sum(1 for o, t in zip(oracle, truth) if o == t)
        dist[acc] += 1
    return dist


def binomial_coeff(n: int, k: int) -> int:
    """Compute C(n, k)."""
    if k < 0 or k > n:
        return 0
    return math.comb(n, k)


def theoretical_distribution(N: int) -> dict:
    """
    Theoretical accuracy distribution.
    P(accuracy = a) = C(N, a) * 2^(N-a) / 3^N
    (a positions agree, N-a positions each have 2 wrong choices)
    """
    dist = {}
    total = 3 ** N
    for a in range(N + 1):
        count = binomial_coeff(N, a) * (2 ** (N - a))
        dist[a] = count
    return dist


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Oracle Accuracy Distribution', fontsize=14, fontweight='bold')

    # Plot 1: Empirical distribution for small N
    ax = axes[0]
    for N in [3, 4, 5, 6]:
        dist = accuracy_distribution(N)
        total = 3 ** N
        accs = sorted(dist.keys())
        probs = [dist[a] / total for a in accs]
        ax.plot(accs, probs, 'o-', label=f'N={N}', markersize=4)
    ax.set_xlabel('Accuracy (# correct)')
    ax.set_ylabel('Fraction of oracles')
    ax.set_title('Accuracy Distribution (empirical)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Theoretical distribution for larger N
    ax = axes[1]
    for N in [10, 20, 50]:
        dist = theoretical_distribution(N)
        total = 3 ** N
        accs = sorted(dist.keys())
        probs = [dist[a] / total for a in accs]
        # Normalize x-axis to fraction
        fracs = [a / N for a in accs]
        ax.plot(fracs, probs, '-', label=f'N={N}', linewidth=1.5)
    ax.axvline(x=1/3, color='red', linestyle='--', alpha=0.7, label='Random guess (1/3)')
    ax.axvline(x=0.95, color='green', linestyle='--', alpha=0.7, label='95% threshold')
    ax.set_xlabel('Accuracy fraction')
    ax.set_ylabel('Fraction of oracles')
    ax.set_title('Accuracy Distribution (theoretical)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Plot 3: Cumulative — fraction of oracles above accuracy threshold
    ax = axes[2]
    for N in [10, 20, 50]:
        dist = theoretical_distribution(N)
        total = 3 ** N
        thresholds = np.linspace(0, 1, 100)
        cum_fracs = []
        for t in thresholds:
            min_acc = int(math.ceil(t * N))
            above = sum(dist.get(a, 0) for a in range(min_acc, N + 1))
            cum_fracs.append(above / total)
        ax.semilogy(thresholds, [max(f, 1e-20) for f in cum_fracs], '-',
                    label=f'N={N}', linewidth=1.5)
    ax.axvline(x=0.95, color='green', linestyle='--', alpha=0.7, label='95% threshold')
    ax.set_xlabel('Accuracy threshold')
    ax.set_ylabel('Fraction of oracles above threshold (log)')
    ax.set_title('Cumulative Accuracy Distribution')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('accuracy_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved: accuracy_distribution.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Oracle Space vs Program Space Gap

Shows how 3^N (oracle space) exponentially dominates b^k (program space)
as N grows, for various values of b and k.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Ramanujan Oracle Non-Computability: Quantitative Analysis',
                 fontsize=14, fontweight='bold')

    # Plot 1: Oracle space vs program space (log scale)
    ax = axes[0, 0]
    N_vals = np.arange(1, 31)
    oracle_sizes = [3**N for N in N_vals]
    for b in [2, 4, 10]:
        prog_sizes = [b**N for N in N_vals]
        ax.semilogy(N_vals, prog_sizes, '--', label=f'{b}^N (programs, b={b})')
    ax.semilogy(N_vals, oracle_sizes, 'r-', linewidth=2, label='3^N (oracles)')
    ax.set_xlabel('N (number of statements)')
    ax.set_ylabel('Space size (log scale)')
    ax.set_title('Oracle Space vs Program Space')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Plot 2: Gap ratio (3/2)^N
    ax = axes[0, 1]
    N_vals = np.arange(1, 51)
    ratio = [(3/2)**N for N in N_vals]
    ax.semilogy(N_vals, ratio, 'b-', linewidth=2)
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Parity (ratio=1)')
    ax.set_xlabel('N')
    ax.set_ylabel('Gap ratio 3^N / 2^N')
    ax.set_title('Exponential Gap Growth (binary programs)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Minimum program length
    ax = axes[1, 0]
    N_vals = np.arange(1, 101)
    for b in [2, 10, 256]:
        min_k = [math.ceil(N * math.log(3) / math.log(b)) for N in N_vals]
        ax.plot(N_vals, min_k, label=f'b={b}')
    ax.plot(N_vals, N_vals, 'k--', alpha=0.5, label='k=N (identity)')
    ax.set_xlabel('N (statements)')
    ax.set_ylabel('Min program length k')
    ax.set_title('Minimum Program Length for Oracle Coverage')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Information deficit
    ax = axes[1, 1]
    N_vals = np.arange(1, 101)
    oracle_info = [N * math.log2(3) for N in N_vals]
    binary_info = [N * 1.0 for N in N_vals]
    deficit = [N * (math.log2(3) - 1) for N in N_vals]
    ax.fill_between(N_vals, binary_info, oracle_info, alpha=0.3, color='red',
                    label='Information deficit')
    ax.plot(N_vals, oracle_info, 'r-', linewidth=2, label='Oracle info (N·log₂3)')
    ax.plot(N_vals, binary_info, 'b-', linewidth=2, label='Program info (N bits)')
    ax.set_xlabel('N (statements)')
    ax.set_ylabel('Information (bits)')
    ax.set_title('Information Deficit: Oracle vs Binary Program')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('oracle_gap_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: oracle_gap_analysis.png")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Visualization: Thue-Morse sequence structure and DFAO state space.

Generates three plots:
1. Thue-Morse sequence as a 2D grid (showing fractal structure)
2. k-kernel growth comparison (automatic vs non-automatic)
3. DFAO state transition diagram
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def bit_sum(n: int) -> int:
    count = 0
    while n > 0:
        count += n & 1
        n >>= 1
    return count


def thue_morse(n: int) -> int:
    return bit_sum(n) % 2


def plot_thue_morse_grid():
    """Plot Thue-Morse as a 2D grid showing fractal self-similarity."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Grid visualization
    N = 64
    grid = np.array([[thue_morse(i * N + j) for j in range(N)] for i in range(N)])
    axes[0].imshow(grid, cmap='binary', interpolation='nearest', aspect='equal')
    axes[0].set_title('Thue-Morse: t(n) for n = 0..4095\n(row-major, 64×64 grid)', fontsize=11)
    axes[0].set_xlabel('Column (n mod 64)')
    axes[0].set_ylabel('Row (n ÷ 64)')

    # Plot 2: Self-similarity demonstration
    n_vals = np.arange(128)
    tm = [thue_morse(n) for n in n_vals]
    even_idx = [thue_morse(2 * n) for n in range(64)]
    odd_idx = [thue_morse(2 * n + 1) for n in range(64)]

    axes[1].step(range(128), tm, where='mid', color='black', linewidth=0.5, label='t(n)')
    axes[1].step(range(64), even_idx, where='mid', color='blue', linewidth=1.5,
                 alpha=0.7, label='t(2n) = t(n)')
    axes[1].step(range(64), odd_idx, where='mid', color='red', linewidth=1.5,
                 alpha=0.7, linestyle='--', label='t(2n+1) ≠ t(n)')
    axes[1].set_title('Self-Similarity and Complementation', fontsize=11)
    axes[1].set_xlabel('Index')
    axes[1].set_ylabel('Value')
    axes[1].legend(fontsize=9)
    axes[1].set_ylim(-0.2, 1.2)

    # Plot 3: k-kernel size vs exponent
    def compute_kernel_size(k, seq_fn, max_e):
        """Compute number of distinct kernel elements."""
        seen = set()
        test_len = 30
        for e in range(max_e + 1):
            ke = k ** e
            for r in range(ke):
                fp = tuple(seq_fn(ke * n + r) for n in range(test_len))
                seen.add(fp)
        return len(seen)

    # Thue-Morse: 2-automatic, kernel size = 2
    exponents = range(1, 8)
    tm_kernel = [compute_kernel_size(2, thue_morse, e) for e in exponents]

    # A non-automatic sequence for comparison: n mod 3
    def mod3_seq(n):
        return n % 3
    mod3_kernel = [compute_kernel_size(2, mod3_seq, e) for e in exponents]

    axes[2].plot(list(exponents), tm_kernel, 'bo-', linewidth=2, markersize=6,
                 label='Thue-Morse (2-automatic)')
    axes[2].plot(list(exponents), mod3_kernel, 'rs--', linewidth=2, markersize=6,
                 label='n mod 3 (not 2-automatic)')
    axes[2].set_title('2-Kernel Size vs Max Exponent', fontsize=11)
    axes[2].set_xlabel('Maximum exponent e')
    axes[2].set_ylabel('Number of distinct kernel elements')
    axes[2].legend(fontsize=9)
    axes[2].set_yscale('log')

    plt.tight_layout()
    plt.savefig('thue_morse_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: thue_morse_analysis.png")


def plot_dfao_decidability():
    """Plot demonstrating the decidability algorithm."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Reachable states and outputs
    import random
    random.seed(42)

    n_states_list = range(2, 12)
    reachable_counts = []
    output_range_sizes = []

    for n_states in n_states_list:
        total_reachable = 0
        total_range = 0
        trials = 50
        for _ in range(trials):
            transition = [[random.randint(0, n_states - 1) for _ in range(2)]
                          for _ in range(n_states)]
            output = [random.randint(0, 3) for _ in range(n_states)]

            # BFS for reachable states
            visited = set()
            queue = [0]
            while queue:
                s = queue.pop(0)
                if s in visited:
                    continue
                visited.add(s)
                for d in range(2):
                    ns = transition[s][d]
                    if ns not in visited:
                        queue.append(ns)

            total_reachable += len(visited)
            total_range += len({output[s] for s in visited})

        reachable_counts.append(total_reachable / trials)
        output_range_sizes.append(total_range / trials)

    axes[0].plot(list(n_states_list), reachable_counts, 'bo-', label='Avg reachable states')
    axes[0].plot(list(n_states_list), list(n_states_list), 'k--', alpha=0.5, label='Total states')
    axes[0].plot(list(n_states_list), output_range_sizes, 'rs-', label='Avg output range size')
    axes[0].set_xlabel('Number of DFAO states')
    axes[0].set_ylabel('Count')
    axes[0].set_title('DFAO Reachability (base 2, avg over 50 trials)', fontsize=11)
    axes[0].legend()

    # Plot 2: Decision time vs number of states
    import time

    state_sizes = [2, 5, 10, 20, 50, 100, 200, 500]
    times = []

    for n_states in state_sizes:
        transition = [[random.randint(0, n_states - 1) for _ in range(2)]
                      for _ in range(n_states)]
        output = [random.randint(0, 3) for _ in range(n_states)]

        start = time.perf_counter()
        for _ in range(100):
            visited = set()
            queue = [0]
            while queue:
                s = queue.pop(0)
                if s in visited:
                    continue
                visited.add(s)
                for d in range(2):
                    ns = transition[s][d]
                    if ns not in visited:
                        queue.append(ns)
            _ = any(output[s] == 0 for s in visited)
        elapsed = (time.perf_counter() - start) / 100

        times.append(elapsed)

    axes[1].loglog(state_sizes, times, 'go-', linewidth=2, markersize=8)
    axes[1].set_xlabel('Number of DFAO states')
    axes[1].set_ylabel('Decision time (seconds)')
    axes[1].set_title('Decidability Algorithm Performance', fontsize=11)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('dfao_decidability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dfao_decidability.png")


if __name__ == "__main__":
    plot_thue_morse_grid()
    plot_dfao_decidability()
    print("All visualizations generated.")

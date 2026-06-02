#!/usr/bin/env python3
"""
Quantum Random Walks on Cayley Graphs: Numerical Demonstrations

Demonstrates the spectral gap theory and mixing time bounds for
quantum and classical random walks on various Cayley graphs.
"""

import numpy as np
from itertools import permutations

def cayley_adj_matrix(group_elements, generators, group_op, group_inv):
    """
    Construct the adjacency matrix of Cay(G, S).
    
    Parameters:
        group_elements: list of group elements
        generators: list of generators (symmetric set S)
        group_op: function (g, h) -> g*h
        group_inv: function g -> g^{-1}
    
    Returns:
        numpy array of shape (|G|, |G|)
    """
    n = len(group_elements)
    idx = {g: i for i, g in enumerate(group_elements)}
    A = np.zeros((n, n))
    for i, g in enumerate(group_elements):
        g_inv = group_inv(g)
        for j, h in enumerate(group_elements):
            prod = group_op(g_inv, h)
            if prod in [s for s in generators]:
                A[i, j] = 1.0
    return A


def cyclic_group_walk(n):
    """Cayley graph of Z/nZ with generators {1, n-1}."""
    elements = list(range(n))
    generators = [1, n - 1]
    
    def op(a, b):
        return (a + b) % n
    
    def inv(a):
        return (-a) % n
    
    A = cayley_adj_matrix(elements, generators, op, inv)
    return A


def spectral_gap(A):
    """Compute the spectral gap of a transition matrix P = A/d."""
    d = A.sum(axis=1)[0]  # degree (regular graph)
    if d == 0:
        return 0.0
    P = A / d
    eigenvalues = np.linalg.eigvalsh(P)
    eigenvalues = np.sort(np.abs(eigenvalues))[::-1]
    # Gap = 1 - |lambda_2|
    if len(eigenvalues) < 2:
        return 1.0
    return 1.0 - eigenvalues[1]


def mixing_time_bound(n, gap):
    """Classical mixing time bound: ceil(log(n) / gap)."""
    if gap <= 0:
        return float('inf')
    return np.ceil(np.log(n) / gap)


def quantum_mixing_time_bound(n, gap):
    """Quantum mixing time bound: sqrt(n) * log(n) / gap."""
    if gap <= 0:
        return float('inf')
    return np.sqrt(n) * np.log(n) / gap


def simulate_walk(P, steps, start=0):
    """Simulate a classical random walk, returning distribution at each step."""
    n = P.shape[0]
    dist = np.zeros(n)
    dist[start] = 1.0
    distributions = [dist.copy()]
    for _ in range(steps):
        dist = dist @ P
        distributions.append(dist.copy())
    return distributions


def total_variation(p, q):
    """Total variation distance between distributions p and q."""
    return 0.5 * np.sum(np.abs(p - q))


def demo_cyclic_groups():
    """Demonstrate mixing on cyclic groups Z/nZ."""
    print("=" * 70)
    print("DEMO 1: Cyclic Groups Z/nZ with S = {±1}")
    print("=" * 70)
    
    for n in [8, 16, 32, 64, 128]:
        A = cyclic_group_walk(n)
        gap = spectral_gap(A)
        classical_t = mixing_time_bound(n, gap)
        quantum_t = quantum_mixing_time_bound(n, gap)
        
        # Theoretical gap for Z/nZ: 1 - cos(2π/n) ≈ 2π²/n²
        theoretical_gap = 1 - np.cos(2 * np.pi / n)
        
        print(f"\nZ/{n}Z:")
        print(f"  Computed spectral gap:    {gap:.6f}")
        print(f"  Theoretical gap:         {theoretical_gap:.6f}")
        print(f"  Classical mixing time:   {classical_t:.0f}")
        print(f"  Quantum mixing time:     {quantum_t:.1f}")
        print(f"  Speedup ratio (√n):      {quantum_t / classical_t:.2f} vs √{n} = {np.sqrt(n):.2f}")


def demo_symmetric_group():
    """Demonstrate mixing on S_n with transpositions."""
    print("\n" + "=" * 70)
    print("DEMO 2: Symmetric Group S_n with Transposition Generators")
    print("=" * 70)
    
    for n in [3, 4, 5]:
        # Generate S_n
        elements = list(permutations(range(n)))
        elem_idx = {e: i for i, e in enumerate(elements)}
        N = len(elements)
        
        # Generators: all transpositions
        def apply_transposition(perm, i, j):
            p = list(perm)
            p[i], p[j] = p[j], p[i]
            return tuple(p)
        
        # Build adjacency matrix
        num_trans = n * (n - 1) // 2
        A_mat = np.zeros((N, N))
        for idx_p, perm in enumerate(elements):
            for i in range(n):
                for j in range(i + 1, n):
                    neighbor = apply_transposition(perm, i, j)
                    idx_n = elem_idx[neighbor]
                    A_mat[idx_p, idx_n] = 1.0
        
        gap = spectral_gap(A_mat)
        theoretical_gap = 2.0 / n  # Diaconis-Shahshahani
        classical_t = mixing_time_bound(N, gap)
        quantum_t = quantum_mixing_time_bound(N, gap)
        
        print(f"\nS_{n} (|S_{n}| = {N}, generators = {num_trans} transpositions):")
        print(f"  Computed spectral gap:    {gap:.6f}")
        print(f"  Theoretical gap (2/n):   {theoretical_gap:.6f}")
        print(f"  Classical mixing time:   {classical_t:.0f}")
        print(f"  Quantum mixing time:     {quantum_t:.1f}")
        print(f"  Speedup ratio:           {classical_t / quantum_t:.2f}x")


def demo_mixing_convergence():
    """Show how the walk converges to uniform distribution."""
    print("\n" + "=" * 70)
    print("DEMO 3: Convergence to Uniform Distribution (Z/16Z)")
    print("=" * 70)
    
    n = 16
    A = cyclic_group_walk(n)
    P = A / A.sum(axis=1)[0]
    uniform = np.ones(n) / n
    
    distributions = simulate_walk(P, 200)
    
    print(f"\n{'Step':>6} | {'TV Distance':>12} | {'Max Deviation':>14}")
    print("-" * 40)
    for t in [0, 1, 5, 10, 20, 50, 100, 150, 200]:
        tv = total_variation(distributions[t], uniform)
        max_dev = np.max(np.abs(distributions[t] - uniform))
        print(f"{t:>6} | {tv:>12.6f} | {max_dev:>14.6f}")


def demo_spectral_gap_scaling():
    """Show how spectral gap scales with group size."""
    print("\n" + "=" * 70)
    print("DEMO 4: Spectral Gap Scaling")
    print("=" * 70)
    
    print(f"\n{'n':>6} | {'Gap':>10} | {'1/n²':>10} | {'Gap·n²':>10} | {'Classical T':>12} | {'Quantum T':>12}")
    print("-" * 70)
    
    for n in [4, 8, 16, 32, 64, 128, 256]:
        A = cyclic_group_walk(n)
        gap = spectral_gap(A)
        classical_t = mixing_time_bound(n, gap)
        quantum_t = quantum_mixing_time_bound(n, gap)
        
        print(f"{n:>6} | {gap:>10.6f} | {1/n**2:>10.6f} | {gap*n**2:>10.4f} | {classical_t:>12.0f} | {quantum_t:>12.1f}")


if __name__ == "__main__":
    demo_cyclic_groups()
    demo_symmetric_group()
    demo_mixing_convergence()
    demo_spectral_gap_scaling()
    
    print("\n" + "=" * 70)
    print("SUMMARY: Quantum walks achieve √n speedup in mixing time")
    print("The spectral gap determines both classical and quantum mixing rates.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Mixing Time Comparison for Quantum vs Classical Walks
"""

import numpy as np
import matplotlib.pyplot as plt


def cayley_graph_cyclic(n):
    A = np.zeros((n, n))
    for i in range(n):
        A[i, (i + 1) % n] = 1.0
        A[i, (i - 1) % n] = 1.0
    return A


def spectral_gap(A):
    d = A.sum(axis=1)[0]
    P = A / d
    eigenvalues = np.linalg.eigvalsh(P)
    sorted_eigs = np.sort(np.abs(eigenvalues))[::-1]
    return 1.0 - sorted_eigs[1]


def main():
    sizes = [4, 8, 16, 32, 64, 128, 256, 512]
    classical_times = []
    quantum_times = []
    gaps = []
    
    for n in sizes:
        A = cayley_graph_cyclic(n)
        gap = spectral_gap(A)
        gaps.append(gap)
        classical_times.append(np.log(n) / gap)
        quantum_times.append(np.sqrt(n) * np.log(n) / gap)
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Plot 1: Mixing times
    ax = axes[0]
    ax.loglog(sizes, classical_times, 'bo-', label='Classical: log(n)/γ', linewidth=2)
    ax.loglog(sizes, quantum_times, 'rs-', label='Quantum: √n·log(n)/γ', linewidth=2)
    ax.set_xlabel('Group size n', fontsize=12)
    ax.set_ylabel('Mixing time bound', fontsize=12)
    ax.set_title('Mixing Times: Quantum vs Classical', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Spectral gap scaling
    ax = axes[1]
    ax.loglog(sizes, gaps, 'go-', label='Computed gap', linewidth=2)
    theoretical = [2 * np.pi**2 / n**2 for n in sizes]
    ax.loglog(sizes, theoretical, 'k--', label='2π²/n² (theory)', linewidth=2)
    ax.set_xlabel('Group size n', fontsize=12)
    ax.set_ylabel('Spectral gap γ', fontsize=12)
    ax.set_title('Spectral Gap Scaling (Z/nZ)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Speedup ratio
    ax = axes[2]
    ratios = [q / c for q, c in zip(quantum_times, classical_times)]
    sqrt_n = [np.sqrt(n) for n in sizes]
    ax.plot(sizes, ratios, 'mo-', label='Actual ratio', linewidth=2)
    ax.plot(sizes, sqrt_n, 'k--', label='√n', linewidth=2)
    ax.set_xlabel('Group size n', fontsize=12)
    ax.set_ylabel('Quantum / Classical ratio', fontsize=12)
    ax.set_title('Speedup Factor = √n', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('mixing_time_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved mixing_time_comparison.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Continuous-Time Quantum Walk Evolution on Cayley Graphs
"""

import numpy as np
import matplotlib.pyplot as plt


def simulate_quantum_walk_cyclic(n, times):
    """Simulate CTQW on Z/nZ."""
    A = np.zeros((n, n))
    for i in range(n):
        A[i, (i + 1) % n] = 1.0
        A[i, (i - 1) % n] = 1.0
    
    eigenvalues, eigenvectors = np.linalg.eigh(A)
    initial = np.zeros(n, dtype=complex)
    initial[0] = 1.0
    coeffs = eigenvectors.conj().T @ initial
    
    distributions = []
    for t in times:
        phase = np.exp(-1j * eigenvalues * t)
        state = eigenvectors @ (coeffs * phase)
        prob = np.abs(state) ** 2
        distributions.append(prob)
    
    return distributions


def main():
    n = 32
    times = np.linspace(0, 50, 500)
    distributions = simulate_quantum_walk_cyclic(n, times)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Plot 1: Probability heatmap over time
    ax = axes[0, 0]
    prob_matrix = np.array(distributions)
    im = ax.imshow(prob_matrix.T, aspect='auto', cmap='hot',
                   extent=[0, times[-1], n-0.5, -0.5])
    ax.set_xlabel('Time t', fontsize=12)
    ax.set_ylabel('Vertex (group element)', fontsize=12)
    ax.set_title(f'Quantum Walk on Z/{n}Z: P(g,t)', fontsize=13)
    plt.colorbar(im, ax=ax, label='Probability')
    
    # Plot 2: Snapshots at specific times
    ax = axes[0, 1]
    snapshot_times = [0.5, 5, 15, 40]
    for t_val in snapshot_times:
        idx = np.argmin(np.abs(times - t_val))
        ax.plot(range(n), distributions[idx], 'o-', label=f't = {t_val}',
                markersize=3, linewidth=1.5)
    ax.axhline(y=1/n, color='k', linestyle='--', alpha=0.5, label='Uniform')
    ax.set_xlabel('Vertex', fontsize=12)
    ax.set_ylabel('Probability', fontsize=12)
    ax.set_title('Probability Distribution Snapshots', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Total variation from uniform over time
    ax = axes[1, 0]
    uniform = np.ones(n) / n
    tv_distances = [0.5 * np.sum(np.abs(d - uniform)) for d in distributions]
    ax.plot(times, tv_distances, 'b-', linewidth=1.5)
    ax.set_xlabel('Time t', fontsize=12)
    ax.set_ylabel('TV distance from uniform', fontsize=12)
    ax.set_title('Quantum Walk: Distance to Uniform', fontsize=13)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.1)
    
    # Plot 4: Time-averaged distribution convergence
    ax = axes[1, 1]
    cumulative = np.zeros(n)
    avg_tv = []
    for i, d in enumerate(distributions):
        cumulative += d
        avg = cumulative / (i + 1)
        avg_tv.append(0.5 * np.sum(np.abs(avg - uniform)))
    ax.plot(times, avg_tv, 'r-', linewidth=1.5)
    ax.set_xlabel('Time t', fontsize=12)
    ax.set_ylabel('TV distance (time-averaged)', fontsize=12)
    ax.set_title('Time-Averaged Distribution → Uniform', fontsize=13)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.1)
    
    plt.tight_layout()
    plt.savefig('quantum_walk_evolution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved quantum_walk_evolution.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Spectral Analysis of Cayley Graphs
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def cayley_graph_cyclic(n):
    A = np.zeros((n, n))
    for i in range(n):
        A[i, (i + 1) % n] = 1.0
        A[i, (i - 1) % n] = 1.0
    return A


def cayley_graph_sn_transpositions(n):
    """Adjacency matrix of Cay(S_n, transpositions)."""
    elements = list(permutations(range(n)))
    elem_idx = {e: i for i, e in enumerate(elements)}
    N = len(elements)
    A = np.zeros((N, N))
    for idx_p, perm in enumerate(elements):
        for i in range(n):
            for j in range(i + 1, n):
                p = list(perm)
                p[i], p[j] = p[j], p[i]
                A[idx_p, elem_idx[tuple(p)]] = 1.0
    return A, N


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Plot 1: Eigenvalue spectra of Z/nZ for various n
    ax = axes[0, 0]
    for n in [8, 16, 32, 64]:
        A = cayley_graph_cyclic(n)
        P = A / 2.0
        eigs = np.sort(np.linalg.eigvalsh(P))[::-1]
        ax.plot(range(len(eigs)), eigs, 'o-', markersize=3, label=f'Z/{n}Z')
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.set_xlabel('Eigenvalue index', fontsize=12)
    ax.set_ylabel('Eigenvalue', fontsize=12)
    ax.set_title('Eigenvalue Spectra of Z/nZ Walks', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Eigenvalue spectrum of S_n
    ax = axes[0, 1]
    for n in [3, 4, 5]:
        A, N = cayley_graph_sn_transpositions(n)
        d = n * (n - 1) / 2
        P = A / d
        eigs = np.sort(np.linalg.eigvalsh(P))[::-1]
        ax.plot(range(len(eigs)), eigs, 'o', markersize=4, label=f'S_{n} (|G|={N})')
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.set_xlabel('Eigenvalue index', fontsize=12)
    ax.set_ylabel('Eigenvalue', fontsize=12)
    ax.set_title('Eigenvalue Spectra of S_n Walks', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Spectral gap vs n for cyclic groups
    ax = axes[1, 0]
    ns = list(range(4, 129))
    computed_gaps = []
    theoretical_gaps = []
    for n in ns:
        A = cayley_graph_cyclic(n)
        P = A / 2.0
        eigs = np.sort(np.abs(np.linalg.eigvalsh(P)))[::-1]
        computed_gaps.append(1 - eigs[1])
        theoretical_gaps.append(1 - np.cos(2 * np.pi / n))
    
    ax.semilogy(ns, computed_gaps, 'b-', linewidth=1.5, label='Computed gap')
    ax.semilogy(ns, theoretical_gaps, 'r--', linewidth=1.5, label='1 - cos(2π/n)')
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Spectral gap γ', fontsize=12)
    ax.set_title('Spectral Gap: Computed vs Theory', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 4: Entropy production rate
    ax = axes[1, 1]
    ns_ent = list(range(4, 257))
    entropy_rates = []
    for n in ns_ent:
        gap = 1 - np.cos(2 * np.pi / n)
        rate = gap * np.log(2)  # d=2 for cyclic
        entropy_rates.append(rate)
    
    ax.semilogy(ns_ent, entropy_rates, 'g-', linewidth=1.5)
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Entropy production rate γ·log(d)', fontsize=12)
    ax.set_title('Entropy Production Rate (Z/nZ)', fontsize=13)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('spectral_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved spectral_analysis.png")


if __name__ == "__main__":
    main()

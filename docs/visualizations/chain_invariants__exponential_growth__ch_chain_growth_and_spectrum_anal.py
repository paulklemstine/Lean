"""
Visualization: Exponential Growth in Divisibility Chains

Shows the exponential lower bound 2^n * a_0 versus actual chain values,
demonstrating the key lemma behind the Anti-Escher property.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def prime_factorization(n):
    if n <= 1:
        return []
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def big_omega(n):
    return len(prime_factorization(n))


def divisors_of(n):
    divs = []
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)


def find_example_chain(n, strategy="smallest"):
    """Find a divisibility chain from 1 to n using a greedy strategy."""
    chain = [1]
    current = 1
    while current != n:
        divs = [d for d in divisors_of(n) if d > current and d % current == 0]
        if not divs:
            break
        if strategy == "smallest":
            next_val = min(divs)
        elif strategy == "largest":
            next_val = max(divs)
        else:
            next_val = divs[len(divs)//2]
        chain.append(next_val)
        current = next_val
    return chain


def plot_exponential_growth():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left panel: specific chains with exponential bound
    ax1 = axes[0]
    
    chains = {
        "Powers of 2": [1, 2, 4, 8, 16, 32, 64, 128, 256],
        "Powers of 3": [1, 3, 9, 27, 81, 243, 729],
        "Primorial": [1, 2, 6, 30, 210, 2310],
        "Mixed": [1, 2, 6, 12, 60, 180, 1260],
    }
    
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0']
    
    for (name, chain), color in zip(chains.items(), colors):
        n_vals = range(len(chain))
        ax1.semilogy(list(n_vals), chain, 'o-', color=color, label=name, 
                     markersize=6, linewidth=2)
    
    # Plot the 2^n lower bound
    n_range = np.arange(0, 10)
    ax1.semilogy(n_range, 2.0**n_range, 'k--', linewidth=2, alpha=0.7, 
                 label=r'Lower bound $2^n$')
    
    ax1.set_xlabel('Chain position n', fontsize=12)
    ax1.set_ylabel('Value (log scale)', fontsize=12)
    ax1.set_title('Exponential Growth in Divisibility Chains', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(-0.5, 9.5)
    
    # Right panel: Ω(n) vs log₂(n) showing chain rank
    ax2 = axes[1]
    
    ns = range(2, 201)
    omegas = [big_omega(n) for n in ns]
    log2s = [np.log2(n) for n in ns]
    
    ax2.scatter(list(ns), omegas, s=8, alpha=0.7, color='#2196F3', label=r'$\Omega(n)$ (chain rank)')
    ax2.plot(list(ns), log2s, 'r-', linewidth=2, alpha=0.7, label=r'$\log_2(n)$ (upper bound)')
    
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title(r'Chain Rank $\Omega(n)$ vs $\log_2(n)$', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('chain_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved chain_growth.png")


def plot_spectrum_analysis():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: spectrum sum vs sopfr for all n
    ax1 = axes[0]
    
    ns = []
    sopfrs = []
    min_sums = []
    max_sums = []
    
    for n in range(2, 101):
        factors = prime_factorization(n)
        s = sum(factors)
        
        # Find all maximal chains
        omega = big_omega(n)
        target_len = omega + 1
        divs = divisors_of(n)
        
        all_chains = []
        def dfs(current, chain):
            if current == n:
                if len(chain) == target_len:
                    all_chains.append(chain[:])
                return
            if len(chain) >= target_len:
                return
            for d in divs:
                if d > current and d % current == 0:
                    chain.append(d)
                    dfs(d, chain)
                    chain.pop()
        dfs(1, [1])
        
        if all_chains:
            spectra_sums = [sum(c[i+1]//c[i] for i in range(len(c)-1)) for c in all_chains]
            ns.append(n)
            sopfrs.append(s)
            min_sums.append(min(spectra_sums))
            max_sums.append(max(spectra_sums))
    
    ax1.scatter(ns, sopfrs, s=20, alpha=0.8, color='#2196F3', label='sopfr(n)', zorder=5)
    ax1.scatter(ns, min_sums, s=10, alpha=0.5, color='#4CAF50', marker='v', label='Min spectrum sum')
    
    # Highlight cases where min_sum > sopfr
    for i, n in enumerate(ns):
        if min_sums[i] > sopfrs[i]:
            ax1.annotate(str(n), (n, min_sums[i]), fontsize=7, alpha=0.6)
    
    ax1.plot([0, 100], [0, 100], 'k--', alpha=0.3, label='y = x')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('Sum', fontsize=12)
    ax1.set_title('Spectrum Sum vs sopfr(n)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Right: number of maximal chains vs Ω(n)
    ax2 = axes[1]
    
    chain_counts = {}
    for n in range(2, 101):
        omega = big_omega(n)
        divs = divisors_of(n)
        target_len = omega + 1
        count = [0]
        
        def count_chains(current, depth):
            if current == n:
                if depth == target_len - 1:
                    count[0] += 1
                return
            if depth >= target_len - 1:
                return
            for d in divs:
                if d > current and d % current == 0:
                    count_chains(d, depth + 1)
        count_chains(1, 0)
        
        if omega not in chain_counts:
            chain_counts[omega] = []
        chain_counts[omega].append((n, count[0]))
    
    for omega in sorted(chain_counts.keys()):
        data = chain_counts[omega]
        ax2.scatter([d[0] for d in data], [d[1] for d in data], 
                    s=20, alpha=0.7, label=f'Ω = {omega}')
    
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Number of maximal chains', fontsize=12)
    ax2.set_title('Chain Multiplicity by Ω(n)', fontsize=14)
    ax2.legend(fontsize=9, ncol=2)
    ax2.grid(True, alpha=0.3)
    ax2.set_yscale('log')
    
    plt.tight_layout()
    plt.savefig('spectrum_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved spectrum_analysis.png")


if __name__ == "__main__":
    plot_exponential_growth()
    plot_spectrum_analysis()

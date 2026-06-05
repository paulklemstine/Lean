import matplotlib.pyplot as plt
import math

def plot_entropy_gap():
    b = 2
    T = 100
    ns = list(range(1, 21))
    gaps = []
    spaces = []
    provables = []
    for n in ns:
        space = b ** n
        provable = min(space - 1, T)
        gap = space - provable
        gaps.append(gap)
        spaces.append(space)
        provables.append(provable)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    ax1.semilogy(ns, spaces, 'b-o', label='Search space $b^n$', markersize=4)
    ax1.semilogy(ns, provables, 'r-s', label='Provable $P(n)$', markersize=4)
    ax1.semilogy(ns, gaps, 'g-^', label='Entropy gap', markersize=4)
    ax1.set_xlabel('Proof length n')
    ax1.set_ylabel('Count (log scale)')
    ax1.set_title('Entropy Gap Growth (b=2, T=100)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    densities = [p / s for p, s in zip(provables, spaces)]
    ax2.plot(ns, densities, 'r-o', markersize=4)
    ax2.set_xlabel('Proof length n')
    ax2.set_ylabel('Density P(n)/b^n')
    ax2.set_title('Proof Density Decay')
    ax2.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('entropy_gap_growth.png', dpi=150)
    plt.close()

plot_entropy_gap()
print('Saved entropy_gap_growth.png')

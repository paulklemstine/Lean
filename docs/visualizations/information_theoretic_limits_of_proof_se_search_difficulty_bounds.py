import matplotlib.pyplot as plt
import math

def plot_search_difficulty():
    b = 2
    ns = list(range(2, 21))
    fig, ax = plt.subplots(figsize=(10, 6))
    for k_frac, color, label in [(0.1, 'red', 'k=n/10'), (0.25, 'orange', 'k=n/4'), (0.5, 'blue', 'k=n/2')]:
        lower_bounds = []
        actual_diffs = []
        valid_ns = []
        for n in ns:
            k = max(1, int(k_frac * n))
            if k + 1 > n:
                continue
            V = b ** k
            lb = b ** (n - k - 1)
            actual = b ** n // (V + 1)
            lower_bounds.append(lb)
            actual_diffs.append(actual)
            valid_ns.append(n)
        ax.semilogy(valid_ns, lower_bounds, f'{color}', linestyle='--', marker='o', markersize=3, label=f'Lower bound ({label})')
        ax.semilogy(valid_ns, actual_diffs, f'{color}', linestyle='-', marker='s', markersize=3, label=f'Actual ({label})')
    ax.set_xlabel('Proof length n')
    ax.set_ylabel('Search difficulty (log scale)')
    ax.set_title('Information-Search Duality: Difficulty Bounds')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('search_difficulty_bounds.png', dpi=150)
    plt.close()

plot_search_difficulty()
print('Saved search_difficulty_bounds.png')

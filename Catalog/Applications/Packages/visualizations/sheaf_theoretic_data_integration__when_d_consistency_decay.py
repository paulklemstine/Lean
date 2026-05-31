import numpy as np
import matplotlib.pyplot as plt

def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    ax = axes[0]
    constraints = np.arange(0, 201)
    for r in [0.01, 0.05, 0.1, 0.2, 0.3]:
        probs = [(1 - r) ** c for c in constraints]
        ax.plot(constraints, probs, label=f'r = {r}')
    ax.set_xlabel('Number of constraints C')
    ax.set_ylabel('P(consistent) = (1-r)^C')
    ax.set_title('Exponential Decay of Consistency')
    ax.legend()
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)
    ax = axes[1]
    constraints = np.arange(1, 501)
    for r in [0.01, 0.05, 0.1, 0.2]:
        log_probs = [c * np.log10(1 - r) for c in constraints]
        ax.plot(constraints, log_probs, label=f'r = {r}')
    ax.set_xlabel('Number of constraints C')
    ax.set_ylabel('log10 P(consistent)')
    ax.set_title('Consistency Decay (Log Scale)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax = axes[2]
    n_dbs_values = [2, 3, 5, 10]
    n_cols_range = range(2, 21)
    n_rows = 50
    for n_dbs in n_dbs_values:
        counts = [n_dbs*(n_dbs-1)//2 * n_rows * nc for nc in n_cols_range]
        ax.plot(list(n_cols_range), counts, marker='o', markersize=3, label=f'n_dbs = {n_dbs}')
    ax.set_xlabel('Number of columns')
    ax.set_ylabel('Overlap constraint count')
    ax.set_title(f'Constraint Growth (n_rows = {n_rows})')
    ax.legend()
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('viz_consistency_decay.png', dpi=150, bbox_inches='tight')
    plt.close()
    print('Saved viz_consistency_decay.png')

if __name__ == '__main__':
    main()
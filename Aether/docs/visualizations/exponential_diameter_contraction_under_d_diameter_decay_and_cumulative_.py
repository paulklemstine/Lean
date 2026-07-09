import numpy as np
import matplotlib.pyplot as plt

def plot_decay_and_budget(D: float = 1.0, K: int = 30) -> None:
    lams = [3.0, 2.0, 1.5, 1.2]
    ks = np.arange(K)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    for lam in lams:
        d = D * (1.0 / lam) ** ks
        ax1.semilogy(ks, d, marker='o', ms=3, label=f'lambda={lam}')
        ax2.plot(ks, np.cumsum(d), marker='o', ms=3, label=f'lambda={lam}')
        ax2.axhline(D * lam / (lam - 1.0), ls='--', alpha=0.4)
    ax1.set_title('Maximum diameter d_k = D*(1/lambda)^k')
    ax1.set_xlabel('refinement round k'); ax1.set_ylabel('d_k (log)')
    ax1.legend(); ax1.grid(True, which='both', alpha=0.3)
    ax2.set_title('Cumulative budget -> D*lambda/(lambda-1)')
    ax2.set_xlabel('refinement round k'); ax2.set_ylabel('sum_{j<=k} d_j')
    ax2.legend(); ax2.grid(True, alpha=0.3)
    plt.tight_layout(); plt.savefig('decay_and_budget.png', dpi=150)
    print('saved decay_and_budget.png')

if __name__ == '__main__':
    plot_decay_and_budget()

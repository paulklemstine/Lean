import matplotlib.pyplot as plt, numpy as np

def divisibility_grid(k_max: int = 8, n_max: int = 24) -> None:
    """Heatmap of the criterion: cell (k,n) lit iff p_k | (x^n - 1), i.e. k | n."""
    M = np.array([[1 if (n % k == 0) else 0
                   for n in range(1, n_max + 1)] for k in range(2, k_max + 1)])
    plt.figure(figsize=(9, 4))
    plt.imshow(M, aspect='auto', cmap='Greens', origin='lower',
               extent=[1, n_max, 2, k_max])
    plt.xlabel('n'); plt.ylabel('k'); plt.title('p_k divides x^n - 1  (lit = yes)')
    plt.colorbar(label='divisible')
    plt.savefig('petrie_divisibility_grid.png', dpi=120, bbox_inches='tight')

if __name__ == "__main__":
    divisibility_grid()

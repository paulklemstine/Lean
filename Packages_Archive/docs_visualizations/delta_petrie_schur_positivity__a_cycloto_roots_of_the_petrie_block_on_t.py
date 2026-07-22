import cmath, matplotlib.pyplot as plt

def plot_petrie_roots(k: int) -> None:
    """Plot the roots of p_k: the k-th roots of unity except 1."""
    roots = [cmath.exp(2j * cmath.pi * j / k) for j in range(1, k)]
    circle = [cmath.exp(2j * cmath.pi * t / 200) for t in range(201)]
    plt.figure(figsize=(5, 5))
    plt.plot([z.real for z in circle], [z.imag for z in circle], 'k--', lw=0.6)
    plt.scatter([z.real for z in roots], [z.imag for z in roots], c='crimson', s=80,
                zorder=3, label='roots of p_k')
    plt.scatter([1], [0], c='gray', s=80, marker='x', label='x=1 (removed)')
    plt.gca().set_aspect('equal'); plt.grid(alpha=0.3); plt.legend()
    plt.title(f'Roots of the Petrie block p_{k} on the unit circle')
    plt.savefig(f'petrie_roots_k{k}.png', dpi=120, bbox_inches='tight')

if __name__ == "__main__":
    plot_petrie_roots(6)

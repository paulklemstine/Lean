"""
Visualization: Proof Refinement Chains and Complexity Landscapes

Produces matplotlib visualizations of:
1. Complexity decrease along refinement chains
2. Optimizer convergence trajectories
3. Complexity spectrum heatmap
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_refinement_chains():
    """Plot complexity decrease along refinement chains of various lengths."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Linear chains of different lengths
    for ax, N in zip(axes, [5, 10, 20]):
        complexities = list(range(N, -1, -1))
        steps = list(range(len(complexities)))
        ax.plot(steps, complexities, 'bo-', markersize=6, linewidth=2)
        ax.fill_between(steps, complexities, alpha=0.15, color='blue')
        ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
        ax.set_xlabel('Refinement Step', fontsize=12)
        ax.set_ylabel('Complexity C(P)', fontsize=12)
        ax.set_title(f'Linear System (N={N})', fontsize=14)
        ax.set_ylim(-0.5, N + 1)
        ax.annotate(f'Chain length = {N}\n= C(P₀) = {N}',
                    xy=(N//2, N//2), fontsize=10,
                    bbox=dict(boxstyle='round', facecolor='lightyellow'))

    plt.suptitle('Proof Refinement: Complexity Strictly Decreases', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('refinement_chains.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: refinement_chains.png")


def plot_optimizer_convergence():
    """Plot optimizer convergence for different strategies."""
    fig, ax = plt.subplots(figsize=(10, 6))

    N = 20

    # Step-by-step optimizer: decreases by 1 each step
    step_complexities = list(range(N, -1, -1))

    # Halving optimizer: approximately halves each step
    halving = [N]
    c = N
    while c > 0:
        c = c // 2
        halving.append(c)

    # Slow optimizer: decreases by 1 every 3 steps
    slow = []
    c = N
    step = 0
    while c > 0:
        slow.append(c)
        step += 1
        if step % 3 == 0:
            c -= 1
    slow.append(0)
    # Pad slow to show stabilization
    while len(slow) < len(slow) + 5:
        slow.append(0)
        if len(slow) > 100:
            break

    ax.plot(range(len(step_complexities)), step_complexities,
            'b-o', label='Step optimizer (−1 each step)', markersize=4)
    ax.plot(range(len(halving)), halving,
            'r-s', label='Halving optimizer (÷2 each step)', markersize=6)
    ax.plot(range(len(slow)), slow,
            'g-^', label='Slow optimizer (−1 every 3 steps)', markersize=4)

    ax.set_xlabel('Iteration n', fontsize=13)
    ax.set_ylabel('Complexity C(optⁿ(P))', fontsize=13)
    ax.set_title('Fixed Point Theorem: All Optimizers Converge', fontsize=15)
    ax.legend(fontsize=11)
    ax.set_ylim(-1, N + 2)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5, label='Fixed point')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('optimizer_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: optimizer_convergence.png")


def plot_complexity_landscape():
    """Plot a heatmap of proof complexity across theorems."""
    fig, ax = plt.subplots(figsize=(10, 6))

    num_theorems = 8
    max_complexity = 15

    # Generate interesting complexity data
    np.random.seed(42)
    data = np.zeros((num_theorems, max_complexity + 1))
    for t in range(num_theorems):
        # Each theorem has a random minimal complexity
        min_c = np.random.randint(0, 5)
        max_c = np.random.randint(min_c + 2, max_complexity + 1)
        for c in range(min_c, max_c + 1):
            # Number of proofs at each complexity
            data[t, c] = max(1, int(np.random.exponential(2)))

    im = ax.imshow(data, aspect='auto', cmap='YlOrRd', origin='lower')
    ax.set_xlabel('Proof Complexity', fontsize=13)
    ax.set_ylabel('Theorem ID', fontsize=13)
    ax.set_title('Proof Complexity Landscape', fontsize=15)
    plt.colorbar(im, ax=ax, label='Number of Proofs')

    # Mark minimal proofs
    for t in range(num_theorems):
        min_c = np.argmax(data[t] > 0)
        ax.plot(min_c, t, 'w*', markersize=12, markeredgecolor='black')

    ax.legend(['★ = Minimal proof'], loc='upper right', fontsize=10)
    plt.tight_layout()
    plt.savefig('complexity_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: complexity_landscape.png")


if __name__ == "__main__":
    plot_refinement_chains()
    plot_optimizer_convergence()
    plot_complexity_landscape()
    print("\nAll visualizations generated.")

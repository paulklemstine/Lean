"""
Visualization: Hessian Spectrum and Lorentzian Signature

Shows how the eigenvalue spectrum of Hessian matrices determines
Lorentzian signature. Demonstrates the rank-one perturbation theorem:
adding a single positive direction to a negative definite matrix
preserves the Lorentzian condition, but rank-2 perturbations can break it.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

np.random.seed(42)

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

n = 6

# Generate a negative definite base matrix
B = -3 * np.eye(n)

# Row 1: Increasing rank perturbation
for col, rank in enumerate([1, 2, 3]):
    ax = axes[0, col]
    
    # Generate random perturbation of given rank
    V = np.random.randn(n, rank) * 1.5
    A = B + V @ V.T
    eigenvalues = np.sort(np.linalg.eigvalsh(A))[::-1]
    n_positive = np.sum(eigenvalues > 1e-8)
    
    colors = ['green' if e > 1e-8 else ('red' if e < -1e-8 else 'gray') 
              for e in eigenvalues]
    
    bars = ax.bar(range(n), eigenvalues, color=colors, edgecolor='black', linewidth=0.5)
    ax.axhline(y=0, color='black', linewidth=1)
    ax.set_xlabel('Eigenvalue index', fontsize=11)
    ax.set_ylabel('Value', fontsize=11)
    
    is_lor = n_positive <= 1
    status = "✓ LORENTZIAN" if is_lor else "✗ NOT LORENTZIAN"
    status_color = "green" if is_lor else "red"
    ax.set_title(f'Rank-{rank} perturbation\n{status}',
                 fontsize=12, fontweight='bold', color=status_color)
    ax.set_xticks(range(n))
    ax.grid(True, alpha=0.3, axis='y')

# Row 2: Transition animation - gradually increase perturbation strength
scales = np.linspace(0, 3.0, 6)
v1 = np.array([1, 0, 0, 0, 0, 0], dtype=float)
v2 = np.array([0, 1, 0, 0, 0, 0], dtype=float)

for col in range(3):
    ax = axes[1, col]
    
    if col == 0:
        # Single direction, increasing strength
        all_evals = []
        strengths = np.linspace(0, 5, 50)
        for s in strengths:
            A = B + s * np.outer(v1, v1)
            evals = np.sort(np.linalg.eigvalsh(A))[::-1]
            all_evals.append(evals)
        all_evals = np.array(all_evals)
        
        for i in range(n):
            color = 'blue' if i == 0 else 'gray'
            lw = 2 if i == 0 else 1
            ax.plot(strengths, all_evals[:, i], color=color, linewidth=lw)
        ax.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
        ax.fill_between(strengths, 0, np.max(all_evals, axis=1),
                       where=np.sum(all_evals > 1e-8, axis=1) <= 1,
                       alpha=0.1, color='green', label='Lorentzian')
        ax.set_xlabel('Perturbation strength', fontsize=11)
        ax.set_ylabel('Eigenvalue', fontsize=11)
        ax.set_title('Rank-1: Always Lorentzian', fontsize=12, fontweight='bold', color='green')
        ax.grid(True, alpha=0.3)
    
    elif col == 1:
        # Two directions, increasing strength
        all_evals = []
        strengths = np.linspace(0, 5, 50)
        for s in strengths:
            A = B + s * np.outer(v1, v1) + s * np.outer(v2, v2)
            evals = np.sort(np.linalg.eigvalsh(A))[::-1]
            all_evals.append(evals)
        all_evals = np.array(all_evals)
        
        # Find transition point
        n_pos = [np.sum(e > 1e-8) for e in all_evals]
        transition_idx = next((i for i, np_ in enumerate(n_pos) if np_ > 1), len(strengths)-1)
        transition_s = strengths[transition_idx]
        
        for i in range(n):
            color = 'blue' if i < 2 else 'gray'
            lw = 2 if i < 2 else 1
            ax.plot(strengths, all_evals[:, i], color=color, linewidth=lw)
        ax.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
        ax.axvline(x=transition_s, color='red', linewidth=1.5, linestyle='--',
                   label=f'Transition at s≈{transition_s:.1f}')
        ax.set_xlabel('Perturbation strength', fontsize=11)
        ax.set_ylabel('Eigenvalue', fontsize=11)
        ax.set_title('Rank-2: Transition Point', fontsize=12, fontweight='bold', color='orange')
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
    
    else:
        # Heatmap of Lorentzian signature vs (rank, strength)
        ranks = range(1, n + 1)
        strengths = np.linspace(0.1, 5, 30)
        heatmap = np.zeros((len(list(ranks)), len(strengths)))
        
        for ri, rank in enumerate(ranks):
            for si, s in enumerate(strengths):
                V_rand = np.random.randn(n, rank)
                A = B + s * V_rand @ V_rand.T / rank
                evals = np.linalg.eigvalsh(A)
                n_pos = np.sum(evals > 1e-8)
                heatmap[ri, si] = n_pos
        
        im = ax.imshow(heatmap, aspect='auto', cmap='RdYlGn_r',
                       extent=[strengths[0], strengths[-1], n + 0.5, 0.5],
                       vmin=0, vmax=n)
        ax.set_xlabel('Perturbation strength', fontsize=11)
        ax.set_ylabel('Perturbation rank', fontsize=11)
        ax.set_title('Positive Eigenvalue Count', fontsize=12, fontweight='bold')
        plt.colorbar(im, ax=ax, label='# positive eigenvalues')
        
        # Mark the Lorentzian boundary
        ax.axhline(y=1.5, color='white', linewidth=2, linestyle='--')
        ax.text(strengths[-1]*0.7, 1.2, 'LORENTZIAN', color='white',
                fontsize=9, fontweight='bold')

plt.suptitle('Hessian Spectrum & Lorentzian Signature: The Rank-One Perturbation Theorem',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('hessian_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved hessian_spectrum.png")

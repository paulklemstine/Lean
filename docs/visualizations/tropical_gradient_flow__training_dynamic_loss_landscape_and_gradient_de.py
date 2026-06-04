"""
Visualization: Tropical L₁ Loss Landscape and Gradient Descent
===============================================================

Shows the piecewise-linear loss landscape and the trajectory
of tropical subgradient descent.
"""

import numpy as np
import matplotlib.pyplot as plt


def tropical_l1_loss(data, a):
    return sum(abs(max(a + x, 0) - y) for x, y in data)


def tropical_subgrad(data, a):
    g = 0.0
    for x, y in data:
        if a + x <= 0:
            g += 0.0 if y == 0 else (-1.0 if y > 0 else 1.0)
        else:
            g += 1.0 if max(a + x, 0) >= y else -1.0
    return g


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Dataset
    data = [(-2.0, 0.5), (-0.5, 1.5), (1.0, 2.5)]
    
    # Panel 1: Loss landscape
    ax = axes[0]
    a_range = np.linspace(-4, 4, 2000)
    losses = [tropical_l1_loss(data, a) for a in a_range]
    
    ax.plot(a_range, losses, 'b-', linewidth=2)
    
    # Mark breakpoints
    breakpoints = sorted([-x for x, _ in data])
    for bp in breakpoints:
        ax.axvline(x=bp, color='red', linestyle='--', alpha=0.5)
        ax.plot(bp, tropical_l1_loss(data, bp), 'ro', markersize=8)
    
    ax.set_xlabel('Parameter a', fontsize=12)
    ax.set_ylabel('L₁ Loss', fontsize=12)
    ax.set_title('Tropical L₁ Loss Landscape', fontsize=13)
    ax.grid(True, alpha=0.3)
    
    # Add legend for breakpoints
    ax.plot([], [], 'r--', label='Breakpoints (-xᵢ)')
    ax.legend(fontsize=10)
    
    # Panel 2: Gradient descent trajectory
    ax = axes[1]
    ax.plot(a_range, losses, 'b-', linewidth=1.5, alpha=0.5)
    
    # Run gradient descent
    eta = 0.15
    a = -3.5
    trajectory = [a]
    loss_trajectory = [tropical_l1_loss(data, a)]
    
    for _ in range(30):
        g = tropical_subgrad(data, a)
        if abs(g) < 1e-10:
            break
        a = a - eta * g
        trajectory.append(a)
        loss_trajectory.append(tropical_l1_loss(data, a))
    
    # Plot trajectory
    for i in range(len(trajectory) - 1):
        ax.annotate('', xy=(trajectory[i+1], loss_trajectory[i+1]),
                    xytext=(trajectory[i], loss_trajectory[i]),
                    arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
    ax.plot(trajectory, loss_trajectory, 'ro', markersize=5)
    ax.plot(trajectory[0], loss_trajectory[0], 'gs', markersize=10, label='Start')
    ax.plot(trajectory[-1], loss_trajectory[-1], 'r*', markersize=15, label='End')
    
    ax.set_xlabel('Parameter a', fontsize=12)
    ax.set_ylabel('L₁ Loss', fontsize=12)
    ax.set_title(f'Subgradient Descent (η={eta})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Loss over iterations
    ax = axes[2]
    ax.plot(range(len(loss_trajectory)), loss_trajectory, 'b-o', markersize=4)
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('L₁ Loss', fontsize=12)
    ax.set_title('Loss Convergence', fontsize=13)
    ax.grid(True, alpha=0.3)
    
    # Add Lipschitz bound annotation
    n = len(data)
    ax.annotate(f'Lipschitz constant = {n}',
               xy=(0.5, 0.85), xycoords='axes fraction',
               fontsize=11, color='darkgreen',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', alpha=0.5))
    
    plt.suptitle('Tropical Gradient Flow: Piecewise-Linear Optimization', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('loss_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: loss_landscape.png")


if __name__ == "__main__":
    main()

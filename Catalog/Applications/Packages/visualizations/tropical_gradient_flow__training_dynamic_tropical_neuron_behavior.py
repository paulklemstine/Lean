"""
Visualization: Tropical Neuron Behavior
========================================

Shows the piecewise-linear structure of the tropical neuron
and its four characteristic regions.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches


def tropical_neuron(a, b, x):
    return np.maximum(a + x, 0) - np.maximum(b + x, 0)


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # Panel 1: Tropical neuron for different (a, b) parameters
    ax = axes[0, 0]
    x = np.linspace(-5, 5, 1000)
    params = [(2, -1, 'b'), (1, 1, 'r'), (-1, 2, 'g'), (3, 0, 'purple')]
    for a, b, color in params:
        y = tropical_neuron(a, b, x)
        ax.plot(x, y, color=color, linewidth=2, label=f'a={a}, b={b}')
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    ax.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x; a, b)', fontsize=12)
    ax.set_title('Tropical Neuron: max(a+x,0) - max(b+x,0)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Four regions for a=2, b=-1
    ax = axes[0, 1]
    a, b = 2.0, -1.0
    x = np.linspace(-5, 5, 1000)
    y = tropical_neuron(a, b, x)
    
    # Color regions
    region1 = x <= -a  # both inactive
    region2 = (x > -a) & (x <= -b)  # a active only
    region3 = x > -b  # both active (when a > b)
    
    ax.fill_between(x, -4, 4, where=region1, alpha=0.15, color='blue', label='Both inactive')
    ax.fill_between(x, -4, 4, where=region2, alpha=0.15, color='green', label='a active only')
    ax.fill_between(x, -4, 4, where=region3, alpha=0.15, color='red', label='Both active')
    
    ax.plot(x, y, 'k-', linewidth=2.5)
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    ax.axvline(x=-a, color='blue', linestyle='--', alpha=0.7, label=f'x = -a = {-a}')
    ax.axvline(x=-b, color='red', linestyle='--', alpha=0.7, label=f'x = -b = {-b}')
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x; 2, -1)', fontsize=12)
    ax.set_title('Four Regions of the Tropical Neuron', fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.set_ylim(-4, 4)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Antisymmetry
    ax = axes[1, 0]
    a, b = 1.5, -0.5
    x = np.linspace(-4, 4, 1000)
    y1 = tropical_neuron(a, b, x)
    y2 = tropical_neuron(b, a, x)
    
    ax.plot(x, y1, 'b-', linewidth=2, label=f'f(x; {a}, {b})')
    ax.plot(x, y2, 'r-', linewidth=2, label=f'f(x; {b}, {a})')
    ax.plot(x, -y1, 'r--', linewidth=1.5, alpha=0.5, label=f'-f(x; {a}, {b})')
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)', fontsize=12)
    ax.set_title('Antisymmetry: f(x; a,b) = -f(x; b,a)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 4: Softplus convergence to ReLU
    ax = axes[1, 1]
    x = np.linspace(-3, 3, 500)
    relu = np.maximum(x, 0)
    
    for t in [0.5, 1, 2, 5, 20]:
        # Numerically stable softplus
        sp = np.where(t * x > 20, x, (1.0/t) * np.log(1 + np.exp(t * x)))
        ax.plot(x, sp, alpha=0.8, label=f't = {t}')
    
    ax.plot(x, relu, 'k--', linewidth=2.5, label='ReLU = max(x,0)')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('(1/t)·softplus(tx)', fontsize=12)
    ax.set_title('Scaled Softplus → ReLU (Tropical Limit)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.suptitle('Tropical Gradient Flow: Neural Network Tropicalization', fontsize=15, y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_neuron.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_neuron.png")


if __name__ == "__main__":
    main()

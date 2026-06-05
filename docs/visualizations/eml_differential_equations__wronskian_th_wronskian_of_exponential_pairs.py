import numpy as np
import matplotlib.pyplot as plt

def plot_wronskian_exponentials():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    xs = np.linspace(-2, 2, 200)
    
    pairs = [(1, -1, 'exp(x), exp(-x)'), (1, 2, 'exp(x), exp(2x)'), (0.5, 1.5, 'exp(x/2), exp(3x/2)')]
    for ax, (a, b, label) in zip(axes, pairs):
        W = (b - a) * np.exp((a + b) * xs)
        ax.plot(xs, W, 'b-', linewidth=2)
        ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
        ax.set_title(f'W({label})', fontsize=12)
        ax.set_xlabel('x')
        ax.set_ylabel('W(x)')
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('Wronskian of Exponential Pairs: W = (β-α)·exp((α+β)x)', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('wronskian_exponentials.png', dpi=150, bbox_inches='tight')
    plt.show()

plot_wronskian_exponentials()
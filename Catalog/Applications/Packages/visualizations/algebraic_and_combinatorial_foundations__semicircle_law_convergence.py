#!/usr/bin/env python3
import math, random
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

np.random.seed(42)

def semicircle_density(x):
    if abs(x) > 2: return 0.0
    return (1 / (2 * math.pi)) * math.sqrt(4 - x**2)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
for ax, n in zip(axes.flat, [50, 200, 500, 2000]):
    M = np.random.randn(n, n)
    M = (M + M.T) / 2 / np.sqrt(n)
    eigs = np.linalg.eigvalsh(M)
    x = np.linspace(-2.5, 2.5, 500)
    ax.hist(eigs, bins=60, density=True, alpha=0.7, color='steelblue')
    ax.plot(x, [semicircle_density(xi) for xi in x], 'r-', lw=2)
    ax.set_title(f'n = {n}')
plt.suptitle('Semicircle Law Convergence')
plt.tight_layout()
plt.savefig('viz_semicircle.png', dpi=150)

#!/usr/bin/env python3
"""
Visualization: EML Approximation of Continuous Functions

Demonstrates the Stone-Weierstrass density result by showing how
EML generators can approximate various target functions with
increasing accuracy as more generators are added.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def eml_generator(x: np.ndarray, w: float, b: float) -> np.ndarray:
    return np.exp(np.clip(w * x + b, -500, 500))

def fit_eml(x: np.ndarray, target: np.ndarray,
            params: list) -> tuple:
    basis = np.column_stack(
        [eml_generator(x, w, b) for w, b in params] + [np.ones_like(x)]
    )
    coeffs, _, _, _ = np.linalg.lstsq(basis, target, rcond=None)
    approx = basis @ coeffs
    return approx, float(np.max(np.abs(target - approx)))

def main():
    x = np.linspace(0, 1, 200)
    targets = {
        'x²': x**2,
        'sin(2πx)': np.sin(2 * np.pi * x),
        '|x - 0.5|': np.abs(x - 0.5),
    }

    generator_sets = [
        [(1, 0), (-1, 0)],
        [(1, 0), (-1, 0), (2, -1), (-2, 1)],
        [(1, 0), (-1, 0), (2, -1), (-2, 1), (3, -2), (-3, 2), (0.5, 0.5), (-0.5, -0.5)],
        [(i*0.7, j*0.5) for i in range(-3, 4) for j in range(-2, 3)],
    ]
    n_gens = [len(g) for g in generator_sets]

    fig, axes = plt.subplots(len(targets), len(generator_sets), figsize=(18, 10))

    for row, (name, target) in enumerate(targets.items()):
        for col, (params, ng) in enumerate(zip(generator_sets, n_gens)):
            ax = axes[row, col]
            approx, error = fit_eml(x, target, params)
            ax.plot(x, target, 'b-', linewidth=2, alpha=0.7, label='Target')
            ax.plot(x, approx, 'r--', linewidth=1.5, label=f'EML (n={ng})')
            ax.fill_between(x, target, approx, alpha=0.15, color='red')
            ax.set_title(f'{name}, {ng} gens\nerror = {error:.2e}', fontsize=10)
            ax.grid(True, alpha=0.3)
            if row == 0 and col == 0:
                ax.legend(fontsize=8)

    fig.suptitle('EML Approximation: Stone-Weierstrass in Action', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('eml_approximation_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_approximation_visualization.png")

if __name__ == "__main__":
    main()

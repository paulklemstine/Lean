#!/usr/bin/env python3
"""
Visualization: Page Curve for Holographic Code Families

Plots the radiation entropy k(t) as a function of time, showing the
characteristic Page curve shape with a peak at the Page time.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def page_curve_k(t: np.ndarray, n: int, page_time: int) -> np.ndarray:
    """Compute k(t) for a Page curve."""
    result = np.zeros_like(t, dtype=float)
    for i, ti in enumerate(t):
        if ti <= page_time:
            result[i] = min(ti, n // 2)
        else:
            result[i] = max(n // 2 - (ti - page_time), 0)
    return result


def page_curve_smooth(t: np.ndarray, n: int, page_time: float) -> np.ndarray:
    """Smooth Page curve using thermodynamic approximation."""
    k_max = n / 2
    # Before page time: k ~ t (linear growth)
    # After page time: k ~ n - t (linear decrease)
    # Smooth version using tanh
    width = page_time / 5
    return k_max * (1 - np.tanh((t - page_time) / width)) / 2


def main():
    n = 40
    page_time = 20

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Discrete Page curve
    ax = axes[0]
    t_discrete = np.arange(0, 41)
    k_discrete = page_curve_k(t_discrete, n, page_time)
    d_discrete = (n - k_discrete) / 2 + 1

    ax.plot(t_discrete, k_discrete, 'b-o', markersize=4, label='k(t) = logical qubits')
    ax.axvline(x=page_time, color='red', linestyle='--', alpha=0.7, label=f'Page time = {page_time}')
    ax.fill_between(t_discrete, k_discrete, alpha=0.15, color='blue')
    ax.set_xlabel('Time t', fontsize=12)
    ax.set_ylabel('Radiation entropy k(t)', fontsize=12)
    ax.set_title(f'Page Curve (n={n})', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1, 41)

    # Right: Smooth thermodynamic Page curve
    ax = axes[1]
    t_smooth = np.linspace(0, 40, 200)
    k_smooth = page_curve_smooth(t_smooth, n, page_time)

    ax.plot(t_smooth, k_smooth, 'b-', linewidth=2, label='S_rad(t)')
    ax.axvline(x=page_time, color='red', linestyle='--', alpha=0.7, label='Page time')

    # Also plot the "naive" Hawking curve (always increasing)
    k_hawking = np.minimum(t_smooth, n / 2) * np.ones_like(t_smooth)
    k_hawking = np.where(t_smooth <= n, t_smooth * (n/2) / n, n/2)
    ax.plot(t_smooth, k_hawking, 'gray', linestyle=':', linewidth=1.5,
            label='Hawking (no unitarity)', alpha=0.6)

    ax.fill_between(t_smooth, k_smooth, alpha=0.15, color='blue')
    ax.set_xlabel('Time t', fontsize=12)
    ax.set_ylabel('Radiation entropy', fontsize=12)
    ax.set_title('Thermodynamic Page Curve', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1, 41)

    plt.tight_layout()
    plt.savefig('page_curve.png', dpi=150, bbox_inches='tight')
    print("Saved page_curve.png")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Bifurcation diagram of the logistic scoring map."""

import matplotlib.pyplot as plt
import numpy as np


def logistic_map(mu: float, x: float) -> float:
    return mu * x * (1.0 - x)


def main():
    mu_values = np.linspace(0.5, 4.0, 2000)
    n_warmup = 500
    n_plot = 200

    fig, ax = plt.subplots(figsize=(12, 7))

    all_mu = []
    all_x = []
    for mu in mu_values:
        x = 0.5
        for _ in range(n_warmup):
            x = logistic_map(mu, x)
        for _ in range(n_plot):
            x = logistic_map(mu, x)
            all_mu.append(mu)
            all_x.append(x)

    ax.scatter(all_mu, all_x, s=0.02, c='black', alpha=0.5)

    # Mark key bifurcation points
    ax.axvline(x=1.0, color='blue', linestyle='--', alpha=0.5, label='μ=1 (transcritical)')
    ax.axvline(x=3.0, color='red', linestyle='--', alpha=0.5, label='μ=3 (period-2)')
    ax.axvline(x=1 + np.sqrt(6), color='green', linestyle='--', alpha=0.5, label='μ=1+√6 (period-4)')

    # Plot the non-trivial fixed point branch
    mu_fp = np.linspace(1.01, 4.0, 500)
    fp = 1 - 1 / mu_fp
    ax.plot(mu_fp, fp, 'r-', linewidth=1.5, alpha=0.7, label='x* = 1 - 1/μ')

    ax.set_xlabel('Feedback parameter μ', fontsize=13)
    ax.set_ylabel('Score attractor x', fontsize=13)
    ax.set_title('Bifurcation Diagram: Phase Transitions in Social Credit Scoring', fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.set_xlim(0.5, 4.0)
    ax.set_ylim(-0.05, 1.05)
    plt.tight_layout()
    plt.savefig('bifurcation_diagram.png', dpi=150)
    print("Saved bifurcation_diagram.png")


if __name__ == "__main__":
    main()

"""Visualization: Wronskian constancy (Abel's identity).

For y'' = r^2 y the basis y1 = e^{rx}, y2 = e^{-rx} has Wronskian
W = y1 y2' - y2 y1', which is the constant -2r. We plot the two solutions
and their (flat) Wronskian to illustrate that W lies in the constants subfield.
"""
import math
import numpy as np
import matplotlib.pyplot as plt

def plot_wronskian(r: float = 1.0) -> None:
    xs = np.linspace(-2.0, 2.0, 400)
    y1 = np.exp(r * xs); y2 = np.exp(-r * xs)
    dy1 = r * y1; dy2 = -r * y2
    W = y1 * dy2 - y2 * dy1
    fig, ax = plt.subplots(1, 2, figsize=(11, 4))
    ax[0].plot(xs, y1, label='y1 = e^{rx}')
    ax[0].plot(xs, y2, label='y2 = e^{-rx}')
    ax[0].set_title('Two solutions of y\" = r^2 y'); ax[0].legend(); ax[0].grid(alpha=0.3)
    ax[1].plot(xs, W, color='crimson')
    ax[1].axhline(-2 * r, ls='--', color='gray', label='-2r')
    ax[1].set_title('Wronskian W = y1 y2\' - y2 y1\' (constant)')
    ax[1].legend(); ax[1].grid(alpha=0.3)
    plt.tight_layout(); plt.savefig('wronskian.png', dpi=150)
    print('wrote wronskian.png')

if __name__ == '__main__':
    plot_wronskian()

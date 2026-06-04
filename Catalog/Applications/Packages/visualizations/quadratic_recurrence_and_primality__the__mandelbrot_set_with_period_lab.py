#!/usr/bin/env python3
"""
Visualization: Mandelbrot Set with Bulb Period Labels
=====================================================
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def escape_time(c, max_iter=200):
    z = 0 + 0j
    for n in range(max_iter):
        z = z * z + c
        if abs(z) > 2:
            return n
    return max_iter


def compute_mandelbrot(xmin, xmax, ymin, ymax, width, height, max_iter=200):
    x = np.linspace(xmin, xmax, width)
    y = np.linspace(ymin, ymax, height)
    img = np.zeros((height, width))
    for j in range(height):
        for i in range(width):
            c = complex(x[i], y[j])
            img[j, i] = escape_time(c, max_iter)
    return img


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Full Mandelbrot set
    ax = axes[0]
    img = compute_mandelbrot(-2.2, 0.8, -1.2, 1.2, 600, 480, 100)
    ax.imshow(img, extent=[-2.2, 0.8, -1.2, 1.2], cmap='hot', origin='lower')
    ax.set_title("Mandelbrot Set with Bulb Periods", fontsize=14)
    ax.set_xlabel("Re(c)")
    ax.set_ylabel("Im(c)")

    # Label key bulbs
    bulbs = [
        (0.0, 0.0, "1", 14),
        (-1.0, 0.0, "2", 12),
        (-0.125, 0.744, "3", 10),
        (-0.125, -0.744, "3", 10),
        (0.282, 0.533, "4", 9),
        (0.282, -0.533, "4", 9),
        (-1.755, 0.0, "3", 10),
        (0.379, 0.337, "5", 8),
        (-0.156, 1.032, "5", 8),
    ]
    for x, y, label, size in bulbs:
        ax.annotate(label, (x, y), fontsize=size, color='cyan', fontweight='bold',
                   ha='center', va='center')

    # Right: Dynatomic point counts
    ax = axes[1]
    periods = list(range(1, 16))
    psi_values = []
    orbit_counts = []
    for n in periods:
        # Möbius inversion
        divs = [d for d in range(1, n+1) if n % d == 0]
        def mobius(k):
            if k == 1: return 1
            d = 2
            factors = []
            temp = k
            while d * d <= temp:
                if temp % d == 0:
                    exp = 0
                    while temp % d == 0:
                        exp += 1
                        temp //= d
                    if exp > 1: return 0
                    factors.append(d)
                d += 1
            if temp > 1: factors.append(temp)
            return (-1)**len(factors)
        psi = sum(mobius(n // d) * (2**d) for d in divs)
        psi_values.append(psi)
        orbit_counts.append(psi // n)

    colors = ['red' if all(n % p != 0 for p in range(2, n)) and n > 1
              else 'steelblue' for n in periods]
    ax.bar(periods, orbit_counts, color=colors, edgecolor='black', alpha=0.8)
    ax.set_xlabel("Period n", fontsize=12)
    ax.set_ylabel("Number of Primitive Orbits", fontsize=12)
    ax.set_title("Primitive Orbit Count by Period\n(red = prime period)", fontsize=14)
    ax.set_xticks(periods)

    # Add Ψ(n)/n formula annotation
    ax.annotate(r"$\frac{\Psi(n)}{n} = \frac{1}{n}\sum_{d|n} \mu(n/d) \cdot 2^d$",
               xy=(0.5, 0.92), xycoords='axes fraction', fontsize=11,
               ha='center', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    plt.tight_layout()
    plt.savefig("mandelbrot_number_theory.png", dpi=150, bbox_inches='tight')
    print("Saved mandelbrot_number_theory.png")


if __name__ == "__main__":
    main()

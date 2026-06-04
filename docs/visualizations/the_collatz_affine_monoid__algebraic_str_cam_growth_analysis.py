#!/usr/bin/env python3
"""
Visualization: CAM Growth Analysis — Contraction Ratios and Barrier Depths

Shows how the CAM contraction ratio num/denom relates to orbit behavior,
and visualizes the barrier depth function.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def collatz(n):
    return n // 2 if n % 2 == 0 else 3 * n + 1


def stopping_time(n, max_steps=10000):
    current = n
    for k in range(max_steps):
        if current == 1:
            return k
        current = collatz(current)
    return None


def compute_cam(n):
    num, offset, denom = 1, 0, 1
    current = n
    while current != 1:
        if current % 2 == 0:
            denom *= 2
            current = current // 2
        else:
            offset = 3 * offset + denom
            num *= 3
            current = 3 * current + 1
    return num, offset, denom


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # Plot 1: Stopping times
    ax = axes[0, 0]
    N = 1000
    ns = list(range(2, N + 1))
    times = [stopping_time(n) for n in ns]
    ax.scatter(ns, times, s=1, alpha=0.5, color='navy')
    ax.set_xlabel('n', fontsize=11)
    ax.set_ylabel('Stopping time', fontsize=11)
    ax.set_title('Collatz Stopping Times', fontsize=13)

    # Plot 2: log(contraction ratio) = s*log(3) - e*log(2)
    ax = axes[0, 1]
    ratios = []
    for n in range(2, N + 1):
        num, offset, denom = compute_cam(n)
        if denom > 0:
            ratio = math.log(num) - math.log(denom)
            ratios.append((n, ratio))
    ax.scatter([r[0] for r in ratios], [r[1] for r in ratios],
               s=1, alpha=0.5, color='darkred')
    ax.axhline(0, color='black', linewidth=1, linestyle='-')
    ax.set_xlabel('n', fontsize=11)
    ax.set_ylabel('log(3ˢ/2ᵉ)', fontsize=11)
    ax.set_title('CAM Contraction Ratio (log scale)', fontsize=13)

    # Plot 3: Barrier depth vs n
    ax = axes[1, 0]
    depths = [(n, stopping_time(n)) for n in range(1, 501)]
    ax.bar([d[0] for d in depths], [d[1] for d in depths],
           width=1, color='teal', alpha=0.7)
    # Overlay 2^k reference
    for k in range(1, 10):
        if 2**k <= 500:
            ax.plot(2**k, k, 'ro', markersize=8)
    ax.set_xlabel('n', fontsize=11)
    ax.set_ylabel('Barrier depth (steps to 1)', fontsize=11)
    ax.set_title('Barrier Depth Function', fontsize=13)
    ax.legend(['Powers of 2 (depth = k)'], fontsize=9)

    # Plot 4: 3^s vs 2^e separation
    ax = axes[1, 1]
    s_vals = range(0, 15)
    for s in s_vals:
        ax.plot(s, 3**s, 'bo', markersize=4)
    e_vals = range(0, 25)
    for e in e_vals:
        ax.plot(e * math.log(3) / math.log(2), 2**e, 'r^', markersize=4)
    x = np.linspace(0, 14, 100)
    ax.plot(x, 3**x, 'b-', linewidth=2, label='3ˢ')
    ax.plot(x, 2**(x * math.log(2) / math.log(3) * math.log(3) / math.log(2)),
            'r-', linewidth=2, label='2ᵉ at e=s·log₂3')
    ax.set_yscale('log')
    ax.set_xlabel('s (odd steps)', fontsize=11)
    ax.set_ylabel('Value (log scale)', fontsize=11)
    ax.set_title('Three-Two Separation: 3ˢ vs 2ᵉ', fontsize=13)
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('collatz_cam_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: collatz_cam_analysis.png")


if __name__ == "__main__":
    main()

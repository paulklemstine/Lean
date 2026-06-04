#!/usr/bin/env python3
"""
Visualization: Farey-Fibonacci Structure in Mandelbrot Bulbs
=============================================================
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def fibonacci(n):
    fibs = [0, 1]
    for _ in range(n):
        fibs.append(fibs[-1] + fibs[-2])
    return fibs


def farey_mediant(p1, q1, p2, q2):
    return (p1 + p2, q1 + q2)


def mobius(n):
    if n == 1: return 1
    d, factors = 2, []
    temp = n
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


def dynatomic(n):
    divs = [d for d in range(1, n+1) if n % d == 0]
    return sum(mobius(n // d) * (2**d) for d in divs)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Farey tree showing Fibonacci emergence
    ax = axes[0]
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.5, 5.5)
    ax.set_title("Farey Tree → Fibonacci Periods\nin Mandelbrot Antenna", fontsize=14)
    ax.set_ylabel("Depth", fontsize=12)

    # Draw Farey tree levels
    def draw_farey_level(fracs, depth, ax):
        new_fracs = []
        for i in range(len(fracs) - 1):
            p1, q1 = fracs[i]
            p2, q2 = fracs[i + 1]
            med = farey_mediant(p1, q1, p2, q2)
            new_fracs.append(fracs[i])
            new_fracs.append(med)
            # Draw lines
            x1 = p1 / q1
            x2 = p2 / q2
            xm = med[0] / med[1]
            ax.plot([x1, xm], [depth - 1, depth], 'b-', alpha=0.3, lw=0.8)
            ax.plot([x2, xm], [depth - 1, depth], 'b-', alpha=0.3, lw=0.8)
            # Mark mediant
            is_fib = med[1] in fibonacci(15)
            color = 'red' if is_fib else 'steelblue'
            size = 10 if is_fib else 7
            ax.plot(xm, depth, 'o', color=color, markersize=size, zorder=5)
            ax.annotate(f"{med[0]}/{med[1]}", (xm, depth),
                       textcoords="offset points", xytext=(0, 8),
                       fontsize=7, ha='center', color=color)
        new_fracs.append(fracs[-1])
        return new_fracs

    fracs = [(0, 1), (1, 1)]
    for f in fracs:
        x = f[0] / f[1] if f[1] > 0 else 0
        ax.plot(x, 0, 'ko', markersize=8, zorder=5)
        ax.annotate(f"{f[0]}/{f[1]}", (x, 0), textcoords="offset points",
                   xytext=(0, 8), fontsize=8, ha='center')

    for depth in range(1, 6):
        fracs = draw_farey_level(fracs, depth, ax)

    # Highlight Fibonacci path
    fib = fibonacci(10)
    fib_fracs = [(fib[i], fib[i+1]) for i in range(1, 8)]
    for p, q in fib_fracs:
        if q > 0:
            x = p / q
            ax.plot(x, -0.3, '*', color='gold', markersize=15, zorder=10)

    ax.axhline(y=-0.15, color='gray', linestyle='--', alpha=0.3)
    ax.text(0.5, -0.4, "★ = Fibonacci fraction (golden ratio path)",
           ha='center', fontsize=9, color='goldenrod')

    # Right: Dynatomic degree growth
    ax = axes[1]
    periods = list(range(1, 21))
    psi = [dynatomic(n) for n in periods]
    two_n = [2**n for n in periods]

    ax.semilogy(periods, psi, 'ro-', label=r'$\Psi(n)$ (dynatomic)', markersize=6)
    ax.semilogy(periods, two_n, 'b--', label=r'$2^n$ (total periodic)', alpha=0.5)
    ax.semilogy(periods, [p / n for p, n in zip(psi, periods)], 'g^-',
               label=r'$\Psi(n)/n$ (orbits)', markersize=5)

    # Mark primes
    primes = [p for p in periods if p > 1 and all(p % d != 0 for d in range(2, p))]
    for p in primes:
        ax.axvline(x=p, color='red', alpha=0.1, lw=8)

    ax.set_xlabel("Period n", fontsize=12)
    ax.set_ylabel("Count (log scale)", fontsize=12)
    ax.set_title("Dynatomic Point Count Growth\n(shaded = prime periods)", fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(periods)

    plt.tight_layout()
    plt.savefig("farey_fibonacci_structure.png", dpi=150, bbox_inches='tight')
    print("Saved farey_fibonacci_structure.png")


if __name__ == "__main__":
    main()

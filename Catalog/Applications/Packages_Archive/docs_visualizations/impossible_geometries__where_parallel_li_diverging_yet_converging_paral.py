"""Visualization: the apparition lattice -- diverging then converging lines.
Generates a figure showing two divisibility lines L(a), L(b) as evenly spaced
ticks that diverge locally yet share crossing points on the lcm-line.
Requires matplotlib. Run:  python apparition_lattice_viz.py
"""
from __future__ import annotations
from math import gcd
import matplotlib.pyplot as plt

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def alpha(m: int) -> int:
    k = 1
    while fib(k) % m != 0:
        k += 1
    return k

def lcm(a: int, b: int) -> int:
    return a // gcd(a, b) * b

def plot_lattice(a: int = 3, b: int = 5, bound: int = 60) -> None:
    sa, sb = alpha(a), alpha(b)
    step = lcm(sa, sb)
    ticks_a = list(range(0, bound + 1, sa))
    ticks_b = list(range(0, bound + 1, sb))
    crossings = list(range(0, bound + 1, step))

    fig, ax = plt.subplots(figsize=(12, 3.2))
    ax.hlines(1.0, 0, bound, color="#888", lw=0.6)
    ax.hlines(0.0, 0, bound, color="#888", lw=0.6)
    ax.plot(ticks_a, [1.0] * len(ticks_a), "o", color="#2c7fb8",
            label=f"L({a})  step alpha({a})={sa}")
    ax.plot(ticks_b, [0.0] * len(ticks_b), "s", color="#d95f0e",
            label=f"L({b})  step alpha({b})={sb}")
    for c in crossings:
        ax.plot([c, c], [0.0, 1.0], "--", color="#31a354", lw=1.2)
        ax.plot(c, 0.5, "*", color="#31a354", ms=14)
    ax.set_title(f"Apparition lattice: L({a}) and L({b}) diverge locally, "
                 f"reconverge every lcm({sa},{sb})={step}")
    ax.set_yticks([0, 1]); ax.set_yticklabels([f"L({b})", f"L({a})"])
    ax.set_xlabel("index k  (position in the Fibonacci sequence)")
    ax.legend(loc="upper right"); ax.set_ylim(-0.5, 1.6)
    plt.tight_layout(); plt.savefig("apparition_lattice.png", dpi=150)
    print("saved apparition_lattice.png")

if __name__ == "__main__":
    plot_lattice()

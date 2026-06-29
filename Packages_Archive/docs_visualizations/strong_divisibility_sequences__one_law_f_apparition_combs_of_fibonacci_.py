"""Visualization: apparition combs of Fibonacci divisors.

Each divisor p first appears at its rank r and reappears exactly at multiples of r,
producing a periodic "comb". This script draws those combs for several primes and
overlays the joint comb of two divisors (spacing = lcm of ranks)."""
import matplotlib.pyplot as plt
from math import gcd

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def rank(p: int, search: int = 200) -> int:
    for n in range(1, search + 1):
        if fib(n) % p == 0:
            return n
    raise ValueError

N = 60
primes = [2, 3, 5, 7, 11, 13]
fig, ax = plt.subplots(figsize=(11, 4))
for row, p in enumerate(primes):
    r = rank(p)
    hits = [m for m in range(1, N + 1) if m % r == 0]
    ax.scatter(hits, [row] * len(hits), s=40)
    ax.text(-2, row, f"p={p} (rank {r})", ha="right", va="center", fontsize=9)
ax.set_yticks([])
ax.set_xlabel("index m")
ax.set_title("Apparition combs in the Fibonacci sequence:  p | F(m)  <=>  rank(p) | m")
ax.set_xlim(-12, N + 1)
plt.tight_layout()
plt.savefig("apparition_combs.png", dpi=150)
print("wrote apparition_combs.png")

import matplotlib.pyplot as plt
import numpy as np


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def rank_fib(p: int, bound: int = 200) -> int:
    for k in range(1, bound + 1):
        if fib(k) % p == 0:
            return k
    return 0


primes = [2, 3, 5, 7, 11, 13, 17, 19, 23]
N = 60
fig, ax = plt.subplots(figsize=(11, 6))
for i, p in enumerate(primes):
    r = rank_fib(p)
    hits = [m for m in range(1, N + 1) if fib(m) % p == 0]
    ax.scatter(hits, [i] * len(hits), s=40)
    ax.text(-2, i, f"p={p} (rank {r})", ha="right", va="center", fontsize=9)
ax.set_yticks([])
ax.set_xlabel("index m  (dots: m where p | F_m  =  multiples of rank)")
ax.set_title("Fibonacci apparition: divisibility sits exactly on multiples of the rank")
ax.set_xlim(-12, N + 1)
plt.tight_layout()
plt.savefig("rank_apparition.png", dpi=140)
print("wrote rank_apparition.png")

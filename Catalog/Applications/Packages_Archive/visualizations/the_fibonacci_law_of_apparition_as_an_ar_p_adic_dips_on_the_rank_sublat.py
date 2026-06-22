"""Visualization: the p-adic size of Fibonacci numbers dips on the rank sublattice.

Plots |F(n)|_p against n for several primes p, overlaying vertical guides at the
multiples of the rank of apparition z(p). The dips occur exactly at multiples of
z(p), the visual signature of the capstone theorem |F(n)|_p < 1 <=> z(p) | n.
Requires matplotlib.
"""
import matplotlib.pyplot as plt

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def fib_rank(m: int) -> int:
    if m == 1:
        return 1
    a, b = 0 % m, 1 % m
    k = 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k

def v_p(p: int, x: int) -> int:
    if x == 0:
        return 99
    v = 0
    while x % p == 0:
        x //= p; v += 1
    return v

def main() -> None:
    primes = [2, 3, 5, 7]
    N = 40
    fig, axes = plt.subplots(len(primes), 1, figsize=(10, 9), sharex=True)
    for ax, p in zip(axes, primes):
        z = fib_rank(p)
        ns = list(range(1, N + 1))
        norms = [float(p) ** (-v_p(p, fib(n))) if fib(n) != 0 else 0.0 for n in ns]
        ax.stem(ns, norms, basefmt=" ")
        for k in range(z, N + 1, z):
            ax.axvline(k, color="crimson", ls="--", alpha=0.4)
        ax.set_ylabel(f"|F(n)|_{p}")
        ax.set_title(f"p = {p},  rank z(p) = {z}  (dips at multiples of {z})")
    axes[-1].set_xlabel("index n")
    fig.suptitle("p-adic size of Fibonacci numbers dips exactly on the rank sublattice")
    fig.tight_layout()
    fig.savefig("fibonacci_padic_dips.png", dpi=150)
    print("saved fibonacci_padic_dips.png")

if __name__ == "__main__":
    main()

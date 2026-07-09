"""Visualization: SYZ torus Betti vectors (Pascal's triangle) and even/odd balance.

Draws the palindromic Betti vectors b_k(T^n) = C(n,k) as bars for several n and a
companion chart of even-degree vs odd-degree sums, illustrating eulerTorus_eq_zero
and evenBetti_eq_oddBetti. Requires matplotlib.
"""
import matplotlib.pyplot as plt
from math import comb

def main(max_n: int = 8) -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
    for n in range(1, max_n + 1):
        betti = [comb(n, k) for k in range(n + 1)]
        ax1.plot(range(n + 1), betti, marker="o", label=f"T^{n}")
    ax1.set_xlabel("degree k")
    ax1.set_ylabel("b_k = C(n, k)")
    ax1.set_title("Palindromic Betti vectors (T-duality: k <-> n-k)")
    ax1.legend(fontsize=8)

    ns = list(range(1, max_n + 1))
    even = [sum(comb(n, k) for k in range(n + 1) if k % 2 == 0) for n in ns]
    odd = [sum(comb(n, k) for k in range(n + 1) if k % 2 == 1) for n in ns]
    width = 0.4
    ax2.bar([n - width / 2 for n in ns], even, width, label="even sum", color="#2a9d8f")
    ax2.bar([n + width / 2 for n in ns], odd, width, label="odd sum", color="#e9c46a")
    ax2.plot(ns, [2 ** (n - 1) for n in ns], "k--", label="2^(n-1)")
    ax2.set_xlabel("torus dimension n")
    ax2.set_ylabel("Betti sum")
    ax2.set_title("Even = Odd = 2^(n-1)  =>  chi(T^n) = 0")
    ax2.legend()
    plt.tight_layout()
    plt.savefig("betti_balance.png", dpi=140)
    print("wrote betti_balance.png")

if __name__ == "__main__":
    main()

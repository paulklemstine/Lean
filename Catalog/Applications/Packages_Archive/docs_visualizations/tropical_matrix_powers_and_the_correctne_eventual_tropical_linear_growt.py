"""Visualize the eventual tropical-linear growth of A^{(X)m}.

Plots the minimum entry of successive tropical powers against m and
overlays the line predicted by the minimum cycle mean, showing why the
tropical discrete logarithm leaks the exponent.
"""
from typing import List
import matplotlib.pyplot as plt
import random

Matrix = List[List[float]]

def trop_mat_mul(A: Matrix, B: Matrix) -> Matrix:
    n = len(A)
    return [[min(A[i][k] + B[k][j] for k in range(n)) for j in range(n)]
            for i in range(n)]

def main() -> None:
    random.seed(7)
    n = 6
    A = [[round(random.uniform(0.5, 4.0), 2) for _ in range(n)] for _ in range(n)]
    ms = list(range(1, 25))
    mins = []
    P = [row[:] for row in A]
    for _ in ms:
        mins.append(min(min(row) for row in P))
        P = trop_mat_mul(A, P)
    # slope between consecutive points approximates the cycle mean
    slope = (mins[-1] - mins[len(mins)//2]) / (ms[-1] - ms[len(ms)//2])
    line = [mins[0] + slope * (m - ms[0]) for m in ms]
    plt.figure(figsize=(8, 5))
    plt.plot(ms, mins, "o-", label="min entry of A^{(X)m}")
    plt.plot(ms, line, "--", label=f"cycle-mean trend (slope={slope:.3f})")
    plt.xlabel("exponent m")
    plt.ylabel("minimum entry")
    plt.title("Tropical powers grow linearly: the discrete log leaks")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("tropical_growth.png", dpi=150)
    print("saved tropical_growth.png")

if __name__ == "__main__":
    main()

import numpy as np
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def main() -> None:
    max_m, max_n = 16, 40
    grid = np.zeros((max_m, max_n), dtype=float)
    fibs = [fib(n) for n in range(max_n + 1)]
    for m in range(1, max_m + 1):
        for n in range(1, max_n + 1):
            grid[m - 1, n - 1] = 1.0 if fibs[n] % m == 0 else 0.0
    plt.figure(figsize=(12, 6))
    plt.imshow(grid, aspect="auto", cmap="viridis", origin="lower",
               extent=[1, max_n, 1, max_m])
    plt.xlabel("index n")
    plt.ylabel("modulus m")
    plt.title("m | F(n): periodic appearance combs (period = rank of apparition)")
    plt.colorbar(label="m divides F(n)")
    plt.tight_layout()
    plt.savefig("appearance_lattice.png", dpi=150)
    print("Saved appearance_lattice.png")


if __name__ == "__main__":
    main()

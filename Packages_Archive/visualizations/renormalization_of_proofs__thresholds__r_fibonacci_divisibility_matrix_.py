import matplotlib.pyplot as plt
import numpy as np


def fib(k: int) -> int:
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a


def visualize(upper: int = 20) -> None:
    M = np.zeros((upper, upper))
    for i, m in enumerate(range(1, upper + 1)):
        fm = fib(m)
        for j, n in enumerate(range(1, upper + 1)):
            value = (fib(n) % fm == 0) if fm else (fib(n) == 0)
            index = (n % m == 0)
            M[i, j] = 2 if (value and index) else (1 if value else 0)
    plt.figure(figsize=(7, 6))
    plt.imshow(M, origin="lower", cmap="viridis",
               extent=[1, upper, 1, upper])
    plt.axhline(2.5, color="red", lw=2, label="phase boundary m = 3")
    plt.colorbar(label="0:neither 1:value-only 2:value&index")
    plt.xlabel("n"); plt.ylabel("m")
    plt.title("F_m | F_n vs m | n  (rows m=1,2 are all value-only)")
    plt.legend()
    plt.tight_layout()
    plt.savefig("fibonacci_rigidity.png", dpi=130)
    print("saved fibonacci_rigidity.png")


if __name__ == "__main__":
    visualize(20)

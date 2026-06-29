"""Visualize the Ackermann encoding: a bit-matrix of which m belongs to which n."""
import matplotlib.pyplot as plt
import numpy as np


def ack_mem(m: int, n: int) -> bool:
    return (n >> m) & 1 == 1


def main() -> None:
    N = 32
    M = 6
    grid = np.array([[1 if ack_mem(m, n) else 0 for m in range(M)] for n in range(N)])
    plt.figure(figsize=(5, 9))
    plt.imshow(grid, aspect="auto", cmap="Greys", interpolation="nearest")
    plt.xlabel("element m")
    plt.ylabel("set n (as a natural number)")
    plt.title("Ackermann membership  m in_a n  (black = member)")
    plt.xticks(range(M))
    plt.yticks(range(0, N, 2))
    plt.colorbar(label="bit value")
    plt.tight_layout()
    plt.savefig("ackermann_membership.png", dpi=150)
    print("wrote ackermann_membership.png")


if __name__ == "__main__":
    main()

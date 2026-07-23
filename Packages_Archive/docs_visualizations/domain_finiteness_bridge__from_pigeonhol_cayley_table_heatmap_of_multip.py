import numpy as np
import matplotlib.pyplot as plt

def plot_multiplication_table(n: int) -> None:
    table = np.array([[(i * j) % n for j in range(n)] for i in range(n)])
    fig, ax = plt.subplots(figsize=(6, 5))
    im = ax.imshow(table, cmap="viridis")
    ax.set_title(f"Multiplication table mod {n}")
    ax.set_xlabel("j"); ax.set_ylabel("i")
    fig.colorbar(im, ax=ax, label="(i*j) mod n")
    for i in range(n):
        for j in range(n):
            ax.text(j, i, table[i, j], ha="center", va="center",
                    color="white", fontsize=7)
    plt.tight_layout()
    plt.savefig(f"mult_table_mod_{n}.png", dpi=150)
    print(f"saved mult_table_mod_{n}.png")

if __name__ == "__main__":
    plot_multiplication_table(7)   # prime: Latin-square units block
    plot_multiplication_table(8)   # composite: zero divisors visible

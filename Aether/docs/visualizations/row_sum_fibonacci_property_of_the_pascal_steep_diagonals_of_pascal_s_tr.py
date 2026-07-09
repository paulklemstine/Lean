"""Visualization: the steep diagonals of Pascal's triangle whose sums are
odd-indexed Fibonacci numbers. Renders Pascal's triangle and highlights the
entries C(n+k, 2k) summed in each row of the Riordan array."""
from math import comb
import matplotlib.pyplot as plt

def make_figure(rows: int = 9, out: str = "riordan_diagonals.png") -> None:
    fig, ax = plt.subplots(figsize=(11, 7))
    # Plot Pascal's triangle entries C(r, c).
    for r in range(2 * rows):
        for c in range(r + 1):
            x = c - r / 2.0
            y = -r
            ax.text(x, y, str(comb(r, c)), ha="center", va="center",
                    fontsize=8, color="0.6")
    # Highlight the Riordan row sums A(n) = sum_k C(n+k, 2k) = F_{2n+1}.
    colors = plt.cm.viridis
    for n in range(rows):
        total = 0
        for k in range(n + 1):
            r, c = n + k, 2 * k        # entry C(n+k, 2k) lives at (row=n+k, col=2k)
            total += comb(r, c)
            x = c - r / 2.0
            y = -r
            ax.scatter([x], [y], s=260, color=colors(n / rows), alpha=0.45, zorder=0)
        ax.text(rows / 2 + 1.5, -2 * n, f"A({n}) = {total} = F_{2*n+1}",
                fontsize=10, va="center")
    ax.set_title("Steep diagonals C(n+k, 2k) of Pascal's triangle sum to F(2n+1)")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig(out, dpi=150)
    print(f"wrote {out}")

if __name__ == "__main__":
    make_figure()

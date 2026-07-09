"""Visualize the rank profiles of the Boolean lattices B_{n+1} as
overlaid Pascal-triangle rows, highlighting the width (max) and the
tropical dual (min)."""
from math import comb
import matplotlib.pyplot as plt

def main() -> None:
    fig, ax = plt.subplots(figsize=(9, 6))
    for n in range(1, 9):
        m = n + 1
        profile = [comb(m, k) for k in range(m + 1)]
        xs = [k / m for k in range(m + 1)]  # normalized rank
        ax.plot(xs, profile, marker="o", label=f"B_{m}")
        kmax = m // 2
        ax.scatter([kmax / m], [comb(m, kmax)], color="red", zorder=5)
    ax.set_yscale("log")
    ax.set_xlabel("normalized rank k/(n+1)")
    ax.set_ylabel("layer size C(n+1, k)  (log scale)")
    ax.set_title("Rank profiles of B_{n+1}: width (red) vs tropical min (=1)")
    ax.legend(ncol=2, fontsize=8)
    ax.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig("rank_profiles.png", dpi=150)
    print("saved rank_profiles.png")

if __name__ == "__main__":
    main()

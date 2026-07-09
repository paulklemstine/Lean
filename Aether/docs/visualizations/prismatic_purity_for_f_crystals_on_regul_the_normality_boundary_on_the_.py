"""Visualization: the normality boundary on the Gaussian-integer lattice.
Plots which a+bi lie in the NON-normal order Z[2i] vs its normalization Z[i],
and highlights i = (0,1) as the integral element that fails to extend in Z[2i]."""
import matplotlib.pyplot as plt


def in_Z2i(a: int, b: int) -> bool:
    return b % 2 == 0  # coefficient of i must be even


def main() -> None:
    rng = range(-4, 5)
    zi_x, zi_y, z2i_x, z2i_y = [], [], [], []
    for a in rng:
        for b in rng:
            zi_x.append(a); zi_y.append(b)
            if in_Z2i(a, b):
                z2i_x.append(a); z2i_y.append(b)
    fig, ax = plt.subplots(figsize=(6, 6))
    ax.scatter(zi_x, zi_y, s=30, c="lightgray", label="Z[i] (normal: purity holds)")
    ax.scatter(z2i_x, z2i_y, s=60, c="steelblue", label="Z[2i] (non-normal)")
    ax.scatter([0], [1], s=200, marker="*", c="crimson",
               label="i: integral (x^2+1=0) but NOT in Z[2i]")
    ax.axhline(0, color="k", lw=0.5); ax.axvline(0, color="k", lw=0.5)
    ax.set_xlabel("Re"); ax.set_ylabel("Im")
    ax.set_title("Normality boundary: where Hartogs extension fails")
    ax.legend(loc="upper left", fontsize=8)
    ax.set_aspect("equal")
    plt.tight_layout()
    plt.savefig("normality_boundary.png", dpi=150)
    print("wrote normality_boundary.png")


if __name__ == "__main__":
    main()

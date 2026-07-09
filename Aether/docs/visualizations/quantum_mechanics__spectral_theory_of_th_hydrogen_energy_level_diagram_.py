import matplotlib.pyplot as plt


def bohr_energy(n: int) -> float:
    return -1.0 / (n * n)


def main() -> None:
    n_max = 7
    fig, ax = plt.subplots(figsize=(7, 6))
    for n in range(1, n_max + 1):
        e = bohr_energy(n)
        ax.hlines(e, 0, 1, color="black")
        ax.text(1.02, e, f"n={n}", va="center")
    ax.hlines(0, 0, 1, color="red", linestyles="dashed")
    ax.text(1.02, 0, "ionization (E=0)", va="center", color="red")
    colors = {1: "purple", 2: "green", 3: "orange"}
    for m, x in zip((1, 2, 3), (0.2, 0.5, 0.8)):
        for n in range(m + 1, n_max + 1):
            ax.annotate(
                "", xy=(x, bohr_energy(m)), xytext=(x, bohr_energy(n)),
                arrowprops=dict(arrowstyle="->", color=colors[m]))
    ax.set_ylabel("Energy (Rydberg units)")
    ax.set_title("Hydrogen energy levels and emission series")
    ax.set_xticks([])
    plt.tight_layout()
    plt.savefig("hydrogen_levels.png", dpi=150)
    print("wrote hydrogen_levels.png")


if __name__ == "__main__":
    main()

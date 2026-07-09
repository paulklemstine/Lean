import matplotlib.pyplot as plt

def plot_heights() -> None:
    rings = ["field k", "k[x]", "k[x_0..x_3]", "Z_p",
             "Z^N", "k[x_0,x_1,..]", "alg. integers"]
    # 0 for Noetherian; use a tall capped bar to depict "infinite"
    heights = [0, 0, 0, 0, 10, 10, 10]
    colors = ["#4c9f70" if h == 0 else "#b22222" for h in heights]
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.bar(rings, heights, color=colors)
    for i, h in enumerate(heights):
        ax.text(i, h + 0.2, "0" if h == 0 else "infinite", ha="center")
    ax.set_ylabel("Escher height")
    ax.set_title("Escher height: 0 (Noetherian) vs infinite (non-Noetherian)")
    ax.set_yticks([])
    plt.xticks(rotation=25, ha="right")
    plt.tight_layout()
    plt.savefig("escher_heights.png", dpi=150)

if __name__ == "__main__":
    plot_heights()

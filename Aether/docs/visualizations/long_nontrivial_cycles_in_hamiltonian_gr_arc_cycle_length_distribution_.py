import matplotlib.pyplot as plt

def visualize_length_distribution(n: int = 40) -> None:
    lengths = []
    for a in range(n):
        for b in range(n):
            if a == b or b == (a + 1) % n or a == (b + 1) % n:
                continue
            lf, lb = ((b - a) % n) + 1, ((a - b) % n) + 1
            lengths.append(max(lf, lb))
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.hist(lengths, bins=range(n // 2, n + 2), color="tab:blue",
            edgecolor="black", align="left")
    ax.axvline(n // 2 + 1, color="tab:red", ls="--",
               label=f"n//2 + 1 = {n // 2 + 1}")
    ax.set_xlabel("longer arc-cycle length"); ax.set_ylabel("count")
    ax.set_title(f"Longer arc-cycle length over all chords (n = {n})")
    ax.legend(); plt.tight_layout()
    plt.savefig("length_distribution.png", dpi=150)

if __name__ == "__main__":
    visualize_length_distribution()

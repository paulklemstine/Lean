"""Visualize set-local bi-Lipschitz invariance and Hölder distortion.
Generates a figure comparing the Cantor set with its images under a
bi-Lipschitz map (dimension preserved) and a Hölder map (dimension squeezed).
Requires matplotlib; saves to fractal_distortion.png."""
import math
import matplotlib.pyplot as plt


def cantor(depth: int) -> list[float]:
    ivs = [(0.0, 1.0)]
    for _ in range(depth):
        nxt = []
        for a, b in ivs:
            t = (b - a) / 3.0
            nxt += [(a, a + t), (b - t, b)]
        ivs = nxt
    pts = []
    for a, b in ivs:
        pts += [a, b]
    return sorted(set(pts))


def main() -> None:
    s = cantor(7)
    bilip = [2.0 * x + 0.5 for x in s]          # similarity: preserves dimension
    holder = [x ** (1.0 / 0.5) for x in s]      # Hölder r=0.5: changes dimension

    fig, axes = plt.subplots(3, 1, figsize=(9, 4), sharex=False)
    for ax, data, title in zip(
        axes,
        [s, bilip, holder],
        ["Cantor set  (dimH = log2/log3 ≈ 0.631)",
         "bi-Lipschitz image x↦2x+0.5  (dimH preserved)",
         "Hölder image x↦x^2  (dimH squeezed, bound dimH/r)"],
    ):
        ax.scatter(data, [0] * len(data), s=4, c="k")
        ax.set_title(title, fontsize=9)
        ax.set_yticks([])
    plt.tight_layout()
    plt.savefig("fractal_distortion.png", dpi=150)
    print("saved fractal_distortion.png")


if __name__ == "__main__":
    main()

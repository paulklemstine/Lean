"""Visualization: the Calabi-Yau Hodge plot and its mirror symmetry.

Plots admissible Hodge diamonds (h11, h21) in the (chi, h11+h21) plane and
overlays the swap-symmetric Euler-number histogram, illustrating countEuler_neg.
Requires matplotlib.
"""
import matplotlib.pyplot as plt

def euler(h11: int, h21: int) -> int:
    return 2 * (h11 - h21)

def main(bound: int = 20) -> None:
    xs, ys = [], []
    for h11 in range(bound + 1):
        for h21 in range(bound + 1):
            xs.append(euler(h11, h21))
            ys.append(h11 + h21)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
    ax1.scatter(xs, ys, s=6, alpha=0.4, color="#2a6f97")
    ax1.axvline(0, color="crimson", lw=1, ls="--", label="self-mirror chi=0")
    ax1.set_xlabel("Euler number  chi = 2(h11 - h21)")
    ax1.set_ylabel("h11 + h21  (mirror invariant)")
    ax1.set_title("Hodge plot (symmetric about chi = 0)")
    ax1.legend()

    hist = {}
    for e in range(-2 * bound, 2 * bound + 1, 2):
        hist[e] = sum(1 for a in range(bound + 1) for b in range(bound + 1)
                      if 2 * (a - b) == e)
    es = sorted(hist)
    ax2.bar(es, [hist[e] for e in es], width=1.6, color="#e07a5f")
    ax2.axvline(0, color="black", lw=1)
    ax2.set_xlabel("Euler number e")
    ax2.set_ylabel("countEuler(e, B)")
    ax2.set_title("Euler histogram: countEuler(e)=countEuler(-e)")
    plt.tight_layout()
    plt.savefig("hodge_plot.png", dpi=140)
    print("wrote hodge_plot.png")

if __name__ == "__main__":
    main()

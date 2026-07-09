"""Visualization: descending dyadic chain (2^n) in Z and its 2-adic drop-out."""
import matplotlib.pyplot as plt


def v2(m: int) -> int:
    k = 0
    while m % 2 == 0:
        m //= 2
        k += 1
    return k


def main() -> None:
    samples = [1, 3, 6, 12, 40, 96, 128]
    fig, ax = plt.subplots(figsize=(8, 5))
    for m in samples:
        drop = v2(m) + 1
        ax.plot(range(drop + 1), [1] * (drop) + [0], marker="o", label=f"m={m} (drops at n={drop})")
    ax.set_xlabel("rung index n of (2^n)")
    ax.set_ylabel("m in (2^n)?  (1=yes, 0=no)")
    ax.set_title("Descending mirror: each nonzero m survives finitely many rungs; meet={0}")
    ax.legend(fontsize=8)
    fig.tight_layout()
    fig.savefig("dyadic_mirror.png", dpi=150)
    print("wrote dyadic_mirror.png")


if __name__ == "__main__":
    main()

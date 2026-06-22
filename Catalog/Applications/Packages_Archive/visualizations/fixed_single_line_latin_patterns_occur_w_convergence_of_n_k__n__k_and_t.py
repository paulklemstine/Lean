"""Visualization: convergence n^k/(n)_k -> 1 and the intercalate anomaly."""
import matplotlib.pyplot as plt


def desc_factorial(n: int, k: int) -> int:
    result: int = 1
    for i in range(k):
        result *= (n - i)
    return result


def main() -> None:
    ns = list(range(2, 60))
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    for k in (1, 2, 3, 5):
        ys = [n ** k / desc_factorial(n, k) for n in ns if n >= k]
        xs = [n for n in ns if n >= k]
        ax1.plot(xs, ys, marker="o", ms=3, label=f"k={k}")
    ax1.axhline(1.0, color="black", ls="--", lw=1)
    ax1.set_title(r"singleRow_pattern_density: $n^k/(n)_k \to 1$")
    ax1.set_xlabel("n")
    ax1.set_ylabel(r"$n^k/(n)_k = \Pr[L\supseteq P]\cdot n^k$")
    ax1.legend()
    ax1.grid(alpha=0.3)

    # Single-line constant 1 vs intercalate constant 1/4.
    ax2.axhline(1.0, color="C0", lw=2, label="single-line pattern (constant 1)")
    ax2.axhline(0.25, color="C3", lw=2, label="intercalate (constant 1/4)")
    ax2.set_ylim(0, 1.2)
    ax2.set_title(r"Leading constant of $\Pr\cdot n^{e(P)}$")
    ax2.set_xlabel("n (schematic)")
    ax2.set_ylabel("limiting constant")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("latin_pattern_density.png", dpi=150)
    print("wrote latin_pattern_density.png")


if __name__ == "__main__":
    main()

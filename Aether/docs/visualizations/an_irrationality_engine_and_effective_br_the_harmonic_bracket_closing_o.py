"""Visualize the harmonic bracket closing around gamma and the Theta(1/n) rate.
Requires matplotlib. Saves euler_mascheroni_bracket.png."""
from math import log
import matplotlib.pyplot as plt

GAMMA = 0.5772156649015329


def harmonic(n: int) -> float:
    return sum(1.0 / k for k in range(1, n + 1))


def main() -> None:
    ns = list(range(1, 60))
    lo = [harmonic(n) - log(n + 1) for n in ns]
    hi = [harmonic(n) - log(n) for n in ns]
    width = [log(n + 1) - log(n) for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.fill_between(ns, lo, hi, alpha=0.3, color="tab:blue", label="bracket [s_n, s'_n]")
    ax1.plot(ns, lo, color="tab:blue", lw=1, label="s_n = H_n - ln(n+1)")
    ax1.plot(ns, hi, color="tab:green", lw=1, label="s'_n = H_n - ln n")
    ax1.axhline(GAMMA, color="crimson", ls="--", label=f"gamma = {GAMMA:.6f}")
    ax1.set_xlabel("n"); ax1.set_ylabel("value")
    ax1.set_title("Harmonic bracket closing on gamma")
    ax1.legend(fontsize=8)

    ax2.loglog(ns, width, "o-", ms=3, color="tab:purple", label="width = ln(1+1/n)")
    ax2.loglog(ns, [1.0 / n for n in ns], "--", color="gray", label="1/n reference")
    ax2.set_xlabel("n"); ax2.set_ylabel("bracket width")
    ax2.set_title("Sub-geometric Theta(1/n) convergence")
    ax2.legend(fontsize=8)

    fig.tight_layout()
    fig.savefig("euler_mascheroni_bracket.png", dpi=150)
    print("saved euler_mascheroni_bracket.png")


if __name__ == "__main__":
    main()

"""Visualise geometric decay of soundness error across rounds."""
import matplotlib.pyplot as plt


def plot_survival_decay() -> None:
    ks = list(range(0, 61))
    for n in (2, 5, 10, 50):
        base = (n - 1) / n
        ys = [base ** k for k in ks]
        plt.plot(ks, ys, label=f"|Omega| = {n}")
    plt.axhline(2 ** -10, color="gray", ls="--", lw=0.8, label="error 2^-10")
    plt.xlabel("number of independent rounds k")
    plt.ylabel("survival probability bound ((|O|-1)/|O|)^k")
    plt.title("Multi-Round Soundness Amplification: geometric decay")
    plt.yscale("log")
    plt.legend()
    plt.tight_layout()
    plt.savefig("soundness_decay.png", dpi=150)


if __name__ == "__main__":
    plot_survival_decay()

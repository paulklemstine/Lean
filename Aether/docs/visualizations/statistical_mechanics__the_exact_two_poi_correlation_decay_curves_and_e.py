import math
import matplotlib.pyplot as plt

def correlation(beta: float, J: float, n: int) -> float:
    return math.tanh(beta * J) ** n

def main() -> None:
    J = 1.0
    ns = list(range(0, 31))
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    for beta in [0.3, 0.5, 0.7, 1.0, 1.5]:
        ys = [correlation(beta, J, n) for n in ns]
        ax1.plot(ns, ys, marker="o", ms=3, label=f"beta={beta}")
        ax2.semilogy(ns, ys, marker="o", ms=3, label=f"beta={beta}")
    ax1.set(title="1D Ising correlation  <s0 sn> = (tanh bJ)^n",
            xlabel="separation n", ylabel="<s0 sn>")
    ax2.set(title="Exponential decay (log scale): slope = -spectral gap",
            xlabel="separation n", ylabel="<s0 sn> (log)")
    for ax in (ax1, ax2):
        ax.legend(); ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("ising_correlation_decay.png", dpi=150)
    print("saved ising_correlation_decay.png")

if __name__ == "__main__":
    main()

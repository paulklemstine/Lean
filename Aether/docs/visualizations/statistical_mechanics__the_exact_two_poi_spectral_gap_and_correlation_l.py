import math
import matplotlib.pyplot as plt

def spectral_gap(beta: float, J: float) -> float:
    bj = beta * J
    return math.log(math.cosh(bj)) - math.log(math.sinh(bj))

def main() -> None:
    J = 1.0
    betas = [b / 100.0 for b in range(20, 400)]
    gaps = [spectral_gap(b, J) for b in betas]
    xis = [1.0 / g for g in gaps]
    approx = [0.5 * math.exp(2 * b * J) for b in betas]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.plot(betas, gaps)
    ax1.set(title="Spectral gap g = log coth(bJ) > 0 (gap closes as b -> inf)",
            xlabel="beta", ylabel="g")
    ax2.semilogy(betas, xis, label="xi = 1/g (exact)")
    ax2.semilogy(betas, approx, "--", label="0.5 e^(2bJ) (low-T)")
    ax2.set(title="Correlation length diverges as T -> 0",
            xlabel="beta", ylabel="xi (log)")
    ax2.legend()
    for ax in (ax1, ax2):
        ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("ising_correlation_length.png", dpi=150)
    print("saved ising_correlation_length.png")

if __name__ == "__main__":
    main()

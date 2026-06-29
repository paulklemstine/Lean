import matplotlib.pyplot as plt

def error_rate(c: float, p: float, n: int) -> float:
    x = p
    for _ in range(n):
        x = c * x * x
    return x

def main() -> None:
    c = 100.0          # surface-code malignant-pair count -> p_th = 1%
    levels = list(range(8))
    for p, label in [(0.005, "p=0.5%% (below)"),
                     (0.010, "p=1.0%% (at threshold)"),
                     (0.012, "p=1.2%% (above)")]:
        ys = [max(error_rate(c, p, n), 1e-300) for n in levels]
        plt.semilogy(levels, ys, marker="o", label=label)
    plt.axhline(1.0 / c, ls="--", color="gray", label="fixed point 1/c")
    plt.xlabel("concatenation level n")
    plt.ylabel("logical error rate p_n (log scale)")
    plt.title("Fault-tolerance threshold trichotomy (c = 100, p_th = 1%%)")
    plt.legend()
    plt.tight_layout()
    plt.savefig("threshold_trichotomy.png", dpi=150)
    print("wrote threshold_trichotomy.png")

if __name__ == "__main__":
    main()

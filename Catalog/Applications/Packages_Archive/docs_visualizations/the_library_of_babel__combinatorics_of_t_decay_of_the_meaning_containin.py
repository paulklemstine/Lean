"""Visualize how the meaningful-text probability (L-k+1)*b**(-k) decays with
pattern length k, for the Library of Babel (b=25). Requires matplotlib."""
import math
import matplotlib.pyplot as plt

def log10_contains_bound(b: int, length: int, k: int) -> float:
    # log10[(L-k+1) * b**(-k)]
    return math.log10(length - k + 1) - k * math.log10(b)

def main() -> None:
    b, L = 25, 1_312_000
    ks = list(range(1, 401))
    upper = [log10_contains_bound(b, L, k) for k in ks]
    lower = [-k * math.log10(b) for k in ks]  # single-window b**(-k)
    plt.figure(figsize=(9, 5.5))
    plt.fill_between(ks, lower, upper, color="#7aa6ff", alpha=0.35,
                     label="two-sided band")
    plt.plot(ks, upper, color="#16348c", lw=2,
             label=r"upper bound $(L-k+1)\,b^{-k}$")
    plt.plot(ks, lower, color="#8c1616", lw=2,
             label=r"lower bound $b^{-k}$")
    plt.xlabel("pattern length k")
    plt.ylabel(r"$\log_{10}$ probability of containing the pattern")
    plt.title("Library of Babel (b=25, L=1,312,000): meaning is present but rare")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("babel_probability.png", dpi=150)
    print("wrote babel_probability.png")

if __name__ == "__main__":
    main()

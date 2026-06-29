"""Visualize expected fragment occurrences vs pattern length in Borges' library."""
import math
import matplotlib.pyplot as plt

def expected_occurrences(b: int, L: int, k: int) -> float:
    """Theorem 3 in floating point: (L-k+1) * b^-k."""
    return (L - k + 1) * math.pow(b, -k)

def main() -> None:
    b, L = 25, 1_312_000
    ks = list(range(1, 25))
    ys = [expected_occurrences(b, L, k) for k in ks]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(ks, ys, "o-", color="#7b2d8e")
    ax.axhline(1.0, color="grey", ls="--", lw=1, label="E = 1 threshold")
    # threshold k where E crosses 1: k* = log_b(L)
    k_star = math.log(L, b)
    ax.axvline(k_star, color="crimson", ls=":", lw=1,
               label=f"k* = log_b(L) = {k_star:.2f}")
    ax.set_xlabel("pattern length k")
    ax.set_ylabel("expected occurrences  (L-k+1)*25^-k")
    ax.set_title("Library of Babel: expected fragment occurrences vs length\n"
                 "(b = 25, L = 1,312,000)")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("babel_expectation.png", dpi=150)
    print("wrote babel_expectation.png")

if __name__ == "__main__":
    main()

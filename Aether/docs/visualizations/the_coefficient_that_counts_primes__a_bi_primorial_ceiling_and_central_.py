"""Visualization: the primorial n# stays far below the 4^n ceiling,
and the central binomial coefficient sits between its proven bounds.
Generates two stacked log-scale plots. Requires matplotlib."""
from math import comb, sqrt, prod
import matplotlib.pyplot as plt


def is_prime(m: int) -> bool:
    if m < 2:
        return False
    d = 2
    while d * d <= m:
        if m % d == 0:
            return False
        d += 1
    return True


def primorial(n: int) -> int:
    return prod(p for p in range(2, n + 1) if is_prime(p))


def main() -> None:
    N = 40
    ns = list(range(1, N + 1))
    prim = [primorial(n) for n in ns]
    ceiling = [4 ** n for n in ns]

    cb_ns = list(range(1, 26))
    cb = [comb(2 * n, n) for n in cb_ns]
    lower = [4 ** n / (2 * n + 1) for n in cb_ns]
    upper = [4 ** n / sqrt(2 * n) for n in cb_ns]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(9, 9))

    ax1.semilogy(ns, ceiling, "r--", label=r"$4^n$ ceiling")
    ax1.semilogy(ns, prim, "bo-", label=r"primorial $n\#$")
    ax1.set_title("Chebyshev-type bound: primorial stays below $4^n$")
    ax1.set_xlabel("n"); ax1.set_ylabel("value (log scale)"); ax1.legend()
    ax1.grid(True, which="both", alpha=0.3)

    ax2.semilogy(cb_ns, upper, "r--", label=r"upper $4^n/\sqrt{2n}$")
    ax2.semilogy(cb_ns, cb, "go-", label=r"$\binom{2n}{n}$")
    ax2.semilogy(cb_ns, lower, "b--", label=r"lower $4^n/(2n+1)$")
    ax2.set_title("Central binomial coefficient between its bounds")
    ax2.set_xlabel("n"); ax2.set_ylabel("value (log scale)"); ax2.legend()
    ax2.grid(True, which="both", alpha=0.3)

    plt.tight_layout()
    plt.savefig("binomial_prime_bounds.png", dpi=150)
    print("Saved binomial_prime_bounds.png")


if __name__ == "__main__":
    main()

"""Plot the exponential sandwich 2^(k/2) < R(k,k) < 4^k against certified bounds."""
from math import comb
import matplotlib.pyplot as plt


def first_moment_lower_bound(k: int, r: int = 2) -> int:
    bound = 2 ** comb(k, r)
    n = k
    while 2 * comb(n + 1, k) < bound:
        n += 1
    return n


def main() -> None:
    ks = list(range(4, 21))
    lower_certified = [first_moment_lower_bound(k) for k in ks]
    lower_form = [2 ** (k / 2) for k in ks]
    upper_form = [comb(2 * k - 2, k - 1) for k in ks]  # binomial ceiling
    plt.figure(figsize=(8, 5))
    plt.semilogy(ks, lower_certified, "o-", label="certified first-moment lower bound")
    plt.semilogy(ks, lower_form, "--", label=r"$2^{k/2}$ heuristic")
    plt.semilogy(ks, upper_form, "s-", label=r"Erdos-Szekeres ceiling $\binom{2k-2}{k-1}$")
    plt.xlabel("k"); plt.ylabel("R(k,k) bounds (log scale)")
    plt.title("The exponential sandwich for diagonal Ramsey numbers")
    plt.legend(); plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout(); plt.savefig("ramsey_sandwich.png", dpi=150)
    print("saved ramsey_sandwich.png")


if __name__ == "__main__":
    main()

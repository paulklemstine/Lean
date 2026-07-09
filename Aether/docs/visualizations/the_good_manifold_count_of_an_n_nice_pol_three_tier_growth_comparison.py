"""Compare polynomial, exponential a(n), and factorial growth (log scale)."""
import matplotlib.pyplot as plt
from math import factorial

HEAD = {1: 6, 2: 8, 3: 12, 4: 24, 5: 40, 6: 80}


def good_count(n: int) -> int:
    return HEAD.get(n, 2 ** n)


def main() -> None:
    ns = list(range(1, 13))
    poly = [n ** 3 for n in ns]
    expo = [good_count(n) for n in ns]
    supr = [factorial(n) for n in ns]
    plt.figure(figsize=(8, 5))
    plt.semilogy(ns, poly, "^-", label="n^3 (polynomial)")
    plt.semilogy(ns, expo, "o-", label="a(n) ~ 2^n (exponential)")
    plt.semilogy(ns, supr, "s-", label="n! (super-exponential)")
    plt.xlabel("n"); plt.ylabel("value (log scale)")
    plt.title("Three growth tiers: a(n) sits between polynomial and factorial")
    plt.legend(); plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout(); plt.savefig("growth_tiers.png", dpi=150)
    print("saved growth_tiers.png")


if __name__ == "__main__":
    main()

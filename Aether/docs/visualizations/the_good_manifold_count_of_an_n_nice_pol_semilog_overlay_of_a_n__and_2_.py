"""Semilog plot: a(n) versus 2^n, highlighting the exceptional head."""
import matplotlib.pyplot as plt

HEAD = {1: 6, 2: 8, 3: 12, 4: 24, 5: 40, 6: 80}


def good_count(n: int) -> int:
    return HEAD.get(n, 2 ** n)


def main() -> None:
    ns = list(range(1, 16))
    a = [good_count(n) for n in ns]
    pw = [2 ** n for n in ns]
    plt.figure(figsize=(8, 5))
    plt.semilogy(ns, a, "o-", label="a(n)  good-manifold count")
    plt.semilogy(ns, pw, "s--", label="2^n")
    plt.axvspan(0.5, 6.5, color="orange", alpha=0.15, label="exceptional head")
    plt.axvline(6.5, color="gray", ls=":")
    plt.xlabel("n"); plt.ylabel("value (log scale)")
    plt.title("Good-manifold count: exceptional head, exponential tail")
    plt.legend(); plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout(); plt.savefig("good_count_semilog.png", dpi=150)
    print("saved good_count_semilog.png")


if __name__ == "__main__":
    main()

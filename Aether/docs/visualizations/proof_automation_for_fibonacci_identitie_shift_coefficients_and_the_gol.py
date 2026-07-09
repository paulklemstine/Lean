"""Visualize how single-base shift coefficients reproduce the Fibonacci numbers.

Each F_{n+k} = F_{k-1} F_n + F_k F_{n+1}. Plotting the coefficient pairs
(F_{k-1}, F_k) for k = 1, 2, 3, ... traces the Fibonacci spiral of slopes
converging to the golden ratio. Requires matplotlib."""
from functools import lru_cache
import matplotlib.pyplot as plt


@lru_cache(maxsize=None)
def fib(n: int) -> int:
    if n < 2:
        return n
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


def main() -> None:
    ks = list(range(1, 14))
    xs = [fib(k - 1) for k in ks]   # coefficient of F_n
    ys = [fib(k) for k in ks]       # coefficient of F_{n+1}
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))

    ax1.plot(xs, ys, "o-", color="#d2691e")
    for k, x, y in zip(ks, xs, ys):
        ax1.annotate(f"k={k}", (x, y), textcoords="offset points", xytext=(5, 4))
    ax1.set_title(r"Shift coefficients $(F_{k-1}, F_k)$ for $F_{n+k}$")
    ax1.set_xlabel(r"coefficient of $F_n$")
    ax1.set_ylabel(r"coefficient of $F_{n+1}$")
    ax1.grid(alpha=0.3)

    ratios = [fib(k) / fib(k - 1) for k in ks if fib(k - 1) > 0]
    ax2.axhline((1 + 5 ** 0.5) / 2, color="gray", ls="--", label="golden ratio")
    ax2.plot(range(len(ratios)), ratios, "s-", color="#1f77b4", label=r"$F_k/F_{k-1}$")
    ax2.set_title("Coefficient ratios converge to the golden ratio")
    ax2.set_xlabel("k")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("fibonacci_basis.png", dpi=150)
    print("Saved fibonacci_basis.png")


if __name__ == "__main__":
    main()

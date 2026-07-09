import matplotlib.pyplot as plt


def anti_fib(k: int) -> int:
    return (3 * k + 2) // 2


def main() -> None:
    ns = list(range(1, 40))
    anti_ratio = [anti_fib(n + 1) / anti_fib(n) for n in ns]

    fib = [1, 1]
    while len(fib) < 42:
        fib.append(fib[-1] + fib[-2])
    fib_ratio = [fib[n + 1] / fib[n] for n in ns]

    phi = (1 + 5 ** 0.5) / 2
    plt.figure(figsize=(9, 5))
    plt.plot(ns, anti_ratio, "o-", label="anti-Fibonacci  A(n+1)/A(n) -> 1")
    plt.plot(ns, fib_ratio, "s-", label="Fibonacci  F(n+1)/F(n) -> phi")
    plt.axhline(1.0, ls="--", c="gray")
    plt.axhline(phi, ls="--", c="gold", label=f"phi = {phi:.4f}")
    plt.xlabel("n")
    plt.ylabel("consecutive ratio")
    plt.title("Consecutive-term ratios: avoiding vs embracing the golden ratio")
    plt.legend()
    plt.tight_layout()
    plt.savefig("anti_fib_ratio.png", dpi=150)
    print("saved anti_fib_ratio.png")


if __name__ == "__main__":
    main()

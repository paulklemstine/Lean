import matplotlib.pyplot as plt


def anti_fib(k: int) -> int:
    return (3 * k + 2) // 2


def main() -> None:
    ns = list(range(0, 40))
    a = [anti_fib(n) for n in ns]
    lower = [(3 * n + 1) / 2 for n in ns]
    upper = [(3 * n + 2) / 2 for n in ns]

    plt.figure(figsize=(9, 5))
    plt.plot(ns, a, "o-", label="A(n) = floor((3n+2)/2)")
    plt.plot(ns, lower, "--", label="(3n+1)/2 lower bound")
    plt.plot(ns, upper, "--", label="(3n+2)/2 upper bound")
    plt.xlabel("n")
    plt.ylabel("A(n)")
    plt.title("Anti-Fibonacci linear growth, slope 3/2")
    plt.legend()
    plt.tight_layout()
    plt.savefig("anti_fib_growth.png", dpi=150)
    print("saved anti_fib_growth.png")


if __name__ == "__main__":
    main()

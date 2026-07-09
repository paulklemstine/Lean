import matplotlib.pyplot as plt


def anti_fib(k: int) -> int:
    return (3 * k + 2) // 2


def main() -> None:
    N = 60
    terms = set(m for m in range(1, N + 1) if m % 3 != 0)
    fig, ax = plt.subplots(figsize=(12, 2))
    for m in range(1, N + 1):
        is_term = m in terms
        ax.scatter(m, 0, s=120,
                   c="#2c7fb8" if is_term else "#e34a33",
                   marker="o" if is_term else "x")
    ax.set_yticks([])
    ax.set_xlabel("integer")
    ax.set_title("Anti-Fibonacci terms (blue, non-multiples of 3) "
                 "vs avoided values (red x, multiples of 3)")
    plt.tight_layout()
    plt.savefig("anti_fib_number_line.png", dpi=150)
    print("saved anti_fib_number_line.png")


if __name__ == "__main__":
    main()

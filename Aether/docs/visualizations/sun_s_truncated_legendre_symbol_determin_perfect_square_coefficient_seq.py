"""Plot the closed coefficient det(C+J) = floor((p-2)/3)^2 against primes p == 3 (mod 4)."""
import matplotlib.pyplot as plt


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def main(limit: int = 120) -> None:
    primes = [p for p in range(7, limit) if is_prime(p) and p % 4 == 3]
    coeffs = [((p - 2) // 3) ** 2 for p in primes]
    roots = [(p - 2) // 3 for p in primes]
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.plot(primes, coeffs, "o-", label="det(C+J) = floor((p-2)/3)^2")
    for x, y, r in zip(primes, coeffs, roots):
        ax.annotate(f"{r}^2", (x, y), textcoords="offset points", xytext=(0, 8),
                    ha="center", fontsize=8)
    ax.set_xlabel("prime p  (p == 3 mod 4)")
    ax.set_ylabel("linear coefficient of det A")
    ax.set_title("Sun's coefficient is a perfect (odd) square")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("sun_coefficients.png", dpi=150)
    print("wrote sun_coefficients.png")


if __name__ == "__main__":
    main()

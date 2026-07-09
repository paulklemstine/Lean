"""Bar chart of Pisano periods pi(m) of the Fibonacci sequence modulo m."""
import matplotlib.pyplot as plt


def pisano_period(m: int) -> int:
    a, b = 0, 1
    for p in range(1, 6 * m + 1):
        a, b = b, (a + b) % m
        if a == 0 and b == 1:
            return p
    raise RuntimeError("period not found")


def main() -> None:
    ms = list(range(2, 31))
    periods = [pisano_period(m) for m in ms]
    plt.figure(figsize=(11, 5))
    plt.bar(ms, periods, color="#2c7fb8")
    plt.xlabel("modulus m")
    plt.ylabel("Pisano period pi(m)")
    plt.title("Pisano periods: smallest p with F_p=0, F_(p+1)=1 (mod m)")
    plt.grid(axis="y", alpha=0.3)
    plt.tight_layout()
    plt.savefig("pisano_periods.png", dpi=150)
    print("wrote pisano_periods.png")


if __name__ == "__main__":
    main()

"""Visualization: Goldbach 'comet' - number of prime pairs per even n."""
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


def goldbach_count(n: int) -> int:
    return sum(1 for p in range(2, n // 2 + 1) if is_prime(p) and is_prime(n - p))


xs = list(range(4, 2001, 2))
ys = [goldbach_count(n) for n in xs]

plt.figure(figsize=(10, 5))
plt.scatter(xs, ys, s=4, alpha=0.5, color="#2b6cb0")
plt.title("Goldbach comet: number of prime-pair representations of even n")
plt.xlabel("even n")
plt.ylabel("# of pairs (p, q), p <= q, p + q = n")
plt.tight_layout()
plt.savefig("goldbach_comet.png", dpi=150)
print("saved goldbach_comet.png")

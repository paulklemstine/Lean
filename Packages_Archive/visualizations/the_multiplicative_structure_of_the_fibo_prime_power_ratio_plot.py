"""Plot the prime-power ratio alpha(p^2)/alpha(p) across primes.

The conjectured dichotomy says this ratio is 1 (Wall-Sun-Sun prime) or p.
No ratio of 1 has ever been observed; the plot shows the ratio sitting on
the line y = p for every tested prime.
"""
import matplotlib.pyplot as plt

def fib_entry(m: int) -> int:
    if m == 1: return 1
    a, b = 0, 1
    k = 0
    while True:
        k += 1
        a, b = b % m, (a + b) % m
        if a == 0:
            return k

def is_prime(n: int) -> bool:
    if n < 2: return False
    i = 2
    while i * i <= n:
        if n % i == 0: return False
        i += 1
    return True

primes = [p for p in range(2, 80) if is_prime(p)]
ratios = [fib_entry(p * p) // fib_entry(p) for p in primes]

fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(primes, primes, "--", color="gray", label="y = p (expected)")
ax.scatter(primes, ratios, color="crimson", zorder=3,
           label="alpha(p^2)/alpha(p)")
ax.set_xlabel("prime p")
ax.set_ylabel("alpha(p^2) / alpha(p)")
ax.set_title("Prime-power tower ratio (a ratio of 1 = Wall-Sun-Sun prime)")
ax.legend()
plt.tight_layout()
plt.savefig("prime_power_ratio.png", dpi=150)
print("wrote prime_power_ratio.png")

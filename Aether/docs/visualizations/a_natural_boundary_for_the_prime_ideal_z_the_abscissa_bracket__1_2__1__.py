"""Visualization: the abscissa bracket [1/2, 1] for the Gaussian prime-ideal zeta.

Plots truncated partial sums of P_{Q(i)}(s) at increasing cutoffs N, showing
stabilization for s > 1 (convergence ceiling) and growth for s <= 1/2
(divergence floor driven by inert primes). Requires matplotlib + numpy.
"""
import numpy as np
import matplotlib.pyplot as plt


def primes_up_to(n: int):
    sieve = np.ones(n + 1, dtype=bool)
    sieve[:2] = False
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = False
    return np.nonzero(sieve)[0]


def gauss_partial(s: float, primes) -> float:
    total = 0.0
    for p in primes:
        if p == 2:
            total += 2.0 ** (-s)
        elif p % 4 == 1:
            total += 2.0 * (p ** (-s))
        else:
            total += p ** (-2.0 * s)
    return total


cutoffs = [10, 100, 1000, 10000, 100000]
prime_lists = [primes_up_to(N) for N in cutoffs]
s_values = np.linspace(0.2, 2.0, 60)

plt.figure(figsize=(9, 6))
for N, pl in zip(cutoffs, prime_lists):
    ys = [gauss_partial(s, pl) for s in s_values]
    plt.plot(s_values, ys, label=f"p <= {N}")

plt.axvline(0.5, color="gray", ls="--", label="floor s = 1/2 (inert)")
plt.axvline(1.0, color="black", ls="--", label="ceiling s = 1 (split)")
plt.axvspan(0.5, 1.0, color="orange", alpha=0.12)
plt.yscale("log")
plt.xlabel("s")
plt.ylabel("partial sum of P_{Q(i)}(s)  (log scale)")
plt.title("Abscissa bracket [1/2, 1] of the Gaussian prime-ideal zeta")
plt.legend()
plt.tight_layout()
plt.savefig("abscissa_bracket.png", dpi=150)
print("saved abscissa_bracket.png")

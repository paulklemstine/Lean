"""Visualization: how the n! normalization makes binomial convolution
behave like ordinary multiplication. Plots the EGF coefficient triangle
and the agreement between egf(a*b) and egf(a).egf(b)."""
from fractions import Fraction
from math import comb, factorial
import matplotlib.pyplot as plt

N = 8
a = [Fraction(factorial(n)) for n in range(N)]   # linear orders
b = [Fraction(1) for _ in range(N)]              # sets

def egf(s): return [float(s[n] / factorial(n)) for n in range(len(s))]
def bin_conv(x, y):
    return [sum(comb(n, i) * x[i] * y[n - i] for i in range(n + 1))
            for n in range(min(len(x), len(y)))]
def cauchy(x, y):
    return [sum(x[i] * y[n - i] for i in range(n + 1))
            for n in range(min(len(x), len(y)))]

lhs = egf(bin_conv(a, b))
ra, rb = egf(a), egf(b)
rhs = cauchy(ra, rb)

fig, ax = plt.subplots(figsize=(9, 5))
xs = range(N)
ax.plot(xs, lhs, "o-", label="egf(a * b)  (binomial convolution)")
ax.plot(xs, rhs, "x--", label="egf(a) . egf(b)  (Cauchy product)")
ax.set_xlabel("coefficient index n")
ax.set_ylabel("coefficient value")
ax.set_title("The EGF turns binomial convolution into the Cauchy product")
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("egf_bridge.png", dpi=150)
print("saved egf_bridge.png")

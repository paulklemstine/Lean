import matplotlib.pyplot as plt
from math import gcd


def interior_row_gcd(k: int) -> int:
    g, c, n = 0, 1, k + 1
    for i in range(1, k + 1):
        c = c * (n - i + 1) // i
        g = gcd(g, c)
    return g


def is_prime_power(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            p = d
            break
        d += 1
    else:
        return True
    m = n
    while m % p == 0:
        m //= p
    return m == 1


KMAX = 120
ks = list(range(1, KMAX + 1))
vals = [interior_row_gcd(k) for k in ks]
colors = ["#d62728" if is_prime_power(k + 1) else "#1f77b4" for k in ks]

fig, ax = plt.subplots(figsize=(12, 5))
ax.bar(ks, vals, color=colors)
ax.set_xlabel("k")
ax.set_ylabel("F(k) = gcd of interior of row k+1")
ax.set_title("Interior Pascal-row gcd: red = k+1 is a prime power, blue = not")
ax.axhline(1, color="gray", lw=0.7, ls="--")
plt.tight_layout()
plt.savefig("interior_row_gcd.png", dpi=150)
print("wrote interior_row_gcd.png")

"""Visualization: certificate density in GL_n(F_q) versus the 1/n law."""
import matplotlib.pyplot as plt


def mobius(m: int) -> int:
    if m == 1:
        return 1
    res, mm, d = 1, m, 2
    while d * d <= mm:
        if mm % d == 0:
            mm //= d
            if mm % d == 0:
                return 0
            res = -res
        d += 1
    if mm > 1:
        res = -res
    return res


def count_irreducible(n: int, q: int) -> int:
    return sum(mobius(d) * q ** (n // d) for d in range(1, n + 1) if n % d == 0) // n


def gl_order(n: int, q: int) -> int:
    o = 1
    for i in range(n):
        o *= (q ** n - q ** i)
    return o


def density(n: int, q: int) -> float:
    return count_irreducible(n, q) * (gl_order(n, q) // (q ** n - 1)) / gl_order(n, q)


ns = list(range(2, 11))
plt.figure(figsize=(8, 5))
for q in (2, 3, 5, 7):
    plt.plot(ns, [density(n, q) for n in ns], "o-", label=f"q = {q}")
plt.plot(ns, [1.0 / n for n in ns], "k--", label="1/n reference")
plt.xlabel("dimension n")
plt.ylabel("fraction of GL_n(F_q) with irreducible charpoly")
plt.title("Certificate density tracks the 1/n law (Conjecture A)")
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("certificate_density.png", dpi=150)
print("saved certificate_density.png")

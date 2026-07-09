import matplotlib.pyplot as plt
from functools import reduce

def is_prime(p):
    return p >= 2 and all(p % d for d in range(2, int(p ** 0.5) + 1))

def D(n, bound=200):
    fac = [p for p in range(2, bound + 1) if is_prime(p) and (n - 1) % (p - 1) == 0]
    return reduce(lambda x, y: x * y, fac, 1)

ns = list(range(2, 21))
vals = [D(n) for n in ns]

fig, ax = plt.subplots(figsize=(9, 5))
ax.stem(ns, vals)
ax.set_yscale("log")
ax.set_xlabel("n")
ax.set_ylabel("D(n)  (universal denominator of a^n - a)")
ax.set_title("D(n) = product of primes p with (p-1) | (n-1)")
for n, v in zip(ns, vals):
    ax.text(n, v * 1.1, str(v), ha="center", fontsize=7)
plt.tight_layout()
plt.savefig("universal_denominator.png", dpi=150)
print("saved universal_denominator.png")

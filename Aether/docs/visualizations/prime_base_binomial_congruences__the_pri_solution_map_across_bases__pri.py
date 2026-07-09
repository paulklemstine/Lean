"""Scatter of solutions n of C(qn,n) == q^n (mod n) for several bases,
highlighting primes vs composites."""
import matplotlib.pyplot as plt
from math import comb

def is_prime(n):
    return n > 1 and all(n % i for i in range(2, int(n ** 0.5) + 1))

def congruent(q, n):
    return n == 1 or comb(q * n, n) % n == pow(q, n, n)

fig, ax = plt.subplots(figsize=(10, 5))
LIMIT = 80
for q in range(2, 6):
    sols = [n for n in range(2, LIMIT) if congruent(q, n)]
    pr = [n for n in sols if is_prime(n)]
    co = [n for n in sols if not is_prime(n)]
    ax.scatter(pr, [q] * len(pr), c="tab:blue", s=25)
    ax.scatter(co, [q] * len(co), c="tab:red", marker="s", s=45)
ax.set_xlabel("n"); ax.set_ylabel("base q")
ax.set_title("Solutions of C(qn,n) = q^n (mod n):  primes (blue) and composites (red)")
ax.set_yticks(range(2, 6))
plt.tight_layout(); plt.savefig("solutions_scatter.png", dpi=150)
print("wrote solutions_scatter.png")

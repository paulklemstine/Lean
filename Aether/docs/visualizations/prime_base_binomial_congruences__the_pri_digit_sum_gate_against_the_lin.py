"""Base-q digit sum s_q((q-1)p) across primes p, versus the linear gate (q-1)t."""
import matplotlib.pyplot as plt

def is_prime(n):
    return n > 1 and all(n % i for i in range(2, int(n ** 0.5) + 1))

def digit_sum(n, q):
    s = 0
    while n > 0:
        s += n % q; n //= q
    return s

q = 2
primes = [p for p in range(2, 2000) if is_prime(p)]
vals = [digit_sum((q - 1) * p, q) for p in primes]
fig, ax = plt.subplots(figsize=(9, 5))
ax.scatter(primes, vals, s=8, alpha=0.5, label="s_q((q-1)p)")
for t in (3, 6, 9):
    ax.axhline((q - 1) * t, ls="--", label=f"gate (q-1)t, t={t}")
ax.set_xlabel("prime p"); ax.set_ylabel("digit sum")
ax.set_title(f"Digit-sum gate for base q={q}: s_q((q-1)p) grows like log p")
ax.legend(); plt.tight_layout(); plt.savefig("digitsum_gate.png", dpi=150)
print("wrote digitsum_gate.png")

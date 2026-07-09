"""Visualization of S1phi(x) with certified witnesses and the GHP envelope shape."""
import math
import matplotlib.pyplot as plt

def totient(n: int) -> int:
    if n == 1:
        return 1
    r, m, p = n, n, 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            r -= r // p
        p += 1
    if m > 1:
        r -= r // m
    return r

X = 1000
xs = list(range(1, X + 1))
S = []
count = 0
for n in xs:
    if totient(n) == totient(n + 1):
        count += 1
    S.append(count)

witnesses = [n for n in xs if totient(n) == totient(n + 1)]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

ax1.step(xs, S, where="post", color="#1f77b4", lw=2, label=r"$S_1^{\varphi}(x)$")
ax1.scatter(witnesses, [S[w - 1] for w in witnesses], color="#d62728",
            zorder=5, label="certified witnesses")
for w in witnesses:
    ax1.annotate(str(w), (w, S[w - 1]), textcoords="offset points",
                 xytext=(0, 6), ha="center", fontsize=8)
ax1.set_xlabel("x"); ax1.set_ylabel(r"$S_1^{\varphi}(x)$")
ax1.set_title("Unit-shift totient collisions up to 1000")
ax1.legend(); ax1.grid(alpha=0.3)

# GHP envelope shape exp(-c sqrt(log x log log x)) (unnormalized, illustrative).
xs2 = [x for x in xs if x >= 3]
env = [math.exp(-0.5 * math.sqrt(math.log(x) * math.log(math.log(x)))) for x in xs2]
ax2.plot(xs2, env, color="#2ca02c", lw=2)
ax2.set_xlabel("x")
ax2.set_ylabel(r"$\exp\{-\tfrac12\sqrt{\log x\,\log_2 x}\}$")
ax2.set_title("Smooth-number signature of the GHP exponent")
ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig("totient_collisions.png", dpi=150)
print("saved totient_collisions.png; S1phi(1000) =", S[-1])

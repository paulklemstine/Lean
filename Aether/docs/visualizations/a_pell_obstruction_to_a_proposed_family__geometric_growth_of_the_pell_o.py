import matplotlib.pyplot as plt
from math import isqrt

def order(u): return u * (3 * u + 2)

us, u, m = [0], 2, 4
while u < 10 ** 15:
    us.append(u); u, m = 7*u+4*m+2, 12*u+7*m+4
us = us[1:]                      # drop trivial 0 for log scale
ms = [isqrt(order(u)) for u in us]
n = list(range(1, len(us) + 1))

fig, ax = plt.subplots(figsize=(9, 5))
ax.semilogy(n, us, "o-", label="index u_n")
ax.semilogy(n, ms, "s--", label="order root m_n")
ax.set_xlabel("n"); ax.set_ylabel("value (log scale)")
ax.set_title("Pell orbit grows geometrically by 7 + 4√3 per step")
ax.legend(); ax.grid(True, which="both", alpha=0.3)
plt.tight_layout(); plt.savefig("growth.png", dpi=150)
print("saved growth.png")

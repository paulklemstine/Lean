"""Bar chart: fraction of coprime pairs eliminated by the parity criterion."""
import matplotlib.pyplot as plt
from math import gcd

def v2(m: int) -> int:
    c = 0
    while m % 2 == 0:
        m //= 2
        c += 1
    return c

limits = [20, 40, 60, 80, 100]
fracs = []
for L in limits:
    total = forbidden = 0
    for a in range(2, L):
        for b in range(a + 1, L):
            if gcd(a, b) != 1:
                continue
            total += 1
            if (v2(a + 1) + v2(b + 1)) % 2 == 1:
                forbidden += 1
    fracs.append(100 * forbidden / total)

plt.figure(figsize=(7, 5))
plt.bar([str(L) for L in limits], fracs, color="steelblue")
plt.xlabel("window limit L (coprime pairs with a<b<L)")
plt.ylabel("% eliminated by 2-adic parity")
plt.title("Reach of the parity obstruction")
plt.ylim(0, 100)
plt.tight_layout()
plt.savefig("parity_reach.png", dpi=150)
print("saved parity_reach.png")

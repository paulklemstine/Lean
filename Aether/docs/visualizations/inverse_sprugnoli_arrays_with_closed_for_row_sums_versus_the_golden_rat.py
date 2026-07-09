import numpy as np
import matplotlib.pyplot as plt
from math import comb

def s(n):
    return sum(comb(n + k, 2 * k) for k in range(n + 1))

ns = list(range(11))
sn = [s(n) for n in ns]
fig, ax = plt.subplots(figsize=(7, 5))
ax.semilogy(ns, sn, "o-", label="row sum  s(n)=sum C(n+k,2k)")
phi = (1 + 5 ** 0.5) / 2
ax.semilogy(ns, [phi ** (2 * n + 1) / 5 ** 0.5 for n in ns], "--",
            label=r"$\varphi^{2n+1}/\sqrt5$")
ax.set_title("Row sums are odd-indexed Fibonacci numbers  s(n)=F(2n+1)")
ax.set_xlabel("n"); ax.set_ylabel("value (log scale)")
ax.legend()
plt.tight_layout()
plt.savefig("rowsum_fibonacci.png", dpi=150)
print("wrote rowsum_fibonacci.png")

"""Visualize proofCost(d) vs the logarithmic ceiling log2(d), and the
support trade-off ceiling N // 2**proofCost(d). Saves anti_gravity.png."""
import math
import matplotlib.pyplot as plt

def proof_cost(d: int) -> int:
    m, p, c = d, 2, 0
    while p * p <= m:
        while m % p == 0:
            c += 1; m //= p
        p += 1
    if m > 1:
        c += 1
    return c

N = 1_000_000
ds = list(range(2, 2001))
costs = [proof_cost(d) for d in ds]
log2 = [math.log2(d) for d in ds]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

ax1.scatter(ds, costs, s=4, alpha=0.4, label="proofCost(d) = Omega(d)")
ax1.plot(ds, log2, color="crimson", lw=2, label="log2(d)  (the ceiling)")
ax1.set_xlabel("d"); ax1.set_ylabel("number of prime factors")
ax1.set_title("Logarithmic cost bound: 2**proofCost(d) <= d")
ax1.legend()

ceil = [N // (2 ** proof_cost(d)) for d in ds]
sup = [N // d for d in ds]
ax2.scatter(ds, sup, s=4, alpha=0.4, label="support(N,d) = N//d")
ax2.scatter(ds, ceil, s=4, alpha=0.4, color="crimson",
            label="ceiling = N//2**proofCost(d)")
ax2.set_yscale("log")
ax2.set_xlabel("d"); ax2.set_ylabel("support (log scale)")
ax2.set_title(f"Support trade-off in universe N={N:,}")
ax2.legend()

fig.tight_layout()
fig.savefig("anti_gravity.png", dpi=130)
print("saved anti_gravity.png")

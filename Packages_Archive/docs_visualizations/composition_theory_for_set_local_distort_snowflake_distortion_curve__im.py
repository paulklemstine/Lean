"""Visualize how composing snowflake (Holder) maps multiplies exponents and
shifts the Hausdorff-dimension window. Requires matplotlib."""
import math
import matplotlib.pyplot as plt

def similarity_dimension(ratios):
    def moran(d): return sum(c ** d for c in ratios) - 1.0
    lo, hi = 0.0, 8.0
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if moran(mid) > 0.0: lo = mid
        else: hi = mid
    return 0.5 * (lo + hi)

d0 = similarity_dimension([1/3, 1/3])           # Cantor set, log2/log3
exps = [r/100 for r in range(20, 101)]          # forward exponent r in (0.2,1]
dims = [d0 / r for r in exps]                    # dimH s / r (power map on the line)

plt.figure(figsize=(8, 5))
plt.plot(exps, dims, lw=2, color="#b1003a")
plt.axhline(d0, ls="--", color="gray", label=f"source dim = {d0:.4f}")
plt.scatter([1.0], [d0], color="black", zorder=5, label="exponent 1 (bi-Lipschitz)")
plt.title("Snowflake distortion of Hausdorff dimension: dimH s / r")
plt.xlabel("Holder exponent r")
plt.ylabel("image Hausdorff dimension")
plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig("snowflake_distortion.png", dpi=150)
print("saved snowflake_distortion.png")

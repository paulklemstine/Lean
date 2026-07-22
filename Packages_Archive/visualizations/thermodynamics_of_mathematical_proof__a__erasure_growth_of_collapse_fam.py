import math
import matplotlib.pyplot as plt

KB, T = 1.380649e-23, 300.0
ns = list(range(1, 13))
linear = [n for n in ns]                 # collapse_n erases n bits
exponential = [2 ** m for m in ns]       # bigCollapse_m erases 2^m bits

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(ns, linear, "o-", label="collapse family: erased = n bits")
ax.plot(ns, exponential, "s-", label="big-collapse family: erased = 2^m bits")
ax.set_yscale("log")
ax.set_xlabel("problem size parameter")
ax.set_ylabel("erased information (bits, log scale)")
ax.set_title("Unbounded erasure: linear vs. exponential collapse families")
ax.legend()
ax.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("erasure_growth.png", dpi=150)
print("saved erasure_growth.png")

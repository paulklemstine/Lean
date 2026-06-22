import numpy as np
import matplotlib.pyplot as plt

ns = np.arange(1, 9)
fig, ax = plt.subplots(figsize=(9, 6))
for k in (1, 2, 3):
    ax.plot(ns, ns.astype(float) ** k, marker="o",
            label=f"powSystem {k}: exponent n^{k}")
inter = [n ** 2 if n % 2 == 0 else n ** 1 for n in ns]
ax.plot(ns, inter, marker="s", linestyle="--", color="black",
        label="interPowSys 1 (parity-glued interpolant)")
ax.set_yscale("log")
ax.set_xlabel("input n")
ax.set_ylabel("size exponent e  (size = 2^e)")
ax.set_title("Power-tower ladder of p-degrees and a dense interpolant")
ax.legend()
ax.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("ladder.png", dpi=150)
print("wrote ladder.png")

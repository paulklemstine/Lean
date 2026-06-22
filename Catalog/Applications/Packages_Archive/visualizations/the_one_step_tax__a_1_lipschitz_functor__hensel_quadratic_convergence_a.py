"""Visualize Hensel precision growth (>= 2^n) and the log-many-steps law."""
import matplotlib.pyplot as plt
from math import log2, floor

steps = list(range(0, 22))
precision = [2 ** n for n in steps]

targets = [64, 256, 1024, 4096, 1_000_000]
needed = [floor(log2(t)) + 1 for t in targets]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
ax1.semilogy(steps, precision, "o-")
ax1.set_xlabel("Newton / Hensel steps n")
ax1.set_ylabel("guaranteed precision  >= 2^n")
ax1.set_title("Quadratic convergence: precision doubles each step")
ax1.grid(True, which="both", alpha=0.3)

ax2.bar([str(t) for t in targets], needed, color="teal")
ax2.set_xlabel("target precision (digits)")
ax2.set_ylabel("certified steps = floor(log2 target)+1")
ax2.set_title("Logarithmically few steps suffice")
for i, v in enumerate(needed):
    ax2.text(i, v + 0.1, str(v), ha="center")
plt.tight_layout()
plt.savefig("hensel_growth.png", dpi=150)
print("wrote hensel_growth.png")

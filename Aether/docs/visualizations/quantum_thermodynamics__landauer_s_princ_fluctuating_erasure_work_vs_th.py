"""Visualisation: work distribution, mean work, and the kT ln 2 floor."""
import math
import matplotlib.pyplot as plt

K_B = 1.380649e-23
T = 300.0
alpha = 1.0 / (K_B * T)
delta_f = K_B * T * math.log(2)          # Landauer free-energy cost (one bit)

# A fluctuating two-outcome erasure work satisfying the Jarzynski equality.
p = {0: 0.5, 1: 0.5}
w1 = 1.6 * delta_f
w0 = -math.log((math.exp(-alpha * delta_f) - 0.5 * math.exp(-alpha * w1)) / 0.5) / alpha
work = {0: w0, 1: w1}
mean_w = sum(p[o] * work[o] for o in p)

fig, ax = plt.subplots(figsize=(8, 5))
labels = [f"outcome {o}" for o in work]
vals = [work[o] / delta_f for o in work]      # in units of kT ln 2
ax.bar(labels, vals, color=["#4C72B0", "#55A868"], width=0.5,
       label="work per outcome")
ax.axhline(1.0, color="crimson", ls="--", lw=2, label=r"$kT\ln 2$ (Landauer floor)")
ax.axhline(mean_w / delta_f, color="black", ls=":", lw=2,
           label=r"$E[W]$ (mean work)")
ax.set_ylabel(r"work / $(kT\ln 2)$")
ax.set_title("One-bit erasure: fluctuating work vs the Landauer floor")
ax.legend()
plt.tight_layout()
plt.savefig("landauer_work_distribution.png", dpi=150)
print("saved landauer_work_distribution.png")

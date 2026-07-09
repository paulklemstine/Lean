"""Visualisation: extensivity of the Landauer bound across register size."""
import math
import matplotlib.pyplot as plt

K_B = 1.380649e-23
T = 300.0
ns = list(range(1, 13))
total = [n * K_B * T * math.log(2) for n in ns]
per_bit = [K_B * T * math.log(2) for _ in ns]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))
ax1.plot(ns, total, "o-", color="#4C72B0")
ax1.set_xlabel("register size n (bits)")
ax1.set_ylabel("minimum erasure cost (J)")
ax1.set_title(r"Extensive bound  $n\,kT\ln 2$")
ax1.grid(True, ls=":", alpha=0.5)

ax2.plot(ns, per_bit, "s-", color="#55A868")
ax2.set_xlabel("register size n (bits)")
ax2.set_ylabel("cost per bit (J)")
ax2.set_title(r"Exact per-bit cost  $kT\ln 2$ (constant)")
ax2.grid(True, ls=":", alpha=0.5)
plt.tight_layout()
plt.savefig("landauer_extensivity.png", dpi=150)
print("saved landauer_extensivity.png")

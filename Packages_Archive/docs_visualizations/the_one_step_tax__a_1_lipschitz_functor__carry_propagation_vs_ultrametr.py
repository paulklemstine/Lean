"""Visualize classical carry depth (Omega(log n)) vs ultrametric depth (O(1))."""
import matplotlib.pyplot as plt
from math import log2, floor

bits = [2 ** k for k in range(1, 21)]
classical = [floor(log2(b)) for b in bits]
ultra = [1 for _ in bits]

plt.figure(figsize=(8, 5))
plt.plot(bits, classical, "o-", label="classical carry depth  >= floor(log2 n)")
plt.plot(bits, ultra, "s--", label="ultrametric depth = 1 (no carries)")
plt.xscale("log", base=2)
plt.xlabel("operand size n (bits)")
plt.ylabel("addition circuit depth")
plt.title("Carry propagation vs ultrametric locality")
plt.legend()
plt.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("depth_gap.png", dpi=150)
print("wrote depth_gap.png")

import numpy as np
import matplotlib.pyplot as plt

rs = np.arange(1, 7)
plt.figure(figsize=(8, 5))
for k in (2, 3, 4):
    c = 1.0 / k ** (2.0 * rs)
    plt.plot(rs, c, "o-", label=f"k={k}")
plt.yscale("log")
plt.xlabel("number of composition layers r")
plt.ylabel("power-saving constant 1/k^(2r)")
plt.title("Geometric decay of the composition constant")
plt.legend()
plt.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("tower_decay.png", dpi=150)
print("wrote tower_decay.png")

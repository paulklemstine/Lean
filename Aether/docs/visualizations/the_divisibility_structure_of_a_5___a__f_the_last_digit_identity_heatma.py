import matplotlib.pyplot as plt
import numpy as np

# Heatmap: last digit of r^5 (mod 10) vs r -- a diagonal identity.
grid = np.zeros((10, 10), dtype=int)
for r in range(10):
    grid[r, (r ** 5) % 10] = 1

fig, ax = plt.subplots(figsize=(6, 6))
ax.imshow(grid, cmap="Blues", origin="lower")
ax.set_xlabel("last digit of r^5")
ax.set_ylabel("r")
ax.set_xticks(range(10)); ax.set_yticks(range(10))
ax.set_title("Fifth power fixes the last digit: r^5 = r (mod 10)")
plt.tight_layout()
plt.savefig("last_digit_identity.png", dpi=150)
print("saved last_digit_identity.png")

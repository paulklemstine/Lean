import matplotlib.pyplot as plt
import numpy as np

# Heatmap of a^2 + b^2 mod 3 over (a, b) in a grid; solutions to a^2+b^2=c^2
# can only land on residues that are themselves squares (0 or 1), never 2.
N = 30
grid = np.zeros((N, N), dtype=int)
for a in range(N):
    for b in range(N):
        grid[a, b] = (a * a + b * b) % 3

plt.figure(figsize=(6, 5))
plt.imshow(grid, origin="lower", cmap="viridis")
plt.colorbar(label="(a^2 + b^2) mod 3")
plt.title("Residue of a^2 + b^2 modulo 3 (value 2 is forbidden for a hypotenuse)")
plt.xlabel("b"); plt.ylabel("a")
plt.tight_layout(); plt.savefig("mod3_heatmap.png", dpi=140)
print("saved mod3_heatmap.png")

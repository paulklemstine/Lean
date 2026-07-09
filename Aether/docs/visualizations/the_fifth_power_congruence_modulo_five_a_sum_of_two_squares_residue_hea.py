import matplotlib.pyplot as plt
import numpy as np

# Heatmap of (a^2 + b^2) mod 5 for a,b in 0..9, highlighting which sums are squares.
N = 10
M = np.zeros((N, N), dtype=int)
for a in range(N):
    for b in range(N):
        M[a, b] = (a * a + b * b) % 5
fig, ax = plt.subplots(figsize=(7, 6))
im = ax.imshow(M, cmap="viridis")
for a in range(N):
    for b in range(N):
        ax.text(b, a, str(M[a, b]), ha='center', va='center', color='white', fontsize=8)
ax.set_xlabel("b"); ax.set_ylabel("a")
ax.set_title("(a^2 + b^2) mod 5   (0,1,4 are squares; 2,3 are not)")
fig.colorbar(im, ax=ax, label="residue")
plt.tight_layout()
plt.savefig("sum_two_squares_mod5.png", dpi=150)
print("saved sum_two_squares_mod5.png")

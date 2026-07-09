"""Heatmap of the moment matrix for isotropic vs. anisotropic antipodal sets."""
import matplotlib.pyplot as plt

def moment_matrix(X, n):
    M = [[0.0] * n for _ in range(n)]
    for x in X:
        for i in range(n):
            for j in range(n):
                M[i][j] += x[i] * x[j]
    return M

n = 3
cross = []
for i in range(n):
    e = [0.0] * n; e[i] = 1.0; cross.append(e)
    f = [0.0] * n; f[i] = -1.0; cross.append(f)
skew = [[1.0, 0, 0], [-1.0, 0, 0], [0.6, 0.8, 0], [-0.6, -0.8, 0]]

fig, axes = plt.subplots(1, 2, figsize=(9, 4))
for ax, (title, X) in zip(axes, [("isotropic (2 in Hst)", cross),
                                 ("anisotropic (2 not in Hst)", skew)]):
    M = moment_matrix(X, n)
    im = ax.imshow(M, cmap="viridis")
    ax.set_title(title)
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f"{M[i][j]:.2f}", ha="center", va="center",
                    color="white")
    fig.colorbar(im, ax=ax, fraction=0.046)
plt.tight_layout(); plt.savefig("moment_heatmap.png", dpi=150)
print("saved moment_heatmap.png")

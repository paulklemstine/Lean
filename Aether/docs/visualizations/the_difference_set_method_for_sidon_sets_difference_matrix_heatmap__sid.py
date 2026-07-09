import matplotlib.pyplot as plt
import numpy as np

def diff_matrix(s):
    m = len(s)
    M = np.zeros((m, m), dtype=int)
    for i, a in enumerate(s):
        for j, b in enumerate(s):
            M[i, j] = a - b
    return M

# Sidon set {1,2,5,11,13} vs non-Sidon {1,2,3,4,5}
sidon = [1, 2, 5, 11, 13]
nonsidon = [1, 2, 3, 4, 5]
fig, axes = plt.subplots(1, 2, figsize=(11, 5))
for ax, s, title in [(axes[0], sidon, "Sidon: all off-diagonal diffs distinct"),
                     (axes[1], nonsidon, "Non-Sidon: repeated differences")]:
    M = diff_matrix(s)
    im = ax.imshow(M, cmap="coolwarm")
    for i in range(len(s)):
        for j in range(len(s)):
            ax.text(j, i, M[i, j], ha="center", va="center", fontsize=9)
    ax.set_xticks(range(len(s))); ax.set_xticklabels(s)
    ax.set_yticks(range(len(s))); ax.set_yticklabels(s)
    ax.set_title(title)
    fig.colorbar(im, ax=ax, fraction=0.046)
plt.tight_layout(); plt.savefig("difference_matrix.png", dpi=150)

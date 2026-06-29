import numpy as np
import matplotlib.pyplot as plt


def overlap_constraint_count(n: int, n_rows: int, n_cols: int) -> int:
    return (n * (n - 1) // 2) * (n_rows * n_cols)


def consistency_probability(r: float, c: int) -> float:
    return (1.0 - r) ** c


n_rows, n_cols = 1, 4
rates = np.linspace(0.01, 0.6, 60)
sources = np.arange(2, 12)
Z = np.zeros((len(sources), len(rates)))
for i, n in enumerate(sources):
    c = overlap_constraint_count(int(n), n_rows, n_cols)
    for j, r in enumerate(rates):
        # log10 of probability (clamped) for readability
        p = consistency_probability(float(r), c)
        Z[i, j] = np.log10(p) if p > 0 else -50.0

fig, ax = plt.subplots(figsize=(8, 5))
im = ax.imshow(Z, aspect='auto', origin='lower',
               extent=[rates[0], rates[-1], sources[0], sources[-1]],
               cmap='viridis')
ax.set_xlabel('per-constraint disagreement rate r')
ax.set_ylabel('number of sources n')
ax.set_title('log10 P(consistent) = log10 (1 - r)^C')
fig.colorbar(im, ax=ax, label='log10 probability')
plt.tight_layout()
plt.savefig('consistency_decay_heatmap.png', dpi=150)
print('wrote consistency_decay_heatmap.png')

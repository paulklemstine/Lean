import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def model_gap(d, alpha=2.0, df=30/81):
    return max(0, (1 - d/df)**alpha) if d < df else 0.0

DC, DF = 17/81, 30/81
ds = np.linspace(0, 1, 500)
gaps = [model_gap(d) for d in ds]

fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(ds, gaps, 'b-', linewidth=2.5, label=r'$\gamma(d)$')
ax.axvline(DC, color='r', linestyle='--', alpha=0.7, label=f'$d_c = 17/81$')
ax.axvline(DF, color='orange', linestyle='--', alpha=0.7, label=f'$d_f = 30/81$')
ax.fill_between([0, DC], 0, 1.1, alpha=0.1, color='green')
ax.fill_between([DC, DF], 0, 1.1, alpha=0.1, color='yellow')
ax.fill_between([DF, 1], 0, 1.1, alpha=0.1, color='red')
ax.set_xlabel('Constraint Density d', fontsize=14)
ax.set_ylabel('Spectral Gap $\gamma(d)$', fontsize=14)
ax.set_title('Spectral Landscape of Sudoku', fontsize=16)
ax.legend(fontsize=12)
plt.tight_layout()
plt.savefig('spectral_landscape_main.png', dpi=150)
print('Saved spectral_landscape_main.png')
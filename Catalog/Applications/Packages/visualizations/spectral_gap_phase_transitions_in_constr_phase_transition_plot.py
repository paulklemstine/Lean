import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def spectral_gap_model(d):
    d_c, d_f = 17/81, 30/81
    if d < d_c: return max(0.02, 1.0 - (d/d_c)**0.8 * 0.98)
    elif d < d_f:
        p = (d - d_c) / (d_f - d_c)
        return max(0.0, 0.02 * (1-p)**2)
    else: return 0.0

d = np.linspace(0, 0.7, 500)
g = [spectral_gap_model(x) for x in d]
fig, ax = plt.subplots(figsize=(10,6))
ax.plot(d, g, 'b-', lw=2)
ax.axvline(17/81, color='r', ls='--', alpha=0.7, label='d_c=17/81')
ax.axvline(30/81, color='darkred', ls=':', alpha=0.7, label='d_f=30/81')
ax.axvspan(0, 17/81, alpha=0.1, color='green')
ax.axvspan(17/81, 30/81, alpha=0.1, color='orange')
ax.axvspan(30/81, 0.7, alpha=0.1, color='red')
ax.set_xlabel('Constraint Density')
ax.set_ylabel('Spectral Gap')
ax.set_title('Sudoku Spectral Gap Phase Transition')
ax.legend()
plt.savefig('phase_transition.png', dpi=150)

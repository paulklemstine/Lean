import matplotlib.pyplot as plt
import numpy as np

def radar_chart(ax, values, label, color, alpha=0.25):
    N = len(values)
    angles = np.linspace(0, 2 * np.pi, N, endpoint=False).tolist()
    values_plot = values + [values[0]]
    angles += [angles[0]]
    ax.plot(angles, values_plot, 'o-', linewidth=2, label=label, color=color)
    ax.fill(angles, values_plot, alpha=alpha, color=color)

axiom_names = ['Ext', 'Pair', 'Union', 'Pow', 'Inf', 'Repl', 'Found', 'Choice']

spectra = {
    'ZFC (all satisfied)': ([0.0]*8, '#2ecc71'),
    'Ackermann (¬Infinity)': ([0,0,0,0,1,0,0,0], '#e74c3c'),
    'Solovay (¬Choice)': ([0,0,0,0,0,0,0,1], '#3498db'),
    'Phantom (¬Ext, ¬Inf)': ([1,0,0,0,1,0,0,0], '#9b59b6'),
}

fig, ax = plt.subplots(figsize=(10, 10), subplot_kw=dict(polar=True))

N = len(axiom_names)
angles = np.linspace(0, 2*np.pi, N, endpoint=False).tolist()
ax.set_xticks(angles)
ax.set_xticklabels(axiom_names, fontsize=12)
ax.set_ylim(0, 1.1)
ax.set_yticks([0.25, 0.5, 0.75, 1.0])
ax.set_yticklabels(['0.25', '0.5', '0.75', '1.0'], fontsize=8)
ax.set_title('Axiom Defect Spectra of Mathematical Universes', fontsize=14, fontweight='bold', pad=20)

for name, (vals, color) in spectra.items():
    radar_chart(ax, vals, name, color)

ax.legend(loc='upper right', bbox_to_anchor=(1.3, 1.1), fontsize=10)
plt.tight_layout()
plt.savefig('defect_spectrum.png', dpi=150, bbox_inches='tight')
plt.show()
print('Saved defect_spectrum.png')
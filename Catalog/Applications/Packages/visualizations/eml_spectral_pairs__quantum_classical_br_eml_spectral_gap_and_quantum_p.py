import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: EML diagonal
ax = axes[0]
x = np.linspace(0.01, 4, 500)
y_diag = np.exp(x) - np.log(x)
ax.plot(x, y_diag, 'b-', linewidth=2, label='exp(x) - ln(x)')
ax.axhline(y=2, color='orange', linestyle=':', linewidth=2, label='Gap = 2')
x_min = 0.5671
y_min = np.exp(x_min) - np.log(x_min)
ax.plot(x_min, y_min, 'ko', markersize=8)
ax.annotate(f'min ≈ {y_min:.3f}', (x_min, y_min), textcoords='offset points', xytext=(15, -15))
ax.set_xlim(0, 4); ax.set_ylim(0, 12)
ax.set_xlabel('x'); ax.set_ylabel('Value')
ax.set_title('EML Spectral Gap Theorem'); ax.legend(); ax.grid(True, alpha=0.3)

# Panel 2: Unit circle
ax = axes[1]
theta = np.linspace(0, 2*np.pi, 100)
z = np.exp(1j * theta)
ax.plot(z.real, z.imag, 'b-', linewidth=2)
for a in [0, np.pi/2, np.pi, 3*np.pi/2]:
    pt = np.exp(1j * a)
    ax.plot(pt.real, pt.imag, 'ro', markersize=8)
ax.set_xlim(-1.5, 1.5); ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal'); ax.set_xlabel('Re'); ax.set_ylabel('Im')
ax.set_title('Quantum Phase Map: exp(iθ)'); ax.grid(True, alpha=0.3)

# Panel 3: Composition
ax = axes[2]
phases = np.linspace(-2, 3, 200)
for ls, c in zip([0, 0.5, 1.0, -0.5], ['blue', 'red', 'green', 'purple']):
    ax.plot(phases, np.exp(phases) - ls, color=c, linewidth=1.5, label=f's = {ls}')
ax.set_xlabel('Phase'); ax.set_ylabel('EML Value')
ax.set_title('EML Value = Amplitude + Info'); ax.legend(); ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('quantum_eml_spectral_gap.png', dpi=150, bbox_inches='tight')
print('Saved quantum_eml_spectral_gap.png')
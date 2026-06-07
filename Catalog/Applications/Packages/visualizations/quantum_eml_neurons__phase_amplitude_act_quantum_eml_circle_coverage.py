import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def qeml(theta, t):
    return np.exp(1j * theta) * np.log(1 + 1j * t)

def qeml_amplitude(t):
    return abs(np.log(1 + 1j * t))

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
thetas = np.linspace(0, 2 * np.pi, 200)
couplings = [0.5, 1.0, 2.0, 5.0, 10.0]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(couplings)))
for t, color in zip(couplings, colors):
    zs = [qeml(th, t) for th in thetas]
    axes[0].plot([z.real for z in zs], [z.imag for z in zs], color=color, lw=1.5, label=f't={t}')
axes[0].set_xlabel('Re(z)'); axes[0].set_ylabel('Im(z)')
axes[0].set_title('QEML Circles'); axes[0].legend(fontsize=8); axes[0].set_aspect('equal'); axes[0].grid(True, alpha=0.3)
ts = np.linspace(0, 20, 500)
axes[1].plot(ts, [qeml_amplitude(t) for t in ts], 'b-', lw=2, label='Amplitude')
axes[1].plot(ts, np.log(ts + 1), 'r--', lw=1.5, label='log(t+1)')
axes[1].set_xlabel('t'); axes[1].set_ylabel('Amplitude'); axes[1].set_title('Amplitude Growth'); axes[1].legend(); axes[1].grid(True, alpha=0.3)
ts2 = np.linspace(0.01, 5, 200)
axes[2].plot(ts2, [np.log(np.sqrt(1+t**2)) for t in ts2], 'b-', lw=2, label='Re(qeml(0,t))')
axes[2].plot(ts2, [np.arctan(t) for t in ts2], 'r-', lw=2, label='Im(qeml(0,t))')
axes[2].set_xlabel('t'); axes[2].set_title('Classical-Quantum Bridge'); axes[2].legend(); axes[2].grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('qeml_viz.png', dpi=150); plt.close()
print('Saved qeml_viz.png')
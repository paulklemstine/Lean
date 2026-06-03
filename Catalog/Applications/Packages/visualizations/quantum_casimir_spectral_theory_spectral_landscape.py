import numpy as np
import matplotlib.pyplot as plt

theta_vals = np.linspace(0.01, np.pi - 0.01, 500)
n_vals = range(1, 21)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Spectral numerator heatmap
ax = axes[0, 0]
S = np.array([[np.cos(t) - np.cos((2*n+1)*t) for t in theta_vals] for n in n_vals])
im = ax.imshow(S, aspect='auto', cmap='RdBu_r', vmin=-2, vmax=2,
               extent=[0.01, np.pi-0.01, 20, 1])
ax.set_xlabel('θ')
ax.set_ylabel('n (representation label)')
ax.set_title('Spectral Numerator S(n, θ) = cos(θ) - cos((2n+1)θ)')
plt.colorbar(im, ax=ax)

# Plot 2: Individual spectral curves
ax = axes[0, 1]
for n in [1, 2, 3, 5, 10]:
    y = [np.cos(t) - np.cos((2*n+1)*t) for t in theta_vals]
    ax.plot(theta_vals, y, label=f'n={n}')
ax.set_xlabel('θ')
ax.set_ylabel('S(n, θ)')
ax.set_title('Spectral Numerator for Selected n')
ax.legend()
ax.axhline(y=0, color='k', linewidth=0.5)
ax.set_xlim(0, np.pi)

# Plot 3: Dirichlet kernel
ax = axes[1, 0]
for N in [5, 10, 20]:
    y = [np.sin(2*N*t) / (2*np.sin(t)) if abs(np.sin(t)) > 1e-10 else 0 for t in theta_vals]
    ax.plot(theta_vals, y, label=f'N={N}')
ax.set_xlabel('θ')
ax.set_ylabel('Σ cos((2k+1)θ)')
ax.set_title('Odd Cosine Sum (Dirichlet Kernel)')
ax.legend()

# Plot 4: Level-one factorization
ax = axes[1, 1]
y1 = [np.cos(t) - np.cos(3*t) for t in theta_vals]
y2 = [4*np.cos(t)*np.sin(t)**2 for t in theta_vals]
ax.plot(theta_vals, y1, 'b-', linewidth=2, label='cos(θ) - cos(3θ)')
ax.plot(theta_vals, y2, 'r--', linewidth=2, label='4cos(θ)sin²(θ)')
ax.set_xlabel('θ')
ax.set_ylabel('Value')
ax.set_title('Level-One Factorization Identity')
ax.legend()

plt.tight_layout()
plt.savefig('spectral_landscape.png', dpi=150)
plt.show()
print('Saved spectral_landscape.png')
"""Demo 2: Diagonal Dynamics and Super-Exponential Growth

Shows the iterated diagonal map d^n(z) and its super-exponential growth.
Proves d(d(z)) ≥ d(z) visually and plots the orbit from z₀ = 1.
"""
import numpy as np
import matplotlib.pyplot as plt

def diag(z):
    return np.exp(z) - np.log(np.abs(z) + 1e-300)

# Diagonal function plot
z = np.linspace(0.01, 3, 1000)
d_vals = np.exp(z) - np.log(z)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: d(z) vs z
axes[0,0].plot(z, d_vals, 'b-', linewidth=2, label='d(z) = exp(z) - ln(z)')
axes[0,0].plot(z, z, 'k--', alpha=0.5, label='y = z')
axes[0,0].axhline(y=2, color='r', linestyle=':', alpha=0.5, label='y = 2 (lower bound)')
axes[0,0].set_xlabel('z'); axes[0,0].set_ylabel('d(z)')
axes[0,0].set_title('Diagonal Map d(z) = exp(z) - ln(z)')
axes[0,0].legend(); axes[0,0].set_ylim(0, 15)
axes[0,0].grid(True, alpha=0.3)

# Plot 2: d(z) - z > 0 (always above identity)
axes[0,1].fill_between(z, d_vals - z, 0, alpha=0.3, color='green')
axes[0,1].plot(z, d_vals - z, 'g-', linewidth=2, label='d(z) - z > 0')
axes[0,1].axhline(y=0, color='k', linestyle='-', alpha=0.3)
axes[0,1].set_xlabel('z'); axes[0,1].set_ylabel('d(z) - z')
axes[0,1].set_title('d(z) > z for all z > 0 (V17)')
axes[0,1].legend()
axes[0,1].grid(True, alpha=0.3)

# Plot 3: Iterated orbit from z₀ = 1
orbit = [1.0]
for i in range(5):
    try:
        next_val = np.exp(orbit[-1]) - np.log(orbit[-1])
        if next_val > 1e15:
            break
        orbit.append(next_val)
    except:
        break

axes[1,0].semilogy(range(len(orbit)), orbit, 'ro-', linewidth=2, markersize=8)
axes[1,0].set_xlabel('Iteration n'); axes[1,0].set_ylabel('d^n(1)')
axes[1,0].set_title('Diagonal Orbit: Super-Exponential Growth')
axes[1,0].grid(True, alpha=0.3)
for i, v in enumerate(orbit):
    axes[1,0].annotate(f'{v:.2f}' if v < 1000 else f'{v:.1e}',
                       (i, v), textcoords="offset points", xytext=(10, 5))

# Plot 4: Minimum location (Omega constant)
z_fine = np.linspace(0.01, 2, 10000)
d_fine = np.exp(z_fine) - np.log(z_fine)
min_idx = np.argmin(d_fine)
z_min = z_fine[min_idx]
d_min = d_fine[min_idx]

axes[1,1].plot(z_fine, d_fine, 'b-', linewidth=2)
axes[1,1].plot(z_min, d_min, 'r*', markersize=15,
               label=f'Minimum: z* ≈ {z_min:.4f}, d(z*) ≈ {d_min:.4f}')
axes[1,1].axhline(y=2, color='r', linestyle=':', alpha=0.5)
axes[1,1].set_xlabel('z'); axes[1,1].set_ylabel('d(z)')
axes[1,1].set_title(f'd(z) minimum at Ω ≈ {z_min:.4f} (Lambert W(1))')
axes[1,1].legend()
axes[1,1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/EML/EMLv17Research/demos/diagonal_dynamics.png', dpi=150)
plt.close()
print(f"Demo 2 complete. Omega constant ≈ {z_min:.6f}, d(Ω) ≈ {d_min:.6f}")
print(f"Orbit: {orbit}")

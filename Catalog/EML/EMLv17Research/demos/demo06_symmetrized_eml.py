"""Demo 6: Symmetrized EML and KL Divergence Connection

Visualizes S(a,b) = (a - ln a) + (b - ln b) ≥ 2 with equality iff a=b=1,
and the connection to reverse KL divergence.
"""
import numpy as np
import matplotlib.pyplot as plt

a = np.linspace(0.01, 4, 400)
b = np.linspace(0.01, 4, 400)
A, B = np.meshgrid(a, b)
S = (A - np.log(A)) + (B - np.log(B))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Contour plot of S(a,b)
cs = axes[0,0].contourf(A, B, S, levels=np.arange(2, 12, 0.5), cmap='hot_r')
plt.colorbar(cs, ax=axes[0,0], label='S(a,b)')
axes[0,0].contour(A, B, S, levels=[2], colors='white', linewidths=2)
axes[0,0].plot(1, 1, 'w*', markersize=15, label='Minimum (1,1)')
axes[0,0].set_xlabel('a'); axes[0,0].set_ylabel('b')
axes[0,0].set_title('Symmetrized EML: S(a,b) ≥ 2')
axes[0,0].legend()

# Plot 2: 1D slice f(x) = x - ln(x) ≥ 1
x = np.linspace(0.01, 5, 500)
f = x - np.log(x)
axes[0,1].plot(x, f, 'b-', linewidth=2, label='x - ln(x)')
axes[0,1].axhline(y=1, color='r', linestyle='--', label='y = 1 (minimum)')
axes[0,1].plot(1, 1, 'r*', markersize=15)
axes[0,1].fill_between(x, 1, f, alpha=0.1, color='blue')
axes[0,1].set_xlabel('x'); axes[0,1].set_ylabel('x - ln(x)')
axes[0,1].set_title('Sub-log inequality: x - ln(x) ≥ 1, equality at x=1')
axes[0,1].legend(); axes[0,1].grid(True, alpha=0.3)

# Plot 3: Reverse KL divergence D(1||p) = p - 1 - ln(p)
p = np.linspace(0.01, 5, 500)
dkl = p - 1 - np.log(p)
axes[1,0].plot(p, dkl, 'g-', linewidth=2, label=r'$D_{KL}(1||p) = p - 1 - \ln p$')
axes[1,0].plot(1, 0, 'r*', markersize=15, label='Minimum at p=1')
axes[1,0].fill_between(p, 0, dkl, alpha=0.1, color='green')
axes[1,0].set_xlabel('p'); axes[1,0].set_ylabel(r'$D_{KL}(1||p)$')
axes[1,0].set_title('Reverse KL = d(p) - 1 (EML diagonal connection)')
axes[1,0].legend(); axes[1,0].grid(True, alpha=0.3)
axes[1,0].set_ylim(-0.5, 5)

# Plot 4: EML diagonal d(p) = exp(p) - ln(p) and relationship
d_vals = np.exp(p) - np.log(p)
axes[1,1].plot(p, d_vals, 'b-', linewidth=2, label='d(p) = exp(p) - ln(p)')
axes[1,1].plot(p, 1 + dkl, 'r--', linewidth=2, label='1 + D_KL(1||p)')
axes[1,1].plot(p, p - np.log(p), 'g:', linewidth=2, label='p - ln(p) (Bregman)')
axes[1,1].set_xlabel('p'); axes[1,1].set_ylabel('Value')
axes[1,1].set_title('EML Diagonal vs KL Divergence')
axes[1,1].legend(); axes[1,1].grid(True, alpha=0.3)
axes[1,1].set_ylim(0, 10); axes[1,1].set_xlim(0, 3)

plt.tight_layout()
plt.savefig('/workspace/request-project/EML/EMLv17Research/demos/symmetrized_eml_v17.png', dpi=150)
plt.close()
print("Demo 6 complete: symmetrized_eml_v17.png")

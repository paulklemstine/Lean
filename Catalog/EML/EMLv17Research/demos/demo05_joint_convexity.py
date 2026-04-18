"""Demo 5: Joint Convexity Verification and Hessian Analysis

Numerically verifies joint convexity of eml(x,y) and visualizes the
Hessian eigenvalues and convexity inequality.
"""
import numpy as np
import matplotlib.pyplot as plt

def eml(x, y):
    return np.exp(x) - np.log(y)

# Verify convexity: eml(t*p1 + (1-t)*p2) <= t*eml(p1) + (1-t)*eml(p2)
np.random.seed(42)
n_tests = 10000
violations = 0

x1 = np.random.randn(n_tests)
y1 = np.exp(np.random.randn(n_tests))  # positive
x2 = np.random.randn(n_tests)
y2 = np.exp(np.random.randn(n_tests))
t = np.random.rand(n_tests)

lhs = eml(t*x1 + (1-t)*x2, t*y1 + (1-t)*y2)
rhs = t*eml(x1, y1) + (1-t)*eml(x2, y2)
gaps = rhs - lhs

violations = np.sum(gaps < -1e-10)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Convexity gap histogram
axes[0,0].hist(gaps, bins=100, color='steelblue', edgecolor='black', alpha=0.7)
axes[0,0].axvline(x=0, color='red', linestyle='--', label='Gap = 0')
axes[0,0].set_xlabel('Convexity gap (RHS - LHS)')
axes[0,0].set_ylabel('Count')
axes[0,0].set_title(f'Joint Convexity: {n_tests} tests, {violations} violations')
axes[0,0].legend()

# Plot 2: Hessian eigenvalues
x_grid = np.linspace(-2, 2, 100)
y_grid = np.linspace(0.1, 5, 100)
X, Y = np.meshgrid(x_grid, y_grid)

lambda1 = np.exp(X)  # ∂²/∂x² = exp(x)
lambda2 = 1.0 / Y**2  # ∂²/∂y² = 1/y²
min_eig = np.minimum(lambda1, lambda2)

im = axes[0,1].pcolormesh(X, Y, min_eig, cmap='viridis', shading='auto')
plt.colorbar(im, ax=axes[0,1], label='min eigenvalue')
axes[0,1].set_xlabel('x'); axes[0,1].set_ylabel('y')
axes[0,1].set_title('Hessian min eigenvalue (always > 0)')

# Plot 3: Sublevel sets (convex)
Z = np.exp(X) - np.log(Y)
levels = [0, 1, 2, 3, 5, 10]
cs = axes[1,0].contour(X, Y, Z, levels=levels, colors='blue')
axes[1,0].clabel(cs, inline=True, fontsize=10)
axes[1,0].set_xlabel('x'); axes[1,0].set_ylabel('y')
axes[1,0].set_title('EML Sublevel Sets (all convex)')
axes[1,0].grid(True, alpha=0.3)

# Plot 4: Midpoint inequality verification
axes[1,1].scatter(gaps[:500], t[:500]*eml(x1[:500], y1[:500]),
                  c=t[:500], cmap='coolwarm', alpha=0.5, s=10)
axes[1,1].set_xlabel('Convexity gap')
axes[1,1].set_ylabel('t·eml(p₁)')
axes[1,1].set_title('Gap ≥ 0 confirms convexity')
axes[1,1].axvline(x=0, color='red', linestyle='--', alpha=0.5)
axes[1,1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/EML/EMLv17Research/demos/joint_convexity_v17.png', dpi=150)
plt.close()
print(f"Demo 5 complete. Violations: {violations}/{n_tests}")

"""
Visualization: Inner Functions of EML-KA Decompositions

Shows the role of inner functions (log, scaled log, identity) in
separating variables for Kolmogorov-Arnold representations.
Demonstrates how different inner functions φ(x) map the positive
real line into ℝ, enabling the outer function exp to reconstruct
the target.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

x = np.linspace(0.01, 5.0, 300)

# --- Panel 1: Inner functions ---
ax = axes[0, 0]
ax.plot(x, np.log(x), 'b-', linewidth=2.5, label='φ(x) = log(x) [multiplication]')
ax.plot(x, 0.5 * np.log(x), 'r-', linewidth=2.5, label='φ(x) = ½log(x) [geom. mean]')
ax.plot(x, 2 * np.log(x), 'g-', linewidth=2.5, label='φ(x) = 2·log(x) [x² power]')
ax.plot(x, -np.log(x), 'm--', linewidth=2.5, label='φ(x) = −log(x) [division]')
ax.axhline(0, color='black', linewidth=0.5)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('φ(x)', fontsize=12)
ax.set_title('EML Inner Functions', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Panel 2: Outer function (exp) ---
ax = axes[0, 1]
t = np.linspace(-3, 4, 300)
ax.plot(t, np.exp(t), 'b-', linewidth=2.5, label='Φ(t) = exp(t)')
ax.fill_between(t, 0, np.exp(t), alpha=0.1, color='blue')
ax.set_xlabel('t = φ₁(x) + φ₂(y)', fontsize=12)
ax.set_ylabel('Φ(t)', fontsize=12)
ax.set_title('Universal Outer Function: exp', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.set_ylim(0, 20)
ax.grid(True, alpha=0.3)

# --- Panel 3: KA term count comparison ---
ax = axes[1, 0]
dims = np.arange(1, 11)
ka_general = 2 * dims + 1
ka_eml_mul = np.ones_like(dims)
ka_eml_pow = np.ones_like(dims)

ax.bar(dims - 0.2, ka_general, 0.4, label='General KA (2n+1)',
       color='#FF6B6B', alpha=0.8)
ax.bar(dims + 0.2, ka_eml_mul, 0.4, label='EML-KA (multiplication)',
       color='#4ECDC4', alpha=0.8)
ax.set_xlabel('Dimension n', fontsize=12)
ax.set_ylabel('Number of terms Q', fontsize=12)
ax.set_title('KA Term Efficiency:\nGeneral vs. EML-KA', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_xticks(dims)
ax.grid(True, alpha=0.3, axis='y')

# --- Panel 4: Point separation by log ---
ax = axes[1, 1]
points = [0.5, 1.0, 2.0, 3.0, 5.0]
log_points = [np.log(p) for p in points]

ax.scatter(points, [0]*len(points), s=100, c='blue', zorder=5,
           label='Original points')
ax.scatter(log_points, [1]*len(log_points), s=100, c='red', zorder=5,
           label='After log (separated)')

for p, lp in zip(points, log_points):
    ax.annotate('', xy=(lp, 0.95), xytext=(p, 0.05),
                arrowprops=dict(arrowstyle='->', color='gray', alpha=0.5))
    ax.text(p, -0.15, f'{p}', ha='center', fontsize=10, color='blue')
    ax.text(lp, 1.15, f'{lp:.2f}', ha='center', fontsize=10, color='red')

ax.set_xlabel('Value', fontsize=12)
ax.set_yticks([0, 1])
ax.set_yticklabels(['Input space', 'Log-transformed'])
ax.set_title('Log Separates Points\n(Injective on (0,∞))', fontsize=13, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3, axis='x')

plt.suptitle('Anatomy of EML-Kolmogorov-Arnold Decompositions',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_ka_inner_functions.png', dpi=150, bbox_inches='tight')
print("Saved viz_ka_inner_functions.png")

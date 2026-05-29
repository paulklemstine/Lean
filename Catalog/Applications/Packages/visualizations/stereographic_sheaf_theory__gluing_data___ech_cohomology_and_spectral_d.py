"""
Visualization 2: Čech Cohomology and Spectral Decomposition

Visualizes the spectral decomposition of vectors under an involutive
transition map. For the stereographic sheaf, every section decomposes
into symmetric (phi-fixed) and antisymmetric (phi-anti-fixed) parts.

Also shows the Čech differential kernel for different transition maps,
illustrating how the choice of gluing data determines the cohomology.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Spectral Decomposition in R^2
ax = axes[0]

# Reflection involution: phi(x,y) = (-x, y)
def phi_reflect(v):
    return np.array([-v[0], v[1]])

# Generate random vectors and decompose
np.random.seed(42)
vectors = [np.random.randn(2) * 2 for _ in range(8)]

for v in vectors:
    phi_v = phi_reflect(v)
    s = (v + phi_v) / 2  # symmetric part
    a = (v - phi_v) / 2  # antisymmetric part

    ax.arrow(0, 0, v[0], v[1], head_width=0.08, head_length=0.05,
             fc='gray', ec='gray', alpha=0.3)
    ax.arrow(0, 0, s[0], s[1], head_width=0.08, head_length=0.05,
             fc='blue', ec='blue', alpha=0.6)
    ax.arrow(s[0], s[1], a[0], a[1], head_width=0.08, head_length=0.05,
             fc='red', ec='red', alpha=0.6)

# Draw the eigenspaces
ax.axhline(y=0, color='red', linestyle='--', alpha=0.3, label='Antisym axis (x)')
ax.axvline(x=0, color='blue', linestyle='--', alpha=0.3, label='Sym axis (y)')

ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')
ax.set_title('Spectral Decomposition\nφ(x,y) = (-x, y)', fontsize=11)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.legend(fontsize=8, loc='upper left')
ax.grid(True, alpha=0.2)

# Add legend
import matplotlib.patches as mpatches
gray_patch = mpatches.Patch(color='gray', alpha=0.3, label='Original vector')
blue_patch = mpatches.Patch(color='blue', alpha=0.6, label='Symmetric part')
red_patch = mpatches.Patch(color='red', alpha=0.6, label='Antisymmetric part')
ax.legend(handles=[gray_patch, blue_patch, red_patch], fontsize=8, loc='upper left')

# Panel 2: Cech Differential for Different Gluings
ax = axes[1]

# For each gluing, plot the kernel of the Cech differential
# d(a, b) = phi(a) - b

# Grid of (a, b) values
a_vals = np.linspace(-3, 3, 300)
b_vals = np.linspace(-3, 3, 300)
A, B = np.meshgrid(a_vals, b_vals)

# Trivial gluing: d(a,b) = a - b, kernel is a = b
D_trivial = A - B
ax.contour(A, B, D_trivial, levels=[0], colors=['blue'], linewidths=2)
ax.contourf(A, B, np.abs(D_trivial), levels=[0, 0.1], colors=['blue'], alpha=0.1)

# Negation gluing: d(a,b) = -a - b, kernel is a + b = 0
D_neg = -A - B
ax.contour(A, B, D_neg, levels=[0], colors=['red'], linewidths=2)
ax.contourf(A, B, np.abs(D_neg), levels=[0, 0.1], colors=['red'], alpha=0.1)

ax.plot([], [], 'b-', linewidth=2, label='Trivial: a = b')
ax.plot([], [], 'r-', linewidth=2, label='Negation: a = -b')
ax.plot(0, 0, 'ko', markersize=8, label='H⁰ ∩ H⁰')

ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')
ax.set_xlabel('a (north chart section)', fontsize=10)
ax.set_ylabel('b (south chart section)', fontsize=10)
ax.set_title('Čech Cocycles: ker(d⁰)', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 3: ZMod conjecture visualization
ax = axes[2]
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
fixed_counts = []
for p in primes:
    count = sum(1 for x in range(p) if (2*x) % p == 0)
    fixed_counts.append(count)

colors_bar = ['red' if c > 1 else 'steelblue' for c in fixed_counts]
bars = ax.bar(range(len(primes)), fixed_counts, color=colors_bar, alpha=0.7, edgecolor='black')

ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes])
ax.set_xlabel('Prime p', fontsize=11)
ax.set_ylabel('# Fixed points of -x = x in ℤ/pℤ', fontsize=10)
ax.set_title('Stereographic Completeness Conjecture', fontsize=11)
ax.axhline(y=1, color='green', linestyle='--', alpha=0.5, label='Conjecture: exactly 1 for p odd')

# Annotate p=2 failure
ax.annotate('Fails for p=2!\n(-1 = 1 in ℤ/2ℤ)', xy=(0, 2), xytext=(2, 2.5),
            arrowprops=dict(arrowstyle='->', color='red'),
            fontsize=9, color='red', fontweight='bold')

ax.legend(fontsize=9)
ax.grid(True, alpha=0.2, axis='y')

plt.tight_layout()
plt.savefig('viz_cech_cohomology.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_cech_cohomology.png")

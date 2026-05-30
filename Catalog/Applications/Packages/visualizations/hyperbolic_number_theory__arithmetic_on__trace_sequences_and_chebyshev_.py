#!/usr/bin/env python3
"""
Visualization 2: Trace Sequences and Chebyshev Polynomials

Shows the exponential growth of trace sequences for different base
trace values, illustrating the connection to Chebyshev polynomials
and the classification of Möbius transformations.
"""

import numpy as np
import matplotlib.pyplot as plt


def trace_seq(t, n):
    """Compute traceSeq(t, n) via recurrence."""
    if n == 0:
        return 2
    if n == 1:
        return t
    prev2, prev1 = 2, t
    for _ in range(n - 1):
        prev2, prev1 = prev1, t * prev1 - prev2
    return prev1


def primitive_trace_density(N):
    """Compute the density of primitive traces in [3, N]."""
    import math
    count = 0
    total = 0
    for t in range(3, N + 1):
        total += 1
        s = int(math.isqrt(t + 2))
        if not (s >= 2 and s * s == t + 2):
            count += 1
    return count / total if total > 0 else 0


# Create figure with subplots
fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Trace sequences (log scale)
ax1 = axes[0, 0]
n_vals = np.arange(0, 16)
colors = plt.cm.viridis(np.linspace(0.2, 0.9, 5))
for idx, t in enumerate([2, 3, 4, 5, 7]):
    vals = [trace_seq(t, n) for n in n_vals]
    label = f't = {t} ({"parabolic" if t == 2 else "hyperbolic"})'
    ax1.semilogy(n_vals, [abs(v) for v in vals], 'o-', color=colors[idx],
                 label=label, markersize=4, linewidth=1.5)

ax1.set_xlabel('Power n', fontsize=12)
ax1.set_ylabel('|traceSeq(t, n)|', fontsize=12)
ax1.set_title('Trace Sequences: Exponential Growth\n(Chebyshev Polynomials)', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Trace sequence mod (t-2) — verifying congruence theorem
ax2 = axes[0, 1]
t_val = 7
n_range = np.arange(0, 25)
residues = [(trace_seq(t_val, n) - 2) % (t_val - 2) for n in n_range]
ax2.bar(n_range, residues, color='steelblue', alpha=0.7)
ax2.axhline(y=0, color='red', linestyle='--', linewidth=2, label='Expected residue = 0')
ax2.set_xlabel('Power n', fontsize=12)
ax2.set_ylabel(f'(traceSeq({t_val}, n) - 2) mod {t_val-2}', fontsize=12)
ax2.set_title(f'Congruence Theorem Verification: t = {t_val}\n'
              f'traceSeq(t, n) ≡ 2 (mod t-2)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Primitive trace density
ax3 = axes[1, 0]
N_values = list(range(10, 2001, 10))
densities = [primitive_trace_density(N) for N in N_values]
ax3.plot(N_values, densities, 'b-', linewidth=1.5, label='Primitive trace density')
import math
asymptotic = 1 - 6 / math.pi**2
ax3.axhline(y=asymptotic, color='red', linestyle='--', linewidth=2,
            label=f'Conjectured: 1 - 6/π² ≈ {asymptotic:.4f}')
ax3.axhline(y=1.0, color='gray', linestyle=':', linewidth=1, alpha=0.5)
ax3.set_xlabel('N', fontsize=12)
ax3.set_ylabel('Primitive density in [3, N]', fontsize=12)
ax3.set_title('Primitive Trace Density Conjecture\n'
              '(Imprimitive = s²-2 for some s ≥ 2)', fontsize=13)
ax3.legend(fontsize=10)
ax3.set_ylim(0.85, 1.01)
ax3.grid(True, alpha=0.3)

# Panel 4: Markov tree (first few triples)
ax4 = axes[1, 1]
markov = [(1, 1, 1), (1, 1, 2), (1, 2, 5), (2, 5, 29), (1, 5, 13),
          (5, 13, 194), (5, 29, 433), (1, 13, 34), (1, 34, 89)]

# Plot as a tree
positions = {
    (1, 1, 1): (0, 3),
    (1, 1, 2): (0, 2),
    (1, 2, 5): (-2, 1),
    (1, 5, 13): (-3, 0),
    (1, 13, 34): (-4, -1),
    (1, 34, 89): (-5, -2),
    (2, 5, 29): (-1, 0),
    (5, 13, 194): (-2, -1),
    (5, 29, 433): (0, -1),
}

for triple, pos in positions.items():
    x, y, z = triple
    ax4.plot(*pos, 'o', color='darkred', markersize=10, zorder=5)
    ax4.annotate(f'({x},{y},{z})', pos, textcoords="offset points",
                 xytext=(8, 5), fontsize=8, fontweight='bold')

# Draw edges
edges = [
    ((1, 1, 1), (1, 1, 2)),
    ((1, 1, 2), (1, 2, 5)),
    ((1, 2, 5), (2, 5, 29)),
    ((1, 2, 5), (1, 5, 13)),
    ((1, 5, 13), (5, 13, 194)),
    ((1, 5, 13), (1, 13, 34)),
    ((1, 13, 34), (1, 34, 89)),
    ((2, 5, 29), (5, 29, 433)),
]

for t1, t2 in edges:
    if t1 in positions and t2 in positions:
        p1, p2 = positions[t1], positions[t2]
        ax4.plot([p1[0], p2[0]], [p1[1], p2[1]], 'k-', linewidth=1, alpha=0.5)

ax4.set_title('Markov Tree via Vieta Involutions\n'
              'x² + y² + z² = 3xyz', fontsize=13)
ax4.set_xlim(-6, 2)
ax4.set_ylim(-3, 4)
ax4.axis('off')

plt.suptitle('Hyperbolic Number Theory: Key Results',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('trace_sequences.png', dpi=150, bbox_inches='tight')
plt.close()
print("Generated trace sequence visualization")

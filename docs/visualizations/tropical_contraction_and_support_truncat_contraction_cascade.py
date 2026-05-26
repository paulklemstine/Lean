"""
Visualization: Contraction Cascade — Iterative Support Reduction

Shows what happens when we repeatedly contract a support set in
different directions. The support shrinks monotonically, and M-convexity
is preserved at every step. This visualizes the tower of truncations
that connects the original Newton polytope to smaller and smaller
sub-polytopes.
"""

import matplotlib.pyplot as plt
import numpy as np

def exponent_contract(i, m):
    if m[i] == 0:
        return None
    return m[:i] + (m[i] - 1,) + m[i+1:]

def support_contract(i, S):
    return {mc for m in S if (mc := exponent_contract(i, m)) is not None}

def check_exchange(S):
    if not S:
        return True
    S_f = frozenset(S)
    d = len(next(iter(S)))
    for a in S:
        for b in S:
            for k in range(d):
                if a[k] > b[k]:
                    ok = False
                    for j in range(d):
                        if a[j] < b[j]:
                            e = list(a); e[k] -= 1; e[j] += 1
                            if tuple(e) in S_f:
                                ok = True; break
                    if not ok:
                        return False
    return True

# Start with simplex slice sum=4 in 2D
total = 5
S0 = {(a, total - a) for a in range(total + 1)}

# Build contraction cascade
cascade = [("Original (sum=5)", S0)]
current = S0
directions = [0, 1, 0, 1, 0]  # alternate contractions
for step, d in enumerate(directions):
    current = support_contract(d, current)
    if not current:
        break
    dir_name = 'x' if d == 0 else 'y'
    cascade.append((f"Step {step+1}: contract {dir_name}", current))

n_plots = len(cascade)
fig, axes = plt.subplots(1, n_plots, figsize=(4 * n_plots, 4))
if n_plots == 1:
    axes = [axes]

fig.suptitle('Contraction Cascade: Iterative Support Truncation',
             fontsize=14, fontweight='bold')

colors = plt.cm.viridis(np.linspace(0.2, 0.8, n_plots))

for idx, (title, S) in enumerate(cascade):
    ax = axes[idx]
    if not S:
        ax.text(0.5, 0.5, 'Empty', ha='center', va='center', fontsize=14)
        ax.set_title(title)
        continue

    pts = np.array(sorted(S))
    mconv = check_exchange(S)

    ax.scatter(pts[:, 0], pts[:, 1], c=[colors[idx]], s=120,
              zorder=5, edgecolors='black', linewidth=1.5)

    # Connect adjacent points
    if len(pts) >= 2:
        ax.plot(pts[:, 0], pts[:, 1], '-', color=colors[idx], alpha=0.4, linewidth=2)

    for p in S:
        ax.annotate(f'({p[0]},{p[1]})', p, textcoords="offset points",
                   xytext=(5, 8), fontsize=8)

    status = "✓ M-convex" if mconv else "✗ Not M-convex"
    ax.set_title(f'{title}\n|S|={len(S)}, {status}', fontsize=10)
    ax.set_xlabel('x-exponent')
    ax.set_ylabel('y-exponent')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, total + 0.5)
    ax.set_ylim(-0.5, total + 0.5)
    ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('contraction_cascade.png', dpi=150, bbox_inches='tight')
print("Saved contraction_cascade.png")

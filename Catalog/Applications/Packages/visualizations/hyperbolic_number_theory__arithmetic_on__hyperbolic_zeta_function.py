"""
Visualization 2: Hyperbolic Zeta Function and Euclidean Comparison
===================================================================
Plots the truncated hyperbolic zeta function ζ_H(s) = Σ d^{-2s}
alongside the classical Riemann zeta for comparison, illustrating
how curved-space number theory modifies the analytic structure.
"""
import numpy as np
import matplotlib.pyplot as plt
from collections import deque


def moebius_apply(a, b, c, d, z):
    return (a * z + b) / (c * z + d)


def enumerate_orbit_distances(generators, basepoint=0, max_depth=6, tol=1e-6):
    """Enumerate orbit and return hyperbolic distances."""
    all_gens = []
    for g in generators:
        all_gens.append(g)
        all_gens.append((g[3], -g[1], -g[2], g[0]))

    distances = []
    seen = {(round(basepoint.real/tol), round(basepoint.imag/tol))}
    queue = deque([(basepoint, 0)])

    while queue:
        pt, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for g in all_gens:
            new_pt = moebius_apply(*g, pt)
            if abs(new_pt) >= 1 - 1e-10:
                continue
            key = (round(new_pt.real/tol), round(new_pt.imag/tol))
            if key not in seen:
                seen.add(key)
                d = abs(new_pt - basepoint)**2 / ((1-abs(new_pt)**2)*(1-abs(basepoint)**2))
                dist = 2 * np.arcsinh(np.sqrt(max(d, 0)))
                if dist > 0.01:
                    distances.append(dist)
                queue.append((new_pt, depth + 1))
    return sorted(distances)


def trunc_hyp_zeta(distances, s):
    return sum(d**(-2*s) for d in distances if d > 0)


def gauss_circle_count(n):
    count = 0
    for a in range(-int(np.sqrt(n))-1, int(np.sqrt(n))+2):
        if a*a > n:
            continue
        b_max = int(np.sqrt(n - a*a))
        count += 2*b_max + 1
    return count


# Generate data
g1 = (1, -0.3, -0.3, 1)
g2 = (1, -0.3j, 0.3j, 1)
distances = enumerate_orbit_distances([g1, g2], max_depth=7)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top-left: ζ_H(s) vs s
ax = axes[0, 0]
s_vals = np.linspace(0.6, 4.0, 100)
zeta_vals = [trunc_hyp_zeta(distances, s) for s in s_vals]
ax.plot(s_vals, zeta_vals, 'b-', linewidth=2, label='$\\zeta_H(s)$ (hyperbolic)')

# Classical Riemann zeta (truncated)
riemann_vals = [sum(n**(-2*s) for n in range(1, 200)) for s in s_vals]
ax.plot(s_vals, riemann_vals, 'r--', linewidth=2, label='$\\zeta(2s)$ (Riemann, truncated)')

ax.set_xlabel('s', fontsize=12)
ax.set_ylabel('$\\zeta(s)$', fontsize=12)
ax.set_title('Hyperbolic vs Classical Zeta Function', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, max(max(zeta_vals), max(riemann_vals)) * 1.1)

# Top-right: Distance distribution
ax = axes[0, 1]
ax.hist(distances, bins=30, color='steelblue', edgecolor='white', alpha=0.8)
ax.set_xlabel('Hyperbolic distance', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'Distribution of {len(distances)} Orbit Distances', fontsize=13)
ax.grid(True, alpha=0.3)

# Bottom-left: Gauss circle count vs πn
ax = axes[1, 0]
ns = np.arange(1, 101)
gc = [gauss_circle_count(int(n)) for n in ns]
theory = [np.pi * n for n in ns]
ax.plot(ns, gc, 'b-', linewidth=2, label='$G(n)$ (actual count)')
ax.plot(ns, theory, 'r--', linewidth=2, label='$\\pi n$ (asymptotic)')
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Gauss Circle Problem: $G(n) \\sim \\pi n$', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Bottom-right: Error term in Gauss circle problem
ax = axes[1, 1]
errors = [(gc[i] - np.pi * (i+1)) / np.sqrt(i+1) for i in range(len(gc))]
ax.plot(ns, errors, 'g-', linewidth=1.5, alpha=0.8)
ax.axhline(y=0, color='k', linestyle='-', linewidth=0.5)
ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('$(G(n) - \\pi n) / \\sqrt{n}$', fontsize=12)
ax.set_title('Gauss Circle Error (normalized)', fontsize=13)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('zeta_function_comparison.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: zeta_function_comparison.png")

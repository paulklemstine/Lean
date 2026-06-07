"""
Categorical Humor Theory: Demonstrations

This script demonstrates the key mathematical results from the formal theory:
1. Comedy Triangle Inequality visualization
2. Humor convexity in ℝ²
3. Joke contraction principle (iterative decay)
4. Comedy Cauchy-Schwarz bound
5. Optimal joke existence in compact spaces
"""

import numpy as np
from typing import Tuple, List

def humor(expected: np.ndarray, punchline: np.ndarray) -> float:
    """Humor = dist(expected, punchline)"""
    return float(np.linalg.norm(expected - punchline))

def tension(setup: np.ndarray, expected: np.ndarray) -> float:
    """Tension = dist(setup, expected)"""
    return float(np.linalg.norm(setup - expected))

def arc(setup: np.ndarray, punchline: np.ndarray) -> float:
    """Arc = dist(setup, punchline)"""
    return float(np.linalg.norm(setup - punchline))


# Demo 1: Fundamental Theorem of Comedy
print("=" * 60)
print("DEMO 1: Fundamental Theorem of Comedy")
print("=" * 60)

setup = np.array([0.0, 0.0])
expected = np.array([3.0, 0.0])
punchline = np.array([1.0, 4.0])

h = humor(expected, punchline)
t = tension(setup, expected)
a = arc(setup, punchline)

print(f"Setup:    {setup}")
print(f"Expected: {expected}")
print(f"Punchline: {punchline}")
print(f"Tension = {t:.3f}, Humor = {h:.3f}, Arc = {a:.3f}")
print(f"arc ≤ tension + humor: {a:.3f} ≤ {t + h:.3f} ✓" if a <= t + h + 1e-10 else "FAIL")
print(f"humor ≤ arc + tension: {h:.3f} ≤ {a + t:.3f} ✓" if h <= a + t + 1e-10 else "FAIL")
print(f"tension ≤ arc + humor: {t:.3f} ≤ {a + h:.3f} ✓" if t <= a + h + 1e-10 else "FAIL")


# Demo 2: Humor Convexity
print("\n" + "=" * 60)
print("DEMO 2: Humor Convexity")
print("=" * 60)

e = np.array([0.0, 0.0])
p1 = np.array([4.0, 0.0])
p2 = np.array([0.0, 4.0])

for t_val in [0.0, 0.25, 0.5, 0.75, 1.0]:
    p_blend = (1 - t_val) * p1 + t_val * p2
    h_blend = humor(e, p_blend)
    h_bound = (1 - t_val) * humor(e, p1) + t_val * humor(e, p2)
    print(f"t={t_val:.2f}: humor(blend)={h_blend:.3f} ≤ convex_bound={h_bound:.3f} "
          f"{'✓' if h_blend <= h_bound + 1e-10 else '✗'}")


# Demo 3: Joke Contraction Principle
print("\n" + "=" * 60)
print("DEMO 3: Humor Contraction (Geometric Decay)")
print("=" * 60)

contractivity = 0.7
initial_humor = 10.0
print(f"Initial humor: {initial_humor}, contractivity: {contractivity}")
for n in range(15):
    decayed = contractivity**n * initial_humor
    bound = contractivity**n * initial_humor
    print(f"  n={n:2d}: humor = {decayed:.4f}, bound = {bound:.4f}")
    if decayed < 0.01:
        print(f"  → Humor dropped below 0.01 at retelling {n}")
        break


# Demo 4: Comedy Cauchy-Schwarz
print("\n" + "=" * 60)
print("DEMO 4: Comedy Cauchy-Schwarz")
print("=" * 60)

for trial in range(5):
    np.random.seed(42 + trial)
    n = 10
    humors = np.random.exponential(2.0, n)
    lhs = np.sum(humors)**2
    rhs = n * np.sum(humors**2)
    print(f"Trial {trial+1}: (Σhᵢ)² = {lhs:.2f} ≤ n·Σhᵢ² = {rhs:.2f} "
          f"{'✓' if lhs <= rhs + 1e-10 else '✗'} (ratio = {lhs/rhs:.3f})")


# Demo 5: Optimal Joke in Compact Space
print("\n" + "=" * 60)
print("DEMO 5: Optimal Joke in [0,1]²")
print("=" * 60)

expected_pt = np.array([0.3, 0.4])
# Search over a fine grid (approximating compact space)
best_humor = 0
best_p = None
for x in np.linspace(0, 1, 1000):
    for y in np.linspace(0, 1, 1000):
        p = np.array([x, y])
        h = humor(expected_pt, p)
        if h > best_humor:
            best_humor = h
            best_p = p.copy()

print(f"Expected point: {expected_pt}")
print(f"Optimal punchline: {best_p}")
print(f"Maximum humor: {best_humor:.4f}")
print(f"Diameter of [0,1]²: {np.sqrt(2):.4f}")
print(f"Humor ≤ diameter: {best_humor <= np.sqrt(2) + 1e-6}")


# Demo 6: Humor Dilation
print("\n" + "=" * 60)
print("DEMO 6: Humor Dilation (Exaggeration)")
print("=" * 60)

e = np.array([0.0, 0.0])
p = np.array([1.0, 1.0])
original_humor = humor(e, p)
print(f"Original humor: {original_humor:.3f}")
for t in [1.0, 1.5, 2.0, 3.0, 5.0, 10.0]:
    dilated = e + t * (p - e)
    dilated_humor = humor(e, dilated)
    print(f"  t={t:5.1f}: dilated_humor = {dilated_humor:.3f} "
          f"(ratio = {dilated_humor/original_humor:.1f}x) "
          f"≥ original: {'✓' if dilated_humor >= original_humor - 1e-10 else '✗'}")


# Demo 7: Midpoint Factorization
print("\n" + "=" * 60)
print("DEMO 7: Midpoint Factorization")
print("=" * 60)

e = np.array([1.0, 2.0])
p = np.array([5.0, 6.0])
mid = 0.5 * e + 0.5 * p
d_e_mid = humor(e, mid)
d_mid_p = humor(mid, p)
d_e_p = humor(e, p)
print(f"Expected: {e}, Punchline: {p}")
print(f"Midpoint: {mid}")
print(f"dist(e, mid) = {d_e_mid:.4f}")
print(f"dist(mid, p) = {d_mid_p:.4f}")
print(f"dist(e, p)/2 = {d_e_p/2:.4f}")
print(f"Equidistant: {abs(d_e_mid - d_mid_p) < 1e-10} ✓")
print(f"Half humor: {abs(d_e_mid - d_e_p/2) < 1e-10} ✓")

print("\n" + "=" * 60)
print("All demos complete!")
print("=" * 60)


"""
Visualization: The Comedy Landscape

Shows humor as a function of punchline position in ℝ²,
with the expected point fixed. Demonstrates convexity and
optimal joke existence.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm

# Setup
expected = np.array([0.3, 0.4])

# Create grid
x = np.linspace(0, 1, 200)
y = np.linspace(0, 1, 200)
X, Y = np.meshgrid(x, y)

# Compute humor (distance from expected)
H = np.sqrt((X - expected[0])**2 + (Y - expected[1])**2)

# Find optimal punchline
max_idx = np.unravel_index(np.argmax(H), H.shape)
optimal = np.array([X[max_idx], Y[max_idx]])
max_humor = H[max_idx]

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: contour plot
ax1 = axes[0]
cs = ax1.contourf(X, Y, H, levels=20, cmap='YlOrRd')
plt.colorbar(cs, ax=ax1, label='Humor')
ax1.plot(*expected, 'b*', markersize=15, label='Expected')
ax1.plot(*optimal, 'g^', markersize=12, label=f'Optimal (H={max_humor:.2f})')
ax1.set_xlabel('Punchline x')
ax1.set_ylabel('Punchline y')
ax1.set_title('Comedy Landscape: Humor = dist(expected, punchline)')
ax1.legend()
ax1.set_aspect('equal')

# Right: convexity demo
ax2 = axes[1]
p1 = np.array([0.9, 0.1])
p2 = np.array([0.1, 0.9])
ts = np.linspace(0, 1, 100)
blend_humors = []
bound_humors = []
h1 = np.linalg.norm(expected - p1)
h2 = np.linalg.norm(expected - p2)

for t in ts:
    p_blend = (1 - t) * p1 + t * p2
    blend_humors.append(np.linalg.norm(expected - p_blend))
    bound_humors.append((1 - t) * h1 + t * h2)

ax2.plot(ts, blend_humors, 'b-', linewidth=2, label='Actual humor')
ax2.plot(ts, bound_humors, 'r--', linewidth=2, label='Convex bound')
ax2.fill_between(ts, blend_humors, bound_humors, alpha=0.2, color='green',
                  label='Convexity gap')
ax2.set_xlabel('Interpolation parameter t')
ax2.set_ylabel('Humor')
ax2.set_title('Humor Convexity: actual ≤ convex combination')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('comedy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved comedy_landscape.png")


"""
Visualization: Humor Contraction and Decay

Shows geometric decay of humor under repeated joke retelling,
demonstrating the contraction principle and half-life theorem.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Geometric decay for different contraction factors
ax1 = axes[0]
n_iters = 30
ns = np.arange(n_iters)
h0 = 10.0

for c in [0.3, 0.5, 0.7, 0.85, 0.95]:
    humors = [h0 * c**n for n in ns]
    ax1.plot(ns, humors, '-o', markersize=3, label=f'c={c}')

ax1.axhline(y=0.1, color='red', linestyle=':', label='ε = 0.1')
ax1.set_xlabel('Retelling number n')
ax1.set_ylabel('Humor h₀ · cⁿ')
ax1.set_title('Humor Geometric Decay')
ax1.legend(fontsize=8)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Plot 2: Half-life as function of contraction factor
ax2 = axes[1]
import math
cs = np.linspace(0.01, 0.99, 100)
h0_val = 100.0
epsilon = 1.0
half_lives = [math.ceil(math.log(epsilon / h0_val) / math.log(c)) for c in cs]

ax2.plot(cs, half_lives, 'b-', linewidth=2)
ax2.set_xlabel('Contraction factor c')
ax2.set_ylabel('Half-life (retellings)')
ax2.set_title(f'Humor Half-Life (h₀={h0_val}, ε={epsilon})')
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 100)

# Plot 3: Cauchy-Schwarz tightness
ax3 = axes[2]
n_vals = range(2, 51)
ratios_uniform = []
ratios_skewed = []
ratios_random = []

for n in n_vals:
    # Uniform: all equal
    h_unif = np.ones(n)
    r_u = np.sum(h_unif)**2 / (n * np.sum(h_unif**2))
    ratios_uniform.append(r_u)

    # Skewed: one large, rest small
    h_skew = np.zeros(n)
    h_skew[0] = 10.0
    h_skew[1:] = 0.1
    r_s = np.sum(h_skew)**2 / (n * np.sum(h_skew**2))
    ratios_skewed.append(r_s)

    # Random
    np.random.seed(42)
    h_rand = np.random.exponential(1.0, n)
    r_r = np.sum(h_rand)**2 / (n * np.sum(h_rand**2))
    ratios_random.append(r_r)

ax3.plot(list(n_vals), ratios_uniform, 'g-', linewidth=2, label='Uniform (tight)')
ax3.plot(list(n_vals), ratios_random, 'b-', linewidth=2, label='Random (typical)')
ax3.plot(list(n_vals), ratios_skewed, 'r-', linewidth=2, label='Skewed (loose)')
ax3.axhline(y=1.0, color='black', linestyle=':', label='CS bound = 1')
ax3.set_xlabel('Number of jokes n')
ax3.set_ylabel('(Σhᵢ)² / (n·Σhᵢ²)')
ax3.set_title('Comedy Cauchy-Schwarz Tightness')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('humor_contraction.png', dpi=150, bbox_inches='tight')
print("Saved humor_contraction.png")

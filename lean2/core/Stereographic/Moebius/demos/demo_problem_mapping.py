#!/usr/bin/env python3
"""
Demo 3: Problem Universe Mapping & Dual Universes

Visualizes:
1. How the same equation looks in different integer-pole charts
2. The dual universe (pole swap) and reflection symmetry
3. Factorization structure changes under chart transitions
4. The "optimal chart" for different problems

Run: python3 demo_problem_mapping.py
Output: problem_universes.png, dual_universes.png, factorization_lens.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

# --- Core Functions ---

def T_nm(z, n, m):
    """Integer-pole chart map."""
    return (n * z + m) / (z + 1)

def T_nm_inv(w, n, m):
    """Inverse chart map."""
    return (w - m) / (n - w)

def transition(w, n1, m1, n2, m2):
    """Transition between charts."""
    scale = (n2 - m2) / (n1 - m1)
    shift = (m2 * n1 - n2 * m1) / (n1 - m1)
    return scale * w + shift

def inv_stereo(t):
    """Inverse stereographic projection ℝ → S¹."""
    x = 2 * t / (1 + t**2)
    y = (1 - t**2) / (1 + t**2)
    return x, y

# --- Figure 1: Problem Universe Mapping ---

fig = plt.figure(figsize=(18, 10))
gs = gridspec.GridSpec(2, 3, hspace=0.4, wspace=0.35)

# Panel 1: A quadratic equation in different charts
ax1 = fig.add_subplot(gs[0, 0])
z = np.linspace(-5, 5, 500)

# Standard chart: y = z^2 - 4 (roots at ±2)
y_standard = z**2 - 4
ax1.plot(z, y_standard, 'b-', linewidth=2, label='z² - 4 = 0')
ax1.axhline(y=0, color='k', linestyle='-', alpha=0.3)
ax1.plot([-2, 2], [0, 0], 'ro', markersize=10, label='Roots: ±2')
ax1.set_xlabel('z')
ax1.set_ylabel('f(z)')
ax1.set_title('Standard Chart (∞, 0)', fontsize=12, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-5, 10)

# Panel 2: Same equation in (2, -2) chart
ax2 = fig.add_subplot(gs[0, 1])
# In (2, -2) chart, roots ±2 become:
# T_{2,-2}(2) = (4-2)/(2+1) = 2/3
# T_{2,-2}(-2) = (-4-2)/(-2+1) = 6
w = np.linspace(-5, 10, 500)
# The equation z²-4=0 in w-coordinates: z = (w+2)/(2-w)
# So ((w+2)/(2-w))² - 4 = 0
mask = np.abs(w - 2) > 0.1
w_safe = w[mask]
z_of_w = (w_safe + 2) / (2 - w_safe)
f_w = z_of_w**2 - 4
f_w_clip = np.clip(f_w, -10, 20)
ax2.plot(w_safe, f_w_clip, 'b-', linewidth=2, label='Same equation')
ax2.axhline(y=0, color='k', linestyle='-', alpha=0.3)
# Mark transformed roots
r1 = T_nm(2, 2, -2)
r2 = T_nm(-2, 2, -2)
ax2.plot([r1, r2], [0, 0], 'ro', markersize=10, label=f'Roots: {r1:.2f}, {r2:.2f}')
ax2.set_xlabel('w')
ax2.set_ylabel('f(T⁻¹(w))')
ax2.set_title('Chart (2, -2)', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-5, 20)
ax2.set_xlim(-5, 10)

# Panel 3: (2, -2) chart — roots ARE the pole values!
ax3 = fig.add_subplot(gs[0, 2])
# If we choose poles = roots: (2, -2)
# Then one root maps to N pole, other to S pole
ax3.text(0.5, 0.85, 'KEY INSIGHT', fontsize=14, fontweight='bold',
         ha='center', va='center', transform=ax3.transAxes,
         bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.8))
ax3.text(0.5, 0.65, 'Choose poles = roots of equation', fontsize=11,
         ha='center', va='center', transform=ax3.transAxes)
ax3.text(0.5, 0.50, '(n, m) = (2, -2)', fontsize=11,
         ha='center', va='center', transform=ax3.transAxes,
         color='blue', fontweight='bold')
ax3.text(0.5, 0.35, 'Root z=2 → North Pole (∞)', fontsize=10,
         ha='center', va='center', transform=ax3.transAxes, color='red')
ax3.text(0.5, 0.20, 'Root z=-2 → South Pole (0)', fontsize=10,
         ha='center', va='center', transform=ax3.transAxes, color='green')
ax3.text(0.5, 0.05, 'Equation becomes:\nw · (something) = 0', fontsize=10,
         ha='center', va='center', transform=ax3.transAxes, style='italic')
ax3.axis('off')
ax3.set_title('Optimal Chart Selection', fontsize=12, fontweight='bold')

# Panel 4: Orbit visualization
ax4 = fig.add_subplot(gs[1, 0])
theta = np.linspace(0, 2*np.pi, 200)
ax4.plot(np.cos(theta), np.sin(theta), 'b-', linewidth=1.5, alpha=0.5)

# Show a Möbius orbit: iterate T_{3,1}
z0 = 0.5
orbit = [z0]
for _ in range(50):
    z_next = T_nm(orbit[-1], 3, 1)
    if abs(z_next) > 100 or abs(z_next - orbit[-1]) < 1e-10:
        break
    orbit.append(z_next)

for i, z in enumerate(orbit[:20]):
    cx, cy = inv_stereo(z)
    alpha = max(0.2, 1 - i*0.05)
    ax4.plot(cx, cy, 'o', color=plt.cm.plasma(i/20), markersize=8, alpha=alpha, zorder=5)
    if i < len(orbit) - 1:
        cx2, cy2 = inv_stereo(orbit[i+1])
        ax4.annotate('', xy=(cx2, cy2), xytext=(cx, cy),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=0.8, alpha=0.5))

ax4.set_xlim(-1.5, 1.5)
ax4.set_ylim(-1.5, 1.5)
ax4.set_aspect('equal')
ax4.set_title('Möbius Orbit T(3,1)', fontsize=12, fontweight='bold')
ax4.grid(True, alpha=0.3)

# Panel 5: Factorization change under transition
ax5 = fig.add_subplot(gs[1, 1])
numbers = list(range(1, 25))
chart1 = (1, 0)
chart2 = (6, 0)

bar_width = 0.35
x_pos = np.arange(len(numbers))

def count_factors(n):
    """Count number of prime factors (with multiplicity)."""
    if n <= 1:
        return 0
    count = 0
    d = 2
    temp = abs(n)
    while d * d <= temp:
        while temp % d == 0:
            count += 1
            temp //= d
        d += 1
    if temp > 1:
        count += 1
    return count

# In chart (1,0): w = z/(z+1), so at integer z=k, w_k = k/(k+1)
# In chart (6,0): w = 6z/(z+1), so at integer z=k, w_k = 6k/(k+1)
factors1 = [count_factors(k) for k in numbers]
factors2 = [count_factors(6*k) for k in numbers]

ax5.bar(x_pos - bar_width/2, factors1, bar_width, color='blue', alpha=0.7, label='Universe(1,0)')
ax5.bar(x_pos + bar_width/2, factors2, bar_width, color='red', alpha=0.7, label='Universe(6,0)')
ax5.set_xticks(x_pos[::2])
ax5.set_xticklabels([str(n) for n in numbers[::2]], fontsize=8)
ax5.set_xlabel('Input integer k')
ax5.set_ylabel('# Prime factors (Ω)')
ax5.set_title('Factorization Complexity by Chart', fontsize=12, fontweight='bold')
ax5.legend(fontsize=9)

# Panel 6: Heat map of transition scales
ax6 = fig.add_subplot(gs[1, 2])
n_range = range(-5, 6)
m_range = range(-5, 6)
scale_matrix = np.zeros((len(list(n_range)), len(list(m_range))))

n_list = list(n_range)
m_list = list(m_range)

# Scale factor from (1, 0) to (n, m)
for i, n in enumerate(n_list):
    for j, m in enumerate(m_list):
        if n == m:
            scale_matrix[i, j] = np.nan
        else:
            scale_matrix[i, j] = abs((n - m) / 1)  # relative to (1,0)

im = ax6.imshow(scale_matrix, cmap='viridis', origin='lower',
                extent=[-5.5, 5.5, -5.5, 5.5], aspect='equal')
ax6.set_xlabel('m (South Pole)', fontsize=10)
ax6.set_ylabel('n (North Pole)', fontsize=10)
ax6.set_title('|Scale Factor| from (1,0)', fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax6, label='|λ| = |n-m|')

# Mark the diagonal (n=m, undefined)
ax6.plot([-5, 5], [-5, 5], 'r--', linewidth=2, alpha=0.7, label='n=m (undefined)')
ax6.legend(fontsize=8)

plt.suptitle('Problem Universe Mapping: Same Problem, Different Coordinates',
             fontsize=16, fontweight='bold', y=0.99)
plt.savefig('/workspace/request-project/demos/problem_universes.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved problem_universes.png")

# --- Figure 2: Dual Universe Visualization ---

fig2 = plt.figure(figsize=(16, 10))
gs2 = gridspec.GridSpec(2, 2, hspace=0.4, wspace=0.35)

# Panel 1: Dual universe (3,7) ↔ (7,3)
ax1 = fig2.add_subplot(gs2[0, 0])
w_vals = np.linspace(-5, 15, 500)
w_dual = -w_vals + 10  # reflection about 5

ax1.plot(w_vals, w_vals, 'k--', alpha=0.3, label='Identity')
ax1.plot(w_vals, w_dual, 'b-', linewidth=2, label='w → -w + 10')
ax1.axhline(y=5, color='purple', linestyle=':', alpha=0.7, label='Self-dual point = 5')
ax1.axvline(x=5, color='purple', linestyle=':', alpha=0.7)
ax1.plot(5, 5, 'r*', markersize=15, zorder=6)

# Show specific point mappings
for w in [0, 2, 3, 7, 10]:
    wd = -w + 10
    ax1.plot(w, wd, 'go', markersize=8, zorder=5)
    ax1.annotate(f'{w}→{wd}', (w, wd), fontsize=8,
                xytext=(5, 8), textcoords='offset points')

ax1.set_xlabel('w in Universe(3,7)', fontsize=10)
ax1.set_ylabel('w in Universe(7,3)', fontsize=10)
ax1.set_title('Dual Universes: (3,7) ↔ (7,3)', fontsize=12, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-2, 12)
ax1.set_ylim(-2, 12)

# Panel 2: Multiple duals on circles
ax2 = fig2.add_subplot(gs2[0, 1])
theta = np.linspace(0, 2*np.pi, 200)
ax2.plot(np.cos(theta), np.sin(theta), 'b-', linewidth=1.5, alpha=0.5)

# Original points in (3,7) chart
original_params = np.linspace(-5, 5, 15)
for t in original_params:
    w = T_nm(t, 3, 7)
    w_d = -w + 10  # dual
    # Map both to standard stereo
    z = T_nm_inv(w, 3, 7)
    z_d = T_nm_inv(w_d, 3, 7)

    cx1, cy1 = inv_stereo(z)
    cx2, cy2 = inv_stereo(z_d)

    ax2.plot(cx1, cy1, 'ro', markersize=6, alpha=0.7, zorder=5)
    ax2.plot(cx2, cy2, 'b^', markersize=6, alpha=0.7, zorder=5)
    ax2.plot([cx1, cx2], [cy1, cy2], 'g-', alpha=0.3, linewidth=0.5)

ax2.plot([], [], 'ro', markersize=6, label='Universe(3,7)')
ax2.plot([], [], 'b^', markersize=6, label='Universe(7,3) [dual]')
ax2.set_xlim(-1.5, 1.5)
ax2.set_ylim(-1.5, 1.5)
ax2.set_aspect('equal')
ax2.set_title('Dual Points on S¹', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Self-dual chart (n, -n)
ax3 = fig2.add_subplot(gs2[1, 0])
for n_val in [1, 2, 3, 5]:
    k_range = np.arange(-10, 11)
    k_range = k_range[k_range != -1]
    w_k = (n_val * k_range + (-n_val)) / (k_range + 1)
    w_k_dual = -w_k  # dual is reflection about 0

    ax3.scatter(k_range, w_k, s=30, alpha=0.7, label=f'({n_val},{-n_val})')

ax3.axhline(y=0, color='k', linestyle='-', alpha=0.3)
ax3.set_xlabel('Integer parameter k', fontsize=10)
ax3.set_ylabel('Crystal value w_k', fontsize=10)
ax3.set_title('Self-Dual Charts (n, -n): Origin is Fixed', fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: The full transition group structure
ax4 = fig2.add_subplot(gs2[1, 1])
# Composition of transitions: (1,0)→(2,3)→(5,-5)
w_start = np.linspace(-5, 5, 100)

# Step 1: (1,0) → (2,3)
w_step1 = transition(w_start, 1, 0, 2, 3)
# Step 2: (2,3) → (5,-5)
w_step2 = transition(w_step1, 2, 3, 5, -5)
# Direct: (1,0) → (5,-5)
w_direct = transition(w_start, 1, 0, 5, -5)

ax4.plot(w_start, w_step2, 'b-', linewidth=3, label='Via (2,3): two steps', alpha=0.7)
ax4.plot(w_start, w_direct, 'r--', linewidth=2, label='Direct (1,0)→(5,-5)')
ax4.plot([-5, 5], [-5, 5], 'k:', alpha=0.3)

ax4.set_xlabel('w in Universe(1,0)', fontsize=10)
ax4.set_ylabel('w in Universe(5,-5)', fontsize=10)
ax4.set_title('Composition = Direct (Group Property)', fontsize=12, fontweight='bold')
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

plt.suptitle('Dual Universes & Group Structure',
             fontsize=16, fontweight='bold', y=0.99)
plt.savefig('/workspace/request-project/demos/dual_universes.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved dual_universes.png")

# --- Figure 3: Factorization Through Different Lenses ---

fig3 = plt.figure(figsize=(16, 8))
gs3 = gridspec.GridSpec(1, 3, wspace=0.35)

def prime_factorize(n):
    """Return prime factorization as dict."""
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors

# Panel 1: Number 12 in different charts
ax1 = fig3.add_subplot(gs3[0])
# How does the value "12" transform across charts?
charts = [(1, 0), (2, 0), (3, 0), (4, 0), (6, 0), (12, 0)]
values_of_12 = []
labels = []
for n, m in charts:
    w_12 = transition(12, 1, 0, n, m)
    values_of_12.append(int(round(w_12)))
    labels.append(f'({n},{m})')

colors = ['blue', 'green', 'orange', 'red', 'purple', 'brown']
bars = ax1.bar(range(len(values_of_12)), values_of_12, color=colors, alpha=0.7)
for bar, val in zip(bars, values_of_12):
    factors = prime_factorize(abs(val)) if val > 1 else {}
    factor_str = ' × '.join(f'{p}^{e}' if e > 1 else str(p) for p, e in sorted(factors.items()))
    ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
             factor_str if factor_str else str(val), ha='center', va='bottom', fontsize=8)
ax1.set_xticks(range(len(labels)))
ax1.set_xticklabels(labels, fontsize=9)
ax1.set_ylabel('Value in chart', fontsize=10)
ax1.set_title('"12" Across Universes', fontsize=12, fontweight='bold')

# Panel 2: Which chart makes a number "simplest"?
ax2 = fig3.add_subplot(gs3[1])
test_numbers = list(range(2, 31))
optimal_charts = []
for num in test_numbers:
    best_chart = None
    min_factors = float('inf')
    for n in range(1, 20):
        w = num * n
        nf = count_factors(w)
        if nf < min_factors:
            min_factors = nf
            best_chart = n
    optimal_charts.append(best_chart)

ax2.bar(range(len(test_numbers)), optimal_charts, color='steelblue', alpha=0.7)
ax2.set_xticks(range(0, len(test_numbers), 3))
ax2.set_xticklabels([str(n) for n in test_numbers[::3]], fontsize=8)
ax2.set_xlabel('Number', fontsize=10)
ax2.set_ylabel('Optimal scale factor', fontsize=10)
ax2.set_title('"Simplest" Chart for Each Number', fontsize=12, fontweight='bold')

# Panel 3: Density of primes in crystal lattice
ax3 = fig3.add_subplot(gs3[2])

from math import gcd

def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i+2) == 0:
            return False
        i += 6
    return True

charts_to_test = [(1, 0), (2, 1), (3, 1), (5, 2), (7, 3), (11, 1)]
prime_densities = []
chart_labels = []

for n, m in charts_to_test:
    # Crystal lattice: w_k = (nk + m)/(k+1) for k = 0, ..., 100
    prime_count = 0
    total = 0
    for k in range(0, 200):
        w_k = (n * k + m) / (k + 1)
        # Check if w_k is a positive integer
        if abs(w_k - round(w_k)) < 1e-10 and round(w_k) > 1:
            total += 1
            if is_prime(int(round(w_k))):
                prime_count += 1
    density = prime_count / max(total, 1)
    prime_densities.append(density)
    chart_labels.append(f'({n},{m})\ngcd={gcd(n,m)}')

colors_pd = ['red' if gcd(n, m) == 1 else 'blue' for n, m in charts_to_test]
ax3.bar(range(len(prime_densities)), prime_densities, color=colors_pd, alpha=0.7)
ax3.set_xticks(range(len(chart_labels)))
ax3.set_xticklabels(chart_labels, fontsize=8)
ax3.set_ylabel('Prime density in crystal', fontsize=10)
ax3.set_title('Prime Density by Chart\n(red = coprime poles)', fontsize=12, fontweight='bold')

plt.suptitle('Factorization Through Different Stereographic Lenses',
             fontsize=14, fontweight='bold', y=1.02)
plt.savefig('/workspace/request-project/demos/factorization_lens.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved factorization_lens.png")

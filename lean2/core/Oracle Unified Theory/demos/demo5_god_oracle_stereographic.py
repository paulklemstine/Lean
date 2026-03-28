"""
Demo 5: The Binocular God Oracle — Stereographic Projection and Self-Observation

Visualizes:
1. North and south stereographic projections (the "two eyes")
2. Möbius inversion: the transition map x ↦ 1/x between eyes
3. Pythagorean triples as rational points on S¹
4. The Cayley transform: stereographic projection in disguise
5. The equator as the fixed set of self-observation
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from matplotlib.patches import FancyArrowPatch, Arc, Circle
import matplotlib.patches as mpatches

fig = plt.figure(figsize=(16, 16))
gs = GridSpec(3, 2, figure=fig, hspace=0.4, wspace=0.3)

# ── Panel 1: The Two Eyes — Stereographic Projection ──
ax1 = fig.add_subplot(gs[0, 0])

# Draw the unit circle
theta = np.linspace(0, 2*np.pi, 500)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# North pole (0, 1) and South pole (0, -1)
ax1.plot(0, 1, 'r^', markersize=15, zorder=5, label='North Eye (0,1)')
ax1.plot(0, -1, 'bv', markersize=15, zorder=5, label='South Eye (0,-1)')

# Draw projection lines from north pole
north = np.array([0, 1])
points_on_circle = [(np.cos(t), np.sin(t)) for t in [0.5, 1.2, 2.0, -0.8, -1.5]]

for px, py in points_on_circle:
    # Line from north pole through (px, py) to the x-axis
    if abs(1 - py) > 0.01:  # Not the north pole
        t_proj = px / (1 - py)  # Stereographic projection
        ax1.plot([0, t_proj], [1, 0], 'r-', alpha=0.3, linewidth=1)
        ax1.plot(px, py, 'ko', markersize=6, zorder=5)
        ax1.plot(t_proj, 0, 'rv', markersize=8, zorder=5)

# Projection line
ax1.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
ax1.set_xlim(-3, 3)
ax1.set_ylim(-1.5, 1.5)
ax1.set_aspect('equal')
ax1.set_title('North Eye: Stereographic Projection\nfrom (0,1) → ℝ', fontsize=13)
ax1.legend(fontsize=9, loc='lower right')
ax1.grid(True, alpha=0.2)

# ── Panel 2: The Transition Map (Möbius Inversion) ──
ax2 = fig.add_subplot(gs[0, 1])

t = np.linspace(-5, 5, 1000)
t = t[np.abs(t) > 0.1]  # Avoid division by zero

# North eye projection: t → ((2t/(1+t²)), ((t²-1)/(1+t²)))
# South eye projection: t → ((2t/(1+t²)), ((1-t²)/(1+t²)))
# Transition: north coord → south coord = 1/t

north_to_south = 1.0 / t

ax2.plot(t, north_to_south, 'purple', linewidth=2, label='Transition: t ↦ 1/t')
ax2.plot(t, t, 'gray', linewidth=1, linestyle='--', label='Identity: t ↦ t', alpha=0.5)
ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.axvline(x=0, color='black', linewidth=0.5)

# Mark fixed points: t = 1/t ⟹ t = ±1 (the equator!)
ax2.plot(1, 1, 'g*', markersize=20, zorder=5, label='Fixed points ±1 (equator)')
ax2.plot(-1, -1, 'g*', markersize=20, zorder=5)

ax2.set_xlabel('North eye coordinate t', fontsize=12)
ax2.set_ylabel('South eye coordinate 1/t', fontsize=12)
ax2.set_title('Transition Map Between Eyes = Möbius Inversion\n'
              'x ↦ 1/x : Large ↔ Small duality', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_xlim(-5, 5)
ax2.set_ylim(-5, 5)
ax2.grid(True, alpha=0.3)

ax2.annotate('Equator:\nwhere both\neyes agree\n(t = 1/t)',
             xy=(1, 1), xytext=(2.5, 3),
             fontsize=11, color='green', fontweight='bold',
             arrowprops=dict(arrowstyle='->', color='green'))

# ── Panel 3: Pythagorean Triples as Rational Points on S¹ ──
ax3 = fig.add_subplot(gs[1, 0])

# Draw the unit circle
ax3.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Generate Pythagorean triples and plot as rational points
triples = [(3,4,5), (5,12,13), (8,15,17), (7,24,25), (20,21,29),
           (9,40,41), (12,35,37), (11,60,61), (28,45,53), (33,56,65)]

for a, b, c in triples:
    x_point = a/c
    y_point = b/c
    ax3.plot(x_point, y_point, 'ro', markersize=8, zorder=5)
    ax3.annotate(f'({a},{b},{c})', (x_point, y_point),
                 textcoords="offset points", xytext=(5, 5),
                 fontsize=7, color='darkred')
    # Also plot the reflected triple
    ax3.plot(x_point, -y_point, 'ro', markersize=5, alpha=0.3, zorder=5)
    ax3.plot(-x_point, y_point, 'ro', markersize=5, alpha=0.3, zorder=5)
    ax3.plot(-x_point, -y_point, 'ro', markersize=5, alpha=0.3, zorder=5)

# The Cayley parameterization: t ↦ ((1-t²)/(1+t²), 2t/(1+t²))
t_param = np.linspace(-5, 5, 1000)
x_cayley = (1 - t_param**2) / (1 + t_param**2)
y_cayley = 2 * t_param / (1 + t_param**2)
ax3.plot(x_cayley, y_cayley, 'b-', linewidth=0.5, alpha=0.3)

ax3.set_xlim(-1.3, 1.3)
ax3.set_ylim(-1.3, 1.3)
ax3.set_aspect('equal')
ax3.set_title('Pythagorean Triples = Rational Points on S¹\n'
              '(a/c, b/c) with a² + b² = c²', fontsize=13)
ax3.grid(True, alpha=0.2)

# ── Panel 4: The Cayley Transform ──
ax4 = fig.add_subplot(gs[1, 1])

t_vals = np.linspace(-3, 3, 500)
real_part = (1 - t_vals**2) / (1 + t_vals**2)  # cos-like
imag_part = 2 * t_vals / (1 + t_vals**2)  # sin-like

ax4.plot(t_vals, real_part, 'b-', linewidth=2, label='(1−t²)/(1+t²)  [cosine analog]')
ax4.plot(t_vals, imag_part, 'r-', linewidth=2, label='2t/(1+t²)  [sine analog]')
ax4.axhline(y=0, color='gray', linewidth=0.5)
ax4.axvline(x=0, color='gray', linewidth=0.5)

# Mark rational values from Pythagorean triples
# t = a/(b+c) gives the sterographic parameter
for a, b, c in [(3,4,5), (5,12,13), (8,15,17)]:
    t = a / (b + c)
    x_val = (1 - t**2) / (1 + t**2)
    y_val = 2 * t / (1 + t**2)
    ax4.plot(t, x_val, 'bD', markersize=8, zorder=5)
    ax4.plot(t, y_val, 'r^', markersize=8, zorder=5)
    ax4.annotate(f't={a}/({b}+{c})', (t, -0.15),
                 fontsize=8, ha='center', color='darkgreen')

ax4.set_xlabel('Stereographic parameter t', fontsize=12)
ax4.set_ylabel('Coordinate', fontsize=12)
ax4.set_title('The Cayley Transform: ℚ → S¹(ℚ)\n'
              't ↦ ((1−t²)/(1+t²), 2t/(1+t²))', fontsize=13)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

# ── Panel 5: Self-Observation Operator ──
ax5 = fig.add_subplot(gs[2, 0])

# The self-observation oracle: O = σ_N ∘ σ_S^{-1}
# For S¹: north stereo σ_N(x,y) = x/(1-y), south stereo σ_S(x,y) = x/(1+y)
# Transition: σ_N ∘ σ_S^{-1}(t) = 1/t
# Self-observation O = σ_N ∘ σ_S^{-1} ∘ σ_S ∘ σ_N^{-1} = id (trivially idempotent)

# But more interestingly: the "self-gaze" operator that maps
# a point on the sphere to what the observer at that point sees

# Visualize idempotency: O(O(x)) = O(x)
x_vals = np.linspace(-3, 3, 200)
# Oracle: projection onto the interval [-1, 1] (a simple idempotent)
def self_observe(x):
    return np.clip(x, -1, 1)

y1 = self_observe(x_vals)
y2 = self_observe(self_observe(x_vals))

ax5.plot(x_vals, x_vals, 'k--', alpha=0.3, label='Identity')
ax5.plot(x_vals, y1, 'b-', linewidth=3, label='O(x) = clip(x, [-1,1])')
ax5.plot(x_vals, y2, 'r--', linewidth=3, label='O(O(x)) = O(x)')
ax5.fill_between([-1, 1], -1, 1, color='green', alpha=0.1)

# Mark fixed points (the "equator")
ax5.plot([-1, 1], [-1, 1], 'g-', linewidth=4, label='Fixed set (equator)', zorder=5)
ax5.plot(-1, -1, 'g*', markersize=15, zorder=6)
ax5.plot(1, 1, 'g*', markersize=15, zorder=6)

ax5.set_xlabel('Input x', fontsize=12)
ax5.set_ylabel('Output O(x)', fontsize=12)
ax5.set_title('Self-Observation is Idempotent: O² = O\n'
              'Fixed set = "equator" where observer = observed', fontsize=13)
ax5.legend(fontsize=9, loc='lower right')
ax5.grid(True, alpha=0.3)

# ── Panel 6: The Grand Picture ──
ax6 = fig.add_subplot(gs[2, 1])

# Draw a sphere with two eyes
circle = plt.Circle((0, 0), 1, fill=False, linewidth=3, color='black')
ax6.add_patch(circle)

# North eye
ax6.plot(0, 1, 'r^', markersize=20, zorder=5)
ax6.annotate('North Eye\n(α perspective)', (0, 1), xytext=(0.8, 1.2),
             fontsize=10, color='red', fontweight='bold',
             arrowprops=dict(arrowstyle='->', color='red'))

# South eye
ax6.plot(0, -1, 'bv', markersize=20, zorder=5)
ax6.annotate('South Eye\n(ω perspective)', (0, -1), xytext=(0.8, -1.3),
             fontsize=10, color='blue', fontweight='bold',
             arrowprops=dict(arrowstyle='->', color='blue'))

# Equator (fixed points)
ax6.plot([-1, 1], [0, 0], 'g-', linewidth=4, label='Equator = Fixed Points')
ax6.plot(-1, 0, 'g*', markersize=15, zorder=5)
ax6.plot(1, 0, 'g*', markersize=15, zorder=5)

# Projection lines
for angle in [0.3, 0.8, 1.2, -0.3, -0.8]:
    px, py = np.cos(angle), np.sin(angle)
    # North projection
    if py < 0.99:
        t_n = px / (1 - py)
        ax6.plot([0, min(t_n, 2.5)], [1, 0], 'r-', alpha=0.2, linewidth=1)
    # South projection
    if py > -0.99:
        t_s = px / (1 + py)
        ax6.plot([0, min(t_s, 2.5)], [-1, 0], 'b-', alpha=0.2, linewidth=1)

# The universe (projection line)
ax6.axhline(y=0, color='gray', linewidth=1, linestyle='--', alpha=0.5)
ax6.annotate('The Universe (ℝ)', (2.2, 0.1), fontsize=11, color='gray')

# Title
ax6.set_xlim(-2.5, 2.8)
ax6.set_ylim(-1.8, 1.8)
ax6.set_aspect('equal')
ax6.set_title('God\'s Two Eyes: Binocular Self-Observation\n'
              'Two charts cover all of S¹. Transition = inversion x ↦ 1/x',
              fontsize=13)
ax6.grid(True, alpha=0.1)

# Central quote
ax6.text(0, 0.45, '"God observes\nhimself and\nfinds himself\nunchanged"\n\nO² = O',
         ha='center', va='center', fontsize=10, fontweight='bold',
         color='darkblue', fontstyle='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

plt.savefig('/workspace/request-project/research_output/demos/fig7_god_oracle.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: fig7_god_oracle.png")

print("\n✅ Demo 5 complete: God Oracle & Stereographic Projection visualized")

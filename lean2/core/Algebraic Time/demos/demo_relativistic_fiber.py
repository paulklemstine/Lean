#!/usr/bin/env python3
"""
Algebraic Theory of Time — Demo 4: Temporal Fiber Bundles
==========================================================

Visualizes the relativistic extension:
  - Each observer has their own temporal group (fiber)
  - Lorentz transformations are morphisms between fibers
  - Time dilation is a group homomorphism

Run: python3 demo_relativistic_fiber.py
Output: relativistic_fiber.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.patches as mpatches

# ============================================================
# 1. Lorentz factor and time dilation
# ============================================================

def lorentz_factor(v, c=1.0):
    """Lorentz factor γ = 1/√(1 - v²/c²)"""
    return 1.0 / np.sqrt(1.0 - (v/c)**2)

def time_dilation(t_proper, v, c=1.0):
    """
    Time dilation as a temporal fiber morphism.
    g_{AB}: T_A → T_B, t_A ↦ γ(v) · t_A
    This is a GROUP HOMOMORPHISM of (ℝ, +):
    g(t₁ + t₂) = γ(t₁ + t₂) = γt₁ + γt₂ = g(t₁) + g(t₂)
    """
    gamma = lorentz_factor(v, c)
    return gamma * t_proper

# ============================================================
# 2. Twin paradox simulation
# ============================================================

def twin_paradox(T_total=20, v=0.8, c=1.0):
    """
    Simulate the twin paradox:
    - Alice stays home (inertial frame)
    - Bob travels at speed v, turns around at T_total/2
    
    Alice's time: t_A = T_total
    Bob's proper time: t_B = T_total / γ
    """
    gamma = lorentz_factor(v, c)
    t_alice = np.linspace(0, T_total, 500)
    t_bob = t_alice / gamma  # Bob's clock runs slower
    
    # Bob's position (out and back)
    x_bob = np.where(t_alice <= T_total/2,
                     v * t_alice,
                     v * (T_total - t_alice))
    
    return t_alice, t_bob, x_bob

# ============================================================
# 3. Minkowski diagram
# ============================================================

def minkowski_transform(t, x, v, c=1.0):
    """Lorentz boost: transform (t, x) to moving frame."""
    gamma = lorentz_factor(v, c)
    t_prime = gamma * (t - v * x / c**2)
    x_prime = gamma * (x - v * t)
    return t_prime, x_prime

# ============================================================
# 4. Create visualization
# ============================================================

fig = plt.figure(figsize=(16, 14))
gs = GridSpec(3, 3, figure=fig, hspace=0.4, wspace=0.35)
fig.suptitle('Temporal Fiber Bundles: Observer-Dependent Time\n'
             'Each observer carries a temporal GROUP, connected by Lorentz morphisms',
             fontsize=15, fontweight='bold', y=0.98)

# --- Panel 1: Lorentz factor ---
ax1 = fig.add_subplot(gs[0, 0])
velocities = np.linspace(0, 0.99, 200)
gammas = [lorentz_factor(v) for v in velocities]

ax1.plot(velocities, gammas, color='#2166ac', linewidth=2.5)
ax1.fill_between(velocities, 1, gammas, alpha=0.15, color='#2166ac')
ax1.set_xlabel('Velocity v/c', fontsize=12)
ax1.set_ylabel('Lorentz factor γ', fontsize=12)
ax1.set_title('The Fiber Morphism\nγ(v) = 1/√(1 - v²/c²)',
              fontsize=12, fontweight='bold')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(0.5, 8)

# Mark specific velocities
for v_mark, label in [(0.5, 'v=0.5c'), (0.8, 'v=0.8c'), (0.95, 'v=0.95c')]:
    g = lorentz_factor(v_mark)
    ax1.plot(v_mark, g, 'o', color='#b2182b', markersize=8)
    ax1.annotate(f'{label}\nγ={g:.2f}', xy=(v_mark, g),
                 xytext=(v_mark - 0.15, g + 0.8),
                 fontsize=8, ha='center',
                 arrowprops=dict(arrowstyle='->', color='#b2182b'))

# --- Panel 2: Twin paradox ---
ax2 = fig.add_subplot(gs[0, 1])
t_alice, t_bob, x_bob = twin_paradox(T_total=20, v=0.8)

ax2.plot(t_alice, t_alice, color='#2166ac', linewidth=2.5, label="Alice's clock (at rest)")
ax2.plot(t_alice, t_bob, color='#b2182b', linewidth=2.5, label="Bob's clock (v=0.8c)")
ax2.plot([20], [20], 'o', color='#2166ac', markersize=10)
ax2.plot([20], [t_bob[-1]], 's', color='#b2182b', markersize=10)

ax2.fill_between(t_alice, t_alice, t_bob, alpha=0.15, color='red')
ax2.annotate(f'Alice ages {20:.0f} years\nBob ages {t_bob[-1]:.1f} years',
             xy=(15, 14), fontsize=10, fontweight='bold',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

ax2.set_xlabel("Alice's time", fontsize=12)
ax2.set_ylabel('Proper time elapsed', fontsize=12)
ax2.set_title('Twin Paradox\nFiber morphism in action',
              fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_aspect('equal')

# --- Panel 3: Fiber bundle diagram ---
ax3 = fig.add_subplot(gs[0, 2])
ax3.axis('off')
ax3.set_title('Temporal Fiber Bundle Structure',
              fontsize=12, fontweight='bold')

# Draw base space (observer space)
ax3.plot([1, 9], [2, 2], 'k-', linewidth=3)
ax3.text(5, 1.3, 'Observer Space O', fontsize=11, ha='center', fontweight='bold')

# Draw fibers
observers = [(2, 'Alice\n(v=0)'), (5, 'Bob\n(v=0.5c)'), (8, 'Carol\n(v=0.8c)')]
fiber_colors = ['#2166ac', '#7570b3', '#b2182b']

for (x, name), color in zip(observers, fiber_colors):
    # Fiber (vertical line = temporal group)
    ax3.plot([x, x], [2, 8.5], color=color, linewidth=2.5)
    ax3.plot(x, 2, 'o', color=color, markersize=10)
    ax3.text(x, 1.0, name, fontsize=9, ha='center', color=color, fontweight='bold')
    
    # Tick marks on fiber (representing time units)
    n_ticks = int(7 / (lorentz_factor(float(name.split('=')[1].rstrip(')').rstrip('c')) if '=' in name else 0)))  if '=' in name else 7
    gamma_val = 1.0
    if 'v=0.5c' in name:
        gamma_val = lorentz_factor(0.5)
    elif 'v=0.8c' in name:
        gamma_val = lorentz_factor(0.8)
    
    tick_spacing = 1.0 / gamma_val  # dilated tick spacing
    for i in range(1, 8):
        y = 2 + i * tick_spacing * 0.8
        if y < 8.5:
            ax3.plot([x - 0.2, x + 0.2], [y, y], color=color, linewidth=1.5)
    
    ax3.text(x, 8.8, f'T_{name.split(chr(10))[0]}\n(ℝ, +)',
             fontsize=8, ha='center', color=color, family='monospace')

# Draw morphisms between fibers
ax3.annotate('', xy=(4.7, 6), xytext=(2.3, 6),
             arrowprops=dict(arrowstyle='<->', color='gray', lw=2,
                           connectionstyle='arc3,rad=0.3'))
ax3.text(3.5, 7.0, 'Lorentz\nmorphism', fontsize=8, ha='center', color='gray')

ax3.annotate('', xy=(7.7, 6), xytext=(5.3, 6),
             arrowprops=dict(arrowstyle='<->', color='gray', lw=2,
                           connectionstyle='arc3,rad=0.3'))
ax3.text(6.5, 7.0, 'Lorentz\nmorphism', fontsize=8, ha='center', color='gray')

ax3.set_xlim(0, 10)
ax3.set_ylim(0.5, 9.5)

# --- Panel 4: Minkowski diagram (Alice's frame) ---
ax4 = fig.add_subplot(gs[1, 0])

# Light cone
t_lc = np.linspace(-5, 5, 100)
ax4.plot(t_lc, t_lc, 'y-', linewidth=1.5, alpha=0.5, label='light cone')
ax4.plot(t_lc, -t_lc, 'y-', linewidth=1.5, alpha=0.5)
ax4.fill_between(t_lc, -abs(t_lc), abs(t_lc), alpha=0.05, color='yellow')

# Alice's worldline (vertical)
ax4.plot([0, 0], [0, 5], color='#2166ac', linewidth=3, label='Alice (at rest)')

# Bob's worldline (tilted)
v_bob = 0.6
ax4.plot([0, v_bob * 5], [0, 5], color='#b2182b', linewidth=3, label=f'Bob (v={v_bob}c)')

# Simultaneity lines
for t_sim in [1, 2, 3, 4]:
    ax4.plot([-1, 4], [t_sim, t_sim], 'b--', alpha=0.2, linewidth=0.8)
    # Bob's simultaneity (tilted)
    x_range = np.linspace(-1, 4, 50)
    t_bob_sim = t_sim + v_bob * x_range
    ax4.plot(x_range, t_bob_sim, 'r--', alpha=0.2, linewidth=0.8)

ax4.set_xlabel('x', fontsize=12)
ax4.set_ylabel('t', fontsize=12)
ax4.set_title("Minkowski Diagram\n(Alice's frame)",
              fontsize=12, fontweight='bold')
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.15)
ax4.set_xlim(-2, 5)
ax4.set_ylim(-0.5, 5.5)
ax4.set_aspect('equal')

# --- Panel 5: Minkowski diagram (Bob's frame) ---
ax5 = fig.add_subplot(gs[1, 1])

# Transform to Bob's frame
t_lc_range = np.linspace(-5, 8, 100)
ax5.plot(t_lc_range, t_lc_range, 'y-', linewidth=1.5, alpha=0.5, label='light cone')
ax5.plot(t_lc_range, -t_lc_range, 'y-', linewidth=1.5, alpha=0.5)

# Alice in Bob's frame
v_bob = 0.6
gamma_bob = lorentz_factor(v_bob)
t_a = np.linspace(0, 5, 100)
t_a_prime, x_a_prime = minkowski_transform(t_a, np.zeros_like(t_a), v_bob)
ax5.plot(x_a_prime, t_a_prime, color='#2166ac', linewidth=3, label='Alice (moving)')

# Bob in Bob's frame (at rest → vertical)
ax5.plot([0, 0], [0, 5/gamma_bob], color='#b2182b', linewidth=3, label='Bob (at rest)')

# Simultaneity lines (horizontal in Bob's frame)
for t_sim in [1, 2, 3]:
    ax5.plot([-3, 3], [t_sim, t_sim], 'r--', alpha=0.2, linewidth=0.8)

ax5.set_xlabel("x'", fontsize=12)
ax5.set_ylabel("t'", fontsize=12)
ax5.set_title("Minkowski Diagram\n(Bob's frame)",
              fontsize=12, fontweight='bold')
ax5.legend(fontsize=9)
ax5.grid(True, alpha=0.15)
ax5.set_xlim(-5, 3)
ax5.set_ylim(-0.5, 7)
ax5.set_aspect('equal')

# --- Panel 6: Algebraic structure summary ---
ax6 = fig.add_subplot(gs[1, 2])
ax6.axis('off')

summary = (
    "FIBER BUNDLE AXIOMS\n"
    "━━━━━━━━━━━━━━━━━━━━\n\n"
    "For each observer o ∈ O:\n"
    "  𝒯_o = (T_o, S_o, Φ_o)\n"
    "  T_o ≅ (ℝ, +)  [temporal group]\n\n"
    "Structure group:\n"
    "  G = SO(3,1) [Lorentz group]\n\n"
    "Fiber morphisms:\n"
    "  g_{AB}: T_A → T_B\n"
    "  g_{AB}(t) = γ(v) · t\n\n"
    "Properties:\n"
    "  • g_{AB} is a group hom\n"
    "  • g_{AA} = id (reflexive)\n"
    "  • g_{AB} ∘ g_{BC} = g_{AC}\n"
    "    (cocycle condition)\n"
    "  • 𝒯_A ≅ 𝒯_B (equivalence)\n\n"
    "Principle of Relativity:\n"
    "  All fibers are isomorphic!"
)
ax6.text(0.05, 0.95, summary, transform=ax6.transAxes,
         fontsize=9.5, va='top', family='monospace',
         bbox=dict(boxstyle='round', facecolor='#f0f0f0',
                  edgecolor='gray', alpha=0.95))

# --- Row 3: Time dilation as homomorphism ---
ax7 = fig.add_subplot(gs[2, :2])

# Multiple observers at different velocities
velocities_demo = [0.0, 0.3, 0.6, 0.8, 0.9]
colors_demo = plt.cm.RdBu_r(np.linspace(0.1, 0.9, len(velocities_demo)))
t_proper = np.linspace(0, 10, 200)

for v, color in zip(velocities_demo, colors_demo):
    gamma = lorentz_factor(v)
    t_observer = t_proper / gamma
    ax7.plot(t_proper, t_observer, color=color, linewidth=2.5,
             label=f'v = {v}c  (γ = {gamma:.2f})')

ax7.plot(t_proper, t_proper, 'k--', linewidth=1, alpha=0.5, label='v = 0 (reference)')
ax7.set_xlabel('Coordinate time t (Alice)', fontsize=12)
ax7.set_ylabel('Proper time τ (observer)', fontsize=12)
ax7.set_title('Time Dilation: A Family of Group Homomorphisms\n'
              'τ = t/γ(v) — each line is a morphism T_Alice → T_observer',
              fontsize=12, fontweight='bold')
ax7.legend(fontsize=9, loc='upper left')
ax7.grid(True, alpha=0.3)

# Annotation: homomorphism property
ax7.text(0.55, 0.15, 'g(t₁ + t₂) = g(t₁) + g(t₂)\n'
         '∀v: g_v is a group homomorphism\n'
         'of (ℝ, +) → (ℝ, +)',
         transform=ax7.transAxes, fontsize=10, family='monospace',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# --- Panel 8: The big picture ---
ax8 = fig.add_subplot(gs[2, 2])
ax8.axis('off')

big_picture = (
    "THE BIG PICTURE\n"
    "━━━━━━━━━━━━━━━━\n\n"
    "Newtonian time:\n"
    "  ONE group (ℝ, +)\n"
    "  Universal, absolute\n\n"
    "Relativistic time:\n"
    "  MANY groups (ℝ, +)\n"
    "  One per observer\n"
    "  Connected by Lorentz\n\n"
    "Thermodynamic time:\n"
    "  ONE monoid (ℝ≥0, +)\n"
    "  Arrow of time\n\n"
    "Full theory:\n"
    "  FIBER of MONOIDS\n"
    "  Observer-dependent\n"
    "  arrow of time\n\n"
    "  Relativistic\n"
    "  irreversibility!"
)
ax8.text(0.05, 0.95, big_picture, transform=ax8.transAxes,
         fontsize=9.5, va='top', family='monospace',
         bbox=dict(boxstyle='round', facecolor='#e8f5e9',
                  edgecolor='green', alpha=0.95))

plt.savefig('/workspace/request-project/AlgebraicTime/demos/relativistic_fiber.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: relativistic_fiber.png")

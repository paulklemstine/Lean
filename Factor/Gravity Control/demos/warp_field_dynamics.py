#!/usr/bin/env python3
"""
Warp Field Dynamics & Sci-Fi Technology Simulator
==================================================

Simulates various sci-fi propulsion and gravity control concepts,
grounding each in real physics:

1. Warp field dynamics (time evolution of Alcubierre bubble)
2. Artificial gravity via rotation (space stations)
3. Tractor beams (gravitational focusing)
4. Inertial dampening (geodesic motion in curved spacetime)
5. Hyperspace jumps (topology change visualization)
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.patches import FancyBboxPatch, Wedge, Arc
import os

output_dir = os.path.dirname(os.path.abspath(__file__))

# ============================================================
# 1. Warp Bubble Time Evolution
# ============================================================
def warp_field_evolution():
    """Simulate warp bubble formation, cruise, and collapse."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle("Warp Bubble Lifecycle: Formation → Cruise → Deceleration",
                 fontsize=16, fontweight='bold')
    
    N = 200
    x = np.linspace(-5, 5, N)
    y = np.linspace(-5, 5, N)
    X, Y = np.meshgrid(x, y)
    
    R = 1.0
    sigma_max = 8.0
    
    phases = [
        ('t = 0: Flat Space', 0, 0),
        ('t = 1: Bubble Forming', 0.3, 2),
        ('t = 2: Bubble Growing', 0.7, 5),
        ('t = 3: Full Warp (v = c)', 1.0, 8),
        ('t = 4: Decelerating', 0.5, 6),
        ('t = 5: Bubble Collapsed', 0, 0),
    ]
    
    for idx, (title, v_s, sigma) in enumerate(phases):
        ax = axes[idx // 3, idx % 3]
        R_s = np.sqrt(X**2 + Y**2)
        
        if sigma > 0:
            f = (np.tanh(sigma * (R_s + R)) - np.tanh(sigma * (R_s - R))) / (2 * np.tanh(sigma * R))
        else:
            f = np.zeros_like(R_s)
        
        # York time
        if sigma > 0:
            dr = 1e-4
            df = ((np.tanh(sigma * (R_s + dr + R)) - np.tanh(sigma * (R_s + dr - R))) / (2 * np.tanh(sigma * R)) -
                  (np.tanh(sigma * (R_s - dr + R)) - np.tanh(sigma * (R_s - dr - R))) / (2 * np.tanh(sigma * R))) / (2 * dr)
            with np.errstate(divide='ignore', invalid='ignore'):
                theta = v_s * X / R_s * df
                theta = np.where(np.isfinite(theta), theta, 0)
        else:
            theta = np.zeros_like(R_s)
        
        vmax = max(np.max(np.abs(theta)), 0.01)
        im = ax.pcolormesh(X, Y, theta, cmap='RdBu_r', shading='auto',
                          vmin=-vmax, vmax=vmax)
        
        circle = plt.Circle((0, 0), R, fill=False, color='white', linewidth=2, linestyle='--')
        ax.add_patch(circle)
        
        if v_s > 0:
            ax.annotate('', xy=(v_s * 2, 0), xytext=(0, 0),
                       arrowprops=dict(arrowstyle='->', color='yellow', lw=2))
        
        ax.plot(0, 0, 'w*', markersize=10)  # Ship
        ax.set_title(f'{title}\nv = {v_s}c', fontsize=12)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.set_aspect('equal')
        ax.set_xlim(-4, 4)
        ax.set_ylim(-4, 4)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'warp_lifecycle.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: warp_lifecycle.png")

# ============================================================
# 2. Artificial Gravity via Rotation
# ============================================================
def rotating_space_station():
    """Simulate artificial gravity in a rotating space station (the real way to do it!)."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle("Artificial Gravity: The Centrifuge Approach (Real Physics!)",
                 fontsize=16, fontweight='bold')
    
    # Panel 1: Space station schematic
    ax = axes[0]
    theta = np.linspace(0, 2*np.pi, 100)
    R_station = 100  # meters
    
    # Outer ring
    ax.plot(R_station * np.cos(theta), R_station * np.sin(theta), 'b-', linewidth=3)
    ax.plot(0.9*R_station * np.cos(theta), 0.9*R_station * np.sin(theta), 'b-', linewidth=1)
    
    # Spokes
    for angle in np.linspace(0, 2*np.pi, 6, endpoint=False):
        ax.plot([0, R_station*np.cos(angle)], [0, R_station*np.sin(angle)], 
               'gray', linewidth=1, alpha=0.5)
    
    # Hub
    hub = plt.Circle((0, 0), 10, facecolor='lightgray', edgecolor='black')
    ax.add_patch(hub)
    
    # People on floor (outer ring)
    for angle in [0, np.pi/3, 2*np.pi/3, np.pi, 4*np.pi/3, 5*np.pi/3]:
        px = 0.95 * R_station * np.cos(angle)
        py = 0.95 * R_station * np.sin(angle)
        ax.plot(px, py, 'r^', markersize=8)
    
    # Rotation arrow
    arc_theta = np.linspace(0.1, 0.5, 50)
    ax.plot(50*np.cos(arc_theta), 50*np.sin(arc_theta), 'g-', linewidth=2)
    ax.annotate('', xy=(50*np.cos(0.5), 50*np.sin(0.5)),
               xytext=(50*np.cos(0.45), 50*np.sin(0.45)),
               arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax.text(55, 30, 'ω', fontsize=16, color='green')
    
    ax.set_title(f'Space Station (R = {R_station} m)\nPeople stand on outer ring', fontsize=13)
    ax.set_xlim(-150, 150)
    ax.set_ylim(-150, 150)
    ax.set_aspect('equal')
    ax.set_xlabel('meters')
    ax.set_ylabel('meters')
    
    # Panel 2: Effective gravity vs radius and rotation rate
    ax = axes[1]
    R_vals = np.array([50, 100, 200, 500, 1000])
    omega_range = np.linspace(0, 0.5, 1000)  # rad/s
    
    g_earth = 9.81
    
    for R_val in R_vals:
        g_eff = omega_range**2 * R_val
        ax.plot(omega_range * 60 / (2*np.pi), g_eff / g_earth, linewidth=2, 
               label=f'R = {R_val} m')
    
    ax.axhline(1.0, color='red', linestyle='--', alpha=0.5, label='Earth gravity')
    ax.axhline(0.38, color='orange', linestyle=':', alpha=0.5, label='Mars gravity')
    ax.axhline(0.17, color='yellow', linestyle=':', alpha=0.5, label='Moon gravity')
    
    ax.set_xlabel('Rotation Rate (RPM)', fontsize=12)
    ax.set_ylabel('Effective Gravity (g)', fontsize=12)
    ax.set_title('Effective Gravity = ω²R\nLarger radius → slower spin needed', fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.set_xlim(0, 5)
    ax.set_ylim(0, 2)
    ax.grid(True, alpha=0.3)
    
    # Comfort zone
    ax.axvspan(0, 2, alpha=0.05, color='green')
    ax.text(1, 1.8, 'Comfort zone\n(< 2 RPM)', fontsize=10, color='green',
           ha='center', style='italic')
    
    # Panel 3: Coriolis effects
    ax = axes[2]
    omega = 0.1  # rad/s (about 1 RPM)
    R_s = 100  # m
    
    # Throw a ball radially inward
    dt = 0.01
    t_max = 3.0
    t = np.arange(0, t_max, dt)
    
    # In rotating frame: Coriolis force = -2mω×v, centrifugal = -mω×(ω×r)
    x_ball = np.zeros_like(t)
    y_ball = np.zeros_like(t)
    vx = np.zeros_like(t)
    vy = np.zeros_like(t)
    
    # Start at "floor" (bottom of ring), throw "upward" (toward center)
    x_ball[0] = 0
    y_ball[0] = -R_s
    vx[0] = 0
    vy[0] = 5  # 5 m/s upward (toward center)
    
    for i in range(len(t) - 1):
        r = np.sqrt(x_ball[i]**2 + y_ball[i]**2)
        # Centrifugal: outward
        if r > 0:
            Fx_cent = omega**2 * x_ball[i]
            Fy_cent = omega**2 * y_ball[i]
        else:
            Fx_cent = Fy_cent = 0
        # Coriolis: -2ω × v (ω along z)
        Fx_cor = 2 * omega * vy[i]
        Fy_cor = -2 * omega * vx[i]
        
        ax_total = Fx_cent + Fx_cor
        ay_total = Fy_cent + Fy_cor
        
        vx[i+1] = vx[i] + ax_total * dt
        vy[i+1] = vy[i] + ay_total * dt
        x_ball[i+1] = x_ball[i] + vx[i+1] * dt
        y_ball[i+1] = y_ball[i] + vy[i+1] * dt
    
    # Plot in rotating frame
    ax.plot(x_ball, y_ball + R_s, 'r-', linewidth=2, label='Ball trajectory\n(rotating frame)')
    ax.plot(x_ball[0], y_ball[0] + R_s, 'go', markersize=10, label='Start')
    ax.plot(x_ball[-1], y_ball[-1] + R_s, 'rx', markersize=10, label='End')
    
    # Floor
    ax.axhline(0, color='brown', linewidth=3)
    ax.text(0, -2, '"Floor" (outer ring)', ha='center', fontsize=10, color='brown')
    
    ax.set_xlabel('Lateral displacement (m)', fontsize=12)
    ax.set_ylabel('Height above floor (m)', fontsize=12)
    ax.set_title(f'Coriolis Effect on Thrown Ball\n'
                 f'ω = {omega:.2f} rad/s, R = {R_s} m\n'
                 f'Ball curves sideways!', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'artificial_gravity.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: artificial_gravity.png")

# ============================================================
# 3. Inertial Dampening via Geodesic Motion
# ============================================================
def inertial_dampening():
    """Demonstrate why warp drive passengers feel no acceleration."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 7))
    fig.suptitle("Inertial Dampening: Why Warp Drive Passengers Feel Nothing",
                 fontsize=16, fontweight='bold')
    
    # Panel 1: Conventional rocket — passengers feel acceleration
    ax = axes[0]
    
    t = np.linspace(0, 10, 1000)
    a_rocket = 3 * 9.81  # 3g acceleration
    
    # Rocket position
    x_rocket = 0.5 * a_rocket * t**2
    
    # Passenger experiences g-force
    g_force = a_rocket / 9.81
    
    ax2 = ax.twinx()
    ax.plot(t, x_rocket / 1000, 'b-', linewidth=2, label='Position (km)')
    ax2.plot(t, np.ones_like(t) * g_force, 'r-', linewidth=2, label=f'G-force = {g_force:.0f}g')
    
    # Danger zones
    ax2.axhspan(5, 15, alpha=0.1, color='red')
    ax2.text(5, 6, 'DANGEROUS', fontsize=11, color='red', ha='center')
    ax2.axhspan(0, 1, alpha=0.1, color='green')
    ax2.text(5, 0.5, 'Comfortable', fontsize=11, color='green', ha='center')
    
    ax.set_xlabel('Time (s)', fontsize=12)
    ax.set_ylabel('Position (km)', fontsize=12, color='blue')
    ax2.set_ylabel('G-force experienced', fontsize=12, color='red')
    ax.set_title('Conventional Rocket\nPassengers crushed by acceleration!', fontsize=13)
    ax.legend(loc='upper left', fontsize=10)
    ax2.legend(loc='center right', fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Warp drive — geodesic motion, no g-force
    ax = axes[1]
    
    # Warp bubble position (can go FTL!)
    v_warp = np.concatenate([
        np.linspace(0, 3e8, 200),    # Accelerating
        np.ones(600) * 3e8,           # Cruising at c
        np.linspace(3e8, 0, 200)      # Decelerating
    ])
    x_warp = np.cumsum(v_warp) * (t[1] - t[0])
    
    g_felt = np.zeros_like(t)  # ZERO g-force throughout!
    
    ax2 = ax.twinx()
    ax.plot(t, x_warp / 1e9, 'b-', linewidth=2, label='Position (10⁹ m)')
    ax2.plot(t, g_felt, 'g-', linewidth=3, label='G-force = 0g (always!)')
    
    ax2.axhspan(-0.5, 0.5, alpha=0.1, color='green')
    ax2.text(5, 0.3, 'ALWAYS Comfortable\n(geodesic motion)', fontsize=11, 
            color='green', ha='center', fontweight='bold')
    
    ax.set_xlabel('Time (s)', fontsize=12)
    ax.set_ylabel('Position (×10⁹ m)', fontsize=12, color='blue')
    ax2.set_ylabel('G-force experienced', fontsize=12, color='green')
    ax.set_title('Warp Drive\nPassengers in free-fall (geodesic) — zero g-force!', fontsize=13)
    ax.legend(loc='upper left', fontsize=10)
    ax2.legend(loc='center right', fontsize=10)
    ax2.set_ylim(-1, 5)
    ax.grid(True, alpha=0.3)
    
    # Physics explanation
    fig.text(0.5, 0.01, 
             "KEY PHYSICS: In a warp drive, the ship doesn't accelerate through space — "
             "space moves around the ship.\n"
             "The ship follows a geodesic (free-fall path) in curved spacetime, "
             "so occupants experience zero proper acceleration.\n"
             "This is the same reason astronauts feel weightless in orbit — "
             "they're in free-fall (following geodesics).",
             fontsize=11, ha='center', style='italic',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))
    
    plt.tight_layout(rect=[0, 0.08, 1, 0.95])
    plt.savefig(os.path.join(output_dir, 'inertial_dampening.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: inertial_dampening.png")

# ============================================================
# 4. Sci-Fi Technology Feasibility Map
# ============================================================
def scifi_feasibility():
    """Map sci-fi technologies onto physics feasibility axes."""
    fig, ax = plt.subplots(figsize=(14, 10))
    
    technologies = {
        'Maglev Train': (0, 0, '✅'),
        'Diamagnetic Levitation': (1, 0, '✅'),
        'Ion Drive': (0, 1, '✅'),
        'Solar Sail': (0, 2, '✅'),
        'Nuclear Pulse\nPropulsion': (2, 3, '🔬'),
        'Artificial Gravity\n(Centrifuge)': (1, 1, '✅'),
        'Space Elevator': (2, 1, '🔬'),
        'Fusion Rocket': (3, 2, '🔬'),
        'Antimatter\nPropulsion': (4, 3, '🔬'),
        'Gravitomagnetic\nResonance': (5, 2, '❓'),
        'Casimir-Gravity\nCoupling': (6, 1, '❓'),
        'Gravitational\nMetamaterial': (7, 3, '❓'),
        'Tractor Beam\n(Gravitational)': (8, 4, '❓'),
        'Inertial Dampener': (7, 5, '❌'),
        'Antigravity': (9, 5, '❌'),
        'Warp Drive': (9, 7, '❌'),
        'Wormhole': (10, 8, '❌'),
        'Time Machine': (10, 10, '❌'),
    }
    
    colors = {'✅': '#2ecc71', '🔬': '#f1c40f', '❓': '#e67e22', '❌': '#e74c3c'}
    
    for name, (x, y, status) in technologies.items():
        color = colors[status]
        ax.scatter(x, y, s=200, c=color, edgecolors='black', zorder=5)
        ax.annotate(name, xy=(x, y), xytext=(x + 0.3, y + 0.2),
                   fontsize=9, fontweight='bold')
    
    ax.set_xlabel('Physics Challenge Level\n(0 = Known physics → 10 = New physics required)', fontsize=13)
    ax.set_ylabel('Engineering Challenge Level\n(0 = Current tech → 10 = Far future)', fontsize=13)
    ax.set_title('Sci-Fi Technology Feasibility Map\n'
                 'Where does each technology fall on the physics/engineering axes?',
                 fontsize=15, fontweight='bold')
    
    # Legend
    for status, color in colors.items():
        label = {'✅': 'Demonstrated', '🔬': 'Under Development', 
                '❓': 'Theoretical (Testable)', '❌': 'Requires New Physics'}[status]
        ax.scatter([], [], c=color, s=100, edgecolors='black', label=f'{status} {label}')
    ax.legend(loc='upper left', fontsize=11, framealpha=0.9)
    
    # Zones
    ax.axvspan(0, 3, alpha=0.05, color='green')
    ax.axvspan(3, 7, alpha=0.05, color='yellow')
    ax.axvspan(7, 11, alpha=0.05, color='red')
    
    ax.text(1.5, 9, 'Known\nPhysics', fontsize=14, ha='center', color='green', alpha=0.5)
    ax.text(5, 9, 'Testable\nHypotheses', fontsize=14, ha='center', color='orange', alpha=0.5)
    ax.text(9, 9, 'New Physics\nRequired', fontsize=14, ha='center', color='red', alpha=0.5)
    
    ax.set_xlim(-0.5, 11)
    ax.set_ylim(-0.5, 11)
    ax.grid(True, alpha=0.2)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'scifi_feasibility_map.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: scifi_feasibility_map.png")

# ============================================================
# Run all simulations
# ============================================================
if __name__ == '__main__':
    warp_field_evolution()
    rotating_space_station()
    inertial_dampening()
    scifi_feasibility()
    
    print("\n🌟 All warp field dynamics simulations complete!")
    print("Key insights:")
    print("  1. Warp drives provide built-in inertial dampening (geodesic motion)")
    print("  2. Artificial gravity via rotation is fully achievable today")
    print("  3. Most sci-fi technologies have a basis in real physics")
    print("  4. The gap between 'possible in principle' and 'possible in practice' is vast")

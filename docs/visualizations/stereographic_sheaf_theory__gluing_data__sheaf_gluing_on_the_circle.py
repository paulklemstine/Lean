"""
Visualization 3: Sheaf Gluing on the Circle

Visualizes how local sections on two overlapping charts of S^1 glue
(or fail to glue) into a global section. Shows the Mayer-Vietoris
exact sequence geometrically: sections that agree on the overlap
extend globally; those that don't create a cohomological obstruction.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Two-chart cover of S^1
ax = axes[0]
theta = np.linspace(0, 2*np.pi, 500)

# Draw the circle
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1)

# North chart: everything except north pole (0, -1)
# Covering angle: roughly -π + ε to π - ε
theta_north = np.linspace(-0.8*np.pi, 0.8*np.pi, 200)
ax.plot(np.cos(theta_north), np.sin(theta_north), 'b-', linewidth=5, alpha=0.3, label='U_N (north chart)')

# South chart: everything except south pole (0, 1)
theta_south_1 = np.linspace(0.2*np.pi, np.pi, 100)
theta_south_2 = np.linspace(-np.pi, -0.2*np.pi, 100)
theta_south = np.concatenate([theta_south_1, theta_south_2])
ax.plot(np.cos(theta_south), np.sin(theta_south), 'r-', linewidth=5, alpha=0.3, label='U_S (south chart)')

# Overlap regions
theta_overlap1 = np.linspace(0.2*np.pi, 0.8*np.pi, 100)
theta_overlap2 = np.linspace(-0.8*np.pi, -0.2*np.pi, 100)
ax.plot(np.cos(theta_overlap1), np.sin(theta_overlap1), 'g-', linewidth=8, alpha=0.4)
ax.plot(np.cos(theta_overlap2), np.sin(theta_overlap2), 'g-', linewidth=8, alpha=0.4, label='Overlap U_N ∩ U_S')

# Mark poles
ax.plot(0, 1, 'b^', markersize=12, zorder=5)
ax.annotate('South pole\n(origin of U_N)', (0, 1), textcoords="offset points",
            xytext=(15, 10), fontsize=8)
ax.plot(0, -1, 'rv', markersize=12, zorder=5)
ax.annotate('North pole\n(origin of U_S)', (0, -1), textcoords="offset points",
            xytext=(15, -20), fontsize=8)

ax.set_xlim(-1.6, 1.6)
ax.set_ylim(-1.6, 1.6)
ax.set_aspect('equal')
ax.set_title('Two-Chart Cover of S¹', fontsize=12)
ax.legend(fontsize=8, loc='lower left')
ax.grid(True, alpha=0.2)

# Panel 2: Successful gluing (compatible sections)
ax = axes[1]

t_north = np.linspace(-3, 3, 200)
t_south = np.linspace(-3, 3, 200)

# Section on north chart: f(t) = cos(t)
f_north = np.cos(t_north)

# For trivial gluing, section on south chart should match
f_south = np.cos(t_south)

# Overlap region (say |t| in [0.5, 2])
overlap_mask_n = (np.abs(t_north) > 0.5) & (np.abs(t_north) < 2)
overlap_mask_s = (np.abs(t_south) > 0.5) & (np.abs(t_south) < 2)

ax.plot(t_north, f_north, 'b-', linewidth=2, label='Section on U_N')
ax.plot(t_south, f_south, 'r--', linewidth=2, alpha=0.7, label='Section on U_S')
ax.fill_between(t_north, -1.5, 1.5, where=overlap_mask_n,
                color='green', alpha=0.1, label='Overlap')

# Cech differential
diff = f_north - f_south  # trivial transition
ax.plot(t_north, diff, 'g-', linewidth=1, alpha=0.5, label='d⁰(f_N, f_S) = 0')

ax.set_xlabel('t (chart coordinate)', fontsize=10)
ax.set_ylabel('Section value', fontsize=10)
ax.set_title('Successful Gluing\n(Trivial Transition, H¹ = 0)', fontsize=11)
ax.legend(fontsize=8)
ax.set_ylim(-1.5, 1.5)
ax.grid(True, alpha=0.2)

# Panel 3: Failed gluing (obstruction)
ax = axes[2]

# Section on north chart: f(t) = t
f_north_bad = t_north

# For negation gluing, transition is t -> -t
# So f_south should satisfy f_south(1/t) = -f_north(t) on overlap
# But let's use a different section that creates an obstruction
f_south_bad = -t_south + 1  # shifted, doesn't match

# Overlap region
ax.plot(t_north, f_north_bad, 'b-', linewidth=2, label='Section on U_N: f(t) = t')
ax.plot(t_south, f_south_bad, 'r--', linewidth=2, alpha=0.7, label='Section on U_S: g(t) = -t + 1')

# Negation transition: d(a,b) = -a - b
diff_neg = -f_north_bad - f_south_bad
ax.plot(t_north, diff_neg, 'g-', linewidth=2, alpha=0.8, label='d⁰ = -f - g = -1 ≠ 0')

ax.fill_between(t_north, -5, 5, where=overlap_mask_n,
                color='red', alpha=0.05)

ax.axhline(y=0, color='k', linewidth=0.5, alpha=0.3)
ax.set_xlabel('t (chart coordinate)', fontsize=10)
ax.set_ylabel('Section value', fontsize=10)
ax.set_title('Failed Gluing\n(Negation Transition, H¹ ≠ 0)', fontsize=11)
ax.legend(fontsize=8)
ax.set_ylim(-5, 5)
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_sheaf_gluing.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_sheaf_gluing.png")

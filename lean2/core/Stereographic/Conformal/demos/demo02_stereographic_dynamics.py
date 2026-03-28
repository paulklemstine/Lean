#!/usr/bin/env python3
"""
Demo 02: Stereographic Dynamics — Pulling Back Flows from R² to S²
====================================================================
Every vector field in the plane induces a vector field on the sphere via
the differential of inverse stereographic projection. Simple flows become
beautifully complex on the sphere.

Oracle Δ's Discovery: Linear flows become conformally damped on S².
The conformal factor creates position-dependent "time dilation."
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D

def inverse_stereo(y1, y2):
    """Inverse stereographic projection R² → S²"""
    D = 1.0 + y1**2 + y2**2
    return 2*y1/D, 2*y2/D, (D-2)/D

def stereo_forward(x1, x2, x3):
    """Forward stereographic projection S² → R² (from north pole)"""
    denom = 1.0 - x3
    mask = np.abs(denom) > 1e-10
    y1 = np.where(mask, x1 / denom, np.nan)
    y2 = np.where(mask, x2 / denom, np.nan)
    return y1, y2

fig = plt.figure(figsize=(20, 20))
fig.suptitle("Stereographic Dynamics: Simple Flows in R² Become Complex on S²",
             fontsize=16, fontweight='bold', y=0.98)

# Define 4 different flows in R²
flows = [
    ("Linear Source: ẏ = y", lambda y1, y2: (y1, y2)),
    ("Rotation: ẏ = (-y₂, y₁)", lambda y1, y2: (-y2, y1)),
    ("Saddle: ẏ = (y₁, -y₂)", lambda y1, y2: (y1, -y2)),
    ("Spiral Sink: ẏ = (-y-y⊥)/2", lambda y1, y2: (-y1/2 + y2, -y1 - y2/2)),
]

for idx, (title, flow_fn) in enumerate(flows):
    # --- Left: Flow in R² ---
    ax_flat = fig.add_subplot(4, 2, 2*idx + 1)
    Y = np.linspace(-3, 3, 20)
    Y1, Y2 = np.meshgrid(Y, Y)
    V1, V2 = flow_fn(Y1, Y2)
    speed = np.sqrt(V1**2 + V2**2 + 0.01)
    ax_flat.streamplot(Y, Y, V1, V2, color=speed, cmap='coolwarm',
                       linewidth=1.5, density=1.8, arrowsize=1.3)
    
    # Integrate trajectories
    dt = 0.01
    n_steps = 2000
    starts = [(1, 0), (0, 1), (-1, 0), (0, -1), (2, 0), (0, 2),
              (0.5, 0.5), (-0.5, 0.5), (1.5, 1.5)]
    colors_traj = cm.Set1(np.linspace(0, 1, len(starts)))
    
    trajectories = []
    for (s1, s2), c in zip(starts, colors_traj):
        traj = [(s1, s2)]
        y1, y2 = s1, s2
        for _ in range(n_steps):
            v1, v2 = flow_fn(y1, y2)
            y1 += v1 * dt
            y2 += v2 * dt
            if y1**2 + y2**2 > 50:
                break
            traj.append((y1, y2))
        traj = np.array(traj)
        trajectories.append(traj)
        ax_flat.plot(traj[:, 0], traj[:, 1], color=c, linewidth=1.5, alpha=0.7)
    
    ax_flat.set_xlim(-3.5, 3.5)
    ax_flat.set_ylim(-3.5, 3.5)
    ax_flat.set_aspect('equal')
    ax_flat.set_title(f'R²: {title}', fontsize=12)
    ax_flat.grid(True, alpha=0.2)
    
    # --- Right: Same flow pulled back to S² ---
    ax_sphere = fig.add_subplot(4, 2, 2*idx + 2, projection='3d')
    
    # Sphere wireframe
    u_s = np.linspace(0, 2*np.pi, 50)
    v_s = np.linspace(0, np.pi, 25)
    xs = np.outer(np.cos(u_s), np.sin(v_s))
    ys = np.outer(np.sin(u_s), np.sin(v_s))
    zs = np.outer(np.ones_like(u_s), np.cos(v_s))
    ax_sphere.plot_wireframe(xs, ys, zs, color='lightblue', alpha=0.1, linewidth=0.3)
    
    # Project trajectories onto sphere
    for traj, c in zip(trajectories, colors_traj):
        x1, x2, x3 = inverse_stereo(traj[:, 0], traj[:, 1])
        ax_sphere.plot(x1, x2, x3, color=c, linewidth=1.8, alpha=0.85)
        ax_sphere.scatter([x1[0]], [x2[0]], [x3[0]], color=c, s=30, zorder=5)
    
    ax_sphere.set_title(f'S²: Pulled-back Flow', fontsize=12)
    ax_sphere.set_box_aspect([1, 1, 1])
    ax_sphere.view_init(elev=20, azim=-50)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('/workspace/request-project/demos/demo02_stereographic_dynamics.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 02 saved: demos/demo02_stereographic_dynamics.png")

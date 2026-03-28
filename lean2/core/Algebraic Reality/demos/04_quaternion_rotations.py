#!/usr/bin/env python3
"""
Demo 4: Quaternion Rotations and Non-Commutativity
===================================================
Demonstrates that quaternion multiplication is non-commutative,
and shows how this non-commutativity IS the physics of spin.

The Algebraic Theory of Reality
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

class Quaternion:
    """Simple quaternion implementation for visualization."""
    def __init__(self, w, x, y, z):
        self.w, self.x, self.y, self.z = w, x, y, z

    def __mul__(self, other):
        return Quaternion(
            self.w*other.w - self.x*other.x - self.y*other.y - self.z*other.z,
            self.w*other.x + self.x*other.w + self.y*other.z - self.z*other.y,
            self.w*other.y - self.x*other.z + self.y*other.w + self.z*other.x,
            self.w*other.z + self.x*other.y - self.y*other.x + self.z*other.w
        )

    def conjugate(self):
        return Quaternion(self.w, -self.x, -self.y, -self.z)

    def norm(self):
        return np.sqrt(self.w**2 + self.x**2 + self.y**2 + self.z**2)

    def rotate_vector(self, v):
        """Rotate vector v = (vx, vy, vz) by this unit quaternion."""
        p = Quaternion(0, v[0], v[1], v[2])
        result = self * p * self.conjugate()
        return np.array([result.x, result.y, result.z])

    def __repr__(self):
        parts = []
        if abs(self.w) > 1e-10: parts.append(f'{self.w:.2f}')
        if abs(self.x) > 1e-10: parts.append(f'{self.x:+.2f}i')
        if abs(self.y) > 1e-10: parts.append(f'{self.y:+.2f}j')
        if abs(self.z) > 1e-10: parts.append(f'{self.z:+.2f}k')
        return ' '.join(parts) if parts else '0'

    @staticmethod
    def from_axis_angle(axis, angle):
        """Create rotation quaternion from axis and angle."""
        axis = np.array(axis, dtype=float)
        axis = axis / np.linalg.norm(axis)
        s = np.sin(angle / 2)
        c = np.cos(angle / 2)
        return Quaternion(c, axis[0]*s, axis[1]*s, axis[2]*s)

def draw_axes_frame(ax, origin, quat, length=1.0, alpha=0.8, lw=2):
    """Draw a rotated coordinate frame."""
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1']
    labels = ['x', 'y', 'z']
    basis = [np.array([1,0,0]), np.array([0,1,0]), np.array([0,0,1])]

    for i, (b, c, l) in enumerate(zip(basis, colors, labels)):
        v = quat.rotate_vector(b) * length
        ax.quiver(origin[0], origin[1], origin[2],
                 v[0], v[1], v[2],
                 color=c, alpha=alpha, linewidth=lw, arrow_length_ratio=0.15)

def create_quaternion_demo():
    """Create the quaternion rotation visualization."""
    fig = plt.figure(figsize=(18, 14), facecolor='#0a0a1a')

    # ===== Panel 1: Non-commutativity demonstration =====
    ax1 = fig.add_subplot(221, facecolor='#0a0a1a')
    ax1.axis('off')
    ax1.set_title('Quaternion Multiplication Table\ni² = j² = k² = ijk = -1',
                 color='white', fontsize=12, pad=10)

    # Multiplication table
    table = [
        ['×', '1', 'i', 'j', 'k'],
        ['1', '1', 'i', 'j', 'k'],
        ['i', 'i', '-1', 'k', '-j'],
        ['j', 'j', '-k', '-1', 'i'],
        ['k', 'k', 'j', '-i', '-1'],
    ]

    for i, row in enumerate(table):
        for j, cell in enumerate(row):
            x = 0.15 + j * 0.15
            y = 0.85 - i * 0.12
            color = '#FFD93D' if i == 0 or j == 0 else 'white'
            if cell.startswith('-') and i > 0 and j > 0:
                color = '#FF6B6B'
            weight = 'bold' if i == 0 or j == 0 else 'normal'
            ax1.text(x, y, cell, fontsize=14, fontweight=weight,
                    color=color, ha='center', va='center',
                    transform=ax1.transAxes, family='monospace')

    # Show non-commutativity
    ax1.text(0.5, 0.25, 'NON-COMMUTATIVITY:', fontsize=12, fontweight='bold',
            color='#FF6B6B', ha='center', transform=ax1.transAxes)
    ax1.text(0.5, 0.17, 'i·j = k    but    j·i = -k',
            fontsize=14, color='white', ha='center', transform=ax1.transAxes,
            family='monospace')
    ax1.text(0.5, 0.09, '→ Rotations don\'t commute!',
            fontsize=11, color='#4ECDC4', ha='center', transform=ax1.transAxes)
    ax1.text(0.5, 0.02, '→ This IS the physics of spin and the weak force',
            fontsize=10, color='#FFD93D', ha='center', transform=ax1.transAxes,
            alpha=0.7)

    # ===== Panel 2: Rotation order matters =====
    ax2 = fig.add_subplot(222, projection='3d', facecolor='#0a0a1a')
    ax2.set_title('Rotation Order Matters!\n(90° around X then Y ≠ Y then X)',
                 color='white', fontsize=11, pad=10)

    angle = np.pi / 2  # 90 degrees

    # Identity
    q_id = Quaternion(1, 0, 0, 0)

    # Rotation around X then Y
    q_x = Quaternion.from_axis_angle([1,0,0], angle)
    q_y = Quaternion.from_axis_angle([0,1,0], angle)
    q_xy = q_y * q_x  # Y after X

    # Rotation around Y then X
    q_yx = q_x * q_y  # X after Y

    # Draw original frame
    draw_axes_frame(ax2, [0, 0, 0], q_id, length=0.8, alpha=0.3, lw=1)

    # Draw XY result
    draw_axes_frame(ax2, [2.5, 0, 0], q_xy, length=0.8, alpha=0.9, lw=3)
    ax2.text(2.5, 0, -1.5, 'X then Y', color='#4ECDC4', fontsize=10, ha='center')

    # Draw YX result
    draw_axes_frame(ax2, [-2.5, 0, 0], q_yx, length=0.8, alpha=0.9, lw=3)
    ax2.text(-2.5, 0, -1.5, 'Y then X', color='#FF6B6B', fontsize=10, ha='center')

    ax2.text(0, 0, -2.2, '≠', color='#FFD93D', fontsize=20, ha='center')

    ax2.set_xlim(-3, 3)
    ax2.set_ylim(-2, 2)
    ax2.set_zlim(-2.5, 2)
    ax2.set_xlabel('', color='white')
    ax2.set_ylabel('', color='white')
    ax2.set_zlabel('', color='white')
    ax2.tick_params(colors='white', labelsize=6)
    ax2.xaxis.pane.fill = False
    ax2.yaxis.pane.fill = False
    ax2.zaxis.pane.fill = False

    # ===== Panel 3: SU(2) double cover =====
    ax3 = fig.add_subplot(223, facecolor='#0a0a1a')
    ax3.set_title('SU(2) Double Cover of SO(3)\n(Why spinors need 720° to return)',
                 color='white', fontsize=11, pad=10)

    # Show the angle trajectory: q and -q give the same rotation
    angles = np.linspace(0, 4*np.pi, 500)

    # Trace the quaternion components for rotation around z-axis
    w_vals = np.cos(angles / 2)
    z_vals = np.sin(angles / 2)

    ax3.plot(angles * 180 / np.pi, w_vals, color='#4ECDC4', linewidth=2,
            label='Re(q) = cos(θ/2)')
    ax3.plot(angles * 180 / np.pi, z_vals, color='#FF6B6B', linewidth=2,
            label='Im_k(q) = sin(θ/2)')

    # Mark 360° — spinor has flipped sign!
    ax3.axvline(360, color='#FFD93D', linestyle='--', alpha=0.5)
    ax3.text(360, 1.15, '360°: q → -q\n(same rotation!)', fontsize=9,
            ha='center', color='#FFD93D')

    # Mark 720° — spinor returns
    ax3.axvline(720, color='#96CEB4', linestyle='--', alpha=0.5)
    ax3.text(720, 1.15, '720°: q → q\n(spinor returns)', fontsize=9,
            ha='center', color='#96CEB4')

    ax3.set_xlabel('Physical rotation angle (degrees)', color='white')
    ax3.set_ylabel('Quaternion component', color='white')
    ax3.set_xlim(0, 720)
    ax3.set_ylim(-1.3, 1.4)
    ax3.legend(fontsize=9, loc='lower right', facecolor='#1a1a2e',
              edgecolor='white', labelcolor='white')
    ax3.tick_params(colors='white')
    ax3.set_facecolor('#0a0a1a')
    ax3.spines['bottom'].set_color('white')
    ax3.spines['left'].set_color('white')
    ax3.spines['top'].set_visible(False)
    ax3.spines['right'].set_visible(False)

    # ===== Panel 4: The belt trick / plate trick =====
    ax4 = fig.add_subplot(224, facecolor='#0a0a1a')
    ax4.axis('off')
    ax4.set_title('The Algebraic Theory of Spin\n(Why fermions are quaternionic)',
                 color='white', fontsize=11, pad=10)

    explanations = [
        ('KEY INSIGHT', '#FFD93D', 14,
         ''),
        ('', 'white', 10,
         'Unit quaternions form SU(2), the double cover of SO(3).'),
        ('', 'white', 10,
         'This means: q and -q represent the SAME rotation.'),
        ('', 'white', 10,
         ''),
        ('Physical consequence:', '#4ECDC4', 12,
         ''),
        ('', 'white', 10,
         '• Electrons need 720° (not 360°) to return to original state'),
        ('', 'white', 10,
         '• This is the spin-statistics theorem: fermions are quaternionic'),
        ('', 'white', 10,
         '• Bosons are complex (live in ℂ), fermions are quaternionic (live in ℍ)'),
        ('', 'white', 10,
         ''),
        ('Algebraic explanation:', '#FF6B6B', 12,
         ''),
        ('', 'white', 10,
         '• ℂ is commutative → bosons have symmetric wavefunctions'),
        ('', 'white', 10,
         '• ℍ is non-commutative → fermions have antisymmetric wavefunctions'),
        ('', 'white', 10,
         '• The Pauli exclusion principle IS non-commutativity!'),
        ('', 'white', 10,
         ''),
        ('', '#96CEB4', 11,
         '"The division algebras don\'t just describe particles —'),
        ('', '#96CEB4', 11,
         ' they ARE the particles."'),
    ]

    y = 0.92
    for title, color, fontsize, text in explanations:
        display = title if title else text
        if display:
            ax4.text(0.05, y, display, fontsize=fontsize,
                    fontweight='bold' if title else 'normal',
                    color=color, transform=ax4.transAxes, va='top')
        y -= 0.055

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Algebraic Theory of Reality/figures/04_quaternion_rotations.png',
               dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
    plt.close()
    print("✅ Saved: figures/04_quaternion_rotations.png")

if __name__ == '__main__':
    create_quaternion_demo()

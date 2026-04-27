"""
Berggren-Lorentz Quantum Simulation Demo
=========================================
Future Direction 6.2: Pythagorean triples parameterize quantum gates.

Each Pythagorean triple (a,b,c) defines a rotation gate:
  U(a,b,c) = [[a/c, -b/c], [b/c, a/c]]

The Berggren tree generates all primitive Pythagorean triples,
providing a systematic set of rational rotation gates.

This demo shows:
  1. Berggren tree generation and gate angles
  2. Density of Pythagorean rotation angles
  3. Gate synthesis using Berggren-generated gates
  4. Lorentz form preservation across the tree
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import deque


def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def generate_berggren_tree(max_depth=6):
    """Generate Pythagorean triples via the Berggren tree."""
    root = (3, 4, 5)
    triples = [root]
    queue = deque([(root, 0)])

    while queue:
        triple, depth = queue.popleft()
        if depth >= max_depth:
            continue
        a, b, c = triple
        for transform in [berggren_A, berggren_B, berggren_C]:
            child = transform(a, b, c)
            triples.append(child)
            queue.append((child, depth + 1))

    return triples


def pyth_gate(a, b, c):
    """Rotation gate from Pythagorean triple."""
    return np.array([[a/c, -b/c], [b/c, a/c]])


def gate_angle(a, b, c):
    """Rotation angle from triple."""
    return np.arctan2(b, a)


# ============================================================
# Demo 1: Berggren Tree and Gate Angles
# ============================================================
def demo_berggren_tree():
    """Visualize the Berggren tree and corresponding gate angles."""
    triples = generate_berggren_tree(max_depth=5)

    angles = [gate_angle(a, b, c) for a, b, c in triples]
    hypotenuses = [c for _, _, c in triples]

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Left: Tree structure (angle vs hypotenuse)
    depths = []
    queue = deque([(0, 0)])
    idx = 1
    while queue:
        node_idx, d = queue.popleft()
        depths.append(d)
        for _ in range(3):
            if idx < len(triples):
                depths.append(d + 1)
                queue.append((idx, d + 1))
                idx += 1

    depths = depths[:len(triples)]
    scatter = axes[0].scatter(np.degrees(angles), hypotenuses,
                               c=depths, cmap='viridis', s=20, alpha=0.7)
    axes[0].set_xlabel('Gate Angle (degrees)', fontsize=12)
    axes[0].set_ylabel('Hypotenuse c', fontsize=12)
    axes[0].set_title(f'Berggren Tree: {len(triples)} Triples', fontsize=13)
    plt.colorbar(scatter, ax=axes[0], label='Tree Depth')
    axes[0].grid(True, alpha=0.3)

    # Middle: Angle histogram — density
    axes[1].hist(np.degrees(angles), bins=50, color='steelblue',
                  edgecolor='black', alpha=0.7, density=True)
    axes[1].set_xlabel('Gate Angle (degrees)', fontsize=12)
    axes[1].set_ylabel('Density', fontsize=12)
    axes[1].set_title('Distribution of Pythagorean Gate Angles', fontsize=13)
    axes[1].axhline(y=1/90, color='red', linestyle='--',
                     label='Uniform density 1/90°')
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    # Right: Unit circle with gate angles
    theta = np.array(angles)
    r = np.ones_like(theta)
    axes[2] = plt.subplot(133, projection='polar')
    axes[2].scatter(theta, r, c=depths[:len(theta)], cmap='viridis', s=15, alpha=0.7)
    axes[2].set_title('Gate Angles on Unit Circle', fontsize=13, pad=15)
    axes[2].set_rticks([])

    plt.tight_layout()
    plt.savefig('berggren_quantum_tree.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"✓ Demo 1: Berggren tree visualization saved ({len(triples)} triples)")


# ============================================================
# Demo 2: Gate Synthesis via Berggren Composition
# ============================================================
def demo_gate_synthesis():
    """
    Approximate an arbitrary rotation using compositions of
    Berggren-generated gates.
    """
    triples = generate_berggren_tree(max_depth=7)
    gates = [(a, b, c, gate_angle(a, b, c)) for a, b, c in triples]
    gate_angles_sorted = sorted(gates, key=lambda x: x[3])
    available_angles = np.array([g[3] for g in gate_angles_sorted])

    # Target angles to approximate
    target_angles = np.linspace(0.01, np.pi/2 - 0.01, 100)
    errors_1gate = []
    errors_2gate = []

    for target in target_angles:
        # Best single gate
        idx = np.argmin(np.abs(available_angles - target))
        errors_1gate.append(np.abs(available_angles[idx] - target))

        # Best two-gate composition
        best_err = errors_1gate[-1]
        for i in range(min(len(available_angles), 200)):
            remaining = target - available_angles[i]
            idx2 = np.argmin(np.abs(available_angles - remaining))
            err = np.abs(available_angles[i] + available_angles[idx2] - target)
            best_err = min(best_err, err)
        errors_2gate.append(best_err)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    axes[0].semilogy(np.degrees(target_angles), np.degrees(errors_1gate),
                      'b-', linewidth=1.5, label='1 gate', alpha=0.7)
    axes[0].semilogy(np.degrees(target_angles), np.degrees(errors_2gate),
                      'r-', linewidth=1.5, label='2 gates', alpha=0.7)
    axes[0].set_xlabel('Target Angle (degrees)', fontsize=12)
    axes[0].set_ylabel('Approximation Error (degrees)', fontsize=12)
    axes[0].set_title('Gate Synthesis Error', fontsize=13)
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)

    # Unitarity verification
    det_errors = []
    orthog_errors = []
    for a, b, c in triples[:100]:
        G = pyth_gate(a, b, c)
        det_errors.append(abs(np.linalg.det(G) - 1.0))
        orthog_errors.append(np.max(np.abs(G @ G.T - np.eye(2))))

    axes[1].semilogy(range(len(det_errors)), det_errors, 'b.', markersize=3,
                      label='|det(U) - 1|', alpha=0.7)
    axes[1].semilogy(range(len(orthog_errors)), orthog_errors, 'r.', markersize=3,
                      label='‖UUᵀ - I‖', alpha=0.7)
    axes[1].set_xlabel('Gate Index', fontsize=12)
    axes[1].set_ylabel('Error', fontsize=12)
    axes[1].set_title('Unitarity Verification (Machine Precision)', fontsize=13)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('berggren_quantum_synthesis.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"\n✓ Demo 2: Gate synthesis saved")
    print(f"  Mean 1-gate error: {np.mean(np.degrees(errors_1gate)):.4f}°")
    print(f"  Mean 2-gate error: {np.mean(np.degrees(errors_2gate)):.4f}°")
    print(f"  Max det error: {max(det_errors):.2e}")
    print(f"  Max orthogonality error: {max(orthog_errors):.2e}")


# ============================================================
# Demo 3: Lorentz Form Preservation
# ============================================================
def demo_lorentz_preservation():
    """
    Verify that Berggren transformations preserve the Lorentz form
    a² + b² - c² = 0 (light cone condition).
    """
    triples = generate_berggren_tree(max_depth=7)

    lorentz_forms = [a**2 + b**2 - c**2 for a, b, c in triples]

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    axes[0].plot(range(len(lorentz_forms)), lorentz_forms, 'b.', markersize=2)
    axes[0].set_xlabel('Triple Index', fontsize=12)
    axes[0].set_ylabel('a² + b² - c²', fontsize=12)
    axes[0].set_title('Lorentz Form = 0 for All Triples', fontsize=13)
    axes[0].grid(True, alpha=0.3)

    # Visualize on the light cone
    a_vals = [a for a, _, _ in triples[:200]]
    b_vals = [b for _, b, _ in triples[:200]]
    c_vals = [c for _, _, c in triples[:200]]

    ax3d = fig.add_subplot(122, projection='3d')
    ax3d.scatter(a_vals, b_vals, c_vals, c='blue', s=5, alpha=0.5)

    # Draw the light cone surface
    theta = np.linspace(0, np.pi/2, 50)
    r = np.linspace(0, max(c_vals), 50)
    T, R = np.meshgrid(theta, r)
    X = R * np.cos(T)
    Y = R * np.sin(T)
    Z = R
    ax3d.plot_surface(X, Y, Z, alpha=0.1, color='red')

    ax3d.set_xlabel('a')
    ax3d.set_ylabel('b')
    ax3d.set_zlabel('c')
    ax3d.set_title('Triples on Light Cone a²+b²=c²', fontsize=13)

    plt.tight_layout()
    plt.savefig('berggren_lorentz.png', dpi=150, bbox_inches='tight')
    plt.close()

    print(f"\n✓ Demo 3: Lorentz form preservation saved")
    print(f"  All Lorentz forms = 0: {all(l == 0 for l in lorentz_forms)}")
    print(f"  Number of triples verified: {len(triples)}")


if __name__ == '__main__':
    print("=" * 60)
    print("Berggren-Lorentz Quantum Simulation — Future Direction 6.2")
    print("=" * 60)

    demo_berggren_tree()
    demo_gate_synthesis()
    demo_lorentz_preservation()

    print("\n" + "=" * 60)
    print("All demos complete! Generated 3 PNG files.")
    print("=" * 60)

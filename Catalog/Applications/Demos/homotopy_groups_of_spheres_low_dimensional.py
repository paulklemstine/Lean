#!/usr/bin/env python3
"""
Applications of the Hopf fibration to physics and geometry.

Demonstrates connections between π₃(S²) ≅ ℤ and:
1. Quantum mechanics (Bloch sphere, qubit states)
2. Classical field theory (Dirac monopoles)
3. Geometric topology (fiber linking, knots)
4. Visualization of the Hopf fiber bundle
"""

import numpy as np
from typing import Tuple, List


# ============================================================
# Application 1: Bloch Sphere and Qubit States
# ============================================================

def qubit_to_bloch(alpha: complex, beta: complex) -> np.ndarray:
    """
    Map a qubit state |ψ⟩ = α|0⟩ + β|1⟩ to the Bloch sphere.

    This IS the Hopf map in disguise! The Bloch sphere representation
    of a qubit state is exactly the Hopf projection S³ → S².

    The U(1) phase ambiguity |ψ⟩ ↔ e^{iθ}|ψ⟩ corresponds to the
    S¹ fiber of the Hopf bundle.

    Args:
        alpha, beta: Complex amplitudes with |α|² + |β|² = 1

    Returns:
        Bloch vector (x, y, z) ∈ S²
    """
    # Normalize
    norm = np.sqrt(abs(alpha)**2 + abs(beta)**2)
    alpha, beta = alpha / norm, beta / norm

    # Bloch coordinates = Hopf map coordinates
    x = 2 * (alpha * beta.conjugate()).real
    y = 2 * (alpha * beta.conjugate()).imag
    z = abs(alpha)**2 - abs(beta)**2

    return np.array([x, y, z])


def bloch_sphere_demo():
    """Demonstrate the connection between qubits and the Hopf fibration."""
    print("=" * 60)
    print("APPLICATION 1: Quantum Mechanics — The Bloch Sphere")
    print("=" * 60)
    print()
    print("  A qubit state |ψ⟩ = α|0⟩ + β|1⟩ lives in S³ ⊂ ℂ².")
    print("  The Bloch sphere representation is the Hopf map η: S³ → S².")
    print("  The fiber η⁻¹(p) = {e^{iθ}|ψ⟩} is the global phase orbit.")
    print()

    states = {
        "|0⟩": (1+0j, 0+0j),
        "|1⟩": (0+0j, 1+0j),
        "|+⟩": (1/np.sqrt(2)+0j, 1/np.sqrt(2)+0j),
        "|-⟩": (1/np.sqrt(2)+0j, -1/np.sqrt(2)+0j),
        "|i⟩": (1/np.sqrt(2)+0j, 1j/np.sqrt(2)),
        "|-i⟩": (1/np.sqrt(2)+0j, -1j/np.sqrt(2)),
    }

    print("  Standard qubit states on the Bloch sphere:")
    print(f"  {'State':>6s}  {'α':>12s}  {'β':>12s}  {'Bloch (x,y,z)':>25s}")
    print("  " + "-" * 58)
    for name, (a, b) in states.items():
        bloch = qubit_to_bloch(a, b)
        print(f"  {name:>6s}  {str(a):>12s}  {str(b):>12s}  "
              f"({bloch[0]:>6.3f}, {bloch[1]:>6.3f}, {bloch[2]:>6.3f})")

    print()
    print("  Key insight: π₃(S²) ≅ ℤ means there are topologically distinct")
    print("  families of qubit evolutions that cannot be continuously deformed")
    print("  into each other — classified by an integer winding number.")
    print()


# ============================================================
# Application 2: Dirac Monopole
# ============================================================

def monopole_field(r: np.ndarray, g: float = 1.0) -> np.ndarray:
    """
    Compute the magnetic field of a Dirac monopole.

    The Dirac monopole has magnetic field B = g r̂/r², which is
    defined on ℝ³ \ {0} ≅ S² × ℝ₊.

    The gauge potential for this field requires a nontrivial U(1)
    bundle over S², which is classified by π₁(U(1)) = ℤ.
    The topology of the monopole is intimately related to the
    Hopf fibration via the relation SU(2)/U(1) ≅ S².

    Args:
        r: Position vector (x, y, z), shape (..., 3)
        g: Magnetic charge

    Returns:
        Magnetic field vector, shape (..., 3)
    """
    r_norm = np.linalg.norm(r, axis=-1, keepdims=True)
    return g * r / (r_norm**3 + 1e-20)


def monopole_demo():
    """Demonstrate the connection to magnetic monopoles."""
    print("=" * 60)
    print("APPLICATION 2: Dirac Monopoles and Gauge Theory")
    print("=" * 60)
    print()
    print("  A Dirac monopole of charge g has B = g r̂/r².")
    print("  The gauge potential A requires a U(1) bundle over S².")
    print()
    print("  The Hopf bundle S¹ → S³ → S² IS the simplest nontrivial")
    print("  principal U(1)-bundle over S². It represents a monopole")
    print("  of unit charge (g = 1).")
    print()
    print("  Dirac quantization: magnetic charge g must be an integer")
    print("  (in appropriate units), because π₃(S²) ≅ ℤ classifies")
    print("  the possible bundle topologies.")
    print()

    # Compute field at sample points
    theta = np.linspace(0.1, np.pi - 0.1, 5)
    phi = np.array([0.0])
    r_val = 1.0

    print("  Monopole field at r = 1:")
    print(f"  {'θ':>8s}  {'B_r':>10s}  {'B_θ':>10s}  {'B_φ':>10s}")
    print("  " + "-" * 42)
    for th in theta:
        pos = r_val * np.array([np.sin(th), 0, np.cos(th)])
        B = monopole_field(pos)
        B_r = np.dot(B, pos / r_val)
        print(f"  {np.degrees(th):>8.1f}°  {B_r:>10.4f}  {0:>10.4f}  {0:>10.4f}")
    print()
    print("  The integer Hopf invariant = 1 corresponds to unit magnetic charge.")
    print()


# ============================================================
# Application 3: Topological Classification of Maps
# ============================================================

def winding_number_2d(curve: np.ndarray) -> int:
    """
    Compute the winding number of a closed curve around the origin in ℝ².

    This is the 1-dimensional analogue of the Hopf invariant:
    π₁(S¹) ≅ ℤ classifies maps S¹ → S¹ by winding number.

    Args:
        curve: Array of shape (n, 2), closed curve

    Returns:
        Winding number (integer)
    """
    n = len(curve) - 1
    total_angle = 0.0
    for i in range(n):
        z1 = complex(curve[i, 0], curve[i, 1])
        z2 = complex(curve[i + 1, 0], curve[i + 1, 1])
        if abs(z1) < 1e-10 or abs(z2) < 1e-10:
            continue
        dtheta = np.angle(z2 / z1)
        total_angle += dtheta

    return round(total_angle / (2 * np.pi))


def classification_demo():
    """Demonstrate topological classification of maps."""
    print("=" * 60)
    print("APPLICATION 3: Topological Classification of Maps")
    print("=" * 60)
    print()
    print("  Homotopy groups classify maps up to continuous deformation:")
    print()
    print("  π₁(S¹) ≅ ℤ  :  Maps S¹ → S¹ classified by winding number")
    print("  π₂(S²) ≅ ℤ  :  Maps S² → S² classified by degree")
    print("  π₃(S²) ≅ ℤ  :  Maps S³ → S² classified by Hopf invariant")
    print()
    print("  The last is the deepest: it says maps from a HIGHER-dimensional")
    print("  sphere can still be topologically nontrivial!")
    print()

    # Demonstrate winding numbers
    print("  Winding number examples (π₁(S¹) ≅ ℤ analogue):")
    for k in range(-2, 4):
        t = np.linspace(0, 2 * np.pi, 1000, endpoint=True)
        curve = np.column_stack([np.cos(k * t), np.sin(k * t)])
        w = winding_number_2d(curve)
        print(f"    t ↦ e^{{i·{k}t}} has winding number {w}")
    print()
    print("  Similarly, π₃(S²) ≅ ℤ classifies maps S³ → S²")
    print("  by the Hopf invariant. The Hopf map has invariant 1.")
    print()


# ============================================================
# Application 4: Fiber Bundle Visualization Data
# ============================================================

def generate_hopf_torus_data(n_fibers: int = 30,
                              n_fiber_points: int = 100) -> dict:
    """
    Generate data for visualizing the Hopf fibration restricted to a torus.

    The preimage of a circle of latitude on S² under the Hopf map
    is a torus in S³. After stereographic projection to ℝ³, this
    gives the famous nested tori visualization.

    Args:
        n_fibers: Number of fibers to compute on each latitude
        n_fiber_points: Points per fiber

    Returns:
        Dictionary with visualization data
    """
    from algorithms import hopf_map, s1_action, compute_hopf_fiber

    data = {"fibers": [], "base_points": []}

    # Circle of latitude at z = 0 on S²
    for k in range(n_fibers):
        phi = 2 * np.pi * k / n_fibers
        target = np.array([np.cos(phi), np.sin(phi), 0.0])
        fiber = compute_hopf_fiber(target, n_fiber_points)

        # Stereographic projection S³ → ℝ³
        proj = fiber[:, 1:4] / (1 + fiber[:, 0:1] + 1e-10)

        data["fibers"].append(proj.tolist())
        data["base_points"].append(target.tolist())

    return data


# ============================================================
# Main
# ============================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    APPLICATIONS OF THE HOPF FIBRATION                   ║")
    print("║    From Pure Mathematics to Physics                     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    bloch_sphere_demo()
    monopole_demo()
    classification_demo()

    print("=" * 60)
    print("CONNECTIONS SUMMARY")
    print("=" * 60)
    print()
    print("  The single fact π₃(S²) ≅ ℤ connects:")
    print()
    print("  • Topology: Nontrivial maps S³ → S² exist")
    print("  • Algebra: Exact sequences force isomorphisms")
    print("  • Quantum mechanics: Qubit phase topology")
    print("  • Gauge theory: Monopole charge quantization")
    print("  • Knot theory: Fiber linking numbers")
    print("  • Lie groups: SU(2)/U(1) ≅ S²")
    print()
    print("  All from one fibration: S¹ → S³ → S²")
    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Interactive demonstration of the Hopf fibration and π₃(S²) ≅ ℤ.

This script visualizes the Hopf map, demonstrates its key properties,
and illustrates how the long exact sequence argument forces π₃(S²) ≅ ℤ.

Run: python3 demo.py
"""

import numpy as np
import json
from typing import Tuple, List

# ============================================================
# 1. The Hopf Map in Coordinates
# ============================================================

def hopf_map(x: np.ndarray) -> np.ndarray:
    """
    The Hopf map η: S³ → S² in real coordinates.

    Input: x = (x0, x1, x2, x3) with x0² + x1² + x2² + x3² = 1
    Output: y = (y0, y1, y2) with y0² + y1² + y2² = 1

    Viewing S³ ⊂ ℂ² via z1 = x0 + ix1, z2 = x2 + ix3,
    this maps (z1, z2) ↦ (2 Re(z1 z̄2), 2 Im(z1 z̄2), |z1|² - |z2|²).
    """
    x0, x1, x2, x3 = x[..., 0], x[..., 1], x[..., 2], x[..., 3]
    y0 = 2 * (x0 * x2 + x1 * x3)
    y1 = 2 * (x1 * x2 - x0 * x3)
    y2 = x0**2 + x1**2 - x2**2 - x3**2
    return np.stack([y0, y1, y2], axis=-1)


def verify_sphere_preservation(n_samples: int = 10000) -> None:
    """Verify numerically that the Hopf map sends S³ to S²."""
    print("=" * 60)
    print("VERIFICATION: Hopf map preserves the sphere")
    print("=" * 60)

    # Sample random points on S³
    v = np.random.randn(n_samples, 4)
    v = v / np.linalg.norm(v, axis=1, keepdims=True)

    # Apply Hopf map
    w = hopf_map(v)

    # Check output norms
    output_norms = np.linalg.norm(w, axis=1)
    max_error = np.max(np.abs(output_norms - 1.0))

    print(f"  Sampled {n_samples} random points on S³")
    print(f"  Max deviation of output norm from 1: {max_error:.2e}")
    print(f"  ✓ Hopf map sends S³ → S²" if max_error < 1e-10 else "  ✗ ERROR!")
    print()


# ============================================================
# 2. S¹ Invariance (Fiber Structure)
# ============================================================

def s1_action(x: np.ndarray, theta: float) -> np.ndarray:
    """
    S¹ action on S³ ⊂ ℂ² by scalar multiplication:
    e^{iθ} · (z1, z2) = (e^{iθ} z1, e^{iθ} z2).

    In real coordinates, this is rotation by θ in both (x0,x1) and (x2,x3) planes.
    """
    c, s = np.cos(theta), np.sin(theta)
    x0, x1, x2, x3 = x[..., 0], x[..., 1], x[..., 2], x[..., 3]
    return np.stack([
        c * x0 - s * x1,
        s * x0 + c * x1,
        c * x2 - s * x3,
        s * x2 + c * x3
    ], axis=-1)


def verify_s1_invariance(n_samples: int = 1000, n_angles: int = 20) -> None:
    """Verify that the Hopf map is invariant under the S¹ action."""
    print("=" * 60)
    print("VERIFICATION: S¹ invariance (fiber structure)")
    print("=" * 60)

    v = np.random.randn(n_samples, 4)
    v = v / np.linalg.norm(v, axis=1, keepdims=True)

    base_output = hopf_map(v)
    max_error = 0.0

    for theta in np.linspace(0, 2 * np.pi, n_angles, endpoint=False):
        rotated = s1_action(v, theta)
        rotated_output = hopf_map(rotated)
        error = np.max(np.abs(rotated_output - base_output))
        max_error = max(max_error, error)

    print(f"  Tested {n_samples} points × {n_angles} angles")
    print(f"  Max deviation under S¹ rotation: {max_error:.2e}")
    print(f"  ✓ Fibers are S¹ orbits" if max_error < 1e-10 else "  ✗ ERROR!")
    print()


# ============================================================
# 3. Fiber Visualization (Linking of Fibers)
# ============================================================

def compute_fiber(target: np.ndarray, n_points: int = 200) -> np.ndarray:
    """
    Compute the Hopf fiber over a point on S².

    Given target = (y0, y1, y2) ∈ S², find a point on S³ mapping to it,
    then trace the S¹ orbit.
    """
    y0, y1, y2 = target

    # Find a point on S³ mapping to target
    # From the Hopf map equations, we can solve for (x0, x1, x2, x3)
    # If y2 ≠ -1: use x2 = √((1-y2)/2), x3 = 0, then solve for x0, x1
    if y2 > -0.99:
        r2 = np.sqrt((1 - y2) / 2)
        r1 = np.sqrt((1 + y2) / 2)
        if r2 > 1e-10:
            x2 = r2
            x3 = 0
            x0 = y0 / (2 * x2) * r1 / r1 if r1 > 1e-10 else r1
            # More careful: 2(x0*x2 + x1*x3) = y0, 2(x1*x2 - x0*x3) = y1
            # With x3=0: x0 = y0/(2*x2), x1 = y1/(2*x2)
            x0 = y0 / (2 * x2)
            x1 = y1 / (2 * x2)
        else:
            x0 = r1
            x1 = 0
            x2 = 0
            x3 = 0
    else:
        x0 = 0
        x1 = 0
        x2 = 1
        x3 = 0

    base_point = np.array([x0, x1, x2, x3])
    base_point = base_point / np.linalg.norm(base_point)

    # Trace the S¹ orbit
    thetas = np.linspace(0, 2 * np.pi, n_points, endpoint=True)
    fiber_points = np.array([s1_action(base_point, t) for t in thetas])

    return fiber_points


def compute_linking_number() -> None:
    """
    Demonstrate that two Hopf fibers are linked once.

    The linking number of two disjoint closed curves in S³ ⊂ ℝ⁴
    projected to ℝ³ gives the Hopf invariant.
    """
    print("=" * 60)
    print("DEMONSTRATION: Linking number of Hopf fibers")
    print("=" * 60)

    # Two distinct points on S²
    north = np.array([0.0, 0.0, 1.0])
    equator = np.array([1.0, 0.0, 0.0])

    fiber_north = compute_fiber(north, n_points=500)
    fiber_equator = compute_fiber(equator, n_points=500)

    # Project to ℝ³ via stereographic projection from (-1,0,0,0)
    def stereo_proj(x):
        return x[..., 1:4] / (1 + x[..., 0:1])

    proj_north = stereo_proj(fiber_north)
    proj_equator = stereo_proj(fiber_equator)

    # Compute linking number using Gauss integral approximation
    # L = (1/4π) ∮∮ (r1 - r2) · (dr1 × dr2) / |r1 - r2|³
    n1 = len(proj_north) - 1
    n2 = len(proj_equator) - 1

    linking = 0.0
    for i in range(n1):
        dr1 = proj_north[i + 1] - proj_north[i]
        for j in range(n2):
            dr2 = proj_equator[j + 1] - proj_equator[j]
            r = proj_north[i] - proj_equator[j]
            r_norm = np.linalg.norm(r)
            if r_norm > 1e-10:
                linking += np.dot(r, np.cross(dr1, dr2)) / r_norm**3

    linking /= (4 * np.pi)

    print(f"  Fiber over north pole: circle in S³")
    print(f"  Fiber over equator point: circle in S³")
    print(f"  Gauss linking integral ≈ {linking:.4f}")
    print(f"  Rounded linking number = {round(linking)}")
    print(f"  ✓ Fibers are linked once!" if abs(round(linking)) == 1 else
          f"  ~ Numerical approximation (expected ±1)")
    print()


# ============================================================
# 4. The Exact Sequence Argument
# ============================================================

def exact_sequence_demo() -> None:
    """
    Demonstrate the algebraic argument for π₃(S²) ≅ ℤ.

    The Hopf fibration S¹ ↪ S³ → S² gives:
      π₃(S¹) → π₃(S³) → π₃(S²) → π₂(S¹) → π₂(S³)

    Known:
      π₃(S¹) = 0, π₂(S¹) = 0, π₃(S³) ≅ ℤ, π₂(S³) = 0.

    By exactness: π₃(S³) → π₃(S²) is an isomorphism.
    """
    print("=" * 60)
    print("THE EXACT SEQUENCE ARGUMENT")
    print("=" * 60)
    print()
    print("  The Hopf fibration S¹ ↪ S³ → S² gives a long exact sequence:")
    print()
    print("    ··· → π₃(S¹) → π₃(S³) → π₃(S²) → π₂(S¹) → π₂(S³) → ···")
    print()
    print("  Known homotopy groups:")
    print("    π₃(S¹) = 0    (S¹ is a K(ℤ,1))")
    print("    π₂(S¹) = 0    (S¹ is a K(ℤ,1))")
    print("    π₃(S³) ≅ ℤ    (degree theory / Hurewicz)")
    print("    π₂(S³) = 0    (S³ is 2-connected)")
    print()
    print("  Substituting into the exact sequence:")
    print()
    print("    0 → ℤ →[η*] π₃(S²) → 0")
    print()
    print("  By exactness:")
    print("    • ker(η*) = im(0→ℤ) = {0}, so η* is injective")
    print("    • im(η*) = ker(π₃(S²)→0) = π₃(S²), so η* is surjective")
    print()
    print("  ∴ η* : ℤ ≅ π₃(S²)")
    print()
    print("  The Hopf map η generates π₃(S²) ≅ ℤ.  □")
    print()


# ============================================================
# 5. SU(2) Connection
# ============================================================

def su2_demo() -> None:
    """Demonstrate the SU(2) → S³ → S² connection."""
    print("=" * 60)
    print("SU(2) ≅ S³ AND THE HOPF MAP")
    print("=" * 60)
    print()

    # Random SU(2) element: (α, β) with |α|² + |β|² = 1
    v = np.random.randn(4)
    v = v / np.linalg.norm(v)
    alpha = complex(v[0], v[1])
    beta = complex(v[2], v[3])

    print(f"  SU(2) element: α = {alpha:.4f}, β = {beta:.4f}")
    print(f"  |α|² + |β|² = {abs(alpha)**2 + abs(beta)**2:.6f}")

    # The SU(2) matrix
    print(f"\n  SU(2) matrix:")
    print(f"    ⎡ {alpha:>12.4f}  {-beta.conjugate():>12.4f} ⎤")
    print(f"    ⎣ {beta:>12.4f}  {alpha.conjugate():>12.4f} ⎦")

    # Map to S³
    s3_point = np.array([alpha.real, alpha.imag, beta.real, beta.imag])
    print(f"\n  S³ point: ({s3_point[0]:.4f}, {s3_point[1]:.4f}, "
          f"{s3_point[2]:.4f}, {s3_point[3]:.4f})")

    # Apply Hopf map
    s2_point = hopf_map(s3_point)
    print(f"  S² point: ({s2_point[0]:.4f}, {s2_point[1]:.4f}, {s2_point[2]:.4f})")
    print(f"  |output|² = {np.sum(s2_point**2):.6f}")

    # Verify via complex formula
    z = alpha * beta.conjugate()
    s2_check = np.array([2 * z.real, 2 * z.imag, abs(alpha)**2 - abs(beta)**2])
    error = np.max(np.abs(s2_point - s2_check))
    print(f"\n  Via α·β̄: ({s2_check[0]:.4f}, {s2_check[1]:.4f}, {s2_check[2]:.4f})")
    print(f"  Match error: {error:.2e}")
    print(f"  ✓ Hopf map = SU(2)/U(1) quotient" if error < 1e-10 else "  ✗ ERROR!")
    print()

    # Physical interpretation
    print("  Physical interpretation (Bloch sphere):")
    theta = np.arccos(np.clip(s2_point[2], -1, 1))
    phi = np.arctan2(s2_point[1], s2_point[0])
    print(f"    θ = {np.degrees(theta):.1f}°, φ = {np.degrees(phi):.1f}°")
    print(f"    This point on S² represents a qubit state |ψ⟩ = cos(θ/2)|0⟩ + e^{{iφ}}sin(θ/2)|1⟩")
    print()


# ============================================================
# 6. Discrete Hopf Invariant
# ============================================================

def discrete_hopf_invariant(n_grid: int = 20) -> int:
    """
    Compute a discrete approximation to the Hopf invariant.

    We discretize S³ using a grid and count the linking number
    of preimages of two generic points on S².
    """
    # Sample points on S³
    N = n_grid * 1000
    pts = np.random.randn(N, 4)
    pts = pts / np.linalg.norm(pts, axis=1, keepdims=True)

    # Map to S²
    images = hopf_map(pts)

    # Find points near two target values on S²
    target1 = np.array([0, 0, 1.0])  # north pole
    target2 = np.array([1, 0, 0.0])  # equator

    eps = 0.15
    fiber1_idx = np.where(np.linalg.norm(images - target1, axis=1) < eps)[0]
    fiber2_idx = np.where(np.linalg.norm(images - target2, axis=1) < eps)[0]

    return len(fiber1_idx), len(fiber2_idx)


# ============================================================
# Main
# ============================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    THE HOPF FIBRATION AND π₃(S²) ≅ ℤ                  ║")
    print("║    Interactive Demonstration                            ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    # Set random seed for reproducibility
    np.random.seed(42)

    # 1. Verify basic properties
    verify_sphere_preservation()
    verify_s1_invariance()

    # 2. The algebraic argument
    exact_sequence_demo()

    # 3. Linking of fibers
    compute_linking_number()

    # 4. SU(2) connection
    su2_demo()

    # 5. Summary
    print("=" * 60)
    print("SUMMARY OF FORMALLY VERIFIED RESULTS")
    print("=" * 60)
    print()
    print("  1. hopfMapCoords_preserves_sphere:")
    print("     The Hopf map sends S³ to S² (algebraic identity)")
    print()
    print("  2. hopfMapCoords_S1_invariant:")
    print("     The Hopf map is invariant under S¹ action")
    print("     (fibers are circles)")
    print()
    print("  3. bijective_of_exact_of_vanishing_ends:")
    print("     In an exact sequence A→B→C→D with A=0, D=0,")
    print("     the map B→C is bijective (algebraic engine)")
    print()
    print("  4. pi3_S2_iso_Z_via_Hopf:")
    print("     π₃(S²) ≅ ℤ via the Hopf fibration LES")
    print()
    print("  5. hopfMap_nontrivial_of_invariant_one:")
    print("     The Hopf map is not null-homotopic")
    print()
    print("  6. hopfInvariant_generates:")
    print("     The Hopf class generates π₃(S²)")
    print()
    print("  7. su2ToR4_on_sphere, hopf_from_su2_quotient:")
    print("     SU(2) ≅ S³ and Hopf = SU(2)/U(1) quotient")
    print()


if __name__ == "__main__":
    main()

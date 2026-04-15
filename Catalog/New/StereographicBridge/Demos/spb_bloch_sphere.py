#!/usr/bin/env python3
"""
SPB and the Bloch Sphere: Quantum Computing Connection
=======================================================

Single-qubit states on the Bloch sphere, via stereographic projection,
become points in ℂ ∪ {∞}. Quantum gates become Möbius transformations.

This demo:
1. Maps Bloch sphere states to stereographic coordinates
2. Expresses standard quantum gates as Möbius transformations
3. Identifies which gates are SPB operations
4. Visualizes gate orbits on the complex plane

Run: python3 spb_bloch_sphere.py
"""

import cmath
import math

# ══════════════════════════════════════════════════════════════
# Bloch Sphere → Stereographic Coordinates
# ══════════════════════════════════════════════════════════════

def bloch_to_stereo(theta, phi):
    """Map Bloch sphere angles (θ, φ) to stereographic coordinate ζ = tan(θ/2)·e^{iφ}."""
    if abs(theta - math.pi) < 1e-10:
        return complex(float('inf'), 0)
    return math.tan(theta / 2) * cmath.exp(1j * phi)

def stereo_to_bloch(zeta):
    """Map stereographic coordinate back to Bloch sphere angles."""
    r = abs(zeta)
    theta = 2 * math.atan(r)
    phi = cmath.phase(zeta)
    return theta, phi

# ══════════════════════════════════════════════════════════════
# Quantum Gates as Möbius Transformations
# ══════════════════════════════════════════════════════════════

def mobius(a, b, c, d, z):
    """Apply Möbius transformation (az+b)/(cz+d) to z."""
    denom = c * z + d
    if abs(denom) < 1e-15:
        return complex(float('inf'), 0)
    return (a * z + b) / denom

# Standard gates as SU(2) matrices → Möbius transformations
# A qubit state |ψ⟩ = α|0⟩ + β|1⟩ maps to ζ = β/α
# Gate U = [[a,b],[c,d]] maps ζ → (cζ+d)/(aζ+b)... careful with conventions

def gate_z_rotation(phi, z):
    """Z-rotation by angle φ: Rz(φ) = [[e^{-iφ/2}, 0], [0, e^{iφ/2}]]
    Möbius: ζ → e^{iφ} · ζ (pure rotation in stereographic plane)"""
    return cmath.exp(1j * phi) * z

def gate_x_rotation(phi, z):
    """X-rotation by angle φ.
    Möbius: ζ → (cos(φ/2)·ζ + i·sin(φ/2)) / (i·sin(φ/2)·ζ + cos(φ/2))"""
    c = math.cos(phi / 2)
    s = math.sin(phi / 2)
    return mobius(c, 1j * s, 1j * s, c, z)

def gate_hadamard(z):
    """Hadamard gate: H = (1/√2)[[1,1],[1,-1]]
    Möbius: ζ → (ζ - 1)/(ζ + 1)"""
    return mobius(1, -1, 1, 1, z)

def gate_phase(z):
    """S gate (phase): S = [[1,0],[0,i]]
    Möbius: ζ → i·ζ"""
    return 1j * z

def gate_t(z):
    """T gate: T = [[1,0],[0,e^{iπ/4}]]
    Möbius: ζ → e^{iπ/4}·ζ"""
    return cmath.exp(1j * math.pi / 4) * z

# ══════════════════════════════════════════════════════════════
# SPB Connection
# ══════════════════════════════════════════════════════════════

def spb_complex(x, y):
    """Complex SPB: (x+y)/(1-xy)"""
    d = 1 - x * y
    if abs(d) < 1e-15:
        return complex(float('inf'), 0)
    return (x + y) / d

def demo():
    print("=" * 60)
    print("SPB AND THE BLOCH SPHERE")
    print("=" * 60)

    # Standard states
    states = {
        "|0⟩": (0, 0),           # North pole → ζ = 0
        "|1⟩": (math.pi, 0),     # South pole → ζ = ∞
        "|+⟩": (math.pi/2, 0),   # Equator x → ζ = 1
        "|-⟩": (math.pi/2, math.pi),  # Equator -x → ζ = -1
        "|+i⟩": (math.pi/2, math.pi/2),   # ζ = i
        "|-i⟩": (math.pi/2, -math.pi/2),  # ζ = -i
    }

    print("\n  Bloch sphere states in stereographic coordinates:")
    print(f"  {'State':>6} {'θ':>6} {'φ':>6} {'ζ':>15}")
    for name, (theta, phi) in states.items():
        zeta = bloch_to_stereo(theta, phi)
        if abs(zeta) > 1e10:
            print(f"  {name:>6} {theta:>6.3f} {phi:>6.3f} {'∞':>15}")
        else:
            print(f"  {name:>6} {theta:>6.3f} {phi:>6.3f} {zeta:>15.4f}")

    # Gate actions
    print("\n  Quantum gate actions (on |+⟩ = ζ=1):")
    z0 = 1.0 + 0j

    gates = {
        "H": lambda z: gate_hadamard(z),
        "S": lambda z: gate_phase(z),
        "T": lambda z: gate_t(z),
        "Rz(π/3)": lambda z: gate_z_rotation(math.pi/3, z),
        "Rx(π/2)": lambda z: gate_x_rotation(math.pi/2, z),
    }

    for name, gate in gates.items():
        result = gate(z0)
        print(f"    {name:>8}(|+⟩) → ζ = {result:.4f}")

    # SPB connection: X-rotation is related to SPB!
    # Rx(φ) maps ζ → (cos(φ/2)·ζ + i·sin(φ/2)) / (i·sin(φ/2)·ζ + cos(φ/2))
    # This is spb(ζ, i·tan(φ/2)) when restricted to the imaginary axis parameter

    print("\n  SPB connection to X-rotation:")
    print("  Rx(φ) on the equator (ζ real) equals spb(ζ, i·tan(φ/2)):")
    for phi_val in [math.pi/6, math.pi/4, math.pi/3, math.pi/2]:
        z_test = 0.5 + 0j
        rx_result = gate_x_rotation(phi_val, z_test)
        spb_param = 1j * math.tan(phi_val / 2)
        spb_result = spb_complex(z_test, spb_param)
        match = abs(rx_result - spb_result) < 1e-10
        print(f"    φ={phi_val:.4f}: Rx={rx_result:.4f}, SPB={spb_result:.4f}, "
              f"match={'✓' if match else '✗'}")

    # Z-rotation as multiplicative SPB (trivial)
    print("\n  Z-rotations: ζ → e^{iφ}·ζ (scaling, not SPB)")
    print("  These correspond to phase shifts, not SPB additions.")

    # Hadamard as SPB-like operation
    print("\n  Hadamard: ζ → (ζ-1)/(ζ+1) = spb(ζ, -1) with OPPOSITE sign convention")
    h_test = 0.5 + 0j
    h_result = gate_hadamard(h_test)
    spb_neg1 = spb_complex(h_test, -1.0)
    print(f"    H(0.5) = {h_result:.4f}")
    print(f"    spb(0.5, -1) = {spb_neg1:.4f}")
    print(f"    Note: H uses (ζ-1)/(ζ+1), SPB uses (ζ+a)/(1-ζa)")
    print(f"    H(ζ) = -spb(ζ, -1) with the hyperbolic sign convention!")
    print()

if __name__ == "__main__":
    demo()

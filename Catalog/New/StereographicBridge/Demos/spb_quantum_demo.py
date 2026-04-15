#!/usr/bin/env python3
"""
SPB Quantum Computing Demo
============================
Demonstrates how single-qubit quantum gates act as SPB/Möbius
transformations on Bloch sphere stereographic coordinates.

Key idea: Under stereographic projection from the south pole,
qubit states |ψ⟩ = cos(θ/2)|0⟩ + e^{iφ}sin(θ/2)|1⟩ map to
ζ = tan(θ/2) · e^{iφ} ∈ ℂ ∪ {∞}

Quantum gates (SU(2) matrices) become Möbius transformations of ζ.
"""

import cmath
import math

def spb_complex(x, y):
    """Complex SPB: (x+y)/(1-xy)"""
    denom = 1 - x * y
    if abs(denom) < 1e-15:
        return complex(float('inf'), 0)
    return (x + y) / denom

def mobius(a, b, c, d, z):
    """Möbius transformation (az+b)/(cz+d)"""
    denom = c * z + d
    if abs(denom) < 1e-15:
        return complex(float('inf'), 0)
    return (a * z + b) / denom

def bloch_to_stereo(theta, phi):
    """Convert Bloch sphere angles to stereographic coordinate."""
    return math.tan(theta / 2) * cmath.exp(1j * phi)

def stereo_to_bloch(zeta):
    """Convert stereographic coordinate to Bloch sphere angles."""
    if abs(zeta) < 1e-15:
        return 0.0, 0.0
    theta = 2 * math.atan(abs(zeta))
    phi = cmath.phase(zeta)
    return theta, phi

print("=" * 70)
print("SPB QUANTUM COMPUTING DEMO")
print("=" * 70)

# --- Standard states ---
print("\n--- Stereographic Coordinates of Standard States ---")
states = {
    "|0⟩ (North pole)": (0, 0),
    "|1⟩ (South pole)": (math.pi, 0),
    "|+⟩ = (|0⟩+|1⟩)/√2": (math.pi/2, 0),
    "|-⟩ = (|0⟩-|1⟩)/√2": (math.pi/2, math.pi),
    "|+i⟩ = (|0⟩+i|1⟩)/√2": (math.pi/2, math.pi/2),
    "|-i⟩ = (|0⟩-i|1⟩)/√2": (math.pi/2, -math.pi/2),
}

for name, (theta, phi) in states.items():
    zeta = bloch_to_stereo(theta, phi)
    print(f"  {name:30s} → ζ = {zeta.real:+.4f} {zeta.imag:+.4f}i")

# --- Hadamard Gate ---
print("\n--- Hadamard Gate as SPB ---")
print("H(ζ) = (ζ - 1)/(ζ + 1) = spb(ζ, -1)")

test_states = [0+0j, 1+0j, -1+0j, 1j, -1j]
for z in test_states:
    h_z = spb_complex(z, -1+0j)
    theta_in, phi_in = stereo_to_bloch(z) if abs(z) > 1e-15 else (0.0, 0.0)
    if abs(h_z) < 1e10:
        theta_out, phi_out = stereo_to_bloch(h_z)
        print(f"  H({z.real:+.2f}{z.imag:+.2f}i) = {h_z.real:+.4f}{h_z.imag:+.4f}i")
    else:
        print(f"  H({z.real:+.2f}{z.imag:+.2f}i) = ∞ (South pole)")

# --- Phase Gate ---
print("\n--- Phase Gate (S gate) ---")
print("S(ζ) = iζ  (rotation by π/2 around Z-axis)")
for z in test_states:
    s_z = 1j * z
    print(f"  S({z.real:+.2f}{z.imag:+.2f}i) = {s_z.real:+.4f}{s_z.imag:+.4f}i")

# --- T Gate ---
print("\n--- T Gate ---")
print("T(ζ) = e^{iπ/4} · ζ  (rotation by π/4 around Z-axis)")
phase = cmath.exp(1j * math.pi / 4)
for z in test_states:
    t_z = phase * z
    print(f"  T({z.real:+.2f}{z.imag:+.2f}i) = {t_z.real:+.4f}{t_z.imag:+.4f}i")

# --- Gate Composition ---
print("\n--- Gate Composition via SPB ---")
print("Composing two SPB gates: spb(spb(ζ, a), b) = spb(ζ, spb(a, b))")
a = 0.3 + 0.4j
b = -0.2 + 0.5j
z = 0.5 + 0.3j
lhs = spb_complex(spb_complex(z, a), b)
ab = spb_complex(a, b)
rhs = spb_complex(z, ab)
print(f"  a = {a}, b = {b}, ζ = {z}")
print(f"  spb(spb(ζ, a), b) = {lhs.real:+.6f}{lhs.imag:+.6f}i")
print(f"  spb(ζ, spb(a, b)) = {rhs.real:+.6f}{rhs.imag:+.6f}i")
print(f"  Match: {abs(lhs - rhs) < 1e-12}")

# --- Hadamard is its own inverse (up to stereographic nonlinearity) ---
print("\n--- Hadamard Squared ---")
print("H²(ζ) = -1/ζ (NOT identity on stereographic coords!)")
print("(Even though H² = I in Hilbert space)")
for z in [0.5+0j, 1j, 0.3+0.4j]:
    h1 = spb_complex(z, -1)
    h2 = spb_complex(h1, -1) if abs(h1 + 1) > 1e-15 else complex(float('inf'))
    neg_inv = -1/z if abs(z) > 1e-15 else complex(float('inf'))
    print(f"  ζ = {z}, H²(ζ) = {h2.real:+.6f}{h2.imag:+.6f}i, -1/ζ = {neg_inv.real:+.6f}{neg_inv.imag:+.6f}i")

# --- Bloch sphere visualization data ---
print("\n--- Orbit of |0⟩ under repeated SPB gates ---")
z = 0+0j  # Start at north pole
gate_param = 0.3 + 0.1j  # SPB gate parameter
print(f"Gate parameter: w = {gate_param}")
for step in range(10):
    theta, phi = stereo_to_bloch(z) if abs(z) > 1e-15 else (0.0, 0.0)
    print(f"  Step {step}: ζ = {z.real:+.6f}{z.imag:+.6f}i  (θ={theta:.4f}, φ={phi:.4f})")
    z = spb_complex(z, gate_param)

print("\n" + "=" * 70)
print("KEY INSIGHT: Quantum gates are Möbius transformations of stereographic")
print("coordinates. SPB is the special case arising from SU(2) elements of the")
print("form [[1, w], [-w*, 1]]/√(1+|w|²).")
print("=" * 70)

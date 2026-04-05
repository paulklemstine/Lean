#!/usr/bin/env python3
"""
Quantum Gate Synthesis via Quaternion Factoring
=================================================

Demonstrates the connection between quaternion factoring and quantum
gate synthesis. In quantum computing, any single-qubit gate is an
element of SU(2), which is isomorphic to the unit quaternions.

The Solovay-Kitaev theorem guarantees that any SU(2) element can be
approximated by a sequence of gates from a finite universal set
(e.g., Clifford+T). Finding the shortest such sequence is equivalent
to factoring in a quaternion algebra.

This demo:
1. Represents SU(2) gates as unit quaternions
2. Shows how gate composition = quaternion multiplication
3. Demonstrates the norm connection to factoring
4. Builds a gate dictionary via quaternion products

Usage:
    python quantum_gate_synthesis.py
"""

import math
import random
from typing import List, Tuple, Optional

random.seed(2024)


# ============================================================
# SU(2) as Unit Quaternions
# ============================================================

class UnitQuaternion:
    """A unit quaternion representing an SU(2) rotation.
    q = a + bi + cj + dk with a² + b² + c² + d² = 1."""

    def __init__(self, a: float, b: float, c: float, d: float):
        norm = math.sqrt(a**2 + b**2 + c**2 + d**2)
        if norm < 1e-12:
            self.a, self.b, self.c, self.d = 1, 0, 0, 0
        else:
            self.a = a/norm
            self.b = b/norm
            self.c = c/norm
            self.d = d/norm

    def __mul__(self, other: 'UnitQuaternion') -> 'UnitQuaternion':
        return UnitQuaternion(
            self.a*other.a - self.b*other.b - self.c*other.c - self.d*other.d,
            self.a*other.b + self.b*other.a + self.c*other.d - self.d*other.c,
            self.a*other.c - self.b*other.d + self.c*other.a + self.d*other.b,
            self.a*other.d + self.b*other.c - self.c*other.b + self.d*other.a
        )

    def conj(self) -> 'UnitQuaternion':
        return UnitQuaternion(self.a, -self.b, -self.c, -self.d)

    def rotation_angle(self) -> float:
        """The rotation angle θ such that q = cos(θ/2) + sin(θ/2)(bi+cj+dk)."""
        return 2 * math.acos(min(1.0, max(-1.0, self.a)))

    def distance(self, other: 'UnitQuaternion') -> float:
        """Distance on S³ between two unit quaternions."""
        dot = self.a*other.a + self.b*other.b + self.c*other.c + self.d*other.d
        return math.acos(min(1.0, max(-1.0, abs(dot))))

    def __repr__(self):
        return f"({self.a:.4f}, {self.b:.4f}, {self.c:.4f}, {self.d:.4f})"


# Standard quantum gates as quaternions
IDENTITY = UnitQuaternion(1, 0, 0, 0)
# Pauli gates
PAULI_X = UnitQuaternion(0, 1, 0, 0)  # 180° rotation about X
PAULI_Y = UnitQuaternion(0, 0, 1, 0)  # 180° rotation about Y
PAULI_Z = UnitQuaternion(0, 0, 0, 1)  # 180° rotation about Z
# Hadamard ≈ 180° rotation about (X+Z)/√2
HADAMARD = UnitQuaternion(0, 1/math.sqrt(2), 0, 1/math.sqrt(2))
# T gate = π/4 rotation about Z
T_GATE = UnitQuaternion(math.cos(math.pi/8), 0, 0, math.sin(math.pi/8))
# S gate = π/2 rotation about Z
S_GATE = UnitQuaternion(math.cos(math.pi/4), 0, 0, math.sin(math.pi/4))

GATE_SET = {
    'I': IDENTITY,
    'X': PAULI_X,
    'Y': PAULI_Y,
    'Z': PAULI_Z,
    'H': HADAMARD,
    'T': T_GATE,
    'S': S_GATE,
}


# ============================================================
# Gate Synthesis via Exhaustive Search
# ============================================================

def build_gate_dictionary(generators: dict, max_depth: int = 4) -> dict:
    """Build a dictionary of reachable gates via products of generators."""
    dictionary = {}
    current_level = {'': IDENTITY}
    dictionary[''] = IDENTITY

    for depth in range(1, max_depth + 1):
        next_level = {}
        for seq, q in current_level.items():
            for name, gate in generators.items():
                new_seq = seq + name
                new_q = q * gate
                # Check if we already have something close
                is_new = True
                for existing_q in dictionary.values():
                    if new_q.distance(existing_q) < 0.01:
                        is_new = False
                        break
                if is_new:
                    next_level[new_seq] = new_q
                    dictionary[new_seq] = new_q
        current_level = next_level

    return dictionary


def synthesize_gate(target: UnitQuaternion, dictionary: dict,
                    tolerance: float = 0.05) -> Optional[str]:
    """Find a gate sequence that approximates the target."""
    best_seq = None
    best_dist = float('inf')

    for seq, q in dictionary.items():
        dist = target.distance(q)
        if dist < best_dist:
            best_dist = dist
            best_seq = seq

    if best_dist < tolerance:
        return best_seq
    return None


# ============================================================
# Integer Quaternion → Gate Connection
# ============================================================

def integer_to_gate(a: int, b: int, c: int, d: int) -> UnitQuaternion:
    """Convert an integer quaternion to a unit quaternion (gate).
    This normalizes (a, b, c, d) to lie on S³."""
    return UnitQuaternion(a, b, c, d)


def demonstrate_norm_factoring_connection():
    """Show how integer quaternion norms relate to gate decomposition."""
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║    QUATERNION FACTORING ↔ QUANTUM GATE SYNTHESIS           ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    print("  The Key Isomorphism:")
    print("  ─────────────────────")
    print("  • SU(2) ≅ {unit quaternions}  (group isomorphism)")
    print("  • Quantum gate G ↔ unit quaternion q_G")
    print("  • Gate composition G₁G₂ ↔ quaternion product q₁·q₂")
    print("  • Gate synthesis = factoring q into generator products")
    print()

    # Show standard gates as quaternions
    print("  Standard Quantum Gates as Unit Quaternions:")
    print("  ─────────────────────────────────────────────")
    for name, gate in GATE_SET.items():
        angle = gate.rotation_angle() * 180 / math.pi
        print(f"    {name:3s} → q = {gate}  (rotation {angle:.1f}°)")
    print()

    # Verify multiplicativity
    print("  Multiplicativity Check (Gate Composition):")
    print("  ──────────────────────────────────────────────")
    compositions = [
        ('H', 'T', 'HT'),
        ('T', 'H', 'TH'),
        ('H', 'H', 'HH≈I'),
        ('S', 'S', 'SS=Z'),
        ('T', 'T', 'TT=S'),
    ]

    for g1_name, g2_name, label in compositions:
        g1 = GATE_SET[g1_name]
        g2 = GATE_SET[g2_name]
        product = g1 * g2
        angle = product.rotation_angle() * 180 / math.pi
        print(f"    {label:8s}: q({g1_name}) · q({g2_name}) = {product}  ({angle:.1f}°)")

    print()

    # Integer quaternion connection
    print("  Integer Quaternions → Gates:")
    print("  ──────────────────────────────")
    print("  An integer quaternion (a,b,c,d) with norm N = a²+b²+c²+d²")
    print("  normalizes to the unit quaternion (a/√N, b/√N, c/√N, d/√N).")
    print()

    int_quats = [
        (1, 1, 0, 0),   # norm 2
        (1, 1, 1, 0),   # norm 3
        (1, 1, 1, 1),   # norm 4
        (2, 1, 0, 0),   # norm 5
        (0, 1, 1, 1),   # norm 3
    ]

    for iq in int_quats:
        a, b, c, d = iq
        norm = a**2 + b**2 + c**2 + d**2
        uq = integer_to_gate(a, b, c, d)
        angle = uq.rotation_angle() * 180 / math.pi
        print(f"    ({a},{b},{c},{d})  norm={norm:2d}  → gate {uq}  ({angle:.1f}°)")

    print()

    # Factoring = gate decomposition
    print("  Factoring as Gate Decomposition:")
    print("  ──────────────────────────────────")
    print("  If N = p·q, then q_N = q_p · q_q (up to normalization)")
    print()

    # Example: 15 = 3 × 5
    q3 = UnitQuaternion(0, 1, 1, 1)   # norm-3 direction
    q5 = UnitQuaternion(0, 0, 1, 2)   # norm-5 direction
    q15_product = q3 * q5
    q15_direct = UnitQuaternion(1, 1, 2, 3)  # direct norm-15

    print(f"    15 = 3 × 5:")
    print(f"      q₃  = {q3}")
    print(f"      q₅  = {q5}")
    print(f"      q₃·q₅ = {q15_product}")
    print(f"      Direct q₁₅ = {q15_direct}")
    print(f"      Distance: {q15_product.distance(q15_direct):.6f}")
    print()

    # 143 = 11 × 13
    q11 = UnitQuaternion(0, 1, 1, 3)
    q13 = UnitQuaternion(0, 0, 2, 3)
    q143_product = q11 * q13

    print(f"    143 = 11 × 13:")
    print(f"      q₁₁ = {q11}")
    print(f"      q₁₃ = {q13}")
    print(f"      q₁₁·q₁₃ = {q143_product}")
    print(f"      Rotation angle: {q143_product.rotation_angle()*180/math.pi:.1f}°")


def demonstrate_gate_synthesis():
    """Demo the gate synthesis procedure."""
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║    GATE SYNTHESIS: FINDING SHORT QUATERNION PRODUCTS       ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    # Build dictionary from {H, T}
    generators = {'H': HADAMARD, 'T': T_GATE}
    print("  Building gate dictionary from {H, T}...")
    dictionary = build_gate_dictionary(generators, max_depth=5)
    print(f"  Dictionary size: {len(dictionary)} distinct gates")
    print()

    # Try to synthesize random rotations
    print("  Synthesizing Random Rotations:")
    print("  ────────────────────────────────")

    for trial in range(8):
        # Random rotation
        theta = random.uniform(0, 2*math.pi)
        phi = random.uniform(0, math.pi)
        psi = random.uniform(0, 2*math.pi)

        # Convert to quaternion
        a = math.cos(theta/2)
        b = math.sin(theta/2) * math.sin(phi) * math.cos(psi)
        c = math.sin(theta/2) * math.sin(phi) * math.sin(psi)
        d = math.sin(theta/2) * math.cos(phi)
        target = UnitQuaternion(a, b, c, d)

        # Synthesize
        seq = synthesize_gate(target, dictionary, tolerance=0.15)
        if seq:
            approx = dictionary[seq]
            dist = target.distance(approx)
            print(f"    Target {target} → '{seq}' (len={len(seq)}, dist={dist:.4f})")
        else:
            # Find best approximation
            best_seq = min(dictionary.keys(), key=lambda s: target.distance(dictionary[s]))
            best_dist = target.distance(dictionary[best_seq])
            print(f"    Target {target} → best '{best_seq}' (len={len(best_seq)}, dist={best_dist:.4f})")

    print()
    print("  Connection to Factoring:")
    print("  ────────────────────────")
    print("  • Short gate sequences ↔ short quaternion products")
    print("  • Gate synthesis complexity ↔ lattice shortest vector problem")
    print("  • Exact synthesis over ℤ[1/√2] ↔ factoring in quaternion orders")
    print("  • Solovay-Kitaev bound: O(log^c(1/ε)) gates for ε-approximation")


def demonstrate_coverage():
    """Show how the quaternion factoring lattice covers the rotation space."""
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║    ROTATION SPACE COVERAGE                                 ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    # Generate integer quaternions with small norm
    print("  Integer quaternions of norm ≤ 20 and their rotation angles:")
    print("  ────────────────────────────────────────────────────────────")

    angles_by_norm = {}
    for n in range(1, 21):
        angles = set()
        for a in range(int(math.isqrt(n)) + 1):
            for b in range(int(math.isqrt(n - a*a)) + 1):
                for c in range(int(math.isqrt(n - a*a - b*b)) + 1):
                    d2 = n - a*a - b*b - c*c
                    if d2 >= 0:
                        d = int(math.isqrt(d2))
                        if d*d == d2:
                            q = UnitQuaternion(a, b, c, d)
                            angle = round(q.rotation_angle() * 180 / math.pi, 1)
                            angles.add(angle)
        if angles:
            angles_by_norm[n] = sorted(angles)

    for n, angles in list(angles_by_norm.items())[:15]:
        print(f"    norm {n:2d}: {len(angles):3d} distinct angles: {angles[:8]}{'...' if len(angles) > 8 else ''}")

    print()

    # Measure coverage of [0°, 180°] range
    all_angles = set()
    for angles in angles_by_norm.values():
        for a in angles:
            all_angles.add(a)

    bucket_size = 10  # degrees
    covered_buckets = set()
    for a in all_angles:
        covered_buckets.add(int(a / bucket_size))

    total_buckets = 180 // bucket_size
    coverage = len(covered_buckets) / total_buckets * 100

    print(f"  Coverage of [0°, 180°] in {bucket_size}° buckets: "
          f"{len(covered_buckets)}/{total_buckets} = {coverage:.0f}%")
    print()
    print(f"  Total distinct rotation angles (norm ≤ 20): {len(all_angles)}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demonstrate_norm_factoring_connection()
    demonstrate_gate_synthesis()
    demonstrate_coverage()

    print()
    print("═" * 62)
    print("  QUANTUM GATE SYNTHESIS DEMO COMPLETE")
    print("═" * 62)

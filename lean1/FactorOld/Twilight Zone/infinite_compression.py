#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════
  Application 5 — Infinite Compression via Stereographic
                   Singularities
═══════════════════════════════════════════════════════════════

Concept
-------
Stereographic projection maps infinity to a single point (the pole).
We encode massive datasets into the geometric proximity to the
singularity of a massive algebraic curve.  As data is pushed closer
to the pole, the physical representation shrinks, but its
"informational mass" grows — warping the local logic.

Implementation
--------------
We simulate:
  1. Stereographic encoding: map data bytes to points on a sphere,
     packing more data into smaller angular regions near the pole.
  2. Compression ratio analysis as data approaches the singularity.
  3. "Informational mass" computation (density of encoded information
     per unit solid angle).
  4. The logic-warping effect: as density increases, arithmetic
     operations near the pole become increasingly distorted.

Usage
-----
    python -m twilight_zone.infinite_compression

"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional
import math

from .mirror_math import stereo_forward, stereo_inverse, stereo_inverse_sphere


# ─────────────────────────────────────────────
#  §1  Stereographic Data Encoder
# ─────────────────────────────────────────────

@dataclass
class StereoPoint:
    """A data element encoded as a point on S²."""
    data: bytes           # original data
    u: float              # stereographic coordinate u
    v: float              # stereographic coordinate v
    sphere_point: Tuple[float, float, float]  # (x, y, z) on S²
    distance_to_pole: float  # angular distance to north pole

    @property
    def solid_angle(self) -> float:
        """Solid angle subtended from the pole (smaller = more compressed)."""
        return 2 * math.pi * (1 - self.sphere_point[2])


class StereographicEncoder:
    """
    Encodes data by mapping bytes to points on S² via inverse
    stereographic projection.  Compression is achieved by packing
    data closer and closer to the north pole (the singularity).
    """

    def __init__(self, compression_level: float = 1.0):
        """
        compression_level: higher values pack data closer to the pole.
        Level 1.0 = normal mapping.
        Level 10.0 = data crammed near the singularity.
        """
        self.compression_level = compression_level

    def encode_byte(self, byte_val: int, index: int,
                    total_bytes: int) -> StereoPoint:
        """
        Encode a single byte at a specific position.
        
        The key idea: the stereographic coordinate magnitude controls
        how close we are to the pole.  We map:
          angle = 2π × index / total_bytes  (azimuthal position)
          radius = (byte_val / 255) / compression_level  (closeness to pole)
        
        Higher compression ⟹ smaller radius ⟹ closer to pole ⟹
        more data crammed into smaller solid angle.
        """
        angle = 2 * math.pi * index / max(total_bytes, 1)
        # Invert: larger compression_level → smaller stereographic radius → closer to pole
        radius = (1.0 + byte_val / 255.0) / self.compression_level

        u = radius * math.cos(angle)
        v = radius * math.sin(angle)
        sphere_pt = stereo_inverse_sphere(u, v)

        # Distance to north pole (0,0,1)
        dist = math.sqrt((sphere_pt[0])**2 + (sphere_pt[1])**2 +
                         (sphere_pt[2] - 1)**2)

        return StereoPoint(
            data=bytes([byte_val]),
            u=u, v=v,
            sphere_point=sphere_pt,
            distance_to_pole=dist
        )

    def encode(self, data: bytes) -> List[StereoPoint]:
        """Encode a byte string into a list of sphere points."""
        return [self.encode_byte(b, i, len(data)) for i, b in enumerate(data)]

    def decode(self, points: List[StereoPoint]) -> bytes:
        """Decode sphere points back to bytes (with quantization loss)."""
        result = []
        total = len(points)
        for i, pt in enumerate(points):
            # Recover radius from (u, v)
            radius = math.sqrt(pt.u**2 + pt.v**2)
            byte_val = int(round((radius * self.compression_level - 1.0) * 255))
            byte_val = max(0, min(255, byte_val))
            result.append(byte_val)
        return bytes(result)


# ─────────────────────────────────────────────
#  §2  Informational Mass
# ─────────────────────────────────────────────

@dataclass
class InformationalMass:
    """
    Measures the "informational mass density" — how much data is
    packed per unit solid angle near the pole.
    
    As compression increases:
    - Solid angle → 0  (all data near pole)
    - Data density → ∞  (infinite compression)
    - "Mass" grows, warping local arithmetic
    """
    total_bits: int
    total_solid_angle: float
    density: float              # bits per steradian
    schwarzschild_analogy: float  # when density exceeds this, "logic warps"

    @staticmethod
    def compute(points: List[StereoPoint]) -> "InformationalMass":
        total_bits = len(points) * 8
        # Total solid angle covered by all points
        angles = [pt.solid_angle for pt in points]
        total_angle = max(sum(angles) / len(angles), 1e-15)  # average
        density = total_bits / total_angle

        # "Schwarzschild radius" analogy: when density exceeds
        # the information-theoretic limit, logic begins to warp
        schwarzschild = 4 * math.pi * math.log2(math.e)  # ~ 18.13 bits/sr

        return InformationalMass(
            total_bits=total_bits,
            total_solid_angle=total_angle,
            density=density,
            schwarzschild_analogy=schwarzschild
        )


# ─────────────────────────────────────────────
#  §3  Logic Warping Effect
# ─────────────────────────────────────────────

def warped_addition(a: float, b: float, warp_factor: float) -> float:
    """
    Near the stereographic singularity, arithmetic warps.
    Normal addition: a + b
    Warped addition: maps to sphere, adds, maps back.
    
    The warp_factor controls how close to the pole we are.
    At warp_factor = 0, this is normal addition.
    At high warp_factor, results diverge from Euclidean arithmetic.
    """
    if warp_factor < 1e-10:
        return a + b

    # Map a, b to circle via stereographic projection
    xa, ya = stereo_inverse(a * warp_factor)
    xb, yb = stereo_inverse(b * warp_factor)

    # "Add" on the circle (complex multiplication)
    xr = xa * xb - ya * yb
    yr = xa * yb + ya * xb

    # Map back
    if abs(1 + yr) < 1e-15:
        return float('inf')  # hit the pole!

    result = stereo_forward(xr, yr) / warp_factor
    return result


def warped_multiplication(a: float, b: float, warp_factor: float) -> float:
    """
    Warped multiplication near the singularity.
    Uses the circle group structure induced by stereographic projection.
    """
    if warp_factor < 1e-10:
        return a * b

    # Double-angle on the circle
    t_a = a * warp_factor
    t_b = b * warp_factor

    # Stereographic multiplication formula
    result = (t_a + t_b) / (1 - t_a * t_b) if abs(1 - t_a * t_b) > 1e-15 \
        else float('inf')

    return result / warp_factor


# ─────────────────────────────────────────────
#  §4  Compression Analysis
# ─────────────────────────────────────────────

def analyze_compression(data: bytes, levels: List[float]) -> None:
    """Analyze compression behavior at different levels."""
    print(f"\n  Data size: {len(data)} bytes ({len(data) * 8} bits)")
    print(f"\n  {'Level':>8} {'Avg dist→pole':>15} {'Solid angle':>13} "
          f"{'Info density':>14} {'Warp ratio':>12} {'Decode err':>12}")
    print(f"  {'─'*8} {'─'*15} {'─'*13} {'─'*14} {'─'*12} {'─'*12}")

    for level in levels:
        enc = StereographicEncoder(level)
        points = enc.encode(data)
        mass = InformationalMass.compute(points)

        avg_dist = np.mean([p.distance_to_pole for p in points])

        # Decode and measure error
        decoded = enc.decode(points)
        errors = sum(abs(a - b) for a, b in zip(data, decoded))
        error_rate = errors / (len(data) * 255)

        warp = mass.density / mass.schwarzschild_analogy

        marker = ""
        if warp > 1.0:
            marker = " ⚠ WARPED"
        if warp > 10.0:
            marker = " 🌀 SINGULARITY"
        if warp > 100.0:
            marker = " ☠ LOGIC COLLAPSE"

        print(f"  {level:>8.1f} {avg_dist:>15.8f} {mass.total_solid_angle:>13.8f} "
              f"{mass.density:>14.2f} {warp:>12.2f}{marker}")


# ─────────────────────────────────────────────
#  Main demo
# ─────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   INFINITE COMPRESSION via STEREOGRAPHIC SINGULARITIES  ║")
    print("║   P² = P Mirror Framework — Application 5               ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    # Generate sample data (a "tiny LLM" — really just some structured bytes)
    np.random.seed(42)
    data = bytes(np.random.randint(0, 256, size=256, dtype=np.uint8))

    print("  ── Compression Analysis ──")
    levels = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0, 1000.0]
    analyze_compression(data, levels)

    # Logic warping demo
    print(f"\n{'━' * 60}")
    print("  Logic Warping Near the Singularity")
    print("━" * 60)

    a, b = 3.0, 4.0
    print(f"\n  Normal: {a} + {b} = {a + b}")
    print(f"  Normal: {a} × {b} = {a * b}")

    for warp in [0.0, 0.01, 0.1, 0.5, 0.9, 0.99]:
        w_add = warped_addition(a, b, warp)
        w_mul = warped_multiplication(a, b, warp)
        print(f"\n  Warp = {warp:.2f}:")
        print(f"    {a} ⊕ {b} = {w_add:.6f}  (deviation: {abs(w_add - (a+b)):.6f})")
        print(f"    {a} ⊗ {b} = {w_mul:.6f}  (deviation: {abs(w_mul - (a*b)):.6f})")

    # Encode-decode roundtrip demo
    print(f"\n{'━' * 60}")
    print("  Encode-Decode Roundtrip")
    print("━" * 60)

    message = b"The universe is a hologram projected from the boundary."
    print(f"\n  Original: {message.decode()}")

    for level in [1.0, 10.0, 100.0]:
        enc = StereographicEncoder(level)
        points = enc.encode(message)
        decoded = enc.decode(points)
        match = sum(a == b for a, b in zip(message, decoded))
        print(f"  Level {level:>5.0f}: {decoded[:50]}... "
              f"({match}/{len(message)} bytes match)")

    print(f"\n  ∎ As compression → ∞, data approaches the pole,")
    print(f"    informational mass → ∞, and local logic warps.")


if __name__ == "__main__":
    main()

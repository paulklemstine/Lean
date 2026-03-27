#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════
  Application 3 — Gravity-Resonant Blockchains
═══════════════════════════════════════════════════════════════

Concept
-------
A blockchain where elliptic curve parameters are dynamically linked
to the local gravitational field.  Transactions can only be signed
when spacetime curvature matches the curve's discriminant — e.g.,
"This wallet unlocks only during a solar eclipse."

Implementation
--------------
We simulate:
  1. A gravitational field model (Schwarzschild metric + tidal tensor).
  2. Dynamic elliptic curve parameter generation from local curvature.
  3. A "gravity-locked" wallet that only signs at specific altitudes
     or near specific masses.
  4. A solar-eclipse signature scenario.

Usage
-----
    python -m twilight_zone.gravity_blockchain

"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from typing import Optional, Tuple, List
import hashlib, time

from .mirror_math import (
    EllipticCurve, ec_add, ec_mul, INF_POINT,
    sha256_int, random_scalar,
    stereo_inverse_sphere
)


# ─────────────────────────────────────────────
#  §1  Gravitational field model
# ─────────────────────────────────────────────

# Physical constants
G_NEWTON = 6.674e-11      # m³/(kg·s²)
C_LIGHT = 2.998e8         # m/s
M_EARTH = 5.972e24        # kg
M_SUN = 1.989e30          # kg
M_MOON = 7.342e22         # kg
R_EARTH = 6.371e6         # m
AU = 1.496e11             # m (Earth-Sun distance)
R_MOON_ORBIT = 3.844e8    # m


@dataclass
class GravitySource:
    """A point mass generating a gravitational field."""
    name: str
    mass: float       # kg
    position: np.ndarray  # 3-D position in meters

    def potential(self, r: np.ndarray) -> float:
        """Newtonian gravitational potential Φ = -GM/|r - r₀|."""
        dist = np.linalg.norm(r - self.position)
        if dist < 1.0:
            dist = 1.0
        return -G_NEWTON * self.mass / dist

    def schwarzschild_radius(self) -> float:
        return 2 * G_NEWTON * self.mass / (C_LIGHT ** 2)

    def curvature_scalar(self, r: np.ndarray) -> float:
        """
        Kretschner scalar (simplified) ∝ M²/r⁶ for Schwarzschild.
        Gives a measure of local spacetime curvature.
        """
        dist = np.linalg.norm(r - self.position)
        if dist < 1.0:
            dist = 1.0
        rs = self.schwarzschild_radius()
        return 48 * (rs ** 2) / (dist ** 6)


@dataclass
class GravityField:
    """Superposition of gravity sources."""
    sources: List[GravitySource]

    def total_curvature(self, r: np.ndarray) -> float:
        """Sum of curvature contributions (simplified superposition)."""
        return sum(s.curvature_scalar(r) for s in self.sources)

    def total_potential(self, r: np.ndarray) -> float:
        return sum(s.potential(r) for s in self.sources)

    def tidal_tensor_trace(self, r: np.ndarray, delta: float = 1.0) -> float:
        """
        Numerical trace of the tidal tensor (∇²Φ) via finite differences.
        In vacuum, this should be ~0 (Laplace equation), but with
        multiple sources and numerical noise, it encodes local field info.
        """
        phi_center = self.total_potential(r)
        trace = 0.0
        for axis in range(3):
            dr = np.zeros(3)
            dr[axis] = delta
            trace += (self.total_potential(r + dr) +
                      self.total_potential(r - dr) - 2 * phi_center) / delta**2
        return trace


# ─────────────────────────────────────────────
#  §2  Gravity → Elliptic Curve mapping
# ─────────────────────────────────────────────

def gravity_fingerprint(field: 'GravityField', position: np.ndarray) -> bytes:
    """
    Compute a cryptographic fingerprint of the full gravitational
    field configuration at a given position.  This is sensitive to
    the positions/masses of ALL sources, not just total curvature.
    """
    import struct
    data = b"GRAV_FP:"
    for src in field.sources:
        dist = np.linalg.norm(position - src.position)
        pot = src.potential(position)
        curv = src.curvature_scalar(position)
        data += struct.pack("!ddd", dist, pot, curv)
    return hashlib.sha512(data).digest()


def curvature_to_curve_params(curvature: float, tidal_trace: float,
                              prime_bits: int = 64) -> Tuple[int, int, int]:
    """
    Map gravitational field observables to elliptic curve parameters (a, b, p).
    
    The curvature feeds into the curve parameters via hashing, ensuring:
    - Deterministic: same gravity ⟹ same curve.
    - Sensitive: tiny changes in position ⟹ completely different curve.
    - Valid: discriminant Δ = -16(4a³ + 27b²) ≠ 0 mod p.
    """
    # Encode the gravitational observables
    data = f"GRAV:{curvature:.15e}|TIDAL:{tidal_trace:.15e}".encode()
    h = hashlib.sha512(data).hexdigest()

    # Extract a, b from hash
    a = int(h[:16], 16)
    b = int(h[16:32], 16)

    # Use a known safe prime for the field (64-bit for demo speed)
    p = (1 << prime_bits) - 59  # a 64-bit prime

    a = a % p
    b = b % p

    # Ensure non-singular: Δ ≠ 0
    disc = (4 * pow(a, 3, p) + 27 * pow(b, 2, p)) % p
    while disc == 0:
        b = (b + 1) % p
        disc = (4 * pow(a, 3, p) + 27 * pow(b, 2, p)) % p

    return a, b, p


# ─────────────────────────────────────────────
#  §3  Gravity-Locked Wallet
# ─────────────────────────────────────────────

@dataclass
class GravityWallet:
    """
    A wallet that can only sign transactions when the local gravitational
    field matches the wallet's birth curvature within a tolerance.
    """
    owner: str
    birth_curvature: float
    birth_tidal: float
    tolerance: float          # relative tolerance on curvature match
    private_key: int
    curve: EllipticCurve
    generator: Optional[Tuple[int, int]]
    order: int

    @staticmethod
    def create(owner: str, field: GravityField, position: np.ndarray,
               tolerance: float = 0.01) -> "GravityWallet":
        """Create a wallet locked to the gravitational field at `position`."""
        curv = field.total_curvature(position)
        tidal = field.tidal_tensor_trace(position)
        # Store the full gravitational fingerprint for precise matching
        birth_fp = gravity_fingerprint(field, position)
        a, b, p = curvature_to_curve_params(curv, tidal)
        curve = EllipticCurve(a=a, b=b, p=p)

        # Find a generator point (brute-force for small fields)
        G = _find_generator(curve)
        order = _point_order(curve, G)

        priv = random_scalar() % (order - 1) + 1

        print(f"  [Wallet] Created for '{owner}'")
        print(f"  [Wallet] Curvature = {curv:.6e}")
        print(f"  [Wallet] Curve: y² = x³ + {a}x + {b}  (mod {p})")
        print(f"  [Wallet] Tolerance: ±{tolerance*100:.1f}%")

        wallet = GravityWallet(
            owner=owner, birth_curvature=curv, birth_tidal=tidal,
            tolerance=tolerance, private_key=priv,
            curve=curve, generator=G, order=order
        )
        wallet._birth_fingerprint = birth_fp
        return wallet

    def try_sign(self, message: bytes, field: GravityField,
                 current_position: np.ndarray) -> Optional[Tuple[int, int]]:
        """
        Attempt to sign a transaction.  Only succeeds if the current
        gravitational curvature matches the wallet's birth curvature.
        """
        # Check full gravitational fingerprint for precise matching
        current_fp = gravity_fingerprint(field, current_position)
        current_curv = field.total_curvature(current_position)
        ratio = abs(current_curv - self.birth_curvature) / max(self.birth_curvature, 1e-50)

        # Fingerprint must match exactly (captures source geometry)
        fp_match = hasattr(self, '_birth_fingerprint') and current_fp == self._birth_fingerprint

        if not fp_match:
            print(f"  [DENIED] Gravitational fingerprint mismatch!")
            print(f"  [DENIED] The gravitational source geometry has changed.")
            if ratio > 0.001:
                print(f"  [DENIED] Curvature: {current_curv:.6e} vs required {self.birth_curvature:.6e}")
            else:
                print(f"  [DENIED] Curvature is similar, but source positions differ.")
            return None
        if ratio > self.tolerance:
            print(f"  [DENIED] Curvature mismatch: {ratio*100:.2f}% "
                  f"(need < {self.tolerance*100:.1f}%)")
            print(f"  [DENIED] Current: {current_curv:.6e}, "
                  f"Required: {self.birth_curvature:.6e}")
            return None

        # Curvature matches — sign the transaction
        z = sha256_int(message) % self.order
        # Find a k that is coprime with the order
        import math
        for attempt in range(100):
            k = sha256_int(message + b"nonce" + attempt.to_bytes(4, 'big')) % (self.order - 1) + 1
            if math.gcd(k, self.order) == 1:
                break
        else:
            print("  [ERROR] Could not find valid nonce")
            return None
        R = ec_mul(self.curve, k, self.generator)
        if R is None:
            return None
        r = R[0] % self.order
        if r == 0:
            return None
        s = (pow(k, -1, self.order) * (z + r * self.private_key)) % self.order

        print(f"  [SIGNED] Curvature match: {ratio*100:.4f}% < {self.tolerance*100:.1f}%")
        return (r, s)


def _find_generator(curve: EllipticCurve) -> Tuple[int, int]:
    """Find a point on the curve by brute force (for small primes)."""
    p = curve.p
    for x in range(p):
        rhs = (pow(x, 3, p) + curve.a * x + curve.b) % p
        y = _modular_sqrt(rhs, p)
        if y is not None:
            return (x, y)
    raise ValueError("No point found on curve")


def _modular_sqrt(a: int, p: int) -> Optional[int]:
    """Tonelli-Shanks (simplified for small primes)."""
    a = a % p
    if a == 0:
        return 0
    if pow(a, (p - 1) // 2, p) != 1:
        return None  # not a QR
    # For p ≡ 3 (mod 4)
    if p % 4 == 3:
        return pow(a, (p + 1) // 4, p)
    # General Tonelli-Shanks
    q, s = p - 1, 0
    while q % 2 == 0:
        q //= 2
        s += 1
    z = 2
    while pow(z, (p - 1) // 2, p) != p - 1:
        z += 1
    m, c, t, r = s, pow(z, q, p), pow(a, q, p), pow(a, (q + 1) // 2, p)
    while t != 1:
        i = 1
        tmp = (t * t) % p
        while tmp != 1:
            tmp = (tmp * tmp) % p
            i += 1
        b = pow(c, 1 << (m - i - 1), p)
        m, c, t, r = i, (b * b) % p, (t * b * b) % p, (r * b) % p
    return r


def _point_order(curve: EllipticCurve, P: Tuple[int, int],
                 max_order: int = 100000) -> int:
    """Find the order of point P (brute force for small curves)."""
    Q = P
    for n in range(2, max_order):
        Q = ec_add(curve, Q, P)
        if Q is None:
            return n
    return max_order


# ─────────────────────────────────────────────
#  Main demo
# ─────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   GRAVITY-RESONANT BLOCKCHAINS                          ║")
    print("║   P² = P Mirror Framework — Application 3               ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    # Set up the solar system
    earth = GravitySource("Earth", M_EARTH, np.array([0.0, 0.0, 0.0]))
    sun = GravitySource("Sun", M_SUN, np.array([AU, 0.0, 0.0]))
    moon = GravitySource("Moon", M_MOON, np.array([R_MOON_ORBIT, 0.0, 0.0]))
    field = GravityField([earth, sun, moon])

    # ── Scenario 1: Altitude-locked wallet ──
    print("━" * 60)
    print("  Scenario 1: Altitude-Locked Wallet")
    print("━" * 60)

    surface = np.array([0.0, 0.0, R_EARTH])  # on Earth's surface
    wallet = GravityWallet.create("Alice", field, surface, tolerance=0.001)

    msg = b"Transfer 1 BTC to Bob"
    print(f"\n  Signing from Earth's surface (altitude = 0 m):")
    sig = wallet.try_sign(msg, field, surface)

    airplane = np.array([0.0, 0.0, R_EARTH + 10000])  # 10 km altitude
    print(f"\n  Signing from airplane (altitude = 10,000 m):")
    sig = wallet.try_sign(msg, field, airplane)

    space = np.array([0.0, 0.0, R_EARTH + 400000])  # ISS altitude
    print(f"\n  Signing from ISS (altitude = 400 km):")
    sig = wallet.try_sign(msg, field, space)

    # ── Scenario 2: Solar Eclipse Lock ──
    print(f"\n{'━' * 60}")
    print("  Scenario 2: Solar Eclipse Transaction")
    print("━" * 60)

    # During a solar eclipse, the Moon is between Earth and Sun
    eclipse_moon = GravitySource("Moon (eclipse)",
                                  M_MOON, np.array([R_MOON_ORBIT, 0.0, 0.0]))
    eclipse_field = GravityField([earth, sun, eclipse_moon])

    # Wallet created during the eclipse
    eclipse_pos = np.array([0.0, 0.0, R_EARTH])
    eclipse_wallet = GravityWallet.create("Eclipse Wallet",
                                           eclipse_field, eclipse_pos,
                                           tolerance=1e-10)

    print(f"\n  Signing during eclipse (Moon aligned):")
    sig = eclipse_wallet.try_sign(b"Eclipse TX", eclipse_field, eclipse_pos)

    # Try signing when Moon has moved (no eclipse)
    # Moon moves to a different position — observer is on the Earth-Sun line
    # so the distance to the Moon changes
    normal_moon = GravitySource("Moon (normal)",
                                 M_MOON, np.array([0.0, R_MOON_ORBIT, 0.0]))
    normal_field = GravityField([earth, sun, normal_moon])
    # Observer is on the x-axis (toward the Sun), so Moon's x vs y position matters
    observer_eclipse = np.array([R_EARTH, 0.0, 0.0])  # on Earth-Sun line
    eclipse_wallet_v2 = GravityWallet.create("Eclipse Wallet v2",
                                              eclipse_field, observer_eclipse,
                                              tolerance=0.001)
    print(f"\n  Signing during eclipse (observer on Earth-Sun line):")
    sig = eclipse_wallet_v2.try_sign(b"Eclipse TX", eclipse_field, observer_eclipse)
    print(f"\n  Signing outside eclipse (Moon at 90°, same observer):")
    sig = eclipse_wallet_v2.try_sign(b"Eclipse TX", normal_field, observer_eclipse)

    print(f"\n  ∎ The wallet is gravitationally locked to the eclipse geometry.")


if __name__ == "__main__":
    main()

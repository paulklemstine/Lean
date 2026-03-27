"""
mirror_math.py — Shared mathematical primitives for the P² = P framework.

Provides:
  - Projection matrices and the Mirror Axiom (P² = P)
  - Stereographic projection (forward and inverse)
  - Elliptic curve point arithmetic over finite fields
  - Utility helpers used by all five application modules
"""

import numpy as np
from dataclasses import dataclass
from typing import Optional, Tuple
import hashlib, secrets


# ─────────────────────────────────────────────
#  §1  Projection / Mirror primitives
# ─────────────────────────────────────────────

def make_projector(v: np.ndarray) -> np.ndarray:
    """Return the rank-1 projector P = |v><v| / <v|v>, satisfying P² = P."""
    v = v.astype(float).reshape(-1, 1)
    return (v @ v.T) / (v.T @ v)


def verify_mirror_axiom(P: np.ndarray, tol: float = 1e-12) -> bool:
    """Check P² = P (idempotency) and P = Pᵀ (self-adjointness)."""
    return (np.allclose(P @ P, P, atol=tol) and
            np.allclose(P, P.T, atol=tol))


def complement(P: np.ndarray) -> np.ndarray:
    """Return I - P, the orthogonal complement mirror."""
    return np.eye(P.shape[0]) - P


def grover_reflection(P: np.ndarray) -> np.ndarray:
    """Grover iterate: 2P - I."""
    return 2 * P - np.eye(P.shape[0])


# ─────────────────────────────────────────────
#  §2  Stereographic projection
# ─────────────────────────────────────────────

def stereo_forward(x: float, y: float) -> float:
    """Stereographic projection from S¹ → ℝ, projecting from south pole: t = x/(1+y)."""
    if np.isclose(y, -1.0):
        return float('inf')
    return x / (1.0 + y)


def stereo_inverse(t: float) -> Tuple[float, float]:
    """Inverse stereographic projection ℝ → S¹: (x, y) = (2t/(1+t²), (1-t²)/(1+t²))."""
    t2 = t * t
    denom = 1.0 + t2
    return (2.0 * t / denom, (1.0 - t2) / denom)


def stereo_inverse_sphere(u: float, v: float) -> Tuple[float, float, float]:
    """Inverse stereographic projection ℝ² → S², from north pole."""
    r2 = u * u + v * v
    denom = 1.0 + r2
    return (2 * u / denom, 2 * v / denom, (r2 - 1) / denom)


# ─────────────────────────────────────────────
#  §3  Elliptic Curve arithmetic (Weierstrass)
# ─────────────────────────────────────────────

@dataclass
class EllipticCurve:
    """y² = x³ + ax + b  over F_p (or ℝ when p=0)."""
    a: int
    b: int
    p: int  # 0 means real / symbolic

    def discriminant(self) -> int:
        return (-16 * (4 * self.a**3 + 27 * self.b**2)) % self.p if self.p else \
               -16 * (4 * self.a**3 + 27 * self.b**2)

    def on_curve(self, x: int, y: int) -> bool:
        if self.p:
            return (y * y - x * x * x - self.a * x - self.b) % self.p == 0
        return y * y == x * x * x + self.a * x + self.b


# Point at infinity sentinel
INF_POINT = None


def ec_add(curve: EllipticCurve, P: Optional[Tuple[int, int]],
           Q: Optional[Tuple[int, int]]) -> Optional[Tuple[int, int]]:
    """Add two points on an elliptic curve over F_p."""
    p = curve.p
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2 and (y1 + y2) % p == 0:
        return INF_POINT
    if P == Q:
        lam = (3 * x1 * x1 + curve.a) * pow(2 * y1, -1, p) % p
    else:
        lam = (y2 - y1) * pow(x2 - x1, -1, p) % p
    x3 = (lam * lam - x1 - x2) % p
    y3 = (lam * (x1 - x3) - y1) % p
    return (x3, y3)


def ec_mul(curve: EllipticCurve, k: int,
           P: Optional[Tuple[int, int]]) -> Optional[Tuple[int, int]]:
    """Scalar multiplication k·P via double-and-add (the 'mirror chain')."""
    result = INF_POINT
    addend = P
    while k > 0:
        if k & 1:
            result = ec_add(curve, result, addend)
        addend = ec_add(curve, addend, addend)  # "mirror reflection" doubling
        k >>= 1
    return result


# ─────────────────────────────────────────────
#  §4  secp256k1 parameters (production curve)
# ─────────────────────────────────────────────

SECP256K1 = EllipticCurve(
    a=0, b=7,
    p=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
)
SECP256K1_G = (
    0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
    0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
)
SECP256K1_N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141


# ─────────────────────────────────────────────
#  §5  Hashing / Signature helpers
# ─────────────────────────────────────────────

def sha256_int(data: bytes) -> int:
    return int(hashlib.sha256(data).hexdigest(), 16)


def random_scalar() -> int:
    return secrets.randbelow(SECP256K1_N - 1) + 1

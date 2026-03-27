#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════
  Application 1 — The Holographic Cryptographic Vault
═══════════════════════════════════════════════════════════════

Concept
-------
A vault whose "password" is a photon trajectory through a physical
mirror geometry.  The room's mirror layout encodes an elliptic curve;
a photon bouncing through the mirrors traces out a scalar-multiplication
chain, computing an ECDSA signature at the speed of light.

If an intruder tries to measure the geometry (observe intermediate
reflections), the P² = P projection axiom collapses the chain into a
single fixed point — a topological trap.

Implementation
--------------
We simulate:
  1. A 2-D mirror room whose wall normals define projection operators.
  2. A photon whose reflections trace out EC point doublings.
  3. An ECDSA-like "vault signature" computed purely by mirror bounces.
  4. An intrusion detector: measuring any intermediate state triggers
     the collapse (P² = P ⟹ chain contracts to a fixed point).

Usage
-----
    python -m twilight_zone.holographic_vault

"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass, field
from typing import List, Tuple, Optional
import secrets, hashlib

from .mirror_math import (
    make_projector, verify_mirror_axiom, complement, grover_reflection,
    EllipticCurve, ec_add, ec_mul, INF_POINT,
    SECP256K1, SECP256K1_G, SECP256K1_N, sha256_int, random_scalar
)


# ─────────────────────────────────────────────
#  Mirror Room geometry
# ─────────────────────────────────────────────

@dataclass
class Mirror:
    """A physical mirror defined by its normal vector (a rank-1 projector)."""
    normal: np.ndarray          # unit normal
    projector: np.ndarray = field(init=False)
    complement: np.ndarray = field(init=False)

    def __post_init__(self):
        self.normal = self.normal / np.linalg.norm(self.normal)
        self.projector = make_projector(self.normal)
        self.complement = complement(self.projector)
        assert verify_mirror_axiom(self.projector), "Mirror axiom violated!"

    def reflect(self, v: np.ndarray) -> np.ndarray:
        """Reflect vector v: R = I - 2P (Householder reflection)."""
        return v - 2 * self.projector @ v


@dataclass
class MirrorRoom:
    """A vault room defined by N mirrors arranged in a cycle."""
    mirrors: List[Mirror]

    @staticmethod
    def from_polygon(n_sides: int, radius: float = 1.0) -> "MirrorRoom":
        """Create a regular-polygon room with n mirrors."""
        mirrors = []
        for i in range(n_sides):
            angle = 2 * np.pi * i / n_sides
            normal = np.array([np.cos(angle), np.sin(angle)])
            mirrors.append(Mirror(normal))
        return MirrorRoom(mirrors)

    def bounce_photon(self, direction: np.ndarray, n_bounces: int,
                      observed: Optional[int] = None) -> List[np.ndarray]:
        """
        Trace a photon through the room for n_bounces reflections.
        
        If `observed` is set, an "intruder" observes bounce #observed,
        triggering wavefunction collapse (P² = P projection).
        """
        trajectory = [direction.copy()]
        v = direction.astype(float)

        for i in range(n_bounces):
            mirror = self.mirrors[i % len(self.mirrors)]

            if observed is not None and i == observed:
                # Observation ⟹ P² = P collapse: project instead of reflect
                v = mirror.projector @ v
                # The photon is now trapped on the mirror's axis
                trajectory.append(v.copy())
                # All subsequent bounces are fixed points
                for _ in range(i + 1, n_bounces):
                    trajectory.append(v.copy())  # trapped!
                return trajectory

            v = mirror.reflect(v)
            trajectory.append(v.copy())

        return trajectory


# ─────────────────────────────────────────────
#  Vault Signature Protocol
# ─────────────────────────────────────────────

@dataclass
class VaultSignature:
    """ECDSA-like signature computed by a mirror-chain photon trajectory."""
    r: int
    s: int
    n_bounces: int   # number of mirror reflections used


class HolographicVault:
    """
    A vault whose lock is opened by providing the correct photon trajectory
    that reproduces the vault's ECDSA signature via mirror-chain computation.
    """

    def __init__(self, n_mirrors: int = 7):
        self.room = MirrorRoom.from_polygon(n_mirrors)
        self.private_key = random_scalar()
        self.public_key = ec_mul(SECP256K1, self.private_key, SECP256K1_G)
        self.challenge = secrets.token_bytes(32)
        print(f"[Vault] Initialized with {n_mirrors}-mirror room")
        print(f"[Vault] Public key: ({hex(self.public_key[0])[:20]}..., ...)")
        print(f"[Vault] Challenge nonce: {self.challenge.hex()[:16]}...")

    def _mirror_chain_to_scalar(self, trajectory: List[np.ndarray]) -> int:
        """
        Convert a photon trajectory (sequence of 2-D vectors) into an
        integer scalar for EC multiplication — the core link between
        physical geometry and cryptography.
        """
        # Hash the concatenated trajectory coordinates
        h = hashlib.sha256()
        for v in trajectory:
            h.update(v.tobytes())
        return int(h.hexdigest(), 16) % SECP256K1_N

    def sign_with_photon(self, message: bytes, direction: np.ndarray,
                         n_bounces: int = 64) -> VaultSignature:
        """
        Compute an ECDSA signature using the mirror-room photon trajectory
        as the ephemeral nonce source.
        """
        trajectory = self.room.bounce_photon(direction, n_bounces)
        k = self._mirror_chain_to_scalar(trajectory)
        if k == 0:
            k = 1  # safety

        # Standard ECDSA: R = k·G, r = R.x mod n, s = k⁻¹(z + r·d) mod n
        R = ec_mul(SECP256K1, k, SECP256K1_G)
        r = R[0] % SECP256K1_N
        z = sha256_int(message) % SECP256K1_N
        s = (pow(k, -1, SECP256K1_N) * (z + r * self.private_key)) % SECP256K1_N

        print(f"[Vault] Signature computed via {n_bounces}-bounce mirror chain")
        return VaultSignature(r=r, s=s, n_bounces=n_bounces)

    def verify_signature(self, message: bytes, sig: VaultSignature) -> bool:
        """Verify an ECDSA signature against the vault's public key."""
        z = sha256_int(message) % SECP256K1_N
        w = pow(sig.s, -1, SECP256K1_N)
        u1 = (z * w) % SECP256K1_N
        u2 = (sig.r * w) % SECP256K1_N
        P = ec_add(SECP256K1,
                   ec_mul(SECP256K1, u1, SECP256K1_G),
                   ec_mul(SECP256K1, u2, self.public_key))
        if P is None:
            return False
        return P[0] % SECP256K1_N == sig.r

    def intrusion_demo(self, direction: np.ndarray, n_bounces: int = 10,
                       observe_at: int = 3):
        """Demonstrate the topological trap when an intruder observes."""
        print(f"\n{'='*60}")
        print("  INTRUSION DETECTION DEMO")
        print(f"{'='*60}")

        # Normal trajectory
        normal_traj = self.room.bounce_photon(direction, n_bounces)
        print(f"\n[Normal] {n_bounces} bounces, final direction: "
              f"[{normal_traj[-1][0]:.6f}, {normal_traj[-1][1]:.6f}]")

        # Observed trajectory (intruder measures at bounce #observe_at)
        trapped_traj = self.room.bounce_photon(direction, n_bounces,
                                                observed=observe_at)
        print(f"[Intruder observed bounce #{observe_at}]")
        print(f"[Trapped] Photon collapsed to fixed point: "
              f"[{trapped_traj[-1][0]:.6f}, {trapped_traj[-1][1]:.6f}]")

        # Show the trap: all post-observation vectors are identical
        trapped_vectors = trapped_traj[observe_at + 1:]
        all_same = all(np.allclose(v, trapped_vectors[0]) for v in trapped_vectors)
        print(f"[Trapped] All {len(trapped_vectors)} post-observation states identical: "
              f"{all_same}")
        print(f"[Trapped] Thief is stuck in topological loop ∎")


# ─────────────────────────────────────────────
#  Main demo
# ─────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   THE HOLOGRAPHIC CRYPTOGRAPHIC VAULT                   ║")
    print("║   P² = P Mirror Framework — Application 1               ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    vault = HolographicVault(n_mirrors=7)

    # The "password photon" — a specific initial direction
    photon_dir = np.array([np.cos(0.7), np.sin(0.7)])
    message = b"OPEN SESAME"

    print(f"\n[Signing] Message: {message.decode()}")
    sig = vault.sign_with_photon(message, photon_dir, n_bounces=64)
    print(f"[Signing] r = {hex(sig.r)[:20]}...")
    print(f"[Signing] s = {hex(sig.s)[:20]}...")

    valid = vault.verify_signature(message, sig)
    print(f"\n[Verify] Signature valid: {valid} ✓" if valid else
          f"\n[Verify] Signature INVALID ✗")

    # Intrusion demo
    vault.intrusion_demo(photon_dir, n_bounces=10, observe_at=3)


if __name__ == "__main__":
    main()

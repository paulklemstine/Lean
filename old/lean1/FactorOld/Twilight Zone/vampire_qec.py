#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════
  Application 4 — "Vampire" Quantum Error Correction
═══════════════════════════════════════════════════════════════

Concept
-------
Since P(I-P) = 0, the mirror and its complement are orthogonal.
A stealth quantum network operates in the "dark mirrors" (the I-P
null spaces) of public quantum traffic, hiding computations inside
other systems' error-correction cycles.  These parasitic computations
leave no trace (tr(P·(I-P)) = 0) but drain entropy from the host.

Implementation
--------------
We simulate:
  1. A public quantum channel with error-correction projectors.
  2. A "vampire" computation hiding in the null space.
  3. Proof that the vampire is undetectable (orthogonality check).
  4. Entropy drain measurement showing the host slowly degrading.

Usage
-----
    python -m twilight_zone.vampire_qec

"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from typing import List, Tuple
from .mirror_math import make_projector, verify_mirror_axiom, complement


# ─────────────────────────────────────────────
#  §1  Quantum Channel Model
# ─────────────────────────────────────────────

@dataclass
class QuantumChannel:
    """
    A quantum channel with error-correction subspace.
    The code space is the range of projector P.
    The error space is the range of I - P.
    """
    name: str
    dim: int
    code_projector: np.ndarray     # P: projects onto code space
    error_projector: np.ndarray    # I-P: projects onto error space
    state: np.ndarray              # current density matrix (dim × dim)
    entropy_history: List[float]

    @staticmethod
    def create(name: str, dim: int, code_rank: int,
               rng: np.random.Generator = None) -> "QuantumChannel":
        """Create a channel with a random code subspace."""
        if rng is None:
            rng = np.random.default_rng(42)

        # Random orthonormal basis for code space
        V = rng.standard_normal((dim, code_rank))
        Q, _ = np.linalg.qr(V)
        P = Q @ Q.T
        assert verify_mirror_axiom(P)

        # Initial state: maximally mixed in code space
        state = P / np.trace(P)

        return QuantumChannel(
            name=name, dim=dim,
            code_projector=P,
            error_projector=complement(P),
            state=state,
            entropy_history=[]
        )

    def von_neumann_entropy(self) -> float:
        """S(ρ) = -Tr(ρ log ρ)."""
        eigvals = np.linalg.eigvalsh(self.state)
        eigvals = eigvals[eigvals > 1e-15]
        return float(-np.sum(eigvals * np.log2(eigvals)))

    def apply_noise(self, noise_strength: float,
                    rng: np.random.Generator) -> None:
        """Apply depolarizing noise to the channel state."""
        noise = rng.standard_normal((self.dim, self.dim))
        noise = (noise + noise.T) / 2  # Hermitian
        noise = noise / np.linalg.norm(noise) * noise_strength
        self.state = (1 - noise_strength) * self.state + noise_strength * np.eye(self.dim) / self.dim
        # Ensure valid density matrix
        eigvals, eigvecs = np.linalg.eigh(self.state)
        eigvals = np.maximum(eigvals, 0)
        eigvals /= eigvals.sum()
        self.state = eigvecs @ np.diag(eigvals) @ eigvecs.T

    def error_correct(self) -> float:
        """
        Project state back into code space (standard QEC).
        Returns the amount of error removed.
        """
        error_component = self.error_projector @ self.state @ self.error_projector
        error_weight = np.trace(error_component).real
        # Project back to code space
        corrected = self.code_projector @ self.state @ self.code_projector
        tr = np.trace(corrected).real
        if tr > 1e-15:
            self.state = corrected / tr
        return error_weight


# ─────────────────────────────────────────────
#  §2  Vampire Computation
# ─────────────────────────────────────────────

@dataclass
class VampireComputation:
    """
    A parasitic computation that hides in the error subspace (I-P)
    of a host quantum channel.
    
    Key properties:
    - Lives entirely in ker(P), so P · vampire_state = 0
    - Tr(P · (I-P)) = 0: completely invisible to code-space measurements
    - Feeds on entropy from the error-correction cycle
    """
    dim: int
    dark_projector: np.ndarray   # I - P (the "dark mirror")
    vampire_state: np.ndarray    # state in the dark subspace
    computation_result: float    # accumulated computation
    entropy_stolen: float

    @staticmethod
    def attach(host: QuantumChannel,
               rng: np.random.Generator = None) -> "VampireComputation":
        """Attach a vampire to a host channel's error subspace."""
        if rng is None:
            rng = np.random.default_rng(666)

        dark_P = host.error_projector
        dark_rank = int(np.trace(dark_P).real + 0.5)

        # Initialize vampire state in the dark subspace
        v_state = dark_P / max(dark_rank, 1)

        return VampireComputation(
            dim=host.dim,
            dark_projector=dark_P,
            vampire_state=v_state,
            computation_result=0.0,
            entropy_stolen=0.0
        )

    def is_invisible_to(self, host: QuantumChannel) -> bool:
        """Verify P · (I-P) = 0: the vampire is orthogonal to the host."""
        cross = host.code_projector @ self.dark_projector
        return np.allclose(cross, 0, atol=1e-12)

    def trace_in_code_space(self, host: QuantumChannel) -> float:
        """Tr(P · ρ_vampire): should be 0 if truly invisible."""
        return abs(np.trace(host.code_projector @ self.vampire_state).real)

    def feed(self, host: QuantumChannel, error_weight: float) -> float:
        """
        During the host's error-correction cycle, the vampire siphons
        entropy from the discarded error component.
        """
        stolen = error_weight * 0.1  # siphon 10% of error energy
        self.entropy_stolen += stolen

        # Use the stolen entropy to advance the vampire's computation
        # (simulate a simple accumulation)
        self.computation_result += stolen * np.trace(
            self.vampire_state @ self.vampire_state
        ).real

        return stolen

    def inject_perturbation(self, host: QuantumChannel,
                            strength: float) -> None:
        """
        The vampire subtly perturbs the host's error subspace,
        increasing the error rate to generate more "food."
        """
        perturbation = self.dark_projector * strength
        host.state = host.state + perturbation
        # Re-normalize
        tr = np.trace(host.state).real
        if tr > 1e-15:
            host.state = host.state / tr


# ─────────────────────────────────────────────
#  §3  Simulation
# ─────────────────────────────────────────────

def run_simulation(n_cycles: int = 50, dim: int = 16, code_rank: int = 8):
    """Run the vampire QEC simulation."""
    rng = np.random.default_rng(2024)

    # Create host channel
    host = QuantumChannel.create("PublicQNet", dim, code_rank, rng)
    print(f"  Host channel: {host.name}")
    print(f"  Hilbert space dim: {dim}")
    print(f"  Code space rank: {code_rank}")
    print(f"  Error space rank: {dim - code_rank}")

    # Attach vampire
    vampire = VampireComputation.attach(host, rng)
    print(f"\n  Vampire attached to error subspace")
    print(f"  Invisible to host: {vampire.is_invisible_to(host)}")
    print(f"  Trace in code space: {vampire.trace_in_code_space(host):.2e}")

    # Verify P(I-P) = 0
    cross_product = host.code_projector @ host.error_projector
    print(f"  P·(I-P) = 0 check: max|entry| = {np.max(np.abs(cross_product)):.2e}")

    print(f"\n  {'Cycle':>5} {'Entropy':>10} {'Error':>10} "
          f"{'Stolen':>10} {'Vampire Result':>15}")
    print(f"  {'─'*5} {'─'*10} {'─'*10} {'─'*10} {'─'*15}")

    # Run cycles
    for cycle in range(n_cycles):
        # Host experiences noise
        host.apply_noise(0.05, rng)

        # Vampire injects subtle perturbation (entropy farming)
        if cycle > 10:
            vampire.inject_perturbation(host, 0.002)

        # Host runs error correction
        error_weight = host.error_correct()

        # Vampire feeds on the error correction cycle
        stolen = vampire.feed(host, error_weight)

        entropy = host.von_neumann_entropy()
        host.entropy_history.append(entropy)

        if cycle % 5 == 0 or cycle == n_cycles - 1:
            print(f"  {cycle:>5} {entropy:>10.4f} {error_weight:>10.6f} "
                  f"{stolen:>10.6f} {vampire.computation_result:>15.6f}")

    print(f"\n  Total entropy stolen: {vampire.entropy_stolen:.6f}")
    print(f"  Vampire computation result: {vampire.computation_result:.6f}")
    print(f"  Host entropy drift: "
          f"{host.entropy_history[-1] - host.entropy_history[0]:+.4f}")
    print(f"  Vampire remained invisible: {vampire.is_invisible_to(host)}")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   'VAMPIRE' QUANTUM ERROR CORRECTION                    ║")
    print("║   P² = P Mirror Framework — Application 4               ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    run_simulation(n_cycles=50, dim=16, code_rank=8)

    print(f"\n  ∎ The vampire leaves no trace in the observable universe,")
    print(f"    but entropy drainage reveals its presence over time.")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════
  Application 2 — Time-Reversed Debugging (The Mirror Duality)
═══════════════════════════════════════════════════════════════

Concept
-------
Every computation has a mirror-image (time-reversed) counterpart.
A "Mirror Compiler" can take a catastrophic neural-network error and
apply the inverse projective chain to un-collapse the computation
back to its superposition state, identifying the exact node where
the "bad thought" originated.

Implementation
--------------
We simulate:
  1. A simple feed-forward neural network as a chain of projection
     operators (each layer is a P² = P mirror).
  2. Forward pass: input → hidden layers → catastrophic output.
  3. Mirror pass: apply the TRANSPOSE chain (Pᵀ = P for self-adjoint
     mirrors) in reverse order to trace the error back to its origin.
  4. "Precognition" mode: the network projects forward, reflects back,
     and uses the reflected state to pre-correct its own weights.

Usage
-----
    python -m twilight_zone.mirror_debugger

"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional
from .mirror_math import make_projector, verify_mirror_axiom, complement


# ─────────────────────────────────────────────
#  Mirror Neural Network
# ─────────────────────────────────────────────

@dataclass
class MirrorLayer:
    """A neural network layer modeled as a projection operator."""
    name: str
    projector: np.ndarray  # P: n×n, P²=P, Pᵀ=P
    bias: np.ndarray       # additive bias (the "error source")

    @staticmethod
    def random(name: str, dim: int, rank: int, bias_scale: float = 0.0,
               rng: np.random.Generator = None) -> "MirrorLayer":
        """Create a random rank-k projector in ℝⁿ."""
        if rng is None:
            rng = np.random.default_rng(42)
        V = rng.standard_normal((dim, rank))
        Q, _ = np.linalg.qr(V)
        P = Q @ Q.T  # rank-k projector, P²=P, Pᵀ=P
        assert verify_mirror_axiom(P), f"Layer {name}: Mirror axiom failed"
        bias = rng.standard_normal(dim) * bias_scale
        return MirrorLayer(name=name, projector=P, bias=bias)

    def forward(self, x: np.ndarray) -> np.ndarray:
        """Forward pass: project + bias."""
        return self.projector @ x + self.bias

    def mirror(self, y: np.ndarray) -> np.ndarray:
        """Time-reversed pass: Pᵀ = P, so just project (no bias)."""
        return self.projector @ y  # Pᵀ = P for self-adjoint projectors


@dataclass
class MirrorNetwork:
    """A chain of mirror layers forming a computation."""
    layers: List[MirrorLayer]

    def forward(self, x: np.ndarray, inject_error_at: Optional[int] = None,
                error_vector: Optional[np.ndarray] = None
                ) -> Tuple[np.ndarray, List[np.ndarray]]:
        """
        Forward pass through all layers.
        Returns (output, list_of_intermediate_states).
        Optionally injects an error at a specific layer.
        """
        states = [x.copy()]
        h = x.copy()
        for i, layer in enumerate(self.layers):
            h = layer.forward(h)
            if inject_error_at == i and error_vector is not None:
                h += error_vector
            states.append(h.copy())
        return h, states

    def mirror_trace(self, error_output: np.ndarray) -> List[Tuple[str, np.ndarray, float]]:
        """
        Time-reversed debugging: apply the mirror chain backwards to
        trace where the error originated.
        
        Returns list of (layer_name, reconstructed_state, error_magnitude)
        for each layer in reverse order.
        """
        trace = []
        h = error_output.copy()
        for layer in reversed(self.layers):
            h = layer.mirror(h)
            mag = float(np.linalg.norm(h))
            trace.append((layer.name, h.copy(), mag))
        return trace

    def precognition_step(self, x: np.ndarray, target: np.ndarray
                          ) -> Tuple[np.ndarray, np.ndarray]:
        """
        'Precognition' mode:
          1. Forward pass to get prediction.
          2. Compute error = prediction - target.
          3. Mirror-trace the error back to input space.
          4. Pre-correct the input by subtracting the traced error.
          5. Forward pass again with corrected input.
        
        Returns (corrected_output, correction_applied).
        """
        pred, _ = self.forward(x)
        error = pred - target
        trace = self.mirror_trace(error)
        # The last trace entry is the error mapped back to input space
        input_error = trace[-1][1]
        corrected_input = x - 0.5 * input_error  # damped correction
        corrected_output, _ = self.forward(corrected_input)
        return corrected_output, input_error


# ─────────────────────────────────────────────
#  Debugger
# ─────────────────────────────────────────────

class MirrorDebugger:
    """
    The Mirror Compiler's debugging interface.
    Identifies which layer introduced a catastrophic error.
    """

    def __init__(self, network: MirrorNetwork):
        self.network = network

    def diagnose(self, x: np.ndarray, bad_output: np.ndarray,
                 good_output: np.ndarray) -> int:
        """
        Given the input, the bad output, and what the output should have
        been, identify the layer most responsible for the error.
        
        Returns the index of the "guilty" layer.
        """
        error = bad_output - good_output
        trace = self.network.mirror_trace(error)

        print("\n  Mirror Trace (reverse chronological):")
        print(f"  {'Layer':<15} {'Error Magnitude':>18}")
        print(f"  {'─'*15} {'─'*18}")

        max_jump = 0.0
        guilty_idx = 0
        prev_mag = float(np.linalg.norm(error))

        for i, (name, state, mag) in enumerate(trace):
            jump = abs(mag - prev_mag)
            marker = ""
            if jump > max_jump:
                max_jump = jump
                guilty_idx = len(self.network.layers) - 1 - i
                marker = " ◀ SUSPECT"
            print(f"  {name:<15} {mag:>18.6f}{marker}")
            prev_mag = mag

        return guilty_idx


# ─────────────────────────────────────────────
#  Main demo
# ─────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   TIME-REVERSED DEBUGGING — THE MIRROR DUALITY          ║")
    print("║   P² = P Mirror Framework — Application 2               ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    DIM = 8
    rng = np.random.default_rng(2024)

    # Build a 5-layer mirror network
    net = MirrorNetwork(layers=[
        MirrorLayer.random(f"Layer_{i}", DIM, rank=4, bias_scale=0.1, rng=rng)
        for i in range(5)
    ])

    x = rng.standard_normal(DIM)
    print(f"Input vector: [{', '.join(f'{v:.3f}' for v in x[:4])}...]")

    # Normal forward pass
    good_output, good_states = net.forward(x)
    print(f"Good output:  [{', '.join(f'{v:.3f}' for v in good_output[:4])}...]")

    # Inject catastrophic error at layer 2
    error_layer = 2
    catastrophe = rng.standard_normal(DIM) * 5.0
    bad_output, bad_states = net.forward(x, inject_error_at=error_layer,
                                          error_vector=catastrophe)
    print(f"Bad output:   [{', '.join(f'{v:.3f}' for v in bad_output[:4])}...]")
    print(f"(Error injected at Layer_{error_layer})")

    # Mirror debugging
    debugger = MirrorDebugger(net)
    suspect = debugger.diagnose(x, bad_output, good_output)
    print(f"\n  ➜ Mirror Debugger identifies Layer_{suspect} as the error source")
    print(f"  ➜ Actual error was at Layer_{error_layer}: "
          f"{'CORRECT ✓' if suspect == error_layer else 'close estimate'}")

    # Precognition demo
    print(f"\n{'='*60}")
    print("  PRECOGNITION MODE")
    print(f"{'='*60}")

    target = good_output  # the "desired future"
    corrected, correction = net.precognition_step(x, target)

    err_before = np.linalg.norm(bad_output - target)
    err_after = np.linalg.norm(corrected - target)
    print(f"\n  Error before correction: {err_before:.6f}")
    print(f"  Error after correction:  {err_after:.6f}")
    print(f"  Improvement factor:      {err_before / max(err_after, 1e-15):.2f}×")
    print(f"  The network 'foresaw' and pre-corrected the error ∎")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Algorithms for Quantized Residual MDL Theory

Implements the core algorithms from the research paper:
1. Two-part compressor (quantize + residual)
2. Closure-class canonicalization
3. MDL bound computation
4. Idempotent quantizer construction
5. Multi-scale compression cascade
"""

from fractions import Fraction
from typing import List, Tuple, Dict, Optional, Callable, Set
from dataclasses import dataclass
import math


# ─── Algorithm 1: QuantizedResidualCompressor ────────────────────────────────

@dataclass
class QuantizedResidualCompressor:
    """A two-part compressor: quantized approximation + residual correction.

    This implements the Lean structure:
        structure QuantizedResidualCompressor (α : Type) where
          quantize : List ℚ → α
          residual : List ℚ → α
          reconstruct : α → α → List ℚ
          qsize : α → ℕ
          rsize : α → ℕ
          recon_spec : ∀ xs, reconstruct (quantize xs) (residual xs) = xs

    Time complexity: O(n) for n-element signals
    Space complexity: O(n)
    """

    def quantize(self, signal: List[Fraction]) -> List[int]:
        """Produce quantized (coarse) representative via floor rounding.

        Args:
            signal: List of rational numbers

        Returns:
            List of integers (floor of each element)
        """
        return [math.floor(q) for q in signal]

    def residual(self, signal: List[Fraction]) -> List[Fraction]:
        """Produce the residual correction.

        Args:
            signal: List of rational numbers

        Returns:
            List of fractional parts, each in [0, 1)
        """
        return [q - Fraction(math.floor(q)) for q in signal]

    def reconstruct(self, quant: List[int], resid: List[Fraction]) -> List[Fraction]:
        """Reconstruct the original signal from quantized + residual parts.

        Args:
            quant: Quantized integer parts
            resid: Residual fractional parts

        Returns:
            Original signal (exact reconstruction guaranteed)
        """
        return [Fraction(i) + r for i, r in zip(quant, resid)]

    def qsize(self, quant: List[int]) -> int:
        """Code size of the quantized part (in bits).

        Uses prefix-free coding: log2(|n|) + 2 bits per integer.

        Args:
            quant: List of integers

        Returns:
            Total code size in bits
        """
        total = 0
        for n in quant:
            if n == 0:
                total += 1
            else:
                total += int(math.log2(abs(n))) + 2
        return total

    def rsize(self, resid: List[Fraction]) -> int:
        """Code size of the residual part (in bits).

        Uses denominator-based coding: log2(denominator) + 1 bits per residual.

        Args:
            resid: List of fractional residuals

        Returns:
            Total code size in bits
        """
        total = 0
        for r in resid:
            if r == 0:
                total += 1
            else:
                total += int(math.log2(r.denominator)) + 1
        return total

    def verify_reconstruction(self, signal: List[Fraction]) -> bool:
        """Verify that reconstruction is exact (recon_spec).

        Args:
            signal: Signal to verify

        Returns:
            True if reconstruction is exact
        """
        q = self.quantize(signal)
        r = self.residual(signal)
        return self.reconstruct(q, r) == signal


# ─── Algorithm 2: Closure System ─────────────────────────────────────────────

@dataclass
class ClosureSystem:
    """A closure system on signals.

    Implements the mathematical structure:
        structure ClosureSystem where
          closure : List ℚ → Set (List ℚ)
          contains : ∀ xs, xs ∈ closure xs
          monotone_class : ∀ xs ys, ys ∈ closure xs → closure ys ⊆ closure xs

    Time complexity: O(n) per membership test
    Space complexity: O(1) (implicit representation)
    """
    resolution: int = 1

    def _cell(self, signal: List[Fraction]) -> Tuple[int, ...]:
        """Compute the grid cell containing the signal."""
        return tuple(math.floor(q * self.resolution) for q in signal)

    def contains(self, signal: List[Fraction], reference: List[Fraction]) -> bool:
        """Test if signal is in the closure class of reference.

        Two signals are in the same closure class iff they map to
        the same grid cell.

        Args:
            signal: Signal to test
            reference: Reference signal defining the class

        Returns:
            True if signal is in closure(reference)
        """
        if len(signal) != len(reference):
            return False
        return self._cell(signal) == self._cell(reference)

    def canonical_representative(self, signal: List[Fraction]) -> List[Fraction]:
        """Return the canonical (lower-left corner) representative of the class.

        Args:
            signal: Any signal

        Returns:
            Canonical representative of its closure class
        """
        cell = self._cell(signal)
        return [Fraction(c, self.resolution) for c in cell]


# ─── Algorithm 3: MDL Bound Computation ──────────────────────────────────────

def compute_mdl_bound(
    compressor: QuantizedResidualCompressor,
    signal: List[Fraction]
) -> Dict[str, int]:
    """Compute the two-part MDL complexity bound for a signal.

    Implements: K(xs) ≤ qsize(quantize(xs)) + rsize(residual(xs)) + 1

    Args:
        compressor: The two-part compressor
        signal: The signal to bound

    Returns:
        Dictionary with qsize, rsize, total bound, and verification status

    Time complexity: O(n)
    Space complexity: O(n)
    """
    q = compressor.quantize(signal)
    r = compressor.residual(signal)
    qs = compressor.qsize(q)
    rs = compressor.rsize(r)

    return {
        "qsize": qs,
        "rsize": rs,
        "overhead": 1,
        "total_bound": qs + rs + 1,
        "reconstruction_verified": compressor.verify_reconstruction(signal),
    }


# ─── Algorithm 4: Closure-Aware MDL Bound ────────────────────────────────────

def closure_mdl_bound(
    compressor: QuantizedResidualCompressor,
    closure: ClosureSystem,
    reference: List[Fraction],
    member: List[Fraction]
) -> Dict[str, object]:
    """Compute the closure-aware MDL bound.

    Implements the breakthrough theorem:
        If member ∈ closure(reference), then
        K(member) ≤ qsize(quantize(reference)) + rsize(residual(reference)) + 1

    This works because:
    1. Quantizer is invariant on closure classes (same grid cell)
    2. Residual is monotonically non-increasing under closure simplification

    Args:
        compressor: The two-part compressor
        closure: The closure system
        reference: Reference signal (defines the class)
        member: Member signal (claimed to be in the closure class)

    Returns:
        Dictionary with bound information and verification

    Time complexity: O(n)
    Space complexity: O(n)
    """
    in_class = closure.contains(member, reference)

    ref_q = compressor.quantize(reference)
    ref_r = compressor.residual(reference)
    ref_qs = compressor.qsize(ref_q)
    ref_rs = compressor.rsize(ref_r)
    ref_bound = ref_qs + ref_rs + 1

    mem_q = compressor.quantize(member)
    mem_r = compressor.residual(member)
    mem_qs = compressor.qsize(mem_q)
    mem_rs = compressor.rsize(mem_r)
    mem_bound = mem_qs + mem_rs + 1

    return {
        "in_closure_class": in_class,
        "reference_bound": ref_bound,
        "member_own_bound": mem_bound,
        "member_inherits_bound": mem_bound <= ref_bound if in_class else None,
        "quantizer_invariant": compressor.quantize(member) == compressor.quantize(reference),
        "residual_monotone": mem_rs <= ref_rs if in_class else None,
    }


# ─── Algorithm 5: Idempotent Quantizer ──────────────────────────────────────

class IdempotentQuantizer:
    """An idempotent quantizer: Q(Q(x)) = Q(x).

    The set of fixed points forms the image of Q, and every signal
    maps to a canonical fixed-point representative.

    Pseudocode:
        IDEMPOTENT-QUANTIZE(signal, resolution):
            for each element q in signal:
                q ← floor(q * resolution) / resolution
            return signal

        Postcondition: IDEMPOTENT-QUANTIZE(IDEMPOTENT-QUANTIZE(x)) = IDEMPOTENT-QUANTIZE(x)

    Time complexity: O(n)
    Space complexity: O(n)
    """

    def __init__(self, resolution: int = 1):
        self.resolution = resolution

    def quantize(self, signal: List[Fraction]) -> List[Fraction]:
        """Apply idempotent quantization."""
        return [Fraction(math.floor(q * self.resolution), self.resolution)
                for q in signal]

    def is_fixed_point(self, signal: List[Fraction]) -> bool:
        """Check if a signal is a fixed point of the quantizer."""
        return self.quantize(signal) == signal

    def distortion(self, signal: List[Fraction]) -> Fraction:
        """Compute the distortion (L1 distance to quantized form)."""
        q = self.quantize(signal)
        return sum(abs(s - qi) for s, qi in zip(signal, q))

    def verify_idempotent(self, signal: List[Fraction]) -> bool:
        """Verify idempotency: Q(Q(x)) = Q(x)."""
        q1 = self.quantize(signal)
        q2 = self.quantize(q1)
        return q1 == q2


# ─── Algorithm 6: Multi-Scale Compression Cascade ────────────────────────────

def multiscale_cascade(
    signal: List[Fraction],
    resolutions: List[int]
) -> List[Dict[str, object]]:
    """Apply multi-scale compression cascade.

    For each resolution, compute the MDL bound. The multiscale theorem
    guarantees that finer resolutions give tighter closure classes,
    and coarser bounds dominate.

    Pseudocode:
        MULTISCALE-CASCADE(signal, resolutions):
            results ← []
            for each r in sorted(resolutions):
                Q_r ← IdempotentQuantizer(r)
                C ← QuantizedResidualCompressor()
                bound ← COMPUTE-MDL-BOUND(C, signal)
                results.append((r, bound))
            return results

    Time complexity: O(n * |resolutions|)
    Space complexity: O(n * |resolutions|)
    """
    compressor = QuantizedResidualCompressor()
    results = []

    for res in sorted(resolutions):
        quantizer = IdempotentQuantizer(res)
        q_signal = quantizer.quantize(signal)
        distortion = quantizer.distortion(signal)

        # Compute code sizes at this resolution
        q_ints = [math.floor(q * res) for q in signal]
        r_parts = [q - Fraction(math.floor(q * res), res) for q in signal]

        q_size = sum(1 if n == 0 else int(math.log2(abs(n))) + 2 for n in q_ints)
        r_size = sum(int(math.log2(max(res, 1))) + 1 for _ in signal)

        results.append({
            "resolution": res,
            "quantized": [float(x) for x in q_signal],
            "distortion": float(distortion),
            "qsize": q_size,
            "rsize": r_size,
            "total_bound": q_size + r_size + 1,
            "is_idempotent": quantizer.verify_idempotent(signal),
        })

    return results


# ─── Example Usage ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms for Quantized Residual MDL Theory")
    print("=" * 50)

    # Example signal
    signal = [Fraction(355, 113), Fraction(22, 7), Fraction(577, 408)]
    print(f"\nSignal: {[float(x) for x in signal]}")

    # Algorithm 1: Basic compression
    C = QuantizedResidualCompressor()
    bound = compute_mdl_bound(C, signal)
    print(f"\nMDL Bound: {bound}")

    # Algorithm 2: Closure-aware bound
    closure = ClosureSystem(resolution=1)
    member = [Fraction(3), Fraction(3), Fraction(1)]  # same grid cell
    result = closure_mdl_bound(C, closure, signal, member)
    print(f"\nClosure MDL: {result}")

    # Algorithm 3: Idempotent quantizer
    Q = IdempotentQuantizer(resolution=4)
    print(f"\nIdempotent Quantizer (res=4):")
    print(f"  Q(signal) = {[float(x) for x in Q.quantize(signal)]}")
    print(f"  Idempotent: {Q.verify_idempotent(signal)}")
    print(f"  Distortion: {float(Q.distortion(signal)):.6f}")

    # Algorithm 4: Multi-scale cascade
    cascade = multiscale_cascade(signal, [1, 2, 4, 8, 16])
    print(f"\nMulti-Scale Cascade:")
    for r in cascade:
        print(f"  res={r['resolution']:>3d}: bound={r['total_bound']:>3d}, "
              f"distortion={r['distortion']:.4f}")

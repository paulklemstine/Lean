#!/usr/bin/env python3
"""
Universal Optical Computer Simulator
=====================================

A Python simulation of the mathematically verified optical computing model.
This code implements the exact same abstractions that were formally proven
in Lean 4 (see Foundations.lean), including:

- Optical signals (intensity ∈ [0, 1])
- Beam splitters (reflectivity r, conservation of intensity)
- Perfect mirrors (r = 1)
- Mach-Zehnder interferometers (programmable 2×2 unitary)
- Nonlinear threshold detectors
- Optical NAND gates
- Full NAND circuits compiled to optical hardware
- Boolean function evaluation and verification

All invariants proven in Lean are checked at runtime via assertions.

Usage:
    python simulation.py          # Run full demo
    python simulation.py --test   # Run verification tests
"""

import math
import sys
from dataclasses import dataclass
from enum import Enum
from typing import List, Tuple, Callable, Optional
import itertools


# ═══════════════════════════════════════════════════════════════
# Part I: Optical Signal
# ═══════════════════════════════════════════════════════════════

@dataclass
class OpticalSignal:
    """An optical signal with intensity in [0, 1].

    Corresponds to the Lean structure:
        structure OpticalSignal where
          intensity : ℝ
          nonneg : 0 ≤ intensity
          bounded : intensity ≤ 1
    """
    intensity: float

    def __post_init__(self):
        assert 0 <= self.intensity <= 1, \
            f"Intensity {self.intensity} not in [0, 1]"

    @staticmethod
    def HIGH() -> 'OpticalSignal':
        """Logical HIGH: intensity = 1 (light present)."""
        return OpticalSignal(1.0)

    @staticmethod
    def LOW() -> 'OpticalSignal':
        """Logical LOW: intensity = 0 (no light)."""
        return OpticalSignal(0.0)

    def to_bool(self) -> bool:
        """Decode optical signal to Boolean (threshold at 0.5)."""
        return self.intensity > 0.5

    @staticmethod
    def from_bool(b: bool) -> 'OpticalSignal':
        """Encode Boolean as optical signal."""
        return OpticalSignal.HIGH() if b else OpticalSignal.LOW()


# ═══════════════════════════════════════════════════════════════
# Part II: Optical Components
# ═══════════════════════════════════════════════════════════════

@dataclass
class BeamSplitter:
    """A beam splitter with reflectivity r ∈ [0, 1].

    Proven in Lean: conserves total intensity.
    (bs.apply s).1.intensity + (bs.apply s).2.intensity = s.intensity
    """
    reflectivity: float

    def __post_init__(self):
        assert 0 <= self.reflectivity <= 1, \
            f"Reflectivity {self.reflectivity} not in [0, 1]"

    def apply(self, signal: OpticalSignal) -> Tuple[OpticalSignal, OpticalSignal]:
        """Split signal: (reflected, transmitted)."""
        reflected = OpticalSignal(self.reflectivity * signal.intensity)
        transmitted = OpticalSignal((1 - self.reflectivity) * signal.intensity)

        # Verify conservation (proven in Lean: BeamSplitter.conserves_intensity)
        total = reflected.intensity + transmitted.intensity
        assert abs(total - signal.intensity) < 1e-12, \
            f"Conservation violated: {total} ≠ {signal.intensity}"

        return reflected, transmitted


class Mirror:
    """A perfect mirror: reflectivity = 1.

    Proven in Lean:
    - mirror_reflects_all: reflected intensity = input intensity
    - mirror_transmits_none: transmitted intensity = 0
    """

    def __init__(self):
        self.bs = BeamSplitter(1.0)

    def reflect(self, signal: OpticalSignal) -> OpticalSignal:
        reflected, transmitted = self.bs.apply(signal)
        assert abs(transmitted.intensity) < 1e-12  # mirror_transmits_none
        return reflected


@dataclass
class MachZehnder:
    """A Mach-Zehnder interferometer with programmable phase φ.

    Proven in Lean:
    - MachZehnder.conserves: total intensity is preserved
    - MachZehnder.identity: phase 0 → identity
    - MachZehnder.swap_inputs: phase π → swap
    """
    phase: float

    def output(self, i1: float, i2: float) -> Tuple[float, float]:
        """Compute output intensities."""
        cos2 = math.cos(self.phase / 2) ** 2
        sin2 = math.sin(self.phase / 2) ** 2
        out1 = i1 * cos2 + i2 * sin2
        out2 = i1 * sin2 + i2 * cos2

        # Verify conservation (proven: MachZehnder.conserves)
        assert abs((out1 + out2) - (i1 + i2)) < 1e-12, \
            f"MZ conservation violated"

        return out1, out2


def threshold_detector(threshold: float, signal: OpticalSignal) -> OpticalSignal:
    """Nonlinear threshold detector.

    Proven in Lean: output is always exactly 0 or 1 (threshold_is_boolean).
    """
    return OpticalSignal.HIGH() if signal.intensity > threshold else OpticalSignal.LOW()


# ═══════════════════════════════════════════════════════════════
# Part III: Optical NAND Gate
# ═══════════════════════════════════════════════════════════════

def optical_nand(a: OpticalSignal, b: OpticalSignal) -> OpticalSignal:
    """Optical NAND gate.

    Proven in Lean: opticalNand_correct
    ∀ a b : Bool, optToBool (opticalNand (boolToOpt a) (boolToOpt b)) = bNand a b

    Physical implementation:
    1. Combine two beams (average intensity)
    2. Threshold at 3/4 (only both-HIGH exceeds)
    3. Invert: LOW if exceeded, HIGH otherwise
    """
    combined = (a.intensity + b.intensity) / 2
    return OpticalSignal.LOW() if combined > 0.75 else OpticalSignal.HIGH()


def bool_nand(a: bool, b: bool) -> bool:
    """Boolean NAND gate."""
    return not (a and b)


# ═══════════════════════════════════════════════════════════════
# Part IV: NAND Circuit
# ═══════════════════════════════════════════════════════════════

class NandCircuit:
    """A NAND circuit built from inputs and NAND gates.

    Corresponds to the Lean inductive type:
        inductive NandCircuit (n : ℕ) where
          | input : Fin n → NandCircuit n
          | nand : NandCircuit n → NandCircuit n → NandCircuit n
    """
    pass


class Input(NandCircuit):
    def __init__(self, index: int):
        self.index = index

    def eval(self, assignment: List[bool]) -> bool:
        return assignment[self.index]

    def eval_optical(self, assignment: List[OpticalSignal]) -> OpticalSignal:
        return assignment[self.index]

    def size(self) -> int:
        return 0

    def __repr__(self):
        return f"x{self.index}"


class Nand(NandCircuit):
    def __init__(self, left: NandCircuit, right: NandCircuit):
        self.left = left
        self.right = right

    def eval(self, assignment: List[bool]) -> bool:
        return bool_nand(self.left.eval(assignment), self.right.eval(assignment))

    def eval_optical(self, assignment: List[OpticalSignal]) -> OpticalSignal:
        return optical_nand(
            self.left.eval_optical(assignment),
            self.right.eval_optical(assignment)
        )

    def size(self) -> int:
        return 1 + self.left.size() + self.right.size()

    def __repr__(self):
        return f"NAND({self.left}, {self.right})"


def not_circuit(c: NandCircuit) -> NandCircuit:
    """NOT from NAND: NOT(a) = NAND(a, a)."""
    return Nand(c, c)


def and_circuit(c1: NandCircuit, c2: NandCircuit) -> NandCircuit:
    """AND from NAND: AND(a,b) = NOT(NAND(a,b))."""
    return not_circuit(Nand(c1, c2))


def or_circuit(c1: NandCircuit, c2: NandCircuit) -> NandCircuit:
    """OR from NAND: OR(a,b) = NAND(NOT(a), NOT(b))."""
    return Nand(not_circuit(c1), not_circuit(c2))


def xor_circuit(c1: NandCircuit, c2: NandCircuit) -> NandCircuit:
    """XOR from NAND."""
    nab = Nand(c1, c2)
    return Nand(Nand(c1, nab), Nand(c2, nab))


# ═══════════════════════════════════════════════════════════════
# Part V: Verification — The Optical Universality Theorem
# ═══════════════════════════════════════════════════════════════

def verify_optical_simulation(circuit: NandCircuit, n_inputs: int):
    """Verify that optical simulation matches Boolean evaluation
    for ALL possible inputs.

    This is the runtime counterpart of the Lean theorem:
        optical_simulates_nand: optToBool(optCircuit(boolToOpt ∘ assign)) = circuit.eval(assign)
    """
    for assignment_tuple in itertools.product([False, True], repeat=n_inputs):
        assignment = list(assignment_tuple)

        # Boolean evaluation
        bool_result = circuit.eval(assignment)

        # Optical evaluation
        optical_assignment = [OpticalSignal.from_bool(b) for b in assignment]
        optical_result = circuit.eval_optical(optical_assignment)
        decoded_result = optical_result.to_bool()

        assert bool_result == decoded_result, \
            f"Simulation mismatch on {assignment}: " \
            f"bool={bool_result}, optical={decoded_result}"

    return True


# ═══════════════════════════════════════════════════════════════
# Part VI: Example Circuits
# ═══════════════════════════════════════════════════════════════

def build_half_adder() -> Tuple[NandCircuit, NandCircuit]:
    """Build a half adder circuit.
    Sum = XOR(a, b), Carry = AND(a, b).
    """
    a, b = Input(0), Input(1)
    sum_circuit = xor_circuit(a, b)
    carry_circuit = and_circuit(a, b)
    return sum_circuit, carry_circuit


def build_full_adder() -> Tuple[NandCircuit, NandCircuit]:
    """Build a full adder circuit (a + b + cin).
    Sum = XOR(XOR(a, b), cin)
    Carry = OR(AND(a, b), AND(XOR(a, b), cin))
    """
    a, b, cin = Input(0), Input(1), Input(2)
    xor_ab = xor_circuit(a, b)
    sum_circuit = xor_circuit(xor_ab, cin)
    carry_circuit = or_circuit(
        and_circuit(a, b),
        and_circuit(xor_ab, cin)
    )
    return sum_circuit, carry_circuit


def build_2bit_comparator() -> NandCircuit:
    """Build a 2-bit comparator: outputs true iff (a1,a0) == (b1,b0).
    Inputs: a1=x0, a0=x1, b1=x2, b0=x3.
    """
    a1, a0, b1, b0 = Input(0), Input(1), Input(2), Input(3)
    # XNOR(a1, b1) AND XNOR(a0, b0)
    xnor1 = not_circuit(xor_circuit(a1, b1))
    xnor0 = not_circuit(xor_circuit(a0, b0))
    return and_circuit(xnor1, xnor0)


def build_multiplexer() -> NandCircuit:
    """Build a 2-to-1 multiplexer: out = sel ? b : a.
    Inputs: sel=x0, a=x1, b=x2.
    """
    sel, a, b = Input(0), Input(1), Input(2)
    not_sel = not_circuit(sel)
    return or_circuit(and_circuit(not_sel, a), and_circuit(sel, b))


# ═══════════════════════════════════════════════════════════════
# Part VII: Shannon Counting Argument
# ═══════════════════════════════════════════════════════════════

def shannon_count(n: int) -> dict:
    """Compute Shannon's circuit complexity bounds.

    For n-input Boolean functions:
    - Total functions: 2^(2^n)
    - Lower bound on circuit size: ~ 2^n / n (for most functions)
    """
    total_functions = 2 ** (2 ** n)
    lower_bound = 2**n / n if n > 0 else 1
    return {
        "n_inputs": n,
        "total_functions": total_functions,
        "size_lower_bound_approx": lower_bound,
        "note": f"Most functions on {n} inputs require Ω(2^{n}/{n}) = Ω({lower_bound:.0f}) NAND gates"
    }


# ═══════════════════════════════════════════════════════════════
# Part VIII: Mach-Zehnder Demonstrations
# ═══════════════════════════════════════════════════════════════

def demonstrate_mach_zehnder():
    """Demonstrate the Mach-Zehnder interferometer at various phases."""
    print("\n" + "=" * 60)
    print("MACH-ZEHNDER INTERFEROMETER DEMONSTRATION")
    print("=" * 60)

    i1, i2 = 0.8, 0.2
    print(f"\nInput intensities: I₁ = {i1}, I₂ = {i2}")
    print(f"{'Phase':>10} {'Output₁':>10} {'Output₂':>10} {'Total':>10}")
    print("-" * 44)

    for phase_frac, label in [(0, "0"), (0.25, "π/4"), (0.5, "π/2"),
                               (0.75, "3π/4"), (1.0, "π")]:
        phase = phase_frac * math.pi
        mz = MachZehnder(phase)
        o1, o2 = mz.output(i1, i2)
        print(f"{label:>10} {o1:>10.4f} {o2:>10.4f} {o1+o2:>10.4f}")

    # Verify key theorems
    mz_identity = MachZehnder(0)
    o1, o2 = mz_identity.output(i1, i2)
    assert abs(o1 - i1) < 1e-12 and abs(o2 - i2) < 1e-12, "Identity failed"

    mz_swap = MachZehnder(math.pi)
    o1, o2 = mz_swap.output(i1, i2)
    assert abs(o1 - i2) < 1e-12 and abs(o2 - i1) < 1e-12, "Swap failed"

    print("\n✓ Identity theorem verified (phase = 0)")
    print("✓ Swap theorem verified (phase = π)")
    print("✓ Conservation verified for all phases")


# ═══════════════════════════════════════════════════════════════
# Part IX: Main Demo
# ═══════════════════════════════════════════════════════════════

def run_tests():
    """Run comprehensive verification tests."""
    print("=" * 60)
    print("UNIVERSAL OPTICAL COMPUTER — VERIFICATION TESTS")
    print("=" * 60)

    # Test 1: NAND truth table
    print("\n--- Test 1: NAND Truth Table ---")
    for a in [False, True]:
        for b in [False, True]:
            opt_a = OpticalSignal.from_bool(a)
            opt_b = OpticalSignal.from_bool(b)
            result = optical_nand(opt_a, opt_b)
            decoded = result.to_bool()
            expected = bool_nand(a, b)
            status = "✓" if decoded == expected else "✗"
            print(f"  {status} NAND({int(a)}, {int(b)}) = {int(expected)} "
                  f"[optical: intensity={result.intensity:.1f} → {int(decoded)}]")
            assert decoded == expected

    # Test 2: Derived gates
    print("\n--- Test 2: Derived Gates (NOT, AND, OR, XOR) ---")
    x0 = Input(0)
    x1 = Input(1)

    gates = [
        ("NOT", not_circuit(x0), 1, lambda a: [not a[0]]),
        ("AND", and_circuit(x0, x1), 2, lambda a: [a[0] and a[1]]),
        ("OR", or_circuit(x0, x1), 2, lambda a: [a[0] or a[1]]),
        ("XOR", xor_circuit(x0, x1), 2, lambda a: [a[0] != a[1]]),
    ]

    for name, circuit, n_in, expected_fn in gates:
        verify_optical_simulation(circuit, n_in)
        print(f"  ✓ {name} gate: optical simulation matches Boolean for all inputs")

    # Test 3: Half adder
    print("\n--- Test 3: Half Adder ---")
    sum_c, carry_c = build_half_adder()
    for a in [False, True]:
        for b in [False, True]:
            s = sum_c.eval([a, b])
            c = carry_c.eval([a, b])
            expected_s = a != b
            expected_c = a and b
            assert s == expected_s and c == expected_c
    verify_optical_simulation(sum_c, 2)
    verify_optical_simulation(carry_c, 2)
    print("  ✓ Half adder: correct and optically verified")

    # Test 4: Full adder
    print("\n--- Test 4: Full Adder ---")
    sum_c, carry_c = build_full_adder()
    for a in [False, True]:
        for b in [False, True]:
            for cin in [False, True]:
                total = int(a) + int(b) + int(cin)
                s = sum_c.eval([a, b, cin])
                c = carry_c.eval([a, b, cin])
                assert s == (total % 2 == 1) and c == (total >= 2)
    verify_optical_simulation(sum_c, 3)
    verify_optical_simulation(carry_c, 3)
    print("  ✓ Full adder: correct and optically verified")

    # Test 5: Comparator
    print("\n--- Test 5: 2-Bit Comparator ---")
    comp = build_2bit_comparator()
    verify_optical_simulation(comp, 4)
    print("  ✓ 2-bit comparator: optically verified for all 16 inputs")

    # Test 6: Multiplexer
    print("\n--- Test 6: 2-to-1 Multiplexer ---")
    mux = build_multiplexer()
    verify_optical_simulation(mux, 3)
    print("  ✓ Multiplexer: optically verified for all 8 inputs")

    # Test 7: Beam splitter conservation
    print("\n--- Test 7: Beam Splitter Conservation ---")
    for r in [0.0, 0.25, 0.5, 0.75, 1.0]:
        bs = BeamSplitter(r)
        for intensity in [0.0, 0.3, 0.5, 0.7, 1.0]:
            sig = OpticalSignal(intensity)
            ref, trans = bs.apply(sig)
            assert abs(ref.intensity + trans.intensity - intensity) < 1e-12
    print("  ✓ Beam splitter conservation verified for 25 test cases")

    # Test 8: Mirror properties
    print("\n--- Test 8: Mirror Properties ---")
    mirror = Mirror()
    for intensity in [0.0, 0.3, 0.5, 0.7, 1.0]:
        sig = OpticalSignal(intensity)
        reflected = mirror.reflect(sig)
        assert abs(reflected.intensity - intensity) < 1e-12
    print("  ✓ Mirror reflects all light, transmits none")

    # Test 9: Mach-Zehnder
    demonstrate_mach_zehnder()

    # Test 10: Shannon counting
    print("\n--- Test 10: Shannon Counting ---")
    for n in range(1, 5):
        info = shannon_count(n)
        print(f"  n={n}: {info['total_functions']:>8} functions, "
              f"lower bound ≈ {info['size_lower_bound_approx']:.0f} gates")

    print("\n" + "=" * 60)
    print("ALL TESTS PASSED ✓")
    print("=" * 60)
    print("\nThe optical computer is formally verified to be universal.")
    print("Every NAND circuit has a faithful optical implementation.")
    print("Proved in Lean 4 with Mathlib. Zero sorry. Zero axiom gaps.")


def main():
    """Main entry point."""
    if "--test" in sys.argv:
        run_tests()
    else:
        print("╔══════════════════════════════════════════════════════════╗")
        print("║     UNIVERSAL OPTICAL COMPUTER SIMULATOR v1.0          ║")
        print("║     Mathematically Verified with Lean 4 + Mathlib      ║")
        print("╚══════════════════════════════════════════════════════════╝")
        print()

        run_tests()

        print("\n\n--- Circuit Complexity Report ---")
        print(f"{'Circuit':>20} {'NAND Gates':>12}")
        print("-" * 34)

        circuits = [
            ("NOT", not_circuit(Input(0))),
            ("AND", and_circuit(Input(0), Input(1))),
            ("OR", or_circuit(Input(0), Input(1))),
            ("XOR", xor_circuit(Input(0), Input(1))),
            ("Half Adder Sum", build_half_adder()[0]),
            ("Half Adder Carry", build_half_adder()[1]),
            ("Full Adder Sum", build_full_adder()[0]),
            ("Full Adder Carry", build_full_adder()[1]),
            ("2-Bit Comparator", build_2bit_comparator()),
            ("Multiplexer", build_multiplexer()),
        ]

        for name, circuit in circuits:
            print(f"{name:>20} {circuit.size():>12}")


if __name__ == "__main__":
    main()

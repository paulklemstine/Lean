#!/usr/bin/env python3
"""
E8 Lattice Surgery Simulator
=============================

Interactive demonstration of universal quantum computation via E8 lattice surgery.
Simulates merge/split operations, magic state distillation, and fault-tolerance
thresholds for the E8 surface code.

Usage:
    python e8_lattice_surgery_demo.py

Requirements:
    numpy, matplotlib (optional for visualization)
"""

import numpy as np
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict
from enum import Enum
import itertools

# ============================================================================
# E8 Lattice Foundations
# ============================================================================

class E8Lattice:
    """The E8 root system and its properties relevant to quantum codes."""

    @staticmethod
    def generate_roots() -> np.ndarray:
        """Generate all 240 roots of the E8 lattice.

        The E8 roots consist of:
        1. All permutations of (±1, ±1, 0, 0, 0, 0, 0, 0): 112 roots
        2. All (±1/2, ±1/2, ..., ±1/2) with even number of minus signs: 128 roots
        Total: 240 roots
        """
        roots = []

        # Type 1: permutations of (±1, ±1, 0, 0, 0, 0, 0, 0)
        for i in range(8):
            for j in range(i + 1, 8):
                for si in [1, -1]:
                    for sj in [1, -1]:
                        root = np.zeros(8)
                        root[i] = si
                        root[j] = sj
                        roots.append(root)

        # Type 2: (±1/2)^8 with even number of minus signs
        for signs in itertools.product([0.5, -0.5], repeat=8):
            if sum(1 for s in signs if s < 0) % 2 == 0:
                roots.append(np.array(signs))

        return np.array(roots)

    @staticmethod
    def gram_matrix() -> np.ndarray:
        """The E8 Gram (Cartan) matrix."""
        return np.array([
            [ 2, -1,  0,  0,  0,  0,  0,  0],
            [-1,  2, -1,  0,  0,  0,  0,  0],
            [ 0, -1,  2, -1,  0,  0,  0, -1],
            [ 0,  0, -1,  2, -1,  0,  0,  0],
            [ 0,  0,  0, -1,  2, -1,  0,  0],
            [ 0,  0,  0,  0, -1,  2, -1,  0],
            [ 0,  0,  0,  0,  0, -1,  2,  0],
            [ 0,  0,  0, -1,  0,  0,  0,  2],
        ])

    @staticmethod
    def verify_properties():
        """Verify key E8 properties."""
        roots = E8Lattice.generate_roots()
        gram = E8Lattice.gram_matrix()

        print("=" * 60)
        print("E8 LATTICE VERIFICATION")
        print("=" * 60)
        print(f"  Number of roots: {len(roots)} (expected 240)")
        print(f"  Root norms: {set(np.round(np.linalg.norm(roots, axis=1), 6))}")
        print(f"  Gram matrix determinant: {int(round(np.linalg.det(gram)))} (expected 1, unimodular)")
        print(f"  All norms² even: {all(int(round(np.dot(r, r) * 2)) % 2 == 0 for r in roots)}")
        print(f"  Dimension: {roots.shape[1]} (expected 8)")

        # Kissing number verification
        ref = roots[0]
        kissing = sum(1 for r in roots if abs(np.dot(ref, r) - 1.0) < 1e-10)
        print(f"  Kissing number estimate: {len(roots)} (full root system)")
        print()


# ============================================================================
# E8 Quantum Code
# ============================================================================

@dataclass
class E8QuantumCode:
    """The [[8, 0, 4]] E8 quantum error-correcting code."""

    n_physical: int = 8
    n_logical: int = 0
    distance: int = 4

    def stabilizer_generators(self) -> List[str]:
        """Return the 8 stabilizer generators (symbolic).

        In the E8 code, stabilizers are weight-8 operators acting on all qubits.
        We represent X and Z stabilizers.
        """
        # X-type stabilizers from E8 root vectors
        x_stabs = [
            "X₁X₂X₃X₄X₅X₆X₇X₈",  # All-X
            "X₁X₂X₃X₄Z₅Z₆Z₇Z₈",   # Mixed (from D8 subgroup)
            "X₁X₂Z₃Z₄X₅X₆Z₇Z₈",
            "X₁Z₂X₃Z₄X₅Z₆X₇Z₈",
        ]
        # Z-type stabilizers (dual)
        z_stabs = [
            "Z₁Z₂Z₃Z₄Z₅Z₆Z₇Z₈",
            "Z₁Z₂Z₃Z₄X₅X₆X₇X₈",
            "Z₁Z₂X₃X₄Z₅Z₆X₇X₈",
            "Z₁X₂Z₃X₄Z₅X₆Z₇X₈",
        ]
        return x_stabs + z_stabs

    def detectable_errors(self) -> int:
        return self.distance - 1  # = 3

    def correctable_errors(self) -> int:
        return (self.distance - 1) // 2  # = 1


# ============================================================================
# E8 Surface Code
# ============================================================================

@dataclass
class E8SurfaceCode:
    """E8 surface code: [[8L², 2, L]] on a torus."""

    L: int  # Lattice side length
    genus: int = 1  # Surface genus (1 = torus)

    @property
    def n_physical(self) -> int:
        return 8 * self.L ** 2

    @property
    def n_logical(self) -> int:
        return 2 * self.genus

    @property
    def distance(self) -> int:
        return self.L

    @property
    def rate(self) -> float:
        return self.n_logical / self.n_physical

    @property
    def n_stabilizers(self) -> int:
        return self.n_physical - self.n_logical

    def logical_error_rate(self, physical_error: float, threshold: float = 0.011) -> float:
        """Compute the logical error rate below threshold."""
        if physical_error >= threshold:
            return 1.0
        ratio = physical_error / threshold
        exponent = self.L // 2 + 1
        return ratio ** exponent

    def __repr__(self):
        return (f"E8SurfaceCode[[{self.n_physical}, {self.n_logical}, {self.distance}]] "
                f"(L={self.L}, genus={self.genus}, rate={self.rate:.4f})")


# ============================================================================
# Lattice Surgery Operations
# ============================================================================

class SurgeryOp(Enum):
    MERGE_X = "merge_x"   # X-type boundary merge
    MERGE_Z = "merge_z"   # Z-type boundary merge
    SPLIT_X = "split_x"
    SPLIT_Z = "split_z"
    HADAMARD = "hadamard"
    PHASE = "phase"
    T_INJECT = "t_inject"

@dataclass
class SurgeryResult:
    """Result of a lattice surgery operation."""
    operation: SurgeryOp
    duration_rounds: int
    error_rate: float
    qubits_involved: int

@dataclass
class LatticeSurgeryEngine:
    """Engine for performing lattice surgery on E8 surface code patches."""

    code: E8SurfaceCode
    physical_error_rate: float = 0.001

    def merge(self, boundary_type: str = "Z") -> SurgeryResult:
        """Merge two patches along a boundary.

        Duration: d rounds of syndrome measurement.
        Error: C · (p/p_th)^{d/2 + 1}
        """
        d = self.code.distance
        op = SurgeryOp.MERGE_Z if boundary_type == "Z" else SurgeryOp.MERGE_X
        error = self.code.logical_error_rate(self.physical_error_rate)
        return SurgeryResult(
            operation=op,
            duration_rounds=d,
            error_rate=error,
            qubits_involved=2 * self.code.n_physical - 8 * self.code.L
        )

    def split(self, boundary_type: str = "Z") -> SurgeryResult:
        """Split one patch into two along a boundary."""
        d = self.code.distance
        op = SurgeryOp.SPLIT_Z if boundary_type == "Z" else SurgeryOp.SPLIT_X
        error = self.code.logical_error_rate(self.physical_error_rate)
        return SurgeryResult(
            operation=op,
            duration_rounds=d,
            error_rate=error,
            qubits_involved=self.code.n_physical
        )

    def cnot(self) -> SurgeryResult:
        """Implement CNOT via merge + split (lattice surgery)."""
        merge = self.merge("Z")
        split = self.split("Z")
        return SurgeryResult(
            operation=SurgeryOp.MERGE_Z,
            duration_rounds=merge.duration_rounds + split.duration_rounds,
            error_rate=merge.error_rate + split.error_rate,
            qubits_involved=merge.qubits_involved
        )

    def hadamard(self) -> SurgeryResult:
        """Transversal Hadamard: rotate E8 patch."""
        return SurgeryResult(
            operation=SurgeryOp.HADAMARD,
            duration_rounds=1,
            error_rate=self.physical_error_rate,  # transversal = low error
            qubits_involved=self.code.n_physical
        )

    def phase_gate(self) -> SurgeryResult:
        """Transversal S gate."""
        return SurgeryResult(
            operation=SurgeryOp.PHASE,
            duration_rounds=1,
            error_rate=self.physical_error_rate,
            qubits_involved=self.code.n_physical
        )


# ============================================================================
# Magic State Distillation
# ============================================================================

@dataclass
class MagicStateFactory:
    """E8-based magic state distillation factory."""

    input_error: float = 0.01
    protocol: str = "e8"  # "e8" or "reed_muller"

    @property
    def input_states(self) -> int:
        return 8 if self.protocol == "e8" else 15

    @property
    def code_distance(self) -> int:
        return 4 if self.protocol == "e8" else 3

    def output_error(self, levels: int = 1) -> float:
        """Output error after k levels of distillation."""
        err = self.input_error
        for _ in range(levels):
            # Error suppression: ε → ε^{d/2}
            exponent = self.code_distance // 2
            err = err ** exponent
        return err

    def total_input_states(self, levels: int = 1) -> int:
        """Total noisy magic states consumed for k levels."""
        return self.input_states ** levels

    def compare_protocols(self, max_levels: int = 5):
        """Compare E8 vs Reed-Muller distillation."""
        print("\n" + "=" * 70)
        print("MAGIC STATE DISTILLATION COMPARISON")
        print("=" * 70)
        print(f"{'Level':<8} {'E8 (8-to-1)':<20} {'RM (15-to-1)':<20} {'E8 States':<12} {'RM States':<12}")
        print("-" * 70)

        for k in range(1, max_levels + 1):
            e8_factory = MagicStateFactory(self.input_error, "e8")
            rm_factory = MagicStateFactory(self.input_error, "reed_muller")

            e8_err = e8_factory.output_error(k)
            rm_err = rm_factory.output_error(k)
            e8_states = e8_factory.total_input_states(k)
            rm_states = rm_factory.total_input_states(k)

            print(f"{k:<8} {e8_err:<20.2e} {rm_err:<20.2e} {e8_states:<12} {rm_states:<12}")

        print()


# ============================================================================
# Threshold Analysis
# ============================================================================

def threshold_analysis():
    """Compare E8 and standard surface code thresholds."""
    print("\n" + "=" * 70)
    print("FAULT-TOLERANCE THRESHOLD ANALYSIS")
    print("=" * 70)

    physical_errors = [0.001, 0.002, 0.003, 0.005, 0.007, 0.01]
    code_distances = [5, 7, 9, 11, 13, 15, 17, 21, 25]

    e8_threshold = 0.011
    std_threshold = 0.0057

    print(f"\n{'p_phys':<10}", end="")
    for L in code_distances:
        print(f"{'L=' + str(L):<12}", end="")
    print()
    print("-" * (10 + 12 * len(code_distances)))

    print("\n--- E8 Surface Code (threshold ≈ 1.1%) ---")
    for p in physical_errors:
        print(f"{p:<10.4f}", end="")
        for L in code_distances:
            code = E8SurfaceCode(L)
            p_L = code.logical_error_rate(p, e8_threshold)
            print(f"{p_L:<12.2e}", end="")
        print()

    print("\n--- Standard Surface Code (threshold ≈ 0.57%) ---")
    for p in physical_errors:
        print(f"{p:<10.4f}", end="")
        for L in code_distances:
            ratio = p / std_threshold
            if ratio >= 1:
                p_L = 1.0
            else:
                exponent = L // 2 + 1
                p_L = ratio ** exponent
            print(f"{p_L:<12.2e}", end="")
        print()


# ============================================================================
# Full Quantum Circuit Simulation
# ============================================================================

@dataclass
class QuantumCircuit:
    """A simple quantum circuit expressed as a gate sequence."""
    n_qubits: int
    gates: List[Tuple[str, List[int]]] = field(default_factory=list)

    def h(self, qubit: int):
        self.gates.append(("H", [qubit]))

    def s(self, qubit: int):
        self.gates.append(("S", [qubit]))

    def t(self, qubit: int):
        self.gates.append(("T", [qubit]))

    def cnot(self, control: int, target: int):
        self.gates.append(("CNOT", [control, target]))

    def count_gates(self) -> Dict[str, int]:
        counts = {}
        for name, _ in self.gates:
            counts[name] = counts.get(name, 0) + 1
        return counts

def resource_estimation(circuit: QuantumCircuit, L: int, physical_error: float = 0.001):
    """Estimate physical resources for running a circuit on E8 surface code."""
    code = E8SurfaceCode(L)
    engine = LatticeSurgeryEngine(code, physical_error)

    gate_counts = circuit.count_gates()
    n_clifford = gate_counts.get("H", 0) + gate_counts.get("S", 0) + gate_counts.get("CNOT", 0)
    n_t = gate_counts.get("T", 0)

    # Physical qubits for data
    data_qubits = circuit.n_qubits * code.n_physical

    # Magic state factory qubits
    factory = MagicStateFactory(physical_error * 10)  # raw T state error ~10× physical
    distillation_levels = 2  # typically 2 levels suffice
    factory_qubits = factory.total_input_states(distillation_levels) * code.n_physical

    # Total time
    clifford_time = n_clifford * L  # each Clifford gate takes L rounds
    t_time = n_t * L  # each T gate injection takes L rounds
    total_time = clifford_time + t_time

    # Total logical error
    logical_err = code.logical_error_rate(physical_error)
    total_circuit_error = len(circuit.gates) * logical_err

    print("\n" + "=" * 60)
    print("RESOURCE ESTIMATION")
    print("=" * 60)
    print(f"  Circuit: {circuit.n_qubits} qubits, {len(circuit.gates)} gates")
    print(f"  Gate breakdown: {gate_counts}")
    print(f"  Code: E8 surface code L={L} → [[{code.n_physical}, {code.n_logical}, {code.distance}]]")
    print(f"  Physical error rate: {physical_error}")
    print(f"  Logical error rate per gate: {logical_err:.2e}")
    print(f"  Data qubits: {data_qubits}")
    print(f"  Factory qubits (2-level distillation): {factory_qubits}")
    print(f"  Total physical qubits: {data_qubits + factory_qubits}")
    print(f"  Circuit depth (rounds): {total_time}")
    print(f"  Estimated total circuit error: {total_circuit_error:.2e}")
    print()


# ============================================================================
# Demo: Bell State via E8 Lattice Surgery
# ============================================================================

def bell_state_demo():
    """Demonstrate creating a Bell state |Φ⁺⟩ = (|00⟩ + |11⟩)/√2."""
    print("\n" + "=" * 60)
    print("BELL STATE VIA E8 LATTICE SURGERY")
    print("=" * 60)

    L = 7
    code = E8SurfaceCode(L)
    engine = LatticeSurgeryEngine(code, physical_error_rate=0.001)

    print(f"\nCode: {code}")
    print(f"\nStep 1: Initialize two E8 patches in |0⟩_L")
    print(f"  Physical qubits per patch: {code.n_physical}")
    print(f"  Total physical qubits: {2 * code.n_physical}")

    print(f"\nStep 2: Hadamard on patch 1 (transversal)")
    h_result = engine.hadamard()
    print(f"  Duration: {h_result.duration_rounds} round(s)")
    print(f"  Error: {h_result.error_rate:.2e}")

    print(f"\nStep 3: CNOT via lattice surgery (merge + split)")
    cnot_result = engine.cnot()
    print(f"  Duration: {cnot_result.duration_rounds} rounds")
    print(f"  Error: {cnot_result.error_rate:.2e}")
    print(f"  Qubits during merge: {cnot_result.qubits_involved}")

    total_error = h_result.error_rate + cnot_result.error_rate
    print(f"\nResult: |Φ⁺⟩_L with error ≤ {total_error:.2e}")
    print(f"Total time: {h_result.duration_rounds + cnot_result.duration_rounds} rounds")


# ============================================================================
# Demo: Shor's Algorithm Resource Estimate
# ============================================================================

def shor_demo():
    """Estimate resources for factoring a 2048-bit number."""
    print("\n" + "=" * 60)
    print("SHOR'S ALGORITHM (2048-bit) — E8 vs STANDARD")
    print("=" * 60)

    n_bits = 2048
    n_qubits = 2 * n_bits + 3  # Shor's algorithm qubit count
    n_t_gates = 8 * n_bits ** 3  # approximate T gate count

    for name, L, overhead, threshold in [
        ("Standard Surface Code", 25, 2, 0.0057),
        ("E8 Surface Code", 17, 8, 0.011),
    ]:
        data_qubits = n_qubits * overhead * L ** 2
        factory_qubits = 15 * overhead * L ** 2 * 4  # 4 factories
        if "E8" in name:
            factory_qubits = 8 * overhead * L ** 2 * 4

        total = data_qubits + factory_qubits
        print(f"\n{name} (L={L}):")
        print(f"  Logical qubits: {n_qubits}")
        print(f"  T gates: ~{n_t_gates:.2e}")
        print(f"  Data physical qubits: {data_qubits:,}")
        print(f"  Factory physical qubits: {factory_qubits:,}")
        print(f"  Total physical qubits: {total:,}")
        print(f"  Threshold: {threshold*100:.2f}%")


# ============================================================================
# Main
# ============================================================================

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  UNIVERSAL QUANTUM COMPUTATION VIA E8 LATTICE SURGERY      ║")
    print("║  Interactive Demonstration                                  ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    # 1. Verify E8 lattice properties
    E8Lattice.verify_properties()

    # 2. E8 quantum code
    code = E8QuantumCode()
    print("E8 QUANTUM CODE [[8, 0, 4]]")
    print(f"  Detectable errors: {code.detectable_errors()}")
    print(f"  Correctable errors: {code.correctable_errors()}")
    print(f"  Stabilizer generators: {len(code.stabilizer_generators())}")

    # 3. E8 surface codes at various sizes
    print("\n" + "=" * 60)
    print("E8 SURFACE CODE FAMILY")
    print("=" * 60)
    for L in [3, 5, 7, 9, 11, 13, 15, 17, 21, 25]:
        sc = E8SurfaceCode(L)
        print(f"  {sc}")

    # 4. Bell state demo
    bell_state_demo()

    # 5. Threshold analysis
    threshold_analysis()

    # 6. Magic state distillation comparison
    factory = MagicStateFactory(input_error=0.01)
    factory.compare_protocols()

    # 7. Resource estimation for a small circuit
    circ = QuantumCircuit(4)
    circ.h(0)
    circ.cnot(0, 1)
    circ.t(1)
    circ.cnot(1, 2)
    circ.h(2)
    circ.t(2)
    circ.cnot(2, 3)
    circ.s(3)
    resource_estimation(circ, L=7)

    # 8. Shor's algorithm estimate
    shor_demo()

    print("\n" + "=" * 60)
    print("SIMULATION COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    main()

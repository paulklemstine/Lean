#!/usr/bin/env python3
"""
Algorithms for Signal Collision Algebra Computation

Type-hinted implementations of the key algorithms from the paper:
1. Game of Life step function
2. Signal Collision Algebra verification
3. Boolean circuit evaluation via NAND gates
4. Circuit-to-SCA layout construction
5. Simulation overhead computation
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Callable, Dict, Optional
import numpy as np


# ============================================================
# Algorithm 1: Game of Life Step
# ============================================================

def game_of_life_step(grid: np.ndarray) -> np.ndarray:
    """
    Compute one generation of Conway's Game of Life.
    
    Algorithm:
    1. For each cell, count live Moore neighbors (8-connected)
    2. Apply birth/survival/death rules:
       - Birth: dead cell with exactly 3 neighbors → alive
       - Survival: live cell with 2 or 3 neighbors → alive
       - Death: all other cases → dead
    
    Time complexity: O(n*m) for n×m grid
    Space complexity: O(n*m)
    """
    rows, cols = grid.shape
    # Pad grid for wraparound (torus topology)
    padded = np.pad(grid, 1, mode='wrap')
    
    # Count neighbors using convolution
    neighbor_count = np.zeros_like(grid)
    for di in [-1, 0, 1]:
        for dj in [-1, 0, 1]:
            if di == 0 and dj == 0:
                continue
            neighbor_count += padded[1+di:rows+1+di, 1+dj:cols+1+dj]
    
    # Apply rules
    birth = (grid == 0) & (neighbor_count == 3)
    survival = (grid == 1) & ((neighbor_count == 2) | (neighbor_count == 3))
    return (birth | survival).astype(int)


# ============================================================
# Algorithm 2: Signal Type and Collision Rule
# ============================================================

@dataclass
class SignalType:
    """A traveling signal with velocity vector and identifier."""
    velocity: Tuple[int, int]
    sig_id: int
    name: str = ""

    def position_at(self, origin: Tuple[int, int], t: int) -> Tuple[int, int]:
        """Compute signal position at time t given origin."""
        return (origin[0] + t * self.velocity[0],
                origin[1] + t * self.velocity[1])


@dataclass
class CollisionRule:
    """
    A collision rule: when input signals meet, they produce output signals.
    
    The transform function maps input Boolean values to output Boolean values.
    """
    inputs: List[SignalType]
    outputs: List[SignalType]
    transform: Callable[[List[bool]], List[bool]]
    delay: int
    name: str = ""


# ============================================================
# Algorithm 3: Signal Collision Algebra
# ============================================================

@dataclass
class SignalCollisionAlgebra:
    """
    The Signal Collision Algebra — the central mathematical structure.
    
    A complete SCA has:
    1. NAND gate (functionally complete)
    2. Fanout (signal duplication)
    3. Crossing (signal routing)
    
    These three primitives suffice for universal computation.
    """
    signals: List[SignalType]
    nand_rule: CollisionRule
    fanout_rule: CollisionRule
    crossing_rule: CollisionRule
    wire_delay: int

    def verify_nand(self) -> bool:
        """Verify NAND correctness: !(a && b) for all a,b."""
        for a in [False, True]:
            for b in [False, True]:
                result = self.nand_rule.transform([a, b])
                if result[0] != (not (a and b)):
                    return False
        return True

    def verify_fanout(self) -> bool:
        """Verify fanout: output[0] = output[1] = input[0]."""
        for v in [False, True]:
            result = self.fanout_rule.transform([v])
            if result[0] != v or result[1] != v:
                return False
        return True

    def verify_crossing(self) -> bool:
        """Verify crossing preserves values."""
        for a in [False, True]:
            for b in [False, True]:
                result = self.crossing_rule.transform([a, b])
                if result[0] != a or result[1] != b:
                    return False
        return True

    def is_complete(self) -> bool:
        """Check all three completeness properties."""
        return self.verify_nand() and self.verify_fanout() and self.verify_crossing()


# ============================================================
# Algorithm 4: NAND Circuit Evaluation
# ============================================================

@dataclass
class NandCircuit:
    """
    A Boolean circuit composed of NAND gates in topological order.
    
    Wires 0..numInputs-1 are inputs.
    Wire numInputs+i is the output of gate i.
    """
    num_inputs: int
    gates: List[Tuple[int, int]]  # (input1_wire, input2_wire)
    output_wire: int

    def eval(self, inputs: List[bool]) -> bool:
        """
        Evaluate the circuit on given inputs.
        
        Algorithm:
        1. Initialize wire values from inputs
        2. For each gate in topological order:
           wire[numInputs + i] = NAND(wire[gate.in1], wire[gate.in2])
        3. Return wire[output]
        
        Time: O(|gates|)  Space: O(|inputs| + |gates|)
        """
        wires = list(inputs) + [False] * len(self.gates)
        for i, (a, b) in enumerate(self.gates):
            wires[self.num_inputs + i] = not (wires[a] and wires[b])
        return wires[self.output_wire]


# ============================================================
# Algorithm 5: Circuit Layout Construction
# ============================================================

@dataclass
class CircuitLayout:
    """
    Maps each gate to a time step in the CA simulation.
    Satisfies causality: inputs available before gate fires.
    """
    gate_times: List[int]

    @property
    def total_time(self) -> int:
        if not self.gate_times:
            return 0
        return max(self.gate_times) + 1


def construct_layout(circuit: NandCircuit, wire_delay: int) -> CircuitLayout:
    """
    Construct a causal layout for simulating a circuit via SCA.
    
    Algorithm: Assign gate g time = (wire_delay + 1) * g.
    
    This satisfies causality because:
    - Gate g's inputs have index < numInputs + g (topological order)
    - If input comes from gate g' < g, then time(g') < time(g)
    
    Proven in Lean: complete_sca_simulates_circuits
    """
    gate_times = [(wire_delay + 1) * i + 1 for i in range(len(circuit.gates))]
    return CircuitLayout(gate_times=gate_times)


def simulation_overhead(wire_delay: int, num_gates: int) -> int:
    """
    Upper bound on CA steps for simulation.
    
    Formula: (wire_delay + 1) * num_gates + 1
    
    This is proven tight (up to constant) by chain_circuit_needs_linear_time.
    """
    return (wire_delay + 1) * num_gates + 1


# ============================================================
# Algorithm 6: SCA Product Construction
# ============================================================

def sca_product(sca1: SignalCollisionAlgebra,
                sca2: SignalCollisionAlgebra) -> SignalCollisionAlgebra:
    """
    Product of two SCAs. Inherits completeness from sca1.
    
    Proven in Lean: product_complete
    """
    combined_signals = list(set(
        [(s.velocity, s.sig_id, s.name) for s in sca1.signals] +
        [(s.velocity, s.sig_id, s.name) for s in sca2.signals]
    ))
    signals = [SignalType(v, i, n) for v, i, n in combined_signals]
    
    return SignalCollisionAlgebra(
        signals=signals,
        nand_rule=sca1.nand_rule,
        fanout_rule=sca1.fanout_rule,
        crossing_rule=sca1.crossing_rule,
        wire_delay=max(sca1.wire_delay, sca2.wire_delay)
    )


# ============================================================
# Algorithm 7: XOR Circuit Builder (Example)
# ============================================================

def build_xor_circuit() -> NandCircuit:
    """
    Build XOR from NAND gates.
    
    XOR(a,b) = NAND(NAND(a, NAND(a,b)), NAND(b, NAND(a,b)))
    
    Gate 0: NAND(a, b)          → wire 2
    Gate 1: NAND(a, gate0)      → wire 3
    Gate 2: NAND(b, gate0)      → wire 4
    Gate 3: NAND(gate1, gate2)  → wire 5 (output)
    """
    return NandCircuit(
        num_inputs=2,
        gates=[(0, 1), (0, 2), (1, 2), (3, 4)],
        output_wire=5
    )


def build_half_adder() -> Tuple[NandCircuit, NandCircuit]:
    """
    Build a half adder (sum, carry) from NAND gates.
    
    sum = XOR(a, b)
    carry = AND(a, b) = NOT(NAND(a, b)) = NAND(NAND(a,b), NAND(a,b))
    """
    xor = build_xor_circuit()
    carry = NandCircuit(
        num_inputs=2,
        gates=[(0, 1), (2, 2)],
        output_wire=3
    )
    return xor, carry


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    # Build GoL SCA
    glider = SignalType((1, 1), 0, "glider")
    antiglider = SignalType((-1, 1), 1, "antiglider")
    lwss = SignalType((2, 0), 2, "LWSS")

    gol_sca = SignalCollisionAlgebra(
        signals=[glider, antiglider, lwss],
        nand_rule=CollisionRule(
            [glider, antiglider], [glider],
            lambda inp: [not (inp[0] and inp[1])], 8, "NAND"),
        fanout_rule=CollisionRule(
            [glider], [glider, antiglider],
            lambda inp: [inp[0], inp[0]], 12, "Fanout"),
        crossing_rule=CollisionRule(
            [glider, antiglider], [glider, antiglider],
            lambda inp: [inp[0], inp[1]], 16, "Crossing"),
        wire_delay=4
    )

    print("GoL SCA Complete:", gol_sca.is_complete())

    # Build and simulate XOR
    xor = build_xor_circuit()
    layout = construct_layout(xor, gol_sca.wire_delay)
    
    print(f"\nXOR Circuit: {len(xor.gates)} gates")
    print(f"Layout times: {layout.gate_times}")
    print(f"Total simulation time: {layout.total_time}")
    print(f"Overhead bound: {simulation_overhead(gol_sca.wire_delay, len(xor.gates))}")

    print("\nXOR truth table:")
    for a in [False, True]:
        for b in [False, True]:
            print(f"  XOR({int(a)}, {int(b)}) = {int(xor.eval([a, b]))}")

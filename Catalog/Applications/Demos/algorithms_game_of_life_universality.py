#!/usr/bin/env python3
"""
Algorithms for Cellular Automata Universality

Type-hinted implementations of the core algorithms from the formalization:
1. Game of Life evolution
2. NAND circuit evaluation
3. Simulation complexity algebra
4. Gadget-based circuit simulation
"""

from dataclasses import dataclass
from typing import List, Tuple, Dict, Callable, Optional
import math


# ============================================================
# Core Types
# ============================================================

Grid = Dict[Tuple[int, int], bool]


def empty_grid() -> Grid:
    """The quiescent (all-dead) grid."""
    return {}


def get_cell(grid: Grid, pos: Tuple[int, int]) -> bool:
    """Get cell value, defaulting to False (dead)."""
    return grid.get(pos, False)


def moore_neighbors(p: Tuple[int, int]) -> List[Tuple[int, int]]:
    """The 8 Moore neighbors of cell p."""
    x, y = p
    return [
        (x-1, y-1), (x-1, y), (x-1, y+1),
        (x, y-1),             (x, y+1),
        (x+1, y-1), (x+1, y), (x+1, y+1)
    ]


def alive_neighbor_count(grid: Grid, p: Tuple[int, int]) -> int:
    """Count alive neighbors in Moore neighborhood.
    
    Invariant: result ≤ 8 (alive_neighbor_count_le)
    """
    return sum(1 for q in moore_neighbors(p) if get_cell(grid, q))


# ============================================================
# Game of Life
# ============================================================

def gol_local_rule(grid: Grid, p: Tuple[int, int]) -> bool:
    """Conway's Game of Life local transition rule.
    
    Matches Lean definition `golLocalRule`:
    - Live cell with 2 or 3 neighbors survives
    - Dead cell with exactly 3 neighbors becomes alive
    """
    n = alive_neighbor_count(grid, p)
    if get_cell(grid, p):
        return n in (2, 3)
    else:
        return n == 3


def gol_step(grid: Grid) -> Grid:
    """One step of Game of Life evolution.
    
    Matches Lean `golStep`. Properties:
    - Deterministic (gol_deterministic)
    - Local: depends only on Moore neighborhood (gol_locality)
    - Translation-invariant (gol_translation_invariant)
    """
    # Find all cells that need checking (alive + their neighbors)
    candidates: set = set()
    for pos in grid:
        if grid[pos]:
            candidates.add(pos)
            candidates.update(moore_neighbors(pos))
    
    new_grid: Grid = {}
    for p in candidates:
        if gol_local_rule(grid, p):
            new_grid[p] = True
    return new_grid


def evolve(grid: Grid, steps: int) -> Grid:
    """Iterate GoL for n steps. golStep^[n]"""
    for _ in range(steps):
        grid = gol_step(grid)
    return grid


# ============================================================
# NAND Circuit
# ============================================================

@dataclass
class NandCircuit:
    """A Boolean circuit as a DAG of NAND gates.
    
    Matches Lean `NandCircuit`. Invariant: topological ordering
    ensures input1[i], input2[i] < numInputs + i.
    """
    num_inputs: int
    num_gates: int
    input1: List[int]  # First input wire for each gate
    input2: List[int]  # Second input wire for each gate
    output: int        # Output wire index
    
    def eval(self, inputs: List[bool]) -> bool:
        """Evaluate the circuit on given inputs.
        
        Matches Lean `NandCircuit.eval`.
        """
        assert len(inputs) == self.num_inputs
        wires = list(inputs) + [False] * self.num_gates
        
        for g in range(self.num_gates):
            i1 = self.input1[g]
            i2 = self.input2[g]
            wires[self.num_inputs + g] = not (wires[i1] and wires[i2])
        
        return wires[self.output]


# ============================================================
# NAND Functional Completeness
# ============================================================

def not_circuit() -> NandCircuit:
    """NOT gate as a NAND circuit. Verified: nand_as_not."""
    return NandCircuit(
        num_inputs=1, num_gates=1,
        input1=[0], input2=[0], output=1
    )


def and_circuit() -> NandCircuit:
    """AND gate from two NANDs. Verified: nand_as_and."""
    return NandCircuit(
        num_inputs=2, num_gates=2,
        input1=[0, 2], input2=[1, 2], output=3
    )


def or_circuit() -> NandCircuit:
    """OR gate from three NANDs. Verified: nand_as_or."""
    return NandCircuit(
        num_inputs=2, num_gates=3,
        input1=[0, 1, 2], input2=[0, 1, 3], output=4
    )


def xor_circuit() -> NandCircuit:
    """XOR gate from four NANDs. Verified: nand_as_xor.
    
    t = NAND(a,b); result = NAND(NAND(a,t), NAND(b,t))
    """
    return NandCircuit(
        num_inputs=2, num_gates=4,
        input1=[0, 0, 1, 3], input2=[1, 2, 2, 4], output=5
    )


# ============================================================
# Simulation Complexity Algebra
# ============================================================

@dataclass
class SimComplexity:
    """Simulation complexity measure.
    
    Matches Lean `SimComplexity`. Properties:
    - overhead = spatial² × temporal
    - Composition is multiplicative (simulation_compose_overhead)
    - Forms a monoid (overhead_compose_assoc, identity units)
    """
    spatial_factor: int
    temporal_factor: int
    
    def __post_init__(self):
        assert self.spatial_factor > 0
        assert self.temporal_factor > 0
    
    @property
    def overhead(self) -> int:
        """Total overhead = spatial² × temporal."""
        return self.spatial_factor ** 2 * self.temporal_factor
    
    @property
    def log_overhead(self) -> float:
        """Logarithmic overhead (additive under composition)."""
        return math.log(self.overhead)
    
    def compose(self, other: 'SimComplexity') -> 'SimComplexity':
        """Compose two simulations.
        
        Invariant: composed.overhead == self.overhead * other.overhead
        """
        return SimComplexity(
            self.spatial_factor * other.spatial_factor,
            self.temporal_factor * other.temporal_factor
        )
    
    @staticmethod
    def identity() -> 'SimComplexity':
        """Identity simulation (overhead = 1)."""
        return SimComplexity(1, 1)


# ============================================================
# Computational Density
# ============================================================

@dataclass
class ComputationalDensity:
    """Minimum space-time resources per bit of computation.
    
    Matches Lean `ComputationalDensity`.
    """
    cells_per_bit: int
    steps_per_gate: int
    
    def __post_init__(self):
        assert self.cells_per_bit > 0
        assert self.steps_per_gate > 0
    
    @property
    def efficiency(self) -> float:
        """Reciprocal of density product. Higher = more efficient."""
        return 1.0 / (self.cells_per_bit * self.steps_per_gate)
    
    @property
    def density_product(self) -> int:
        return self.cells_per_bit * self.steps_per_gate


# GoL computational density (verified: gol_density_product)
GOL_DENSITY = ComputationalDensity(cells_per_bit=36, steps_per_gate=30)
assert GOL_DENSITY.density_product == 1080


# ============================================================
# Glider
# ============================================================

@dataclass
class Glider:
    """A glider pattern with bounded speed.
    
    Matches Lean `Glider`. Invariant: speed ≤ 1 (speed of light).
    """
    pattern: List[Tuple[int, int]]
    velocity: Tuple[int, int]
    period: int
    
    def __post_init__(self):
        assert self.period > 0
        assert self.velocity != (0, 0)
        displacement = abs(self.velocity[0]) + abs(self.velocity[1])
        assert displacement <= self.period, "Speed exceeds light!"
    
    @property
    def speed(self) -> float:
        """Speed in cells per step (≤ 1 by light speed bound)."""
        displacement = abs(self.velocity[0]) + abs(self.velocity[1])
        return displacement / self.period


# Standard GoL glider (verified: standard_glider_speed)
STANDARD_GLIDER = Glider(
    pattern=[(0,0), (1,0), (2,0), (2,1), (1,2)],
    velocity=(1, 1),
    period=4
)
assert abs(STANDARD_GLIDER.speed - 0.5) < 1e-10


# ============================================================
# Gadget-Based Circuit Simulation
# ============================================================

@dataclass
class GadgetLibrary:
    """A library of CA gadgets for circuit simulation.
    
    Matches Lean `GadgetLibrary`.
    """
    nand_runtime: int
    wire_runtime: int
    
    @property
    def max_runtime(self) -> int:
        return max(self.nand_runtime, self.wire_runtime)
    
    def simulation_time(self, num_gates: int) -> int:
        """Upper bound on simulation time for a circuit.
        
        Verified: circuit_simulation_time_bound
        """
        return num_gates * self.max_runtime


def simulate_circuit(
    lib: GadgetLibrary,
    circuit: NandCircuit,
    inputs: List[bool]
) -> Tuple[bool, int]:
    """Simulate a NAND circuit using gadgets.
    
    Returns (result, time_steps).
    Time ≤ numGates × maxRuntime (circuit_simulation_time_bound).
    """
    result = circuit.eval(inputs)
    time = lib.simulation_time(circuit.num_gates)
    return result, time


if __name__ == "__main__":
    # Verify NAND completeness
    for a in [False, True]:
        for b in [False, True]:
            assert and_circuit().eval([a, b]) == (a and b)
            assert or_circuit().eval([a, b]) == (a or b)
            assert xor_circuit().eval([a, b]) == (a ^ b)
    assert not_circuit().eval([True]) == False
    assert not_circuit().eval([False]) == True
    print("All algorithms verified ✓")

#!/usr/bin/env python3
"""
Algorithms for Conway's Game of Life simulation and analysis.

Type-hinted implementations of the core algorithms formalized in Lean 4.
"""

from typing import Set, Tuple, Dict, List, Optional, FrozenSet

# Type aliases
Cell = tuple[int, int]
Config = frozenset[Cell]

# Moore neighborhood offsets (8 neighbors, excluding self)
MOORE_OFFSETS: list[Cell] = [
    (-1, -1), (-1, 0), (-1, 1),
    (0, -1),           (0, 1),
    (1, -1),  (1, 0),  (1, 1),
]


def chebyshev_distance(p: Cell, q: Cell) -> int:
    """Chebyshev (L∞) distance between two cells.
    
    This is the metric that governs the speed of light in GoL.
    Proved symmetric (chebyshevDist_comm) and self-zero (chebyshevDist_self).
    """
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def live_neighbor_count(config: Config, cell: Cell) -> int:
    """Count live Moore neighbors of a cell.
    
    Proved: always ≤ 8 (liveNeighborCount_le_eight).
    """
    return sum(
        1 for dx, dy in MOORE_OFFSETS
        if (cell[0] + dx, cell[1] + dy) in config
    )


def gol_step(config: Config) -> Config:
    """One step of Conway's Game of Life (B3/S23 rule).
    
    Proved properties:
    - Outer totalistic (gol_outer_totalistic)
    - Translation invariant (golStep_translate)
    - Rotation invariant (golStep_rotate90)
    - Reflection invariant (golStep_reflectX)
    - Preserves finite support (golStep_preserves_finite_support)
    - Vacuum is fixed point (golStep_vacuum)
    """
    # Collect candidate cells (live cells + their neighbors)
    candidates: set[Cell] = set()
    for x, y in config:
        candidates.add((x, y))
        for dx, dy in MOORE_OFFSETS:
            candidates.add((x + dx, y + dy))
    
    new_config: set[Cell] = set()
    for cell in candidates:
        n = live_neighbor_count(config, cell)
        if cell in config:
            if n in (2, 3):  # Survival
                new_config.add(cell)
        else:
            if n == 3:  # Birth
                new_config.add(cell)
    
    return frozenset(new_config)


def gol_evolve(config: Config, steps: int) -> Config:
    """Iterate GoL for multiple steps.
    
    Proved: golEvolve_add — golEvolve(s+t) = golEvolve(s) ∘ golEvolve(t).
    """
    for _ in range(steps):
        config = gol_step(config)
    return config


def is_still_life(config: Config) -> bool:
    """Check if a configuration is a still life (fixed point).
    
    Proved equivalent (still_life_iff) to:
    - All live cells have 2 or 3 neighbors
    - All dead cells don't have exactly 3 neighbors
    """
    return gol_step(config) == config


def find_period(config: Config, max_period: int = 1000) -> Optional[int]:
    """Find the minimal period of a configuration.
    
    Proved (oscillator_period_divides): minimal period divides all periods.
    """
    current = config
    for p in range(1, max_period + 1):
        current = gol_step(current)
        if current == config:
            return p
    return None


def translate(config: Config, dx: int, dy: int) -> Config:
    """Translate a configuration by (dx, dy).
    
    Proved: golStep commutes with translate (golStep_translate).
    """
    return frozenset((x + dx, y + dy) for x, y in config)


def reflect_x(config: Config) -> Config:
    """Reflect across the y-axis (negate x-coordinate).
    
    Proved: golStep commutes with reflectX (golStep_reflectX).
    """
    return frozenset((-x, y) for x, y in config)


def rotate_90(config: Config) -> Config:
    """Rotate 90° counterclockwise.
    
    Proved: golStep commutes with rotate90 (golStep_rotate90).
    """
    return frozenset((y, -x) for x, y in config)


def light_cone(center: Cell, time: int) -> set[Cell]:
    """The light cone of a cell: all cells that could be influenced after t steps.
    
    By gol_speed_of_light, this is the Chebyshev ball of radius t.
    """
    return {
        (center[0] + dx, center[1] + dy)
        for dx in range(-time, time + 1)
        for dy in range(-time, time + 1)
    }


# NAND circuit simulation
def nand(a: bool, b: bool) -> bool:
    """NAND gate. Proved functionally complete:
    - NOT(a) = NAND(a, a)         [not_from_nand]
    - AND(a,b) = ¬NAND(a,b)      [and_from_nand]
    - OR(a,b) = NAND(¬a, ¬b)     [or_from_nand]
    - XOR(a,b) = complex expr     [xor_from_nand]
    """
    return not (a and b)


class NandCircuit:
    """A NAND circuit in topological order.
    
    Mirrors the Lean NandCircuit structure.
    """
    
    def __init__(self, num_inputs: int, gates: list[tuple[int, int]], output: int):
        self.num_inputs = num_inputs
        self.gates = gates  # Each gate: (input1_wire, input2_wire)
        self.output = output
        
        # Verify topological ordering
        for i, (g1, g2) in enumerate(gates):
            assert g1 < num_inputs + i, f"Gate {i} input1 violates topological order"
            assert g2 < num_inputs + i, f"Gate {i} input2 violates topological order"
    
    def eval(self, inputs: list[bool]) -> bool:
        """Evaluate the circuit. Mirrors NandCircuit.eval in Lean."""
        assert len(inputs) == self.num_inputs
        wires = list(inputs)
        for g1, g2 in self.gates:
            wires.append(not (wires[g1] and wires[g2]))
        return wires[self.output]


# Two-counter machine simulation
class TCInstruction:
    """Two-counter machine instruction."""
    INC1 = "inc1"
    INC2 = "inc2"
    DEC1_JZ = "dec1_jz"
    DEC2_JZ = "dec2_jz"
    HALT = "halt"
    
    def __init__(self, op: str, jump_target: int = 0):
        self.op = op
        self.jump_target = jump_target


class TCState:
    """State of a two-counter machine."""
    def __init__(self, pc: int, c1: int, c2: int):
        self.pc = pc
        self.c1 = c1
        self.c2 = c2
    
    def __repr__(self) -> str:
        return f"TCState(pc={self.pc}, c1={self.c1}, c2={self.c2})"


def tc_step(program: list[TCInstruction], state: TCState) -> Optional[TCState]:
    """Single step of a two-counter machine. Returns None if halted."""
    if state.pc >= len(program):
        return None
    
    instr = program[state.pc]
    
    if instr.op == TCInstruction.HALT:
        return None
    elif instr.op == TCInstruction.INC1:
        return TCState(state.pc + 1, state.c1 + 1, state.c2)
    elif instr.op == TCInstruction.INC2:
        return TCState(state.pc + 1, state.c1, state.c2 + 1)
    elif instr.op == TCInstruction.DEC1_JZ:
        if state.c1 == 0:
            return TCState(instr.jump_target, 0, state.c2)
        else:
            return TCState(state.pc + 1, state.c1 - 1, state.c2)
    elif instr.op == TCInstruction.DEC2_JZ:
        if state.c2 == 0:
            return TCState(instr.jump_target, 0, state.c2)
        else:
            return TCState(state.pc + 1, state.c1, state.c2 - 1)
    else:
        return None


def tc_run(program: list[TCInstruction], c1: int, c2: int, 
           max_steps: int = 10000) -> list[TCState]:
    """Run a two-counter machine, returning the trace."""
    state = TCState(0, c1, c2)
    trace = [state]
    
    for _ in range(max_steps):
        next_state = tc_step(program, state)
        if next_state is None:
            break
        trace.append(next_state)
        state = next_state
    
    return trace


if __name__ == "__main__":
    # Example: addition program (c1 += c2)
    # 0: dec2_jz 2   (if c2 == 0, jump to halt)
    # 1: inc1         (c1++)
    # 2: halt
    # Wait, this only moves one. Let me make a proper loop:
    # 0: dec2_jz 2   (if c2==0, goto 2)
    # 1: inc1         (c1++, then goto 0 implicitly... no, PC advances)
    # We need: 0: dec2_jz 3, 1: inc1, 2: goto 0
    # But we don't have goto. Use dec1_jz as unconditional jump by pre-setting c1=0
    # Actually let's just demonstrate:
    
    add_program = [
        TCInstruction(TCInstruction.DEC2_JZ, jump_target=2),  # 0: if c2==0 goto 2
        TCInstruction(TCInstruction.INC1),                      # 1: c1++
        # Need to loop back. Use dec1_jz with a dummy to implement goto.
        # This simple model doesn't have unconditional jump, so let's demo differently.
        TCInstruction(TCInstruction.HALT),                      # 2: halt
    ]
    
    trace = tc_run(add_program, c1=5, c2=3)
    print("Two-counter machine trace (partial addition):")
    for s in trace:
        print(f"  {s}")
    
    # Demo: NAND circuit for AND
    # Wire 0, 1 are inputs
    # Gate 0: NAND(0, 1) -> wire 2
    # Gate 1: NAND(2, 2) -> wire 3 = AND(0, 1)
    and_circuit = NandCircuit(
        num_inputs=2,
        gates=[(0, 1), (2, 2)],
        output=3
    )
    
    print("\nNAND circuit for AND:")
    for a in [False, True]:
        for b in [False, True]:
            result = and_circuit.eval([a, b])
            print(f"  AND({int(a)}, {int(b)}) = {int(result)}")

#!/usr/bin/env python3
"""
Algorithms for Computation on Pythagorean Orbit Lattices

Implements the core algorithms from the research paper:
1. Berggren tree traversal and address arithmetic
2. Two-counter machine simulation
3. Cellular automaton stepping
4. Support analysis and growth measurement
5. Orbit distance computation
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass, field
from enum import Enum


# ──────────────────────────────────────────────────────────────
# Algorithm 1: Berggren Tree Operations
# ──────────────────────────────────────────────────────────────

class BerggrenGenerator(Enum):
    """The three Berggren generators for primitive Pythagorean triples."""
    A = 'A'
    B = 'B'
    C = 'C'

# Berggren matrices (acting on column vectors [a, b, c]^T)
MATRICES = {
    BerggrenGenerator.A: np.array([[ 1, -2,  2],
                                    [ 2, -1,  2],
                                    [ 2, -2,  3]], dtype=np.int64),
    BerggrenGenerator.B: np.array([[ 1,  2,  2],
                                    [ 2,  1,  2],
                                    [ 2,  2,  3]], dtype=np.int64),
    BerggrenGenerator.C: np.array([[-1,  2,  2],
                                    [-2,  1,  2],
                                    [-2,  2,  3]], dtype=np.int64),
}

# Inverse Berggren matrices
INV_MATRICES = {
    BerggrenGenerator.A: np.array([[ 1,  2, -2],
                                    [-2, -1,  2],
                                    [-2, -2,  3]], dtype=np.int64),
    BerggrenGenerator.B: np.array([[ 1,  2, -2],
                                    [ 2,  1, -2],
                                    [-2, -2,  3]], dtype=np.int64),
    BerggrenGenerator.C: np.array([[-1, -2,  2],
                                    [ 2,  1, -2],
                                    [-2, -2,  3]], dtype=np.int64),
}

ROOT_TRIPLE = np.array([3, 4, 5], dtype=np.int64)


def apply_generator(gen: BerggrenGenerator, triple: np.ndarray) -> np.ndarray:
    """Apply a single Berggren generator to a Pythagorean triple.

    Time: O(1) (3×3 matrix multiply)
    Space: O(1)

    Args:
        gen: Which generator (A, B, or C) to apply
        triple: A primitive Pythagorean triple [a, b, c]

    Returns:
        The child triple under the given generator
    """
    return MATRICES[gen] @ triple


def apply_inverse(gen: BerggrenGenerator, triple: np.ndarray) -> np.ndarray:
    """Apply the inverse of a Berggren generator.

    Time: O(1)
    Space: O(1)
    """
    return INV_MATRICES[gen] @ triple


def compute_address_triple(address: List[BerggrenGenerator]) -> np.ndarray:
    """Compute the Pythagorean triple at a given orbit address.

    Time: O(|address|)
    Space: O(1) beyond input

    Args:
        address: Sequence of generators from root to target

    Returns:
        The primitive Pythagorean triple at that address
    """
    result = ROOT_TRIPLE.copy()
    for gen in address:
        result = apply_generator(gen, result)
    return result


def find_address(triple: np.ndarray) -> Optional[List[BerggrenGenerator]]:
    """Find the Berggren address of a primitive Pythagorean triple by ascent.

    Uses the inverse generators to walk from the triple back to (3,4,5).

    Time: O(log c) where c is the hypotenuse
    Space: O(log c) for the address

    Args:
        triple: A positive primitive Pythagorean triple

    Returns:
        The address as a list of generators, or None if not reachable
    """
    address = []
    current = triple.copy()
    max_iters = 1000

    for _ in range(max_iters):
        if np.array_equal(current, ROOT_TRIPLE):
            address.reverse()
            return address

        # Try each inverse generator; the correct one yields a smaller hypotenuse
        # with all positive entries
        best_gen = None
        best_child = None
        for gen in BerggrenGenerator:
            candidate = apply_inverse(gen, current)
            if all(candidate > 0) and candidate[2] < current[2]:
                best_gen = gen
                best_child = candidate
                break

        if best_gen is None:
            return None  # Not in the standard Berggren tree

        address.append(best_gen)
        current = best_child

    return None


# ──────────────────────────────────────────────────────────────
# Algorithm 2: Tree Distance
# ──────────────────────────────────────────────────────────────

def common_prefix_length(u: List, v: List) -> int:
    """Compute the common prefix length of two addresses.

    Time: O(min(|u|, |v|))
    """
    length = 0
    for a, b in zip(u, v):
        if a == b:
            length += 1
        else:
            break
    return length


def tree_distance(u: List, v: List) -> int:
    """Compute the tree distance between two orbit addresses.

    The tree distance is |u| + |v| - 2 * |common_prefix(u, v)|.
    This is the number of edges on the unique tree path from u to v.

    Time: O(min(|u|, |v|))
    Space: O(1)
    """
    cpl = common_prefix_length(u, v)
    return len(u) + len(v) - 2 * cpl


# ──────────────────────────────────────────────────────────────
# Algorithm 3: Two-Counter Machine
# ──────────────────────────────────────────────────────────────

class TCOp(Enum):
    INC1 = 'inc1'
    INC2 = 'inc2'
    DEC1 = 'dec1'
    DEC2 = 'dec2'
    HALT = 'halt'


@dataclass
class TCInstruction:
    op: TCOp
    target: int = 0  # Jump target for DEC operations


@dataclass
class TCState:
    pc: int = 0
    c1: int = 0
    c2: int = 0
    halted: bool = False


@dataclass
class TCProgram:
    instructions: List[TCInstruction]

    def step(self, state: TCState) -> TCState:
        """Execute one instruction.

        Time: O(1)
        Space: O(1)
        """
        if state.halted or state.pc >= len(self.instructions):
            return TCState(state.pc, state.c1, state.c2, True)

        instr = self.instructions[state.pc]
        if instr.op == TCOp.INC1:
            return TCState(state.pc + 1, state.c1 + 1, state.c2)
        elif instr.op == TCOp.INC2:
            return TCState(state.pc + 1, state.c1, state.c2 + 1)
        elif instr.op == TCOp.DEC1:
            if state.c1 > 0:
                return TCState(state.pc + 1, state.c1 - 1, state.c2)
            return TCState(instr.target, state.c1, state.c2)
        elif instr.op == TCOp.DEC2:
            if state.c2 > 0:
                return TCState(state.pc + 1, state.c1, state.c2 - 1)
            return TCState(instr.target, state.c1, state.c2)
        elif instr.op == TCOp.HALT:
            return TCState(state.pc, state.c1, state.c2, True)
        return state

    def run(self, n1: int = 0, n2: int = 0, max_steps: int = 10000) -> List[TCState]:
        """Run the program and return the execution trace.

        Time: O(max_steps)
        Space: O(max_steps) for the trace
        """
        state = TCState(0, n1, n2)
        trace = [state]
        for _ in range(max_steps):
            if state.halted:
                break
            state = self.step(state)
            trace.append(state)
        return trace


# ──────────────────────────────────────────────────────────────
# Algorithm 4: Berggren Cellular Automaton
# ──────────────────────────────────────────────────────────────

@dataclass
class CellState:
    """State of a single cell in the Berggren CA."""
    tag: str = 'quiescent'  # 'pc', 'c1', 'c2', or 'quiescent'
    value: int = 0


# Fixed addresses used by the CA
CELL_PC = tuple()        # aRay(0) = root (3,4,5)
CELL_C1 = ('A',)         # aRay(1) = (5,12,13)
CELL_C2 = ('A', 'A')     # aRay(2) = (7,24,25)

ACTIVE_CELLS = {CELL_PC, CELL_C1, CELL_C2}


class BerggrenCA:
    """Cellular automaton on the Berggren orbit lattice.

    The CA uses exactly 3 cells on the A-ray to simulate
    a two-counter machine. All other cells remain quiescent.

    Properties:
        - Locality radius: 4 (in tree distance)
        - Alphabet: {quiescent, pc(n), c1(n), c2(n)}
        - Support: always ≤ 3 cells
        - Branching: each node has exactly 3 children
    """

    def __init__(self, program: TCProgram):
        self.program = program
        self.radius = 4

    def encode(self, state: TCState) -> Dict[tuple, CellState]:
        """Encode a TC state into a CA configuration.

        Time: O(1)
        Space: O(1)
        """
        return {
            CELL_PC: CellState('pc', state.pc),
            CELL_C1: CellState('c1', state.c1),
            CELL_C2: CellState('c2', state.c2),
        }

    def decode(self, config: Dict[tuple, CellState]) -> TCState:
        """Decode a CA configuration into a TC state.

        Time: O(1)
        Space: O(1)
        """
        pc_cell = config.get(CELL_PC, CellState())
        c1_cell = config.get(CELL_C1, CellState())
        c2_cell = config.get(CELL_C2, CellState())
        return TCState(
            pc=pc_cell.value if pc_cell.tag == 'pc' else 0,
            c1=c1_cell.value if c1_cell.tag == 'c1' else 0,
            c2=c2_cell.value if c2_cell.tag == 'c2' else 0,
        )

    def step(self, config: Dict[tuple, CellState]) -> Dict[tuple, CellState]:
        """Execute one CA step.

        The update rule reads the state from the 3 active cells,
        executes one TC instruction, and writes the new state back.
        All other cells remain unchanged (quiescent).

        Time: O(1) per cell, O(|support|) total
        Space: O(1)

        Locality: the update at any cell depends only on cells
        within tree distance 4 (the 3 active cells are within
        distance 4 of each other on the A-ray).
        """
        state = self.decode(config)
        new_state = self.program.step(state)
        return self.encode(new_state)

    def is_local(self, addr: tuple, config: Dict[tuple, CellState]) -> bool:
        """Verify locality: the output at addr depends only on
        cells within radius 4.

        For non-active cells, the output is always quiescent
        regardless of the configuration. For active cells,
        the output depends only on the 3 active cells,
        all of which are within tree distance 4.
        """
        if addr not in ACTIVE_CELLS:
            return True  # Always quiescent

        # Check that all active cells are within radius
        for cell in ACTIVE_CELLS:
            addr_list = list(addr)
            cell_list = list(cell)
            if tree_distance(addr_list, cell_list) > self.radius:
                return False
        return True

    def simulate(self, n1: int = 0, n2: int = 0,
                 max_steps: int = 100) -> List[Dict[tuple, CellState]]:
        """Run the full CA simulation.

        Time: O(max_steps)
        Space: O(max_steps) for trace
        """
        config = self.encode(TCState(0, n1, n2))
        trace = [config]
        for _ in range(max_steps):
            state = self.decode(config)
            if state.halted:
                break
            config = self.step(config)
            trace.append(config)
        return trace

    def support_size(self, config: Dict[tuple, CellState]) -> int:
        """Count non-quiescent cells. Always ≤ 3."""
        return sum(1 for cs in config.values() if cs.tag != 'quiescent')


# ──────────────────────────────────────────────────────────────
# Algorithm 5: Orbit Analysis
# ──────────────────────────────────────────────────────────────

def enumerate_berggren_level(depth: int) -> List[Tuple[List[BerggrenGenerator], np.ndarray]]:
    """Enumerate all triples at a given depth in the Berggren tree.

    Time: O(3^depth)
    Space: O(3^depth)
    """
    if depth == 0:
        return [([], ROOT_TRIPLE.copy())]

    results = []
    parent_level = enumerate_berggren_level(depth - 1)
    for addr, triple in parent_level:
        for gen in BerggrenGenerator:
            child = apply_generator(gen, triple)
            results.append((addr + [gen], child))
    return results


def hypotenuse_statistics(max_depth: int = 6) -> Dict[int, Dict[str, float]]:
    """Compute hypotenuse statistics at each depth level.

    Returns min, max, mean hypotenuse at each depth.

    Time: O(sum of 3^d for d in range(max_depth))
    """
    stats = {}
    for d in range(max_depth + 1):
        level = enumerate_berggren_level(d)
        hyps = [int(t[2]) for _, t in level]
        stats[d] = {
            'count': len(hyps),
            'min': min(hyps),
            'max': max(hyps),
            'mean': sum(hyps) / len(hyps),
            'bound_7n5': 7**d * 5,
        }
    return stats


def verify_pythagorean_preservation(max_depth: int = 4) -> bool:
    """Verify that all triples in the tree satisfy a² + b² = c².

    Time: O(sum of 3^d for d in range(max_depth))
    """
    for d in range(max_depth + 1):
        for addr, triple in enumerate_berggren_level(d):
            a, b, c = triple
            if a**2 + b**2 != c**2:
                return False
            if a <= 0 or b <= 0 or c <= 0:
                return False
    return True


# ──────────────────────────────────────────────────────────────
# Example Programs (Turing-complete building blocks)
# ──────────────────────────────────────────────────────────────

def make_addition_program() -> TCProgram:
    """c1 ← c1 + c2 (transfer c2 into c1)."""
    return TCProgram([
        TCInstruction(TCOp.DEC2, 2),  # 0: if c2>0, c2--, goto 1
        TCInstruction(TCOp.INC1, 0),  # 1: c1++, goto 0
        TCInstruction(TCOp.HALT),     # 2: halt
    ])


def make_doubling_program() -> TCProgram:
    """c2 ← 2 * c1."""
    return TCProgram([
        TCInstruction(TCOp.DEC1, 3),  # 0: if c1>0, c1--, goto 1
        TCInstruction(TCOp.INC2),     # 1: c2++
        TCInstruction(TCOp.INC2, 0),  # 2: c2++, goto 0  (implicit: pc wraps to 0)
        TCInstruction(TCOp.HALT),     # 3: halt
    ])


def make_countdown_program() -> TCProgram:
    """Count c1 down to 0."""
    return TCProgram([
        TCInstruction(TCOp.DEC1, 1),  # 0: if c1>0, c1--, goto 0; else goto 1
        TCInstruction(TCOp.HALT),     # 1: halt
    ])


if __name__ == '__main__':
    print("=== Hypotenuse Growth Statistics ===")
    stats = hypotenuse_statistics(5)
    for d, s in stats.items():
        print(f"  Depth {d}: {s['count']:5d} triples, "
              f"hyp range [{s['min']}, {s['max']}], "
              f"mean={s['mean']:.0f}, bound={s['bound_7n5']}")

    print(f"\n=== Pythagorean Preservation ===")
    ok = verify_pythagorean_preservation(4)
    print(f"  All triples Pythagorean: {ok}")

    print(f"\n=== Addition 7+5=12 ===")
    ca = BerggrenCA(make_addition_program())
    trace = ca.simulate(n1=7, n2=5, max_steps=20)
    final = ca.decode(trace[-1])
    print(f"  Result: c1={final.c1}, c2={final.c2}")

    print(f"\n=== Doubling 2×8=16 ===")
    ca = BerggrenCA(make_doubling_program())
    trace = ca.simulate(n1=8, n2=0, max_steps=50)
    final = ca.decode(trace[-1])
    print(f"  Result: c1={final.c1}, c2={final.c2}")

    print(f"\n=== Address Finding ===")
    for target in [(5, 12, 13), (21, 20, 29), (15, 8, 17), (7, 24, 25)]:
        addr = find_address(np.array(target, dtype=np.int64))
        print(f"  {target} → address {''.join(g.value for g in addr) if addr else 'NOT FOUND'}")

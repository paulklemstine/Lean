#!/usr/bin/env python3
"""
Algorithms for Tropical Collision-Based Computing

Implements the core algorithms from the research:
1. Min-plus CA evolution
2. NAND expression builder (functional completeness)
3. Circuit-to-torus compiler
4. Periodic orbit finder via constraint system
5. Tropical expression evaluator
"""

from typing import List, Tuple, Optional, Dict, Set
from dataclasses import dataclass
from enum import Enum
import numpy as np


# ============================================================================
# Algorithm 1: Min-Plus Expression Evaluator
# ============================================================================

class ExprType(Enum):
    VAR = "var"
    CONST = "const"
    TMIN = "tmin"
    TPLUS = "tplus"


@dataclass
class MinPlusExpr:
    """A min-plus (tropical) expression.

    Represents elements of the tropical semiring (Z, min, +).
    Variables are indexed by integers.

    Time complexity for evaluation: O(size of expression tree)
    Space complexity: O(depth of expression tree) for recursion stack
    """
    kind: ExprType
    value: Optional[int] = None     # for CONST
    var_idx: Optional[int] = None   # for VAR
    left: Optional['MinPlusExpr'] = None
    right: Optional['MinPlusExpr'] = None

    @staticmethod
    def var(i: int) -> 'MinPlusExpr':
        return MinPlusExpr(kind=ExprType.VAR, var_idx=i)

    @staticmethod
    def const(c: int) -> 'MinPlusExpr':
        return MinPlusExpr(kind=ExprType.CONST, value=c)

    @staticmethod
    def tmin(a: 'MinPlusExpr', b: 'MinPlusExpr') -> 'MinPlusExpr':
        return MinPlusExpr(kind=ExprType.TMIN, left=a, right=b)

    @staticmethod
    def tplus(a: 'MinPlusExpr', b: 'MinPlusExpr') -> 'MinPlusExpr':
        return MinPlusExpr(kind=ExprType.TPLUS, left=a, right=b)

    def eval(self, assignment: Dict[int, int]) -> int:
        """Evaluate the expression given variable assignments.

        Args:
            assignment: maps variable index -> integer value

        Returns:
            Integer result of evaluation

        Time: O(n) where n = tree size
        Space: O(d) where d = tree depth
        """
        if self.kind == ExprType.VAR:
            return assignment[self.var_idx]
        elif self.kind == ExprType.CONST:
            return self.value
        elif self.kind == ExprType.TMIN:
            return min(self.left.eval(assignment), self.right.eval(assignment))
        elif self.kind == ExprType.TPLUS:
            return self.left.eval(assignment) + self.right.eval(assignment)

    def substitute(self, sigma: Dict[int, 'MinPlusExpr']) -> 'MinPlusExpr':
        """Substitute variables with expressions.

        Args:
            sigma: maps variable index -> replacement expression

        Returns:
            New expression with substitutions applied

        Time: O(n * m) where n = tree size, m = max substitution size
        """
        if self.kind == ExprType.VAR:
            return sigma.get(self.var_idx, self)
        elif self.kind == ExprType.CONST:
            return self
        elif self.kind == ExprType.TMIN:
            return MinPlusExpr.tmin(
                self.left.substitute(sigma),
                self.right.substitute(sigma))
        elif self.kind == ExprType.TPLUS:
            return MinPlusExpr.tplus(
                self.left.substitute(sigma),
                self.right.substitute(sigma))

    def size(self) -> int:
        """Number of nodes in the expression tree."""
        if self.kind in (ExprType.VAR, ExprType.CONST):
            return 1
        return 1 + self.left.size() + self.right.size()


# ============================================================================
# Algorithm 2: Min-Plus CA Step
# ============================================================================

def min_plus_ca_step(config: np.ndarray, radius: int = 1) -> np.ndarray:
    """One step of a min-plus cellular automaton on a torus.

    The update rule is:
        new[i,j] = min over neighbors (q) of (old[q] + weight(p, q))

    where weight(p, q) = Manhattan distance between p and q.

    Args:
        config: m×n integer array (torus configuration)
        radius: neighborhood radius (default 1 = von Neumann)

    Returns:
        Updated configuration

    Time: O(m * n * (2r+1)^2)
    Space: O(m * n)
    """
    m, n = config.shape
    result = config.copy()

    for di in range(-radius, radius + 1):
        for dj in range(-radius, radius + 1):
            weight = abs(di) + abs(dj)
            if weight == 0:
                continue
            shifted = np.roll(np.roll(config, -di, axis=0), -dj, axis=1) + weight
            result = np.minimum(result, shifted)

    return result


def min_plus_ca_evolve(config: np.ndarray, steps: int, radius: int = 1) -> np.ndarray:
    """Evolve a min-plus CA configuration for multiple steps.

    Time: O(T * m * n * (2r+1)^2)
    """
    for _ in range(steps):
        config = min_plus_ca_step(config, radius)
    return config


# ============================================================================
# Algorithm 3: NAND Expression Builder
# ============================================================================

@dataclass
class BoolExpr:
    """Boolean expression from NAND gates.

    Represents the BoolExpr type from the formalization.
    """
    kind: str  # "var" or "nand"
    var_idx: Optional[int] = None
    left: Optional['BoolExpr'] = None
    right: Optional['BoolExpr'] = None

    @staticmethod
    def var(i: int) -> 'BoolExpr':
        return BoolExpr(kind="var", var_idx=i)

    @staticmethod
    def nand(a: 'BoolExpr', b: 'BoolExpr') -> 'BoolExpr':
        return BoolExpr(kind="nand", left=a, right=b)

    @staticmethod
    def not_(e: 'BoolExpr') -> 'BoolExpr':
        return BoolExpr.nand(e, e)

    @staticmethod
    def and_(a: 'BoolExpr', b: 'BoolExpr') -> 'BoolExpr':
        nab = BoolExpr.nand(a, b)
        return BoolExpr.nand(nab, nab)

    @staticmethod
    def or_(a: 'BoolExpr', b: 'BoolExpr') -> 'BoolExpr':
        return BoolExpr.nand(BoolExpr.not_(a), BoolExpr.not_(b))

    def eval(self, inputs: Dict[int, bool]) -> bool:
        if self.kind == "var":
            return inputs[self.var_idx]
        elif self.kind == "nand":
            return not (self.left.eval(inputs) and self.right.eval(inputs))

    def gate_count(self) -> int:
        """Count NAND gates used."""
        if self.kind == "var":
            return 0
        return 1 + self.left.gate_count() + self.right.gate_count()


def build_bool_expr(f_tt: bool, f_tf: bool, f_ft: bool, f_ff: bool) -> BoolExpr:
    """Build a BoolExpr computing any 2-input Boolean function from its truth table.

    This implements the buildBoolExpr function from the formalization.

    Args:
        f_tt, f_tf, f_ft, f_ff: function values at (T,T), (T,F), (F,T), (F,F)

    Returns:
        BoolExpr computing the function using only NAND gates

    Time: O(1) — fixed-size lookup
    Gate count: at most 12 NAND gates for any function
    """
    x = BoolExpr.var(0)
    y = BoolExpr.var(1)
    nx = BoolExpr.not_(x)
    ny = BoolExpr.not_(y)
    ct = BoolExpr.nand(nx, x)  # const True
    cf = BoolExpr.nand(ct, ct)  # const False

    key = (f_tt, f_tf, f_ft, f_ff)
    table = {
        (True,True,True,True): ct,
        (False,False,False,False): cf,
        (True,True,True,False): BoolExpr.or_(x, y),
        (True,True,False,False): x,
        (True,False,True,False): y,
        (True,False,False,False): BoolExpr.and_(x, y),
        (False,True,True,True): BoolExpr.nand(x, y),
        (False,False,True,True): nx,
        (False,True,False,True): ny,
        (False,False,False,True): BoolExpr.and_(nx, ny),
        (False,True,False,False): BoolExpr.and_(x, ny),
        (False,False,True,False): BoolExpr.and_(nx, y),
        (True,False,False,True): BoolExpr.or_(BoolExpr.and_(x, y), BoolExpr.and_(nx, ny)),
        (False,True,True,False): BoolExpr.or_(BoolExpr.and_(x, ny), BoolExpr.and_(nx, y)),
        (True,True,False,True): BoolExpr.or_(x, ny),
        (True,False,True,True): BoolExpr.or_(nx, y),
    }

    return table[key]


# ============================================================================
# Algorithm 4: Periodic Orbit Constraint System Builder
# ============================================================================

def build_periodic_constraints(
    update_exprs: List[MinPlusExpr],
    period: int
) -> List[Tuple[MinPlusExpr, MinPlusExpr]]:
    """Build the constraint system for period-p fixed points.

    Given a min-plus CA defined by update expressions F_i for each cell i,
    computes F^p by iterated substitution and returns constraints
    F^p_i(x) = x_i.

    Args:
        update_exprs: list of MinPlusExpr, one per cell
        period: the period p

    Returns:
        List of (lhs, rhs) pairs where lhs is F^p_i and rhs is var(i)

    Time: O(p * n * S) where S = max expression size, n = number of cells
    Space: O(n * S^p) — expression trees grow exponentially with period
    """
    n = len(update_exprs)

    # Build F^p by iterated composition
    current_map = {i: MinPlusExpr.var(i) for i in range(n)}

    for _ in range(period):
        new_map = {}
        sigma = current_map
        for i in range(n):
            new_map[i] = update_exprs[i].substitute(sigma)
        current_map = new_map

    # Build constraints: F^p_i(x) = x_i
    constraints = []
    for i in range(n):
        constraints.append((current_map[i], MinPlusExpr.var(i)))

    return constraints


def check_periodic_point(
    update_exprs: List[MinPlusExpr],
    assignment: Dict[int, int],
    period: int
) -> bool:
    """Check if an assignment is a period-p point.

    Time: O(p * n * S)
    """
    current = dict(assignment)
    for _ in range(period):
        new_vals = {}
        for i, expr in enumerate(update_exprs):
            new_vals[i] = expr.eval(current)
        current = new_vals

    return all(current[i] == assignment[i] for i in assignment)


# ============================================================================
# Algorithm 5: Tropical CA Circuit Compiler
# ============================================================================

@dataclass
class GadgetPlacement:
    """A gadget placed at a specific position on the torus."""
    gadget_type: str
    position: Tuple[int, int]
    input_wires: List[int]
    output_wire: int
    runtime: int
    bounding_box: Tuple[int, int]  # width, height


def compile_nand_circuit(
    circuit_gates: List[Tuple[int, int]],
    num_inputs: int,
    output_wire: int,
    gadget_width: int = 10,
    gadget_height: int = 10,
    wire_spacing: int = 5,
    gadget_runtime: int = 20
) -> Tuple[int, int, int, List[GadgetPlacement]]:
    """Compile a NAND circuit into torus gadget placements.

    Uses a layered layout where each gate layer is separated by
    sufficient spacing to ensure causal isolation.

    Args:
        circuit_gates: list of (input1, input2) pairs for each gate
        num_inputs: number of input wires
        output_wire: index of the output wire
        gadget_width, gadget_height: dimensions of each gate gadget
        wire_spacing: minimum spacing between gadgets
        gadget_runtime: time steps for one gate evaluation

    Returns:
        (torus_m, torus_n, total_runtime, placements)

    Time: O(g) where g = number of gates
    Space: O(g)
    """
    num_gates = len(circuit_gates)

    # Compute gate depths (topological layering)
    depths = [0] * (num_inputs + num_gates)
    for i, (in1, in2) in enumerate(circuit_gates):
        gate_idx = num_inputs + i
        depths[gate_idx] = max(depths[in1], depths[in2]) + 1

    max_depth = max(depths) if depths else 0

    # Compute torus dimensions
    separation = gadget_width + wire_spacing
    torus_n = separation * (num_gates + num_inputs + 1)
    torus_m = separation * (max_depth + 2)
    total_runtime = (max_depth + 1) * gadget_runtime

    # Place gadgets
    placements = []
    for i, (in1, in2) in enumerate(circuit_gates):
        gate_idx = num_inputs + i
        depth = depths[gate_idx]
        placements.append(GadgetPlacement(
            gadget_type="NAND",
            position=(depth * separation, i * separation),
            input_wires=[in1, in2],
            output_wire=gate_idx,
            runtime=gadget_runtime,
            bounding_box=(gadget_width, gadget_height)
        ))

    return torus_m, torus_n, total_runtime, placements


# ============================================================================
# DEMONSTRATIONS
# ============================================================================

def demo_min_plus_expr():
    """Demonstrate min-plus expression evaluation."""
    print("=" * 60)
    print("Min-Plus Expression Evaluation")
    print("=" * 60)

    # Example: min(x + 3, y + 1, x + y)
    x = MinPlusExpr.var(0)
    y = MinPlusExpr.var(1)

    expr = MinPlusExpr.tmin(
        MinPlusExpr.tplus(x, MinPlusExpr.const(3)),
        MinPlusExpr.tmin(
            MinPlusExpr.tplus(y, MinPlusExpr.const(1)),
            MinPlusExpr.tplus(x, y)
        )
    )

    print(f"  Expression: min(x+3, y+1, x+y)")
    print(f"  Expression size: {expr.size()} nodes")

    for xv, yv in [(0, 0), (1, 2), (5, 1), (-3, 4)]:
        result = expr.eval({0: xv, 1: yv})
        expected = min(xv + 3, yv + 1, xv + yv)
        print(f"    x={xv:3d}, y={yv:3d} → {result:3d} (expected: {expected:3d}) {'✓' if result == expected else '✗'}")
    print()


def demo_periodic_constraints():
    """Demonstrate periodic orbit constraint system."""
    print("=" * 60)
    print("Periodic Orbit Constraint System")
    print("=" * 60)

    # Simple 2-cell CA: F(x0, x1) = (min(x0, x1+1), min(x1, x0+1))
    x0 = MinPlusExpr.var(0)
    x1 = MinPlusExpr.var(1)

    update = [
        MinPlusExpr.tmin(x0, MinPlusExpr.tplus(x1, MinPlusExpr.const(1))),
        MinPlusExpr.tmin(x1, MinPlusExpr.tplus(x0, MinPlusExpr.const(1)))
    ]

    for p in [1, 2, 3]:
        constraints = build_periodic_constraints(update, p)
        print(f"\n  Period-{p} constraints ({len(constraints)} equations):")
        print(f"    Constraint system size: {sum(c[0].size() for c in constraints)} nodes")

        # Check some candidate points
        test_points = [
            {0: 0, 1: 0},
            {0: 0, 1: 1},
            {0: 1, 1: 1},
            {0: 0, 1: 2},
            {0: 5, 1: 5},
        ]
        for pt in test_points:
            is_periodic = check_periodic_point(update, pt, p)
            if is_periodic:
                print(f"    ✓ ({pt[0]}, {pt[1]}) is period-{p}")
    print()


def demo_circuit_compiler():
    """Demonstrate the circuit compiler."""
    print("=" * 60)
    print("Circuit-to-Torus Compiler")
    print("=" * 60)

    # XOR circuit: 4 NAND gates
    xor_gates = [(0, 1), (0, 2), (1, 2), (3, 4)]
    m, n, T, placements = compile_nand_circuit(xor_gates, 2, 5)
    print(f"  XOR circuit:")
    print(f"    Inputs: 2, Gates: {len(xor_gates)}")
    print(f"    Torus size: {m} × {n}")
    print(f"    Runtime: {T} steps")
    print(f"    Gadget placements: {len(placements)}")
    for p in placements:
        print(f"      {p.gadget_type} at {p.position}: "
              f"wires {p.input_wires} → {p.output_wire}")

    # Full adder
    adder_gates = [
        (0, 1),  # NAND(a,b) = wire 3
        (0, 3),  # NAND(a, NAND(a,b)) = wire 4
        (1, 3),  # NAND(b, NAND(a,b)) = wire 5
        (4, 5),  # XOR(a,b) = wire 6
        (6, 2),  # NAND(XOR(a,b), cin) = wire 7
        (6, 7),  # NAND(XOR, NAND(XOR,cin)) = wire 8
        (2, 7),  # NAND(cin, NAND(XOR,cin)) = wire 9
        (8, 9),  # SUM = wire 10
    ]
    m, n, T, placements = compile_nand_circuit(adder_gates, 3, 10)
    print(f"\n  Full Adder (sum bit):")
    print(f"    Inputs: 3, Gates: {len(adder_gates)}")
    print(f"    Torus size: {m} × {n}")
    print(f"    Runtime: {T} steps")
    print()


if __name__ == '__main__':
    demo_min_plus_expr()
    demo_periodic_constraints()
    demo_circuit_compiler()
    print("✓ All algorithm demos completed!")

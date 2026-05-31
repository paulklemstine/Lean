"""
Circuit Complexity Algorithms

Implementations of key algorithms from circuit complexity theory,
including Shannon's counting argument, sensitivity computation,
and barrier analysis.
"""

from typing import Callable, List, Tuple, Dict, Set, Optional
from itertools import product
from math import log2, ceil, comb
from functools import lru_cache


# ============================================================
# Boolean Function Representation
# ============================================================

BoolFn = Callable[[Tuple[bool, ...]], bool]


def enumerate_inputs(n: int) -> List[Tuple[bool, ...]]:
    """Enumerate all 2^n Boolean inputs of length n."""
    return list(product([False, True], repeat=n))


def truth_table(f: BoolFn, n: int) -> Tuple[bool, ...]:
    """Compute the truth table of a Boolean function on n variables."""
    return tuple(f(x) for x in enumerate_inputs(n))


def count_boolean_functions(n: int) -> int:
    """Count the number of Boolean functions on n variables: 2^(2^n)."""
    return 2 ** (2 ** n)


# ============================================================
# Parity Function
# ============================================================

def parity(x: Tuple[bool, ...]) -> bool:
    """Compute the parity (XOR) of a Boolean input."""
    return sum(x) % 2 == 1


def flip_bit(x: Tuple[bool, ...], i: int) -> Tuple[bool, ...]:
    """Flip bit i in input x."""
    lst = list(x)
    lst[i] = not lst[i]
    return tuple(lst)


# ============================================================
# Sensitivity Computation
# ============================================================

def sensitivity_at(f: BoolFn, x: Tuple[bool, ...]) -> int:
    """Compute the sensitivity of f at input x."""
    n = len(x)
    count = 0
    for i in range(n):
        x_flipped = flip_bit(x, i)
        if f(x) != f(x_flipped):
            count += 1
    return count


def max_sensitivity(f: BoolFn, n: int) -> int:
    """Compute the maximum sensitivity of f over all inputs."""
    return max(sensitivity_at(f, x) for x in enumerate_inputs(n))


def avg_sensitivity(f: BoolFn, n: int) -> float:
    """Compute the average sensitivity of f over all inputs."""
    inputs = enumerate_inputs(n)
    return sum(sensitivity_at(f, x) for x in inputs) / len(inputs)


# ============================================================
# Shannon's Counting Argument
# ============================================================

def circuit_count_upper_bound(n: int, s: int) -> int:
    """
    Upper bound on the number of Boolean circuits with n inputs and s gates.

    Each gate has:
    - 3 choices of gate type (AND, OR, NOT)
    - For binary gates: (s + n + 2)^2 choices of inputs
    - For NOT: (s + n + 2) choices of input

    Rough upper bound: 3^s * (s + n + 2)^(2s)
    """
    base = s + n + 2
    return (3 ** s) * (base ** (2 * s))


def shannon_threshold(n: int) -> int:
    """
    Find the minimum circuit size s such that the number of circuits
    of size ≤ s exceeds the number of Boolean functions on n variables.

    Shannon's theorem says this threshold is approximately 2^n / (2n).
    """
    num_functions = count_boolean_functions(n)
    s = 1
    while circuit_count_upper_bound(n, s) < num_functions:
        s += 1
    return s


def shannon_lower_bound(n: int) -> float:
    """
    Shannon's lower bound: most functions on n variables require
    circuits of size at least 2^n / (2n).
    """
    return (2 ** n) / (2 * n)


# ============================================================
# Complexity Barrier Model
# ============================================================

class ComplexityBarrier:
    """
    A complexity barrier consists of:
    - A ceiling: the maximum lower bound achievable by techniques in scope
    - A set of technique strengths
    """

    def __init__(self, name: str, ceiling: int, technique_strengths: List[int]):
        self.name = name
        self.ceiling = ceiling
        self.technique_strengths = technique_strengths
        # Verify the barrier property
        assert all(s <= ceiling for s in technique_strengths), \
            f"Barrier {name}: some technique exceeds ceiling {ceiling}"

    def blocks(self, target: int) -> bool:
        """Check if this barrier blocks achieving the target."""
        return self.ceiling < target

    def is_tight(self) -> bool:
        """Check if some technique achieves the ceiling."""
        return self.ceiling in self.technique_strengths

    def gap(self, target: int) -> int:
        """Compute the gap between ceiling and target."""
        return max(0, target - self.ceiling)

    @staticmethod
    def compose(b1: 'ComplexityBarrier', b2: 'ComplexityBarrier') -> 'ComplexityBarrier':
        """Compose two barriers."""
        ceiling = max(b1.ceiling, b2.ceiling)
        strengths = [
            max(s1, s2)
            for s1 in b1.technique_strengths
            for s2 in b2.technique_strengths
        ]
        return ComplexityBarrier(
            f"{b1.name}+{b2.name}",
            ceiling,
            strengths
        )


def create_relativization_barrier() -> ComplexityBarrier:
    """
    Relativization barrier (Baker-Gill-Solovay, 1975).
    Relativizing techniques can prove at most polynomial
    relationships between complexity classes.
    """
    return ComplexityBarrier(
        "Relativization",
        ceiling=3,  # can prove polynomial relationships
        technique_strengths=[1, 2, 3]  # diagonalization, simulation, padding
    )


def create_natural_proofs_barrier() -> ComplexityBarrier:
    """
    Natural proofs barrier (Razborov-Rudich, 1997).
    Natural proof techniques can prove at most quasi-polynomial
    circuit lower bounds (under OWF assumption).
    """
    return ComplexityBarrier(
        "Natural Proofs",
        ceiling=4,  # quasi-polynomial lower bounds
        technique_strengths=[2, 3, 4]  # random restriction, approximation, sunflower
    )


def create_algebrization_barrier() -> ComplexityBarrier:
    """
    Algebrization barrier (Aaronson-Wigderson, 2009).
    Algebrizing techniques extend relativization with algebraic structure.
    """
    return ComplexityBarrier(
        "Algebrization",
        ceiling=5,  # slightly beyond relativization
        technique_strengths=[3, 4, 5]  # arithmetization, sumcheck, low-degree extension
    )


# ============================================================
# Monotone Circuit Analysis
# ============================================================

class BoolCircuit:
    """Simple Boolean circuit representation."""

    def __init__(self, gate_type: str, inputs=None, children=None):
        """
        gate_type: 'INPUT', 'TRUE', 'FALSE', 'AND', 'OR', 'NOT'
        inputs: for INPUT gates, the variable index
        children: list of child circuits
        """
        self.gate_type = gate_type
        self.input_idx = inputs
        self.children = children or []

    def eval(self, x: Tuple[bool, ...]) -> bool:
        if self.gate_type == 'INPUT':
            return x[self.input_idx]
        elif self.gate_type == 'TRUE':
            return True
        elif self.gate_type == 'FALSE':
            return False
        elif self.gate_type == 'AND':
            return self.children[0].eval(x) and self.children[1].eval(x)
        elif self.gate_type == 'OR':
            return self.children[0].eval(x) or self.children[1].eval(x)
        elif self.gate_type == 'NOT':
            return not self.children[0].eval(x)
        else:
            raise ValueError(f"Unknown gate type: {self.gate_type}")

    @property
    def size(self) -> int:
        if self.gate_type in ('INPUT', 'TRUE', 'FALSE'):
            return 0
        elif self.gate_type == 'NOT':
            return 1 + self.children[0].size
        else:
            return 1 + self.children[0].size + self.children[1].size

    @property
    def depth(self) -> int:
        if self.gate_type in ('INPUT', 'TRUE', 'FALSE'):
            return 0
        elif self.gate_type == 'NOT':
            return 1 + self.children[0].depth
        else:
            return 1 + max(self.children[0].depth, self.children[1].depth)

    @property
    def is_monotone(self) -> bool:
        if self.gate_type == 'NOT':
            return False
        return all(c.is_monotone for c in self.children)

    def restrict(self, var_idx: int, value: bool) -> 'BoolCircuit':
        """Restrict variable var_idx to the given value."""
        if self.gate_type == 'INPUT':
            if self.input_idx == var_idx:
                return BoolCircuit('TRUE' if value else 'FALSE')
            return self
        elif self.gate_type in ('TRUE', 'FALSE'):
            return self
        elif self.gate_type == 'NOT':
            return BoolCircuit('NOT', children=[self.children[0].restrict(var_idx, value)])
        else:
            return BoolCircuit(
                self.gate_type,
                children=[c.restrict(var_idx, value) for c in self.children]
            )


# ============================================================
# CNF and SAT
# ============================================================

Literal = Tuple[int, bool]  # (variable_index, is_positive)
Clause = List[Literal]
CNFFormula = List[Clause]


def eval_literal(x: Tuple[bool, ...], lit: Literal) -> bool:
    """Evaluate a literal."""
    var, positive = lit
    return x[var] if positive else not x[var]


def eval_clause(x: Tuple[bool, ...], clause: Clause) -> bool:
    """Evaluate a clause (disjunction)."""
    return any(eval_literal(x, lit) for lit in clause)


def eval_cnf(x: Tuple[bool, ...], formula: CNFFormula) -> bool:
    """Evaluate a CNF formula (conjunction of clauses)."""
    return all(eval_clause(x, clause) for clause in formula)


def is_satisfiable(formula: CNFFormula, n: int) -> Optional[Tuple[bool, ...]]:
    """Brute-force SAT solver. Returns a satisfying assignment or None."""
    for x in enumerate_inputs(n):
        if eval_cnf(x, formula):
            return x
    return None


def pigeonhole_cnf(n: int) -> Tuple[CNFFormula, int]:
    """
    Generate PHP(n+1, n): pigeonhole principle for n+1 pigeons, n holes.
    Returns (formula, num_variables).

    Variables: x_{i,j} = pigeon i is in hole j
    For i in {0,...,n}, j in {0,...,n-1}.
    """
    num_vars = (n + 1) * n

    def var(pigeon: int, hole: int) -> int:
        return pigeon * n + hole

    clauses: CNFFormula = []

    # Each pigeon must be in some hole
    for i in range(n + 1):
        clause = [(var(i, j), True) for j in range(n)]
        clauses.append(clause)

    # No two pigeons in the same hole
    for j in range(n):
        for i1 in range(n + 1):
            for i2 in range(i1 + 1, n + 1):
                clauses.append([(var(i1, j), False), (var(i2, j), False)])

    return clauses, num_vars


if __name__ == "__main__":
    # Quick self-test
    print("=== Algorithm Self-Tests ===")

    # Test parity
    assert parity((False,)) == False
    assert parity((True,)) == True
    assert parity((True, True)) == False
    assert parity((True, False, True)) == False
    print("✓ Parity function correct")

    # Test sensitivity
    for n in range(1, 6):
        s = max_sensitivity(parity, n)
        assert s == n, f"Expected sensitivity {n}, got {s}"
    print("✓ Parity has maximum sensitivity n")

    # Test Shannon threshold
    for n in range(2, 7):
        lb = shannon_lower_bound(n)
        print(f"  n={n}: Shannon lower bound = {lb:.1f}")
    print("✓ Shannon lower bounds computed")

    # Test barriers
    b1 = create_relativization_barrier()
    b2 = create_natural_proofs_barrier()
    b3 = create_algebrization_barrier()
    target = 10  # superpolynomial
    assert b1.blocks(target)
    assert b2.blocks(target)
    assert b3.blocks(target)
    composed = ComplexityBarrier.compose(
        ComplexityBarrier.compose(b1, b2), b3
    )
    assert composed.blocks(target)
    print("✓ All three barriers block superpolynomial target")

    # Test PHP unsatisfiability
    for n in range(2, 5):
        php, num_vars = pigeonhole_cnf(n)
        result = is_satisfiable(php, num_vars)
        assert result is None, f"PHP({n+1},{n}) should be unsatisfiable"
    print("✓ PHP unsatisfiability verified for small n")

    print("\nAll self-tests passed!")

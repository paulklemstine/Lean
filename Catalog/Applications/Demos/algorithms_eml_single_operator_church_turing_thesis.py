"""
EML Single-Operator Church-Turing Thesis: Algorithms

Type-hinted implementations of EML circuit evaluation, depth computation,
and circuit enumeration for the depth-width tradeoff conjecture.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, Optional
import math


# ============================================================================
# §1. EML Circuit Data Structure
# ============================================================================

@dataclass(frozen=True)
class EMLCircuit:
    """An EML expression tree node."""
    kind: str  # 'var', 'const', 'add', 'mul', 'neg', 'inv', 'exp', 'log'
    value: Optional[float] = None  # For 'const' nodes
    left: Optional['EMLCircuit'] = None
    right: Optional['EMLCircuit'] = None

    def eval(self, x: float) -> float:
        """Evaluate the circuit at input x."""
        if self.kind == 'var':
            return x
        elif self.kind == 'const':
            return self.value if self.value is not None else 0.0
        elif self.kind == 'add':
            return self.left.eval(x) + self.right.eval(x)
        elif self.kind == 'mul':
            return self.left.eval(x) * self.right.eval(x)
        elif self.kind == 'neg':
            return -self.left.eval(x)
        elif self.kind == 'inv':
            v = self.left.eval(x)
            return 1.0 / v if v != 0 else 0.0
        elif self.kind == 'exp':
            v = self.left.eval(x)
            try:
                return math.exp(v)
            except OverflowError:
                return float('inf')
        elif self.kind == 'log':
            v = self.left.eval(x)
            return math.log(v) if v > 0 else 0.0
        else:
            raise ValueError(f"Unknown node kind: {self.kind}")

    @property
    def size(self) -> int:
        """Total number of nodes."""
        if self.kind in ('var', 'const'):
            return 1
        elif self.kind in ('neg', 'inv', 'exp', 'log'):
            return 1 + self.left.size
        else:
            return 1 + self.left.size + self.right.size

    @property
    def transc_depth(self) -> int:
        """Transcendental depth: max exp/log nodes on root-to-leaf path."""
        if self.kind in ('var', 'const'):
            return 0
        elif self.kind in ('add', 'mul'):
            return max(self.left.transc_depth, self.right.transc_depth)
        elif self.kind in ('neg', 'inv'):
            return self.left.transc_depth
        elif self.kind in ('exp', 'log'):
            return 1 + self.left.transc_depth
        else:
            return 0

    @property
    def depth(self) -> int:
        """Standard depth (max root-to-leaf path)."""
        if self.kind in ('var', 'const'):
            return 0
        elif self.kind in ('add', 'mul'):
            return 1 + max(self.left.depth, self.right.depth)
        elif self.kind in ('neg', 'inv', 'exp', 'log'):
            return 1 + self.left.depth
        else:
            return 0

    @property
    def is_algebraic(self) -> bool:
        """True if no exp/log nodes."""
        if self.kind in ('var', 'const'):
            return True
        elif self.kind in ('add', 'mul'):
            return self.left.is_algebraic and self.right.is_algebraic
        elif self.kind in ('neg', 'inv'):
            return self.left.is_algebraic
        elif self.kind in ('exp', 'log'):
            return False
        return False

    def substitute(self, replacement: 'EMLCircuit') -> 'EMLCircuit':
        """Replace all 'var' leaves with the given circuit."""
        if self.kind == 'var':
            return replacement
        elif self.kind == 'const':
            return self
        elif self.kind in ('neg', 'inv', 'exp', 'log'):
            return EMLCircuit(self.kind, left=self.left.substitute(replacement))
        elif self.kind in ('add', 'mul'):
            return EMLCircuit(self.kind,
                              left=self.left.substitute(replacement),
                              right=self.right.substitute(replacement))
        return self

    def __str__(self) -> str:
        if self.kind == 'var':
            return 'x'
        elif self.kind == 'const':
            return str(self.value)
        elif self.kind == 'add':
            return f'({self.left} + {self.right})'
        elif self.kind == 'mul':
            return f'({self.left} * {self.right})'
        elif self.kind == 'neg':
            return f'(-{self.left})'
        elif self.kind == 'inv':
            return f'(1/{self.left})'
        elif self.kind == 'exp':
            return f'exp({self.left})'
        elif self.kind == 'log':
            return f'log({self.left})'
        return '?'


# ============================================================================
# §2. Constructor Helpers
# ============================================================================

def Var() -> EMLCircuit:
    return EMLCircuit('var')

def Const(c: float) -> EMLCircuit:
    return EMLCircuit('const', value=c)

def Add(a: EMLCircuit, b: EMLCircuit) -> EMLCircuit:
    return EMLCircuit('add', left=a, right=b)

def Mul(a: EMLCircuit, b: EMLCircuit) -> EMLCircuit:
    return EMLCircuit('mul', left=a, right=b)

def Neg(a: EMLCircuit) -> EMLCircuit:
    return EMLCircuit('neg', left=a)

def Inv(a: EMLCircuit) -> EMLCircuit:
    return EMLCircuit('inv', left=a)

def Exp(a: EMLCircuit) -> EMLCircuit:
    return EMLCircuit('exp', left=a)

def Log(a: EMLCircuit) -> EMLCircuit:
    return EMLCircuit('log', left=a)


# ============================================================================
# §3. Standard Circuits
# ============================================================================

def iter_exp_circuit(n: int) -> EMLCircuit:
    """Circuit for the n-fold iterated exponential."""
    c = Var()
    for _ in range(n):
        c = Exp(c)
    return c

def sinh_circuit() -> EMLCircuit:
    """Circuit for sinh(x) = (exp(x) - exp(-x)) / 2."""
    return Mul(Add(Exp(Var()), Neg(Exp(Neg(Var())))), Const(0.5))

def cosh_circuit() -> EMLCircuit:
    """Circuit for cosh(x) = (exp(x) + exp(-x)) / 2."""
    return Mul(Add(Exp(Var()), Exp(Neg(Var()))), Const(0.5))

def gaussian_circuit() -> EMLCircuit:
    """Circuit for exp(-x^2)."""
    return Exp(Neg(Mul(Var(), Var())))

def sigmoid_circuit() -> EMLCircuit:
    """Circuit for 1 / (1 + exp(-x))."""
    return Inv(Add(Const(1.0), Exp(Neg(Var()))))

def logistic_map_circuit(r: float) -> EMLCircuit:
    """Circuit for the logistic map r*x*(1-x)."""
    return Mul(Mul(Const(r), Var()), Add(Const(1.0), Neg(Var())))


# ============================================================================
# §4. The EML Operator
# ============================================================================

def eml_op(x: float, y: float) -> float:
    """The EML binary operator: eml(x, y) = exp(x) - log(y)."""
    log_y = math.log(y) if y > 0 else 0.0
    try:
        return math.exp(x) - log_y
    except OverflowError:
        return float('inf')


def recover_exp_via_eml(x: float) -> float:
    """Recover exp(x) via eml(x, 1)."""
    return eml_op(x, 1.0)


def recover_log_via_eml(y: float) -> float:
    """Recover log(y) via 1 - eml(0, y)."""
    return 1.0 - eml_op(0.0, y)


# ============================================================================
# §5. Iterated Exponential
# ============================================================================

def iter_exp(n: int, x: float) -> float:
    """Compute the n-fold iterated exponential."""
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


# ============================================================================
# §6. Circuit Enumeration (for Depth-Width Tradeoff)
# ============================================================================

def enumerate_circuits(max_size: int, max_depth: int,
                       constants: list[float] = [0.0, 1.0, -1.0, 0.5, 2.0]
                       ) -> list[EMLCircuit]:
    """
    Enumerate all EML circuits up to a given size and transcendental depth.

    This is for testing the depth-width tradeoff conjecture.
    """
    circuits: list[EMLCircuit] = []

    def _gen(remaining_size: int, remaining_td: int) -> list[EMLCircuit]:
        if remaining_size <= 0:
            return []
        result = [Var()]
        for c in constants:
            result.append(Const(c))
        if remaining_size >= 2:
            for sub in _gen(remaining_size - 1, remaining_td):
                result.append(Neg(sub))
                result.append(Inv(sub))
            if remaining_td >= 1:
                for sub in _gen(remaining_size - 1, remaining_td - 1):
                    result.append(Exp(sub))
                    result.append(Log(sub))
        if remaining_size >= 3:
            for s1 in range(1, remaining_size - 1):
                s2 = remaining_size - 1 - s1
                left_circuits = _gen(s1, remaining_td)
                right_circuits = _gen(s2, remaining_td)
                for l in left_circuits:
                    for r in right_circuits:
                        result.append(Add(l, r))
                        result.append(Mul(l, r))
        return result

    return _gen(max_size, max_depth)


def check_tradeoff(n: int, test_points: list[float] = [-1.0, 0.0, 1.0, 2.0],
                   max_search_size: int = 6, tol: float = 1e-10
                   ) -> dict:
    """
    Check the depth-width tradeoff conjecture for iterExp(n).

    Returns information about the smallest circuit found.
    """
    target_values = [iter_exp(n, x) for x in test_points]
    chain = iter_exp_circuit(n)
    chain_size = chain.size

    print(f"\nChecking depth-width tradeoff for iterExp({n}):")
    print(f"  Chain circuit size: {chain_size}")
    print(f"  Chain transc depth: {chain.transc_depth}")
    print(f"  Target values at test points: {target_values}")

    best_size = chain_size
    best_circuit = chain

    # Search for smaller circuits
    for size in range(1, min(max_search_size, chain_size)):
        circuits = enumerate_circuits(size, n)
        for c in circuits:
            if c.transc_depth > n:
                continue
            try:
                values = [c.eval(x) for x in test_points]
                if all(abs(v - t) < tol for v, t in zip(values, target_values)
                       if math.isfinite(v) and math.isfinite(t)):
                    if all(math.isfinite(v) for v in values):
                        if c.size < best_size:
                            best_size = c.size
                            best_circuit = c
                            print(f"  Found smaller circuit of size {c.size}: {c}")
            except (OverflowError, ZeroDivisionError, ValueError):
                continue

    return {
        'n': n,
        'chain_size': chain_size,
        'best_size': best_size,
        'best_circuit': str(best_circuit),
        'conjecture_bound': 2 * n - 1,
        'conjecture_holds': best_size >= 2 * n - 1
    }


# ============================================================================
# §7. Depth Class Verification
# ============================================================================

def verify_depth_class(circuit: EMLCircuit, target_fn: Callable[[float], float],
                       test_points: list[float], expected_depth: int,
                       tol: float = 1e-10) -> dict:
    """Verify that a circuit computes the target function at the expected depth."""
    errors = []
    for x in test_points:
        try:
            computed = circuit.eval(x)
            expected = target_fn(x)
            if math.isfinite(computed) and math.isfinite(expected):
                errors.append(abs(computed - expected))
            else:
                errors.append(float('inf'))
        except (OverflowError, ValueError):
            errors.append(float('inf'))

    max_error = max(errors) if errors else 0.0
    return {
        'circuit': str(circuit),
        'size': circuit.size,
        'transc_depth': circuit.transc_depth,
        'expected_depth': expected_depth,
        'depth_correct': circuit.transc_depth <= expected_depth,
        'max_error': max_error,
        'function_correct': max_error < tol,
        'test_points': len(test_points)
    }


if __name__ == '__main__':
    # Quick self-test
    x = Var()
    assert Exp(x).eval(0.0) == 1.0
    assert abs(sinh_circuit().eval(1.0) - math.sinh(1.0)) < 1e-10
    assert abs(cosh_circuit().eval(1.0) - math.cosh(1.0)) < 1e-10
    print("All self-tests passed.")

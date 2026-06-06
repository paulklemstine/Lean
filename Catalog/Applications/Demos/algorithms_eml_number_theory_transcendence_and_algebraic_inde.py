#!/usr/bin/env python3
"""
Algorithms for EML Transcendence Theory

Type-hinted implementations of algorithms related to EML numbers,
Schanuel's conjecture verification, and algebraic independence testing.
"""

from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass
from enum import Enum
import math


class EMLExprType(Enum):
    """Types of EML expression nodes."""
    RAT = "rational"
    ADD = "add"
    MUL = "mul"
    NEG = "neg"
    EXP = "exp"
    LOG = "log"


@dataclass
class EMLExpr:
    """An EML expression tree node."""
    type: EMLExprType
    value: Optional[float] = None  # For RAT nodes
    left: Optional['EMLExpr'] = None  # For binary ops
    right: Optional['EMLExpr'] = None  # For binary ops
    child: Optional['EMLExpr'] = None  # For unary ops

    def eval(self) -> float:
        """Evaluate the EML expression to a real number."""
        if self.type == EMLExprType.RAT:
            return self.value or 0.0
        elif self.type == EMLExprType.ADD:
            return self.left.eval() + self.right.eval()
        elif self.type == EMLExprType.MUL:
            return self.left.eval() * self.right.eval()
        elif self.type == EMLExprType.NEG:
            return -self.child.eval()
        elif self.type == EMLExprType.EXP:
            return math.exp(self.child.eval())
        elif self.type == EMLExprType.LOG:
            v = self.child.eval()
            return math.log(v) if v > 0 else float('-inf')
        raise ValueError(f"Unknown type: {self.type}")

    def depth(self) -> int:
        """Compute the transcendental nesting depth."""
        if self.type == EMLExprType.RAT:
            return 0
        elif self.type in (EMLExprType.ADD, EMLExprType.MUL):
            return max(self.left.depth(), self.right.depth())
        elif self.type == EMLExprType.NEG:
            return self.child.depth()
        elif self.type in (EMLExprType.EXP, EMLExprType.LOG):
            return self.child.depth() + 1
        return 0

    def transc_ops(self) -> int:
        """Count the number of transcendental operations (exp/log)."""
        if self.type == EMLExprType.RAT:
            return 0
        elif self.type in (EMLExprType.ADD, EMLExprType.MUL):
            return self.left.transc_ops() + self.right.transc_ops()
        elif self.type == EMLExprType.NEG:
            return self.child.transc_ops()
        elif self.type in (EMLExprType.EXP, EMLExprType.LOG):
            return self.child.transc_ops() + 1
        return 0

    def is_purely_algebraic(self) -> bool:
        """Check if the expression contains no exp or log."""
        if self.type == EMLExprType.RAT:
            return True
        elif self.type in (EMLExprType.ADD, EMLExprType.MUL):
            return self.left.is_purely_algebraic() and self.right.is_purely_algebraic()
        elif self.type == EMLExprType.NEG:
            return self.child.is_purely_algebraic()
        return False


def make_rat(q: float) -> EMLExpr:
    """Create a rational EML expression."""
    return EMLExpr(type=EMLExprType.RAT, value=q)


def make_eml(ex: EMLExpr, ey: EMLExpr) -> EMLExpr:
    """Create the EML expression eml(x, y) = exp(x) - log(y)."""
    return EMLExpr(
        type=EMLExprType.ADD,
        left=EMLExpr(type=EMLExprType.EXP, child=ex),
        right=EMLExpr(
            type=EMLExprType.NEG,
            child=EMLExpr(type=EMLExprType.LOG, child=ey)
        )
    )


def eml(x: float, y: float) -> float:
    """The EML function: eml(x, y) = exp(x) - log(y)."""
    return math.exp(x) - math.log(y)


def eml_diag(z: float) -> float:
    """Diagonal EML: emlDiag(z) = exp(z) - log(z)."""
    return math.exp(z) - math.log(z)


def schanuel_test_linear_independence(
    vectors: List[List[float]],
    tolerance: float = 1e-10
) -> bool:
    """
    Test approximate Q-linear independence of real numbers.
    
    Uses the LLL algorithm heuristic: if no short integer relation is found
    among the numbers, they are likely Q-linearly independent.
    
    This is a simplified version; a full implementation would use PSLQ or LLL.
    
    Args:
        vectors: List of real number tuples to test
        tolerance: Numerical tolerance for zero detection
    
    Returns:
        True if the vectors appear Q-linearly independent
    """
    n = len(vectors)
    if n == 0:
        return True
    
    # Simple test: check if any integer linear combination with small
    # coefficients gives zero
    max_coeff = 100
    
    for total in range(1, min(max_coeff, 50)):
        # Generate coefficient vectors with L1 norm = total
        # (simplified: just try a few)
        import itertools
        if n <= 3 and total <= 10:
            for coeffs in itertools.product(range(-total, total + 1), repeat=n):
                if all(c == 0 for c in coeffs):
                    continue
                if sum(abs(c) for c in coeffs) > total:
                    continue
                val = sum(c * v for c, v in zip(coeffs, [v[0] if isinstance(v, list) else v for v in vectors]))
                if abs(val) < tolerance:
                    return False
    
    return True


def transcendence_degree_lower_bound(
    numbers: List[float],
    max_degree: int = 4,
    tolerance: float = 1e-8
) -> int:
    """
    Estimate a lower bound on the transcendence degree of a set of numbers.
    
    Tests polynomial relations of increasing degree. If no relation of degree
    up to max_degree is found, returns max_degree as a lower bound.
    
    Algorithm:
    1. For degree d = 1, 2, ..., max_degree:
       a. Generate all monomials of degree ≤ d in the given numbers
       b. Check if any integer linear combination of monomials vanishes
       c. If yes, the transcendence degree is ≤ number_of_vars - 1
    
    Args:
        numbers: List of real numbers to analyze
        max_degree: Maximum polynomial degree to test
        tolerance: Numerical tolerance
    
    Returns:
        Lower bound on transcendence degree
    """
    import itertools
    
    n = len(numbers)
    
    for d in range(1, max_degree + 1):
        # Generate all monomials of degree ≤ d
        monomials: List[float] = []
        exponent_lists: List[Tuple[int, ...]] = []
        
        for exps in itertools.product(range(d + 1), repeat=n):
            if sum(exps) <= d:
                val = 1.0
                for base, exp in zip(numbers, exps):
                    val *= base ** exp
                monomials.append(val)
                exponent_lists.append(exps)
        
        # Check for small integer relations using simple search
        num_monomials = len(monomials)
        if num_monomials > 20:
            continue  # Too many to search exhaustively
        
        found_relation = False
        max_c = 5
        for coeffs in itertools.product(range(-max_c, max_c + 1), repeat=min(num_monomials, 8)):
            if all(c == 0 for c in coeffs):
                continue
            padded = list(coeffs) + [0] * (num_monomials - len(coeffs))
            val = sum(c * m for c, m in zip(padded, monomials))
            if abs(val) < tolerance:
                found_relation = True
                break
        
        if found_relation:
            return max(0, d - 1)
    
    return max_degree


def eml_expression_enumeration(max_depth: int = 2) -> List[Tuple[str, float, int]]:
    """
    Enumerate EML expressions up to a given depth and compute their values.
    
    Returns a list of (expression_string, value, depth) triples.
    
    Args:
        max_depth: Maximum depth of expressions to enumerate
    
    Returns:
        List of (description, value, depth) triples
    """
    results: List[Tuple[str, float, int]] = []
    
    # Depth 0: rationals
    base_rats = [0, 1, 2, -1, 0.5]
    for q in base_rats:
        results.append((f"{q}", q, 0))
    
    if max_depth >= 1:
        # Depth 1: exp and log of rationals
        for q in base_rats:
            if q != 0 or True:  # exp is defined everywhere
                results.append((f"exp({q})", math.exp(q), 1))
            if q > 0:
                results.append((f"log({q})", math.log(q), 1))
        
        # EML at rational inputs
        for p in [0, 1, 2]:
            for q in [1, 2, 3]:
                if q > 0:
                    val = eml(p, q)
                    results.append((f"eml({p},{q})", val, 1))
    
    if max_depth >= 2:
        # Depth 2: exp(exp(q)), exp(log(q)), etc.
        for q in [1, 2]:
            results.append((f"exp(exp({q}))", math.exp(math.exp(q)), 2))
            if q > 0:
                results.append((f"exp(log({q}))", math.exp(math.log(q)), 2))
                results.append((f"log(exp({q}))", math.log(math.exp(q)), 2))
        
        # EML of EML values
        e_val = eml(1, 1)  # = e
        results.append((f"eml(eml(1,1), 1) = exp(e)", eml(e_val, 1), 2))
    
    return results


if __name__ == "__main__":
    print("EML Expression Enumeration (depth ≤ 2)")
    print("=" * 60)
    
    exprs = eml_expression_enumeration(max_depth=2)
    for desc, val, depth in sorted(exprs, key=lambda x: x[2]):
        print(f"  depth={depth}: {desc:30s} = {val:.10f}")
    
    print("\n\nTranscendence Degree Estimates")
    print("=" * 60)
    
    e = math.e
    log2 = math.log(2)
    
    # Test {e, log(2)}
    td = transcendence_degree_lower_bound([e, log2], max_degree=3)
    print(f"  trdeg(Q(e, log(2))) ≥ {td}")
    print(f"  (Under Schanuel: expected = 2)")
    
    # Test {e, e²}
    td = transcendence_degree_lower_bound([e, e**2], max_degree=3)
    print(f"  trdeg(Q(e, e²)) ≥ {td}")
    print(f"  (These are algebraically dependent: e² = e·e)")
    
    # Test {e}
    td = transcendence_degree_lower_bound([e], max_degree=5)
    print(f"  trdeg(Q(e)) ≥ {td}")
    print(f"  (e is transcendental, so expected = 1)")

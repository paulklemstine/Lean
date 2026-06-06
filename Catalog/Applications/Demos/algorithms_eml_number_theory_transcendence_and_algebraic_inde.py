#!/usr/bin/env python3
"""
Algorithms for EML Transcendence Theory

Type-hinted implementations of key algorithms for:
1. EML expression evaluation and analysis
2. Transcendence tower level computation
3. Algebraic independence testing (numerical)
4. Schanuel conjecture verification for small cases
"""

from typing import List, Tuple, Optional, Set, Dict, Union
from dataclasses import dataclass
from enum import Enum
import math
from fractions import Fraction


# ============================================================
# Algorithm 1: EML Expression Tree with Full Analysis
# ============================================================

class NodeType(Enum):
    RAT = "rat"
    ADD = "add"
    MUL = "mul"
    NEG = "neg"
    INV = "inv"
    EXP = "exp"
    LOG = "log"


@dataclass
class EMLNode:
    """A node in an EML expression tree with full metadata."""
    node_type: NodeType
    value: Optional[float] = None  # For RAT nodes
    children: Optional[List['EMLNode']] = None
    
    def eval(self) -> float:
        """Evaluate the expression to a float."""
        if self.node_type == NodeType.RAT:
            return self.value or 0.0
        elif self.node_type == NodeType.ADD:
            return self.children[0].eval() + self.children[1].eval()
        elif self.node_type == NodeType.MUL:
            return self.children[0].eval() * self.children[1].eval()
        elif self.node_type == NodeType.NEG:
            return -self.children[0].eval()
        elif self.node_type == NodeType.INV:
            v = self.children[0].eval()
            return 1.0/v if v != 0 else float('inf')
        elif self.node_type == NodeType.EXP:
            return math.exp(self.children[0].eval())
        elif self.node_type == NodeType.LOG:
            v = self.children[0].eval()
            return math.log(v) if v > 0 else 0.0
        return 0.0
    
    def depth(self) -> int:
        """Compute the transcendental depth (max nesting of exp/log)."""
        if self.node_type == NodeType.RAT:
            return 0
        elif self.node_type in (NodeType.ADD, NodeType.MUL):
            return max(self.children[0].depth(), self.children[1].depth())
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return self.children[0].depth()
        elif self.node_type in (NodeType.EXP, NodeType.LOG):
            return self.children[0].depth() + 1
        return 0
    
    def size(self) -> int:
        """Count total nodes."""
        if self.children is None:
            return 1
        return 1 + sum(c.size() for c in self.children)
    
    def exp_count(self) -> int:
        """Count exp operations."""
        if self.children is None:
            return 0
        base = sum(c.exp_count() for c in self.children)
        return base + (1 if self.node_type == NodeType.EXP else 0)
    
    def log_count(self) -> int:
        """Count log operations."""
        if self.children is None:
            return 0
        base = sum(c.log_count() for c in self.children)
        return base + (1 if self.node_type == NodeType.LOG else 0)
    
    def transc_weight(self) -> int:
        """Total transcendental operations (exp + log)."""
        return self.exp_count() + self.log_count()


def make_rat(q: float) -> EMLNode:
    return EMLNode(NodeType.RAT, value=q)

def make_exp(a: EMLNode) -> EMLNode:
    return EMLNode(NodeType.EXP, children=[a])

def make_log(a: EMLNode) -> EMLNode:
    return EMLNode(NodeType.LOG, children=[a])

def make_add(a: EMLNode, b: EMLNode) -> EMLNode:
    return EMLNode(NodeType.ADD, children=[a, b])

def make_mul(a: EMLNode, b: EMLNode) -> EMLNode:
    return EMLNode(NodeType.MUL, children=[a, b])


# ============================================================
# Algorithm 2: Tower Level Assignment
# ============================================================

def assign_tower_level(expr: EMLNode) -> int:
    """
    Compute the canonical tower level of an EML expression.
    
    Level 0: rationals
    Level k: expressions with depth ≤ k
    
    Algorithm: Simply return the depth.
    
    Pseudocode:
        function TOWER_LEVEL(expr):
            if expr is RAT: return 0
            if expr is ADD or MUL: return max(TOWER_LEVEL(left), TOWER_LEVEL(right))
            if expr is NEG or INV: return TOWER_LEVEL(child)
            if expr is EXP or LOG: return TOWER_LEVEL(child) + 1
    """
    return expr.depth()


# ============================================================
# Algorithm 3: Numerical Algebraic Independence Test
# ============================================================

def numerical_algebraic_independence_test(
    values: List[float],
    max_degree: int = 5,
    tolerance: float = 1e-10
) -> Tuple[bool, Optional[List[int]]]:
    """
    Numerically test if a set of real numbers appears algebraically independent.
    
    Tests all monomials up to given degree for integer relations.
    Returns (True, None) if likely independent, or (False, relation) if a
    near-integer relation is found.
    
    Pseudocode:
        function TEST_ALG_INDEP(values, max_degree):
            for each multiindex α with |α| ≤ max_degree:
                compute product = Π values[i]^α[i]
                if product ≈ integer: return DEPENDENT
            return LIKELY_INDEPENDENT
    """
    from itertools import product as iproduct
    
    n = len(values)
    
    # Generate multi-indices up to max_degree
    for total_deg in range(1, max_degree + 1):
        for exponents in iproduct(range(total_deg + 1), repeat=n):
            if sum(exponents) != total_deg:
                continue
            
            # Compute monomial value
            try:
                monomial_val = 1.0
                for v, e in zip(values, exponents):
                    if e > 0:
                        monomial_val *= v ** e
                
                # Check if close to an integer (simple test)
                rounded = round(monomial_val)
                if abs(monomial_val - rounded) < tolerance and rounded != 0:
                    return False, list(exponents)
            except (OverflowError, ValueError):
                continue
    
    return True, None


# ============================================================
# Algorithm 4: Schanuel Conjecture Verifier (Numerical)
# ============================================================

def verify_schanuel_n1(alpha: float, tolerance: float = 1e-12) -> Dict:
    """
    Numerically verify Schanuel's conjecture for n=1.
    
    For a nonzero α, check that at least one of {α, exp(α)} 
    appears transcendental (not well-approximated by algebraic numbers
    of low degree).
    
    Returns analysis dict with findings.
    """
    exp_alpha = math.exp(alpha)
    
    result = {
        "alpha": alpha,
        "exp_alpha": exp_alpha,
        "alpha_appears_algebraic": False,
        "exp_alpha_appears_algebraic": False,
        "schanuel_satisfied": True,
    }
    
    # Test if alpha appears to be a root of a low-degree polynomial
    for d in range(1, 6):
        # Test p(alpha) ≈ 0 for p with small integer coefficients
        from itertools import product as iproduct
        for coeffs in iproduct(range(-5, 6), repeat=d+1):
            if all(c == 0 for c in coeffs) or coeffs[-1] == 0:
                continue
            val = sum(c * alpha**i for i, c in enumerate(coeffs))
            if abs(val) < tolerance:
                result["alpha_appears_algebraic"] = True
                result["alpha_minimal_poly_degree"] = d
                break
        if result["alpha_appears_algebraic"]:
            break
    
    # Test if exp(alpha) appears algebraic similarly
    for d in range(1, 4):
        from itertools import product as iproduct
        for coeffs in iproduct(range(-5, 6), repeat=d+1):
            if all(c == 0 for c in coeffs) or coeffs[-1] == 0:
                continue
            val = sum(c * exp_alpha**i for i, c in enumerate(coeffs))
            if abs(val) < tolerance:
                result["exp_alpha_appears_algebraic"] = True
                result["exp_alpha_minimal_poly_degree"] = d
                break
        if result["exp_alpha_appears_algebraic"]:
            break
    
    # Schanuel says at least one should be transcendental
    if result["alpha_appears_algebraic"] and result["exp_alpha_appears_algebraic"]:
        result["schanuel_satisfied"] = False
        result["note"] = "POTENTIAL VIOLATION (or numerical artifact)"
    else:
        result["note"] = "Consistent with Schanuel"
    
    return result


# ============================================================
# Algorithm 5: EML Expression Optimizer
# ============================================================

def optimize_eml_depth(target: float, max_depth: int = 3, 
                       tolerance: float = 1e-8) -> Optional[EMLNode]:
    """
    Find a minimal-depth EML expression approximating a target value.
    
    Uses beam search over EML expression trees.
    
    Pseudocode:
        function OPTIMIZE(target, max_depth):
            beam = {Rat(q) : q ∈ small rationals}
            for depth = 1 to max_depth:
                new_beam = {}
                for expr in beam:
                    try exp(expr), log(expr)
                    try expr + other, expr * other for other in beam
                    if |eval(new) - target| < tolerance: return new
                beam = top-k closest expressions
            return closest found
    """
    # Start with small rationals
    rats = [Fraction(p, q) for p in range(-5, 6) for q in range(1, 6)]
    beam: List[Tuple[float, EMLNode]] = []
    
    for r in rats:
        node = make_rat(float(r))
        err = abs(node.eval() - target)
        if err < tolerance:
            return node
        beam.append((err, node))
    
    beam.sort(key=lambda x: x[0])
    beam = beam[:50]
    
    for depth in range(1, max_depth + 1):
        new_candidates = []
        for _, expr in beam:
            # Try exp
            try:
                e = make_exp(expr)
                v = e.eval()
                if not math.isinf(v) and not math.isnan(v):
                    err = abs(v - target)
                    if err < tolerance:
                        return e
                    new_candidates.append((err, e))
            except (OverflowError, ValueError):
                pass
            
            # Try log
            try:
                l = make_log(expr)
                v = l.eval()
                if not math.isinf(v) and not math.isnan(v):
                    err = abs(v - target)
                    if err < tolerance:
                        return l
                    new_candidates.append((err, l))
            except (OverflowError, ValueError):
                pass
        
        new_candidates.sort(key=lambda x: x[0])
        beam = new_candidates[:50]
    
    return beam[0][1] if beam else None


if __name__ == "__main__":
    print("=== EML Expression Analysis ===\n")
    
    # Demo: canonical constants
    e_expr = make_exp(make_rat(1))
    ee_expr = make_exp(make_exp(make_rat(1)))
    log2_expr = make_log(make_rat(2))
    target_expr = make_add(ee_expr, log2_expr)
    
    for name, expr in [
        ("e", e_expr),
        ("e^e", ee_expr),
        ("log 2", log2_expr),
        ("e^e + log 2", target_expr),
    ]:
        print(f"{name}:")
        print(f"  value = {expr.eval():.15f}")
        print(f"  depth = {expr.depth()}")
        print(f"  size  = {expr.size()}")
        print(f"  transc_weight = {expr.transc_weight()}")
        print(f"  tower_level = {assign_tower_level(expr)}")
        print()
    
    print("=== Schanuel N=1 Verification ===\n")
    for alpha in [1.0, math.log(2), math.e, math.pi]:
        result = verify_schanuel_n1(alpha)
        print(f"α = {alpha:.6f}: {result['note']}")
    
    print("\n=== Algebraic Independence Tests ===\n")
    test_sets = [
        ("e, e^e", [math.e, math.exp(math.e)]),
        ("e, π", [math.e, math.pi]),
        ("e, log 2", [math.e, math.log(2)]),
        ("√2, √3", [math.sqrt(2), math.sqrt(3)]),
    ]
    for name, vals in test_sets:
        indep, relation = numerical_algebraic_independence_test(vals, max_degree=4)
        status = "likely independent" if indep else f"relation found: {relation}"
        print(f"{{{name}}}: {status}")

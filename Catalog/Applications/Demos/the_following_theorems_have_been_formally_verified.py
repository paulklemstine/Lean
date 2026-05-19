#!/usr/bin/env python3
"""
applications.py — Real-world applications of ordinal tree compilation.

Demonstrates how ordinal-indexed trees arise in:
1. Termination proofs for recursive programs
2. Complexity classification of rewrite systems
3. Well-founded recursion depth measurement
"""

from __future__ import annotations
from typing import List, Tuple, Optional
from algorithms import CNFOrdinal, compile_cnf, fundamental_sequence


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 1: Termination Analysis via Ordinal Ranking
# ═══════════════════════════════════════════════════════════════════════

class TerminationAnalyzer:
    """Analyze termination of recursive programs using ordinal ranking functions.
    
    For a recursive function with k nested loops/recursions, the termination
    complexity can be bounded by an ordinal in CNF. The tree realization
    provides a concrete witness that the recursion is well-founded.
    
    Example: A function with triple-nested recursion where:
    - Outer loop decreases a counter bounded by n
    - Middle loop resets to ω at each outer step
    - Inner loop is bounded by m
    has termination ordinal ω^2·n + ω·m or similar.
    """
    
    @staticmethod
    def analyze_simple_loop(bound: int) -> CNFOrdinal:
        """Simple loop: for i in range(bound). Terminates in ≤ bound steps.
        
        Termination ordinal: bound (finite).
        """
        return CNFOrdinal.finite(bound)
    
    @staticmethod 
    def analyze_nested_loop(outer: int, inner: int) -> CNFOrdinal:
        """Nested loop: outer loop bound × inner loop bound.
        
        Termination ordinal: outer * inner (still finite).
        """
        return CNFOrdinal.finite(outer * inner)
    
    @staticmethod
    def analyze_recursive_descent(depth: int) -> CNFOrdinal:
        """Recursive function that decreases an ordinal argument.
        
        Example: Ackermann-like function with recursion depth bounded by ω^depth.
        """
        return CNFOrdinal.omega_power(depth)
    
    @staticmethod
    def analyze_multi_level_recursion(levels: List[Tuple[int, int]]) -> CNFOrdinal:
        """Multi-level recursion with different nesting depths.
        
        levels: [(count, depth), ...] where each level has 'count' recursive
        calls at nesting 'depth'.
        
        Returns the termination ordinal in CNF.
        """
        return CNFOrdinal.from_cnf_list(levels)


def demo_termination():
    """Demonstrate termination analysis."""
    print("=" * 65)
    print("APPLICATION 1: Termination Analysis")
    print("=" * 65)
    print()
    
    analyzer = TerminationAnalyzer()
    
    # Simple examples
    programs = [
        ("Simple counter loop (n=100)", 
         analyzer.analyze_simple_loop(100)),
        ("Nested loop (10 × 20)", 
         analyzer.analyze_nested_loop(10, 20)),
        ("Single recursive descent",
         analyzer.analyze_recursive_descent(1)),
        ("Double recursive descent (Ackermann-like)",
         analyzer.analyze_recursive_descent(2)),
        ("Triple recursive descent",
         analyzer.analyze_recursive_descent(3)),
        ("Multi-level: 2×ω³ + 3×ω + 5 iterations",
         analyzer.analyze_multi_level_recursion([(2, 3), (3, 1), (5, 0)])),
    ]
    
    for desc, ordinal in programs:
        tree = compile_cnf([(c, e) for e, c in ordinal.terms] if ordinal.terms else [])
        print(f"  {desc}")
        print(f"    Termination ordinal: {ordinal}")
        print(f"    Tree realization: {tree}")
        print(f"    Is finite? {ordinal.is_finite()}")
        print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 2: Rewrite System Complexity Classification
# ═══════════════════════════════════════════════════════════════════════

class RewriteSystem:
    """A simple term rewriting system with ordinal complexity measure.
    
    Each rewrite rule decreases the ordinal rank of the term.
    The maximum rank gives the worst-case number of rewrite steps.
    """
    
    def __init__(self, name: str, rules: List[str], complexity: CNFOrdinal):
        self.name = name
        self.rules = rules
        self.complexity = complexity
    
    def describe(self) -> str:
        lines = [f"  System: {self.name}"]
        lines.append(f"  Rules:")
        for rule in self.rules:
            lines.append(f"    {rule}")
        lines.append(f"  Complexity ordinal: {self.complexity}")
        lines.append(f"  Classification: {self._classify()}")
        return "\n".join(lines)
    
    def _classify(self) -> str:
        if self.complexity.is_finite():
            return "PRIMITIVE RECURSIVE (finite bound)"
        exp = self.complexity.leading_exponent()
        if exp == 1:
            return "MULTIPLY RECURSIVE (ω-level)"
        elif exp == 2:
            return "DOUBLY RECURSIVE (ω²-level)"
        elif exp < 10:
            return f"LEVEL-{exp} RECURSIVE (ω^{exp}-level)"
        else:
            return f"HIGHLY RECURSIVE (ω^{exp}-level)"


def demo_rewrite_systems():
    """Demonstrate complexity classification of rewrite systems."""
    print("=" * 65)
    print("APPLICATION 2: Rewrite System Complexity Classification")
    print("=" * 65)
    print()
    
    systems = [
        RewriteSystem(
            "Bubble Sort",
            ["swap(x,y) → (y,x) if x > y"],
            CNFOrdinal.finite(100)  # n² for n=10
        ),
        RewriteSystem(
            "String Rewriting (length-decreasing)",
            ["ab → a", "ba → b"],
            CNFOrdinal.omega_power(1)
        ),
        RewriteSystem(
            "Hydra Game (2-level)",
            ["cut head → grow k new heads at parent"],
            CNFOrdinal.omega_power(2)
        ),
        RewriteSystem(
            "Goodstein sequences (base-k)",
            ["subtract 1 in hereditary base-k, change to base-(k+1)"],
            CNFOrdinal.from_cnf_list([(1, 3)])
        ),
        RewriteSystem(
            "Extended rewrite with CNF bound",
            ["f(s(x),y) → f(x, g(y))", "g(s(x)) → g(x)·g(x)"],
            CNFOrdinal.from_cnf_list([(2, 3), (1, 1), (5, 0)])
        ),
    ]
    
    for system in systems:
        print(system.describe())
        print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 3: Hierarchical Complexity Measure
# ═══════════════════════════════════════════════════════════════════════

def complexity_hierarchy():
    """Show how ordinals create a natural complexity hierarchy."""
    print("=" * 65)
    print("APPLICATION 3: Ordinal Complexity Hierarchy")
    print("=" * 65)
    print()
    print("  Each ordinal α defines a complexity class C(α):")
    print("  C(α) = functions whose recursion depth is bounded by α")
    print()
    
    levels = [
        (CNFOrdinal.finite(1), "Constant-time operations"),
        (CNFOrdinal.finite(10), "Bounded iteration (≤10 steps)"),
        (CNFOrdinal.omega_power(1), "Primitive recursive (single recursion)"),
        (CNFOrdinal.from_cnf_list([(2, 1)]), "Double recursion (ω·2 steps)"),
        (CNFOrdinal.omega_power(2), "Doubly nested recursion (ω² steps)"),
        (CNFOrdinal.omega_power(3), "Triply nested recursion (ω³ steps)"),
        (CNFOrdinal.from_cnf_list([(1, 3), (2, 1), (5, 0)]),
         "Mixed: ω³ + ω·2 + 5 step bound"),
    ]
    
    print("  ┌──────────────────┬────────────────────────────────────────┐")
    print("  │  Ordinal         │  Complexity Class                      │")
    print("  ├──────────────────┼────────────────────────────────────────┤")
    for ordinal, desc in levels:
        ord_str = str(ordinal).ljust(16)
        print(f"  │  {ord_str}│  {desc.ljust(38)}│")
    print("  └──────────────────┴────────────────────────────────────────┘")
    print()
    print("  KEY THEOREM: Every ordinal in this hierarchy is realized by")
    print("  a concrete tree, providing a WITNESS for the complexity bound.")
    print()
    print("  The ordinal ω^ω serves as the boundary of this classification:")
    print("  it is the supremum of all finite-exponent complexity levels.")
    print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 4: Fundamental Sequence Enumeration
# ═══════════════════════════════════════════════════════════════════════

def demo_fundamental_sequences():
    """Show how fundamental sequences provide constructive access to limits."""
    print("=" * 65)
    print("APPLICATION 4: Fundamental Sequences — Constructive Limits")
    print("=" * 65)
    print()
    print("  Every limit ordinal α has a fundamental sequence α[0] < α[1] < ...")
    print("  with sup{α[n]} = α. This gives constructive access to limits.")
    print()
    
    examples = [
        ("ω", CNFOrdinal.omega_power(1)),
        ("ω·2", CNFOrdinal.from_cnf_list([(2, 1)])),
        ("ω²", CNFOrdinal.omega_power(2)),
        ("ω² + ω", CNFOrdinal.from_cnf_list([(1, 2), (1, 1)])),
        ("ω³", CNFOrdinal.omega_power(3)),
    ]
    
    for name, alpha in examples:
        print(f"  {name}[n]:")
        for n in range(6):
            try:
                val = fundamental_sequence(alpha, n)
                print(f"    [{n}] = {val}")
            except ValueError:
                print(f"    [{n}] = (not a limit ordinal)")
                break
        print()
    
    print("  In tree terms: the child tree at index n of a limit-ordinal")
    print("  tree has rank α[n], providing a concrete witness for each")
    print("  approximation stage.")
    print()


if __name__ == "__main__":
    demo_termination()
    demo_rewrite_systems()
    complexity_hierarchy()
    demo_fundamental_sequences()


#!/usr/bin/env python3
"""
demo.py — Concrete demonstrations of Cantor Normal Form realizability
and ordinal tree constructions.

Shows how infinite-branching trees encode ordinals via their rank function,
and demonstrates the CNF-to-tree compilation pipeline.
"""

from __future__ import annotations
import sys
sys.setrecursionlimit(5000)

# ─── Symbolic ordinal arithmetic ──────────────────────────────────────
# We work symbolically since actual tree ranks are transfinite ordinals.

class Ordinal:
    """Symbolic ordinal in Cantor normal form below ω^ω.
    
    Represented as a list of (coefficient, exponent) pairs in strictly
    descending exponent order, with positive coefficients.
    CNF: a_k·ω^{n_k} + ... + a_1·ω^{n_1} + a_0·ω^{n_0}
    """
    def __init__(self, terms=None):
        # terms: list of (coeff, exp) with exp strictly decreasing, coeff > 0
        self.terms = terms or []
    
    @staticmethod
    def zero():
        return Ordinal([])
    
    @staticmethod
    def finite(n: int):
        if n == 0:
            return Ordinal.zero()
        return Ordinal([(n, 0)])
    
    @staticmethod
    def omega_pow(n: int, coeff: int = 1):
        if coeff == 0:
            return Ordinal.zero()
        return Ordinal([(coeff, n)])
    
    @staticmethod
    def from_cnf(terms: list):
        """Create from [(coeff, exp), ...] in descending exp order."""
        return Ordinal([(c, e) for c, e in terms if c > 0])
    
    def __repr__(self):
        if not self.terms:
            return "0"
        parts = []
        for coeff, exp in self.terms:
            if exp == 0:
                parts.append(str(coeff))
            elif exp == 1:
                if coeff == 1:
                    parts.append("ω")
                else:
                    parts.append(f"ω·{coeff}")
            else:
                if coeff == 1:
                    parts.append(f"ω^{exp}")
                else:
                    parts.append(f"ω^{exp}·{coeff}")
        return " + ".join(parts)
    
    def __eq__(self, other):
        if not isinstance(other, Ordinal):
            return False
        return self.terms == other.terms
    
    def add(self, other: 'Ordinal') -> 'Ordinal':
        """Ordinal addition (not commutative!).
        self + other: other's high terms absorb self's low terms."""
        if not other.terms:
            return self
        if not self.terms:
            return other
        # Find the highest exponent in other
        other_max_exp = other.terms[0][1]
        # Keep only terms from self with exponent > other_max_exp
        kept = [(c, e) for c, e in self.terms if e > other_max_exp]
        # If self has a term with same exponent as other's leading term, add coefficients
        self_same = [(c, e) for c, e in self.terms if e == other_max_exp]
        if self_same:
            new_coeff = self_same[0][0] + other.terms[0][0]
            result = kept + [(new_coeff, other_max_exp)] + other.terms[1:]
        else:
            result = kept + other.terms
        return Ordinal(result)
    
    def mul_nat(self, k: int) -> 'Ordinal':
        """Multiply by natural number k (on the right).
        α·k = α + α + ... + α (k times)."""
        if k == 0 or not self.terms:
            return Ordinal.zero()
        if k == 1:
            return self
        # ω^n · a · k: the leading term's coefficient gets multiplied
        # Lower terms are absorbed if leading exp > 0
        lead_coeff, lead_exp = self.terms[0]
        if lead_exp == 0:
            # Finite ordinal * k
            return Ordinal.finite(lead_coeff * k)
        # For ω^n·a + lower: (ω^n·a + lower)·k = ω^n·(a·k) 
        # because lower terms get absorbed by the next copy's ω^n
        return Ordinal([(lead_coeff * k, lead_exp)])


def cnf_value(terms: list) -> Ordinal:
    """Compute the ordinal value of a CNF list [(coeff, exp), ...]."""
    result = Ordinal.zero()
    # Process from right to left (lowest terms first)
    for coeff, exp in reversed(terms):
        term = Ordinal.omega_pow(exp).mul_nat(coeff)
        result = term.add(result)
    return result


# ─── Demonstrations ───────────────────────────────────────────────────

def demo_finite_ordinals():
    """Demonstrate finite ordinal realization."""
    print("=" * 65)
    print("DEMO 1: Finite ordinals via chain trees")
    print("=" * 65)
    print()
    print("  chain(n) = node(fun _ => chain(n-1)), with chain(0) = leaf")
    print("  rank(chain(n)) = n")
    print()
    for n in range(8):
        print(f"  chain({n}): rank = {Ordinal.finite(n)}")
    print()


def demo_ordinal_addition():
    """Demonstrate ordinal addition via prepend."""
    print("=" * 65)
    print("DEMO 2: Ordinal addition via prepend")
    print("=" * 65)
    print()
    print("  THEOREM: rank(prepend(s, t)) = rank(s) + rank(t)")
    print()
    
    examples = [
        ("chain(3)", "chain(4)", Ordinal.finite(3), Ordinal.finite(4)),
        ("chain(0)", "chain(5)", Ordinal.finite(0), Ordinal.finite(5)),
        ("omegaPowTree(1)", "chain(3)", Ordinal.omega_pow(1), Ordinal.finite(3)),
        ("omegaPowTree(2)", "omegaPowTree(1)", Ordinal.omega_pow(2), Ordinal.omega_pow(1)),
    ]
    for s_name, t_name, s_rank, t_rank in examples:
        result = s_rank.add(t_rank)
        print(f"  prepend({s_name}, {t_name})")
        print(f"    rank = {s_rank} + {t_rank} = {result}")
        print()


def demo_ordinal_multiplication():
    """Demonstrate ordinal multiplication by naturals."""
    print("=" * 65)
    print("DEMO 3: Ordinal multiplication via mulByNat")
    print("=" * 65)
    print()
    print("  THEOREM: rank(mulByNat(t, k)) = rank(t) * k")
    print()
    
    examples = [
        ("chain(3)", 4, Ordinal.finite(3)),
        ("omegaPowTree(1)", 5, Ordinal.omega_pow(1)),
        ("omegaPowTree(2)", 3, Ordinal.omega_pow(2)),
        ("omegaPowTree(3)", 2, Ordinal.omega_pow(3)),
    ]
    for t_name, k, t_rank in examples:
        result = t_rank.mul_nat(k)
        print(f"  mulByNat({t_name}, {k})")
        print(f"    rank = {t_rank} * {k} = {result}")
        print()


def demo_omega_powers():
    """Demonstrate ω^n tree construction."""
    print("=" * 65)
    print("DEMO 4: Ordinal power trees — omegaPowTree(n) has rank ω^n")
    print("=" * 65)
    print()
    print("  THEOREM: rank(omegaPowTree(n)) = ω^n")
    print()
    print("  Construction:")
    print("    omegaPowTree(0) = node(fun _ => leaf)        rank = 1 = ω^0")
    print("    omegaPowTree(n+1) = node(fun k => mulByNat(omegaPowTree(n), k))")
    print()
    
    for n in range(7):
        rank = Ordinal.omega_pow(n)
        print(f"  omegaPowTree({n}): rank = {rank}")
        if n <= 3:
            print(f"    Children: ", end="")
            child_ranks = []
            for k in range(5):
                cr = Ordinal.omega_pow(n - 1).mul_nat(k) if n > 0 else Ordinal.finite(0)
                child_ranks.append(str(cr))
            print(", ".join(child_ranks) + ", ...")
    print()


def demo_cnf():
    """Demonstrate CNF tree construction."""
    print("=" * 65)
    print("DEMO 5: Cantor Normal Form realizability")
    print("=" * 65)
    print()
    print("  THEOREM: rank(cnfTree(L)) = cnfValue(L) for ALL lists L")
    print()
    print("  cnfValue([(a₁,n₁), (a₂,n₂), ...]) = ω^n₁·a₁ + ω^n₂·a₂ + ...")
    print()
    
    examples = [
        [(2, 3), (5, 2), (3, 1), (7, 0)],
        [(1, 2), (1, 0)],
        [(42, 1)],
        [(1, 5)],
        [(17, 0)],
        [(3, 4), (1, 2), (2, 1)],
        [(1, 3), (1, 2), (1, 1), (1, 0)],
    ]
    
    for terms in examples:
        val = cnf_value(terms)
        print(f"  cnfTree({terms})")
        print(f"    rank = {val}")
        print()


def demo_omega_to_omega():
    """Demonstrate the ω^ω tree."""
    print("=" * 65)
    print("DEMO 6: The ω^ω tree — first limit-stage realization")
    print("=" * 65)
    print()
    print("  THEOREM: rank(omegaToOmegaTree) = ω^ω")
    print()
    print("  omegaToOmegaTree = node(fun n => omegaPowTree(n))")
    print()
    print("  Children enumerate the entire ω^n hierarchy:")
    for n in range(8):
        print(f"    child[{n}] = omegaPowTree({n}), rank = {Ordinal.omega_pow(n)}")
    print(f"    ...")
    print()
    print("  rank = sup{{ω^0, ω^1, ω^2, ω^3, ...}} = ω^ω")
    print()
    print("  This is the FIRST true limit-stage object:")
    print("  • Not a successor of any previously realized ordinal")
    print("  • Requires infinitely many construction stages to enumerate")
    print("  • Demonstrates transfinite convergence of tree complexity")
    print()


def demo_coverage_map():
    """Show the complete ordinal coverage below ω^ω."""
    print("=" * 65)
    print("DEMO 7: Complete ordinal coverage below ω^ω")
    print("=" * 65)
    print()
    print("  Every ordinal below ω^ω has a unique Cantor Normal Form:")
    print("    α = ω^{n_k}·a_k + ω^{n_{k-1}}·a_{k-1} + ... + ω^{n_0}·a_0")
    print("  where n_k > n_{k-1} > ... > n_0 and all a_i > 0.")
    print()
    print("  Our construction provides a TREE for each such ordinal:")
    print()
    print("  ┌────────────────────────────────────────────────────────┐")
    print("  │  Ordinal                │  Tree Constructor            │")
    print("  ├────────────────────────────────────────────────────────┤")
    print("  │  0                      │  leaf                        │")
    print("  │  n (finite)             │  cnfTree([(n,0)])            │")
    print("  │  ω                      │  omegaPowTree(1)             │")
    print("  │  ω·k + m               │  cnfTree([(k,1),(m,0)])      │")
    print("  │  ω²                     │  omegaPowTree(2)             │")
    print("  │  ω²·a + ω·b + c        │  cnfTree([(a,2),(b,1),(c,0)])│")
    print("  │  ω^n                    │  omegaPowTree(n)             │")
    print("  │  general CNF            │  cnfTree(terms)              │")
    print("  │  ω^ω                    │  omegaToOmegaTree            │")
    print("  └────────────────────────────────────────────────────────┘")
    print()
    print("  KEY INSIGHT: The tree calculus is not merely representing")
    print("  isolated ordinals — it provides a complete NOTATION SYSTEM")
    print("  for all ordinals in the initial segment [0, ω^ω].")
    print()


if __name__ == "__main__":
    demo_finite_ordinals()
    demo_ordinal_addition()
    demo_ordinal_multiplication()
    demo_omega_powers()
    demo_cnf()
    demo_omega_to_omega()
    demo_coverage_map()

#!/usr/bin/env python3
"""
Algorithms for Automated Transfer Discovery

Implements the definability analysis and transfer pipeline algorithms
described in the research paper.
"""

from dataclasses import dataclass, field
from typing import List, Optional, Tuple, Set, Dict
from enum import Enum, auto
import time


# ============================================================
# Algorithm 1: Definability Analysis Engine
# ============================================================

class FormulaType(Enum):
    POLY_EQ = auto()
    CONJ = auto()
    DISJ = auto()
    NEG = auto()


@dataclass
class Formula:
    """Restricted polynomial formula."""
    kind: FormulaType
    poly: str = ""
    children: List['Formula'] = field(default_factory=list)

    def complexity(self) -> int:
        if self.kind == FormulaType.POLY_EQ:
            return 1
        return 1 + sum(c.complexity() for c in self.children)

    def depth(self) -> int:
        if self.kind == FormulaType.POLY_EQ:
            return 0
        return 1 + max(c.depth() for c in self.children)

    def atom_count(self) -> int:
        if self.kind == FormulaType.POLY_EQ:
            return 1
        return sum(c.atom_count() for c in self.children)

    def neg_count(self) -> int:
        if self.kind == FormulaType.POLY_EQ:
            return 0
        base = sum(c.neg_count() for c in self.children)
        return (1 + base) if self.kind == FormulaType.NEG else base


@dataclass
class DefinabilityResult:
    """Result of definability analysis."""
    is_definable: bool
    formula: Optional[Formula] = None
    complexity: int = 0
    transfer_steps: List[str] = field(default_factory=list)


class DefinabilityAnalyzer:
    """
    Definability Analysis Engine

    Analyzes whether a predicate is expressible as a restricted polynomial
    formula and computes the transfer cost.

    Algorithm:
    1. Parse the predicate into an AST
    2. Attempt to decompose into polynomial equality atoms
    3. Build the restricted formula via boolean composition
    4. Compute complexity and transfer cost

    Time complexity: O(n) where n is the size of the predicate AST
    Space complexity: O(n) for the formula tree
    """

    def __init__(self):
        self.known_atoms: Dict[str, Formula] = {}
        self.analysis_log: List[str] = []

    def register_atom(self, name: str, polynomial: str) -> None:
        """Register a known polynomial equality atom."""
        self.known_atoms[name] = Formula(FormulaType.POLY_EQ, poly=polynomial)
        self.analysis_log.append(f"Registered atom: {name} ↔ ({polynomial} = 0)")

    def analyze(self, predicate: str) -> DefinabilityResult:
        """
        Analyze whether a predicate is definable by a restricted formula.

        Args:
            predicate: A string representation of the predicate using
                      registered atom names and boolean connectives
                      (AND, OR, NOT, IMPLIES)

        Returns:
            DefinabilityResult with the formula if definable

        Algorithm:
            1. Tokenize the predicate string
            2. Parse into an expression tree
            3. Check each leaf against registered atoms
            4. Build the restricted formula bottom-up
            5. Compute complexity metrics
        """
        tokens = self._tokenize(predicate)
        formula, steps = self._parse(tokens)

        if formula is None:
            return DefinabilityResult(is_definable=False, transfer_steps=steps)

        return DefinabilityResult(
            is_definable=True,
            formula=formula,
            complexity=formula.complexity(),
            transfer_steps=steps
        )

    def _tokenize(self, s: str) -> List[str]:
        """Tokenize a predicate string."""
        tokens = []
        current = ""
        for c in s:
            if c in "()":
                if current.strip():
                    tokens.append(current.strip())
                    current = ""
                tokens.append(c)
            elif c == " ":
                if current.strip():
                    tokens.append(current.strip())
                    current = ""
            else:
                current += c
        if current.strip():
            tokens.append(current.strip())
        return tokens

    def _parse(self, tokens: List[str]) -> Tuple[Optional[Formula], List[str]]:
        """Parse tokens into a formula."""
        steps = []

        # Simple recursive descent parser
        pos = [0]

        def parse_expr() -> Optional[Formula]:
            left = parse_unary()
            if left is None:
                return None

            while pos[0] < len(tokens) and tokens[pos[0]] in ("AND", "OR", "IMPLIES"):
                op = tokens[pos[0]]
                pos[0] += 1
                right = parse_unary()
                if right is None:
                    return None

                if op == "AND":
                    left = Formula(FormulaType.CONJ, children=[left, right])
                    steps.append(f"Apply conjunction: complexity {left.complexity()}")
                elif op == "OR":
                    left = Formula(FormulaType.DISJ, children=[left, right])
                    steps.append(f"Apply disjunction: complexity {left.complexity()}")
                elif op == "IMPLIES":
                    # P → Q = ¬P ∨ Q
                    neg_left = Formula(FormulaType.NEG, children=[left])
                    left = Formula(FormulaType.DISJ, children=[neg_left, right])
                    steps.append(f"Apply implication (¬P ∨ Q): complexity {left.complexity()}")

            return left

        def parse_unary() -> Optional[Formula]:
            if pos[0] < len(tokens) and tokens[pos[0]] == "NOT":
                pos[0] += 1
                inner = parse_unary()
                if inner is None:
                    return None
                f = Formula(FormulaType.NEG, children=[inner])
                steps.append(f"Apply negation: complexity {f.complexity()}")
                return f
            return parse_atom()

        def parse_atom() -> Optional[Formula]:
            if pos[0] >= len(tokens):
                return None

            if tokens[pos[0]] == "(":
                pos[0] += 1
                result = parse_expr()
                if pos[0] < len(tokens) and tokens[pos[0]] == ")":
                    pos[0] += 1
                return result

            name = tokens[pos[0]]
            pos[0] += 1

            if name in self.known_atoms:
                steps.append(f"Atom '{name}': polynomial equality")
                return Formula(FormulaType.POLY_EQ, poly=self.known_atoms[name].poly)
            else:
                steps.append(f"ERROR: '{name}' is not a known definable predicate")
                return None

        formula = parse_expr()
        return formula, steps

    def transfer_cost(self, result: DefinabilityResult) -> Dict[str, int]:
        """
        Compute the cost of executing the transfer for a definable predicate.

        Returns a dictionary with:
        - total_steps: Total number of Łoś theorem applications
        - poly_eval_steps: Number of polynomial evaluation lemma applications
        - boolean_steps: Number of boolean closure lemma applications
        """
        if not result.is_definable or result.formula is None:
            return {"total_steps": 0, "poly_eval_steps": 0, "boolean_steps": 0}

        f = result.formula
        atoms = f.atom_count()
        negs = f.neg_count()
        conj_disj = f.complexity() - atoms - negs

        return {
            "total_steps": f.complexity(),
            "poly_eval_steps": atoms,
            "boolean_steps": conj_disj + negs
        }


# ============================================================
# Algorithm 2: Transfer Pipeline
# ============================================================

@dataclass
class TransferResult:
    """Result of executing a transfer."""
    success: bool
    source_theorem: str
    transferred_theorem: str
    proof_steps: List[str]
    complexity: int


class TransferPipeline:
    """
    Automated Transfer Pipeline

    Executes the three-phase transfer:
    1. Definability analysis
    2. Complexity bounding
    3. Transfer execution (via Łoś theorem)

    Time complexity: O(c) where c is the formula complexity
    Space complexity: O(c) for the proof term
    """

    def __init__(self):
        self.analyzer = DefinabilityAnalyzer()
        self.history: List[TransferResult] = []

    def register_predicate(self, name: str, polynomial: str) -> None:
        """Register a polynomial equality predicate."""
        self.analyzer.register_atom(name, polynomial)

    def execute_transfer(self, source: str, predicate_expr: str) -> TransferResult:
        """
        Execute the full transfer pipeline.

        Args:
            source: Description of the finite theorem
            predicate_expr: The predicate expression to transfer

        Returns:
            TransferResult with the proof steps
        """
        # Phase 1: Definability analysis
        result = self.analyzer.analyze(predicate_expr)

        if not result.is_definable:
            return TransferResult(
                success=False,
                source_theorem=source,
                transferred_theorem="",
                proof_steps=["Definability analysis failed"] + result.transfer_steps,
                complexity=0
            )

        # Phase 2: Complexity bounding
        cost = self.analyzer.transfer_cost(result)

        # Phase 3: Transfer execution (simulation)
        proof_steps = [
            f"Phase 1: Definability analysis — formula has complexity {result.complexity}",
            f"Phase 2: Cost estimate — {cost['total_steps']} total steps",
            f"  - {cost['poly_eval_steps']} polynomial evaluation lemma applications",
            f"  - {cost['boolean_steps']} boolean closure lemma applications",
            "Phase 3: Transfer execution via Łoś theorem",
        ]
        proof_steps.extend(f"  Step: {s}" for s in result.transfer_steps)
        proof_steps.append("Transfer complete ✓")

        transferred = f"[Pseudofinite] {source}"

        tr = TransferResult(
            success=True,
            source_theorem=source,
            transferred_theorem=transferred,
            proof_steps=proof_steps,
            complexity=result.complexity
        )
        self.history.append(tr)
        return tr

    def chain_transfer(self, sources: List[Tuple[str, str]]) -> TransferResult:
        """
        Execute a chain of transfers: P₁ → P₂ → ... → Pₙ.

        Each (source, expr) pair is transferred individually, then
        the chain composition theorem is applied.
        """
        results = []
        for source, expr in sources:
            r = self.execute_transfer(source, expr)
            results.append(r)

        all_success = all(r.success for r in results)
        total_complexity = sum(r.complexity for r in results)

        chain_steps = [f"Chain of {len(sources)} transfers:"]
        for i, r in enumerate(results):
            status = "✓" if r.success else "✗"
            chain_steps.append(f"  Link {i+1}: {r.source_theorem} [{status}]")

        if all_success:
            chain_steps.append(f"Apply transfer_chain_{len(sources)} theorem")
            chain_steps.append(f"Total complexity: {total_complexity}")

        return TransferResult(
            success=all_success,
            source_theorem=" → ".join(s for s, _ in sources),
            transferred_theorem=f"[Chain Transfer] {sources[-1][0]}" if all_success else "",
            proof_steps=chain_steps,
            complexity=total_complexity
        )


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Transfer Pipeline Demo")
    print("=" * 60)

    pipeline = TransferPipeline()

    # Register some predicates
    pipeline.register_predicate("Pythagorean", "a^2+b^2-c^2")
    pipeline.register_predicate("Primitive", "gcd(a,b)-1")
    pipeline.register_predicate("BoundedDoubling", "card(AA)-K*card(A)")
    pipeline.register_predicate("CosetControl", "card(T)-C")

    # Single transfer
    print("\n--- Single Transfer ---")
    r1 = pipeline.execute_transfer(
        "Finite Pythagorean Theorem",
        "Pythagorean AND Primitive"
    )
    print(f"Success: {r1.success}")
    print(f"Complexity: {r1.complexity}")
    for step in r1.proof_steps:
        print(f"  {step}")

    # Implication transfer
    print("\n--- Implication Transfer ---")
    r2 = pipeline.execute_transfer(
        "Growth-Control Dichotomy",
        "BoundedDoubling IMPLIES CosetControl"
    )
    print(f"Success: {r2.success}")
    print(f"Complexity: {r2.complexity}")
    for step in r2.proof_steps:
        print(f"  {step}")

    # Chain transfer
    print("\n--- Chain Transfer ---")
    r3 = pipeline.chain_transfer([
        ("Bounded Doubling", "BoundedDoubling"),
        ("Growth Control", "BoundedDoubling IMPLIES CosetControl"),
        ("Structural Result", "CosetControl"),
    ])
    print(f"Success: {r3.success}")
    for step in r3.proof_steps:
        print(f"  {step}")

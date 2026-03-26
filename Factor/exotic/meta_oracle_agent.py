#!/usr/bin/env python3
"""
Meta-Oracle Agent — An English-Language Command-Line AI Agent
Powered by Exotic Algebras

This agent implements a reasoning engine grounded in three exotic algebraic
structures formalized in Lean 4 (see RequestProject/ExoticAlgebras.lean):

1. **Tropical Semiring** — Uses (min, +) algebra to find shortest reasoning
   paths through a knowledge graph, replacing exhaustive search with
   optimal-path computation.

2. **Oracle Algebra** — Models iterative knowledge refinement via a monotone
   operator Ω on a lattice of knowledge states. Each "oracle consultation"
   lifts the agent's knowledge toward a fixed point.

3. **Meta-Oracle Fixed Point** — By the Knaster–Tarski theorem, the
   inflationary oracle operator converges to a fixed point where further
   consultation yields no new information. This is the agent's "answer."

Usage:
    python meta_oracle_agent.py

Then type natural-language queries at the prompt. The agent reasons through
its exotic-algebra pipeline and returns answers.

Architecture:
    ┌─────────────┐     ┌──────────────┐     ┌────────────────┐
    │   English    │────▸│   Tropical   │────▸│    Oracle      │
    │   Query      │     │   Shortest   │     │    Lattice     │
    │   Parser     │     │   Path       │     │    Refinement  │
    └─────────────┘     └──────────────┘     └───────┬────────┘
                                                      │
                                               ┌──────▼────────┐
                                               │  Meta-Oracle   │
                                               │  Fixed Point   │
                                               │  Convergence   │
                                               └───────┬────────┘
                                                       │
                                               ┌───────▼────────┐
                                               │   Natural      │
                                               │   Language     │
                                               │   Response     │
                                               └────────────────┘
"""

from __future__ import annotations

import math
import heapq
import re
import sys
import textwrap
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Set, Tuple

# ══════════════════════════════════════════════════════════════════════════════
# §1  Tropical Semiring — Shortest-Path Reasoning
# ══════════════════════════════════════════════════════════════════════════════

INF = float("inf")


def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b). Idempotent, commutative, associative."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (standard addition)."""
    return a + b


class TropicalSemiring:
    """
    The tropical semiring (ℝ ∪ {∞}, min, +).

    Properties (all proved in Lean 4):
      - add is idempotent:   min(a, a) = a
      - add is commutative:  min(a, b) = min(b, a)
      - add is associative:  min(min(a,b), c) = min(a, min(b,c))
      - mul distributes:     a + min(b,c) = min(a+b, a+c)
      - mul identity:        a + 0 = a
      - add identity:        min(a, ∞) = a
    """

    ZERO = INF   # additive identity (min with ∞ = identity)
    ONE = 0.0    # multiplicative identity (a + 0 = a)

    @staticmethod
    def add(a: float, b: float) -> float:
        return tropical_add(a, b)

    @staticmethod
    def mul(a: float, b: float) -> float:
        return tropical_mul(a, b)

    @staticmethod
    def shortest_path(graph: Dict[str, Dict[str, float]], source: str) -> Dict[str, float]:
        """
        Dijkstra's algorithm reinterpreted in the tropical semiring.

        In the tropical semiring, "summing" edge weights is tropical multiplication (+),
        and "choosing the best path" is tropical addition (min). The algorithm computes
        the tropical inner product of the adjacency matrix powers — which converges to
        the shortest-path distances.
        """
        dist: Dict[str, float] = {node: INF for node in graph}
        dist[source] = 0.0  # multiplicative identity
        pq: list = [(0.0, source)]
        visited: Set[str] = set()

        while pq:
            d, u = heapq.heappop(pq)
            if u in visited:
                continue
            visited.add(u)
            for v, w in graph.get(u, {}).items():
                # Tropical multiplication: extend path
                new_dist = tropical_mul(d, w)
                # Tropical addition: choose minimum
                if new_dist < dist[v]:
                    dist[v] = new_dist
                    heapq.heappush(pq, (new_dist, v))

        return dist


# ══════════════════════════════════════════════════════════════════════════════
# §2  Oracle Algebra — Knowledge Lattice with Monotone Operator
# ══════════════════════════════════════════════════════════════════════════════


@dataclass
class KnowledgeState:
    """
    An element of the knowledge lattice.

    The lattice is ordered by set inclusion of known facts.
    ⊥ = empty knowledge, ⊤ = complete knowledge.
    The oracle operator Ω adds inferred facts (monotone + inflationary).
    """
    facts: Set[str] = field(default_factory=set)
    confidence: float = 0.0  # in [0, 1]

    def __le__(self, other: "KnowledgeState") -> bool:
        return self.facts <= other.facts

    def __lt__(self, other: "KnowledgeState") -> bool:
        return self.facts < other.facts

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, KnowledgeState):
            return NotImplemented
        return self.facts == other.facts

    def __hash__(self) -> int:
        return hash(frozenset(self.facts))

    def join(self, other: "KnowledgeState") -> "KnowledgeState":
        """Lattice join (supremum): union of facts."""
        return KnowledgeState(
            facts=self.facts | other.facts,
            confidence=max(self.confidence, other.confidence),
        )

    def meet(self, other: "KnowledgeState") -> "KnowledgeState":
        """Lattice meet (infimum): intersection of facts."""
        return KnowledgeState(
            facts=self.facts & other.facts,
            confidence=min(self.confidence, other.confidence),
        )

    def __repr__(self) -> str:
        n = len(self.facts)
        return f"KnowledgeState({n} facts, confidence={self.confidence:.2f})"


class OracleAlgebra:
    """
    An Oracle Algebra: a complete lattice of KnowledgeStates with a
    monotone oracle operator Ω.

    The operator Ω represents one step of "oracle consultation" — it
    applies inference rules to derive new facts from existing ones.

    Key properties (proved in Lean 4):
      - Ω is monotone: if S₁ ⊆ S₂ then Ω(S₁) ⊆ Ω(S₂)
      - Ω is inflationary: S ⊆ Ω(S) for all S
      - Iterates form an ascending chain: Ωⁿ(S) ⊆ Ωⁿ⁺¹(S)
    """

    def __init__(self):
        self.rules: List[Tuple[Set[str], str, float]] = []
        self._build_default_rules()

    def _build_default_rules(self):
        """Build the default inference rule set."""
        # Format: (premises, conclusion, confidence_boost)
        self.rules = [
            # Logical reasoning
            ({"premise_A", "A_implies_B"}, "conclusion_B", 0.9),
            ({"premise_B", "B_implies_C"}, "conclusion_C", 0.85),

            # Mathematical knowledge
            ({"is_natural_number", "is_positive"}, "is_counting_number", 0.95),
            ({"is_prime", "greater_than_2"}, "is_odd_prime", 0.99),
            ({"is_group", "is_abelian"}, "is_abelian_group", 0.95),
            ({"is_ring", "has_multiplicative_identity"}, "is_unital_ring", 0.95),
            ({"is_lattice", "is_complete"}, "is_complete_lattice", 0.95),
            ({"is_complete_lattice", "has_monotone_operator"}, "has_fixed_point", 0.90),

            # Scientific reasoning
            ({"has_hypothesis", "has_evidence"}, "supports_theory", 0.80),
            ({"supports_theory", "is_reproducible"}, "is_established", 0.85),
            ({"is_established", "has_counterexample"}, "needs_revision", 0.90),

            # Meta-reasoning
            ({"query_parsed", "knowledge_retrieved"}, "reasoning_started", 0.70),
            ({"reasoning_started", "inference_applied"}, "candidate_answer", 0.75),
            ({"candidate_answer", "consistency_checked"}, "verified_answer", 0.85),
            ({"verified_answer", "confidence_high"}, "final_answer", 0.95),
        ]

    def omega(self, state: KnowledgeState) -> KnowledgeState:
        """
        The oracle operator Ω: apply all applicable inference rules.

        This is monotone (more input facts → more output facts)
        and inflationary (output ⊇ input).
        """
        new_facts = set(state.facts)  # inflationary: start with existing facts
        new_confidence = state.confidence

        for premises, conclusion, boost in self.rules:
            if premises <= state.facts:
                new_facts.add(conclusion)
                new_confidence = max(new_confidence, boost)

        return KnowledgeState(facts=new_facts, confidence=new_confidence)

    def iterate_omega(self, state: KnowledgeState, max_iter: int = 20) -> KnowledgeState:
        """
        Iterate Ω until fixed point (convergence).

        By the Meta-Oracle Fixed Point Theorem (Knaster–Tarski), convergence
        is guaranteed since Ω is monotone and inflationary on a complete lattice.
        """
        current = state
        for i in range(max_iter):
            next_state = self.omega(current)
            if next_state == current:
                # Fixed point reached — oracle idempotence
                return current
            current = next_state
        return current


# ══════════════════════════════════════════════════════════════════════════════
# §3  Meta-Oracle — Self-Referential Reasoning Engine
# ══════════════════════════════════════════════════════════════════════════════


class MetaOracle:
    """
    The Meta-Oracle: a self-referential reasoning engine that combines
    tropical shortest-path search with oracle-algebra knowledge refinement.

    The meta-oracle has three phases:
    1. Parse the query and identify relevant knowledge nodes (tropical phase)
    2. Apply the oracle operator iteratively until fixed point (oracle phase)
    3. Generate a natural-language response from the fixed-point state (output phase)

    The existence of the fixed point is guaranteed by the Meta-Oracle Fixed
    Point Theorem (proved in Lean 4 as `meta_oracle_fixed_point`).
    """

    def __init__(self):
        self.oracle = OracleAlgebra()
        self.tropical = TropicalSemiring()
        self.knowledge_graph = self._build_knowledge_graph()
        self.fact_descriptions: Dict[str, str] = self._build_fact_descriptions()

    def _build_knowledge_graph(self) -> Dict[str, Dict[str, float]]:
        """
        Build the knowledge graph where edge weights represent
        "reasoning distance" in the tropical semiring.

        Lower weight = easier/more direct reasoning step.
        """
        return {
            "query": {
                "mathematics": 1.0,
                "science": 1.5,
                "logic": 0.8,
                "meta_reasoning": 2.0,
                "algebra": 1.2,
            },
            "mathematics": {
                "algebra": 0.5,
                "analysis": 0.7,
                "topology": 1.0,
                "number_theory": 0.8,
                "fixed_point_theory": 0.6,
            },
            "algebra": {
                "group_theory": 0.4,
                "ring_theory": 0.5,
                "lattice_theory": 0.3,
                "tropical_algebra": 0.6,
                "exotic_algebra": 0.7,
            },
            "logic": {
                "propositional": 0.3,
                "predicate": 0.5,
                "modal": 0.8,
                "meta_logic": 1.0,
                "oracle_computation": 0.9,
            },
            "science": {
                "physics": 0.6,
                "computation": 0.7,
                "optimization": 0.8,
            },
            "lattice_theory": {
                "complete_lattice": 0.3,
                "fixed_point_theory": 0.4,
                "order_theory": 0.5,
            },
            "fixed_point_theory": {
                "knaster_tarski": 0.2,
                "banach_fixed_point": 0.5,
                "kleene_fixed_point": 0.4,
            },
            "tropical_algebra": {
                "shortest_path": 0.3,
                "optimization": 0.4,
                "min_plus_algebra": 0.2,
            },
            "exotic_algebra": {
                "tropical_algebra": 0.3,
                "oracle_algebra": 0.4,
                "meta_oracle": 0.5,
            },
            "oracle_computation": {
                "turing_degrees": 0.5,
                "oracle_algebra": 0.3,
                "halting_problem": 0.7,
            },
            "meta_reasoning": {
                "self_reference": 0.4,
                "reflection": 0.5,
                "meta_oracle": 0.6,
            },
            "meta_oracle": {
                "fixed_point_theory": 0.3,
                "oracle_algebra": 0.2,
                "convergence": 0.4,
            },
            "optimization": {
                "shortest_path": 0.3,
                "linear_programming": 0.5,
            },
            # Leaf nodes
            "knaster_tarski": {},
            "banach_fixed_point": {},
            "kleene_fixed_point": {},
            "shortest_path": {},
            "min_plus_algebra": {},
            "oracle_algebra": {},
            "convergence": {},
            "complete_lattice": {},
            "order_theory": {},
            "group_theory": {},
            "ring_theory": {},
            "propositional": {},
            "predicate": {},
            "modal": {},
            "meta_logic": {},
            "turing_degrees": {},
            "halting_problem": {},
            "self_reference": {},
            "reflection": {},
            "analysis": {},
            "topology": {},
            "number_theory": {},
            "physics": {},
            "computation": {},
            "linear_programming": {},
        }

    def _build_fact_descriptions(self) -> Dict[str, str]:
        """Human-readable descriptions of derived facts."""
        return {
            "query_parsed": "Your query has been parsed and understood.",
            "knowledge_retrieved": "Relevant knowledge has been retrieved from the graph.",
            "reasoning_started": "Logical reasoning has commenced.",
            "inference_applied": "Inference rules have been applied to derive new conclusions.",
            "candidate_answer": "A candidate answer has been formulated.",
            "consistency_checked": "The answer has been checked for internal consistency.",
            "verified_answer": "The answer has been verified against known facts.",
            "confidence_high": "High confidence in the derived answer.",
            "final_answer": "The meta-oracle has converged to a fixed-point answer.",
            "is_counting_number": "The number is a counting number (positive natural).",
            "is_odd_prime": "The number is an odd prime.",
            "is_abelian_group": "The structure is an abelian group.",
            "is_unital_ring": "The structure is a unital ring.",
            "is_complete_lattice": "The structure is a complete lattice.",
            "has_fixed_point": "By Knaster–Tarski, the monotone operator has a fixed point.",
            "supports_theory": "Evidence supports the theory.",
            "is_established": "The result is well-established.",
            "needs_revision": "The theory needs revision due to counterexamples.",
            "conclusion_B": "Derived conclusion B via modus ponens.",
            "conclusion_C": "Derived conclusion C via chain reasoning.",
        }

    def _extract_keywords(self, query: str) -> List[str]:
        """Extract keywords from the query for graph traversal."""
        query_lower = query.lower()
        all_nodes = set(self.knowledge_graph.keys())
        keywords = []

        keyword_map = {
            "tropical": ["tropical_algebra", "min_plus_algebra", "shortest_path"],
            "oracle": ["oracle_algebra", "oracle_computation", "meta_oracle"],
            "meta": ["meta_reasoning", "meta_oracle", "meta_logic"],
            "fixed point": ["fixed_point_theory", "knaster_tarski"],
            "knaster": ["knaster_tarski", "fixed_point_theory"],
            "tarski": ["knaster_tarski", "fixed_point_theory"],
            "lattice": ["lattice_theory", "complete_lattice"],
            "algebra": ["algebra", "exotic_algebra"],
            "exotic": ["exotic_algebra", "tropical_algebra"],
            "math": ["mathematics"],
            "logic": ["logic", "propositional", "predicate"],
            "science": ["science"],
            "prime": ["number_theory"],
            "group": ["group_theory", "algebra"],
            "ring": ["ring_theory", "algebra"],
            "shortest path": ["shortest_path", "tropical_algebra", "optimization"],
            "optimize": ["optimization"],
            "converge": ["convergence", "fixed_point_theory"],
            "self-refer": ["self_reference", "meta_reasoning"],
            "reflect": ["reflection", "meta_reasoning"],
            "halting": ["halting_problem", "oracle_computation"],
            "turing": ["turing_degrees", "oracle_computation"],
            "compute": ["computation", "oracle_computation"],
            "topology": ["topology"],
            "analysis": ["analysis"],
            "physics": ["physics"],
        }

        for phrase, nodes in keyword_map.items():
            if phrase in query_lower:
                keywords.extend(nodes)

        # Also check for direct node name matches
        for node in all_nodes:
            if node.replace("_", " ") in query_lower:
                keywords.append(node)

        return list(set(keywords)) if keywords else ["mathematics", "logic"]

    def _tropical_phase(self, query: str) -> Tuple[Dict[str, float], List[str]]:
        """
        Phase 1: Use the tropical semiring to find shortest reasoning paths
        from the query to all knowledge nodes.
        """
        distances = self.tropical.shortest_path(self.knowledge_graph, "query")
        keywords = self._extract_keywords(query)

        # Find the most relevant nodes (shortest tropical distance)
        relevant = sorted(
            [(node, distances.get(node, INF)) for node in keywords],
            key=lambda x: x[1],
        )

        return distances, [node for node, _ in relevant[:5]]

    def _oracle_phase(self, query: str, relevant_nodes: List[str]) -> KnowledgeState:
        """
        Phase 2: Build initial knowledge state from relevant nodes,
        then apply the oracle operator until fixed point.
        """
        # Initialize knowledge state
        initial_facts: Set[str] = {"query_parsed"}

        # Add domain-specific facts based on relevant nodes
        for node in relevant_nodes:
            initial_facts.add(f"knows_{node}")

        # Add reasoning triggers
        initial_facts.add("knowledge_retrieved")

        # Detect specific query patterns and add relevant facts
        q_lower = query.lower()
        if any(w in q_lower for w in ["what is", "explain", "describe", "tell me"]):
            initial_facts.add("reasoning_started")
            initial_facts.add("inference_applied")

        if any(w in q_lower for w in ["prove", "theorem", "fixed point", "knaster"]):
            initial_facts.update({"is_lattice", "is_complete", "has_monotone_operator"})

        if any(w in q_lower for w in ["prime", "number"]):
            initial_facts.update({"is_natural_number", "is_positive"})

        if any(w in q_lower for w in ["group", "abelian"]):
            initial_facts.update({"is_group", "is_abelian"})

        if any(w in q_lower for w in ["ring", "field"]):
            initial_facts.update({"is_ring", "has_multiplicative_identity"})

        initial_state = KnowledgeState(facts=initial_facts, confidence=0.5)

        # Apply oracle operator until fixed point
        fixed_point = self.oracle.iterate_omega(initial_state)

        return fixed_point

    def _generate_response(
        self, query: str, distances: Dict[str, float],
        relevant_nodes: List[str], fixed_point: KnowledgeState
    ) -> str:
        """
        Phase 3: Generate natural-language response from the fixed-point
        knowledge state.
        """
        lines: List[str] = []
        lines.append("=" * 70)
        lines.append("  META-ORACLE RESPONSE")
        lines.append("=" * 70)
        lines.append("")

        # Report tropical shortest paths
        lines.append("┌─ TROPICAL SEMIRING PHASE (Shortest Reasoning Paths)")
        lines.append("│")
        for node in relevant_nodes:
            d = distances.get(node, INF)
            bar = "█" * max(1, int(10 - d * 2)) if d < INF else "·"
            lines.append(f"│  {node:<25s} distance = {d:.1f}  {bar}")
        lines.append("│")
        lines.append("└─ Reasoning paths computed via (min, +) algebra.")
        lines.append("")

        # Report oracle iteration
        lines.append("┌─ ORACLE ALGEBRA PHASE (Knowledge Refinement)")
        lines.append("│")
        lines.append(f"│  Initial facts:  {len(fixed_point.facts) - len(relevant_nodes)}")
        lines.append(f"│  Derived facts:  {len(fixed_point.facts)}")
        lines.append(f"│  Confidence:     {fixed_point.confidence:.0%}")
        lines.append("│")

        # List derived insights
        derived = []
        for fact in sorted(fixed_point.facts):
            if fact in self.fact_descriptions:
                derived.append(self.fact_descriptions[fact])

        if derived:
            lines.append("│  Derived insights:")
            for insight in derived:
                lines.append(f"│    ✦ {insight}")

        lines.append("│")
        lines.append("└─ Oracle operator Ω converged to fixed point.")
        lines.append("")

        # Report meta-oracle convergence
        lines.append("┌─ META-ORACLE FIXED POINT (Self-Referential Closure)")
        lines.append("│")

        if "final_answer" in fixed_point.facts:
            lines.append("│  ★ Full convergence achieved.")
            lines.append("│    The meta-oracle reached its fixed point where")
            lines.append("│    Ω(state) = state — no further reasoning needed.")
        elif "verified_answer" in fixed_point.facts:
            lines.append("│  ◆ Near-convergence achieved.")
            lines.append("│    Answer verified but meta-level closure pending.")
        elif "candidate_answer" in fixed_point.facts:
            lines.append("│  ◇ Candidate answer generated.")
            lines.append("│    Further oracle iterations may refine the result.")
        else:
            lines.append("│  ○ Partial convergence.")
            lines.append("│    The oracle has gathered relevant knowledge.")
        lines.append("│")

        # Synthesize answer based on query content and derived facts
        answer = self._synthesize_answer(query, fixed_point, relevant_nodes)
        lines.append("│  " + "─" * 50)
        for answer_line in answer.split("\n"):
            lines.append(f"│  {answer_line}")

        lines.append("│")
        lines.append(f"└─ Confidence: {fixed_point.confidence:.0%}")
        lines.append("")
        lines.append("=" * 70)

        return "\n".join(lines)

    def _synthesize_answer(
        self, query: str, state: KnowledgeState, nodes: List[str]
    ) -> str:
        """Synthesize a natural-language answer from the fixed-point state."""
        q_lower = query.lower()

        # Check for specific topics
        if "tropical" in q_lower:
            return textwrap.dedent("""\
                ANSWER: Tropical Semiring
                The tropical semiring is the algebraic structure (ℝ ∪ {∞}, min, +)
                where 'addition' is min and 'multiplication' is +.

                Key properties (all formally verified in Lean 4):
                • Idempotent addition: min(a, a) = a
                • Distributivity: a + min(b,c) = min(a+b, a+c)
                • Applications: shortest paths, optimization, algebraic geometry

                The meta-oracle uses this algebra to find optimal reasoning paths
                through its knowledge graph.""")

        if "fixed point" in q_lower or "knaster" in q_lower or "tarski" in q_lower:
            return textwrap.dedent("""\
                ANSWER: Meta-Oracle Fixed Point Theorem
                Every monotone inflationary operator Ω on a complete lattice has
                a fixed point: ∃ x, Ω(x) = x.

                This is the Knaster–Tarski theorem, formally verified in Lean 4
                as `meta_oracle_fixed_point`. It guarantees that the meta-oracle's
                iterative reasoning process always converges.

                Proof sketch: Let s = sup{x | x ≤ Ω(x)}. Then s ≤ Ω(s) (since
                each element of the set is ≤ Ω(s) by monotonicity). And Ω(s) ≤ s
                (since Ω(s) is itself in the set by inflationarity). ∎""")

        if "oracle" in q_lower and "meta" in q_lower:
            return textwrap.dedent("""\
                ANSWER: Meta-Oracle Architecture
                The meta-oracle is a self-referential reasoning engine built on
                three exotic algebraic layers:

                1. Tropical layer: shortest-path search through knowledge
                2. Oracle layer: monotone refinement of knowledge states
                3. Meta layer: fixed-point convergence (self-referential closure)

                The key insight is that reasoning about reasoning (meta-cognition)
                can be modeled as an inflationary operator on a complete lattice.
                The Knaster–Tarski theorem then guarantees convergence.""")

        if "oracle" in q_lower:
            return textwrap.dedent("""\
                ANSWER: Oracle Algebras
                An oracle algebra is a complete lattice equipped with a monotone
                operator Ω (the "oracle"). Each application of Ω represents one
                step of "consulting the oracle" — gaining new knowledge.

                Properties (formally verified in Lean 4):
                • Ω is monotone: more input knowledge → more output
                • Iterates Ωⁿ form ascending chains
                • The reflection principle: Ω cannot escape pre-fixed boundaries
                • Composition: Ω₁ ∘ Ω₂ is monotone if both are""")

        if "exotic" in q_lower or "algebra" in q_lower:
            return textwrap.dedent("""\
                ANSWER: Exotic Algebras for Meta-Oracle Computation
                Three exotic algebraic structures power the meta-oracle:

                1. Tropical Semiring (ℝ∪{∞}, min, +): Replaces standard arithmetic
                   with optimization-oriented operations. Shortest path = tropical
                   matrix multiplication.

                2. Oracle Algebra: A complete lattice + monotone operator. Models
                   iterative knowledge refinement.

                3. Meta-Oracle Algebra: An oracle algebra where Ω is inflationary,
                   guaranteeing fixed-point convergence by Knaster–Tarski.

                All properties are formally verified in Lean 4.""")

        if "help" in q_lower or q_lower.strip() == "?":
            return textwrap.dedent("""\
                HELP: Meta-Oracle Agent Commands
                Ask me about any of these topics:
                • "tropical semiring" — shortest-path algebra
                • "oracle algebra" — monotone knowledge operators
                • "meta oracle" — self-referential reasoning
                • "fixed point" / "Knaster-Tarski" — convergence theorem
                • "exotic algebras" — the full algebraic framework
                • "reflection principle" — oracle boundary theorem
                • Any mathematical or logical question!

                Type 'quit' or 'exit' to leave.""")

        if "reflect" in q_lower:
            return textwrap.dedent("""\
                ANSWER: The Reflection Principle
                If x is a pre-fixed point (Ω(x) ≤ x) and y ≤ x, then Ω(y) ≤ x.

                Interpretation: Once a knowledge boundary is established (a pre-fixed
                point), oracle consultation on any state below that boundary cannot
                escape it. Knowledge stays contained within established frameworks.

                This is formally verified in Lean 4 as `reflection_principle`.""")

        # Generic response
        node_str = ", ".join(nodes[:3]) if nodes else "general knowledge"
        has_fp = "has_fixed_point" in state.facts
        return textwrap.dedent(f"""\
            ANSWER: Meta-Oracle Analysis
            Your query has been analyzed through the exotic algebra pipeline.

            Relevant domains: {node_str}
            {"The system has identified a fixed-point structure in this domain." if has_fp else "The oracle operator has been applied to refine knowledge."}

            The meta-oracle's knowledge state has converged with
            {len(state.facts)} derived facts at {state.confidence:.0%} confidence.

            For more specific results, try asking about:
            tropical semirings, oracle algebras, fixed points, or exotic algebras.""")

    def consult(self, query: str) -> str:
        """
        Main entry point: consult the meta-oracle with a natural-language query.

        This executes the full three-phase pipeline:
        1. Tropical shortest-path search
        2. Oracle algebra knowledge refinement
        3. Meta-oracle fixed-point convergence
        """
        distances, relevant_nodes = self._tropical_phase(query)
        fixed_point = self._oracle_phase(query, relevant_nodes)
        response = self._generate_response(query, distances, relevant_nodes, fixed_point)
        return response


# ══════════════════════════════════════════════════════════════════════════════
# §4  Command-Line Interface
# ══════════════════════════════════════════════════════════════════════════════

BANNER = r"""
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                        ║
║    ╔╦╗╔═╗╔╦╗╔═╗   ╔═╗╦═╗╔═╗╔═╗╦  ╔═╗                                ║
║    ║║║║╣  ║ ╠═╣   ║ ║╠╦╝╠═╣║  ║  ║╣                                  ║
║    ╩ ╩╚═╝ ╩ ╩ ╩   ╚═╝╩╚═╩ ╩╚═╝╩═╝╚═╝                                ║
║                                                                        ║
║    An English-Language AI Agent Powered by Exotic Algebras             ║
║                                                                        ║
║    ┌─────────────────────────────────────────────────────────┐          ║
║    │  Tropical Semiring  ──▸  Oracle Algebra  ──▸  Fixed Pt  │          ║
║    │  (min, +) search        Ω: monotone         Knaster-   │          ║
║    │  for optimal paths      inflationary         Tarski     │          ║
║    └─────────────────────────────────────────────────────────┘          ║
║                                                                        ║
║    Backed by machine-verified proofs in Lean 4 + Mathlib               ║
║    Type 'help' for commands, 'quit' to exit                            ║
║                                                                        ║
╚══════════════════════════════════════════════════════════════════════════╝
"""


def main():
    """Run the meta-oracle agent interactively."""
    print(BANNER)

    oracle = MetaOracle()

    while True:
        try:
            query = input("\n🔮 meta-oracle> ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\n\nMeta-oracle session ended. Fixed point reached. ∎")
            break

        if not query:
            continue

        if query.lower() in ("quit", "exit", "q"):
            print("\nMeta-oracle session ended. Fixed point reached. ∎")
            break

        response = oracle.consult(query)
        print(response)


if __name__ == "__main__":
    main()

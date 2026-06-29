#!/usr/bin/env python3
"""
Coalgebraic Temporal Adjunction — Algorithms

Implements the core algorithms from the research:
1. Coalgebraic predicate transformer computation
2. Cylinder predicate evaluation on finite Kripke structures
3. EX/AX model checking via the Galois connection
"""

from typing import Callable, Dict, FrozenSet, List, Optional, Set, Tuple


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Coalgebraic Predicate Transformers
# ─────────────────────────────────────────────────────────────────────

class CoalgebraicTransformer:
    """
    Implements the coalgebraic predicate transformers ◇_a, □_a, pre_a
    on finite state spaces.

    Time complexity: O(|states| × |transitions|) per transformer application
    Space complexity: O(|states|)

    These transformers form the adjunction triple:
        ◇_a ⊣ pre_a ⊣ □_a
    """

    def __init__(self, states: List[int], transitions: List[Tuple[int, int]]):
        """
        Initialize with a Kripke structure.

        Args:
            states: List of state identifiers
            transitions: List of (source, target) pairs
        """
        self.states = set(states)
        self.succ: Dict[int, Set[int]] = {s: set() for s in states}
        self.pred: Dict[int, Set[int]] = {s: set() for s in states}
        for s, t in transitions:
            self.succ[s].add(t)
            self.pred[t].add(s)

    def EX(self, P: Set[int]) -> Set[int]:
        """
        Existential next: EX(P) = {s | ∃t. s→t ∧ t∈P}

        Time: O(Σ_{s∈states} |succ(s)|) = O(|transitions|)
        """
        return {s for s in self.states if self.succ[s] & P}

    def AX(self, P: Set[int]) -> Set[int]:
        """
        Universal next: AX(P) = {s | ∀t. s→t → t∈P}

        Time: O(|transitions|)
        """
        return {s for s in self.states if self.succ[s] <= P}

    def backward_AX(self, Q: Set[int]) -> Set[int]:
        """
        Backward universal: backwardAX(Q) = {t | ∀s. s→t → s∈Q}

        This is the right adjoint to EX in the Galois connection:
            EX(P) ⊆ Q  ↔  P ⊆ backwardAX(Q)

        Time: O(|transitions|)
        """
        return {t for t in self.states if self.pred[t] <= Q}

    def verify_galois_connection(self, P: Set[int], Q: Set[int]) -> bool:
        """
        Verify the Galois connection EX(P) ⊆ Q ↔ P ⊆ backwardAX(Q).

        Returns True if both sides agree.
        """
        lhs = self.EX(P) <= Q
        rhs = P <= self.backward_AX(Q)
        return lhs == rhs

    def verify_demorgan(self, P: Set[int]) -> bool:
        """
        Verify De Morgan duality: AX(P) = states \ EX(states \ P)
        """
        complement_P = self.states - P
        return self.AX(P) == self.states - self.EX(complement_P)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Cylinder Predicate Evaluation
# ─────────────────────────────────────────────────────────────────────

class CylinderEvaluator:
    """
    Evaluates cylinder predicates on finite streams/traces.

    A cylinder predicate Cyl(w, U) holds on stream s iff:
    - s starts with prefix w, AND
    - the tail after |w| steps satisfies U

    The key theorem: ◇_a(Cyl(w,U)) = Cyl(a::w, U)

    Time complexity: O(|w|) per evaluation
    Space complexity: O(|w|)
    """

    @staticmethod
    def matches_prefix(w: List[int], s: List[int]) -> bool:
        """Check if stream s starts with prefix w."""
        if len(s) < len(w):
            return False
        return s[:len(w)] == w

    @staticmethod
    def evaluate_cylinder(w: List[int], U: Callable[[List[int]], bool],
                          s: List[int]) -> bool:
        """
        Evaluate Cyl(w, U)(s) = matchesPrefix(w, s) ∧ U(drop(|w|, s))
        """
        if len(s) < len(w):
            return False
        return s[:len(w)] == w and U(s[len(w):])

    @staticmethod
    def diamond_cylinder(a: int, w: List[int], U: Callable[[List[int]], bool],
                         s: List[int]) -> bool:
        """
        Evaluate ◇_a(Cyl(w, U))(s).

        By the cylinder compatibility theorem, this equals Cyl(a::w, U)(s).
        We compute BOTH and verify they agree.
        """
        # Direct diamond computation
        direct = (len(s) > 0 and s[0] == a and
                  CylinderEvaluator.evaluate_cylinder(w, U, s[1:]))
        # Via cylinder compatibility theorem
        theorem = CylinderEvaluator.evaluate_cylinder([a] + w, U, s)

        assert direct == theorem, (
            f"Cylinder compatibility VIOLATED: ◇_{a}(Cyl({w},U))({s}) = {direct} "
            f"but Cyl({[a]+w},U)({s}) = {theorem}"
        )
        return direct

    @staticmethod
    def box_cylinder(a: int, w: List[int], U: Callable[[List[int]], bool],
                     s: List[int]) -> bool:
        """
        Evaluate □_a(Cyl(w, U))(s).
        □_a P(s) = (head(s) = a → P(tail(s)))
        """
        if len(s) == 0 or s[0] != a:
            return True  # Vacuously true
        return CylinderEvaluator.evaluate_cylinder(w, U, s[1:])


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: One-Step CTL Model Checker
# ─────────────────────────────────────────────────────────────────────

class OneStepCTLChecker:
    """
    Model checker for one-step CTL formulas (EX, AX) using the
    coalgebraic adjunction framework.

    Given a Kripke structure K and a state predicate P:
    - Computes EX(P), AX(P)
    - Verifies the Galois connection
    - Checks De Morgan duality

    For a structure with n states and m transitions:
    Time complexity: O(m) per EX/AX evaluation
    Space complexity: O(n)
    """

    def __init__(self, states: List[int], transitions: List[Tuple[int, int]],
                 labeling: Optional[Dict[int, Set[str]]] = None):
        self.transformer = CoalgebraicTransformer(states, transitions)
        self.states = set(states)
        self.labeling = labeling or {}

    def check_EX(self, P: Set[int]) -> Set[int]:
        """States satisfying EX(P)."""
        return self.transformer.EX(P)

    def check_AX(self, P: Set[int]) -> Set[int]:
        """States satisfying AX(P)."""
        return self.transformer.AX(P)

    def full_verification(self) -> Dict[str, bool]:
        """
        Run full verification of all algebraic properties on the structure.

        Returns a dictionary of property names to verification results.
        """
        results = {}

        # Verify Galois connection for all predicate pairs
        galois_ok = True
        for P_mask in range(2**len(self.states)):
            P = {s for i, s in enumerate(sorted(self.states)) if (P_mask >> i) & 1}
            for Q_mask in range(2**len(self.states)):
                Q = {s for i, s in enumerate(sorted(self.states)) if (Q_mask >> i) & 1}
                if not self.transformer.verify_galois_connection(P, Q):
                    galois_ok = False
                    break
            if not galois_ok:
                break
        results["galois_connection"] = galois_ok

        # Verify De Morgan duality
        demorgan_ok = True
        for P_mask in range(2**len(self.states)):
            P = {s for i, s in enumerate(sorted(self.states)) if (P_mask >> i) & 1}
            if not self.transformer.verify_demorgan(P):
                demorgan_ok = False
                break
        results["demorgan_duality"] = demorgan_ok

        # Verify EX distributes over union
        ex_union_ok = True
        for P_mask in range(2**len(self.states)):
            P = {s for i, s in enumerate(sorted(self.states)) if (P_mask >> i) & 1}
            for Q_mask in range(2**len(self.states)):
                Q = {s for i, s in enumerate(sorted(self.states)) if (Q_mask >> i) & 1}
                if self.transformer.EX(P | Q) != self.transformer.EX(P) | self.transformer.EX(Q):
                    ex_union_ok = False
                    break
            if not ex_union_ok:
                break
        results["EX_distributes_union"] = ex_union_ok

        # Verify AX distributes over intersection
        ax_inter_ok = True
        for P_mask in range(2**len(self.states)):
            P = {s for i, s in enumerate(sorted(self.states)) if (P_mask >> i) & 1}
            for Q_mask in range(2**len(self.states)):
                Q = {s for i, s in enumerate(sorted(self.states)) if (Q_mask >> i) & 1}
                if self.transformer.AX(P & Q) != self.transformer.AX(P) & self.transformer.AX(Q):
                    ax_inter_ok = False
                    break
            if not ax_inter_ok:
                break
        results["AX_distributes_intersection"] = ax_inter_ok

        return results


# ─────────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm 1: Coalgebraic Predicate Transformers ===\n")
    ct = CoalgebraicTransformer([0, 1, 2, 3],
                                [(0,1), (0,2), (1,2), (2,3), (3,0)])
    P = {1, 2}
    print(f"States: {{0,1,2,3}}")
    print(f"Transitions: 0→1, 0→2, 1→2, 2→3, 3→0")
    print(f"P = {P}")
    print(f"EX(P) = {ct.EX(P)}")
    print(f"AX(P) = {ct.AX(P)}")
    print(f"backwardAX({{0,1}}) = {ct.backward_AX({0,1})}")

    print("\n=== Algorithm 2: Cylinder Evaluation ===\n")
    ce = CylinderEvaluator()
    w, a = [1, 0], 0
    U = lambda s: len(s) == 0 or s[0] == 1
    for s in [[0,1,0,1], [0,1,0,0], [1,1,0,1], [0,0,1,0]]:
        result = ce.diamond_cylinder(a, w, U, s)
        print(f"◇_{a}(Cyl({w},U))({s}) = {result}")

    print("\n=== Algorithm 3: One-Step CTL Model Checker ===\n")
    checker = OneStepCTLChecker([0, 1, 2], [(0,1), (0,2), (1,2), (2,0)])
    results = checker.full_verification()
    for prop, ok in results.items():
        print(f"  {prop}: {'✓' if ok else '✗'}")

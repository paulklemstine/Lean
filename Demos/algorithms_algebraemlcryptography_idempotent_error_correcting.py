#!/usr/bin/env python3
"""
Tropical Closure Coding Theory — Algorithms

Implements the key algorithms from the theory:
1. Closure computation (iterative implication saturation)
2. Syndrome computation
3. Tropical nearest-codeword decoder
4. Defect separation oracle
5. Minimum distance computation
"""

from typing import FrozenSet, List, Dict, Optional, Tuple, Set
from dataclasses import dataclass
from collections import defaultdict
import heapq


@dataclass(frozen=True)
class HornImplication:
    """A Horn implication: if all premises are present, conclusion must be present.

    In coding theory terms, this is a single parity constraint.
    """
    premise: FrozenSet[int]
    conclusion: int

    def __repr__(self):
        return f"{set(self.premise)} ⇒ {self.conclusion}"


class TropicalClosureCode:
    """A tropical closure code: finite closure system presented by Horn implications.

    This implements the full coding pipeline:
    - Encoding: verify that a set is a codeword (closed)
    - Syndrome computation: detect and quantify violations
    - Decoding: find the nearest codeword via closure
    - Defect separation: find separating violation functionals

    Time complexity:
    - Closure: O(n * m) where n = |ground|, m = |implications|
    - Syndrome: O(n * m)
    - Decoding: O(n * m) (same as closure)
    - All codewords: O(2^n * n * m) (brute force)

    Space complexity: O(n + m)
    """

    def __init__(self, ground: FrozenSet[int],
                 implications: List[HornImplication],
                 weights: Optional[Dict[int, int]] = None):
        self.ground = ground
        self.implications = implications
        self.weights = weights or {a: 1 for a in ground}
        self._validate()

    def _validate(self):
        """Validate that all implications reference elements in the ground set."""
        for imp in self.implications:
            assert imp.premise <= self.ground, \
                f"Premise {imp.premise} not subset of ground {self.ground}"
            assert imp.conclusion in self.ground, \
                f"Conclusion {imp.conclusion} not in ground {self.ground}"
        for a in self.ground:
            assert self.weights.get(a, 0) > 0, \
                f"Weight of {a} must be positive"

    # ─── Closure Computation ──────────────────────────────────────────

    def closure(self, x: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the closure of x by iterative implication saturation.

        Algorithm: Repeatedly scan all implications. For each implication
        A ⇒ b, if A ⊆ current and b ∉ current, add b.
        Terminate when no more elements are added.

        Complexity: O(n * m) where n = |ground|, m = |implications|.
        At most n iterations (one element added per iteration),
        each scanning m implications.
        """
        current = set(x)
        changed = True
        iterations = 0
        while changed:
            changed = False
            iterations += 1
            for imp in self.implications:
                if imp.premise <= current and imp.conclusion not in current:
                    current.add(imp.conclusion)
                    changed = True
        return frozenset(current)

    def is_codeword(self, x: FrozenSet[int]) -> bool:
        """Check if x is a codeword (closed set / fixed point of closure).

        Equivalent to: syndrome(x) == 0
        """
        return self.closure(x) == x

    # ─── Syndrome Computation ─────────────────────────────────────────

    def violation(self, imp: HornImplication, x: FrozenSet[int]) -> int:
        """Compute the violation of a single implication.

        Returns 1 if the premise is satisfied but conclusion is missing.
        Returns 0 otherwise.
        """
        return 1 if (imp.premise <= x and imp.conclusion not in x) else 0

    def syndrome(self, x: FrozenSet[int]) -> int:
        """Compute the total tropical syndrome.

        The syndrome is the sum of all violation indicators.
        By Theorem A: syndrome(x) = 0 ⟺ x is a codeword.
        """
        return sum(self.violation(imp, x) for imp in self.implications)

    def syndrome_vector(self, x: FrozenSet[int]) -> List[int]:
        """Compute the full syndrome vector (one entry per implication).

        This is the "tropical parity-check" output.
        """
        return [self.violation(imp, x) for imp in self.implications]

    # ─── Decoding ─────────────────────────────────────────────────────

    def decode(self, x: FrozenSet[int]) -> FrozenSet[int]:
        """Tropical nearest-codeword decoder.

        By Theorem B: decode(x) = closure(x) is the unique minimum-cost
        codeword in the insertion-only repair model.

        Returns the nearest codeword (closed set) to x.
        """
        return self.closure(x)

    def repair_cost(self, x: FrozenSet[int], y: FrozenSet[int]) -> int:
        """Compute the weighted insertion-only repair cost from x to y.

        Cost = sum of weights of elements in y \\ x.
        """
        return sum(self.weights[a] for a in y - x)

    def symm_repair_cost(self, x: FrozenSet[int], y: FrozenSet[int]) -> int:
        """Compute the symmetric repair cost (Hamming-style distance).

        Cost = sum of weights of elements in the symmetric difference.
        """
        sym_diff = (x - y) | (y - x)
        return sum(self.weights[a] for a in sym_diff)

    # ─── Defect Separation ────────────────────────────────────────────

    def separating_violations(self, x: FrozenSet[int]) -> List[Tuple[int, HornImplication]]:
        """Find all implications that separate x from the codeword space.

        By the Defect Separation Theorem: if x is not a codeword,
        at least one implication violates x while being satisfied by
        all codewords.

        Returns list of (index, implication) pairs.
        """
        result = []
        for i, imp in enumerate(self.implications):
            if self.violation(imp, x) > 0:
                result.append((i, imp))
        return result

    # ─── Enumeration ──────────────────────────────────────────────────

    def all_codewords(self) -> List[FrozenSet[int]]:
        """Enumerate all codewords (closed sets).

        Complexity: O(2^n * n * m).
        """
        from itertools import combinations
        elements = sorted(self.ground)
        n = len(elements)
        codewords = []
        for k in range(n + 1):
            for subset in combinations(elements, k):
                s = frozenset(subset)
                if self.is_codeword(s):
                    codewords.append(s)
        return codewords

    def minimum_distance(self) -> int:
        """Compute the minimum symmetric distance between distinct codewords.

        This is the coding-theoretic minimum distance of the closure code.
        """
        codewords = self.all_codewords()
        if len(codewords) < 2:
            return float('inf')
        min_dist = float('inf')
        for i in range(len(codewords)):
            for j in range(i + 1, len(codewords)):
                d = self.symm_repair_cost(codewords[i], codewords[j])
                min_dist = min(min_dist, d)
        return min_dist

    def rate(self) -> float:
        """Compute the code rate: log2(|codewords|) / |ground|."""
        import math
        codewords = self.all_codewords()
        if len(codewords) == 0:
            return 0.0
        return math.log2(len(codewords)) / len(self.ground)

    # ─── Pretty Printing ─────────────────────────────────────────────

    def summary(self) -> str:
        """Return a summary of the code parameters."""
        codewords = self.all_codewords()
        import math
        n = len(self.ground)
        k = len(codewords)
        d = self.minimum_distance()
        rate = math.log2(k) / n if k > 1 else 0
        return (f"[n={n}, |C|={k}, d={d}, rate={rate:.3f}] "
                f"with {len(self.implications)} implications")


class ClosureMorphism:
    """A closure-preserving map between two closure codes.

    By Theorem C, this induces a syndrome map and commutes with decoding.
    """

    def __init__(self, source: TropicalClosureCode,
                 target: TropicalClosureCode,
                 element_map: Dict[int, int]):
        self.source = source
        self.target = target
        self.element_map = element_map

    def map_set(self, x: FrozenSet[int]) -> FrozenSet[int]:
        """Map a set from source to target ground set."""
        return frozenset(self.element_map[a] for a in x if a in self.element_map)

    def apply(self, x: FrozenSet[int]) -> FrozenSet[int]:
        """Apply the morphism: map then close in the target."""
        return self.target.closure(self.map_set(x))

    def verify_naturality(self, x: FrozenSet[int]) -> bool:
        """Verify decode naturality: f(decode(x)) = decode(f(x))."""
        # f(decode_source(x))
        decoded_source = self.source.decode(x)
        f_decoded = self.apply(decoded_source)

        # decode_target(f(x))
        f_x = self.apply(x)
        decoded_f_x = self.target.decode(f_x)

        return f_decoded == decoded_f_x


# ─── Example Constructions ───────────────────────────────────────────────

def example_dependency_code(n: int = 6) -> TropicalClosureCode:
    """Construct a dependency closure code.

    Models software package dependencies: if package i is installed,
    its dependencies must also be installed.
    """
    ground = frozenset(range(n))
    # Chain dependencies: i ⇒ i+1 for even i
    implications = []
    for i in range(0, n - 1, 2):
        implications.append(HornImplication(frozenset([i]), i + 1))
    # Cross dependency: {0, 2} ⇒ n-1
    if n >= 3:
        implications.append(HornImplication(frozenset([0, 2]), n - 1))

    return TropicalClosureCode(ground, implications)


def example_knowledge_code() -> TropicalClosureCode:
    """Construct a knowledge/concept closure code.

    Models logical entailment in a knowledge base:
    knowing certain facts forces knowing others.
    """
    ground = frozenset(range(8))
    implications = [
        HornImplication(frozenset([0, 1]), 2),  # algebra + geometry ⇒ linear algebra
        HornImplication(frozenset([2]), 3),      # linear algebra ⇒ matrix theory
        HornImplication(frozenset([1, 4]), 5),  # geometry + topology ⇒ manifolds
        HornImplication(frozenset([3, 5]), 6),  # matrices + manifolds ⇒ diff geometry
        HornImplication(frozenset([2, 4]), 7),  # lin alg + topology ⇒ functional analysis
    ]
    return TropicalClosureCode(ground, implications)


if __name__ == "__main__":
    # Quick test
    code = example_dependency_code()
    print(f"Dependency code: {code.summary()}")
    print(f"Codewords: {[set(c) for c in code.all_codewords()]}")

    code2 = example_knowledge_code()
    print(f"\nKnowledge code: {code2.summary()}")
    print(f"Codewords: {len(code2.all_codewords())}")

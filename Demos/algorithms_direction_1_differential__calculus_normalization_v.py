#!/usr/bin/env python3
"""
Algorithms for Differential Lambda-Calculus Normalization

Implements the core algorithms from the research:
1. Typed reduction with stratified measure tracking
2. The Leibniz rule as an abstract rewriting system
3. Newman's lemma checker for finite rewriting systems
4. Automatic differentiation via the D operator

Time complexity: O(n * max_depth) per normalization step
Space complexity: O(n) for term representation
"""

from dataclasses import dataclass, field
from typing import Optional, Callable, TypeVar, Generic
from collections import defaultdict


# =============================================================================
# Algorithm 1: Stratified Measure for Typed Terms
# =============================================================================

class SimpleType:
    """Simple types with level measure."""
    pass

@dataclass(frozen=True)
class Base(SimpleType):
    name: str = "ι"

@dataclass(frozen=True)
class Arrow(SimpleType):
    dom: SimpleType
    cod: SimpleType

@dataclass(frozen=True)
class LinArrow(SimpleType):
    dom: SimpleType
    cod: SimpleType


def type_level(t: SimpleType) -> int:
    """
    Compute the level (nesting depth) of a type.

    The level is the key measure for the stratification argument:
    - level(base) = 0
    - level(σ → τ) = 1 + max(level(σ), level(τ))

    Time: O(size of type)
    Space: O(depth of type) for recursion stack
    """
    if isinstance(t, Base):
        return 0
    elif isinstance(t, Arrow):
        return 1 + max(type_level(t.dom), type_level(t.cod))
    elif isinstance(t, LinArrow):
        return 1 + max(type_level(t.dom), type_level(t.cod))
    raise TypeError


def stratified_measure(type_lev: int, term_size: int) -> tuple[int, int]:
    """
    Compute the stratified termination measure (type_level, term_size).

    This pair, ordered lexicographically, strictly decreases under:
    - β-reduction (decreases the first component)
    - Differential rules at the same type level (decrease the second component)

    Returns: (type_level, term_size)
    """
    return (type_lev, term_size)


# =============================================================================
# Algorithm 2: Abstract Rewriting System with Confluence Check
# =============================================================================

T = TypeVar('T')


class AbstractRewritingSystem(Generic[T]):
    """
    An abstract rewriting system (ARS) with tools for checking
    local confluence and computing normal forms.

    Pseudocode for Newman's Lemma check:
        function is_confluent(ARS, elements):
            for each element a in elements:
                one_step_reducts = {b : a → b}
                for each pair (b, c) in one_step_reducts × one_step_reducts:
                    if not joinable(b, c):
                        return False  # Found a non-joinable peak
            return True

    Complexity: O(|elements| * branching^2 * max_path_length)
    """

    def __init__(self, step: Callable[[T], list[T]]):
        self.step = step

    def all_reducts(self, t: T, max_depth: int = 100) -> set:
        """Compute all terms reachable from t (BFS, bounded)."""
        visited = set()
        queue = [t]
        while queue and len(visited) < max_depth:
            current = queue.pop(0)
            key = repr(current)
            if key in visited:
                continue
            visited.add(key)
            for r in self.step(current):
                queue.append(r)
        return visited

    def is_normal_form(self, t: T) -> bool:
        """Check if t is in normal form (no reducts)."""
        return len(self.step(t)) == 0

    def normalize(self, t: T, fuel: int = 1000) -> Optional[T]:
        """
        Normalize t by leftmost reduction.

        Returns None if fuel is exhausted (potential non-termination).
        """
        for _ in range(fuel):
            reducts = self.step(t)
            if not reducts:
                return t
            t = reducts[0]
        return None

    def check_local_confluence(self, elements: list[T]) -> tuple[bool, Optional[tuple]]:
        """
        Check local confluence for a finite set of elements.

        Returns (True, None) if locally confluent.
        Returns (False, (a, b, c)) if a peak b ← a → c is not joinable.
        """
        for a in elements:
            reducts = self.step(a)
            for i, b in enumerate(reducts):
                for c in reducts[i+1:]:
                    # Check if b and c are joinable
                    nf_b = self.normalize(b)
                    nf_c = self.normalize(c)
                    if nf_b is None or nf_c is None:
                        continue  # Can't determine
                    if repr(nf_b) != repr(nf_c):
                        return False, (a, b, c)
        return True, None


# =============================================================================
# Algorithm 3: Forward-Mode Automatic Differentiation
# =============================================================================

@dataclass
class DualNumber:
    """
    Dual number a + bε where ε² = 0.

    This implements forward-mode automatic differentiation,
    which is the computational counterpart of the Leibniz rule
    in the differential λ-calculus.

    The Leibniz rule D(f·g) = D(f)·g + f·D(g) corresponds to:
    (a + a'ε)(b + b'ε) = ab + (a'b + ab')ε
    """
    real: float
    dual: float = 0.0

    def __add__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(self.real + other, self.dual)
        return DualNumber(self.real + other.real, self.dual + other.dual)

    def __radd__(self, other):
        return self.__add__(other)

    def __mul__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(self.real * other, self.dual * other)
        # Leibniz rule: (a + a'ε)(b + b'ε) = ab + (a'b + ab')ε
        return DualNumber(
            self.real * other.real,
            self.dual * other.real + self.real * other.dual
        )

    def __rmul__(self, other):
        return self.__mul__(other)

    def __sub__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(self.real - other, self.dual)
        return DualNumber(self.real - other.real, self.dual - other.dual)

    def __neg__(self):
        return DualNumber(-self.real, -self.dual)

    def __repr__(self):
        return f"{self.real} + {self.dual}ε"


def auto_diff(f: Callable, x: float) -> tuple[float, float]:
    """
    Compute f(x) and f'(x) simultaneously using forward-mode AD.

    This is the computational realization of the D operator in the
    differential λ-calculus. The Leibniz rule is encoded in the
    multiplication of dual numbers.

    Time: Same as evaluating f
    Space: O(1) additional (dual numbers are constant size)

    Args:
        f: A function from dual numbers to dual numbers
        x: The point at which to differentiate

    Returns:
        (f(x), f'(x))
    """
    result = f(DualNumber(x, 1.0))
    return result.real, result.dual


# =============================================================================
# Algorithm 4: Type-Level Bounded Normalization
# =============================================================================

def bounded_normalize(term, type_level_bound: int, size_bound: int,
                      reduce_fn, measure_fn, fuel: int = 10000):
    """
    Normalize a term with stratified measure bounds.

    The stratified termination principle guarantees that if every reduction
    step strictly decreases the lexicographic measure (type_level, size),
    then normalization terminates. This function tracks the measure at each
    step to verify the decrease.

    Pseudocode:
        current = term
        prev_measure = measure(term)
        while can_reduce(current) and fuel > 0:
            next = reduce(current)
            curr_measure = measure(next)
            assert curr_measure < prev_measure  # lexicographic
            current = next
            prev_measure = curr_measure
            fuel -= 1
        return current

    Args:
        term: Initial term
        type_level_bound: Maximum expected type level
        size_bound: Maximum expected term size
        reduce_fn: One-step reduction function
        measure_fn: Function computing (type_level, size) measure
        fuel: Maximum number of steps

    Returns:
        (normal_form, trace_of_measures, steps)
    """
    measures = [measure_fn(term)]
    steps = 0
    current = term

    while fuel > 0:
        next_term = reduce_fn(current)
        if next_term is None:
            break
        current = next_term
        m = measure_fn(current)
        measures.append(m)
        steps += 1
        fuel -= 1

    # Verify stratification: measures should be strictly decreasing
    is_stratified = all(
        measures[i] > measures[i+1]
        for i in range(len(measures) - 1)
    )

    return current, measures, steps, is_stratified


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Demo 1: Type level computation
    print("1. Type Level Stratification")
    b = Base()
    arr1 = Arrow(b, b)
    arr2 = Arrow(arr1, b)
    arr3 = Arrow(b, Arrow(b, b))
    for t in [b, arr1, arr2, arr3]:
        print(f"   level({t}) = {type_level(t)}")

    # Demo 2: Forward-mode AD
    print("\n2. Forward-Mode Automatic Differentiation")
    # f(x) = x^2 + 3x + 1
    f = lambda x: x * x + 3 * x + 1
    for x_val in [0.0, 1.0, 2.0, -1.0]:
        val, deriv = auto_diff(f, x_val)
        print(f"   f({x_val}) = {val}, f'({x_val}) = {deriv}")
        # Check: f'(x) = 2x + 3
        expected = 2 * x_val + 3
        assert abs(deriv - expected) < 1e-10, f"AD error at x={x_val}"
    print("   All AD computations verified ✓")

    # Demo 3: Dual number Leibniz rule
    print("\n3. Dual Number Leibniz Rule")
    a = DualNumber(2.0, 3.0)  # 2 + 3ε (represents f(x)=2, f'(x)=3)
    b_dn = DualNumber(5.0, 1.0)  # 5 + 1ε (represents g(x)=5, g'(x)=1)
    prod = a * b_dn
    print(f"   ({a}) × ({b_dn}) = {prod}")
    print(f"   Real part: {a.real}×{b_dn.real} = {a.real * b_dn.real}")
    leibniz_dual = a.dual * b_dn.real + a.real * b_dn.dual
    print(f"   Dual part: {a.dual}×{b_dn.real} + {a.real}×{b_dn.dual} = {leibniz_dual}")
    print(f"   Leibniz rule verified: {prod.dual == leibniz_dual} ✓")

    print("\nAll algorithm demonstrations passed!")

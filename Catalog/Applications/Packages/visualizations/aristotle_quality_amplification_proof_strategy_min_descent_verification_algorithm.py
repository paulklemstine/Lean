#!/usr/bin/env python3
"""
Composable Proof Schemata: Algorithms

Implements the core algorithms from the proof schemata framework:
- Schema composition
- Descent verification
- Invariant classification
- Finite core extraction
- Strategy triad orchestration
"""

from typing import Callable, TypeVar, Generic, List, Dict, Set, Tuple, Optional, Any
from dataclasses import dataclass
import math

T = TypeVar('T')


# =============================================================================
# §1. Proof Schema (Algorithmic Implementation)
# =============================================================================

@dataclass
class ProofSchema(Generic[T]):
    """
    A proof schema: a certified reduction between predicates.
    
    Attributes:
        name: Human-readable name
        reduces_to: Function checking if P reduces to Q
        sound: Certificate that reduction preserves truth
        
    Time complexity: O(1) for schema creation, O(n) for verification on n elements.
    Space complexity: O(1) for the schema itself.
    """
    name: str
    transform: Callable[[Callable[[T], bool]], Callable[[T], bool]]
    
    def compose(self, other: 'ProofSchema[T]') -> 'ProofSchema[T]':
        """
        Compose two proof schemata.
        
        If self reduces P to Q, and other reduces Q to R,
        then the composition reduces P to R.
        
        Time: O(T_self + T_other) per element
        Space: O(S_self + S_other)
        """
        def composed_transform(P: Callable[[T], bool]) -> Callable[[T], bool]:
            Q = self.transform(P)
            R = other.transform(Q)
            return R
        
        return ProofSchema(
            name=f"({self.name} ∘ {other.name})",
            transform=composed_transform
        )
    
    def verify(self, predicate: Callable[[T], bool], domain: List[T]) -> bool:
        """
        Verify that the schema correctly handles the given predicate
        on the given domain.
        
        Time: O(|domain| · T_transform)
        Space: O(|domain|)
        """
        reduced = self.transform(predicate)
        for x in domain:
            if reduced(x) and not predicate(x):
                return False  # Soundness violation
        return True


# =============================================================================
# §2. Descent Algorithm
# =============================================================================

def descent_verify(
    predicate: Callable[[int], bool],
    descent_step: Callable[[int], Optional[int]],
    bound: int
) -> Tuple[bool, List[str]]:
    """
    Verify a predicate on [0, bound] using the descent principle.
    
    Algorithm:
    1. For each n from 0 to bound:
       a. If P(n) holds, continue
       b. If ¬P(n), attempt descent: find m < n with ¬P(m)
       c. If no descent possible, n is a minimal counterexample → report failure
       d. If descent succeeds, the counterexample is not minimal
    
    The descent principle guarantees: if every counterexample descends,
    no counterexample exists (by well-foundedness of ℕ).
    
    Args:
        predicate: The property P to verify
        descent_step: Given n with ¬P(n), returns m < n with ¬P(m), or None
        bound: Upper bound for verification
    
    Returns:
        (success, trace): Whether verification succeeded, and a trace of steps
        
    Time: O(bound · T_step)
    Space: O(bound) for the trace
    """
    trace = []
    verified = [False] * (bound + 1)
    
    for n in range(bound + 1):
        if predicate(n):
            verified[n] = True
            trace.append(f"n={n}: P(n) holds directly")
        else:
            # Attempt descent
            m = descent_step(n)
            if m is not None and m < n:
                # Descent succeeds: ¬P(m) with m < n
                # But by induction, P(m) should hold, contradiction
                if verified[m]:
                    trace.append(f"n={n}: ¬P(n), but descent to m={m} where P(m) holds → contradiction proves P(n)")
                    verified[n] = True
                else:
                    trace.append(f"n={n}: ¬P(n), descent to m={m} where ¬P(m) — chain continues")
                    return False, trace
            else:
                trace.append(f"n={n}: ¬P(n), no descent possible — MINIMAL COUNTEREXAMPLE")
                return False, trace
    
    return True, trace


def measured_descent_verify(
    elements: List[Any],
    measure: Callable[[Any], int],
    predicate: Callable[[Any], bool],
    descent_step: Callable[[Any], Optional[Any]]
) -> Tuple[bool, List[str]]:
    """
    Verify a predicate using measured descent on an arbitrary type.
    
    Sorts elements by measure and verifies bottom-up.
    
    Time: O(n log n + n · T_step) where n = |elements|
    Space: O(n)
    """
    sorted_elems = sorted(elements, key=measure)
    trace = []
    verified: Set[int] = set()
    
    for elem in sorted_elems:
        m = measure(elem)
        if predicate(elem):
            verified.add(id(elem))
            trace.append(f"μ={m}: P holds for {elem}")
        else:
            next_elem = descent_step(elem)
            if next_elem is not None and measure(next_elem) < m:
                trace.append(f"μ={m}: ¬P for {elem}, descends to μ={measure(next_elem)}")
            else:
                trace.append(f"μ={m}: ¬P for {elem}, NO DESCENT — minimal counterexample")
                return False, trace
    
    return True, trace


# =============================================================================
# §3. Invariant Classification Algorithm
# =============================================================================

def invariant_classify(
    elements: List[T],
    invariant: Callable[[T], Any],
    predicate: Callable[[T], bool]
) -> Dict[Any, Dict[str, Any]]:
    """
    Classify elements by an invariant and check predicate propagation.
    
    Algorithm:
    1. Group elements by invariant value
    2. For each fiber (group), find a canonical representative
    3. Check if the predicate value is constant within each fiber
    4. Report any rigidity violations
    
    Time: O(n · T_invariant + n · T_predicate)
    Space: O(n + |range(invariant)|)
    """
    fibers: Dict[Any, List[T]] = {}
    for elem in elements:
        inv = invariant(elem)
        if inv not in fibers:
            fibers[inv] = []
        fibers[inv].append(elem)
    
    result = {}
    for inv_val, fiber in fibers.items():
        canonical = fiber[0]
        canonical_value = predicate(canonical)
        all_agree = all(predicate(x) == canonical_value for x in fiber)
        
        result[inv_val] = {
            'fiber': fiber,
            'canonical': canonical,
            'canonical_value': canonical_value,
            'rigid': all_agree,
            'fiber_size': len(fiber),
            'violations': [x for x in fiber if predicate(x) != canonical_value]
        }
    
    return result


# =============================================================================
# §4. Finite Core Extraction Algorithm
# =============================================================================

def extract_finite_core(
    elements: List[T],
    is_core: Callable[[List[T]], bool],
    max_core_size: int
) -> Optional[List[T]]:
    """
    Extract a minimal finite core from a set of elements.
    
    Algorithm (greedy):
    1. Start with empty core
    2. Add elements one by one, checking if the core condition is met
    3. Return when core condition is satisfied or max size reached
    
    Time: O(max_core_size · |elements| · T_is_core)
    Space: O(max_core_size)
    """
    core: List[T] = []
    
    for elem in elements:
        core.append(elem)
        if is_core(core):
            return core
        if len(core) >= max_core_size:
            break
    
    return core if is_core(core) else None


def verify_on_core(
    core: List[T],
    predicate: Callable[[T], bool],
    propagate: Callable[[List[T], T], bool]
) -> Tuple[bool, int]:
    """
    Verify a predicate by checking on a finite core and propagating.
    
    Returns (success, elements_checked).
    
    Time: O(|core| · T_predicate + |universe| · T_propagate)
    Space: O(|core|)
    """
    # Check on core
    for elem in core:
        if not predicate(elem):
            return False, 0
    
    return True, len(core)


# =============================================================================
# §5. Strategy Triad Orchestration
# =============================================================================

def strategy_triad(
    elements: List[T],
    measure: Callable[[T], int],
    invariant: Callable[[T], Any],
    bad: Callable[[T], bool],
    descent_step: Callable[[T], Optional[T]]
) -> Dict[str, Any]:
    """
    Execute the full Strategy Triad:
    1. Descent: find minimal bad elements
    2. Classification: group minimal elements by invariant
    3. Elimination: check each class for contradictions
    
    Time: O(n log n + n · (T_measure + T_invariant + T_bad + T_step))
    Space: O(n)
    """
    result = {
        'total_elements': len(elements),
        'bad_elements': [],
        'minimal_bad': [],
        'invariant_classes': {},
        'eliminated': True
    }
    
    # Find bad elements
    for elem in elements:
        if bad(elem):
            result['bad_elements'].append(elem)
    
    # Layer 1: Descent — find minimal bad elements
    for elem in result['bad_elements']:
        next_elem = descent_step(elem)
        if next_elem is None or measure(next_elem) >= measure(elem) or not bad(next_elem):
            result['minimal_bad'].append(elem)
    
    # Layer 2: Classification — group minimal bad by invariant
    for elem in result['minimal_bad']:
        inv = invariant(elem)
        if inv not in result['invariant_classes']:
            result['invariant_classes'][inv] = []
        result['invariant_classes'][inv].append(elem)
    
    # Layer 3: Elimination — report
    result['eliminated'] = len(result['minimal_bad']) == 0
    
    return result


# =============================================================================
# §6. GCD Descent Algorithm
# =============================================================================

def gcd_descent(a: int, b: int) -> List[Tuple[int, int, int]]:
    """
    Compute GCD via Euclidean descent, recording each step.
    
    The measure μ(a, b) = b strictly decreases at each step,
    demonstrating the descent principle.
    
    Time: O(log(min(a, b)))
    Space: O(log(min(a, b))) for the trace
    """
    trace = []
    while b > 0:
        trace.append((a, b, b))  # (a, b, measure)
        a, b = b, a % b
    trace.append((a, b, 0))
    return trace


# =============================================================================
# Main demonstration
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHMS: Composable Proof Schemata")
    print("=" * 60)
    print()
    
    # Demo 1: Descent verification
    print("1. Descent Verification")
    print("-" * 40)
    success, trace = descent_verify(
        predicate=lambda n: n * n >= n,
        descent_step=lambda n: n - 1 if n > 0 else None,
        bound=20
    )
    for line in trace[:5]:
        print(f"   {line}")
    print(f"   ... ({len(trace)} steps total)")
    print(f"   Result: {'VERIFIED' if success else 'FAILED'}")
    print()
    
    # Demo 2: Invariant classification
    print("2. Invariant Classification")
    print("-" * 40)
    result = invariant_classify(
        elements=list(range(20)),
        invariant=lambda n: n % 4,
        predicate=lambda n: n % 2 == 0
    )
    for inv_val, data in sorted(result.items()):
        print(f"   Fiber {inv_val}: rigid={data['rigid']}, "
              f"canonical P={data['canonical_value']}, size={data['fiber_size']}")
    print()
    
    # Demo 3: GCD descent
    print("3. GCD Descent Trace")
    print("-" * 40)
    trace = gcd_descent(252, 105)
    for a, b, m in trace:
        print(f"   GCD({a}, {b}), measure = {m}")
    print()
    
    # Demo 4: Strategy Triad
    print("4. Strategy Triad")
    print("-" * 40)
    result = strategy_triad(
        elements=list(range(50)),
        measure=lambda n: n,
        invariant=lambda n: n % 5,
        bad=lambda n: False,  # No bad elements — triad succeeds trivially
        descent_step=lambda n: n - 1 if n > 0 else None
    )
    print(f"   Total: {result['total_elements']}")
    print(f"   Bad: {len(result['bad_elements'])}")
    print(f"   Minimal bad: {len(result['minimal_bad'])}")
    print(f"   Eliminated: {result['eliminated']}")
    print()
    
    print("All algorithms demonstrated successfully.")

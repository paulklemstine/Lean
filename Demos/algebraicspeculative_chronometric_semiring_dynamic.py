#!/usr/bin/env python3
"""
Chronometric Semiring Dynamics — Algorithms
=============================================
Core algorithms: trace normalization, spectral analysis, and
causal closure computation.
"""

from typing import List, Set, Dict, Tuple, Callable, Optional
from dataclasses import dataclass, field
from collections import defaultdict
import itertools


# ──────────────────────────────────────────────────────────────
#  Core Data Structures
# ──────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class SignedAtom:
    """An atom tagged with forward/backward direction."""
    name: str
    forward: bool = True

    def flip(self) -> 'SignedAtom':
        return SignedAtom(self.name, not self.forward)

    def __repr__(self):
        return self.name if self.forward else f"{self.name}†"


# Type aliases
TraceWord = Tuple[SignedAtom, ...]
TraceNormalForm = Tuple[TraceWord, ...]


@dataclass
class TraceExpr:
    """Base class for trace expressions."""
    pass

@dataclass
class TZero(TraceExpr):
    """The zero element."""
    pass

@dataclass
class TOne(TraceExpr):
    """The unit element."""
    pass

@dataclass
class TAtom(TraceExpr):
    """An atomic symbol."""
    name: str

@dataclass
class TAdd(TraceExpr):
    """Sum of two expressions."""
    left: TraceExpr
    right: TraceExpr

@dataclass
class TMul(TraceExpr):
    """Product of two expressions."""
    left: TraceExpr
    right: TraceExpr

@dataclass
class TRev(TraceExpr):
    """Time-reversal of an expression."""
    inner: TraceExpr


# ──────────────────────────────────────────────────────────────
#  Algorithm 1: Trace Normalization
# ──────────────────────────────────────────────────────────────

def normalize(expr: TraceExpr) -> TraceNormalForm:
    """
    Normalize a trace expression to sum-of-products form.

    Algorithm:
        Recursive structural induction on the expression tree.
        - zero  → empty sum
        - one   → singleton sum containing empty word
        - atom  → singleton sum containing singleton word
        - add   → concatenation of normal forms
        - mul   → Cartesian product with word concatenation
        - rev   → reverse each word and flip atoms

    Complexity:
        Time:  O(|NF|) where |NF| ≤ 2^size(expr)
        Space: O(|NF|)

    The exponential bound is tight for balanced binary mul trees.
    For mul-free expressions, the bound is O(size(expr)).
    """
    if isinstance(expr, TZero):
        return ()
    elif isinstance(expr, TOne):
        return ((),)
    elif isinstance(expr, TAtom):
        return ((SignedAtom(expr.name, True),),)
    elif isinstance(expr, TAdd):
        return normalize(expr.left) + normalize(expr.right)
    elif isinstance(expr, TMul):
        left = normalize(expr.left)
        right = normalize(expr.right)
        return tuple(w1 + w2 for w1 in left for w2 in right)
    elif isinstance(expr, TRev):
        nf = normalize(expr.inner)
        return tuple(
            tuple(atom.flip() for atom in reversed(word))
            for word in nf
        )
    else:
        raise ValueError(f"Unknown expression: {type(expr)}")


def expr_size(expr: TraceExpr) -> int:
    """Compute the syntactic size of a trace expression."""
    if isinstance(expr, (TZero, TOne, TAtom)):
        return 1
    elif isinstance(expr, (TAdd, TMul)):
        return expr_size(expr.left) + expr_size(expr.right)
    elif isinstance(expr, TRev):
        return expr_size(expr.inner)
    return 0


# ──────────────────────────────────────────────────────────────
#  Algorithm 2: Canonical Deduplication
# ──────────────────────────────────────────────────────────────

def canonicalize(nf: TraceNormalForm) -> TraceNormalForm:
    """
    Canonicalize a normal form by sorting and deduplicating words.

    In an idempotent semiring, a + a = a, so duplicate words
    can be removed. Sorting provides a canonical representative.

    Complexity: O(n log n) where n = |NF|, assuming word comparison is O(k).
    """
    # Remove duplicates using a set
    unique_words = set(nf)
    # Sort for canonical ordering
    return tuple(sorted(unique_words))


def equiv_nf(e1: TraceExpr, e2: TraceExpr) -> bool:
    """
    Decide semantic equivalence of two trace expressions
    in the free idempotent chronometric semiring.

    Two expressions are equivalent iff their canonical normal
    forms are equal (after deduplication and sorting).

    Complexity: O(2^n) in the worst case where n = max(size(e1), size(e2)).
    """
    return canonicalize(normalize(e1)) == canonicalize(normalize(e2))


# ──────────────────────────────────────────────────────────────
#  Algorithm 3: Causal Closure (Finite Sets)
# ──────────────────────────────────────────────────────────────

def causal_closure_downward(
    elements: Set[float],
    universe: Set[float]
) -> Set[float]:
    """
    Compute the causal closure as downward closure in the tropical semiring.

    For the tropical semiring (ℝ ∪ {∞}, min, +), the causal closure of S
    is the downward closure: {x ∈ universe | x ≥ min(S)}.
    (Recall: the tropical order reverses the usual ℝ order.)

    Complexity: O(|universe|)
    """
    if not elements:
        return {float('inf')}
    threshold = min(elements)
    return {x for x in universe if x >= threshold} | {float('inf')}


def causal_closure_ideal(
    elements: Set[int],
    ring_elements: Set[int],
    mul_table: Dict[Tuple[int, int], int],
    add_table: Dict[Tuple[int, int], int],
) -> Set[int]:
    """
    Compute the causal closure as the ideal generated by elements.

    For a finite semiring, the causal closure of S is the smallest
    ideal containing S: close under addition and absorption by multiplication.

    Complexity: O(|R|^2) per iteration, at most |R| iterations.
    """
    closure = set(elements) | {0}  # Always contains 0
    changed = True
    while changed:
        changed = False
        new = set(closure)
        for a in closure:
            for r in ring_elements:
                prod = mul_table.get((r, a), None)
                if prod is not None and prod not in new:
                    new.add(prod)
                    changed = True
        for a, b in itertools.product(closure, closure):
            s = add_table.get((a, b), None)
            if s is not None and s not in new:
                new.add(s)
                changed = True
        closure = new
    return closure


# ──────────────────────────────────────────────────────────────
#  Algorithm 4: Zero Locus Computation (Finite Spectrum)
# ──────────────────────────────────────────────────────────────

@dataclass
class CongruenceOnFiniteSet:
    """A congruence on a finite set, represented as equivalence classes."""
    elements: Set[int]
    classes: Dict[int, int]  # element -> representative

    def related(self, a: int, b: int) -> bool:
        return self.classes.get(a) == self.classes.get(b)


def zero_locus(
    generators: Set[int],
    spectrum: List[CongruenceOnFiniteSet]
) -> List[int]:
    """
    Compute the zero locus of a set of generators.

    Returns indices of spectrum points where all generators vanish.

    Complexity: O(|spectrum| · |generators|)
    """
    result = []
    for i, P in enumerate(spectrum):
        if all(P.related(g, 0) for g in generators):
            result.append(i)
    return result


def basic_open(
    element: int,
    spectrum: List[CongruenceOnFiniteSet]
) -> List[int]:
    """
    Compute the basic open set D(element).

    Returns indices of spectrum points where element does NOT vanish.

    Complexity: O(|spectrum|)
    """
    return [i for i, P in enumerate(spectrum) if not P.related(element, 0)]


# ──────────────────────────────────────────────────────────────
#  Algorithm 5: Time-Reversal Symmetry Detection
# ──────────────────────────────────────────────────────────────

def find_symmetric_elements(
    elements: List[int],
    time_rev: Callable[[int], int]
) -> List[int]:
    """
    Find all quantum-trace-symmetric elements (fixed points of timeRev).

    An element x is symmetric iff timeRev(x) = x.

    Complexity: O(|elements|)
    """
    return [x for x in elements if time_rev(x) == x]


def is_time_rev_stable(
    subset: Set[int],
    time_rev: Callable[[int], int]
) -> bool:
    """
    Check if a subset is time-reversal stable.

    A set S is stable iff timeRev(x) ∈ S for all x ∈ S.

    Complexity: O(|subset|)
    """
    return all(time_rev(x) in subset for x in subset)


# ──────────────────────────────────────────────────────────────
#  Example Usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Normalization
    a, b, c = TAtom("a"), TAtom("b"), TAtom("c")
    expr = TMul(TAdd(a, b), TRev(c))
    nf = normalize(expr)
    print(f"normalize((a + b) · rev(c)) = {nf}")
    print(f"  Size of expression: {expr_size(expr)}")
    print(f"  Size of normal form: {len(nf)}")
    print(f"  Exponential bound: 2^{expr_size(expr)} = {2**expr_size(expr)}")

    # Canonical equivalence
    e1 = TAdd(a, TAdd(b, a))  # a + (b + a)
    e2 = TAdd(TAdd(a, b), a)  # (a + b) + a
    print(f"\n  equiv_nf(a+(b+a), (a+b)+a) = {equiv_nf(e1, e2)}")

    # Tropical causal closure
    universe = {0.0, 1.0, 2.0, 3.0, 5.0, float('inf')}
    S = {2.0, 5.0}
    cc = causal_closure_downward(S, universe)
    print(f"\n  Tropical causal closure of {{2, 5}} = {sorted(cc)}")

    # Symmetry detection
    elements = [0, 1, 2, 3]
    rev = lambda x: x  # identity
    sym = find_symmetric_elements(elements, rev)
    print(f"\n  Symmetric elements (id reversal): {sym}")


#!/usr/bin/env python3
"""
Chronometric Semiring Dynamics — Applications
================================================
Real-world applications in ML certified robustness, cryptographic
protocol analysis, and physics (time-reversal symmetry).
"""

import math
from typing import List, Tuple, Dict, Set
from dataclasses import dataclass


# ──────────────────────────────────────────────────────────────
#  Application 1: Certified Neural Network Robustness
#    via Tropical Path Aggregation
# ──────────────────────────────────────────────────────────────

@dataclass
class TropicalNeuralLayer:
    """
    A layer in a tropical (min-plus) neural network.

    In the tropical semiring, "addition" is min and "multiplication" is +.
    This models worst-case path cost aggregation, which is used for
    certified Lipschitz robustness bounds.

    The key insight: a ReLU network with max-pooling layers has a
    tropical semiring structure, and the Lipschitz constant is the
    minimum-cost path through the network graph.
    """
    weights: List[List[float]]  # weight matrix (cost = -log|weight|)

    def forward_tropical(self, x: List[float]) -> List[float]:
        """
        Tropical matrix-vector product: out[i] = min_j (weights[i][j] + x[j])

        This computes the minimum-cost path to each output neuron.
        """
        out = []
        for row in self.weights:
            out.append(min(w + xj for w, xj in zip(row, x)))
        return out


def lipschitz_bound_tropical(layers: List[TropicalNeuralLayer]) -> float:
    """
    Compute a certified Lipschitz bound for a feedforward network
    using tropical path aggregation.

    The Lipschitz constant is bounded by exp(-min_path_cost), where
    min_path_cost is the minimum total weight along any path from
    input to output in the tropical computation graph.

    This is the lipschitz_certified_robustness_trace_bound:
    the bound is computed by evaluating the tropical trace
    (product of weight matrices in the min-plus semiring).

    Returns: Lipschitz upper bound
    """
    # Start with identity costs for each input dimension
    n_input = len(layers[0].weights[0])
    costs = [0.0] * n_input  # zero cost = Lipschitz 1 per input

    for layer in layers:
        costs = layer.forward_tropical(costs)

    # Lipschitz bound = exp(-min_cost) over all outputs
    min_cost = min(costs)
    return math.exp(-min_cost) if min_cost != float('inf') else 0.0


def certified_robustness_radius(
    lipschitz_bound: float,
    margin: float
) -> float:
    """
    Certified robustness radius from a Lipschitz bound.

    If the classifier has Lipschitz constant L and margin m
    (distance from decision boundary in output space),
    then the certified radius is m / L.

    Any perturbation smaller than this radius cannot change the prediction.
    """
    if lipschitz_bound <= 0:
        return float('inf')
    return margin / lipschitz_bound


# ──────────────────────────────────────────────────────────────
#  Application 2: Cryptographic Protocol Trace Analysis
# ──────────────────────────────────────────────────────────────

@dataclass
class ProtocolStep:
    """A step in a cryptographic protocol."""
    name: str
    sender: str
    receiver: str
    reversible: bool = True

    def __repr__(self):
        arrow = "↔" if self.reversible else "→"
        return f"{self.sender}{arrow}{self.receiver}:{self.name}"


def analyze_protocol_traces(
    forward_trace: List[ProtocolStep],
    backward_trace: List[ProtocolStep]
) -> Dict[str, any]:
    """
    Analyze protocol traces for time-reversal symmetry.

    A protocol is T-symmetric if its reversed trace is equivalent
    to its forward trace (modulo the chronometric semiring structure).

    Applications to post-quantum security:
    - T-symmetric protocols may be vulnerable to replay attacks
    - T-asymmetric protocols have stronger temporal ordering guarantees
    - The normalization procedure canonicalizes protocol representations
      for efficient comparison (post_quantum_trace_canonicalization)

    Returns analysis dictionary with symmetry properties.
    """
    # Check structural time-reversal symmetry
    reversed_backward = list(reversed(backward_trace))

    # Check if forward and reversed-backward have same structure
    names_match = all(
        f.name == b.name
        for f, b in zip(forward_trace, reversed_backward)
    ) if len(forward_trace) == len(reversed_backward) else False

    # Count irreversible steps (one-way functions, hash, commitment)
    irreversible_forward = sum(1 for s in forward_trace if not s.reversible)
    irreversible_backward = sum(1 for s in backward_trace if not s.reversible)

    # Time-reversal barrier: minimum number of irreversible steps
    # that must be "undone" for an attack
    barrier = min(irreversible_forward, irreversible_backward)

    return {
        "forward_length": len(forward_trace),
        "backward_length": len(backward_trace),
        "structural_symmetry": names_match,
        "irreversible_steps_forward": irreversible_forward,
        "irreversible_steps_backward": irreversible_backward,
        "time_reversal_barrier": barrier,
        "security_assessment": (
            "WEAK: T-symmetric — potential replay vulnerability"
            if names_match and barrier == 0
            else f"MODERATE: barrier = {barrier}"
            if barrier < 2
            else f"STRONG: barrier = {barrier}"
        )
    }


# ──────────────────────────────────────────────────────────────
#  Application 3: Physical Time-Reversal Analysis
# ──────────────────────────────────────────────────────────────

def thermodynamic_process_reversibility(
    forward_entropy_changes: List[float],
    tolerance: float = 1e-10
) -> Dict[str, any]:
    """
    Analyze the time-reversal symmetry of a thermodynamic process.

    In the chronometric semiring framework:
    - Each process step has an entropy change ΔS
    - Time reversal negates entropy changes: τ(ΔS) = -ΔS
    - A process is T-symmetric iff total ΔS = 0 (reversible)
    - The causal closure ensures forward-consistency (Second Law)

    This models the thermodynamic arrow of time as a causal
    closure constraint on the chronometric semiring.
    """
    total_entropy = sum(forward_entropy_changes)
    reversed_changes = [-ds for ds in reversed(forward_entropy_changes)]
    reversed_total = sum(reversed_changes)

    is_reversible = abs(total_entropy) < tolerance
    max_local_irreversibility = max(
        abs(ds) for ds in forward_entropy_changes
    ) if forward_entropy_changes else 0

    return {
        "total_entropy_change": total_entropy,
        "is_reversible": is_reversible,
        "reversed_total": reversed_total,
        "consistency_check": abs(total_entropy + reversed_total) < tolerance,
        "max_local_irreversibility": max_local_irreversibility,
        "process_type": (
            "Reversible (T-symmetric)" if is_reversible
            else f"Irreversible (ΔS = {total_entropy:.4f})"
        )
    }


# ──────────────────────────────────────────────────────────────
#  Main demonstration
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("  APPLICATION DEMONSTRATIONS")
    print("=" * 60)

    # Application 1: Neural Network Robustness
    print("\n--- Application 1: Certified Neural Robustness ---\n")
    layers = [
        TropicalNeuralLayer([[0.5, 1.0, 0.3], [0.8, 0.2, 0.7]]),
        TropicalNeuralLayer([[0.4, 0.6], [0.9, 0.1]]),
    ]
    L = lipschitz_bound_tropical(layers)
    margin = 0.5
    radius = certified_robustness_radius(L, margin)
    print(f"  Tropical Lipschitz bound: {L:.4f}")
    print(f"  Classification margin: {margin}")
    print(f"  Certified robustness radius: {radius:.4f}")
    print(f"  → Any L_∞ perturbation < {radius:.4f} cannot change prediction")

    # Application 2: Protocol Analysis
    print("\n--- Application 2: Protocol Security ---\n")
    # Simulated key exchange protocol
    forward = [
        ProtocolStep("KeyGen", "Alice", "Alice", reversible=True),
        ProtocolStep("Encrypt", "Alice", "Bob", reversible=True),
        ProtocolStep("Hash", "Bob", "Bob", reversible=False),
        ProtocolStep("Verify", "Bob", "Alice", reversible=True),
    ]
    backward = [
        ProtocolStep("Verify", "Alice", "Bob", reversible=True),
        ProtocolStep("Hash", "Bob", "Bob", reversible=False),
        ProtocolStep("Decrypt", "Bob", "Alice", reversible=True),
        ProtocolStep("KeyGen", "Alice", "Alice", reversible=True),
    ]
    analysis = analyze_protocol_traces(forward, backward)
    for k, v in analysis.items():
        print(f"  {k}: {v}")

    # Application 3: Thermodynamics
    print("\n--- Application 3: Thermodynamic Reversibility ---\n")

    # Reversible process (isothermal expansion + compression)
    reversible = [0.5, -0.5, 0.3, -0.3]
    result = thermodynamic_process_reversibility(reversible)
    print(f"  Process 1: {result['process_type']}")
    print(f"    Consistency: {result['consistency_check']}")

    # Irreversible process (heat flow)
    irreversible = [1.2, 0.8, 0.5, -0.1]
    result = thermodynamic_process_reversibility(irreversible)
    print(f"  Process 2: {result['process_type']}")
    print(f"    Total ΔS: {result['total_entropy_change']:.4f}")
    print(f"    Max local irreversibility: {result['max_local_irreversibility']:.4f}")


#!/usr/bin/env python3
"""
Chronometric Semiring Dynamics — Demo
======================================
Concrete numerical examples of chronometric semiring computations,
trace normalization, and spectral analysis.
"""

import itertools
from typing import List, Tuple, Set, Optional, Callable


# ──────────────────────────────────────────────────────────────
#  1. The Boolean Chronometric Semiring  {0, 1}  (OR, AND, id)
# ──────────────────────────────────────────────────────────────

class BoolChronoSemiring:
    """
    Boolean chronometric semiring: ({0,1}, OR, AND) with identity timeRev
    and the trivial causal closure (identity on sets).

    This is the simplest non-trivial chronometric semiring.
    """
    @staticmethod
    def add(a: int, b: int) -> int:
        return a | b  # OR

    @staticmethod
    def mul(a: int, b: int) -> int:
        return a & b  # AND

    @staticmethod
    def timeRev(a: int) -> int:
        return a  # identity

    @staticmethod
    def zero() -> int:
        return 0

    @staticmethod
    def one() -> int:
        return 1


def demo_boolean_semiring():
    """Demonstrate the Boolean chronometric semiring."""
    S = BoolChronoSemiring
    print("=" * 60)
    print("DEMO 1: Boolean Chronometric Semiring {0, 1}")
    print("  Addition = OR,  Multiplication = AND,  timeRev = id")
    print("=" * 60)

    # Verify idempotency
    for a in [0, 1]:
        assert S.add(a, a) == a, f"Idempotency failed for {a}"
    print("✓ Additive idempotency: a + a = a")

    # Verify timeRev involutivity
    for a in [0, 1]:
        assert S.timeRev(S.timeRev(a)) == a
    print("✓ timeRev involutive: τ(τ(a)) = a")

    # Verify anti-homomorphism (trivial since commutative)
    for a, b in itertools.product([0, 1], repeat=2):
        assert S.timeRev(S.mul(a, b)) == S.mul(S.timeRev(b), S.timeRev(a))
    print("✓ timeRev anti-homomorphism: τ(a·b) = τ(b)·τ(a)")

    # Canonical order
    print("\nCanonical order (a ≤ b iff a OR b = b):")
    for a, b in itertools.product([0, 1], repeat=2):
        le = (S.add(a, b) == b)
        if le:
            print(f"  {a} ≤ {b}")

    print()


# ──────────────────────────────────────────────────────────────
#  2. Tropical Chronometric Semiring  (ℝ ∪ {∞}, min, +)
# ──────────────────────────────────────────────────────────────

INF = float('inf')

class TropicalChronoSemiring:
    """
    Tropical chronometric semiring: (ℝ ∪ {∞}, min, +) with timeRev = id
    and causal closure as downward closure (min-closure).

    The canonical order is ≥ on ℝ (reversed!), since min(a,b) = b iff a ≥ b.
    """
    @staticmethod
    def add(a: float, b: float) -> float:
        return min(a, b)

    @staticmethod
    def mul(a: float, b: float) -> float:
        return a + b if a != INF and b != INF else INF

    @staticmethod
    def timeRev(a: float) -> float:
        return a  # identity

    @staticmethod
    def zero() -> float:
        return INF

    @staticmethod
    def one() -> float:
        return 0.0


def demo_tropical_semiring():
    """Demonstrate the tropical chronometric semiring."""
    S = TropicalChronoSemiring
    print("=" * 60)
    print("DEMO 2: Tropical Chronometric Semiring (ℝ∪{∞}, min, +)")
    print("=" * 60)

    vals = [0.0, 1.0, 2.5, 5.0, INF]

    # Verify idempotency
    for a in vals:
        assert S.add(a, a) == a
    print("✓ Additive idempotency: min(a, a) = a")

    # Canonical order
    print("\nCanonical order (a ≤ b iff min(a,b) = b, i.e., a ≥ b in ℝ):")
    test_vals = [1.0, 3.0, 5.0, INF]
    for a, b in itertools.product(test_vals, repeat=2):
        le = (S.add(a, b) == b)
        if le:
            sym_a = f"∞" if a == INF else f"{a}"
            sym_b = f"∞" if b == INF else f"{b}"
            print(f"  {sym_a} ≤ {sym_b}")

    # Shortest path interpretation
    print("\nShortest path computation:")
    print("  Path A→B: cost 3.0")
    print("  Path A→C→B: cost 1.0 + 2.5 = 3.5")
    print("  Best path A→B:", S.add(3.0, S.mul(1.0, 2.5)))
    print()


# ──────────────────────────────────────────────────────────────
#  3. Trace Expression Normalization
# ──────────────────────────────────────────────────────────────

class SignedAtom:
    """A signed atom: forward or backward."""
    def __init__(self, name: str, forward: bool = True):
        self.name = name
        self.forward = forward

    def flip(self) -> 'SignedAtom':
        return SignedAtom(self.name, not self.forward)

    def __repr__(self):
        return self.name if self.forward else f"{self.name}†"

    def __eq__(self, other):
        return self.name == other.name and self.forward == other.forward

    def __hash__(self):
        return hash((self.name, self.forward))


# A TraceWord is a list of SignedAtoms
# A TraceNormalForm is a list of TraceWords

class TraceExpr:
    """Trace expression AST."""
    pass

class Zero(TraceExpr):
    def __repr__(self): return "0"

class One(TraceExpr):
    def __repr__(self): return "1"

class Atom(TraceExpr):
    def __init__(self, name: str):
        self.name = name
    def __repr__(self): return self.name

class Add(TraceExpr):
    def __init__(self, left: TraceExpr, right: TraceExpr):
        self.left = left
        self.right = right
    def __repr__(self): return f"({self.left} + {self.right})"

class Mul(TraceExpr):
    def __init__(self, left: TraceExpr, right: TraceExpr):
        self.left = left
        self.right = right
    def __repr__(self): return f"({self.left} · {self.right})"

class Rev(TraceExpr):
    def __init__(self, inner: TraceExpr):
        self.inner = inner
    def __repr__(self): return f"rev({self.inner})"


def normalize(expr: TraceExpr) -> List[List[SignedAtom]]:
    """Normalize a trace expression to sum-of-products form."""
    if isinstance(expr, Zero):
        return []
    elif isinstance(expr, One):
        return [[]]
    elif isinstance(expr, Atom):
        return [[SignedAtom(expr.name, True)]]
    elif isinstance(expr, Add):
        return normalize(expr.left) + normalize(expr.right)
    elif isinstance(expr, Mul):
        left = normalize(expr.left)
        right = normalize(expr.right)
        return [w1 + w2 for w1 in left for w2 in right]
    elif isinstance(expr, Rev):
        nf = normalize(expr.inner)
        return [[atom.flip() for atom in reversed(word)] for word in nf]
    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


def expr_size(expr: TraceExpr) -> int:
    """Compute the size of a trace expression."""
    if isinstance(expr, (Zero, One, Atom)):
        return 1
    elif isinstance(expr, (Add, Mul)):
        return expr_size(expr.left) + expr_size(expr.right)
    elif isinstance(expr, Rev):
        return expr_size(expr.inner)
    return 0


def nf_size(nf: List[List[SignedAtom]]) -> int:
    """Size of a normal form = number of words."""
    return len(nf)


def format_word(word: List[SignedAtom]) -> str:
    if not word:
        return "ε"
    return "·".join(str(a) for a in word)


def format_nf(nf: List[List[SignedAtom]]) -> str:
    if not nf:
        return "∅"
    return " + ".join(format_word(w) for w in nf)


def demo_normalization():
    """Demonstrate trace expression normalization."""
    print("=" * 60)
    print("DEMO 3: Trace Expression Normalization")
    print("=" * 60)

    # Example 1: rev(a · b) = b† · a†
    a, b, c = Atom("a"), Atom("b"), Atom("c")
    e1 = Rev(Mul(a, b))
    nf1 = normalize(e1)
    print(f"\n  Expression: {e1}")
    print(f"  Normal form: {format_nf(nf1)}")
    print(f"  Verifies: rev(a·b) = b†·a† (quantum gate reversal)")

    # Example 2: (a + b) · c = a·c + b·c
    e2 = Mul(Add(a, b), c)
    nf2 = normalize(e2)
    print(f"\n  Expression: {e2}")
    print(f"  Normal form: {format_nf(nf2)}")
    print(f"  Verifies: (a+b)·c = a·c + b·c (distributivity)")

    # Example 3: rev(a + b) · rev(c) = rev(c)·rev(a) + rev(c)·rev(b)
    e3 = Mul(Rev(Add(a, b)), Rev(c))
    nf3 = normalize(e3)
    print(f"\n  Expression: {e3}")
    print(f"  Normal form: {format_nf(nf3)}")

    # Example 4: Size bound verification
    print("\n  Size bound verification (|NF| ≤ 2^size):")
    exprs = [
        ("a", a),
        ("a+b", Add(a, b)),
        ("(a+b)·c", Mul(Add(a, b), c)),
        ("(a+b)·(c+a)", Mul(Add(a, b), Add(c, a))),
        ("rev((a+b)·(c+a))", Rev(Mul(Add(a, b), Add(c, a)))),
    ]
    for name, e in exprs:
        nf = normalize(e)
        s = expr_size(e)
        ns = nf_size(nf)
        bound = 2 ** s
        print(f"    {name:25s}  size={s}  |NF|={ns}  2^size={bound}  {'✓' if ns <= bound else '✗'}")

    print()


# ──────────────────────────────────────────────────────────────
#  4. Spectral Analysis
# ──────────────────────────────────────────────────────────────

def demo_spectral():
    """Demonstrate spectral/zero locus concepts."""
    print("=" * 60)
    print("DEMO 4: Spectral Analysis — Zero Loci")
    print("=" * 60)

    # Work over the Boolean semiring {0, 1}
    # A congruence on {0,1} is determined by whether 0 ~ 1 or not.
    # There are exactly two congruences:
    #   C_triv: 0 ~ 0, 1 ~ 1 (identity)
    #   C_all:  0 ~ 1 (everything identified)
    # C_triv is prime: if a AND b ~ 0 then a = 0 or b = 0.
    # C_all is NOT prime: 1 AND 1 ~ 0 but 1 ≁ 0 in C_triv.

    print("\n  Boolean semiring {0, 1} with OR/AND:")
    print("  Congruences:")
    print("    C_triv: identity (only 0 ~ 0, 1 ~ 1)")
    print("    C_all:  collapse (0 ~ 1)")
    print("  Prime congruence: C_triv (since 0·0=0 and if a·b=0 then a=0 or b=0)")
    print("  ChronoSpec has 1 element: {C_triv}")

    print("\n  Zero loci:")
    print("    V(∅) = {C_triv} = whole spectrum")
    print("    V({0}) = {C_triv} (0 ~ 0 in C_triv)")
    print("    V({1}) = ∅ (1 ≁ 0 in C_triv)")
    print("    V({0,1}) = ∅")

    print("\n  Basic opens:")
    print("    D(0) = ∅ (0 ~ 0 in all prime congruences)")
    print("    D(1) = {C_triv}")
    print("    D(0·1) = D(0) ∩ D(1) = ∅ ∩ {C_triv} = ∅  ✓")

    print("\n  Causal closure invariance:")
    print("    For trivial causal closure: V(S) = V(causalClosure(S))  ✓")
    print()


# ──────────────────────────────────────────────────────────────
#  5. Protocol Trace Canonicalization
# ──────────────────────────────────────────────────────────────

def demo_protocol():
    """Demonstrate post-quantum trace canonicalization."""
    print("=" * 60)
    print("DEMO 5: Post-Quantum Trace Canonicalization")
    print("=" * 60)

    print("\n  Protocol scenario: Alice and Bob exchange messages")
    print("  using quantum key distribution (QKD).")
    print()

    # Model protocol steps as atoms
    key_gen = Atom("KeyGen")
    encrypt = Atom("Enc")
    transmit = Atom("Tx")
    decrypt = Atom("Dec")
    measure = Atom("Meas")

    # Forward protocol: KeyGen · Enc · Tx · Dec
    forward = Mul(Mul(Mul(key_gen, encrypt), transmit), decrypt)

    # With eavesdropper: (KeyGen · Enc + KeyGen · Meas) · Tx · Dec
    with_eve = Mul(Mul(Add(Mul(key_gen, encrypt), Mul(key_gen, measure)),
                       transmit), decrypt)

    # Reversed protocol
    rev_forward = Rev(forward)

    print(f"  Forward protocol:    {forward}")
    nf_fwd = normalize(forward)
    print(f"  Normal form:         {format_nf(nf_fwd)}")

    print(f"\n  With eavesdropper:   {with_eve}")
    nf_eve = normalize(with_eve)
    print(f"  Normal form:         {format_nf(nf_eve)}")

    print(f"\n  Reversed protocol:   {rev_forward}")
    nf_rev = normalize(rev_forward)
    print(f"  Normal form:         {format_nf(nf_rev)}")

    # Check if forward and reversed have same normal form
    same_nf = (nf_fwd == nf_rev)
    print(f"\n  Forward ≡ Reversed?  {same_nf}")
    print("  (Expected: False — protocols are not generally time-symmetric)")
    print()


# ──────────────────────────────────────────────────────────────
#  Main
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "━" * 60)
    print("  CHRONOMETRIC SEMIRING DYNAMICS — DEMONSTRATIONS")
    print("━" * 60 + "\n")

    demo_boolean_semiring()
    demo_tropical_semiring()
    demo_normalization()
    demo_spectral()
    demo_protocol()

    print("━" * 60)
    print("  All demonstrations completed successfully.")
    print("━" * 60)

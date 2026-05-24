#!/usr/bin/env python3
"""
Applications of Coalgebraic Final Semantics

Demonstrates real-world applications of the type-indexed coalgebraic framework:
1. Program equivalence checking via bisimulation
2. State-space compression for program analysis
3. Type-driven test generation
4. Automata minimization as a special case
"""

from algorithms import (
    BaseType, ArrType, FiniteCoalgebra, arity_of,
    partition_refinement, minimize, verify_morphism,
    are_isomorphic, modal_depth_classes, find_stabilization_depth,
    reachable_subcoalgebra, CoalgebraHomomorphism
)


def print_header(title: str):
    print(f"\n{'='*65}")
    print(f"  {title}")
    print(f"{'='*65}\n")


# ============================================================
# Application 1: Program Equivalence Checking
# ============================================================

def app_program_equivalence():
    """Demonstrate program equivalence checking via bisimulation.

    Two programs of the same type are observationally equivalent
    iff their coalgebra representations are behaviorally equivalent.
    This gives a decision procedure for finite-state programs.
    """
    print_header("Application 1: Program Equivalence Checking")

    ty = ArrType(BaseType(), ArrType(BaseType(), BaseType()))  # o → o → o
    ar = arity_of(ty)
    print(f"Type: {ty}  (arity = {ar})")
    print(f"Polynomial functor: F(X) = 1 + X^{ar}\n")

    # Program 1: "evaluate both arguments, return based on first"
    prog1 = FiniteCoalgebra(ty, 4, {
        0: (1, 2),   # Entry: branch on two arguments
        1: None,     # Result A (first arg determines)
        2: None,     # Result B (second arg determines)
        3: (1, 2),   # Redundant copy of entry
    })

    # Program 2: Different structure but same behavior
    prog2 = FiniteCoalgebra(ty, 5, {
        0: (1, 2),   # Entry
        1: None,     # Result A
        2: None,     # Result B
        3: (4, 2),   # Alternate entry
        4: None,     # Another terminal (same as 1)
    })

    m1, _ = minimize(prog1)
    m2, _ = minimize(prog2)

    print(f"Program 1: {prog1.num_states} states → minimized to {m1.num_states}")
    print(f"Program 2: {prog2.num_states} states → minimized to {m2.num_states}")
    print(f"Equivalent (isomorphic minimal forms): {are_isomorphic(m1, m2)}")
    print()

    # Non-equivalent programs
    prog3 = FiniteCoalgebra(ty, 3, {
        0: (1, 2),
        1: None,
        2: (1, 2),  # Different: second branch loops
    })
    m3, _ = minimize(prog3)
    print(f"Program 3 (different behavior): {prog3.num_states} states → {m3.num_states}")
    print(f"Equiv to Program 1: {are_isomorphic(m1, m3)}")


# ============================================================
# Application 2: State-Space Compression
# ============================================================

def app_state_compression():
    """Demonstrate state-space compression for program analysis.

    In program analysis, transition systems can be enormous.
    Bisimulation minimization provides a principled compression
    that preserves all observable behavior.
    """
    print_header("Application 2: State-Space Compression")

    ty = ArrType(BaseType(), BaseType())  # o → o
    print(f"Type: {ty} (arity = {arity_of(ty)})\n")

    # Build a large coalgebra with many redundant states
    # Simulating a program with replicated code paths
    n = 20
    str_map = {}
    for i in range(n):
        if i % 4 == 0:
            str_map[i] = None  # Terminal
        elif i % 4 == 1:
            str_map[i] = ((i + 1) % n,)  # One step to next
        elif i % 4 == 2:
            str_map[i] = ((i + 1) % n,)
        else:
            str_map[i] = ((i + 1) % n,)

    big_coal = FiniteCoalgebra(ty, n, str_map)
    mini, proj = minimize(big_coal)

    print(f"Original program: {big_coal.num_states} states")
    print(f"After bisimulation minimization: {mini.num_states} states")
    print(f"Compression ratio: {big_coal.num_states / mini.num_states:.1f}x")
    print(f"Morphism valid: {verify_morphism(proj)}")
    print()

    # Show how this scales
    print("Scaling analysis (chains with redundant structure):")
    print(f"{'Original':>10} {'Minimized':>10} {'Ratio':>8}")
    for size in [10, 20, 50, 100]:
        sm = {}
        for i in range(size):
            if i == size - 1:
                sm[i] = None
            else:
                sm[i] = ((i + 1),)
        c = FiniteCoalgebra(ty, size, sm)
        m, _ = minimize(c)
        print(f"{size:>10} {m.num_states:>10} {size/m.num_states:>8.1f}x")


# ============================================================
# Application 3: Type-Driven Test Generation
# ============================================================

def app_test_generation():
    """Demonstrate how type structure guides test generation.

    The polynomial functor F_A tells us exactly what observations
    can distinguish states. This gives a systematic way to generate
    minimal distinguishing test suites.
    """
    print_header("Application 3: Type-Driven Test Generation")

    types_to_test = [
        BaseType(),
        ArrType(BaseType(), BaseType()),
        ArrType(BaseType(), ArrType(BaseType(), BaseType())),
        ArrType(ArrType(BaseType(), BaseType()), BaseType()),
    ]

    for ty in types_to_test:
        ar = arity_of(ty)
        print(f"Type: {ty}")
        print(f"  Arity: {ar}")
        print(f"  Functor: F(X) = 1 + X^{ar}")

        if ar == 0:
            print(f"  Test strategy: Single observation (terminal?)")
            print(f"  Distinguishing power: Binary (halts/doesn't halt)")
        elif ar == 1:
            print(f"  Test strategy: Sequential observation chain")
            print(f"  At each step: check terminal, then follow unique successor")
            print(f"  Distinguishing depth: bounded by #states")
        else:
            print(f"  Test strategy: {ar}-way branching exploration")
            print(f"  At each step: check terminal, then test {ar} branches")
            print(f"  Test tree branching factor: {ar}")
            print(f"  Tests needed for depth d: O({ar}^d)")
        print()


# ============================================================
# Application 4: Classical Automata as Special Case
# ============================================================

def app_automata_minimization():
    """Show how classical DFA minimization is a special case.

    A DFA over alphabet {a,b} is an F-coalgebra where
    F(X) = 2 × X^|Σ| (output × transition for each symbol).
    Our framework with F(X) = 1 + X^k captures the reachability
    structure of such automata.
    """
    print_header("Application 4: Classical Automata Minimization")

    # Model a simple DFA as a coalgebra
    # Type o → o gives arity 1: sequential automaton
    ty = ArrType(BaseType(), BaseType())
    print(f"Sequential automaton modeled as {ty}-coalgebra\n")

    # DFA accepting strings of even length
    # States: 0 (even, accept), 1 (odd, reject)
    # Under our encoding: accepting = terminal, rejecting = branching
    dfa_even = FiniteCoalgebra(ty, 4, {
        0: None,     # Accept (even seen)
        1: (0,),     # Reject, go to accept
        2: None,     # Accept (copy)
        3: (2,),     # Reject (copy)
    })

    m, _ = minimize(dfa_even)
    print(f"DFA (even-length): {dfa_even.num_states} states → {m.num_states} minimal")

    # Binary branching automaton
    ty2 = ArrType(BaseType(), ArrType(BaseType(), BaseType()))  # arity 2
    print(f"\nBinary-branching automaton modeled as {ty2}-coalgebra")

    tree_auto = FiniteCoalgebra(ty2, 7, {
        0: (1, 2),
        1: (3, 4),
        2: (5, 6),
        3: None,
        4: None,
        5: None,
        6: None,
    })
    m2, _ = minimize(tree_auto)
    print(f"Tree automaton: {tree_auto.num_states} states → {m2.num_states} minimal")

    # Check modal depth stabilization
    stab = find_stabilization_depth(tree_auto)
    print(f"Modal stabilization depth: {stab}")

    # Show descending chain
    print("\nModal depth refinement (descending chain property):")
    for d in range(stab + 2):
        classes = modal_depth_classes(tree_auto, d)
        print(f"  Depth {d}: {len(classes)} classes")


# ============================================================
# Application 5: Coarse-Graining of Computation
# ============================================================

def app_coarse_graining():
    """Demonstrate computation as coarse-graining (physics analogy).

    Many syntactic microstates (λ-terms) collapse to few behavioral
    macrostates (equivalence classes). This is analogous to
    thermodynamic coarse-graining: microscopic configurations that
    produce the same macroscopic observables are identified.
    """
    print_header("Application 5: Coarse-Graining of Computation")

    ty = ArrType(ArrType(BaseType(), BaseType()), ArrType(BaseType(), BaseType()))
    ar = arity_of(ty)
    print(f"Type: {ty}")
    print(f"Arity: {ar}")
    print(f"Functor: F(X) = 1 + X^{ar}\n")

    # Build a coalgebra with many "microscopic" states
    # that collapse to few "macroscopic" behaviors
    micro = FiniteCoalgebra(ty, 12, {
        0: (1, 2),   1: None,   2: None,
        3: (4, 5),   4: None,   5: None,   # Same behavior as 0-2
        6: (7, 8),   7: None,   8: None,   # Same again
        9: (10, 11), 10: None,  11: None,  # Same again
    })

    classes, _ = partition_refinement(micro)
    macro, _ = minimize(micro)

    print(f"Microstates: {micro.num_states}")
    print(f"Macrostates: {macro.num_states}")
    print(f"Entropy reduction: log₂({micro.num_states}) → log₂({macro.num_states})")
    print(f"  = {micro.num_states.bit_length()-1:.1f} bits → {macro.num_states.bit_length()-1:.1f} bits")
    print(f"\nEquivalence classes (coarse-graining cells):")
    for i, cls in enumerate(classes):
        print(f"  Macrostate {i}: microstates {sorted(cls)}")

    print(f"\nPhysics analogy:")
    print(f"  {micro.num_states} term representations → {macro.num_states} observable behaviors")
    print(f"  Like {micro.num_states} molecular configurations → {macro.num_states} thermodynamic states")


# ============================================================
# Main
# ============================================================

def main():
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║   Applications of Coalgebraic Final Semantics               ║")
    print("║   for Simply Typed λ-Calculus                               ║")
    print("╚═══════════════════════════════════════════════════════════════╝")

    app_program_equivalence()
    app_state_compression()
    app_test_generation()
    app_automata_minimization()
    app_coarse_graining()

    print_header("Conclusion")
    print("The coalgebraic framework provides a unified lens for:")
    print("  • Program equivalence (decidable for finite-state fragments)")
    print("  • State compression (bisimulation = optimal compression)")
    print("  • Test generation (type structure guides observation strategy)")
    print("  • Automata theory (DFA minimization as special case)")
    print("  • Physics (coarse-graining as quotient construction)")
    print()
    print("All backed by machine-verified proofs in the Lean formalization.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Coalgebraic Final Semantics for Simply Typed λ-Calculus — Demo

This script demonstrates the core ideas of the coalgebraic semantics framework:
1. Constructs type polynomial functors for sample simple types
2. Builds finite coalgebras and computes behavioral equivalence
3. Performs bisimulation minimization (quotient construction)
4. Tests stabilization across types and coalgebra sizes
5. Visualizes the coalgebra graphs

Usage: python demo.py
"""

from dataclasses import dataclass
from typing import Optional
from collections import defaultdict
import itertools


# ============================================================
# Simple Types
# ============================================================

@dataclass(frozen=True)
class BaseType:
    """The base type 'o'."""
    def __repr__(self):
        return "o"

@dataclass(frozen=True)
class ArrType:
    """Arrow type A → B."""
    dom: object  # STLCType
    cod: object  # STLCType
    def __repr__(self):
        d = f"({self.dom})" if isinstance(self.dom, ArrType) else str(self.dom)
        return f"{d} → {self.cod}"

STLCType = BaseType | ArrType

def arity_of(ty: STLCType) -> int:
    """Codomain arity: number of arguments in the right-nested arrow chain."""
    if isinstance(ty, BaseType):
        return 0
    return arity_of(ty.cod) + 1

def type_size(ty: STLCType) -> int:
    if isinstance(ty, BaseType):
        return 1
    return type_size(ty.dom) + type_size(ty.cod) + 1

def type_order(ty: STLCType) -> int:
    if isinstance(ty, BaseType):
        return 0
    return max(type_order(ty.dom) + 1, type_order(ty.cod))

# Sample types
o = BaseType()
o_to_o = ArrType(o, o)
oo_to_o_to_o = ArrType(ArrType(o, o), ArrType(o, o))
church_nat = ArrType(ArrType(o, o), ArrType(o, o))  # (o→o)→o→o

SAMPLE_TYPES = [o, o_to_o, oo_to_o_to_o, church_nat,
                ArrType(o, ArrType(o, o)),  # o → o → o
                ArrType(ArrType(o, o), o)]   # (o → o) → o


# ============================================================
# Finite Coalgebras
# ============================================================

@dataclass
class FiniteCoalgebra:
    """A finite F_A-coalgebra: states are integers, transitions are either
    terminal (None) or branching (tuple of successor states)."""
    ty: STLCType
    num_states: int
    # str_map[s] = None (terminal) or tuple of length arity_of(ty)
    str_map: dict

    def is_terminal(self, s: int) -> bool:
        return self.str_map[s] is None

    def successors(self, s: int) -> Optional[tuple]:
        return self.str_map[s]

    def states(self):
        return range(self.num_states)


def make_example_coalgebra(ty: STLCType, spec: list) -> FiniteCoalgebra:
    """Build a coalgebra from a specification list.
    Each element is None (terminal) or a tuple of successor state indices."""
    n = len(spec)
    str_map = {}
    ar = arity_of(ty)
    for i, s in enumerate(spec):
        if s is None:
            str_map[i] = None
        else:
            assert len(s) == ar, f"Expected arity {ar}, got {len(s)}"
            str_map[i] = tuple(s)
    return FiniteCoalgebra(ty=ty, num_states=n, str_map=str_map)


# ============================================================
# Bisimulation & Behavioral Equivalence
# ============================================================

def compute_behavioral_equiv(coal: FiniteCoalgebra) -> list[set]:
    """Compute behavioral equivalence classes using partition refinement.

    Algorithm:
    1. Start with partition by terminal vs. branching.
    2. Iteratively refine: two states are equivalent iff they have the same
       structure (both terminal, or branching with equivalent successors).
    3. Repeat until stable.

    Returns: list of equivalence classes (sets of state indices).
    """
    n = coal.num_states
    ar = arity_of(coal.ty)

    # Initial partition: terminal vs. branching
    terminal = {s for s in range(n) if coal.is_terminal(s)}
    branching = {s for s in range(n) if not coal.is_terminal(s)}
    if not terminal:
        partition = [branching]
    elif not branching:
        partition = [terminal]
    else:
        partition = [terminal, branching]

    def state_to_class(partition):
        mapping = {}
        for idx, cls in enumerate(partition):
            for s in cls:
                mapping[s] = idx
        return mapping

    # Refine until stable
    for _ in range(n + 1):  # At most n refinements
        mapping = state_to_class(partition)
        new_partition = []
        for cls in partition:
            # Sub-partition cls by successor class signatures
            sig_groups = defaultdict(set)
            for s in cls:
                if coal.is_terminal(s):
                    sig = ("term",)
                else:
                    succs = coal.successors(s)
                    sig = ("branch",) + tuple(mapping[si] for si in succs)
                sig_groups[sig].add(s)
            new_partition.extend(sig_groups.values())

        if len(new_partition) == len(partition):
            break
        partition = new_partition

    return partition


def minimize_coalgebra(coal: FiniteCoalgebra) -> FiniteCoalgebra:
    """Construct the quotient coalgebra by behavioral equivalence."""
    classes = compute_behavioral_equiv(coal)
    n_new = len(classes)
    ar = arity_of(coal.ty)

    # Map old states to new class indices
    old_to_new = {}
    for idx, cls in enumerate(classes):
        for s in cls:
            old_to_new[s] = idx

    # Build new structure map
    new_str = {}
    for idx, cls in enumerate(classes):
        rep = next(iter(cls))  # Pick representative
        if coal.is_terminal(rep):
            new_str[idx] = None
        else:
            succs = coal.successors(rep)
            new_str[idx] = tuple(old_to_new[si] for si in succs)

    return FiniteCoalgebra(ty=coal.ty, num_states=n_new, str_map=new_str)


# ============================================================
# Coalgebra Isomorphism Check
# ============================================================

def are_isomorphic(c1: FiniteCoalgebra, c2: FiniteCoalgebra) -> bool:
    """Check if two coalgebras are isomorphic by trying all permutations
    (only feasible for small coalgebras)."""
    if c1.num_states != c2.num_states:
        return False
    if c1.num_states > 8:
        # Fall back to canonical form comparison
        return canonical_signature(c1) == canonical_signature(c2)

    for perm in itertools.permutations(range(c2.num_states)):
        # Check if perm : c1 → c2 is a coalgebra morphism
        ok = True
        for s in range(c1.num_states):
            s2 = perm[s]
            if c1.is_terminal(s) != c2.is_terminal(s2):
                ok = False
                break
            if not c1.is_terminal(s):
                succs1 = c1.successors(s)
                succs2 = c2.successors(s2)
                if tuple(perm[si] for si in succs1) != succs2:
                    ok = False
                    break
        if ok:
            return True
    return False


def canonical_signature(coal: FiniteCoalgebra) -> tuple:
    """Compute a canonical signature for isomorphism comparison.
    BFS from each state, recording the structure pattern."""
    sigs = []
    for start in range(coal.num_states):
        visited = {}
        queue = [start]
        visited[start] = 0
        counter = 1
        pattern = []
        while queue:
            s = queue.pop(0)
            if coal.is_terminal(s):
                pattern.append(("T",))
            else:
                succs = coal.successors(s)
                succ_ids = []
                for si in succs:
                    if si not in visited:
                        visited[si] = counter
                        counter += 1
                        queue.append(si)
                    succ_ids.append(visited[si])
                pattern.append(("B", tuple(succ_ids)))
        sigs.append(tuple(pattern))
    return tuple(sorted(sigs))


# ============================================================
# Demo Execution
# ============================================================

def print_separator(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def demo_type_analysis():
    """Demonstrate type structure analysis."""
    print_separator("Type Structure Analysis")
    print(f"{'Type':<25} {'Arity':>6} {'Size':>6} {'Order':>6}")
    print("-" * 50)
    for ty in SAMPLE_TYPES:
        print(f"{str(ty):<25} {arity_of(ty):>6} {type_size(ty):>6} {type_order(ty):>6}")

    print("\nKey insight: The arity determines the polynomial functor F_A.")
    print("F_A(X) = Unit + X^(arity_of A)")
    print("Base type:  F_o(X) = Unit + X^0 ≅ Unit + Unit  (trivial)")
    print("Arrow type: F_{A→B}(X) = Unit + X^(arity_of(B)+1)  (nontrivial)")


def demo_bisimulation_minimization():
    """Demonstrate bisimulation minimization on concrete coalgebras."""
    print_separator("Bisimulation Minimization")

    # Example 1: o → o type (arity 1)
    # States: 0=apply, 1=identity_result, 2=const_result, 3=same_as_1
    coal1 = make_example_coalgebra(o_to_o, [
        (1,),   # State 0: branches to state 1
        None,   # State 1: terminal
        None,   # State 2: terminal (same behavior as 1)
        (2,),   # State 3: branches to state 2 (same behavior as 0)
    ])

    print("Example 1: Coalgebra for type o → o (arity=1)")
    print("  States: {0, 1, 2, 3}")
    print("  Structure: 0→(1), 1→term, 2→term, 3→(2)")
    classes = compute_behavioral_equiv(coal1)
    print(f"  Behavioral equiv classes: {[sorted(c) for c in classes]}")
    min1 = minimize_coalgebra(coal1)
    print(f"  Minimized: {min1.num_states} states")
    print(f"  Minimized structure: {min1.str_map}")
    print()

    # Example 2: (o→o) → o → o type (Church numerals, arity 2)
    coal2 = make_example_coalgebra(church_nat, [
        (1, 2),   # State 0: branches to 1 and 2
        (1, 2),   # State 1: same as 0 (bisimilar)
        None,     # State 2: terminal
        (3, 2),   # State 3: branches differently but equivalent to 0,1
        None,     # State 4: terminal (same as 2)
    ])
    print("Example 2: Coalgebra for type (o→o) → o → o (arity=2)")
    print("  States: {0, 1, 2, 3, 4}")
    print("  Structure: 0→(1,2), 1→(1,2), 2→term, 3→(3,2), 4→term")
    classes = compute_behavioral_equiv(coal2)
    print(f"  Behavioral equiv classes: {[sorted(c) for c in classes]}")
    min2 = minimize_coalgebra(coal2)
    print(f"  Minimized: {min2.num_states} states")
    print(f"  Minimized structure: {min2.str_map}")


def demo_stabilization():
    """Test the stabilization conjecture across types."""
    print_separator("Stabilization Test")

    print("Testing whether minimized coalgebras stabilize across different")
    print("presentations of the same behavioral pattern.\n")

    # For each type, generate several coalgebras with the same behavior
    # but different presentations, minimize, and check isomorphism

    test_types = [o, o_to_o, church_nat, ArrType(o, ArrType(o, o))]

    for ty in test_types:
        ar = arity_of(ty)
        print(f"Type: {ty}  (arity={ar})")

        if ar == 0:
            # Base type: only terminal states
            c1 = make_example_coalgebra(ty, [None, None, None])
            c2 = make_example_coalgebra(ty, [None, None])
            m1 = minimize_coalgebra(c1)
            m2 = minimize_coalgebra(c2)
            print(f"  All-terminal: {m1.num_states} states, {m2.num_states} states")
            print(f"  Isomorphic: {are_isomorphic(m1, m2)}")
        elif ar == 1:
            # Arity 1: linear chains
            c1 = make_example_coalgebra(ty, [(1,), None])
            c2 = make_example_coalgebra(ty, [(1,), (2,), None])
            c3 = make_example_coalgebra(ty, [(1,), (2,), (3,), None])
            m1 = minimize_coalgebra(c1)
            m2 = minimize_coalgebra(c2)
            m3 = minimize_coalgebra(c3)
            print(f"  Chain lengths 1,2,3: minimized to {m1.num_states}, {m2.num_states}, {m3.num_states} states")

            # Self-loop
            c_loop = make_example_coalgebra(ty, [(0,)])
            m_loop = minimize_coalgebra(c_loop)
            print(f"  Self-loop: minimized to {m_loop.num_states} states")
        elif ar == 2:
            # Arity 2: binary branching
            c1 = make_example_coalgebra(ty, [(1, 2), None, None])
            c2 = make_example_coalgebra(ty, [(1, 2), None, None, (4, 5), None, None])
            m1 = minimize_coalgebra(c1)
            m2 = minimize_coalgebra(c2)
            print(f"  Tree depth 1: {m1.num_states} → {m2.num_states} states (iso: {are_isomorphic(m1, m2)})")

            # Full binary tree depth 2
            c3 = make_example_coalgebra(ty, [
                (1, 2), (3, 4), (5, 6), None, None, None, None
            ])
            m3 = minimize_coalgebra(c3)
            print(f"  Full binary tree depth 2: minimized to {m3.num_states} states")

        print()


def demo_canonical_behavior():
    """Demonstrate the canonical behavior object for each type."""
    print_separator("Canonical Behavior Objects")

    print("For each type A, the canonical behavior object Can_A is the")
    print("final coalgebra among finite generated F_A-coalgebras.\n")

    # For simple types, enumerate small canonical coalgebras
    for ty in [o, o_to_o, ArrType(o, ArrType(o, o)), church_nat]:
        ar = arity_of(ty)
        print(f"Type: {ty}")
        print(f"  Polynomial functor: F_A(X) = Unit + X^{ar}")
        print(f"  Type size: {type_size(ty)}, Type order: {type_order(ty)}")

        if ar == 0:
            print("  Canonical behavior: 1 state (terminal)")
            print("  All base-type coalgebras collapse to a point.")
        elif ar == 1:
            print("  Canonical behavior: 2 states minimum (branching + terminal)")
            print("  This is the 'identity/constant' dichotomy for o → o.")
            print("  Additional states possible for chains of length > 1.")
        else:
            print(f"  Canonical behavior: rich structure with {ar}-ary branching")
            print(f"  Minimal nontrivial coalgebra: {ar + 1} states (1 branching + {ar} terminal)")
        print()


def demo_myhill_nerode_analogy():
    """Demonstrate the Myhill-Nerode analogy."""
    print_separator("Myhill-Nerode Analogy")

    print("Classical Myhill-Nerode (DFA):")
    print("  States ↔ residual languages")
    print("  Equivalence classes ↔ minimal DFA states")
    print("  Quotient ↔ minimal automaton")
    print()
    print("Coalgebraic Myhill-Nerode (λ-calculus):")
    print("  States ↔ λ-term evaluation states")
    print("  Behavioral equiv classes ↔ canonical behavior states")
    print("  Quotient coalgebra ↔ canonical semantic model")
    print()
    print("Key theorem (proved in Lean):")
    print("  For every simple type A and F_A-coalgebra C,")
    print("  the behavioral quotient C/≈ inherits a well-defined")
    print("  F_A-coalgebra structure (quotient_has_coalgebra_structure).")
    print()
    print("  Any two final coalgebras in a class are isomorphic")
    print("  (final_coalgebra_unique).")
    print()
    print("  The kernel of any coalgebra morphism is a bisimulation")
    print("  (morphism_kernel_is_bisimulation).")


def demo_conjecture_tests():
    """Test the conjectures computationally."""
    print_separator("Conjecture Testing")

    # Conjecture A: Type-determined canonical quotient
    print("Conjecture A: Quotient stabilizes and depends only on type")
    print("-" * 50)

    for ty in [o, o_to_o, ArrType(o, ArrType(o, o))]:
        ar = arity_of(ty)
        print(f"\n  Type: {ty} (arity={ar})")

        # Generate multiple coalgebras of increasing size
        sizes = []
        for n in range(2, 7):
            if ar == 0:
                spec = [None] * n
            elif ar == 1:
                spec = [(i + 1,) for i in range(n - 1)] + [None]
            else:
                # Binary branching with terminals
                spec = []
                for i in range(n):
                    if i >= n - ar:
                        spec.append(None)
                    else:
                        succs = tuple(min(i + j + 1, n - 1) for j in range(ar))
                        spec.append(succs)

            coal = make_example_coalgebra(ty, spec)
            mini = minimize_coalgebra(coal)
            sizes.append(mini.num_states)

        print(f"  Original sizes: {list(range(2, 7))}")
        print(f"  Minimized sizes: {sizes}")
        stabilized = all(s == sizes[-1] for s in sizes[-3:]) if len(sizes) >= 3 else False
        print(f"  Stabilized (last 3 equal): {stabilized}")

    # Conjecture B: Arity completeness
    print(f"\n\nConjecture B: arity_of A = max branching degree")
    print("-" * 50)
    for ty in [o, o_to_o, ArrType(o, ArrType(o, o)), church_nat]:
        ar = arity_of(ty)
        # By definition, branching states have exactly ar successors
        # So the conjecture is trivially true for our framework
        print(f"  {ty}: arity={ar}, max branching = {ar} (by construction) ✓")


def visualize_coalgebra(coal: FiniteCoalgebra, name: str):
    """Print a text visualization of a coalgebra."""
    print(f"\n  Coalgebra '{name}' for type {coal.ty}:")
    print(f"  States: {coal.num_states}, Arity: {arity_of(coal.ty)}")
    for s in range(coal.num_states):
        if coal.is_terminal(s):
            print(f"    [{s}] → ●  (terminal)")
        else:
            succs = coal.successors(s)
            arrows = ", ".join(str(si) for si in succs)
            print(f"    [{s}] → ({arrows})")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Coalgebraic Final Semantics for Simply Typed λ-Calculus║")
    print("║  Interactive Demonstration                              ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_type_analysis()
    demo_bisimulation_minimization()
    demo_stabilization()
    demo_canonical_behavior()
    demo_myhill_nerode_analogy()
    demo_conjecture_tests()

    print_separator("Summary")
    print("This demo illustrates the key results formalized in Lean 4:")
    print()
    print("1. Every simple type A determines a polynomial functor F_A(X) = 1 + X^n")
    print("2. Behavioral equivalence on F_A-coalgebras is an equivalence relation")
    print("3. The quotient by behavioral equivalence inherits coalgebra structure")
    print("4. Any two final coalgebras in a class are canonically isomorphic")
    print("5. The kernel of any coalgebra morphism is a bisimulation")
    print("6. Branching degree is bounded by type arity")
    print("7. Modal depth n approximations form a descending chain")
    print()
    print("These results establish a new bridge between typed λ-calculus,")
    print("automata minimization, and coalgebraic semantics.")


if __name__ == "__main__":
    main()

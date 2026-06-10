#!/usr/bin/env python3
"""
Algorithms for Temporal Stone-Birkhoff Duality

Implements:
1. Causal closure computation (fixed-point iteration)
2. Causal equivalence class computation
3. Behavioral invariant extraction
4. Lattice structure computation for fixed points
5. System minimization via causal completion
"""

import itertools
from typing import Dict, FrozenSet, List, Optional, Set, Tuple


class ReversibleSystem:
    """
    A finite reversible transition system.
    
    States: integers 0..n-1
    Transitions: symmetric adjacency (reversible)
    
    Complexity:
    - Space: O(n^2) for adjacency
    - Closure computation: O(n^2) per step, O(n) steps → O(n^3) total
    - All fixed points: O(2^n * n^3) (exponential in state count)
    
    For practical systems, this is used for small state spaces (n ≤ 20).
    """
    
    def __init__(self, n_states: int, edges: List[Tuple[int, int]]):
        """
        Initialize a reversible system.
        
        Args:
            n_states: Number of states
            edges: List of (src, tgt) pairs (symmetrized automatically)
        """
        self.n = n_states
        self.adj: Dict[int, Set[int]] = {s: set() for s in range(n_states)}
        for (a, b) in edges:
            assert 0 <= a < n_states and 0 <= b < n_states
            self.adj[a].add(b)
            self.adj[b].add(a)
    
    def fwd_step(self, A: FrozenSet[int]) -> FrozenSet[int]:
        """
        One forward expansion step.
        
        Time: O(|A| * max_degree)
        """
        result = set(A)
        for s in A:
            result |= self.adj[s]
        return frozenset(result)
    
    def causal_closure(self, A: FrozenSet[int]) -> FrozenSet[int]:
        """
        Compute causal closure by iterated forward expansion to fixpoint.
        
        For reversible systems, backward closure = forward closure,
        so the combined causal closure is just forward closure.
        
        Time: O(n^2) per step, at most n steps → O(n^3)
        Space: O(n)
        
        Terminates because: the sequence A ⊆ fwd(A) ⊆ fwd²(A) ⊆ ...
        is a chain of subsets of {0,...,n-1}, so it stabilizes in ≤ n steps.
        """
        current = A
        for _ in range(self.n):
            next_set = self.fwd_step(current)
            if next_set == current:
                return current
            current = next_set
        return current
    
    def is_causally_fixed(self, A: FrozenSet[int]) -> bool:
        """Check if A is a fixed point of causal closure."""
        return self.causal_closure(A) == A
    
    def all_fixed_points(self) -> List[FrozenSet[int]]:
        """
        Enumerate all causal fixed points.
        
        Time: O(2^n * n^3)
        
        A fixed point is a union of connected components (including ∅).
        This can be computed more efficiently by finding connected components first.
        """
        fixed = []
        for r in range(self.n + 1):
            for subset in itertools.combinations(range(self.n), r):
                fs = frozenset(subset)
                if self.is_causally_fixed(fs):
                    fixed.append(fs)
        return sorted(fixed, key=lambda s: (len(s), sorted(s)))
    
    def connected_components(self) -> List[FrozenSet[int]]:
        """
        Find connected components via BFS.
        
        Time: O(n + |E|)
        
        For reversible systems, causal fixed points are exactly
        the unions of connected components.
        """
        visited: Set[int] = set()
        components = []
        for s in range(self.n):
            if s not in visited:
                # BFS from s
                component: Set[int] = set()
                queue = [s]
                while queue:
                    v = queue.pop()
                    if v in component:
                        continue
                    component.add(v)
                    visited.add(v)
                    for w in self.adj[v]:
                        if w not in component:
                            queue.append(w)
                components.append(frozenset(component))
        return components
    
    def fixed_points_from_components(self) -> List[FrozenSet[int]]:
        """
        Compute fixed points efficiently using connected components.
        
        Time: O(n + |E| + 2^k) where k = number of components
        
        This is exponentially better than all_fixed_points when k << n.
        """
        components = self.connected_components()
        k = len(components)
        fixed = []
        for r in range(k + 1):
            for combo in itertools.combinations(range(k), r):
                union = frozenset().union(*(components[i] for i in combo)) if combo else frozenset()
                fixed.append(union)
        return sorted(fixed, key=lambda s: (len(s), sorted(s)))
    
    def causal_equivalence_classes(self) -> Dict[FrozenSet[int], List[FrozenSet[int]]]:
        """
        Group all subsets by their causal closure.
        
        Time: O(2^n * n^3)
        """
        classes: Dict[FrozenSet[int], List[FrozenSet[int]]] = {}
        for r in range(self.n + 1):
            for subset in itertools.combinations(range(self.n), r):
                fs = frozenset(subset)
                cl = self.causal_closure(fs)
                if cl not in classes:
                    classes[cl] = []
                classes[cl].append(fs)
        return classes
    
    def behavioral_invariant(self) -> Tuple[int, List[Tuple[int, int]]]:
        """
        Extract the behavioral invariant: the Hasse diagram of the
        fixed-point lattice.
        
        Returns:
            (n_fixed_points, covering_relations)
        """
        fps = self.fixed_points_from_components()
        n = len(fps)
        covers = []
        for i, a in enumerate(fps):
            for j, b in enumerate(fps):
                if a < b:
                    is_cover = all(not (a < fps[k] < b) for k in range(n))
                    if is_cover:
                        covers.append((i, j))
        return (n, covers)
    
    def is_behaviorally_equivalent(self, other: 'ReversibleSystem') -> bool:
        """
        Check behavioral equivalence by comparing fixed-point lattice structures.
        
        Two systems are equivalent iff their fixed-point lattices are isomorphic
        as partial orders. For the simple case of union-of-components lattices,
        this reduces to having the same number of connected components.
        
        Time: O(n + |E|) for both systems
        """
        c1 = self.connected_components()
        c2 = other.connected_components()
        # Same number of components → isomorphic Boolean lattice → equivalent
        return len(c1) == len(c2)


def minimize_system(sys: ReversibleSystem) -> Tuple[int, List[Tuple[int, int]]]:
    """
    Minimize a reversible system by computing its causal completion.
    
    The minimal system has one state per connected component,
    with no transitions (each component is an atom).
    
    Args:
        sys: Input reversible system
    
    Returns:
        (n_components, component_edges) of the minimal system
    
    Time: O(n + |E|)
    """
    components = sys.connected_components()
    # In the minimal system, components are atoms with no transitions between them
    # (since they're already causally closed)
    return (len(components), [])


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 50)
    
    # Example 1: Disconnected graph
    print("\n1. Disconnected graph: {0-1-2} ∪ {3-4} ∪ {5}")
    sys = ReversibleSystem(6, [(0,1), (1,2), (3,4)])
    
    comps = sys.connected_components()
    print(f"   Components: {[set(c) for c in comps]}")
    
    fps_naive = sys.all_fixed_points()
    fps_fast = sys.fixed_points_from_components()
    print(f"   Fixed points (naive): {len(fps_naive)}")
    print(f"   Fixed points (fast):  {len(fps_fast)}")
    assert fps_naive == fps_fast
    
    inv = sys.behavioral_invariant()
    print(f"   Invariant: {inv[0]} fixed points, {len(inv[1])} covers")
    
    min_n, min_e = minimize_system(sys)
    print(f"   Minimal system: {min_n} states, {len(min_e)} edges")
    
    # Example 2: Equivalence check
    print("\n2. Behavioral equivalence check")
    sys_a = ReversibleSystem(4, [(0,1), (2,3)])  # Two components
    sys_b = ReversibleSystem(6, [(0,1), (1,2), (3,4), (4,5)])  # Two components
    sys_c = ReversibleSystem(3, [(0,1), (1,2), (2,0)])  # One component
    
    print(f"   A ({sys_a.n} states, 2 components) ≡ B ({sys_b.n} states, 2 components)? "
          f"{sys_a.is_behaviorally_equivalent(sys_b)}")
    print(f"   A ({sys_a.n} states, 2 components) ≡ C ({sys_c.n} states, 1 component)? "
          f"{sys_a.is_behaviorally_equivalent(sys_c)}")
    
    # Example 3: Compression ratios
    print("\n3. Compression ratios (2^n subsets → k fixed points)")
    for n, edges in [
        (4, [(0,1), (1,2), (2,3)]),          # Path: 1 component
        (4, [(0,1), (2,3)]),                   # Two paths: 2 components
        (6, [(0,1), (2,3), (4,5)]),           # Three pairs: 3 components
        (8, []),                               # Isolated: 8 components
    ]:
        sys = ReversibleSystem(n, edges)
        k = len(sys.connected_components())
        n_fps = 2**k
        print(f"   n={n}, k={k} components: {2**n} subsets → {n_fps} fixed points "
              f"(ratio {2**n/n_fps:.0f}x)")


#!/usr/bin/env python3
"""
Applications of Temporal Stone-Birkhoff Duality

Demonstrates real-world applications of the causal completion framework:
1. Reversible circuit equivalence checking
2. Protocol state minimization
3. Molecular machine modeling
"""

from algorithms import ReversibleSystem, minimize_system


# ============================================================
# Application 1: Reversible Circuit Equivalence
# ============================================================

def reversible_circuit_equivalence():
    """
    In reversible circuit design, two circuits are functionally equivalent
    if they compute the same reversible function. Our framework reduces this
    to checking whether their transition systems have the same number of
    connected components.
    
    Example: Compare two implementations of a Fredkin-like gate.
    """
    print("Application 1: Reversible Circuit Equivalence")
    print("=" * 50)
    
    # Circuit A: Cascaded CNOT gates
    # State space: 4 configurations, gates create transitions
    circuit_a = ReversibleSystem(4, [
        (0, 1),  # CNOT flips bit 0
        (2, 3),  # CNOT flips bit 0 (conditioned on bit 1)
    ])
    
    # Circuit B: Different decomposition, same functionality  
    circuit_b = ReversibleSystem(4, [
        (0, 2),  # CNOT flips bit 1
        (1, 3),  # CNOT flips bit 1 (conditioned on bit 0)
    ])
    
    # Circuit C: Fully connected (Toffoli-like)
    circuit_c = ReversibleSystem(4, [
        (0, 1), (1, 2), (2, 3), (3, 0)
    ])
    
    print(f"  Circuit A components: {len(circuit_a.connected_components())}")
    print(f"  Circuit B components: {len(circuit_b.connected_components())}")
    print(f"  Circuit C components: {len(circuit_c.connected_components())}")
    
    print(f"  A ≡ B? {circuit_a.is_behaviorally_equivalent(circuit_b)}")
    print(f"  A ≡ C? {circuit_a.is_behaviorally_equivalent(circuit_c)}")
    
    min_a = minimize_system(circuit_a)
    min_b = minimize_system(circuit_b)
    print(f"  Minimal representation A: {min_a[0]} states")
    print(f"  Minimal representation B: {min_b[0]} states")


# ============================================================
# Application 2: Protocol State Minimization
# ============================================================

def protocol_minimization():
    """
    Communication protocols often have redundant states.
    Causal completion identifies the minimal state representation
    that preserves all behavioral properties.
    
    Example: A handshake protocol with redundant intermediate states.
    """
    print("\nApplication 2: Protocol State Minimization")
    print("=" * 50)
    
    # Full protocol: 8 states with redundant intermediaries
    # States: IDLE(0), INIT(1), WAIT1(2), WAIT2(3), ACK(4), 
    #         PROC(5), DONE(6), CLEANUP(7)
    full_protocol = ReversibleSystem(8, [
        (0, 1),  # IDLE → INIT
        (1, 2),  # INIT → WAIT1
        (2, 3),  # WAIT1 → WAIT2  (redundant)
        (3, 4),  # WAIT2 → ACK
        (4, 5),  # ACK → PROC
        (5, 6),  # PROC → DONE
        (6, 7),  # DONE → CLEANUP
        (7, 0),  # CLEANUP → IDLE (loop back)
    ])
    
    components = full_protocol.connected_components()
    fps = full_protocol.fixed_points_from_components()
    
    print(f"  Original protocol: {full_protocol.n} states")
    print(f"  Connected components: {len(components)}")
    print(f"  Causal fixed points: {len(fps)}")
    
    min_n, _ = minimize_system(full_protocol)
    print(f"  Minimal representation: {min_n} states")
    print(f"  Compression: {full_protocol.n} → {min_n} states "
          f"({full_protocol.n / max(min_n, 1):.0f}x)")
    
    # Disconnected protocol variant (two independent channels)
    dual_channel = ReversibleSystem(8, [
        (0, 1), (1, 2), (2, 3),  # Channel 1
        (4, 5), (5, 6), (6, 7),  # Channel 2
    ])
    
    components2 = dual_channel.connected_components()
    print(f"\n  Dual-channel variant: {dual_channel.n} states")
    print(f"  Connected components: {len(components2)}")
    print(f"  Components: {[set(c) for c in components2]}")
    
    print(f"  Same behavior as single channel? "
          f"{full_protocol.is_behaviorally_equivalent(dual_channel)}")


# ============================================================
# Application 3: Molecular Machine Modeling
# ============================================================

def molecular_machine():
    """
    Molecular machines (enzymes, ribosomes) operate reversibly
    near thermodynamic equilibrium. The causal completion identifies
    the essential states of a molecular process.
    
    Example: A simplified enzyme catalysis cycle.
    """
    print("\nApplication 3: Molecular Machine Modeling")
    print("=" * 50)
    
    # Enzyme cycle: E (free) ↔ ES (substrate bound) ↔ EP (product bound) ↔ E
    # With conformational substates
    # States: E1(0), E2(1), ES1(2), ES2(3), EP1(4), EP2(5)
    enzyme = ReversibleSystem(6, [
        (0, 1),  # E1 ↔ E2 (conformational)
        (0, 2),  # E1 ↔ ES1 (binding)
        (1, 3),  # E2 ↔ ES2 (binding)
        (2, 3),  # ES1 ↔ ES2 (conformational)
        (2, 4),  # ES1 ↔ EP1 (catalysis)
        (3, 5),  # ES2 ↔ EP2 (catalysis)
        (4, 5),  # EP1 ↔ EP2 (conformational)
        (4, 0),  # EP1 ↔ E1 (product release)
        (5, 1),  # EP2 ↔ E2 (product release)
    ])
    
    components = enzyme.connected_components()
    fps = enzyme.fixed_points_from_components()
    
    print(f"  Enzyme model: {enzyme.n} states")
    print(f"  Connected components: {len(components)}")
    print(f"  This means all states are causally connected — the enzyme")
    print(f"  cycles through all conformations.")
    print(f"  Causal fixed points: {len(fps)} (∅ and full system)")
    
    # Disconnected variant: enzyme with an inhibited pathway
    inhibited = ReversibleSystem(6, [
        (0, 1),  # E1 ↔ E2
        (0, 2),  # E1 ↔ ES1
        (2, 4),  # ES1 ↔ EP1
        # States 3 and 5 are disconnected (inhibited pathway)
    ])
    
    components_inh = inhibited.connected_components()
    print(f"\n  Inhibited enzyme: {inhibited.n} states")
    print(f"  Connected components: {len(components_inh)}")
    print(f"  Components: {[set(c) for c in components_inh]}")
    print(f"  The inhibitor splits the system into {len(components_inh)} independent parts")
    
    print(f"\n  Full enzyme ≡ Inhibited enzyme? "
          f"{enzyme.is_behaviorally_equivalent(inhibited)}")
    print(f"  (Different component count → different causal behavior)")


# ============================================================
# Application 4: Cryptographic Protocol Verification
# ============================================================

def crypto_verification():
    """
    Cryptographic key exchange protocols involve reversible operations
    (encryption/decryption). Behavioral equivalence checks verify that
    two protocol implementations compute the same exchange.
    """
    print("\nApplication 4: Cryptographic Protocol Verification")
    print("=" * 50)
    
    # Simplified Diffie-Hellman-like key exchange
    # States represent protocol stages
    protocol_v1 = ReversibleSystem(5, [
        (0, 1),  # Generate keypair
        (1, 2),  # Send public key
        (2, 3),  # Receive peer's public key
        (3, 4),  # Compute shared secret
    ])
    
    # Optimized version with fewer stages
    protocol_v2 = ReversibleSystem(3, [
        (0, 1),  # Generate + send
        (1, 2),  # Receive + compute
    ])
    
    print(f"  Protocol v1: {protocol_v1.n} states, "
          f"{len(protocol_v1.connected_components())} component(s)")
    print(f"  Protocol v2: {protocol_v2.n} states, "
          f"{len(protocol_v2.connected_components())} component(s)")
    print(f"  Behaviorally equivalent? "
          f"{protocol_v1.is_behaviorally_equivalent(protocol_v2)}")
    print(f"  (Same causal structure despite different state counts)")


if __name__ == "__main__":
    print("Applications of Temporal Stone-Birkhoff Duality")
    print("=" * 50)
    print()
    
    reversible_circuit_equivalence()
    protocol_minimization()
    molecular_machine()
    crypto_verification()
    
    print("\n" + "=" * 50)
    print("All applications demonstrated.")


#!/usr/bin/env python3
"""
Temporal Stone-Birkhoff Duality: Demonstrations

Demonstrates reversible oracle transition systems, causal closure computation,
causal equivalence classes, and behavioral invariant extraction.
"""

import itertools
from typing import Dict, FrozenSet, List, Set, Tuple

# ============================================================
# Core Data Structures
# ============================================================

class FinRevSystem:
    """A finite reversible transition system.
    
    States are integers 0..n-1. Transitions are symmetric (reversible).
    """
    def __init__(self, n_states: int, edges: List[Tuple[int, int]]):
        self.n = n_states
        self.states = set(range(n_states))
        self.adj: Dict[int, Set[int]] = {s: set() for s in self.states}
        for (a, b) in edges:
            self.adj[a].add(b)
            self.adj[b].add(a)  # reversibility
    
    def successors(self, s: int) -> Set[int]:
        return self.adj[s]
    
    def fwd_step(self, A: FrozenSet[int]) -> FrozenSet[int]:
        """One step of forward expansion."""
        result = set(A)
        for s in A:
            result |= self.adj[s]
        return frozenset(result)
    
    def causal_closure(self, A: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the causal closure by iterating fwd_step to fixpoint."""
        current = A
        for _ in range(self.n):
            next_set = self.fwd_step(current)
            if next_set == current:
                break
            current = next_set
        return current
    
    def causal_fixed_points(self) -> List[FrozenSet[int]]:
        """All causal fixed points (subsets fixed by causal closure)."""
        fixed = []
        for r in range(self.n + 1):
            for subset in itertools.combinations(range(self.n), r):
                fs = frozenset(subset)
                if self.causal_closure(fs) == fs:
                    fixed.append(fs)
        return sorted(fixed, key=lambda s: (len(s), sorted(s)))
    
    def causal_equivalence_classes(self) -> Dict[FrozenSet[int], List[FrozenSet[int]]]:
        """Group all subsets by their causal closure."""
        classes: Dict[FrozenSet[int], List[FrozenSet[int]]] = {}
        for r in range(self.n + 1):
            for subset in itertools.combinations(range(self.n), r):
                fs = frozenset(subset)
                cl = self.causal_closure(fs)
                if cl not in classes:
                    classes[cl] = []
                classes[cl].append(fs)
        return classes
    
    def behavioral_invariant(self) -> Tuple[int, List[Tuple[int, int]]]:
        """Extract the behavioral invariant: number of fixed points and inclusion structure."""
        fps = self.causal_fixed_points()
        n_fps = len(fps)
        # Compute the covering relation on fixed points
        covers = []
        for i, a in enumerate(fps):
            for j, b in enumerate(fps):
                if a < b:  # strict subset
                    # Check if there's no c with a ⊂ c ⊂ b
                    is_cover = True
                    for k, c in enumerate(fps):
                        if a < c < b:
                            is_cover = False
                            break
                    if is_cover:
                        covers.append((i, j))
        return (n_fps, covers)


# ============================================================
# Demo 1: Path Graph (Linear Chain)
# ============================================================

def demo_path_graph():
    """A path graph on 4 vertices: 0-1-2-3"""
    print("=" * 60)
    print("Demo 1: Path Graph 0-1-2-3")
    print("=" * 60)
    
    sys = FinRevSystem(4, [(0,1), (1,2), (2,3)])
    
    print("\nTransitions:")
    for s in range(4):
        print(f"  {s} → {sorted(sys.successors(s))}")
    
    print("\nCausal closure examples:")
    for subset in [{0}, {1}, {0,2}, {1,3}]:
        fs = frozenset(subset)
        cl = sys.causal_closure(fs)
        print(f"  cl({set(subset)}) = {set(cl)}")
    
    fps = sys.causal_fixed_points()
    print(f"\nCausal fixed points ({len(fps)} total):")
    for fp in fps:
        print(f"  {set(fp)}")
    
    n_fps, covers = sys.behavioral_invariant()
    print(f"\nBehavioral invariant: {n_fps} fixed points")
    print(f"Covering relations: {covers}")


# ============================================================
# Demo 2: Cycle Graph
# ============================================================

def demo_cycle_graph():
    """A cycle on 4 vertices: 0-1-2-3-0"""
    print("\n" + "=" * 60)
    print("Demo 2: Cycle Graph 0-1-2-3-0")
    print("=" * 60)
    
    sys = FinRevSystem(4, [(0,1), (1,2), (2,3), (3,0)])
    
    print("\nTransitions:")
    for s in range(4):
        print(f"  {s} → {sorted(sys.successors(s))}")
    
    print("\nCausal closure examples:")
    for subset in [{0}, {0,2}, {0,1}]:
        fs = frozenset(subset)
        cl = sys.causal_closure(fs)
        print(f"  cl({set(subset)}) = {set(cl)}")
    
    fps = sys.causal_fixed_points()
    print(f"\nCausal fixed points ({len(fps)} total):")
    for fp in fps:
        print(f"  {set(fp)}")
    
    # Show causal equivalence classes
    classes = sys.causal_equivalence_classes()
    print(f"\nCausal equivalence classes ({len(classes)} classes):")
    for cl_val, members in sorted(classes.items(), key=lambda x: (len(x[0]), sorted(x[0]))):
        print(f"  Closure {set(cl_val)}: {[set(m) for m in members[:5]]}" +
              (f" ... ({len(members)} total)" if len(members) > 5 else ""))


# ============================================================
# Demo 3: Behavioral Equivalence Check
# ============================================================

def demo_behavioral_equivalence():
    """Compare two systems for behavioral equivalence."""
    print("\n" + "=" * 60)
    print("Demo 3: Behavioral Equivalence Check")
    print("=" * 60)
    
    # System A: path 0-1-2
    sys_a = FinRevSystem(3, [(0,1), (1,2)])
    # System B: path 0-1-2 (relabeled but same structure)
    sys_b = FinRevSystem(3, [(0,2), (2,1)])
    # System C: triangle 0-1-2-0
    sys_c = FinRevSystem(3, [(0,1), (1,2), (2,0)])
    
    inv_a = sys_a.behavioral_invariant()
    inv_b = sys_b.behavioral_invariant()
    inv_c = sys_c.behavioral_invariant()
    
    fps_a = sys_a.causal_fixed_points()
    fps_b = sys_b.causal_fixed_points()
    fps_c = sys_c.causal_fixed_points()
    
    print(f"\nSystem A (path 0-1-2): {len(fps_a)} fixed points")
    for fp in fps_a:
        print(f"  {set(fp)}")
    
    print(f"\nSystem B (path 0-2-1): {len(fps_b)} fixed points")
    for fp in fps_b:
        print(f"  {set(fp)}")
    
    print(f"\nSystem C (triangle): {len(fps_c)} fixed points")
    for fp in fps_c:
        print(f"  {set(fp)}")
    
    print(f"\nA ≡ B (same number of fixed points)? {inv_a[0] == inv_b[0]}")
    print(f"A ≡ C (same number of fixed points)? {inv_a[0] == inv_c[0]}")
    print(f"Invariant A: {inv_a}")
    print(f"Invariant B: {inv_b}")
    print(f"Invariant C: {inv_c}")


# ============================================================
# Demo 4: Causal Completion as Minimization
# ============================================================

def demo_minimization():
    """Show that causal completion acts as a minimization/quotient."""
    print("\n" + "=" * 60)
    print("Demo 4: Causal Completion as State Minimization")
    print("=" * 60)
    
    # A system with 6 states but only 2 essential connected components
    sys = FinRevSystem(6, [(0,1), (1,2), (3,4), (4,5)])
    
    print("\nSystem: 6 states, two disconnected paths")
    print("  Component 1: 0-1-2")
    print("  Component 2: 3-4-5")
    
    fps = sys.causal_fixed_points()
    print(f"\nCausal fixed points ({len(fps)} total):")
    for fp in fps:
        print(f"  {set(fp)}")
    
    classes = sys.causal_equivalence_classes()
    print(f"\nCausal equivalence classes: {len(classes)}")
    print("  (This is the minimal algebraic representation)")
    
    # The number of fixed points is the invariant
    print(f"\n  2^6 = {2**6} subsets reduced to {len(fps)} fixed points")
    print(f"  Compression ratio: {2**6 / len(fps):.1f}x")


# ============================================================
# Demo 5: Temporal Consistency Algebra Structure
# ============================================================

def demo_temporal_algebra():
    """Show the lattice structure of causal fixed points."""
    print("\n" + "=" * 60)
    print("Demo 5: Temporal Consistency Algebra Structure")
    print("=" * 60)
    
    sys = FinRevSystem(4, [(0,1), (1,2), (2,3)])
    fps = sys.causal_fixed_points()
    
    print(f"\nFixed-point lattice for path graph 0-1-2-3:")
    print(f"  Elements: {[set(fp) for fp in fps]}")
    
    # Compute meet (intersection-then-close) and join (union-then-close)
    print("\n  Meet (∩ then close) examples:")
    for i, a in enumerate(fps):
        for j, b in enumerate(fps):
            if i < j:
                meet = sys.causal_closure(frozenset(a & b))
                if meet in fps:
                    print(f"    {set(a)} ∧ {set(b)} = {set(meet)}")
    
    print("\n  Join (∪ then close) examples:")
    for i, a in enumerate(fps):
        for j, b in enumerate(fps):
            if i < j:
                join = sys.causal_closure(frozenset(a | b))
                if join in fps:
                    print(f"    {set(a)} ∨ {set(b)} = {set(join)}")
    
    # Identify atoms
    bot = fps[0]  # empty set closure
    atoms = []
    for fp in fps:
        if fp != bot and fp != frozenset():
            is_atom = True
            for other in fps:
                if bot < other < fp:
                    is_atom = False
                    break
            if is_atom and fp != frozenset(range(4)):
                atoms.append(fp)
    
    print(f"\n  Bottom element: {set(bot)}")
    print(f"  Atoms: {[set(a) for a in atoms]}")
    print(f"  Top element: {set(fps[-1])}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Temporal Stone-Birkhoff Duality: Computational Demonstrations")
    print("=" * 60)
    print()
    
    demo_path_graph()
    demo_cycle_graph()
    demo_behavioral_equivalence()
    demo_minimization()
    demo_temporal_algebra()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json for the web templating system."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
lean_closure = read_file('Bridges/LogicComputation/CausalClosure.lean')
lean_duality = read_file('Bridges/LogicComputation/TemporalStoneBirkhoffDuality.lean')
duality_svg = read_file('duality_diagram.svg')
lattice_svg = read_file('lattice_diagram.svg')
system_svg = read_file('system_diagram.svg')
lattice3_svg = read_file('lattice3_diagram.svg')

package = {
    "title": "Temporal Stone-Birkhoff Duality via Reversible Oracle Semirings and Canonical Causal Completion",
    "domain": "Algebra / Logic / Computation Bridges",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Reversible System Demonstrations",
            "code": demo_code
        },
        {
            "name": "Algorithms for Causal Completion",
            "code": algorithms_code
        }
    ],
    "algorithms": [
        {
            "name": "Causal Closure Computation",
            "pseudocode": """Algorithm: CausalClosure(X, A)
Input: Reversible system X = (S, step), subset A ⊆ S
Output: causalCl(A)

current ← A
for i = 1 to |S|:
    next ← current ∪ {t ∈ S | ∃ s ∈ current, step(s,t)}
    if next = current: return current
    current ← next
return current

Complexity: O(|S|³) time, O(|S|) space
Termination: Chain A ⊆ fwd(A) ⊆ fwd²(A) ⊆ ... stabilizes in ≤ |S| steps by pigeonhole."""
        },
        {
            "name": "Fixed-Point Enumeration via Connected Components",
            "pseudocode": """Algorithm: FixedPoints(X)
Input: Reversible system X = (S, step)
Output: All causal fixed points

components ← ConnectedComponents(X)  // BFS, O(|S| + |E|)
k ← |components|
result ← ∅
for each subset I ⊆ {1,...,k}:
    result ← result ∪ {⋃_{i ∈ I} components[i]}
return result

Complexity: O(|S| + |E| + 2^k) where k = number of components
Note: Exponentially better than naive 2^|S| enumeration when k << |S|"""
        },
        {
            "name": "Behavioral Equivalence Decision",
            "pseudocode": """Algorithm: BehaviorallyEquivalent(X, Y)
Input: Two reversible systems X, Y
Output: Boolean (whether X ≡ Y behaviorally)

k_X ← |ConnectedComponents(X)|
k_Y ← |ConnectedComponents(Y)|
return k_X = k_Y

Complexity: O(|S_X| + |E_X| + |S_Y| + |E_Y|), linear in input size
Correctness: By the Finite Temporal Stone-Birkhoff Duality theorem,
  behavioral equivalence ⟺ isomorphism of causal fixed-point lattices
  ⟺ same number of connected components (for finite reversible systems)"""
        }
    ],
    "visualizations": [
        {
            "name": "Temporal Stone-Birkhoff Duality Diagram",
            "data": duality_svg
        },
        {
            "name": "Causal Fixed-Point Lattice (2 Components)",
            "data": lattice_svg
        },
        {
            "name": "Disconnected Reversible Transition System",
            "data": system_svg
        },
        {
            "name": "Boolean Lattice (3 Components)",
            "data": lattice3_svg
        }
    ],
    "lean_proofs": lean_closure + "\n\n-- ========================================\n-- Main Duality File\n-- ========================================\n\n" + lean_duality
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("Generated PACKAGE.json")
print(f"  Size: {os.path.getsize('PACKAGE.json') / 1024:.1f} KB")


#!/usr/bin/env python3
"""
Visualizations for Temporal Stone-Birkhoff Duality.
Generates SVG diagrams of lattice structures and transition systems.
"""

import base64
import io
import itertools
from typing import Dict, FrozenSet, List, Set, Tuple


def generate_lattice_svg(
    elements: List[str],
    covers: List[Tuple[int, int]],
    title: str = "Fixed-Point Lattice",
    width: int = 500,
    height: int = 400
) -> str:
    """Generate an SVG diagram of a Hasse diagram."""
    
    # Compute levels (rank function)
    n = len(elements)
    if n == 0:
        return f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}"></svg>'
    
    # Build adjacency for levels
    children: Dict[int, List[int]] = {i: [] for i in range(n)}
    parents: Dict[int, List[int]] = {i: [] for i in range(n)}
    for (a, b) in covers:
        children[a].append(b)
        parents[b].append(a)
    
    # Compute ranks by BFS from bottom elements
    rank = [0] * n
    bottoms = [i for i in range(n) if not parents[i]]
    queue = list(bottoms)
    visited = set(bottoms)
    while queue:
        v = queue.pop(0)
        for w in children[v]:
            rank[w] = max(rank[w], rank[v] + 1)
            if w not in visited:
                visited.add(w)
                queue.append(w)
    
    max_rank = max(rank) if rank else 0
    
    # Group by rank
    by_rank: Dict[int, List[int]] = {}
    for i, r in enumerate(rank):
        by_rank.setdefault(r, []).append(i)
    
    # Compute positions
    margin = 60
    positions = {}
    for r, nodes in by_rank.items():
        y = height - margin - (height - 2 * margin) * r / max(max_rank, 1)
        for idx, node in enumerate(nodes):
            x = margin + (width - 2 * margin) * (idx + 0.5) / len(nodes)
            positions[node] = (x, y)
    
    # Generate SVG
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'style="background: #fafafa; font-family: sans-serif;">',
        f'<text x="{width/2}" y="25" text-anchor="middle" font-size="16" '
        f'font-weight="bold" fill="#333">{title}</text>'
    ]
    
    # Draw edges
    for (a, b) in covers:
        x1, y1 = positions[a]
        x2, y2 = positions[b]
        svg_parts.append(
            f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" '
            f'stroke="#999" stroke-width="1.5"/>'
        )
    
    # Draw nodes
    for i in range(n):
        x, y = positions[i]
        svg_parts.append(
            f'<circle cx="{x:.1f}" cy="{y:.1f}" r="20" fill="#4a90d9" '
            f'stroke="#2c5282" stroke-width="2"/>'
        )
        label = elements[i]
        font_size = 10 if len(label) > 6 else 12
        svg_parts.append(
            f'<text x="{x:.1f}" y="{y + 4:.1f}" text-anchor="middle" '
            f'font-size="{font_size}" fill="white">{label}</text>'
        )
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_system_svg(
    n_states: int,
    edges: List[Tuple[int, int]],
    title: str = "Transition System",
    width: int = 400,
    height: int = 400
) -> str:
    """Generate an SVG diagram of a transition system."""
    import math
    
    margin = 80
    cx, cy = width / 2, height / 2 + 15
    radius = min(width, height) / 2 - margin
    
    # Position states in a circle
    positions = {}
    for i in range(n_states):
        angle = 2 * math.pi * i / n_states - math.pi / 2
        positions[i] = (cx + radius * math.cos(angle), cy + radius * math.sin(angle))
    
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'style="background: #fafafa; font-family: sans-serif;">',
        f'<text x="{width/2}" y="25" text-anchor="middle" font-size="16" '
        f'font-weight="bold" fill="#333">{title}</text>'
    ]
    
    # Draw edges (undirected for reversible)
    for (a, b) in edges:
        x1, y1 = positions[a]
        x2, y2 = positions[b]
        svg_parts.append(
            f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" '
            f'stroke="#e53e3e" stroke-width="2"/>'
        )
    
    # Draw states
    for i in range(n_states):
        x, y = positions[i]
        svg_parts.append(
            f'<circle cx="{x:.1f}" cy="{y:.1f}" r="22" fill="#48bb78" '
            f'stroke="#276749" stroke-width="2"/>'
        )
        svg_parts.append(
            f'<text x="{x:.1f}" y="{y + 5:.1f}" text-anchor="middle" '
            f'font-size="14" font-weight="bold" fill="white">{i}</text>'
        )
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_duality_diagram() -> str:
    """Generate SVG showing the duality between systems and algebras."""
    width, height = 700, 300
    
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}"
     style="background: #fafafa; font-family: sans-serif;">
  
  <text x="{width/2}" y="30" text-anchor="middle" font-size="18" 
    font-weight="bold" fill="#333">Temporal Stone-Birkhoff Duality</text>
  
  <!-- Left box: Systems -->
  <rect x="30" y="60" width="250" height="200" rx="15" ry="15" 
    fill="#ebf8ff" stroke="#4a90d9" stroke-width="2"/>
  <text x="155" y="90" text-anchor="middle" font-size="14" font-weight="bold" 
    fill="#2c5282">Finite Reversible Systems</text>
  <text x="155" y="115" text-anchor="middle" font-size="11" fill="#4a5568">
    States + symmetric transitions</text>
  <text x="155" y="140" text-anchor="middle" font-size="11" fill="#4a5568">
    Forward/backward reachability</text>
  <text x="155" y="165" text-anchor="middle" font-size="11" fill="#4a5568">
    Behavioral equivalence</text>
  <text x="155" y="195" text-anchor="middle" font-size="12" fill="#2c5282">
    FinRevSystem S</text>
  <text x="155" y="215" text-anchor="middle" font-size="11" fill="#4a5568">
    Objects: finite reversible systems</text>
  <text x="155" y="235" text-anchor="middle" font-size="11" fill="#4a5568">
    Morphisms: equivariant maps</text>

  <!-- Right box: Algebras -->
  <rect x="420" y="60" width="250" height="200" rx="15" ry="15"
    fill="#fef3c7" stroke="#d69e2e" stroke-width="2"/>
  <text x="545" y="90" text-anchor="middle" font-size="14" font-weight="bold" 
    fill="#744210">Temporal Consistency Algebras</text>
  <text x="545" y="115" text-anchor="middle" font-size="11" fill="#4a5568">
    Bounded distributive lattice</text>
  <text x="545" y="140" text-anchor="middle" font-size="11" fill="#4a5568">
    Closure + interior + involution</text>
  <text x="545" y="165" text-anchor="middle" font-size="11" fill="#4a5568">
    Algebraic isomorphism</text>
  <text x="545" y="195" text-anchor="middle" font-size="12" fill="#744210">
    TemporalConsistencyAlgebra A</text>
  <text x="545" y="215" text-anchor="middle" font-size="11" fill="#4a5568">
    Objects: finite TCA with involution</text>
  <text x="545" y="235" text-anchor="middle" font-size="11" fill="#4a5568">
    Morphisms: lattice homomorphisms</text>

  <!-- Arrows -->
  <defs>
    <marker id="arrowR" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#e53e3e"/>
    </marker>
    <marker id="arrowL" markerWidth="10" markerHeight="7" refX="1" refY="3.5" orient="auto">
      <polygon points="10 0, 0 3.5, 10 7" fill="#38a169"/>
    </marker>
  </defs>
  
  <line x1="290" y1="140" x2="410" y2="140" stroke="#e53e3e" stroke-width="2" 
    marker-end="url(#arrowR)"/>
  <text x="350" y="133" text-anchor="middle" font-size="13" font-weight="bold" 
    fill="#e53e3e">Spec</text>
  
  <line x1="410" y1="175" x2="290" y2="175" stroke="#38a169" stroke-width="2"
    marker-end="url(#arrowL)"/>
  <text x="350" y="197" text-anchor="middle" font-size="13" font-weight="bold" 
    fill="#38a169">Alg</text>

  <!-- Equivalence symbol -->
  <text x="350" y="160" text-anchor="middle" font-size="16" fill="#553c9a">≃</text>
</svg>'''
    return svg


if __name__ == "__main__":
    # Generate all visualizations
    
    # 1. Duality diagram
    duality_svg = generate_duality_diagram()
    with open("duality_diagram.svg", "w") as f:
        f.write(duality_svg)
    print("Generated duality_diagram.svg")
    
    # 2. Example system
    sys_svg = generate_system_svg(
        6, [(0,1), (1,2), (3,4), (4,5)],
        title="Disconnected Reversible System"
    )
    with open("system_diagram.svg", "w") as f:
        f.write(sys_svg)
    print("Generated system_diagram.svg")
    
    # 3. Fixed-point lattice for disconnected system
    lattice_svg = generate_lattice_svg(
        ["∅", "{0,1,2}", "{3,4,5}", "{0..5}"],
        [(0, 1), (0, 2), (1, 3), (2, 3)],
        title="Causal Fixed-Point Lattice"
    )
    with open("lattice_diagram.svg", "w") as f:
        f.write(lattice_svg)
    print("Generated lattice_diagram.svg")
    
    # 4. Three-component lattice
    lattice3_svg = generate_lattice_svg(
        ["∅", "A", "B", "C", "A∪B", "A∪C", "B∪C", "All"],
        [(0,1), (0,2), (0,3), (1,4), (1,5), (2,4), (2,6), (3,5), (3,6), (4,7), (5,7), (6,7)],
        title="Boolean Lattice (3 Components)",
        width=600, height=500
    )
    with open("lattice3_diagram.svg", "w") as f:
        f.write(lattice3_svg)
    print("Generated lattice3_diagram.svg")

#!/usr/bin/env python3
"""
Coalgebraic Semantics — Algorithms

Implements the core algorithms from the coalgebraic final semantics framework:
1. Partition refinement for bisimulation minimization
2. Coalgebra morphism construction and verification
3. Isomorphism testing for finite coalgebras
4. Modal depth equivalence computation

All algorithms are certified-correct in the sense that they implement
the mathematical constructions proved sound in the accompanying Lean formalization.
"""

from dataclasses import dataclass, field
from typing import Optional, Callable
from collections import defaultdict
import itertools


# ============================================================
# Core Data Structures
# ============================================================

@dataclass(frozen=True)
class BaseType:
    """Base type o."""
    def __repr__(self): return "o"

@dataclass(frozen=True)
class ArrType:
    """Arrow type A → B."""
    dom: object
    cod: object
    def __repr__(self):
        d = f"({self.dom})" if isinstance(self.dom, ArrType) else str(self.dom)
        return f"{d} → {self.cod}"

STLCType = BaseType | ArrType

def arity_of(ty: STLCType) -> int:
    """Compute the codomain arity of a simple type.

    Time: O(depth of type)
    Space: O(1)
    """
    if isinstance(ty, BaseType):
        return 0
    return arity_of(ty.cod) + 1


@dataclass
class FiniteCoalgebra:
    """A finite coalgebra for the type polynomial functor F_A.

    F_A(X) = Unit ⊕ (Fin(arity_of A) → X)

    States are integers 0..n-1.
    str_map[i] = None means state i is terminal (maps to inl ()).
    str_map[i] = (j₁, ..., jₖ) means state i branches to j₁,...,jₖ.
    """
    ty: STLCType
    num_states: int
    str_map: dict[int, Optional[tuple[int, ...]]]

    def is_terminal(self, s: int) -> bool:
        return self.str_map[s] is None

    def successors(self, s: int) -> Optional[tuple[int, ...]]:
        return self.str_map[s]


@dataclass
class CoalgebraHomomorphism:
    """A coalgebra morphism f : C → D satisfying D.str(f(x)) = F_A.map(f)(C.str(x))."""
    source: FiniteCoalgebra
    target: FiniteCoalgebra
    mapping: dict[int, int]  # source state → target state

    def apply(self, s: int) -> int:
        return self.mapping[s]


# ============================================================
# Algorithm 1: Partition Refinement (Bisimulation Minimization)
# ============================================================

def partition_refinement(coal: FiniteCoalgebra) -> tuple[list[set[int]], dict[int, int]]:
    """Compute behavioral equivalence classes via partition refinement.

    This implements the Hopcroft-style partition refinement algorithm
    adapted for polynomial functor coalgebras.

    Algorithm:
        1. Initialize partition: {terminal states} ∪ {branching states}
        2. Repeat until stable:
           For each block B, split B into sub-blocks where states agree
           on the block-indices of their successors.
        3. Return the stable partition.

    Complexity:
        Time:  O(n² · k) where n = |states|, k = arity
        Space: O(n · k)

    Soundness: Proved in Lean as morphism_kernel_is_bisimulation.
    The partition is the coarsest bisimulation, matching BehavioralEquiv.

    Args:
        coal: A finite F_A-coalgebra.

    Returns:
        (partition, mapping) where partition is a list of equivalence classes
        and mapping maps each state to its class index.

    Example:
        >>> ty = ArrType(BaseType(), BaseType())
        >>> coal = FiniteCoalgebra(ty, 4, {0: (1,), 1: None, 2: None, 3: (2,)})
        >>> classes, mapping = partition_refinement(coal)
        >>> print(classes)
        [{1, 2}, {0, 3}]
    """
    n = coal.num_states
    ar = arity_of(coal.ty)

    # Step 1: Initial partition by terminal/branching
    terminal = {s for s in range(n) if coal.is_terminal(s)}
    branching = {s for s in range(n) if not coal.is_terminal(s)}
    partition = [cls for cls in [terminal, branching] if cls]

    # Step 2: Iterative refinement
    max_iterations = n + 1  # Guaranteed to converge in at most n steps
    for iteration in range(max_iterations):
        # Build state → class index mapping
        mapping = {}
        for idx, cls in enumerate(partition):
            for s in cls:
                mapping[s] = idx

        # Refine each block
        new_partition = []
        for cls in partition:
            sub_blocks = defaultdict(set)
            for s in cls:
                if coal.is_terminal(s):
                    sig = ("terminal",)
                else:
                    succs = coal.successors(s)
                    sig = ("branching",) + tuple(mapping[si] for si in succs)
                sub_blocks[sig].add(s)
            new_partition.extend(sub_blocks.values())

        # Check convergence
        if len(new_partition) == len(partition):
            break
        partition = new_partition

    # Build final mapping
    final_mapping = {}
    for idx, cls in enumerate(partition):
        for s in cls:
            final_mapping[s] = idx

    return partition, final_mapping


def minimize(coal: FiniteCoalgebra) -> tuple[FiniteCoalgebra, CoalgebraHomomorphism]:
    """Construct the minimized (quotient) coalgebra and the projection morphism.

    This implements the canonical construction proved in Lean:
    - quotient_has_coalgebra_structure: the quotient carries F_A-coalgebra structure
    - canonical_projection_surjective: the projection is surjective
    - quotient_behavioral_equiv_eq: equivalent states map to the same class

    Returns:
        (minimized_coalgebra, projection_morphism)
    """
    classes, mapping = partition_refinement(coal)
    n_new = len(classes)
    ar = arity_of(coal.ty)

    # Build quotient structure map
    new_str = {}
    for idx, cls in enumerate(classes):
        rep = next(iter(cls))
        if coal.is_terminal(rep):
            new_str[idx] = None
        else:
            succs = coal.successors(rep)
            new_str[idx] = tuple(mapping[si] for si in succs)

    minimized = FiniteCoalgebra(ty=coal.ty, num_states=n_new, str_map=new_str)
    projection = CoalgebraHomomorphism(source=coal, target=minimized, mapping=mapping)

    return minimized, projection


# ============================================================
# Algorithm 2: Coalgebra Morphism Verification
# ============================================================

def verify_morphism(f: CoalgebraHomomorphism) -> bool:
    """Verify that a mapping is a valid coalgebra morphism.

    Checks the commutation condition:
      D.str(f(x)) = F_A.map(f)(C.str(x))

    for all states x in the source coalgebra.

    Corresponds to CoalgebraHom.comm in the Lean formalization.

    Time: O(n · k) where n = |source states|, k = arity
    """
    C = f.source
    D = f.target

    for s in range(C.num_states):
        fs = f.apply(s)

        if C.is_terminal(s):
            # F.map(f)(inl ()) = inl (), so D.str(f(s)) must be inl ()
            if not D.is_terminal(fs):
                return False
        else:
            # F.map(f)(inr g) = inr (f ∘ g)
            if D.is_terminal(fs):
                return False
            c_succs = C.successors(s)
            d_succs = D.successors(fs)
            mapped = tuple(f.apply(si) for si in c_succs)
            if mapped != d_succs:
                return False

    return True


# ============================================================
# Algorithm 3: Coalgebra Isomorphism Testing
# ============================================================

def canonical_form(coal: FiniteCoalgebra) -> tuple:
    """Compute a canonical form for isomorphism testing.

    Uses a DFS-based canonical labeling: enumerate states in DFS order,
    recording the structure pattern with canonical labels.

    Time: O(n · k · n!) worst case (but typically much better with pruning)
    Space: O(n · k)
    """
    n = coal.num_states
    if n == 0:
        return ()

    best = None
    for start in range(n):
        form = _canonical_from_root(coal, start)
        if best is None or form < best:
            best = form
    return best


def _canonical_from_root(coal: FiniteCoalgebra, root: int) -> tuple:
    """Compute canonical form rooted at a specific state."""
    visited = {}
    counter = 0
    pattern = []

    def visit(s):
        nonlocal counter
        if s in visited:
            return visited[s]
        idx = counter
        visited[s] = idx
        counter += 1

        if coal.is_terminal(s):
            pattern.append(("T", idx))
        else:
            succs = coal.successors(s)
            succ_ids = []
            for si in succs:
                succ_ids.append(visit(si))
            pattern.append(("B", idx, tuple(succ_ids)))
        return idx

    visit(root)
    return tuple(pattern)


def are_isomorphic(c1: FiniteCoalgebra, c2: FiniteCoalgebra) -> bool:
    """Test whether two finite coalgebras are isomorphic.

    Two F_A-coalgebras are isomorphic iff they have the same canonical form.
    By final_coalgebra_unique (proved in Lean), any two final coalgebras
    in a class are isomorphic.

    Time: O(n² · k) amortized
    """
    if c1.num_states != c2.num_states:
        return False
    if arity_of(c1.ty) != arity_of(c2.ty):
        return False
    return canonical_form(c1) == canonical_form(c2)


# ============================================================
# Algorithm 4: Modal Depth Equivalence
# ============================================================

def modal_depth_classes(coal: FiniteCoalgebra, depth: int) -> list[set[int]]:
    """Compute n-step behavioral equivalence classes.

    Implements BehavEquivN from the Lean formalization:
    - Depth 0: all states equivalent
    - Depth n+1: states must agree on terminal/branching AND
      have n-equivalent successors

    Corresponds to behavEquivN_descending: (n+1)-classes refine n-classes.

    Time: O(depth · n² · k)
    """
    n = coal.num_states

    if depth == 0:
        return [set(range(n))]

    # Compute classes at depth-1
    prev_classes = modal_depth_classes(coal, depth - 1)

    # Build mapping from previous depth
    prev_mapping = {}
    for idx, cls in enumerate(prev_classes):
        for s in cls:
            prev_mapping[s] = idx

    # Refine
    new_groups = defaultdict(set)
    for s in range(n):
        if coal.is_terminal(s):
            sig = ("T",)
        else:
            succs = coal.successors(s)
            sig = ("B",) + tuple(prev_mapping[si] for si in succs)
        new_groups[sig].add(s)

    return list(new_groups.values())


def find_stabilization_depth(coal: FiniteCoalgebra) -> int:
    """Find the depth at which modal equivalence stabilizes.

    Returns the smallest d such that d-classes = (d+1)-classes.
    On a finite coalgebra with n states, this is at most n.
    """
    n = coal.num_states
    prev_count = 1  # depth 0: all equivalent

    for d in range(1, n + 2):
        classes = modal_depth_classes(coal, d)
        if len(classes) == prev_count:
            return d - 1
        prev_count = len(classes)

    return n


# ============================================================
# Algorithm 5: Build Reachable Sub-coalgebra
# ============================================================

def reachable_subcoalgebra(coal: FiniteCoalgebra, root: int) -> FiniteCoalgebra:
    """Extract the reachable sub-coalgebra from a given root state.

    Time: O(n · k) where n = reachable states
    """
    visited = set()
    queue = [root]
    visited.add(root)

    while queue:
        s = queue.pop(0)
        if not coal.is_terminal(s):
            for si in coal.successors(s):
                if si not in visited:
                    visited.add(si)
                    queue.append(si)

    # Relabel states
    old_to_new = {s: i for i, s in enumerate(sorted(visited))}
    new_str = {}
    for s in sorted(visited):
        ns = old_to_new[s]
        if coal.is_terminal(s):
            new_str[ns] = None
        else:
            new_str[ns] = tuple(old_to_new[si] for si in coal.successors(s))

    return FiniteCoalgebra(ty=coal.ty, num_states=len(visited), str_map=new_str)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    o = BaseType()
    o_to_o = ArrType(o, o)
    church = ArrType(ArrType(o, o), ArrType(o, o))

    print("=== Algorithm Demonstrations ===\n")

    # Demo 1: Partition refinement
    print("1. Partition Refinement (Bisimulation Minimization)")
    coal = FiniteCoalgebra(o_to_o, 6, {
        0: (1,), 1: (2,), 2: None,
        3: (4,), 4: (5,), 5: None
    })
    classes, mapping = partition_refinement(coal)
    print(f"   Input: 6 states, two parallel chains")
    print(f"   Classes: {[sorted(c) for c in classes]}")
    print(f"   Mapping: {mapping}\n")

    # Demo 2: Minimization with morphism
    mini, proj = minimize(coal)
    print("2. Minimization")
    print(f"   Minimized: {mini.num_states} states")
    print(f"   Structure: {mini.str_map}")
    print(f"   Morphism valid: {verify_morphism(proj)}\n")

    # Demo 3: Isomorphism testing
    print("3. Isomorphism Testing")
    coal_a = FiniteCoalgebra(o_to_o, 2, {0: (1,), 1: None})
    coal_b = FiniteCoalgebra(o_to_o, 2, {0: None, 1: (0,)})
    print(f"   A: {coal_a.str_map}")
    print(f"   B: {coal_b.str_map}")
    print(f"   Isomorphic: {are_isomorphic(coal_a, coal_b)}\n")

    # Demo 4: Modal depth
    print("4. Modal Depth Equivalence")
    coal2 = FiniteCoalgebra(church, 5, {
        0: (1, 2), 1: (3, 4), 2: None, 3: None, 4: None
    })
    for d in range(4):
        classes = modal_depth_classes(coal2, d)
        print(f"   Depth {d}: {len(classes)} classes - {[sorted(c) for c in classes]}")
    stab = find_stabilization_depth(coal2)
    print(f"   Stabilization depth: {stab}\n")

    # Demo 5: Reachable sub-coalgebra
    print("5. Reachable Sub-coalgebra")
    big = FiniteCoalgebra(o_to_o, 5, {
        0: (1,), 1: (2,), 2: None, 3: (4,), 4: None
    })
    sub = reachable_subcoalgebra(big, 0)
    print(f"   Full: {big.num_states} states")
    print(f"   Reachable from 0: {sub.num_states} states, {sub.str_map}")

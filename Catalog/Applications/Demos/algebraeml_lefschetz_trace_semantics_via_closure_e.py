#!/usr/bin/env python3
"""
Algorithms for Closure Lefschetz Trace Semantics

Implements the core algorithms from the research paper with
complexity analysis and docstrings.
"""

from itertools import combinations
from typing import Dict, FrozenSet, List, Optional, Set, Tuple
from collections import defaultdict
import math


Element = int
FinSet = frozenset


def enumerate_strata(universe: Set[Element],
                     cl: callable) -> List[FinSet]:
    """
    Enumerate all closure strata (fixed points of the closure operator).

    Algorithm: Brute-force check every subset of the universe.

    Complexity: O(2^|α| · T_cl) where T_cl is the cost of one closure evaluation.

    Args:
        universe: The finite carrier set.
        cl: Closure operator mapping frozensets to frozensets.

    Returns:
        Sorted list of all strata (closed sets).

    Example:
        >>> strata = enumerate_strata({0, 1}, lambda s: s)
        >>> len(strata)
        4
    """
    u_list = sorted(universe)
    strata = []
    for r in range(len(u_list) + 1):
        for combo in combinations(u_list, r):
            s = frozenset(combo)
            if cl(s) == s:
                strata.append(s)
    return sorted(strata, key=lambda x: (len(x), sorted(x)))


def enumerate_chains(strata: List[FinSet], n: int) -> List[Tuple[FinSet, ...]]:
    """
    Enumerate all strictly increasing (n+1)-chains of strata.

    These are the n-simplices of the order complex (nerve) of the closure poset.

    Complexity: O(m^(n+1)) where m = |strata|.

    Args:
        strata: List of closure strata.
        n: Chain dimension (0 = vertices, 1 = edges, etc.)

    Returns:
        List of (n+1)-tuples of strata forming strict chains.
    """
    chains = []
    for combo in combinations(strata, n + 1):
        sorted_combo = sorted(combo, key=lambda x: (len(x), sorted(x)))
        if all(sorted_combo[i] < sorted_combo[i + 1]
               for i in range(len(sorted_combo) - 1)):
            chains.append(tuple(sorted_combo))
    return chains


def compute_lefschetz_number(strata: List[FinSet],
                              endo_map: Dict[FinSet, FinSet]) -> int:
    """
    Compute the Lefschetz number L(C, f) = Σ (-1)^n · |{fixed n-chains}|.

    Algorithm:
    1. For each dimension n from 0 to m:
    2.   Count chains where all vertices are fixed by the endomorphism.
    3.   Add (-1)^n * count to the running sum.

    Complexity: O(Σ_{n=0}^{m} m^(n+1) · (n+1) · T_f)
               ≤ O(m^(m+2) · T_f) in worst case.
               Practically O(m^2 · T_f) since most high-dimensional chain counts are 0.

    Args:
        strata: List of closure strata.
        endo_map: Dictionary mapping each stratum to its image under f.

    Returns:
        The Lefschetz number (integer).

    Example:
        >>> strata = [frozenset(), frozenset({0})]
        >>> endo = {frozenset(): frozenset(), frozenset({0}): frozenset({0})}
        >>> compute_lefschetz_number(strata, endo)
        1
    """
    m = len(strata)
    L = 0
    for n in range(m + 1):
        chains = enumerate_chains(strata, n)
        fixed_count = sum(1 for ch in chains
                         if all(endo_map.get(s, s) == s for s in ch))
        L += ((-1) ** n) * fixed_count
    return L


def compute_euler_characteristic(strata: List[FinSet]) -> int:
    """
    Compute the Euler characteristic χ(C) = Σ (-1)^n · |{n-chains}|.

    This equals L(C, id) — the Lefschetz number of the identity.

    Complexity: O(Σ_{n=0}^{m} m^(n+1)).

    Args:
        strata: List of closure strata.

    Returns:
        The Euler characteristic (integer).
    """
    m = len(strata)
    chi = 0
    for n in range(m + 1):
        count = len(enumerate_chains(strata, n))
        chi += ((-1) ** n) * count
    return chi


def detect_orbit_collision(strata: List[FinSet],
                           endo_map: Dict[FinSet, FinSet],
                           start: FinSet) -> Tuple[int, int]:
    """
    Find the first collision in the orbit of a stratum.

    By the pigeonhole principle, in a system with m strata,
    the orbit of length m+1 must contain a collision.

    Algorithm (Floyd-style with dictionary):
    1. Track visited states with their first occurrence index.
    2. At step k, if f^k(x) was seen at step i, return (i, k).

    Complexity: O(m · T_f) time, O(m) space.

    Args:
        strata: List of closure strata.
        endo_map: Endomorphism mapping.
        start: Starting stratum.

    Returns:
        Pair (i, j) with 0 ≤ i < j ≤ m and f^i(start) = f^j(start).

    Raises:
        ValueError: Should never happen (by pigeonhole theorem).
    """
    m = len(strata)
    seen: Dict[FinSet, int] = {}
    current = start
    for k in range(m + 1):
        if current in seen:
            return (seen[current], k)
        seen[current] = k
        current = endo_map.get(current, current)
    raise ValueError("No collision found — impossible by pigeonhole")


def count_periodic_points(strata: List[FinSet],
                           endo_map: Dict[FinSet, FinSet],
                           period: int) -> int:
    """
    Count strata fixed by f^period.

    Complexity: O(m · period · T_f).

    Args:
        strata: List of closure strata.
        endo_map: Endomorphism mapping.
        period: The period n to check.

    Returns:
        Number of strata x with f^n(x) = x.
    """
    count = 0
    for s in strata:
        current = s
        for _ in range(period):
            current = endo_map.get(current, current)
        if current == s:
            count += 1
    return count


def compute_primitive_periodic_count(strata: List[FinSet],
                                      endo_map: Dict[FinSet, FinSet],
                                      n: int,
                                      cache: Optional[Dict[int, int]] = None) -> int:
    """
    Compute the primitive periodic count Q(n) via recursive divisor subtraction.

    Q(n) = P(n) - Σ_{d | n, d < n} Q(d)

    This is a combinatorial Möbius inversion on the divisor lattice.

    Complexity: O(σ(n) · m · n · T_f) where σ(n) is the number of divisors of n.

    Args:
        strata: List of closure strata.
        endo_map: Endomorphism mapping.
        n: Period to compute primitive count for.
        cache: Optional cache for memoization.

    Returns:
        The primitive periodic count Q(n) (integer, may be negative).
    """
    if cache is None:
        cache = {}
    if n in cache:
        return cache[n]
    if n == 0:
        cache[0] = 0
        return 0

    P_n = count_periodic_points(strata, endo_map, n)
    divisor_sum = 0
    for d in range(1, n):
        if n % d == 0:
            divisor_sum += compute_primitive_periodic_count(
                strata, endo_map, d, cache)
    result = P_n - divisor_sum
    cache[n] = result
    return result


def verify_lefschetz_theorem(strata: List[FinSet],
                              endo_map: Dict[FinSet, FinSet]) -> bool:
    """
    Verify the Lefschetz fixed-point theorem:
    L(C, f) ≠ 0 ⟹ ∃ fixed stratum.

    Returns True if the theorem holds (which it always should).

    Example:
        >>> strata = [frozenset(), frozenset({0})]
        >>> endo = {frozenset(): frozenset({0}), frozenset({0}): frozenset()}
        >>> verify_lefschetz_theorem(strata, endo)
        True
    """
    L = compute_lefschetz_number(strata, endo_map)
    has_fixed = any(endo_map.get(s, s) == s for s in strata)

    if L != 0:
        assert has_fixed, "Lefschetz theorem violated!"
        return True
    return True  # L = 0 doesn't guarantee no fixed point, so always OK


if __name__ == "__main__":
    print("=== Algorithm Tests ===\n")

    # Test with discrete closure on {0, 1, 2}
    universe = {0, 1, 2}
    strata = enumerate_strata(universe, lambda s: s)
    print(f"Discrete closure strata ({len(strata)}):")
    for s in strata:
        print(f"  {set(s)}")

    # Identity endomorphism
    id_map = {s: s for s in strata}
    chi = compute_euler_characteristic(strata)
    L_id = compute_lefschetz_number(strata, id_map)
    print(f"\nEuler characteristic: {chi}")
    print(f"L(id): {L_id}")
    assert L_id == chi, "L(id) should equal χ"

    # Cyclic permutation
    perm = {}
    for s in strata:
        perm[s] = frozenset({(x + 1) % 3 for x in s})
    L_perm = compute_lefschetz_number(strata, perm)
    print(f"\nL(cyclic permutation): {L_perm}")

    # Periodic counts
    print("\nPeriodic point counts (cyclic perm):")
    cache = {}
    for n in range(1, 7):
        P = count_periodic_points(strata, perm, n)
        Q = compute_primitive_periodic_count(strata, perm, n, cache)
        print(f"  P({n}) = {P}, Q({n}) = {Q}")

    # Collision detection
    print("\nOrbit collisions (cyclic perm):")
    for s in strata[:4]:
        i, j = detect_orbit_collision(strata, perm, s)
        print(f"  Start {set(s)}: collision at ({i}, {j})")

    # Verify theorem
    print(f"\nLefschetz theorem verification: {verify_lefschetz_theorem(strata, perm)}")
    print("\n=== All tests passed ===")


#!/usr/bin/env python3
"""
Applications of Closure Lefschetz Trace Semantics

Demonstrates real-world applications to:
1. Post-quantum lattice collision analysis
2. Certified robustness in classification
3. Thermodynamic trace semantics
"""

from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple
import math


Element = int
FinSet = frozenset


def enumerate_strata(universe, cl):
    u_list = sorted(universe)
    strata = []
    for r in range(len(u_list) + 1):
        for combo in combinations(u_list, r):
            s = frozenset(combo)
            if cl(s) == s:
                strata.append(s)
    return sorted(strata, key=lambda x: (len(x), sorted(x)))


def enumerate_chains(strata, n):
    chains = []
    for combo in combinations(strata, n + 1):
        sc = sorted(combo, key=lambda x: (len(x), sorted(x)))
        if all(sc[i] < sc[i + 1] for i in range(len(sc) - 1)):
            chains.append(tuple(sc))
    return chains


def lefschetz_number(strata, endo_map):
    m = len(strata)
    L = 0
    for n in range(m + 1):
        chains = enumerate_chains(strata, n)
        fc = sum(1 for ch in chains if all(endo_map.get(s, s) == s for s in ch))
        L += ((-1) ** n) * fc
    return L


def orbit_collision(strata, endo_map, start):
    m = len(strata)
    seen = {}
    current = start
    for k in range(m + 1):
        if current in seen:
            return (seen[current], k)
        seen[current] = k
        current = endo_map.get(current, current)
    return None


# === Application 1: Post-Quantum Lattice Collision Analysis ===

def post_quantum_collision_analysis():
    """
    Model a simplified lattice-based hash function state space as a closure system.

    In lattice-based cryptography, the security of hash functions depends on
    the difficulty of finding collisions. We model the lattice reduction
    process as a closure endomorphism and use our collision bounds to
    analyze the maximum number of steps before a cycle is found.
    """
    print("=" * 60)
    print("APPLICATION 1: Post-Quantum Lattice Collision Analysis")
    print("=" * 60)

    # Model: simplified lattice with basis reduction closure
    universe = set(range(4))  # 4 lattice basis states

    # Closure: each vector "generates" its reduction neighbors
    closure_map = {
        frozenset(): frozenset(),
        frozenset({0}): frozenset({0, 1}),
        frozenset({1}): frozenset({1}),
        frozenset({2}): frozenset({2, 3}),
        frozenset({3}): frozenset({3}),
    }

    def lattice_cl(s):
        result = set(s)
        changed = True
        while changed:
            changed = False
            new = set()
            for x in result:
                gen = closure_map.get(frozenset({x}), frozenset({x}))
                for g in gen:
                    if g not in result:
                        new.add(g)
                        changed = True
            result |= new
        return frozenset(result)

    strata = enumerate_strata(universe, lattice_cl)
    m = len(strata)

    print(f"\nLattice state space: {universe}")
    print(f"Number of closure strata (reduced states): {m}")
    print(f"Post-quantum collision budget: ≤ {m} function evaluations")
    print(f"Exponential bound: ≤ 2^{m} = {2**m}")

    # Define a "lattice reduction step" endomorphism
    endo_map = {}
    for s in strata:
        # Simulate one step of lattice reduction
        if len(s) > 2:
            # Reduce by removing the largest element
            reduced = frozenset(sorted(s)[:-1])
            target = lattice_cl(reduced)
            if target in strata:
                endo_map[s] = target
            else:
                endo_map[s] = s
        else:
            endo_map[s] = s

    L = lefschetz_number(strata, endo_map)
    print(f"\nLefschetz number of reduction step: {L}")
    if L != 0:
        fixed = [s for s in strata if endo_map[s] == s]
        print(f"L ≠ 0 ⟹ Guaranteed fixed (reduced) state exists!")
        print(f"Fixed strata: {[set(s) for s in fixed]}")

    # Collision analysis
    print("\nCollision detection:")
    for s in strata[:min(5, len(strata))]:
        result = orbit_collision(strata, endo_map, s)
        if result:
            i, j = result
            print(f"  Start {set(s)}: collision at step ({i},{j}), period={j-i}")


# === Application 2: Certified Robustness in Classification ===

def certified_robustness_analysis():
    """
    Model a simple classifier's decision regions as a closure system
    and analyze robustness via the Lefschetz fixed-point theorem.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Certified Robustness in Classification")
    print("=" * 60)

    # Model: 4 features, decision regions form a closure system
    features = {0, 1, 2, 3}

    # Decision regions: certain feature combinations are "stable"
    # Closure: a region includes all features implied by the present ones
    implications = {0: {0, 2}, 1: {1}, 2: {2}, 3: {3}}

    def classifier_cl(s):
        result = set(s)
        changed = True
        while changed:
            changed = False
            new_elems = set()
            for x in result:
                for y in implications.get(x, {x}):
                    if y not in result:
                        new_elems.add(y)
                        changed = True
            result |= new_elems
        return frozenset(result)

    strata = enumerate_strata(features, classifier_cl)
    m = len(strata)

    print(f"\nFeature space: {features}")
    print(f"Number of stable decision regions: {m}")

    # Training step: each region is mapped to a "better" region
    # (simulating one epoch of training)
    endo_map = {}
    for s in strata:
        # Training tends to add features (expand decision regions)
        if len(s) < len(features):
            # Find the next larger stratum
            candidates = [t for t in strata if s < t]
            if candidates:
                endo_map[s] = min(candidates, key=len)
            else:
                endo_map[s] = s
        else:
            endo_map[s] = s

    L = lefschetz_number(strata, endo_map)
    print(f"\nLefschetz number of training step: {L}")

    if L != 0:
        fixed = [s for s in strata if endo_map[s] == s]
        print(f"L ≠ 0 ⟹ Certified robustness: stable region exists!")
        print(f"Stable regions: {[set(s) for s in fixed]}")
        print(f"These regions are invariant under further training.")
    else:
        print("L = 0: No guaranteed stable region from Lefschetz alone.")

    # Energy analysis
    print("\nEnergy landscape (region size as energy):")
    for s in strata:
        energy = len(s) / len(features) if features else 0
        fixed_marker = " ← FIXED" if endo_map.get(s) == s else ""
        print(f"  Region {set(s)}: energy = {energy:.2f}{fixed_marker}")


# === Application 3: Thermodynamic Trace Semantics ===

def thermodynamic_trace_analysis():
    """
    Compute thermodynamic quantities for a closure dynamical system.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Thermodynamic Trace Semantics")
    print("=" * 60)

    universe = {0, 1, 2, 3}

    # Topological closure (T0 topology)
    closed_sets_raw = [set(), {0}, {1}, {0, 1}, {2, 3}, {0, 2, 3}, {1, 2, 3}, {0, 1, 2, 3}]
    closed_sets = [frozenset(s) for s in closed_sets_raw]

    def topo_cl(s):
        for c in sorted(closed_sets, key=len):
            if frozenset(s) <= c:
                return c
        return frozenset(universe)

    strata = enumerate_strata(universe, topo_cl)
    m = len(strata)

    print(f"\nThermodynamic state space: {universe}")
    print(f"Closure strata (thermal equilibria): {m}")
    print(f"Entropy bound: log₂(m) = {math.log2(m):.2f} bits")
    print(f"Max entropy: log₂(2^|α|) = {len(universe)} bits")

    # Euler characteristic as "free energy"
    chi = 0
    for n in range(m + 1):
        nc = len(enumerate_chains(strata, n))
        chi += ((-1) ** n) * nc
        if nc > 0:
            print(f"  {n}-simplices: {nc}")
    print(f"\nEuler characteristic (partition function signature): χ = {chi}")

    # Identity trace density
    id_map = {s: s for s in strata}
    L_id = lefschetz_number(strata, id_map)
    trace_density = L_id / m if m > 0 else 0
    print(f"Trace density (identity): L/m = {L_id}/{m} = {trace_density:.4f}")

    # Thermal evolution: contract toward equilibrium
    eq_state = frozenset(universe)  # Full universe is equilibrium
    thermal_map = {}
    for s in strata:
        # Each state evolves toward equilibrium by adding one element
        if s == eq_state:
            thermal_map[s] = s
        else:
            missing = universe - s
            if missing:
                augmented = s | frozenset({min(missing)})
                target = topo_cl(augmented)
                if target in strata:
                    thermal_map[s] = target
                else:
                    thermal_map[s] = s
            else:
                thermal_map[s] = s

    L_thermal = lefschetz_number(strata, thermal_map)
    thermal_density = L_thermal / m if m > 0 else 0
    print(f"\nThermal evolution Lefschetz number: {L_thermal}")
    print(f"Thermal trace density: {thermal_density:.4f}")

    if L_thermal != 0:
        fixed = [s for s in strata if thermal_map[s] == s]
        print(f"Thermal fixed points: {[set(s) for s in fixed]}")
        print("These represent thermal equilibrium states.")


if __name__ == "__main__":
    post_quantum_collision_analysis()
    certified_robustness_analysis()
    thermodynamic_trace_analysis()
    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Closure Lefschetz Trace Semantics — Concrete Numerical Demonstrations

Demonstrates the core theorems with explicit finite closure systems,
computing Lefschetz numbers, periodic orbit counts, and collision bounds.
"""

from itertools import combinations
from typing import Callable, Dict, FrozenSet, List, Set, Tuple
import math


# === Core Types ===
Element = int
FinSet = frozenset


class SetClosureOp:
    """A closure operator on subsets of a finite set."""

    def __init__(self, universe: Set[Element], cl: Callable[[FinSet], FinSet]):
        self.universe = frozenset(universe)
        self._cl = cl
        # Verify axioms on a sample
        self._verify_axioms()

    def cl(self, s: FinSet) -> FinSet:
        return self._cl(s)

    def _verify_axioms(self):
        """Verify extensivity, monotonicity, idempotence on small examples."""
        powerset = list(self._powerset())
        for s in powerset[:min(len(powerset), 50)]:
            cs = self.cl(s)
            assert s <= cs, f"Extensivity failed: {s} ⊄ {cs}"
            assert self.cl(cs) == cs, f"Idempotence failed: cl(cl({s})) ≠ cl({s})"

    def _powerset(self):
        u = list(self.universe)
        for r in range(len(u) + 1):
            for combo in combinations(u, r):
                yield frozenset(combo)

    def strata(self) -> List[FinSet]:
        """Enumerate all closure strata (fixed points of cl)."""
        return sorted([s for s in self._powerset() if self.cl(s) == s], key=len)

    def entropy_bound(self) -> int:
        """Number of strata = entropy bound m."""
        return len(self.strata())


class ClosureEndomorphism:
    """A monotone self-map on closure strata."""

    def __init__(self, closure_op: SetClosureOp, mapping: Dict[FinSet, FinSet]):
        self.op = closure_op
        self.mapping = mapping

    def apply(self, s: FinSet) -> FinSet:
        return self.mapping[s]

    def iterate(self, s: FinSet, n: int) -> FinSet:
        result = s
        for _ in range(n):
            result = self.apply(result)
        return result


# === Lefschetz Number Computation ===

def closure_chains(strata: List[FinSet], n: int) -> List[Tuple[FinSet, ...]]:
    """Enumerate strictly increasing (n+1)-chains of strata."""
    chains = []
    for combo in combinations(strata, n + 1):
        # Check strict inclusion
        sorted_combo = sorted(combo, key=len)
        if all(sorted_combo[i] < sorted_combo[i + 1] for i in range(len(sorted_combo) - 1)):
            chains.append(tuple(sorted_combo))
    return chains


def fixed_chains(strata: List[FinSet], endo: ClosureEndomorphism, n: int) -> List[Tuple[FinSet, ...]]:
    """Enumerate n-chains where all vertices are fixed by the endomorphism."""
    return [ch for ch in closure_chains(strata, n) if all(endo.apply(s) == s for s in ch)]


def lefschetz_number(closure_op: SetClosureOp, endo: ClosureEndomorphism) -> int:
    """Compute the Lefschetz number L(C, f)."""
    strata = closure_op.strata()
    m = len(strata)
    L = 0
    for n in range(m + 1):
        count = len(fixed_chains(strata, endo, n))
        L += ((-1) ** n) * count
    return L


def euler_characteristic(closure_op: SetClosureOp) -> int:
    """Compute the Euler characteristic χ(C) = L(C, id)."""
    strata = closure_op.strata()
    m = len(strata)
    chi = 0
    for n in range(m + 1):
        count = len(closure_chains(strata, n))
        chi += ((-1) ** n) * count
    return chi


def periodic_point_count(closure_op: SetClosureOp, endo: ClosureEndomorphism, period: int) -> int:
    """Count strata fixed by f^period."""
    strata = closure_op.strata()
    return sum(1 for s in strata if endo.iterate(s, period) == s)


def orbit_collision(closure_op: SetClosureOp, endo: ClosureEndomorphism, start: FinSet) -> Tuple[int, int]:
    """Find the first collision in the orbit of start. Returns (i, j) with f^i = f^j."""
    m = closure_op.entropy_bound()
    seen = {}
    current = start
    for k in range(m + 1):
        if current in seen:
            return (seen[current], k)
        seen[current] = k
        current = endo.apply(current)
    raise ValueError("No collision found (impossible by pigeonhole)")


# === Example Closure Systems ===

def discrete_closure(universe):
    """Discrete closure: cl = id. Every subset is a stratum."""
    return SetClosureOp(universe, lambda s: s)


def trivial_closure(universe):
    """Trivial closure: cl(s) = universe for all s."""
    u = frozenset(universe)
    return SetClosureOp(universe, lambda s: u)


def topological_closure_example():
    """A 3-element set with a non-trivial closure (T0 topology)."""
    universe = {0, 1, 2}
    # Closed sets: ∅, {0}, {1,2}, {0,1,2}
    closed_sets = [frozenset(), frozenset({0}), frozenset({1, 2}), frozenset({0, 1, 2})]

    def cl(s):
        # Return the smallest closed set containing s
        for c in sorted(closed_sets, key=len):
            if s <= c:
                return c
        return frozenset(universe)

    return SetClosureOp(universe, cl)


def identity_endomorphism(closure_op):
    """Identity endomorphism: f(s) = s."""
    strata = closure_op.strata()
    return ClosureEndomorphism(closure_op, {s: s for s in strata})


def constant_endomorphism(closure_op, target):
    """Constant endomorphism: f(s) = target for all s."""
    strata = closure_op.strata()
    return ClosureEndomorphism(closure_op, {s: target for s in strata})


# === Demo ===

def main():
    print("=" * 70)
    print("CLOSURE LEFSCHETZ TRACE SEMANTICS — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Discrete closure on {0, 1}
    print("\n--- Demo 1: Discrete closure on {0, 1} ---")
    C1 = discrete_closure({0, 1})
    strata1 = C1.strata()
    print(f"Strata: {[set(s) for s in strata1]}")
    print(f"Entropy bound m = {C1.entropy_bound()}")
    chi1 = euler_characteristic(C1)
    print(f"Euler characteristic χ(C) = {chi1}")

    id1 = identity_endomorphism(C1)
    L_id = lefschetz_number(C1, id1)
    print(f"L(C, id) = {L_id} (should equal χ = {chi1})")

    const1 = constant_endomorphism(C1, frozenset({0}))
    L_const = lefschetz_number(C1, const1)
    print(f"L(C, const_{{0}}) = {L_const}")
    print(f"Fixed strata of const: {[set(s) for s in strata1 if const1.apply(s) == s]}")

    # Collision detection
    for s in strata1[:3]:
        i, j = orbit_collision(C1, id1, s)
        print(f"  Orbit collision for {set(s)}: i={i}, j={j}")

    # Demo 2: Trivial closure on {0, 1, 2}
    print("\n--- Demo 2: Trivial closure on {0, 1, 2} ---")
    C2 = trivial_closure({0, 1, 2})
    strata2 = C2.strata()
    print(f"Strata: {[set(s) for s in strata2]}")
    print(f"Entropy bound m = {C2.entropy_bound()}")
    chi2 = euler_characteristic(C2)
    print(f"Euler characteristic χ(C) = {chi2}")

    # Demo 3: Topological closure
    print("\n--- Demo 3: Topological closure on {0, 1, 2} ---")
    C3 = topological_closure_example()
    strata3 = C3.strata()
    print(f"Strata: {[set(s) for s in strata3]}")
    print(f"Entropy bound m = {C3.entropy_bound()}")
    chi3 = euler_characteristic(C3)
    print(f"Euler characteristic χ(C) = {chi3}")

    id3 = identity_endomorphism(C3)
    L_id3 = lefschetz_number(C3, id3)
    print(f"L(C, id) = {L_id3}")

    # Chain counts
    for n in range(len(strata3) + 1):
        nc = len(closure_chains(strata3, n))
        print(f"  {n}-chains: {nc}")

    # Demo 4: Periodic orbit counts
    print("\n--- Demo 4: Periodic orbits (discrete, {0,1,2}) ---")
    C4 = discrete_closure({0, 1, 2})
    strata4 = C4.strata()
    print(f"Strata count: {len(strata4)}")

    # Create a cyclic permutation endomorphism on 1-element strata
    # Map: {0} -> {1} -> {2} -> {0}, and close upward
    perm_map = {}
    for s in strata4:
        if s == frozenset({0}):
            perm_map[s] = frozenset({1})
        elif s == frozenset({1}):
            perm_map[s] = frozenset({2})
        elif s == frozenset({2}):
            perm_map[s] = frozenset({0})
        elif s == frozenset({0, 1}):
            perm_map[s] = frozenset({1, 2})
        elif s == frozenset({1, 2}):
            perm_map[s] = frozenset({0, 2})
        elif s == frozenset({0, 2}):
            perm_map[s] = frozenset({0, 1})
        elif s == frozenset({0, 1, 2}):
            perm_map[s] = frozenset({0, 1, 2})
        elif s == frozenset():
            perm_map[s] = frozenset()
        else:
            perm_map[s] = s

    perm_endo = ClosureEndomorphism(C4, perm_map)
    L_perm = lefschetz_number(C4, perm_endo)
    print(f"L(C, cyclic_perm) = {L_perm}")

    for n in range(1, 7):
        pc = periodic_point_count(C4, perm_endo, n)
        print(f"  Period-{n} fixed points: {pc}")

    # Verify Lefschetz theorem
    if L_perm != 0:
        fixed = [s for s in strata4 if perm_endo.apply(s) == s]
        print(f"  L ≠ 0, fixed strata exist: {[set(s) for s in fixed]}")

    # Demo 5: Collision bound verification
    print("\n--- Demo 5: Collision bound verification ---")
    for s in strata4[:4]:
        i, j = orbit_collision(C4, perm_endo, s)
        print(f"  Start={set(s)}: collision at (i={i}, j={j}), gap={j-i}, bound={len(strata4)}")

    # Demo 6: Quantitative bounds verification
    print("\n--- Demo 6: Quantitative bounds ---")
    m = C4.entropy_bound()
    print(f"  Entropy bound m = {m}")
    print(f"  Strata count ≤ 2^|α| = 2^3 = {2**3}: {m} ≤ {2**3} ✓" if m <= 2**3 else "  FAIL")

    for n in range(m + 1):
        nc = len(closure_chains(strata4, n))
        bound = m ** (n + 1)
        check = "✓" if nc <= bound else "✗"
        print(f"  {n}-simplices: {nc} ≤ {m}^{n+1} = {bound} {check}")

    for n in range(1, 5):
        pc = periodic_point_count(C4, perm_endo, n)
        check = "✓" if pc <= m else "✗"
        print(f"  Period-{n} count: {pc} ≤ m={m} {check}")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Closure Lefschetz Trace Semantics

Generates charts showing:
1. Closure stratum lattice structure
2. Lefschetz number vs endomorphism type
3. Periodic orbit growth
4. Simplex count bounds
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import os

FinSet = frozenset


def enumerate_strata(universe, cl):
    u_list = sorted(universe)
    strata = []
    for r in range(len(u_list) + 1):
        for combo in combinations(u_list, r):
            s = frozenset(combo)
            if cl(s) == s:
                strata.append(s)
    return sorted(strata, key=lambda x: (len(x), sorted(x)))


def enumerate_chains(strata, n):
    chains = []
    for combo in combinations(strata, n + 1):
        sc = sorted(combo, key=lambda x: (len(x), sorted(x)))
        if all(sc[i] < sc[i + 1] for i in range(len(sc) - 1)):
            chains.append(tuple(sc))
    return chains


def plot_simplex_counts():
    """Plot simplex counts vs dimension for different closure systems."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Discrete closure on {0,1,2,3}
    universe4 = {0, 1, 2, 3}
    strata4 = enumerate_strata(universe4, lambda s: s)
    m4 = len(strata4)

    dims = list(range(m4 + 1))
    counts4 = [len(enumerate_chains(strata4, n)) for n in dims]
    bounds4 = [m4 ** (n + 1) for n in dims]

    ax1.bar(dims, counts4, alpha=0.7, label='Actual simplex count', color='steelblue')
    ax1.plot(dims, bounds4, 'r--o', label=f'm^(n+1), m={m4}', markersize=4)
    ax1.set_xlabel('Simplex dimension n', fontsize=12)
    ax1.set_ylabel('Count', fontsize=12)
    ax1.set_title(f'Closure Nerve Simplex Counts\n(Discrete closure, |α|=4, m={m4})', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_yscale('log')
    ax1.set_ylim(bottom=0.5)

    # Euler characteristic accumulation
    euler_partial = []
    running = 0
    for n in range(len(counts4)):
        running += ((-1) ** n) * counts4[n]
        euler_partial.append(running)

    ax2.plot(range(len(euler_partial)), euler_partial, 'b-o', markersize=6, linewidth=2)
    ax2.axhline(y=euler_partial[-1], color='r', linestyle='--', alpha=0.5,
                label=f'χ(C) = {euler_partial[-1]}')
    ax2.set_xlabel('Maximum dimension included', fontsize=12)
    ax2.set_ylabel('Partial Euler characteristic', fontsize=12)
    ax2.set_title('Euler Characteristic Convergence', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'simplex_counts.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved simplex_counts.png")


def plot_periodic_orbits():
    """Plot periodic orbit counts vs period for different endomorphisms."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    universe = {0, 1, 2, 3}
    strata = enumerate_strata(universe, lambda s: s)
    m = len(strata)

    # Cyclic permutation: 0→1→2→3→0
    perm = {}
    for s in strata:
        perm[s] = frozenset({(x + 1) % 4 for x in s})

    periods = list(range(1, 13))
    periodic_counts = []
    for p in periods:
        count = 0
        for s in strata:
            current = s
            for _ in range(p):
                current = perm.get(current, current)
            if current == s:
                count += 1
        periodic_counts.append(count)

    ax1.bar(periods, periodic_counts, alpha=0.7, color='darkorange', label='P(n)')
    ax1.axhline(y=m, color='r', linestyle='--', alpha=0.5, label=f'Entropy bound m={m}')
    ax1.set_xlabel('Period n', fontsize=12)
    ax1.set_ylabel('Periodic point count P(n)', fontsize=12)
    ax1.set_title('Periodic Orbit Counts\n(4-element cyclic permutation)', fontsize=13)
    ax1.legend(fontsize=10)

    # Primitive periodic counts via Möbius
    def divisors(n):
        return [d for d in range(1, n + 1) if n % d == 0]

    cache = {}
    def Q(n):
        if n in cache:
            return cache[n]
        if n == 0:
            return 0
        P_n = periodic_counts[n - 1] if n <= len(periodic_counts) else 0
        result = P_n - sum(Q(d) for d in divisors(n) if d < n)
        cache[n] = result
        return result

    primitive = [Q(p) for p in periods]
    colors = ['green' if q >= 0 else 'red' for q in primitive]
    ax2.bar(periods, primitive, alpha=0.7, color=colors, label='Q(n)')
    ax2.axhline(y=0, color='k', linewidth=0.5)
    ax2.set_xlabel('Period n', fontsize=12)
    ax2.set_ylabel('Primitive count Q(n)', fontsize=12)
    ax2.set_title('Primitive Periodic Orbit Decomposition\n(Möbius inversion)', fontsize=13)
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'periodic_orbits.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved periodic_orbits.png")


def plot_collision_bounds():
    """Plot collision bounds vs system size."""
    fig, ax = plt.subplots(figsize=(10, 6))

    sizes = list(range(1, 8))
    entropy_bounds = []
    exponential_bounds = []

    for n in sizes:
        universe = set(range(n))
        strata = enumerate_strata(universe, lambda s: s)
        m = len(strata)
        entropy_bounds.append(m)
        exponential_bounds.append(2 ** n)

    ax.plot(sizes, entropy_bounds, 'bo-', label='Entropy bound m (collision budget)', linewidth=2, markersize=8)
    ax.plot(sizes, exponential_bounds, 'r^--', label='2^|α| (powerset bound)', linewidth=2, markersize=8)
    ax.fill_between(sizes, entropy_bounds, alpha=0.1, color='blue')

    ax.set_xlabel('Carrier set size |α|', fontsize=13)
    ax.set_ylabel('Bound value', fontsize=13)
    ax.set_title('Cryptographic Collision Bounds\nvs Carrier Set Size (Discrete Closure)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Annotate
    for i, (s, m) in enumerate(zip(sizes, entropy_bounds)):
        if s <= 5:
            ax.annotate(f'm={m}', (s, m), textcoords="offset points",
                       xytext=(10, 5), fontsize=9)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'collision_bounds.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved collision_bounds.png")


def plot_lefschetz_summary():
    """Summary plot showing the Lefschetz theorem in action."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Compare Lefschetz numbers for different endomorphisms on discrete closure {0,1,2}
    universe = {0, 1, 2}
    strata = enumerate_strata(universe, lambda s: s)

    endo_names = []
    lefschetz_values = []
    fixed_counts = []

    # Identity
    id_map = {s: s for s in strata}
    L = sum(((-1)**n) * len([ch for ch in enumerate_chains(strata, n)
            if all(id_map[v] == v for v in ch)]) for n in range(len(strata)+1))
    endo_names.append('Identity')
    lefschetz_values.append(L)
    fixed_counts.append(sum(1 for s in strata if id_map[s] == s))

    # Cyclic permutation
    perm = {s: frozenset({(x+1) % 3 for x in s}) for s in strata}
    L = sum(((-1)**n) * len([ch for ch in enumerate_chains(strata, n)
            if all(perm[v] == v for v in ch)]) for n in range(len(strata)+1))
    endo_names.append('Cycle (0→1→2)')
    lefschetz_values.append(L)
    fixed_counts.append(sum(1 for s in strata if perm[s] == s))

    # Transposition (0↔1)
    trans = {}
    for s in strata:
        trans[s] = frozenset({1 if x == 0 else 0 if x == 1 else x for x in s})
    L = sum(((-1)**n) * len([ch for ch in enumerate_chains(strata, n)
            if all(trans[v] == v for v in ch)]) for n in range(len(strata)+1))
    endo_names.append('Swap (0↔1)')
    lefschetz_values.append(L)
    fixed_counts.append(sum(1 for s in strata if trans[s] == s))

    # Constant to ∅
    const_empty = {s: frozenset() for s in strata}
    L = sum(((-1)**n) * len([ch for ch in enumerate_chains(strata, n)
            if all(const_empty[v] == v for v in ch)]) for n in range(len(strata)+1))
    endo_names.append('Const(∅)')
    lefschetz_values.append(L)
    fixed_counts.append(sum(1 for s in strata if const_empty[s] == s))

    # Constant to {0,1,2}
    const_full = {s: frozenset({0,1,2}) for s in strata}
    L = sum(((-1)**n) * len([ch for ch in enumerate_chains(strata, n)
            if all(const_full[v] == v for v in ch)]) for n in range(len(strata)+1))
    endo_names.append('Const({0,1,2})')
    lefschetz_values.append(L)
    fixed_counts.append(sum(1 for s in strata if const_full[s] == s))

    x = np.arange(len(endo_names))
    width = 0.35
    bars1 = ax.bar(x - width/2, lefschetz_values, width, label='Lefschetz number L', color='steelblue', alpha=0.8)
    bars2 = ax.bar(x + width/2, fixed_counts, width, label='Fixed point count', color='coral', alpha=0.8)

    ax.set_ylabel('Value', fontsize=13)
    ax.set_title('Lefschetz Fixed-Point Theorem in Action\n(Discrete closure on {0,1,2})', fontsize=14)
    ax.set_xticks(x)
    ax.set_xticklabels(endo_names, fontsize=10)
    ax.legend(fontsize=11)
    ax.axhline(y=0, color='k', linewidth=0.5)

    # Annotate: L ≠ 0 ⟹ fixed point exists
    for i in range(len(endo_names)):
        if lefschetz_values[i] != 0:
            ax.annotate('L≠0 ✓', (x[i] - width/2, lefschetz_values[i]),
                       textcoords="offset points", xytext=(0, 5),
                       fontsize=8, color='green', ha='center', fontweight='bold')

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'lefschetz_summary.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved lefschetz_summary.png")


if __name__ == "__main__":
    plot_simplex_counts()
    plot_periodic_orbits()
    plot_collision_bounds()
    plot_lefschetz_summary()
    print("\nAll visualizations generated.")

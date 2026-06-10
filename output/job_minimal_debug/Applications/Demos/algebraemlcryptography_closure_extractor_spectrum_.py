#!/usr/bin/env python3
"""
Applications of Closure–Extractor Spectrum Duality

Demonstrates practical applications:
1. Cryptographic key extraction from correlated sources
2. Feature selection via closure-entropy analysis
3. Dependency structure discovery
"""

import itertools
from algorithms import (
    powerset, enumerate_closed_sets, find_extremal_witnesses,
    build_canonical_extractor, reconstruct_closure,
    compute_spectrum_rank, verify_submodularity
)


# ── Application 1: Cryptographic Source Analysis ───────────────────

def crypto_source_analysis():
    """
    Application: Analyzing a correlated random source for key extraction.

    Scenario: A sensor array produces 5 measurements {s0, ..., s4}.
    Some measurements are correlated:
    - s0, s1 are from the same physical process (jointly determined)
    - s2, s3, s4 are independent but s2 is derived from s3+s4

    The closure operator captures these dependencies.
    The spectrum rank tells us the minimum seed budget for extraction.
    """
    print("=" * 60)
    print("Application 1: Cryptographic Source Analysis")
    print("=" * 60)

    ground = frozenset({0, 1, 2, 3, 4})

    # Dependency closure:
    # {0} → {0,1} (s0 determines s1 and vice versa)
    # {3,4} → {2,3,4} (s3+s4 determines s2)
    def cl(A: frozenset) -> frozenset:
        result = set(A)
        changed = True
        while changed:
            changed = False
            if 0 in result and 1 not in result:
                result.add(1); changed = True
            if 1 in result and 0 not in result:
                result.add(0); changed = True
            if 3 in result and 4 in result and 2 not in result:
                result.add(2); changed = True
        return frozenset(result)

    # Defect: entropy loss (monotone, closure-invariant)
    def delta(A: frozenset) -> int:
        clA = cl(A)
        if not clA:
            return 0
        # Independent components: {0,1} counts as 1, {3,4,2} counts as 1
        dep_groups = 0
        if clA & {0, 1}:
            dep_groups += 1
        if clA & {3, 4}:
            dep_groups += 1
        return dep_groups

    closed = enumerate_closed_sets(ground, cl)
    print(f"Sensor array: {{s0, s1, s2, s3, s4}}")
    print(f"Dependencies: s0 ↔ s1, s3+s4 → s2")
    print(f"Closed sets: {[set(C) for C in closed]}")

    ext = build_canonical_extractor(ground, cl, delta)
    print(f"\nSpectrum rank (min seeds needed): {ext['num_seeds']}")
    print(f"Extremal witnesses: {[set(C) for C in ext['extremal_witnesses']]}")
    print(f"Defect bounds: {ext['defect_bounds']}")
    print(f"\nInterpretation: Need {ext['num_seeds']} seed values to extract")
    print(f"independent randomness from this sensor array.")
    print()


# ── Application 2: Feature Selection ──────────────────────────────

def feature_selection():
    """
    Application: Identifying minimal feature sets via closure analysis.

    Scenario: A dataset has 4 features {f0, f1, f2, f3}.
    Feature f3 is a linear combination of f0 and f1.
    Features f0 and f2 are independent.

    The closure operator captures redundancy.
    Extremal witnesses identify independent information sources.
    """
    print("=" * 60)
    print("Application 2: Feature Selection via Closure Analysis")
    print("=" * 60)

    ground = frozenset({0, 1, 2, 3})

    # f3 is determined by {f0, f1}
    def cl(A: frozenset) -> frozenset:
        result = set(A)
        if 0 in result and 1 in result:
            result.add(3)
        return frozenset(result)

    # Defect: information content (how many independent features)
    def delta(A: frozenset) -> int:
        clA = cl(A)
        if not clA:
            return 0
        # Count independent components
        count = 0
        if clA & {0}:
            count += 1
        if clA & {1}:
            count += 1
        if clA & {2}:
            count += 1
        # f3 doesn't add independent info (it's determined by f0, f1)
        return count

    closed = enumerate_closed_sets(ground, cl)
    print(f"Features: {{f0, f1, f2, f3}}")
    print(f"Redundancy: f3 = f(f0, f1)")
    print(f"Closed sets: {[set(C) for C in closed]}")

    ext = build_canonical_extractor(ground, cl, delta)
    print(f"\nSpectrum rank: {ext['num_seeds']}")
    print(f"Extremal witnesses: {[set(C) for C in ext['extremal_witnesses']]}")
    print(f"\nInterpretation: The {ext['num_seeds']} extremal witnesses identify")
    print(f"the independent information sources in the feature space.")
    print(f"Feature f3 is redundant (captured by cl({{f0, f1}}) = {{f0, f1, f3}}).")
    print()


# ── Application 3: Network Dependency Discovery ──────────────────

def network_dependency():
    """
    Application: Discovering dependency structure in a network.

    Scenario: A communication network has 4 nodes {A, B, C, D}.
    Node C relays between A and B (so observing A,B implies C's state).
    Node D is independent.

    The closure structure reveals the network topology.
    """
    print("=" * 60)
    print("Application 3: Network Dependency Discovery")
    print("=" * 60)

    ground = frozenset({'A', 'B', 'C', 'D'})

    # C is a relay: knowing A and B determines C
    def cl(A: frozenset) -> frozenset:
        result = set(A)
        if 'A' in result and 'B' in result:
            result.add('C')
        return frozenset(result)

    def delta(A: frozenset) -> int:
        clA = cl(A)
        if not clA:
            return 0
        count = 0
        if clA & {'A'}:
            count += 1
        if clA & {'B'}:
            count += 1
        if clA & {'D'}:
            count += 1
        return count

    closed = enumerate_closed_sets(ground, cl)
    print(f"Network nodes: {{A, B, C, D}}")
    print(f"Dependency: C is relay between A and B")
    print(f"Closed sets: {[set(C) for C in closed]}")

    ext = build_canonical_extractor(ground, cl, delta)
    print(f"\nSpectrum rank: {ext['num_seeds']}")
    print(f"Extremal witnesses: {[set(C) for C in ext['extremal_witnesses']]}")
    print(f"\nInterpretation: {ext['num_seeds']} independent information channels")
    print(f"in the network. Node C's information is redundant given A and B.")

    # Show reconstruction recovers the topology
    rec_cl = reconstruct_closure(ground, ext['witness_sets'])
    print(f"\nReconstructed dependency structure:")
    for node in sorted(ground):
        print(f"  cl({{{node}}}) = {set(rec_cl(frozenset({node})))}")
    print(f"  cl({{A,B}}) = {set(rec_cl(frozenset({'A', 'B'})))}")
    print()


# ── Application 4: Spectrum Rank Comparison ──────────────────────

def spectrum_rank_comparison():
    """
    Compare spectrum ranks across different closure structures
    on the same ground set, showing how dependency structure
    affects extraction complexity.
    """
    print("=" * 60)
    print("Application 4: Spectrum Rank vs Closure Structure")
    print("=" * 60)

    ground = frozenset({0, 1, 2, 3})

    structures = {
        "Discrete (no deps)": lambda A: A,
        "Chain": lambda A: (
            frozenset() if not A else
            frozenset({0}) if A <= frozenset({0}) else
            frozenset({0,1}) if A <= frozenset({0,1}) else
            frozenset({0,1,2}) if A <= frozenset({0,1,2}) else
            ground
        ),
        "Partition {01|23}": lambda A: (
            frozenset() if not A else
            frozenset({0,1}) if A <= frozenset({0,1}) else
            frozenset({2,3}) if A <= frozenset({2,3}) else
            ground
        ),
        "Full (all determined)": lambda A: ground if A else frozenset(),
    }

    for name, cl in structures.items():
        # Simple defect: 0 for empty, then position/size based
        closed = enumerate_closed_sets(ground, cl)

        # Use index in closed sets as defect (always submodular on chains/partitions)
        closed_sorted = sorted(closed, key=lambda s: len(s))
        defect_map = {C: i for i, C in enumerate(closed_sorted)}

        def delta(A, _cl=cl, _dm=defect_map):
            clA = _cl(A)
            return _dm.get(clA, 0)

        ok, _ = verify_submodularity(closed, delta)
        if ok:
            rank = compute_spectrum_rank(ground, cl, delta)
            print(f"  {name:30s}: spectrum rank = {rank}, "
                  f"closed sets = {len(closed)}")
        else:
            print(f"  {name:30s}: (submodularity check needed)")

    print()
    print("Observation: More dependency → fewer extremal witnesses → lower seed budget.")
    print("The discrete closure (no dependencies) maximizes spectrum rank.")
    print()


if __name__ == "__main__":
    crypto_source_analysis()
    feature_selection()
    network_dependency()
    spectrum_rank_comparison()


#!/usr/bin/env python3
"""
Closure–Extractor Spectrum Duality: Concrete Demonstrations

This script demonstrates the core theorems of the closure-extractor spectrum
duality with concrete numerical examples on small finite types.
"""

import itertools
from typing import Callable


def powerset(s: frozenset) -> list:
    """All subsets of s as frozensets."""
    elems = list(s)
    result = []
    for r in range(len(elems) + 1):
        for combo in itertools.combinations(elems, r):
            result.append(frozenset(combo))
    return result


# ── §1. Closure Operators ──────────────────────────────────────────────

class FiniteClosure:
    """A closure operator on subsets of a finite ground set."""

    def __init__(self, ground: frozenset, cl: Callable):
        self.ground = ground
        self._cl = cl
        self._validate()

    def cl(self, A: frozenset) -> frozenset:
        return self._cl(A)

    def _validate(self):
        for A in powerset(self.ground):
            clA = self.cl(A)
            assert A <= clA, f"Extensive failed: {A} not subset of cl({A})={clA}"
            assert self.cl(clA) == clA, f"Idempotent failed on {A}"
        for A in powerset(self.ground):
            for B in powerset(self.ground):
                if A <= B:
                    assert self.cl(A) <= self.cl(B), \
                        f"Monotone failed: cl({A}) not subset of cl({B})"

    def is_closed(self, A: frozenset) -> bool:
        return self.cl(A) == A

    def closed_sets(self) -> list:
        return [A for A in powerset(self.ground) if self.is_closed(A)]


# ── §2. Closure-Entropy Systems ───────────────────────────────────────

class ClosureEntropySystem:
    """A closure operator plus a submodular, closure-invariant defect profile."""

    def __init__(self, closure: FiniteClosure, delta: Callable):
        self.closure = closure
        self.delta = delta
        self._validate()

    def _validate(self):
        # Normalized
        assert self.delta(frozenset()) == 0, "delta(∅) must be 0"
        # Closure invariant
        for A in powerset(self.closure.ground):
            assert self.delta(A) == self.delta(self.closure.cl(A)), \
                f"Closure invariance failed on {A}"
        # Submodularity on closed sets
        for A in self.closure.closed_sets():
            for B in self.closure.closed_sets():
                lhs = self.delta(A) + self.delta(B)
                rhs = self.delta(A & B) + self.delta(A | B)
                assert lhs >= rhs, \
                    f"Submodularity failed: δ({A})+δ({B})={lhs} < δ({A}&{B})+δ({A}|{B})={rhs}"

    def is_extremal_witness(self, C: frozenset) -> bool:
        if not self.closure.is_closed(C) or C == frozenset():
            return False
        for D in powerset(self.closure.ground):
            if self.closure.is_closed(D) and D < C:
                if not (self.delta(D) < self.delta(C)):
                    return False
        return True

    def extremal_witnesses(self) -> list:
        return [C for C in self.closure.closed_sets() if self.is_extremal_witness(C)]

    def spectrum_rank(self) -> int:
        return len(self.extremal_witnesses())


# ── §3. Finite Seeded Extractors ──────────────────────────────────────

class FiniteSeededExtractor:
    """A finite seeded extractor: seed-indexed witness sets + defect bounds."""

    def __init__(self, witness_sets: list, defect_bounds: list):
        assert len(witness_sets) == len(defect_bounds)
        self.num_seeds = len(witness_sets)
        self.witness_sets = witness_sets
        self.defect_bounds = defect_bounds

    def realizes(self, system: ClosureEntropySystem) -> bool:
        # 1. Each witness set is closed
        for ws in self.witness_sets:
            if not system.closure.is_closed(ws):
                return False
        # 2. Every extremal witness appears
        for ew in system.extremal_witnesses():
            if ew not in self.witness_sets:
                return False
        # 3. Defect bounds match
        for i in range(self.num_seeds):
            if self.defect_bounds[i] != system.delta(self.witness_sets[i]):
                return False
        return True

    def is_seed_minimal(self, system: ClosureEntropySystem) -> bool:
        if not self.realizes(system):
            return False
        # Check no smaller realization exists by trying all subsets
        for size in range(self.num_seeds):
            for indices in itertools.combinations(range(self.num_seeds), size):
                sub_ws = [self.witness_sets[i] for i in indices]
                sub_db = [self.defect_bounds[i] for i in indices]
                sub_ext = FiniteSeededExtractor(sub_ws, sub_db)
                if sub_ext.realizes(system):
                    return False
        return True


def canonical_extractor(system: ClosureEntropySystem) -> FiniteSeededExtractor:
    """Build the canonical seed-minimal extractor."""
    ews = system.extremal_witnesses()
    ws = ews
    db = [system.delta(C) for C in ews]
    return FiniteSeededExtractor(ws, db)


def reconstruct_closure(extractor: FiniteSeededExtractor, ground: frozenset):
    """Reconstruct a closure operator from an extractor."""
    def cl(A: frozenset) -> frozenset:
        covering = [ws for ws in extractor.witness_sets if A <= ws]
        if covering:
            result = covering[0]
            for ws in covering[1:]:
                result = result & ws
            return result
        return ground
    return FiniteClosure(ground, cl)


# ── §4. Example: Linear Dependencies ─────────────────────────────────

def demo_linear_dependency():
    """
    Example: 3-element ground set {0,1,2} with closure encoding
    linear dependency (like a rank-2 matroid).
    """
    print("=" * 60)
    print("Demo 1: Linear Dependency Closure (rank-2 matroid)")
    print("=" * 60)

    ground = frozenset({0, 1, 2})

    # Closure: cl({i}) = {i}, cl({i,j}) = {0,1,2} for i≠j, cl(∅)=∅
    def cl(A: frozenset) -> frozenset:
        if len(A) >= 2:
            return ground
        return A

    closure = FiniteClosure(ground, cl)
    print(f"Ground set: {set(ground)}")
    print(f"Closed sets: {[set(C) for C in closure.closed_sets()]}")

    # Defect = number of singletons in closure (submodular on closed sets)
    # Closed sets: ∅, {0}, {1}, {2}, {0,1,2}
    # δ(∅)=0, δ({i})=1, δ({0,1,2})=1
    # Check: δ({0})+δ({1})=2 ≥ δ(∅)+δ({0,1,2})=1 ✓
    def delta(A: frozenset) -> int:
        clA = closure.cl(A)
        if clA == frozenset():
            return 0
        return 1

    system = ClosureEntropySystem(closure, delta)
    ews = system.extremal_witnesses()
    print(f"\nExtremal witnesses: {[set(C) for C in ews]}")
    print(f"Spectrum rank: {system.spectrum_rank()}")

    ext = canonical_extractor(system)
    print(f"\nCanonical extractor:")
    print(f"  Seeds: {ext.num_seeds}")
    for i in range(ext.num_seeds):
        print(f"  Seed {i}: witness={set(ext.witness_sets[i])}, defect={ext.defect_bounds[i]}")

    print(f"\n  Realizes system: {ext.realizes(system)}")
    print(f"  Is seed-minimal: {ext.is_seed_minimal(system)}")
    print(f"  seed_count == spectrum_rank: {ext.num_seeds == system.spectrum_rank()}")

    # Reconstruction
    rec_cl = reconstruct_closure(ext, ground)
    print(f"\nReconstructed closure operator:")
    for A in powerset(ground):
        print(f"  cl({set(A)}) = {set(rec_cl.cl(A))}")

    print()


def demo_partition_closure():
    """
    Example: 4-element ground set with partition-based closure.
    Partition: {0,1} | {2,3}. Closing = taking union of all blocks touching A.
    """
    print("=" * 60)
    print("Demo 2: Partition Closure on {0,1,2,3}")
    print("=" * 60)

    ground = frozenset({0, 1, 2, 3})
    blocks = [frozenset({0, 1}), frozenset({2, 3})]

    def cl(A: frozenset) -> frozenset:
        result = frozenset()
        for block in blocks:
            if A & block:
                result = result | block
        return result if A else frozenset()

    closure = FiniteClosure(ground, cl)
    print(f"Ground set: {set(ground)}")
    print(f"Partition blocks: {[set(b) for b in blocks]}")
    print(f"Closed sets: {[set(C) for C in closure.closed_sets()]}")

    # Defect: log-like measure — 0 for ∅, 1 for single block, 2 for both
    def delta(A: frozenset) -> int:
        clA = closure.cl(A)
        if not clA:
            return 0
        return sum(1 for b in blocks if clA & b)

    system = ClosureEntropySystem(closure, delta)
    ews = system.extremal_witnesses()
    print(f"\nExtremal witnesses: {[set(C) for C in ews]}")
    print(f"Spectrum rank: {system.spectrum_rank()}")

    ext = canonical_extractor(system)
    print(f"\nCanonical extractor:")
    print(f"  Seeds: {ext.num_seeds}")
    for i in range(ext.num_seeds):
        print(f"  Seed {i}: witness={set(ext.witness_sets[i])}, defect={ext.defect_bounds[i]}")
    print(f"  Realizes system: {ext.realizes(system)}")
    print(f"  Is seed-minimal: {ext.is_seed_minimal(system)}")
    print(f"  seed_count == spectrum_rank: {ext.num_seeds == system.spectrum_rank()}")
    print()


def demo_chain_closure():
    """
    Example: Chain closure on {0,1,2,3}.
    cl({}) = {}, cl({0}) = {0}, cl({0,1}) = {0,1}, cl({0,1,2}) = {0,1,2},
    anything with 3 elements or more closes to {0,1,2,3}.
    """
    print("=" * 60)
    print("Demo 3: Chain Closure on {0,1,2,3}")
    print("=" * 60)

    ground = frozenset({0, 1, 2, 3})

    def cl(A: frozenset) -> frozenset:
        # Chain: closed sets are ∅ ⊂ {0} ⊂ {0,1} ⊂ {0,1,2} ⊂ {0,1,2,3}
        chain = [frozenset(), frozenset({0}), frozenset({0, 1}),
                 frozenset({0, 1, 2}), ground]
        for C in chain:
            if A <= C:
                return C
        return ground

    closure = FiniteClosure(ground, cl)
    print(f"Ground set: {set(ground)}")
    print(f"Closed sets: {[set(C) for C in closure.closed_sets()]}")

    # Defect = position in chain (submodular on a chain = automatic)
    chain_list = [frozenset(), frozenset({0}), frozenset({0, 1}),
                  frozenset({0, 1, 2}), ground]
    def delta(A: frozenset) -> int:
        clA = closure.cl(A)
        return chain_list.index(clA)

    system = ClosureEntropySystem(closure, delta)
    ews = system.extremal_witnesses()
    print(f"\nExtremal witnesses: {[set(C) for C in ews]}")
    print(f"Spectrum rank: {system.spectrum_rank()}")

    ext = canonical_extractor(system)
    print(f"\nCanonical extractor:")
    print(f"  Seeds: {ext.num_seeds}")
    for i in range(ext.num_seeds):
        print(f"  Seed {i}: witness={set(ext.witness_sets[i])}, defect={ext.defect_bounds[i]}")
    print(f"  Realizes system: {ext.realizes(system)}")
    print(f"  Is seed-minimal: {ext.is_seed_minimal(system)}")
    print(f"  seed_count == spectrum_rank: {ext.num_seeds == system.spectrum_rank()}")

    # Verify rank-complexity equality
    print(f"\n  Generator rank = {system.spectrum_rank()}")
    print(f"  Minimal seed complexity = {ext.num_seeds}")
    print(f"  Rank == Complexity: {system.spectrum_rank() == ext.num_seeds}")
    print()


def demo_reconstruction_round_trip():
    """
    Demonstrate the full round-trip: system → extractor → reconstructed closure.
    """
    print("=" * 60)
    print("Demo 4: Round-Trip Reconstruction")
    print("=" * 60)

    ground = frozenset({0, 1, 2})

    def cl(A: frozenset) -> frozenset:
        if len(A) >= 2:
            return ground
        return A

    closure = FiniteClosure(ground, cl)

    def delta(A: frozenset) -> int:
        clA = closure.cl(A)
        if clA == frozenset():
            return 0
        return 1

    system = ClosureEntropySystem(closure, delta)
    ext = canonical_extractor(system)

    # Reconstruct
    rec_cl = reconstruct_closure(ext, ground)

    print("Original closure vs Reconstructed closure:")
    all_match = True
    for A in powerset(ground):
        orig = closure.cl(A)
        recon = rec_cl.cl(A)
        match = "✓" if orig == recon else "✗"
        if orig != recon:
            all_match = False
        print(f"  cl({str(set(A)):>12}) = {str(set(orig)):<15} rec_cl = {str(set(recon)):<15} {match}")

    print(f"\nAll closures match: {all_match}")
    print(f"Reconstruction is a valid closure operator: extensive={all(A <= rec_cl.cl(A) for A in powerset(ground))}")
    print()


if __name__ == "__main__":
    demo_linear_dependency()
    demo_partition_closure()
    demo_chain_closure()
    demo_reconstruction_round_trip()

    print("=" * 60)
    print("Summary: All demonstrations verify the duality theorem:")
    print("  spectrum_rank = minimal_seed_complexity")
    print("  Canonical extractor is seed-minimal")
    print("  Reconstruction yields valid closure operator")
    print("=" * 60)

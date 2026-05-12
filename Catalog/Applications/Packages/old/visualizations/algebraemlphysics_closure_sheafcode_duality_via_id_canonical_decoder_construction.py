"""
Algorithms for Closure-Sheaf Code Duality

Implements the core algorithms from the closure-decoder duality theory:
1. Constraint system construction and validation
2. Canonical decoder construction
3. Canonical constraint system from codewords
4. Refinement to reachable states (Myhill-Nerode minimization)
5. Pairwise consistency checking and gluing verification
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, TypeVar, Generic
from itertools import product
import numpy as np


@dataclass
class CellComplex:
    """A finite cell complex with an incidence relation.

    Attributes:
        n_cells: Number of cells.
        incidence: Boolean adjacency matrix (symmetric, reflexive).
    """
    n_cells: int
    incidence: np.ndarray  # (n_cells, n_cells) boolean matrix

    def __post_init__(self):
        assert self.incidence.shape == (self.n_cells, self.n_cells)
        # Ensure reflexivity
        for i in range(self.n_cells):
            self.incidence[i, i] = True

    def star(self, sigma: int) -> list[int]:
        """Return the star of cell sigma: all incident cells."""
        return [j for j in range(self.n_cells) if self.incidence[sigma, j]]

    @staticmethod
    def path_graph(n: int) -> 'CellComplex':
        """Create a path graph on n vertices."""
        inc = np.eye(n, dtype=bool)
        for i in range(n - 1):
            inc[i, i + 1] = True
            inc[i + 1, i] = True
        return CellComplex(n, inc)

    @staticmethod
    def cycle_graph(n: int) -> 'CellComplex':
        """Create a cycle graph on n vertices."""
        inc = np.eye(n, dtype=bool)
        for i in range(n):
            inc[i, (i + 1) % n] = True
            inc[(i + 1) % n, i] = True
        return CellComplex(n, inc)

    @staticmethod
    def complete_graph(n: int) -> 'CellComplex':
        """Create a complete graph on n vertices."""
        return CellComplex(n, np.ones((n, n), dtype=bool))

    @staticmethod
    def grid_graph(rows: int, cols: int) -> 'CellComplex':
        """Create a grid graph with given dimensions."""
        n = rows * cols
        inc = np.eye(n, dtype=bool)
        for r in range(rows):
            for c in range(cols):
                i = r * cols + c
                if c + 1 < cols:
                    inc[i, i + 1] = True
                    inc[i + 1, i] = True
                if r + 1 < rows:
                    inc[i, i + cols] = True
                    inc[i + cols, i] = True
        return CellComplex(n, inc)


@dataclass
class ConstraintSystem:
    """A constraint system on a cell complex.

    Attributes:
        complex: The underlying cell complex.
        obs_size: Number of possible observable values (alphabet size).
        domains: List of sets, domains[sigma] = admissible values at cell sigma.
        compat: Compatibility function (sigma, tau, a, b) -> bool.
    """
    complex: CellComplex
    obs_size: int
    domains: list[set[int]]
    compat: Callable[[int, int, int, int], bool]

    def is_valid(self, assignment: tuple[int, ...]) -> bool:
        """Check if an assignment is valid (zero-defect)."""
        n = self.complex.n_cells
        # Check domain membership
        for sigma in range(n):
            if assignment[sigma] not in self.domains[sigma]:
                return False
        # Check pairwise compatibility
        for sigma in range(n):
            for tau in range(n):
                if self.complex.incidence[sigma, tau]:
                    if not self.compat(sigma, tau,
                                       assignment[sigma], assignment[tau]):
                        return False
        return True

    def valid_set(self) -> set[tuple[int, ...]]:
        """Enumerate all valid assignments (brute force for small instances)."""
        domain_lists = [sorted(self.domains[i])
                        for i in range(self.complex.n_cells)]
        valid = set()
        for assignment in product(*domain_lists):
            if self.is_valid(assignment):
                valid.add(assignment)
        return valid

    def domain_defect_count(self, assignment: tuple[int, ...]) -> int:
        """Count domain violations."""
        return sum(1 for sigma in range(self.complex.n_cells)
                   if assignment[sigma] not in self.domains[sigma])

    def compat_defect_count(self, assignment: tuple[int, ...]) -> int:
        """Count compatibility violations."""
        count = 0
        for sigma in range(self.complex.n_cells):
            for tau in range(sigma + 1, self.complex.n_cells):
                if self.complex.incidence[sigma, tau]:
                    if not self.compat(sigma, tau,
                                       assignment[sigma], assignment[tau]):
                        count += 1
        return count

    def total_defect(self, assignment: tuple[int, ...]) -> int:
        """Total defect = domain defects + compatibility defects."""
        return self.domain_defect_count(assignment) + \
               self.compat_defect_count(assignment)

    def total_domain_size(self) -> int:
        """Sum of all domain sizes — the measure for refinement termination."""
        return sum(len(d) for d in self.domains)


@dataclass
class CellularDecoder:
    """A cellular decoder with local check predicates.

    Attributes:
        complex: The underlying cell complex.
        obs_size: Alphabet size.
        check: Function (sigma, assignment) -> bool.
    """
    complex: CellComplex
    obs_size: int
    check: Callable[[int, tuple[int, ...]], bool]

    def is_codeword(self, assignment: tuple[int, ...]) -> bool:
        """Check if an assignment passes all checks (is a codeword)."""
        return all(self.check(sigma, assignment)
                   for sigma in range(self.complex.n_cells))

    def codewords(self, domains: list[set[int]] | None = None) -> set[tuple[int, ...]]:
        """Enumerate all codewords."""
        if domains is None:
            domains = [set(range(self.obs_size))
                       for _ in range(self.complex.n_cells)]
        domain_lists = [sorted(domains[i])
                        for i in range(self.complex.n_cells)]
        return {a for a in product(*domain_lists) if self.is_codeword(a)}


def canonical_decoder(S: ConstraintSystem) -> CellularDecoder:
    """Construct the canonical decoder from a constraint system.

    The canonical decoder checks:
    1. Domain membership: f(σ) ∈ domain(σ)
    2. Pairwise compatibility: for all τ incident to σ, compat(σ, τ, f(σ), f(τ))

    This is Theorem A: the resulting codewords equal the valid set.
    """
    def check(sigma: int, assignment: tuple[int, ...]) -> bool:
        if assignment[sigma] not in S.domains[sigma]:
            return False
        for tau in range(S.complex.n_cells):
            if S.complex.incidence[sigma, tau]:
                if not S.compat(sigma, tau, assignment[sigma], assignment[tau]):
                    return False
        return True

    return CellularDecoder(S.complex, S.obs_size, check)


def canonical_constraint(K: CellComplex, obs_size: int,
                          W: set[tuple[int, ...]]) -> ConstraintSystem:
    """Construct the canonical constraint system from a set of valid assignments.

    Domains are projections: domain(σ) = {f(σ) | f ∈ W}
    Compatibility is co-occurrence: compat(σ, τ, a, b) iff ∃ f ∈ W: f(σ)=a, f(τ)=b

    This is Theorem B: the resulting valid set contains W.
    Theorem C (Minimality): this has the smallest domains among all systems
    whose valid set contains W.
    """
    n = K.n_cells
    domains = [set() for _ in range(n)]
    # Build co-occurrence sets for compatibility
    cooccurrence: dict[tuple[int, int], set[tuple[int, int]]] = {}

    for f in W:
        for sigma in range(n):
            domains[sigma].add(f[sigma])
        for sigma in range(n):
            for tau in range(n):
                if K.incidence[sigma, tau]:
                    key = (sigma, tau)
                    if key not in cooccurrence:
                        cooccurrence[key] = set()
                    cooccurrence[key].add((f[sigma], f[tau]))

    def compat(sigma: int, tau: int, a: int, b: int) -> bool:
        key = (sigma, tau)
        if key not in cooccurrence:
            return False
        return (a, b) in cooccurrence[key]

    return ConstraintSystem(K, obs_size, domains, compat)


def refine_to_reachable(S: ConstraintSystem) -> ConstraintSystem:
    """Refine a constraint system to reachable values only.

    Removes domain values that don't appear in any valid assignment.
    This is the Myhill-Nerode minimization step.

    Returns: Refined system with same valid set but minimal domains.
    """
    valid = S.valid_set()
    n = S.complex.n_cells

    # Project valid assignments to each cell
    new_domains = [set() for _ in range(n)]
    for f in valid:
        for sigma in range(n):
            new_domains[sigma].add(f[sigma])

    return ConstraintSystem(S.complex, S.obs_size, new_domains, S.compat)


def iterative_arc_consistency(S: ConstraintSystem,
                               max_iterations: int = 1000) -> tuple[ConstraintSystem, int]:
    """Iterative arc consistency refinement.

    Removes values from domains that have no compatible partner at any
    incident cell. Repeats until convergence.

    Returns: (refined system, number of iterations)
    """
    domains = [set(d) for d in S.domains]
    n = S.complex.n_cells

    for iteration in range(max_iterations):
        changed = False
        new_domains = [set(d) for d in domains]

        for sigma in range(n):
            for a in list(domains[sigma]):
                # Check: does a have a compatible partner at each incident cell?
                for tau in S.complex.star(sigma):
                    if tau == sigma:
                        continue
                    has_partner = any(
                        S.compat(sigma, tau, a, b)
                        for b in domains[tau]
                    )
                    if not has_partner:
                        new_domains[sigma].discard(a)
                        changed = True
                        break

        domains = new_domains
        if not changed:
            return ConstraintSystem(S.complex, S.obs_size, domains, S.compat), iteration + 1

    return ConstraintSystem(S.complex, S.obs_size, domains, S.compat), max_iterations


def check_pairwise_consistency(S: ConstraintSystem,
                                 assignment: tuple[int, ...]) -> bool:
    """Check if an assignment is pairwise consistent.

    Each value and each incident pair must co-occur with some valid assignment.
    """
    valid = S.valid_set()
    n = S.complex.n_cells

    # Check each value appears in some valid assignment
    for sigma in range(n):
        if not any(f[sigma] == assignment[sigma] for f in valid):
            return False

    # Check each incident pair co-occurs
    for sigma in range(n):
        for tau in range(n):
            if S.complex.incidence[sigma, tau]:
                if not any(f[sigma] == assignment[sigma] and
                           f[tau] == assignment[tau] for f in valid):
                    return False

    return True


def has_gluing_property(S: ConstraintSystem) -> bool:
    """Check if a constraint system has the finite gluing property.

    Tests: is every pairwise consistent assignment valid?
    """
    domain_lists = [sorted(S.domains[i])
                    for i in range(S.complex.n_cells)]
    for assignment in product(*domain_lists):
        if check_pairwise_consistency(S, assignment):
            if not S.is_valid(assignment):
                return False
    return True


def zero_defect_kernel_classes(S: ConstraintSystem,
                                sigma: int) -> list[set[int]]:
    """Compute the zero-defect kernel congruence classes at cell sigma.

    Two values a, b are equivalent if swapping them in any valid assignment
    preserves validity.
    """
    valid = S.valid_set()
    domain = sorted(S.domains[sigma])

    # Build equivalence classes by testing swap invariance
    parent = {a: a for a in domain}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for a in domain:
        for b in domain:
            if a >= b:
                continue
            # Check if a and b are zero-defect equivalent
            equivalent = True
            for f in valid:
                if f[sigma] == a:
                    # Swap a -> b
                    swapped = tuple(b if i == sigma else f[i]
                                    for i in range(S.complex.n_cells))
                    if not S.is_valid(swapped):
                        equivalent = False
                        break
                elif f[sigma] == b:
                    # Swap b -> a
                    swapped = tuple(a if i == sigma else f[i]
                                    for i in range(S.complex.n_cells))
                    if not S.is_valid(swapped):
                        equivalent = False
                        break
            if equivalent:
                union(a, b)

    # Collect classes
    classes: dict[int, set[int]] = {}
    for a in domain:
        root = find(a)
        if root not in classes:
            classes[root] = set()
        classes[root].add(a)
    return list(classes.values())


# === Factory functions for common constraint systems ===

def repetition_code(n: int, alphabet_size: int = 2) -> ConstraintSystem:
    """Create a repetition code: all cells must have the same value."""
    K = CellComplex.path_graph(n)
    domains = [set(range(alphabet_size)) for _ in range(n)]
    return ConstraintSystem(K, alphabet_size, domains,
                            lambda s, t, a, b: a == b)


def parity_check_code(n: int) -> ConstraintSystem:
    """Create a simple parity check code on a path graph.

    Adjacent cells must have different values (proper 2-coloring).
    """
    K = CellComplex.path_graph(n)
    domains = [set(range(2)) for _ in range(n)]

    def compat(sigma, tau, a, b):
        if sigma == tau:
            return a == b
        return a != b

    return ConstraintSystem(K, 2, domains, compat)


def coloring_constraint(K: CellComplex, num_colors: int) -> ConstraintSystem:
    """Create a graph coloring constraint system.

    Adjacent cells must have different colors.
    """
    domains = [set(range(num_colors)) for _ in range(K.n_cells)]

    def compat(sigma, tau, a, b):
        if sigma == tau:
            return True
        return a != b

    return ConstraintSystem(K, num_colors, domains, compat)


def verify_duality(S: ConstraintSystem, verbose: bool = True) -> dict:
    """Verify the full closure-decoder duality for a constraint system.

    Returns a dict with verification results.
    """
    results = {}

    # Theorem A: canonical decoder codewords = valid set
    D = canonical_decoder(S)
    valid = S.valid_set()
    codewords = D.codewords(S.domains)
    results['theorem_a'] = (valid == codewords)
    if verbose:
        print(f"Theorem A (decoder reconstruction): {'PASS' if results['theorem_a'] else 'FAIL'}")
        print(f"  Valid assignments: {len(valid)}")
        print(f"  Codewords: {len(codewords)}")

    # Theorem B: canonical constraint contains original codewords
    if valid:
        C = canonical_constraint(S.complex, S.obs_size, valid)
        c_valid = C.valid_set()
        results['theorem_b'] = valid.issubset(c_valid)
        if verbose:
            print(f"Theorem B (constraint canonicalization): {'PASS' if results['theorem_b'] else 'FAIL'}")
            print(f"  Canonical valid set size: {len(c_valid)}")

        # Theorem C: minimality
        original_sizes = [len(d) for d in S.domains]
        canonical_sizes = [len(d) for d in C.domains]
        results['theorem_c'] = all(c <= o for c, o in zip(canonical_sizes, original_sizes))
        if verbose:
            print(f"Theorem C (minimality): {'PASS' if results['theorem_c'] else 'FAIL'}")
            print(f"  Original domain sizes: {original_sizes}")
            print(f"  Canonical domain sizes: {canonical_sizes}")

        # Theorem D: round-trip under gluing
        gluing = has_gluing_property(S)
        results['has_gluing'] = gluing
        if gluing:
            results['theorem_d'] = (c_valid == valid)
            if verbose:
                print(f"Theorem D (round-trip duality): {'PASS' if results['theorem_d'] else 'FAIL'}")
                print(f"  System has gluing property: {gluing}")
        elif verbose:
            print(f"Theorem D: N/A (system lacks gluing property)")
            results['theorem_d'] = None

    # Refinement
    R = refine_to_reachable(S)
    r_valid = R.valid_set()
    results['refinement_preserves'] = (r_valid == valid)
    results['refinement_extensible'] = all(
        any(f[sigma] == a for f in r_valid)
        for sigma in range(S.complex.n_cells)
        for a in R.domains[sigma]
    )
    if verbose:
        print(f"Refinement preserves valid set: {'PASS' if results['refinement_preserves'] else 'FAIL'}")
        print(f"Refinement is extensible: {'PASS' if results['refinement_extensible'] else 'FAIL'}")
        refined_sizes = [len(d) for d in R.domains]
        print(f"  Refined domain sizes: {refined_sizes}")

    return results


if __name__ == '__main__':
    print("=" * 60)
    print("CLOSURE-SHEAF CODE DUALITY — ALGORITHM VERIFICATION")
    print("=" * 60)

    print("\n--- Example 1: Repetition Code (n=4, binary) ---")
    S1 = repetition_code(4, 2)
    verify_duality(S1)

    print("\n--- Example 2: Parity Check Code (n=4) ---")
    S2 = parity_check_code(4)
    verify_duality(S2)

    print("\n--- Example 3: 3-Coloring of Triangle ---")
    K3 = CellComplex.cycle_graph(3)
    S3 = coloring_constraint(K3, 3)
    verify_duality(S3)

    print("\n--- Example 4: 2-Coloring of Path (n=5) ---")
    S4 = parity_check_code(5)
    verify_duality(S4)

    print("\n--- Example 5: Binary on Grid (2x2) ---")
    K_grid = CellComplex.grid_graph(2, 2)
    S5 = coloring_constraint(K_grid, 2)
    verify_duality(S5)

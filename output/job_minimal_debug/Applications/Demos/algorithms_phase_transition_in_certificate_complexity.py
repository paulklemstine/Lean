#!/usr/bin/env python3
"""
Algorithms for Certificate Phase Transition Analysis
=====================================================

Implements core algorithms from the research paper:
1. Certificate Obstruction System construction
2. Satisfiability checking (exact and sampled)
3. Transition window computation
4. Hitting set / transversal computation
5. Disjoint packing bound computation
"""

import itertools
import random
from typing import FrozenSet, Set, List, Tuple, Optional, Dict
from dataclasses import dataclass, field


# ---------------------------------------------------------------------------
# Core Data Structures
# ---------------------------------------------------------------------------

@dataclass
class CertificateObstructionSystem:
    """
    A certificate obstruction system: a finite hypergraph whose vertices
    are certificate atoms and whose edges are minimal obstructions.
    
    Corresponds to the Lean structure:
        structure CertificateObstructionSystem (α : Type*) where
          obstructions : Finset (Finset α)
          nonempty_mem : ∀ s ∈ obstructions, s.Nonempty
    
    Attributes:
        atoms: Set of all certificate atoms (universe)
        obstructions: List of frozensets, each an obstruction
    """
    atoms: FrozenSet
    obstructions: List[FrozenSet]
    
    def __post_init__(self):
        # Verify nonemptiness invariant
        for obs in self.obstructions:
            assert len(obs) > 0, "Every obstruction must be nonempty"
    
    @property
    def n_atoms(self) -> int:
        return len(self.atoms)
    
    @property
    def n_obstructions(self) -> int:
        return len(self.obstructions)
    
    @property
    def density(self) -> float:
        """Obstruction density = |obstructions| / |atoms|."""
        if self.n_atoms == 0:
            return 0.0
        return self.n_obstructions / self.n_atoms
    
    @property
    def min_obstruction_size(self) -> Optional[int]:
        """Minimum obstruction cardinality."""
        if not self.obstructions:
            return None
        return min(len(o) for o in self.obstructions)
    
    @property
    def avg_obstruction_size(self) -> float:
        """Average obstruction cardinality."""
        if not self.obstructions:
            return 0.0
        return sum(len(o) for o in self.obstructions) / len(self.obstructions)


@dataclass
class TransitionWindow:
    """Result of transition window computation."""
    k_sat_max: int          # Largest k where all size-k sets are satisfiable
    k_unsat_min: int        # Smallest k where all size-k sets are unsatisfiable  
    k_half: Optional[int]   # k where P(sat) crosses 0.5
    sat_prob: Dict[int, float]  # Satisfiability probability by cardinality
    exact: bool             # Whether computation was exhaustive


# ---------------------------------------------------------------------------
# Algorithm 1: Satisfiability Check
# ---------------------------------------------------------------------------

def is_satisfiable(system: CertificateObstructionSystem, 
                   retained: FrozenSet) -> bool:
    """
    Check if retained set is satisfiable.
    
    Corresponds to Lean definition:
        def CertificateSatisfiable C S := ∀ o ∈ C.obstructions, ¬ o ⊆ S
    
    Time: O(|obstructions| × max_obstruction_size)
    Space: O(1) additional
    
    Args:
        system: The certificate obstruction system
        retained: The set of retained certificate atoms
    
    Returns:
        True if no obstruction is fully contained in retained
    
    Examples:
        >>> atoms = frozenset({1, 2, 3, 4})
        >>> obs = [frozenset({1, 2, 3})]
        >>> sys = CertificateObstructionSystem(atoms, obs)
        >>> is_satisfiable(sys, frozenset({1, 2}))
        True
        >>> is_satisfiable(sys, frozenset({1, 2, 3}))
        False
    """
    retained_set = set(retained)
    for obs in system.obstructions:
        if obs.issubset(retained_set):
            return False
    return True


# ---------------------------------------------------------------------------
# Algorithm 2: Hitting Set Check (Complement Formulation)
# ---------------------------------------------------------------------------

def is_hitting_set(system: CertificateObstructionSystem,
                   removed: FrozenSet) -> bool:
    """
    Check if the removed set is a hitting set for the obstruction hypergraph.
    
    Corresponds to the Lean theorem:
        certificateSatisfiable_iff_compl_hittingSet
    
    Satisfiability of retained = atoms \ removed is equivalent to
    removed being a hitting set (transversal) of the obstructions.
    
    Time: O(|obstructions| × max_obstruction_size)
    
    Args:
        system: The certificate obstruction system
        removed: The set of removed certificate atoms
    
    Returns:
        True if removed hits every obstruction
    
    Examples:
        >>> atoms = frozenset({1, 2, 3, 4})
        >>> obs = [frozenset({1, 2, 3}), frozenset({2, 3, 4})]
        >>> sys = CertificateObstructionSystem(atoms, obs)
        >>> is_hitting_set(sys, frozenset({2}))
        True
        >>> is_hitting_set(sys, frozenset({1}))
        False
    """
    for obs in system.obstructions:
        if not obs.intersection(removed):
            return False
    return True


def verify_hitting_set_equivalence(system: CertificateObstructionSystem,
                                    retained: FrozenSet) -> bool:
    """
    Verify the hitting-set ↔ satisfiability equivalence.
    
    This is a computational check of the theorem
    certificateSatisfiable_iff_compl_hittingSet.
    
    Returns True if both sides agree.
    """
    removed = system.atoms - retained
    sat = is_satisfiable(system, retained)
    hitting = is_hitting_set(system, removed)
    return sat == hitting


# ---------------------------------------------------------------------------
# Algorithm 3: Transition Window Computation
# ---------------------------------------------------------------------------

def compute_transition_window(
    system: CertificateObstructionSystem,
    n_samples: int = 500,
    exhaustive_threshold: int = 10000
) -> TransitionWindow:
    """
    Compute the transition window for a certificate obstruction system.
    
    For each cardinality k from 0 to |atoms|, estimates the probability
    that a random subset of size k is satisfiable.
    
    Complexity:
        - Exhaustive mode: O(2^n × |obstructions| × max_obs_size) 
        - Sampling mode: O(n × n_samples × |obstructions| × max_obs_size)
    
    The transition window [k₁, k₂] satisfies:
        - ∀ S with |S| ≤ k₁: S is satisfiable
        - ∀ S with |S| ≥ k₂: S is unsatisfiable
    
    This corresponds to the Lean theorem exists_transition_window.
    
    Args:
        system: The certificate obstruction system
        n_samples: Number of random samples per cardinality level
        exhaustive_threshold: Use exhaustive enumeration below this many subsets
    
    Returns:
        TransitionWindow with computed statistics
    """
    atoms_list = sorted(system.atoms)
    n = len(atoms_list)
    sat_prob = {}
    is_exact = True
    
    import math
    
    for k in range(n + 1):
        n_choose_k = math.comb(n, k)
        
        if n_choose_k <= exhaustive_threshold:
            # Exhaustive enumeration
            sat_count = 0
            total = 0
            for subset in itertools.combinations(atoms_list, k):
                total += 1
                if is_satisfiable(system, frozenset(subset)):
                    sat_count += 1
            sat_prob[k] = sat_count / total if total > 0 else 1.0
        else:
            is_exact = False
            sat_count = 0
            for _ in range(n_samples):
                subset = frozenset(random.sample(atoms_list, k))
                if is_satisfiable(system, subset):
                    sat_count += 1
            sat_prob[k] = sat_count / n_samples
    
    # Find k_sat_max
    k_sat_max = 0
    for k in range(n + 1):
        if sat_prob[k] >= 1.0 - 1e-9:
            k_sat_max = k
        else:
            break
    
    # Find k_unsat_min
    k_unsat_min = n
    for k in range(n, -1, -1):
        if sat_prob[k] <= 1e-9:
            k_unsat_min = k
        else:
            break
    
    # Find k_half
    k_half = None
    for k in sorted(sat_prob.keys()):
        if sat_prob[k] < 0.5:
            k_half = k
            break
    
    return TransitionWindow(
        k_sat_max=k_sat_max,
        k_unsat_min=k_unsat_min,
        k_half=k_half,
        sat_prob=sat_prob,
        exact=is_exact
    )


# ---------------------------------------------------------------------------
# Algorithm 4: Greedy Minimum Hitting Set (Approximation)
# ---------------------------------------------------------------------------

def greedy_hitting_set(system: CertificateObstructionSystem) -> FrozenSet:
    """
    Compute an approximate minimum hitting set using greedy algorithm.
    
    At each step, select the atom that hits the most unhit obstructions.
    
    Time: O(|atoms| × |obstructions| × max_obs_size)
    
    Approximation ratio: O(ln(max_obstruction_size)) by standard analysis.
    
    Args:
        system: The certificate obstruction system
    
    Returns:
        A hitting set (not necessarily minimum)
    """
    uncovered = list(range(len(system.obstructions)))
    hitting_set = set()
    
    while uncovered:
        # Count how many uncovered obstructions each atom hits
        best_atom = None
        best_count = -1
        
        for atom in system.atoms:
            if atom in hitting_set:
                continue
            count = sum(1 for i in uncovered 
                       if atom in system.obstructions[i])
            if count > best_count:
                best_count = count
                best_atom = atom
        
        if best_atom is None or best_count == 0:
            break
        
        hitting_set.add(best_atom)
        uncovered = [i for i in uncovered 
                    if best_atom not in system.obstructions[i]]
    
    return frozenset(hitting_set)


# ---------------------------------------------------------------------------
# Algorithm 5: Disjoint Packing (Greedy)
# ---------------------------------------------------------------------------

def greedy_disjoint_packing(system: CertificateObstructionSystem) -> List[FrozenSet]:
    """
    Find a maximal collection of pairwise disjoint obstructions.
    
    This gives an upper bound on the transition location:
    if we find m disjoint obstructions, then any retained set of size
    > |atoms| - m must be unsatisfiable.
    
    Corresponds to the Lean theorem unsat_of_disjoint_packing.
    
    Time: O(|obstructions|² × max_obs_size)
    
    Args:
        system: The certificate obstruction system
    
    Returns:
        List of pairwise disjoint obstructions
    """
    packing = []
    used_atoms = set()
    
    # Sort by size (prefer smaller obstructions for better packing)
    sorted_obs = sorted(system.obstructions, key=len)
    
    for obs in sorted_obs:
        if not obs.intersection(used_atoms):
            packing.append(obs)
            used_atoms.update(obs)
    
    return packing


# ---------------------------------------------------------------------------
# Algorithm 6: Triangle Certificate System Construction
# ---------------------------------------------------------------------------

def triangle_certificate_system(n: int) -> CertificateObstructionSystem:
    """
    Construct the triangle certificate obstruction system for K_n.
    
    Atoms: edges of K_n (as sorted tuples (i,j) with i < j)
    Obstructions: triangles (sets of 3 edges forming a triangle)
    
    Corresponds to the Lean definition triangleCertSystem.
    
    Time: O(n³) for construction
    
    Args:
        n: Number of vertices (must be ≥ 3)
    
    Returns:
        CertificateObstructionSystem for triangle detection
    
    Examples:
        >>> sys = triangle_certificate_system(4)
        >>> sys.n_atoms
        6
        >>> sys.n_obstructions
        4
        >>> sys.min_obstruction_size
        3
    """
    assert n >= 3, "Need at least 3 vertices"
    
    atoms = frozenset((i, j) for i, j in itertools.combinations(range(n), 2))
    
    obstructions = []
    for i, j, k in itertools.combinations(range(n), 3):
        triangle = frozenset({(i, j), (i, k), (j, k)})
        obstructions.append(triangle)
    
    return CertificateObstructionSystem(atoms=atoms, obstructions=obstructions)


# ---------------------------------------------------------------------------
# Algorithm 7: Structural Bounds
# ---------------------------------------------------------------------------

def compute_structural_bounds(system: CertificateObstructionSystem) -> Dict:
    """
    Compute structural bounds on the transition location.
    
    Lower bound: min_obstruction_size - 1 (from satisfiable_of_card_lt_minObstructionSize)
    Upper bound: |atoms| - |max_packing| (from unsat_of_disjoint_packing)
    
    Args:
        system: The certificate obstruction system
    
    Returns:
        Dict with 'lower_bound', 'upper_bound', 'packing_size'
    """
    min_size = system.min_obstruction_size
    lower = (min_size - 1) if min_size is not None else 0
    
    packing = greedy_disjoint_packing(system)
    packing_size = len(packing)
    upper = system.n_atoms - packing_size + 1
    
    return {
        'lower_bound': lower,  # All sets of size ≤ lower are satisfiable
        'upper_bound': upper,  # All sets of size ≥ upper are unsatisfiable
        'packing_size': packing_size,
        'min_obstruction_size': min_size,
        'hitting_set_size': len(greedy_hitting_set(system))
    }


# ---------------------------------------------------------------------------
# Demo
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    print("Certificate Phase Transition Algorithms — Demo\n")
    
    # Build triangle system for K_6
    sys = triangle_certificate_system(6)
    print(f"Triangle system K_6:")
    print(f"  Atoms: {sys.n_atoms}")
    print(f"  Obstructions: {sys.n_obstructions}")
    print(f"  Density: {sys.density:.4f}")
    print(f"  Min obstruction size: {sys.min_obstruction_size}")
    print(f"  Avg obstruction size: {sys.avg_obstruction_size:.2f}")
    
    # Structural bounds
    bounds = compute_structural_bounds(sys)
    print(f"\nStructural bounds:")
    print(f"  Lower (min obs size - 1): {bounds['lower_bound']}")
    print(f"  Upper (atoms - packing):  {bounds['upper_bound']}")
    print(f"  Packing size:             {bounds['packing_size']}")
    print(f"  Greedy hitting set size:  {bounds['hitting_set_size']}")
    
    # Transition window
    tw = compute_transition_window(sys, n_samples=300)
    print(f"\nTransition window: [{tw.k_sat_max}, {tw.k_unsat_min}]")
    print(f"  k_half (50% sat): {tw.k_half}")
    print(f"  Exact computation: {tw.exact}")
    
    # Verify hitting-set equivalence
    import random
    random.seed(42)
    atoms_list = sorted(sys.atoms)
    all_agree = True
    for _ in range(100):
        k = random.randint(0, len(atoms_list))
        subset = frozenset(random.sample(atoms_list, k))
        if not verify_hitting_set_equivalence(sys, subset):
            all_agree = False
            break
    print(f"\nHitting-set equivalence verified on 100 random samples: {all_agree}")

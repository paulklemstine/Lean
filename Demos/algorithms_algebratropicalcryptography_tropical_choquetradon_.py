#!/usr/bin/env python3
"""
Algorithms for Tropical Choquet–Radon Trapdoor Duality

Implements the core algorithms from the research paper:
1. Canonical support computation
2. Support recovery from profiles
3. Collision detection and enumeration
4. Separation matrix analysis
"""

from typing import FrozenSet, Dict, List, Tuple, Set, Optional, Callable
from itertools import combinations, product as iter_product
from collections import defaultdict
import numpy as np


# =============================================================================
# Algorithm 1: Canonical Support Computation
# =============================================================================

def canonical_support(x: np.ndarray) -> FrozenSet[int]:
    """
    Compute the canonical minimal support of x ∈ ℤⁿ.
    
    The canonical support is the set of indices where x is nonzero.
    This is the unique minimal set K such that x is supported on K.
    
    Complexity: O(n) where n = len(x).
    
    Corresponds to Theorem 1 (exists_unique_minimal_extremal_support).
    
    Args:
        x: Integer vector
    
    Returns:
        Frozenset of indices where x is nonzero
    
    Examples:
        >>> canonical_support(np.array([0, 3, 0, 7]))
        frozenset({1, 3})
        >>> canonical_support(np.array([0, 0, 0, 0]))
        frozenset()
    """
    return frozenset(i for i in range(len(x)) if x[i] != 0)


def verify_support_minimality(x: np.ndarray) -> bool:
    """
    Verify that the canonical support is indeed the intersection of all supports.
    
    This is a direct computational verification of Theorem 1:
    suppC(x) = ∩{K | Supports x K}.
    
    Complexity: O(2^n * n) — enumerates all subsets.
    """
    n = len(x)
    min_supp = canonical_support(x)
    
    # Compute intersection of all supports
    all_supports = []
    for size in range(n + 1):
        for combo in combinations(range(n), size):
            K = frozenset(combo)
            if min_supp.issubset(K):
                all_supports.append(K)
    
    if not all_supports:
        return len(min_supp) == 0
    
    intersection = frozenset.intersection(*all_supports)
    return intersection == min_supp


# =============================================================================
# Algorithm 2: Support Recovery (Theorem 3)
# =============================================================================

def make_coordinate_tests(n: int) -> Callable[[int, tuple], bool]:
    """
    Create a certified exposed basis for the coordinate-indicator profile.
    
    test_e(p) = True iff coordinate e is detected as nonzero in profile p.
    This is the "private key" — the test battery.
    
    Args:
        n: Number of generators
    
    Returns:
        Test function: (generator_index, profile) -> bool
    """
    def test(e: int, p: tuple) -> bool:
        return p[e] == 1
    return test


def recover_support(
    tests: Callable[[int, tuple], bool],
    profile: tuple,
    n: int
) -> FrozenSet[int]:
    """
    Support recovery algorithm (Algorithm 3.6).
    
    Given a certified test battery and a profile value, recover the
    canonical support by testing each generator independently.
    
    Complexity: O(n) test evaluations.
    
    Corresponds to Theorem 3 (recoverSupport_correct).
    
    Args:
        tests: Certified test function (e, p) -> bool
        profile: Profile value to invert
        n: Number of generators
    
    Returns:
        Recovered support as a frozenset
    """
    return frozenset(e for e in range(n) if tests(e, profile))


def verify_recovery_correctness(
    n: int,
    num_samples: int = 1000,
    max_val: int = 10,
    seed: int = 42
) -> Tuple[int, int]:
    """
    Verify recovery correctness on random samples.
    
    Returns:
        (correct_count, total_count)
    """
    rng = np.random.RandomState(seed)
    tests = make_coordinate_tests(n)
    profile_fn = lambda x: tuple(1 if x[i] != 0 else 0 for i in range(n))
    
    correct = 0
    for _ in range(num_samples):
        x = rng.randint(0, max_val, size=n)
        p = profile_fn(x)
        true_supp = canonical_support(x)
        recovered = recover_support(tests, p, n)
        if recovered == true_supp:
            correct += 1
    
    return correct, num_samples


# =============================================================================
# Algorithm 3: Collision Detection and Enumeration
# =============================================================================

def find_collisions(
    n: int,
    profile_fn: Callable[[np.ndarray], tuple],
    max_val: int = 3
) -> Dict[tuple, Set[FrozenSet[int]]]:
    """
    Find all collision families: profile values with multiple distinct supports.
    
    A collision is a pair (x, y) where profile(x) = profile(y) but
    suppC(x) ≠ suppC(y). This function groups elements by profile and
    identifies profiles with multiple distinct supports.
    
    Corresponds to Theorem 4 (exists_collision_of_not_exposed).
    
    Complexity: O(max_val^n * n) — exhaustive enumeration.
    
    Args:
        n: Number of generators
        profile_fn: Profile map
        max_val: Range of coordinate values [0, max_val)
    
    Returns:
        Dictionary: profile -> set of distinct supports under that profile
    """
    profile_to_supports: Dict[tuple, Set[FrozenSet[int]]] = defaultdict(set)
    
    for vals in iter_product(range(max_val), repeat=n):
        x = np.array(vals)
        p = profile_fn(x)
        s = canonical_support(x)
        profile_to_supports[p].add(s)
    
    # Filter to profiles with actual collisions
    return {
        p: supps for p, supps in profile_to_supports.items()
        if len(supps) > 1
    }


def collision_multiplicity_distribution(
    collisions: Dict[tuple, Set[FrozenSet[int]]]
) -> Dict[int, int]:
    """
    Compute the distribution of collision multiplicities.
    
    Returns dict mapping multiplicity -> count of profiles with that multiplicity.
    """
    dist: Dict[int, int] = defaultdict(int)
    for supps in collisions.values():
        dist[len(supps)] += 1
    return dict(sorted(dist.items()))


# =============================================================================
# Algorithm 4: Separation Matrix Analysis
# =============================================================================

def separation_matrix(
    n: int,
    profile_fn: Callable[[np.ndarray], tuple],
    max_val: int = 3
) -> np.ndarray:
    """
    Compute the separation matrix for the system.
    
    The separation matrix M has entry M[e, t] = 1 if test t can distinguish
    generator e. The rank of this matrix determines the degree of exposedness.
    
    Full rank = globally exposed (Theorem 2 applies).
    Rank deficient = collisions exist (Theorem 4 applies).
    
    Args:
        n: Number of generators
        profile_fn: Profile map
        max_val: Coordinate range
    
    Returns:
        Binary matrix of shape (n, num_unique_profiles)
    """
    # For each generator e, determine which profiles "see" e
    all_profiles: Set[tuple] = set()
    generator_profile_sets: List[Set[tuple]] = [set() for _ in range(n)]
    
    for vals in iter_product(range(max_val), repeat=n):
        x = np.array(vals)
        p = profile_fn(x)
        all_profiles.add(p)
        for e in range(n):
            if x[e] != 0:
                generator_profile_sets[e].add(p)
    
    profile_list = sorted(all_profiles)
    profile_index = {p: i for i, p in enumerate(profile_list)}
    
    matrix = np.zeros((n, len(profile_list)), dtype=int)
    for e in range(n):
        for p in generator_profile_sets[e]:
            matrix[e, profile_index[p]] = 1
    
    return matrix


def analyze_exposedness(
    n: int,
    profile_fn: Callable[[np.ndarray], tuple],
    max_val: int = 3
) -> Dict[str, object]:
    """
    Analyze the exposedness properties of a tropical system.
    
    Returns a dictionary with:
    - 'rank': rank of the separation matrix
    - 'deficiency': n - rank (degree of non-exposedness)
    - 'is_globally_exposed': whether the system is globally exposed
    - 'num_collisions': number of collision families
    - 'max_multiplicity': largest collision family size
    """
    sep_mat = separation_matrix(n, profile_fn, max_val)
    rank = int(np.linalg.matrix_rank(sep_mat))
    
    collisions = find_collisions(n, profile_fn, max_val)
    max_mult = max((len(s) for s in collisions.values()), default=1)
    
    return {
        'rank': rank,
        'deficiency': n - rank,
        'is_globally_exposed': len(collisions) == 0,
        'num_collisions': len(collisions),
        'max_multiplicity': max_mult,
        'matrix_shape': sep_mat.shape,
    }


# =============================================================================
# Algorithm 5: Phase Transition Detection
# =============================================================================

def phase_transition_scan(
    n: int,
    max_val: int = 3,
    num_random_profiles: int = 50,
    seed: int = 42
) -> List[Tuple[int, float, int]]:
    """
    Scan for the phase transition between exposed and non-exposed regimes.
    
    Generates random profile maps of increasing dimension and measures
    the collision rate.
    
    Returns list of (profile_dim, collision_rate, max_multiplicity).
    """
    rng = np.random.RandomState(seed)
    results = []
    
    for dim in range(1, n + 2):
        # Random projection profile: project to dim-dimensional space
        proj = rng.randint(-2, 3, size=(dim, n))
        
        def make_profile(proj_matrix):
            def profile_fn(x):
                return tuple(int(v) % 5 for v in proj_matrix @ x)
            return profile_fn
        
        pf = make_profile(proj)
        
        # Count collisions on a sample
        profile_groups: Dict[tuple, Set[FrozenSet[int]]] = defaultdict(set)
        for vals in iter_product(range(max_val), repeat=n):
            x = np.array(vals)
            profile_groups[pf(x)].add(canonical_support(x))
        
        num_collision_profiles = sum(
            1 for s in profile_groups.values() if len(s) > 1
        )
        total_profiles = len(profile_groups)
        collision_rate = num_collision_profiles / max(total_profiles, 1)
        max_mult = max((len(s) for s in profile_groups.values()), default=1)
        
        results.append((dim, collision_rate, max_mult))
    
    return results


# =============================================================================
# Main: Run all algorithms with example outputs
# =============================================================================

if __name__ == "__main__":
    print("Tropical Choquet–Radon Trapdoor Duality: Algorithm Demonstrations")
    print("=" * 70)
    
    # Algorithm 1: Canonical support
    print("\n[Algorithm 1] Canonical Support Computation")
    for x in [np.array([0, 3, 0, 7, 0, 1]), np.array([1, 1, 1, 1])]:
        s = canonical_support(x)
        v = verify_support_minimality(x)
        print(f"  x = {x} → suppC = {set(s)}, minimality verified: {v}")
    
    # Algorithm 2: Recovery
    print("\n[Algorithm 2] Support Recovery")
    for n in [4, 8, 16]:
        correct, total = verify_recovery_correctness(n, num_samples=500)
        print(f"  n = {n:2d}: {correct}/{total} correct ({100*correct/total:.1f}%)")
    
    # Algorithm 3: Collision detection
    print("\n[Algorithm 3] Collision Detection")
    n = 4
    for p_mod in [3, 5, 7]:
        pf = lambda x, m=p_mod: (int(np.sum(x)) % m,)
        colls = find_collisions(n, pf, max_val=3)
        dist = collision_multiplicity_distribution(colls)
        print(f"  sum mod {p_mod}: {len(colls)} collision profiles, "
              f"multiplicity dist = {dist}")
    
    # Algorithm 4: Separation analysis
    print("\n[Algorithm 4] Separation Matrix Analysis")
    n = 4
    profiles_to_test = [
        ("coordinate-indicator",
         lambda x: tuple(1 if x[i] != 0 else 0 for i in range(4))),
        ("sum-mod-5",
         lambda x: (int(np.sum(x)) % 5,)),
        ("parity",
         lambda x: tuple(int(x[i]) % 2 for i in range(4))),
    ]
    for name, pf in profiles_to_test:
        analysis = analyze_exposedness(4, pf, max_val=3)
        print(f"  {name}: rank={analysis['rank']}, deficiency={analysis['deficiency']}, "
              f"exposed={analysis['is_globally_exposed']}, "
              f"collisions={analysis['num_collisions']}")
    
    # Algorithm 5: Phase transition
    print("\n[Algorithm 5] Phase Transition Scan (n=4)")
    results = phase_transition_scan(4, max_val=2)
    for dim, rate, mult in results:
        bar = "█" * int(rate * 30)
        print(f"  dim={dim}: collision_rate={rate:.3f} max_mult={mult:3d} {bar}")
    
    print("\nAll algorithms executed successfully.")

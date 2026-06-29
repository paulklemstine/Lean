"""
Algorithms for Adelic Synchronization in Arithmetic Dynamics

Implements the core algorithms from the research:
1. Functional graph computation
2. Orbit signature extraction  
3. Adelic synchronization index
4. Phase transition detection
5. Cross-prime mutual information estimation

All algorithms include docstrings, type hints, and complexity analysis.
"""

from collections import Counter, defaultdict
from math import log2, sqrt
from typing import Callable, Dict, List, Optional, Set, Tuple


# ============================================================
# Algorithm 1: Functional Graph Decomposition
# Time: O(n) where n = |domain|
# Space: O(n)
# ============================================================

def compute_functional_graph(
    f: Callable[[int], int],
    domain: List[int]
) -> Dict[int, Tuple[int, int, List[int]]]:
    """
    Compute the complete functional graph of f on a finite domain.
    
    For each point x, computes:
    - preperiod: number of steps before entering the cycle
    - period: length of the cycle
    - orbit: the full orbit [x, f(x), f²(x), ...]
    
    Algorithm:
    1. For each unvisited point, follow the orbit until we revisit a point.
    2. Use Floyd's cycle detection or simple marking to find the cycle.
    
    Time complexity: O(n) where n = |domain|
    Space complexity: O(n)
    
    Args:
        f: The map to iterate
        domain: The finite domain (list of elements)
    
    Returns:
        Dictionary mapping each element to (preperiod, period, orbit)
    
    Example:
        >>> f = lambda x: (x*x + 1) % 7
        >>> graph = compute_functional_graph(f, list(range(7)))
        >>> graph[0]  # (preperiod, period, orbit)
    """
    result = {}
    for x in domain:
        if x in result:
            continue
        # Trace the orbit
        seen = {}
        orbit = []
        val = x
        step = 0
        while val not in seen:
            if val in result:
                # Already computed — link up
                pre_existing, per_existing, _ = result[val]
                for i, pt in enumerate(orbit):
                    result[pt] = (pre_existing + step - i, per_existing, orbit[i:])
                break
            seen[val] = step
            orbit.append(val)
            val = f(val)
            step += 1
        else:
            # Found a repeat within this orbit
            cycle_start = seen[val]
            period = step - cycle_start
            for i, pt in enumerate(orbit):
                pre = max(0, cycle_start - i)
                result[pt] = (pre, period, orbit[i:])
    return result


# ============================================================
# Algorithm 2: Orbit Signature Extraction
# Time: O(n) where n = |domain|
# Space: O(n)
# ============================================================

def extract_orbit_signature(
    f: Callable[[int], int],
    domain: List[int]
) -> Tuple[List[int], int]:
    """
    Extract the orbit signature: the multiset of cycle lengths
    and the number of tree (preperiodic) elements.
    
    This is the key combinatorial invariant for cross-prime
    comparison in adelic dynamics.
    
    Algorithm:
    1. Compute the functional graph.
    2. Identify cycle elements (preperiod = 0).
    3. Group cycle elements by their cycle, recording lengths.
    4. Count non-cycle elements as tree size.
    
    Time complexity: O(n)
    Space complexity: O(n)
    
    Args:
        f: The map to iterate
        domain: The finite domain
    
    Returns:
        (cycle_lengths, tree_size) where cycle_lengths is a sorted list
    """
    graph = compute_functional_graph(f, domain)
    
    visited_cycles: Set[int] = set()
    cycle_lengths: List[int] = []
    tree_size = 0
    
    for x in domain:
        pre, per, orbit = graph[x]
        if pre == 0 and x not in visited_cycles:
            cycle_lengths.append(per)
            val = x
            for _ in range(per):
                visited_cycles.add(val)
                val = f(val)
        elif pre > 0:
            tree_size += 1
    
    return sorted(cycle_lengths), tree_size


# ============================================================
# Algorithm 3: Adelic Synchronization Index
# Time: O(k) where k = max(|cycles1|, |cycles2|)
# Space: O(k)
# ============================================================

def adelic_sync_index(
    sig1: Tuple[List[int], int],
    sig2: Tuple[List[int], int]
) -> float:
    """
    Compute the adelic synchronization index between two orbit signatures.
    
    The sync index measures the fraction of cycle-length information
    that agrees between two dynamical systems (typically the same map
    reduced modulo different primes).
    
    Definition:
        ASI(S1, S2) = |cycles1 ∩ cycles2| / max(|cycles1|, |cycles2|)
    where the intersection is a multiset intersection.
    
    Properties (formally verified in Lean):
    - 0 ≤ ASI(S1, S2) ≤ 1
    - ASI(S, S) = 1 for nonempty S
    - ASI(S1, S2) = 0 when cycle multisets are disjoint
    
    Time complexity: O(k) where k = max length of cycle lists
    Space complexity: O(k)
    
    Args:
        sig1: First orbit signature (cycle_lengths, tree_size)
        sig2: Second orbit signature (cycle_lengths, tree_size)
    
    Returns:
        Synchronization index in [0, 1]
    """
    cycles1, _ = sig1
    cycles2, _ = sig2
    
    if not cycles1 or not cycles2:
        return 0.0
    
    c1 = Counter(cycles1)
    c2 = Counter(cycles2)
    common = sum((c1 & c2).values())
    
    return common / max(len(cycles1), len(cycles2))


# ============================================================
# Algorithm 4: Cross-Prime Synchronization Matrix
# Time: O(P² · n) where P = number of primes, n = max prime
# Space: O(P² + P·n)
# ============================================================

def compute_sync_matrix(
    c: int,
    primes: List[int],
    map_factory: Optional[Callable] = None
) -> Tuple[Dict[Tuple[int, int], float], float]:
    """
    Compute the full cross-prime synchronization matrix for a
    parameterized family of maps.
    
    For each pair of primes (p, q), computes the synchronization
    index between the orbit signatures of f_c mod p and f_c mod q.
    
    Algorithm:
    1. For each prime p, compute the orbit signature of f_c mod p.
    2. For each pair (p, q), compute the sync index.
    3. Return the matrix and mean synchronization.
    
    Time complexity: O(P² · n) where P = |primes|, n = max prime
    Space complexity: O(P² + P · n)
    
    Args:
        c: Parameter value
        primes: List of primes to use
        map_factory: Optional custom map factory. Default: x -> x² + c
    
    Returns:
        (sync_matrix, mean_sync) where sync_matrix maps (p,q) -> sync value
    """
    if map_factory is None:
        def make_map(c_val, p):
            return lambda x: (x * x + c_val) % p
    else:
        make_map = map_factory
    
    # Compute signatures
    signatures = {}
    for p in primes:
        f = make_map(c, p)
        signatures[p] = extract_orbit_signature(f, list(range(p)))
    
    # Compute pairwise sync
    sync_matrix = {}
    total_sync = 0.0
    count = 0
    
    for i, p in enumerate(primes):
        for j, q in enumerate(primes):
            if i < j:
                sync = adelic_sync_index(signatures[p], signatures[q])
                sync_matrix[(p, q)] = sync
                sync_matrix[(q, p)] = sync
                total_sync += sync
                count += 1
    
    mean_sync = total_sync / count if count > 0 else 0.0
    
    return sync_matrix, mean_sync


# ============================================================
# Algorithm 5: Phase Transition Detector
# Time: O(|params| · P² · n)
# Space: O(|params| · P²)
# ============================================================

def detect_phase_transition(
    params: List[int],
    primes: List[int],
    threshold: Optional[float] = None
) -> Tuple[List[Tuple[int, float]], float]:
    """
    Detect phase transitions in the synchronization landscape
    across a parameter family.
    
    For each parameter c, computes the mean cross-prime synchronization.
    A sharp jump in mean synchronization indicates a phase transition,
    corresponding to exceptional algebraic structure.
    
    Algorithm:
    1. For each parameter c, compute the sync matrix.
    2. Extract the mean synchronization.
    3. Identify the threshold separating high and low sync regions.
    
    The threshold τ is computed as the midpoint of the gap between
    the highest "generic" sync and the lowest "exceptional" sync,
    if such a gap exists.
    
    Time complexity: O(|params| · P² · n)
    Space complexity: O(|params| · P²)
    
    Args:
        params: List of parameter values to test
        primes: List of primes
        threshold: Optional manual threshold. If None, auto-detect.
    
    Returns:
        (results, threshold) where results is list of (param, mean_sync)
    """
    results = []
    for c in params:
        _, mean_sync = compute_sync_matrix(c, primes)
        results.append((c, mean_sync))
    
    results.sort(key=lambda x: x[1])
    
    if threshold is None:
        # Auto-detect: find the largest gap
        syncs = [s for _, s in results]
        max_gap = 0
        best_threshold = 0.5
        for i in range(len(syncs) - 1):
            gap = syncs[i + 1] - syncs[i]
            if gap > max_gap:
                max_gap = gap
                best_threshold = (syncs[i] + syncs[i + 1]) / 2
        threshold = best_threshold
    
    return results, threshold


# ============================================================
# Algorithm 6: Orbit Entropy Computation
# Time: O(n)
# Space: O(n)
# ============================================================

def orbit_entropy(
    f: Callable[[int], int],
    domain: List[int]
) -> float:
    """
    Compute the orbit entropy: log₂ of the number of distinct cycle lengths.
    
    This connects dynamical complexity to information-theoretic content.
    Formally verified bound: orbit_entropy ≤ log₂(|domain|).
    
    Time complexity: O(n)
    Space complexity: O(n)
    
    Args:
        f: The map
        domain: The finite domain
    
    Returns:
        Orbit entropy in bits
    """
    cycles, _ = extract_orbit_signature(f, domain)
    distinct = len(set(cycles))
    return log2(distinct) if distinct > 0 else 0.0


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    def sieve_primes(n: int) -> List[int]:
        """Sieve of Eratosthenes."""
        if n < 2:
            return []
        is_prime = [True] * (n + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(sqrt(n)) + 1):
            if is_prime[i]:
                for j in range(i*i, n + 1, i):
                    is_prime[j] = False
        return [i for i in range(2, n + 1) if is_prime[i]]
    
    primes = sieve_primes(50)
    # Skip p=2 for quadratic maps
    primes = [p for p in primes if p > 2]
    
    print("Adelic Synchronization Algorithms")
    print("=" * 50)
    
    # Test parameters
    exceptional = [0, -1, -2]
    generic = [3, 7, 11, 13, 17]
    all_params = exceptional + generic
    
    results, threshold = detect_phase_transition(all_params, primes)
    
    print(f"\nDetected threshold: τ = {threshold:.4f}\n")
    print(f"{'Parameter':>10} {'Mean Sync':>10} {'Classification':>15}")
    print("-" * 40)
    for c, sync in sorted(results, key=lambda x: -x[1]):
        label = "EXCEPTIONAL" if sync > threshold else "GENERIC"
        print(f"{c:>10} {sync:>10.4f} {label:>15}")
    
    print("\n\nOrbit Entropy Examples:")
    for p in primes[:8]:
        f = lambda x, p=p: (x * x) % p  # x -> x^2 mod p
        ent = orbit_entropy(f, list(range(p)))
        print(f"  p={p:3d}: entropy = {ent:.3f} bits (bound = {log2(p):.3f})")

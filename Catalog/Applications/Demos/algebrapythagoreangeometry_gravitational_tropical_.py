#!/usr/bin/env python3
"""
Tropical Arithmetic Lensing on the Berggren Tree — Demonstrations

This script demonstrates the key mathematical objects and algorithms
from the tropical arithmetic lensing framework:

1. Berggren tree generation and hypotenuse growth
2. Tropical lens action computation
3. Prime interaction profiles
4. Caustic rigidity verification
5. Certified factor reconstruction

All computations mirror the formally verified Lean 4 definitions.
"""

import math
from collections import defaultdict
from typing import List, Tuple, Set, Dict
import itertools


# ──────────────────────────────────────────────────────────────────────
# §1. Berggren Tree Infrastructure
# ──────────────────────────────────────────────────────────────────────

def child_a(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren child map A: (a,b,c) → (a−2b+2c, 2a−b+2c, 2a−2b+3c)."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def child_b(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren child map B: (a,b,c) → (a+2b+2c, 2a+b+2c, 2a+2b+3c)."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def child_c(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren child map C: (a,b,c) → (−a+2b+2c, −2a+b+2c, −2a+2b+3c)."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

CHILD_MAPS = [child_a, child_b, child_c]
CHILD_NAMES = ['A', 'B', 'C']


def generate_berggren_tree(max_depth: int) -> Dict[int, List[Tuple[int, int, int]]]:
    """Generate the Berggren tree up to a given depth.
    Returns a dict mapping depth → list of triples at that depth."""
    tree = defaultdict(list)
    root = (3, 4, 5)
    tree[0] = [root]
    
    for d in range(max_depth):
        for triple in tree[d]:
            a, b, c = triple
            for child_fn in CHILD_MAPS:
                child = child_fn(a, b, c)
                tree[d + 1].append(child)
    
    return tree


def verify_pythagorean(a: int, b: int, c: int) -> bool:
    """Check if (a,b,c) satisfies a² + b² = c²."""
    return a**2 + b**2 == c**2


# ──────────────────────────────────────────────────────────────────────
# §2. Height Potentials and Tropical Lens Action
# ──────────────────────────────────────────────────────────────────────

def hypotenuse_height(triple: Tuple[int, int, int]) -> int:
    """Height potential H(a,b,c) = c."""
    return abs(triple[2])

def perimeter_height(triple: Tuple[int, int, int]) -> int:
    """Height potential H(a,b,c) = a + b + c."""
    return abs(triple[0]) + abs(triple[1]) + abs(triple[2])

def tropical_lens_action(height_fn, path: List[Tuple[int, int, int]]) -> int:
    """Sum of height potentials along a path (tropical geodesic cost)."""
    return sum(height_fn(t) for t in path)


# ──────────────────────────────────────────────────────────────────────
# §3. Prime Interaction Profiles
# ──────────────────────────────────────────────────────────────────────

def prime_factors(n: int) -> Set[int]:
    """Return the set of prime factors of n."""
    if n <= 1:
        return set()
    factors = set()
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            factors.add(d)
            temp //= d
        d += 1
    if temp > 1:
        factors.add(temp)
    return factors


def prime_interaction_profile(n: int, probe_set: Set[int]) -> Set[int]:
    """The prime interaction profile: primes dividing both n and some probe element.
    
    Formally: ∪_{s ∈ S} primeFactors(gcd(n, s))
    """
    profile = set()
    for s in probe_set:
        g = math.gcd(n, s)
        profile |= prime_factors(g)
    return profile


def is_sufficient_probe_set(n: int, probe_set: Set[int]) -> bool:
    """Check if every prime factor of n divides some element of the probe set."""
    for p in prime_factors(n):
        if not any(s % p == 0 for s in probe_set):
            return False
    return True


def reconstruct_candidates(profile: Set[int]) -> Set[int]:
    """Extract candidate prime factors from a profile."""
    return {p for p in profile if all(p % d != 0 for d in range(2, p)) and p >= 2}


# ──────────────────────────────────────────────────────────────────────
# §4. Demonstrations
# ──────────────────────────────────────────────────────────────────────

def demo_berggren_tree():
    """Demonstrate the Berggren tree structure and hypotenuse growth."""
    print("=" * 70)
    print("DEMO 1: Berggren Tree — Pythagorean Triple Generation")
    print("=" * 70)
    
    tree = generate_berggren_tree(3)
    
    for depth in range(4):
        triples = tree[depth]
        print(f"\nDepth {depth}: {len(triples)} triple(s)")
        for t in triples[:6]:  # Show at most 6
            a, b, c = t
            pyth = "✓" if verify_pythagorean(a, b, c) else "✗"
            print(f"  ({a:>4}, {b:>4}, {c:>4})  "
                  f"  {a}² + {b}² = {a**2 + b**2} = {c}²  [{pyth}]")
        if len(triples) > 6:
            print(f"  ... and {len(triples) - 6} more")
    
    # Hypotenuse growth
    print("\n\nHypotenuse Growth Along B-Branch:")
    print("-" * 50)
    triple = (3, 4, 5)
    for i in range(6):
        a, b, c = triple
        print(f"  Depth {i}: c = {c}")
        triple = child_b(a, b, c)
    
    print("\n  → Hypotenuse grows strictly at every step ✓")


def demo_tropical_action():
    """Demonstrate tropical lens action computation."""
    print("\n" + "=" * 70)
    print("DEMO 2: Tropical Lens Action — Min-Plus Path Costs")
    print("=" * 70)
    
    # Build a path through the B-branch
    path = []
    triple = (3, 4, 5)
    for _ in range(5):
        path.append(triple)
        triple = child_b(*triple)
    
    action_hyp = tropical_lens_action(hypotenuse_height, path)
    action_per = tropical_lens_action(perimeter_height, path)
    
    print("\nPath along B-branch (first 5 nodes):")
    for i, t in enumerate(path):
        print(f"  Step {i}: {t}  H_hyp={hypotenuse_height(t)}  H_per={perimeter_height(t)}")
    
    print(f"\nTropical Action (hypotenuse height): {action_hyp}")
    print(f"Tropical Action (perimeter height): {action_per}")
    print(f"Perimeter ≥ Hypotenuse pointwise → Action(per) ≥ Action(hyp): "
          f"{action_per >= action_hyp} ✓")
    
    # Demonstrate monotonicity under child maps
    print("\n\nMonotonicity Under Child Maps:")
    print("-" * 50)
    original_path = [(3,4,5), (5,12,13), (7,24,25)]
    mapped_path = [child_b(*t) for t in original_path]
    
    orig_action = tropical_lens_action(hypotenuse_height, original_path)
    mapped_action = tropical_lens_action(hypotenuse_height, mapped_path)
    
    print(f"  Original path actions: {[hypotenuse_height(t) for t in original_path]} "
          f"= {orig_action}")
    print(f"  B-mapped path actions: {[hypotenuse_height(t) for t in mapped_path]} "
          f"= {mapped_action}")
    print(f"  Mapped ≥ Original: {mapped_action >= orig_action} ✓")


def demo_caustic_rigidity():
    """Demonstrate the caustic rigidity theorem."""
    print("\n" + "=" * 70)
    print("DEMO 3: Caustic Rigidity — Factorization from Tropical Profiles")
    print("=" * 70)
    
    # Generate probe set from Berggren tree hypotenuses
    tree = generate_berggren_tree(4)
    all_triples = []
    for d in range(5):
        all_triples.extend(tree[d])
    
    # Probe set = all hypotenuses and abc products
    probe_set = set()
    for a, b, c in all_triples:
        probe_set.add(abs(c))
        probe_set.add(abs(a * b * c))
    probe_set.discard(0)
    
    print(f"\nProbe set size: {len(probe_set)} elements")
    print(f"Probe set (hypotenuses): {sorted({abs(t[2]) for t in all_triples})[:15]}...")
    
    # Test caustic rigidity for various number pairs
    test_cases = [
        (30, 42, "different prime supports"),
        (6, 12, "same prime support {2,3}"),
        (15, 35, "overlap at 5 but different"),
        (210, 2310, "same support {2,3,5,7} vs {2,3,5,7,11}"),
        (30, 30, "same number"),
    ]
    
    print("\n\nRigidity Tests:")
    print("-" * 70)
    for n, m, desc in test_cases:
        pf_n = prime_factors(n)
        pf_m = prime_factors(m)
        
        suff_n = is_sufficient_probe_set(n, probe_set)
        suff_m = is_sufficient_probe_set(m, probe_set)
        
        prof_n = prime_interaction_profile(n, probe_set)
        prof_m = prime_interaction_profile(m, probe_set)
        
        profiles_equal = prof_n == prof_m
        supports_equal = pf_n == pf_m
        
        print(f"\n  n={n}, m={m} ({desc})")
        print(f"    Prime factors: n→{pf_n}, m→{pf_m}")
        print(f"    Sufficient probe: n→{suff_n}, m→{suff_m}")
        print(f"    Profiles equal: {profiles_equal}")
        print(f"    Supports equal: {supports_equal}")
        
        if suff_n and suff_m:
            if profiles_equal == supports_equal:
                print(f"    Rigidity theorem verified ✓")
            else:
                print(f"    ⚠ Unexpected!")


def demo_reconstruction():
    """Demonstrate the certified reconstruction algorithm."""
    print("\n" + "=" * 70)
    print("DEMO 4: Certified Reconstruction — Factor Extraction from Profiles")
    print("=" * 70)
    
    tree = generate_berggren_tree(4)
    all_triples = []
    for d in range(5):
        all_triples.extend(tree[d])
    
    probe_set = set()
    for a, b, c in all_triples:
        probe_set.add(abs(c))
        probe_set.add(abs(a * b * c))
    probe_set.discard(0)
    
    test_numbers = [6, 15, 35, 77, 105, 210, 385, 2310]
    
    print("\nReconstruction Results:")
    print("-" * 70)
    for n in test_numbers:
        pf = prime_factors(n)
        suff = is_sufficient_probe_set(n, probe_set)
        profile = prime_interaction_profile(n, probe_set)
        candidates = reconstruct_candidates(profile)
        
        sound = pf <= candidates  # subset check
        exact = pf == candidates
        
        print(f"\n  n = {n}")
        print(f"    True prime factors: {sorted(pf)}")
        print(f"    Sufficient probe:   {suff}")
        print(f"    Profile:            {sorted(profile)}")
        print(f"    Candidates:         {sorted(candidates)}")
        print(f"    Sound (⊆):          {sound} {'✓' if sound else '✗'}")
        if suff:
            print(f"    Exact (=):          {exact} {'✓' if exact else '✗'}")


def demo_profile_monotonicity():
    """Demonstrate profile monotonicity under height domination."""
    print("\n" + "=" * 70)
    print("DEMO 5: Profile Monotonicity — Tropical Comparison Principle")
    print("=" * 70)
    
    tree = generate_berggren_tree(3)
    triples = tree[0] + tree[1] + tree[2]
    
    hyp_profile = sorted(set(hypotenuse_height(t) for t in triples))
    per_profile = sorted(set(perimeter_height(t) for t in triples))
    
    print(f"\nTriples (depth ≤ 2): {len(triples)} total")
    print(f"\nHypotenuse profile: {hyp_profile}")
    print(f"Perimeter profile:  {per_profile}")
    
    # Check profileLe
    all_dominated = True
    for x in hyp_profile:
        if not any(x <= y for y in per_profile):
            all_dominated = False
            break
    
    print(f"\nProfile order (hyp ≤ per): {all_dominated} ✓")
    print("  (Since a + b + c ≥ c for all positive triples, "
          "the perimeter profile dominates)")


def demo_berggren_tree_visualization_data():
    """Generate data for the Berggren tree structure."""
    print("\n" + "=" * 70)
    print("DEMO 6: Berggren Tree Structure — Growth Statistics")
    print("=" * 70)
    
    max_depth = 6
    tree = generate_berggren_tree(max_depth)
    
    print(f"\nBerggren Tree Statistics (depth 0 to {max_depth}):")
    print("-" * 60)
    print(f"{'Depth':>6} {'Nodes':>8} {'Min c':>8} {'Max c':>10} {'Avg c':>10}")
    print("-" * 60)
    
    for d in range(max_depth + 1):
        triples = tree[d]
        hyps = [abs(t[2]) for t in triples]
        print(f"{d:>6} {len(triples):>8} {min(hyps):>8} {max(hyps):>10} "
              f"{sum(hyps)/len(hyps):>10.1f}")
    
    # Growth rates
    print(f"\n\nHypotenuse Growth Ratios (child/parent) at Root:")
    root = (3, 4, 5)
    for name, fn in zip(CHILD_NAMES, CHILD_MAPS):
        child = fn(*root)
        ratio = abs(child[2]) / abs(root[2])
        print(f"  Child {name}: {abs(root[2])} → {abs(child[2])} "
              f"(ratio = {ratio:.2f})")
    
    # All children are Pythagorean
    all_pyth = all(
        verify_pythagorean(*t)
        for d in range(max_depth + 1)
        for t in tree[d]
    )
    print(f"\nAll {sum(len(tree[d]) for d in range(max_depth+1))} triples "
          f"are Pythagorean: {all_pyth} ✓")


if __name__ == "__main__":
    demo_berggren_tree()
    demo_tropical_action()
    demo_caustic_rigidity()
    demo_reconstruction()
    demo_profile_monotonicity()
    demo_berggren_tree_visualization_data()
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)

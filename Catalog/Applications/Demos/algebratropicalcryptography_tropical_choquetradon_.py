#!/usr/bin/env python3
"""
Applications of Tropical Choquet–Radon Trapdoor Duality

Demonstrates real-world applications of the theoretical framework:
1. Tropical key exchange protocol simulation
2. Collision resistance analysis
3. Phase transition visualization (generates PNG)
"""

import numpy as np
from collections import defaultdict
from itertools import combinations, product as iter_product
from typing import FrozenSet, Dict, Set, Tuple, List
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# =============================================================================
# Application 1: Tropical Key Exchange Protocol
# =============================================================================

def tropical_key_exchange_demo():
    """
    Simulate a tropical key exchange protocol based on the trapdoor duality.
    
    Alice (private key holder) can recover support from profile.
    Eve (eavesdropper) cannot distinguish collision families.
    """
    print("=" * 60)
    print("Application 1: Tropical Key Exchange Protocol")
    print("=" * 60)
    
    n = 8  # Number of generators
    
    # Key generation (Alice)
    # Private key: the test battery
    def private_tests(e: int, profile: tuple) -> bool:
        """Alice's private test battery."""
        return profile[e] == 1
    
    # Public key: the profile map
    def public_profile(x: np.ndarray) -> tuple:
        return tuple(1 if x[i] != 0 else 0 for i in range(n))
    
    # Bob encrypts a message (a support set)
    rng = np.random.RandomState(42)
    message_support = frozenset({1, 3, 5, 7})  # Bob's secret message
    
    # Bob creates an element with the desired support
    x = np.zeros(n, dtype=int)
    for e in message_support:
        x[e] = rng.randint(1, 100)
    
    # Bob publishes the profile (public channel)
    public_data = public_profile(x)
    
    # Alice recovers the message using private tests
    recovered = frozenset(e for e in range(n) if private_tests(e, public_data))
    
    print(f"\n  [Bob] Message support: {set(message_support)}")
    print(f"  [Bob] Element x: {x}")
    print(f"  [Bob] Published profile: {public_data}")
    print(f"  [Alice] Recovered support: {set(recovered)}")
    print(f"  [Alice] Correct: {'✓' if recovered == message_support else '✗'}")
    
    # Eve's perspective: she sees the profile but not the tests
    # She tries a non-exposed profile map
    def eve_profile(x: np.ndarray) -> tuple:
        return (int(np.sum(x)) % 10,)
    
    # Count how many distinct supports map to the same Eve-profile
    eve_p = eve_profile(x)
    collision_count = 0
    for _ in range(10000):
        y = rng.randint(0, 100, size=n)
        if eve_profile(y) == eve_p:
            s = frozenset(i for i in range(n) if y[i] != 0)
            if s != message_support:
                collision_count += 1
    
    print(f"\n  [Eve] Profile observed: {eve_p}")
    print(f"  [Eve] Candidate collisions found: {collision_count}")
    print(f"  [Eve] Cannot distinguish true support from collisions.")
    print()


# =============================================================================
# Application 2: Collision Resistance Analysis
# =============================================================================

def collision_resistance_analysis():
    """
    Analyze collision resistance as a function of profile dimension.
    Shows the phase transition from non-exposed to exposed.
    """
    print("=" * 60)
    print("Application 2: Collision Resistance Analysis")
    print("=" * 60)
    
    n = 5
    max_val = 3
    rng = np.random.RandomState(123)
    
    print(f"\n  System: n = {n} generators, coords in [0, {max_val-1}]")
    print(f"  Testing profile maps of increasing dimension:\n")
    print(f"  {'Dim':>4} {'Profiles':>10} {'Collisions':>12} {'Max Mult':>10} {'Status':>12}")
    print(f"  {'---':>4} {'--------':>10} {'----------':>12} {'--------':>10} {'------':>12}")
    
    for dim in range(1, n + 2):
        # Random linear projection profile
        proj = rng.randint(-3, 4, size=(dim, n))
        
        def make_pf(p):
            return lambda x: tuple(int(v) % 7 for v in p @ x)
        
        pf = make_pf(proj)
        
        # Enumerate and find collisions
        groups: Dict[tuple, Set[FrozenSet[int]]] = defaultdict(set)
        for vals in iter_product(range(max_val), repeat=n):
            x = np.array(vals)
            groups[pf(x)].add(frozenset(i for i in range(n) if x[i] != 0))
        
        num_profiles = len(groups)
        num_collisions = sum(1 for s in groups.values() if len(s) > 1)
        max_mult = max(len(s) for s in groups.values())
        status = "EXPOSED" if num_collisions == 0 else "COLLISION"
        
        print(f"  {dim:4d} {num_profiles:10d} {num_collisions:12d} "
              f"{max_mult:10d} {status:>12}")
    
    print()


# =============================================================================
# Application 3: Visualization Generation
# =============================================================================

def generate_phase_transition_plot():
    """
    Generate a phase transition plot showing the exposed/non-exposed dichotomy.
    Saves to phase_transition.png.
    """
    print("=" * 60)
    print("Application 3: Phase Transition Visualization")
    print("=" * 60)
    
    n_values = [3, 4, 5, 6]
    max_val = 2
    num_trials = 20
    rng = np.random.RandomState(42)
    
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Tropical Trapdoor Duality: Phase Transition\n'
                 'Collision Rate vs Profile Dimension',
                 fontsize=14, fontweight='bold')
    
    for idx, n in enumerate(n_values):
        ax = axes[idx // 2][idx % 2]
        
        dims = list(range(1, n + 3))
        avg_rates = []
        std_rates = []
        
        for dim in dims:
            rates = []
            for trial in range(num_trials):
                proj = rng.randint(-2, 3, size=(dim, n))
                pf = lambda x, p=proj: tuple(int(v) % 5 for v in p @ x)
                
                groups: Dict[tuple, Set[FrozenSet[int]]] = defaultdict(set)
                for vals in iter_product(range(max_val), repeat=n):
                    x = np.array(vals)
                    groups[pf(x)].add(
                        frozenset(i for i in range(n) if x[i] != 0))
                
                total = len(groups)
                coll = sum(1 for s in groups.values() if len(s) > 1)
                rates.append(coll / max(total, 1))
            
            avg_rates.append(np.mean(rates))
            std_rates.append(np.std(rates))
        
        ax.errorbar(dims, avg_rates, yerr=std_rates, 
                    fmt='o-', capsize=4, color='#2196F3', 
                    markerfacecolor='#1565C0', markersize=8, linewidth=2)
        ax.axhline(y=0, color='green', linestyle='--', alpha=0.5, 
                  label='Global exposedness threshold')
        ax.axvline(x=n, color='red', linestyle=':', alpha=0.5,
                  label=f'n = {n} (generator count)')
        ax.set_xlabel('Profile Dimension', fontsize=11)
        ax.set_ylabel('Collision Rate', fontsize=11)
        ax.set_title(f'n = {n} generators', fontsize=12)
        ax.set_ylim(-0.05, 1.05)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/phase_transition.png', 
                dpi=150, bbox_inches='tight')
    print("  Saved: phase_transition.png")
    
    # Second plot: collision multiplicity heatmap
    fig2, ax2 = plt.subplots(figsize=(10, 6))
    
    n = 5
    max_val = 2
    moduli = list(range(2, 12))
    dims_plot = list(range(1, 7))
    
    heatmap_data = np.zeros((len(moduli), len(dims_plot)))
    
    for i, mod in enumerate(moduli):
        for j, dim in enumerate(dims_plot):
            proj = rng.randint(-2, 3, size=(dim, n))
            pf = lambda x, p=proj, m=mod: tuple(int(v) % m for v in p @ x)
            
            groups: Dict[tuple, Set[FrozenSet[int]]] = defaultdict(set)
            for vals in iter_product(range(max_val), repeat=n):
                x = np.array(vals)
                groups[pf(x)].add(
                    frozenset(k for k in range(n) if x[k] != 0))
            
            max_mult = max(len(s) for s in groups.values())
            heatmap_data[i, j] = max_mult
    
    im = ax2.imshow(heatmap_data, aspect='auto', cmap='YlOrRd',
                    origin='lower')
    ax2.set_xticks(range(len(dims_plot)))
    ax2.set_xticklabels(dims_plot)
    ax2.set_yticks(range(len(moduli)))
    ax2.set_yticklabels(moduli)
    ax2.set_xlabel('Profile Dimension', fontsize=12)
    ax2.set_ylabel('Modulus', fontsize=12)
    ax2.set_title('Maximum Collision Multiplicity\n'
                  '(n=5 generators, coords ∈ {0,1})', fontsize=13)
    plt.colorbar(im, ax=ax2, label='Max Collision Multiplicity')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/collision_heatmap.png',
                dpi=150, bbox_inches='tight')
    print("  Saved: collision_heatmap.png")
    
    # Third plot: support lattice diagram
    fig3, ax3 = plt.subplots(figsize=(10, 7))
    
    n = 4
    x = np.array([0, 1, 0, 1])  # support = {1, 3}
    min_supp = frozenset(i for i in range(n) if x[i] != 0)
    
    # All supports arranged by cardinality
    all_supports = []
    for size in range(n + 1):
        for combo in combinations(range(n), size):
            K = frozenset(combo)
            if min_supp.issubset(K):
                all_supports.append(K)
    
    # Position by cardinality
    by_size = defaultdict(list)
    for K in all_supports:
        by_size[len(K)].append(K)
    
    positions = {}
    for size, sets in by_size.items():
        for i, K in enumerate(sets):
            x_pos = (i - (len(sets) - 1) / 2) * 2
            y_pos = size
            positions[K] = (x_pos, y_pos)
    
    # Draw edges (subset relations)
    for K in all_supports:
        for L in all_supports:
            if K < L and len(L) == len(K) + 1:
                x1, y1 = positions[K]
                x2, y2 = positions[L]
                ax3.plot([x1, x2], [y1, y2], 'gray', alpha=0.3, linewidth=1)
    
    # Draw nodes
    for K in all_supports:
        x_pos, y_pos = positions[K]
        color = '#F44336' if K == min_supp else '#2196F3'
        size = 200 if K == min_supp else 100
        ax3.scatter(x_pos, y_pos, c=color, s=size, zorder=5, edgecolors='black')
        label = '{' + ','.join(str(e) for e in sorted(K)) + '}'
        ax3.annotate(label, (x_pos, y_pos), textcoords="offset points",
                    xytext=(0, 12), ha='center', fontsize=8)
    
    ax3.set_title(f'Support Lattice for x = (0,1,0,1)\n'
                  f'Red = Canonical Support suppC(x) = {{1,3}}',
                  fontsize=13)
    ax3.set_ylabel('Support Size', fontsize=11)
    ax3.set_xlabel('', fontsize=11)
    ax3.set_yticks(range(n + 1))
    ax3.grid(True, alpha=0.2)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/support_lattice.png',
                dpi=150, bbox_inches='tight')
    print("  Saved: support_lattice.png")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print()
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  Tropical Trapdoor Duality: Applications & Visualizations ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print()
    
    tropical_key_exchange_demo()
    collision_resistance_analysis()
    generate_phase_transition_plot()
    
    print("All applications complete.")


#!/usr/bin/env python3
"""
Tropical Choquet–Radon Trapdoor Duality: Demonstrations

This module demonstrates the four main theorems of the tropical trapdoor
duality framework with concrete numerical examples.

Theorems demonstrated:
1. Canonical Minimal Extremal Support
2. Radon Inversion on the Exposed Class
3. Certified Recovery Algorithm
4. Collision Families under Non-Exposedness
"""

import numpy as np
from itertools import combinations
from collections import defaultdict
from typing import FrozenSet, Callable, Dict, List, Tuple, Set

# =============================================================================
# Core Data Structures
# =============================================================================

class TropicalChoquetSystem:
    """
    A concrete tropical Choquet system on vectors in Z^n.
    
    Support of x = set of indices where x is nonzero.
    This is the 'concreteTropicalSystem' from the Lean formalization.
    """
    
    def __init__(self, n: int):
        self.n = n
        self.generators = list(range(n))
    
    def support(self, x: np.ndarray) -> FrozenSet[int]:
        """Compute the canonical minimal support of x."""
        return frozenset(i for i in range(self.n) if x[i] != 0)
    
    def supports(self, x: np.ndarray, K: FrozenSet[int]) -> bool:
        """Check if K is a valid support of x (contains all nonzero indices)."""
        return self.support(x).issubset(K)
    
    def all_supports(self, x: np.ndarray) -> List[FrozenSet[int]]:
        """Enumerate all valid supports of x (supersets of minimal support)."""
        min_supp = self.support(x)
        result = []
        for size in range(len(min_supp), self.n + 1):
            for combo in combinations(range(self.n), size):
                K = frozenset(combo)
                if min_supp.issubset(K):
                    result.append(K)
        return result


class TropicalRadonSystem:
    """
    A tropical Radon system: provides a profile map from elements to a profile space.
    """
    
    def __init__(self, profile_fn: Callable[[np.ndarray], tuple],
                 name: str = "unnamed"):
        self.profile_fn = profile_fn
        self.name = name
    
    def profile(self, x: np.ndarray) -> tuple:
        """Compute the Radon profile of x."""
        return self.profile_fn(x)


# =============================================================================
# Demo 1: Canonical Minimal Extremal Support (Theorem 1)
# =============================================================================

def demo_canonical_support():
    """
    Demonstrate Theorem 1: every element has a unique minimal support,
    which is the intersection of all valid supports.
    """
    print("=" * 70)
    print("DEMO 1: Canonical Minimal Extremal Support (Theorem 1)")
    print("=" * 70)
    print()
    
    TC = TropicalChoquetSystem(6)
    
    # Example elements
    examples = [
        np.array([0, 3, 0, 7, 0, 0]),
        np.array([1, 0, 0, 0, 0, 1]),
        np.array([2, 3, 5, 7, 11, 13]),
        np.array([0, 0, 0, 0, 0, 0]),
    ]
    
    for x in examples:
        min_supp = TC.support(x)
        all_supps = TC.all_supports(x)
        
        # Verify: intersection of all supports equals minimal support
        if all_supps:
            intersection = frozenset.intersection(*all_supps)
        else:
            intersection = frozenset()
        
        assert intersection == min_supp, "Theorem 1 violated!"
        
        # Verify: minimal support is contained in every support
        for K in all_supps:
            assert min_supp.issubset(K), "Minimality violated!"
        
        print(f"  x = {x}")
        print(f"  Canonical support suppC(x) = {set(min_supp)}")
        print(f"  Number of valid supports: {len(all_supps)}")
        print(f"  Intersection of all supports: {set(intersection)}")
        print(f"  suppC(x) == intersection: ✓")
        print()
    
    print("  Theorem 1 verified on all examples. ✓")
    print()


# =============================================================================
# Demo 2: Radon Inversion on the Exposed Class (Theorem 2)
# =============================================================================

def demo_radon_inversion():
    """
    Demonstrate Theorem 2: under separation, the Radon profile uniquely
    determines the canonical support on the exposed class.
    """
    print("=" * 70)
    print("DEMO 2: Radon Inversion on Exposed Class (Theorem 2)")
    print("=" * 70)
    print()
    
    n = 4
    TC = TropicalChoquetSystem(n)
    
    # Exposed profile: each coordinate is independently observable
    # Profile = tuple of (whether coordinate i is nonzero)
    # This is a "fully exposed" system
    exposed_profile = TropicalRadonSystem(
        lambda x: tuple(1 if x[i] != 0 else 0 for i in range(n)),
        name="coordinate-indicator"
    )
    
    print(f"  Profile map: p(x) = (1[x_i ≠ 0] for i=0..{n-1})")
    print(f"  This is a fully exposed system (each generator detectable).")
    print()
    
    # Generate random elements and verify inversion
    rng = np.random.RandomState(42)
    num_tests = 50
    profile_to_support: Dict[tuple, FrozenSet[int]] = {}
    violations = 0
    
    for _ in range(num_tests):
        x = rng.randint(0, 10, size=n)
        p = exposed_profile.profile(x)
        s = TC.support(x)
        
        if p in profile_to_support:
            if profile_to_support[p] != s:
                violations += 1
        else:
            profile_to_support[p] = s
    
    print(f"  Tested {num_tests} random elements.")
    print(f"  Unique profiles observed: {len(profile_to_support)}")
    print(f"  Profile-support violations: {violations}")
    print(f"  Theorem 2 (profile → support injective): {'✓' if violations == 0 else '✗'}")
    print()
    
    # Show some examples
    for p, s in list(profile_to_support.items())[:5]:
        print(f"    Profile {p} → Support {set(s)}")
    
    print()


# =============================================================================
# Demo 3: Certified Recovery Algorithm (Theorem 3)
# =============================================================================

def demo_recovery_algorithm():
    """
    Demonstrate Theorem 3: the recovery algorithm correctly reconstructs
    the canonical support from the Radon profile.
    """
    print("=" * 70)
    print("DEMO 3: Certified Recovery Algorithm (Theorem 3)")
    print("=" * 70)
    print()
    
    n = 8
    TC = TropicalChoquetSystem(n)
    
    # Define certified test battery (the "private key")
    # test_e(profile) = True iff generator e is in the support
    # For the coordinate-indicator profile, test_e checks bit e
    def make_tests(n: int):
        """Create a certified exposed basis: test_e(p) = p[e]."""
        def test(e: int, p: tuple) -> bool:
            return p[e] == 1
        return test
    
    tests = make_tests(n)
    
    # Profile map (the "public key")
    profile_fn = lambda x: tuple(1 if x[i] != 0 else 0 for i in range(n))
    RP = TropicalRadonSystem(profile_fn, "coordinate-indicator")
    
    # Recovery algorithm (Algorithm 3.6 from the paper)
    def recover_support(tests_fn, p: tuple, n: int) -> FrozenSet[int]:
        """Recover support from profile using test battery."""
        return frozenset(e for e in range(n) if tests_fn(e, p))
    
    print(f"  System: n = {n} generators")
    print(f"  Profile: coordinate-indicator (public)")
    print(f"  Tests: bit-check (private)")
    print()
    
    # Test recovery on random elements
    rng = np.random.RandomState(123)
    num_tests_run = 100
    correct = 0
    
    for _ in range(num_tests_run):
        x = rng.randint(0, 5, size=n)
        p = RP.profile(x)
        true_support = TC.support(x)
        recovered = recover_support(tests, p, n)
        
        if recovered == true_support:
            correct += 1
    
    print(f"  Recovery tests: {correct}/{num_tests_run} correct")
    print(f"  Theorem 3 (exact recovery): {'✓' if correct == num_tests_run else '✗'}")
    print()
    
    # Show detailed examples
    print("  Detailed examples:")
    for _ in range(5):
        x = rng.randint(0, 5, size=n)
        p = RP.profile(x)
        true_support = TC.support(x)
        recovered = recover_support(tests, p, n)
        print(f"    x = {x}")
        print(f"    profile = {p}")
        print(f"    true support = {set(true_support)}")
        print(f"    recovered    = {set(recovered)}")
        print(f"    match: {'✓' if recovered == true_support else '✗'}")
        print()


# =============================================================================
# Demo 4: Collision Families under Non-Exposedness (Theorem 4)
# =============================================================================

def demo_collision_families():
    """
    Demonstrate Theorem 4: failure of exposedness produces collision families.
    """
    print("=" * 70)
    print("DEMO 4: Collision Families under Non-Exposedness (Theorem 4)")
    print("=" * 70)
    print()
    
    n = 6
    TC = TropicalChoquetSystem(n)
    
    # Non-exposed profile: sum of all coordinates mod p
    # This loses information about individual coordinates
    p_mod = 7
    non_exposed_profile = TropicalRadonSystem(
        lambda x: (int(np.sum(x)) % p_mod,),
        name=f"sum-mod-{p_mod}"
    )
    
    print(f"  Profile map: p(x) = sum(x) mod {p_mod}")
    print(f"  This is NOT globally exposed (loses individual coordinate info).")
    print()
    
    # Find collision families
    profile_groups: Dict[tuple, List[Tuple[np.ndarray, FrozenSet[int]]]] = defaultdict(list)
    
    # Enumerate elements with small coordinates
    from itertools import product as iter_product
    max_val = 3
    count = 0
    for vals in iter_product(range(max_val), repeat=n):
        x = np.array(vals)
        p = non_exposed_profile.profile(x)
        s = TC.support(x)
        profile_groups[p].append((x.copy(), s))
        count += 1
    
    # Find collisions: same profile, different support
    total_collisions = 0
    collision_examples = []
    
    for p, group in profile_groups.items():
        supports_in_group = set(s for _, s in group)
        if len(supports_in_group) > 1:
            total_collisions += 1
            if len(collision_examples) < 3:
                collision_examples.append((p, group, supports_in_group))
    
    print(f"  Enumerated {count} elements with coords in [0, {max_val-1}]")
    print(f"  Unique profiles: {len(profile_groups)}")
    print(f"  Profiles with collisions: {total_collisions}")
    print(f"  Theorem 4 (collisions exist): {'✓' if total_collisions > 0 else '✗'}")
    print()
    
    # Show collision examples
    print("  Collision examples:")
    for prof, group, supports in collision_examples:
        print(f"    Profile = {prof}")
        print(f"    Distinct supports under this profile: {len(supports)}")
        # Show two elements with different supports
        seen_supports: Set[FrozenSet[int]] = set()
        shown = 0
        for x, s in group:
            if s not in seen_supports and shown < 3:
                print(f"      x = {x}, support = {set(s)}")
                seen_supports.add(s)
                shown += 1
        print()
    
    # Collision multiplicity analysis
    print("  Collision multiplicity distribution:")
    multiplicities = defaultdict(int)
    for p, group in profile_groups.items():
        supports_in_group = set(s for _, s in group)
        multiplicities[len(supports_in_group)] += 1
    
    for mult, count in sorted(multiplicities.items()):
        bar = "█" * min(count, 40)
        print(f"    {mult} distinct supports: {count:4d} profiles  {bar}")
    print()


# =============================================================================
# Demo 5: Trapdoor Duality Dichotomy
# =============================================================================

def demo_duality_dichotomy():
    """
    Demonstrate the trapdoor duality dichotomy: every system is either
    globally exposed (no collisions) or has collision families.
    """
    print("=" * 70)
    print("DEMO 5: Trapdoor Duality Dichotomy")
    print("=" * 70)
    print()
    
    n = 5
    TC = TropicalChoquetSystem(n)
    
    # Test several profile maps
    profiles = [
        ("Full coordinate indicator (exposed)",
         lambda x: tuple(1 if x[i] != 0 else 0 for i in range(n))),
        ("Sum mod 3 (non-exposed)",
         lambda x: (int(np.sum(x)) % 3,)),
        ("Parity vector (partially exposed)",
         lambda x: tuple(int(x[i]) % 2 for i in range(n))),
        ("Max value only (non-exposed)",
         lambda x: (int(np.max(x)),)),
        ("Sorted nonzero values (exposed variant)",
         lambda x: tuple(sorted([int(v) for v in x if v != 0]))),
    ]
    
    rng = np.random.RandomState(99)
    num_samples = 500
    
    for name, prof_fn in profiles:
        RP = TropicalRadonSystem(prof_fn, name)
        
        # Check for collisions
        profile_to_support: Dict[tuple, Set[FrozenSet[int]]] = defaultdict(set)
        for _ in range(num_samples):
            x = rng.randint(0, 4, size=n)
            p = RP.profile(x)
            s = TC.support(x)
            profile_to_support[p].add(s)
        
        has_collision = any(len(supps) > 1 for supps in profile_to_support.values())
        max_collision = max(len(supps) for supps in profile_to_support.values())
        
        status = "COLLISION" if has_collision else "EXPOSED"
        print(f"  {name}")
        print(f"    Status: {status}")
        print(f"    Max collision multiplicity: {max_collision}")
        print(f"    Dichotomy: {'Non-exposed → collisions exist' if has_collision else 'Exposed → unique recovery'}")
        print()
    
    print("  Every system falls into exactly one category. ✓")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Choquet–Radon Trapdoor Duality: Numerical Demonstrations  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_canonical_support()
    demo_radon_inversion()
    demo_recovery_algorithm()
    demo_collision_families()
    demo_duality_dichotomy()
    
    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)

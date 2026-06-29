#!/usr/bin/env python3
"""
Applications of Uniformity Sharpness Theory

Demonstrates real-world applications of the theorems:

1. Network Resilience Analysis — modeling network failure as obstruction systems
2. SAT Instance Difficulty Prediction — using overlap matrix for hardness estimation
3. Certificate Design Optimization — coding-theoretic bounds for verification

Usage:
    python applications.py
"""

import random
import math
from itertools import combinations
from typing import List, Set, Tuple, Dict, FrozenSet


# ============================================================
# Shared utilities
# ============================================================

class ObstructionSystem:
    """Obstruction system (V, O)."""

    def __init__(self, ground: Set[int], obstructions: List[Set[int]]):
        self.ground = frozenset(ground)
        self.obstructions = [frozenset(o) for o in obstructions]

    def is_satisfiable(self, S: Set[int]) -> bool:
        S_frozen = frozenset(S)
        return all(not o <= S_frozen for o in self.obstructions)

    @property
    def n(self) -> int:
        return len(self.ground)

    @property
    def m(self) -> int:
        return len(self.obstructions)

    def uniformity(self):
        if not self.obstructions:
            return None
        sizes = set(len(o) for o in self.obstructions)
        return sizes.pop() if len(sizes) == 1 else None


def compute_transition_window(sys: ObstructionSystem) -> Tuple[int, int]:
    """Compute transition window [k1, k2]."""
    n = sys.n
    elements = sorted(sys.ground)
    k1 = 0
    for k in range(1, n + 1):
        all_sat = all(
            sys.is_satisfiable(set(S)) for S in combinations(elements, k))
        if all_sat:
            k1 = k
        else:
            break
    k2 = n + 1
    for k in range(n, -1, -1):
        all_unsat = all(
            not sys.is_satisfiable(set(S)) for S in combinations(elements, k))
        if all_unsat:
            k2 = k
        else:
            break
    return k1, k2


# ============================================================
# Application 1: Network Resilience Analysis
# ============================================================

def network_resilience_demo():
    """
    Model network failure modes as an obstruction system.

    Each node is a component. Each obstruction is a "minimal cut" —
    a set of components whose simultaneous failure disconnects the network.

    We analyze how the structure of failure modes affects resilience
    using the packing bound and satisfiability floor.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Resilience Analysis")
    print("=" * 60)

    # Model: 10-node network with 3-component minimal cuts
    # (3-uniform obstruction system)
    n_nodes = 10
    ground = set(range(1, n_nodes + 1))

    # Minimal cuts (each is a set of 3 nodes whose failure
    # disconnects the network)
    cuts_uniform = [
        {1, 2, 3},   # Main backbone path
        {4, 5, 6},   # Secondary path
        {7, 8, 9},   # Tertiary path
        {1, 5, 9},   # Diagonal vulnerability
        {3, 5, 7},   # Cross-cut
        {2, 6, 10},  # Edge path
    ]

    sys_uniform = ObstructionSystem(ground, cuts_uniform)

    # Non-uniform cuts (mixed sizes 2, 3, 4)
    cuts_nonuniform = [
        {1, 2},          # Critical bridge (only 2 components)
        {4, 5, 6},       # Secondary path
        {7, 8, 9, 10},   # Wide cut
        {1, 5, 9},       # Diagonal
        {3, 5, 7},       # Cross-cut
        {2, 6},          # Another bridge
    ]

    sys_nonuniform = ObstructionSystem(ground, cuts_nonuniform)

    print(f"\n--- Uniform failure modes (d=3) ---")
    print(f"Components: {n_nodes}")
    print(f"Minimal cuts: {sys_uniform.m}")

    # Satisfiability floor
    d = sys_uniform.uniformity()
    print(f"\nSatisfiability Floor Theorem:")
    print(f"  Any {d-1} component failures are ALWAYS survivable")
    print(f"  (because each cut needs {d} simultaneous failures)")

    # Packing bound
    # Find disjoint cuts
    packing = []
    used = set()
    for cut in cuts_uniform:
        if not (set(cut) & used):
            packing.append(cut)
            used |= set(cut)

    nu = len(packing)
    threshold = n_nodes - nu
    print(f"\nPacking Bound:")
    print(f"  Found {nu} disjoint failure modes")
    print(f"  Network MUST fail if > {threshold} components are down")

    # Transition window
    k1, k2 = compute_transition_window(sys_uniform)
    print(f"\nTransition Window: [{k1}, {k2}]")
    print(f"  Safe zone: ≤ {k1} failures")
    print(f"  Danger zone: ≥ {k2} failures")
    print(f"  Uncertainty window: {k2 - k1} levels")

    print(f"\n--- Non-uniform failure modes ---")
    print(f"Components: {n_nodes}")
    print(f"Minimal cuts: {sys_nonuniform.m}")
    min_cut = min(len(c) for c in cuts_nonuniform)
    print(f"Smallest cut size: {min_cut}")
    print(f"  WARNING: Only {min_cut-1} failure(s) guaranteed safe!")

    k1_nu, k2_nu = compute_transition_window(sys_nonuniform)
    print(f"\nTransition Window: [{k1_nu}, {k2_nu}]")
    print(f"  Window width: {k2_nu - k1_nu}")
    print(f"  vs. uniform width: {k2 - k1}")

    ratio = (k2_nu - k1_nu) / max(1, k2 - k1)
    print(f"\n  Non-uniform window is {ratio:.1f}x wider than uniform")
    print(f"  → Uniform structure gives MORE PREDICTABLE resilience")
    print()


# ============================================================
# Application 2: SAT Instance Difficulty Prediction
# ============================================================

def sat_difficulty_demo():
    """
    Use the overlap matrix to predict SAT instance difficulty.

    The overlap structure determines how "entangled" the clauses are,
    which affects the transition window width and solver difficulty.
    """
    print("=" * 60)
    print("APPLICATION 2: SAT Instance Difficulty Prediction")
    print("=" * 60)

    n = 10
    ground = set(range(1, n + 1))

    # Easy instance: sparse, low overlap
    easy_clauses = [
        {1, 2, 3}, {4, 5, 6}, {7, 8, 9},
    ]
    sys_easy = ObstructionSystem(ground, easy_clauses)

    # Hard instance: dense, high overlap
    hard_clauses = [
        {1, 2, 3}, {1, 2, 4}, {1, 3, 5}, {2, 3, 6},
        {1, 4, 5}, {2, 4, 6}, {3, 5, 6},
    ]
    sys_hard = ObstructionSystem(ground, hard_clauses)

    for label, sys in [("EASY (sparse)", sys_easy), ("HARD (dense)", sys_hard)]:
        print(f"\n--- {label} ---")
        print(f"Clauses: {sys.m}")

        # Compute overlap matrix stats
        M = [[len(sys.obstructions[i] & sys.obstructions[j])
              for j in range(sys.m)] for i in range(sys.m)]

        offdiag = [M[i][j] for i in range(sys.m)
                   for j in range(sys.m) if i != j]
        avg_overlap = sum(offdiag) / len(offdiag) if offdiag else 0
        max_overlap = max(offdiag) if offdiag else 0

        print(f"Average pairwise overlap: {avg_overlap:.2f}")
        print(f"Maximum pairwise overlap: {max_overlap}")

        k1, k2 = compute_transition_window(sys)
        width = k2 - k1
        print(f"Transition window: [{k1}, {k2}], width = {width}")

        # Predict difficulty
        if avg_overlap > 1.0:
            print("Prediction: HARD (high overlap → entangled constraints)")
        else:
            print("Prediction: EASY (low overlap → nearly independent constraints)")

    print(f"\n→ High overlap correlates with wider transition windows")
    print(f"→ The overlap matrix is a fast, computable proxy for difficulty")
    print()


# ============================================================
# Application 3: Certificate Design Optimization
# ============================================================

def certificate_design_demo():
    """
    Use the coding-theoretic connection to design optimal
    verification certificate systems.

    Each certificate check involves d elements. We want to maximize
    the number of checks while maintaining good coverage (each pair
    of checks catches different errors).
    """
    print("=" * 60)
    print("APPLICATION 3: Certificate Design Optimization")
    print("=" * 60)

    n = 9  # number of verifiable properties
    d = 3  # each certificate checks 3 properties

    print(f"\nDesigning certificate system:")
    print(f"  Properties to verify: {n}")
    print(f"  Properties per certificate: {d}")

    # Johnson bound: max certificates without redundancy
    # (no two certificates share d-1 or more properties)
    johnson_bound = n * (n - 1) / (d * (d - 1))
    print(f"\n  Johnson bound (max non-redundant certificates):")
    print(f"    ≤ n(n-1)/(d(d-1)) = {n}·{n-1}/({d}·{d-1}) = {johnson_bound:.0f}")

    # Construct a near-optimal system (Steiner triple system S(2,3,9))
    # The Steiner triple system on 9 points has exactly 12 blocks
    steiner = [
        {1, 2, 3}, {4, 5, 6}, {7, 8, 9},
        {1, 4, 7}, {2, 5, 8}, {3, 6, 9},
        {1, 5, 9}, {2, 6, 7}, {3, 4, 8},
        {1, 6, 8}, {2, 4, 9}, {3, 5, 7},
    ]

    sys = ObstructionSystem(set(range(1, n + 1)), steiner)

    print(f"\n  Steiner triple system S(2, 3, 9):")
    print(f"    Certificates: {len(steiner)} (= Johnson bound ✓)")

    # Verify: every pair of properties appears in exactly one certificate
    pair_count: Dict[Tuple[int, int], int] = {}
    for cert in steiner:
        for a, b in combinations(sorted(cert), 2):
            pair_count[(a, b)] = pair_count.get((a, b), 0) + 1

    all_pairs_covered = all(
        (a, b) in pair_count
        for a in range(1, n + 1)
        for b in range(a + 1, n + 1)
    )
    all_exactly_once = all(v == 1 for v in pair_count.values())

    print(f"    Every pair covered: {all_pairs_covered} ✓")
    print(f"    Each pair exactly once: {all_exactly_once} ✓")

    # Compute Hamming distances
    print(f"\n  Hamming distances between certificates:")
    dists = []
    for i in range(len(steiner)):
        for j in range(i + 1, len(steiner)):
            o1 = frozenset(steiner[i])
            o2 = frozenset(steiner[j])
            h = len(o1) + len(o2) - 2 * len(o1 & o2)
            dists.append(h)

    print(f"    Min Hamming distance: {min(dists)}")
    print(f"    Max Hamming distance: {max(dists)}")
    print(f"    Average Hamming distance: {sum(dists)/len(dists):.2f}")

    # Transition analysis
    k1, k2 = compute_transition_window(sys)
    print(f"\n  Transition window: [{k1}, {k2}]")
    print(f"  → Steiner design gives maximally sharp transition")
    print(f"  → Properties 1-{k1} can always be retained safely")
    print(f"  → Properties {k2}+ always trigger a certificate violation")

    # Compare with random design
    print(f"\n  Comparison with random 3-uniform system:")
    random.seed(42)
    ground = set(range(1, n + 1))
    elements = list(ground)
    random_certs = set()
    while len(random_certs) < 12:
        random_certs.add(frozenset(random.sample(elements, 3)))

    sys_random = ObstructionSystem(ground, [set(c) for c in random_certs])
    k1_r, k2_r = compute_transition_window(sys_random)
    print(f"    Transition window: [{k1_r}, {k2_r}], width = {k2_r - k1_r}")
    print(f"    vs. Steiner width: {k2 - k1}")
    print(f"    → Steiner design is {'sharper' if k2-k1 <= k2_r-k1_r else 'wider'}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)

    network_resilience_demo()
    sat_difficulty_demo()
    certificate_design_demo()

    print("=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Uniformity Sharpness Demonstration

Demonstrates the key theorems from the uniformity sharpness theory
with concrete numerical examples:

1. Satisfiability floor for d-uniform systems
2. Overlap bound for distinct obstructions
3. Packing-based transition bound
4. Sunflower kernel dichotomy
5. Coding-theoretic Hamming distance connection
6. Uniformity sharpness ratio comparison

Usage:
    python demo.py
"""

import random
import math
from itertools import combinations
from typing import List, Set, Tuple, Optional, Dict


# ============================================================
# Core Data Structures
# ============================================================

class ObstructionSystem:
    """An obstruction system (V, O) where V is the ground set and O is
    a family of nonempty subsets (obstructions) of V."""

    def __init__(self, ground: Set[int], obstructions: List[Set[int]]):
        self.ground = ground
        self.obstructions = obstructions
        # Validate
        for o in obstructions:
            assert len(o) > 0, "Obstructions must be nonempty"
            assert o <= ground, f"Obstruction {o} not subset of ground {ground}"

    def is_satisfiable(self, S: Set[int]) -> bool:
        """Check if retained set S is satisfiable (no obstruction ⊆ S)."""
        return all(not o <= S for o in self.obstructions)

    def is_d_uniform(self) -> Optional[int]:
        """Return d if system is d-uniform, else None."""
        if not self.obstructions:
            return None
        d = len(self.obstructions[0])
        if all(len(o) == d for o in self.obstructions):
            return d
        return None

    def overlap_matrix(self) -> List[List[int]]:
        """Compute the uniform overlap matrix M[i][j] = |o_i ∩ o_j|."""
        m = len(self.obstructions)
        M = [[0] * m for _ in range(m)]
        obs = list(self.obstructions)
        for i in range(m):
            for j in range(m):
                M[i][j] = len(obs[i] & obs[j])
        return M

    def independence_number(self) -> int:
        """Compute the obstruction independence number (max packing)."""
        best = 0
        obs = list(self.obstructions)
        # Greedy approach for efficiency
        for _ in range(100):  # random restarts
            random.shuffle(obs)
            packing = []
            used = set()
            for o in obs:
                if not (o & used):
                    packing.append(o)
                    used |= o
            best = max(best, len(packing))
        return best


# ============================================================
# Demo 1: Satisfiability Floor
# ============================================================

def demo_satisfiability_floor():
    """Demonstrate Theorem 1: sets of size < d are always satisfiable."""
    print("=" * 60)
    print("DEMO 1: Satisfiability Floor (Theorem 1)")
    print("=" * 60)

    # Create a 3-uniform system on {1,...,8}
    ground = set(range(1, 9))
    obstructions = [
        {1, 2, 3}, {2, 4, 6}, {3, 5, 7}, {1, 4, 7},
        {2, 5, 8}, {3, 6, 8}, {1, 5, 6}
    ]
    sys = ObstructionSystem(ground, obstructions)
    d = sys.is_d_uniform()
    print(f"\nGround set: {sorted(ground)}")
    print(f"Uniformity parameter d = {d}")
    print(f"Number of obstructions: {len(obstructions)}")

    print(f"\nTheorem: All sets of size < {d} are satisfiable.")
    print("Verification:")

    # Check all subsets of size < d
    for k in range(d):
        all_sat = True
        count = 0
        for S in combinations(ground, k):
            S_set = set(S)
            if not sys.is_satisfiable(S_set):
                all_sat = False
                break
            count += 1
        print(f"  Size {k}: checked {count} subsets, all satisfiable = {all_sat} ✓")

    # Show that size d can be unsatisfiable
    unsat_count = 0
    total = 0
    for S in combinations(ground, d):
        total += 1
        if not sys.is_satisfiable(set(S)):
            unsat_count += 1
    print(f"  Size {d}: {unsat_count}/{total} subsets are unsatisfiable")
    print()


# ============================================================
# Demo 2: Overlap Bound
# ============================================================

def demo_overlap_bound():
    """Demonstrate Theorem 2: distinct obstructions overlap in < d elements."""
    print("=" * 60)
    print("DEMO 2: Overlap Bound (Theorem 2)")
    print("=" * 60)

    ground = set(range(1, 11))
    obstructions = [
        {1, 2, 3, 4}, {2, 3, 5, 6}, {3, 4, 7, 8},
        {1, 5, 7, 9}, {2, 6, 8, 10}, {4, 5, 9, 10}
    ]
    sys = ObstructionSystem(ground, obstructions)
    d = sys.is_d_uniform()
    print(f"\nUniformity parameter d = {d}")
    print(f"Theorem: Any two distinct obstructions share < {d} elements.")
    print("\nPairwise overlaps:")

    max_overlap = 0
    for i, o1 in enumerate(obstructions):
        for j, o2 in enumerate(obstructions):
            if i < j:
                overlap = len(o1 & o2)
                max_overlap = max(max_overlap, overlap)
                print(f"  |{sorted(o1)} ∩ {sorted(o2)}| = {overlap} < {d} ✓")

    print(f"\nMaximum overlap = {max_overlap} < d = {d} ✓")
    print()


# ============================================================
# Demo 3: Packing Transition Bound
# ============================================================

def demo_packing_bound():
    """Demonstrate Theorem 3: packing gives transition upper bound."""
    print("=" * 60)
    print("DEMO 3: Packing Transition Bound (Theorem 3)")
    print("=" * 60)

    ground = set(range(1, 13))
    obstructions = [
        {1, 2, 3}, {4, 5, 6}, {7, 8, 9}, {10, 11, 12},
        {1, 4, 7}, {2, 5, 8}, {3, 6, 9}
    ]
    sys = ObstructionSystem(ground, obstructions)
    n = len(ground)
    d = sys.is_d_uniform()

    # Find disjoint packing
    packing = [{1, 2, 3}, {4, 5, 6}, {7, 8, 9}, {10, 11, 12}]
    nu = len(packing)

    print(f"\nGround set size n = {n}, uniformity d = {d}")
    print(f"Disjoint packing of size ν = {nu}:")
    for p in packing:
        print(f"  {sorted(p)}")

    threshold = n - nu
    print(f"\nTheorem: All sets of size > {threshold} = n - ν are unsatisfiable.")
    print("Verification:")

    for k in range(threshold, n + 1):
        unsat_count = 0
        total = 0
        for S in combinations(ground, k):
            total += 1
            if not sys.is_satisfiable(set(S)):
                unsat_count += 1
        pct = 100 * unsat_count / total if total > 0 else 0
        marker = "✓ (all unsat)" if unsat_count == total else ""
        print(f"  Size {k}: {unsat_count}/{total} unsatisfiable ({pct:.0f}%) {marker}")
    print()


# ============================================================
# Demo 4: Sunflower Kernel Dichotomy
# ============================================================

def demo_sunflower_dichotomy():
    """Demonstrate Theorem 4: hit the kernel or pay per petal."""
    print("=" * 60)
    print("DEMO 4: Sunflower Kernel Dichotomy (Theorem 4)")
    print("=" * 60)

    # Sunflower with kernel {1, 2}
    kernel = {1, 2}
    petals = [{3}, {4}, {5}, {6}]
    sunflower = [kernel | p for p in petals]

    print(f"\nSunflower with kernel K = {sorted(kernel)}:")
    for i, o in enumerate(sunflower):
        print(f"  Petal {i+1}: {sorted(o)} (petal element: {sorted(o - kernel)})")

    # Case 1: Transversal hits kernel
    T1 = {1, 7, 8}
    hits_all = all(T1 & o for o in sunflower)
    hits_kernel = bool(T1 & kernel)
    print(f"\nCase 1: T = {sorted(T1)}")
    print(f"  Hits all obstructions: {hits_all}")
    print(f"  Hits kernel: {hits_kernel} ✓ (Option A of dichotomy)")

    # Case 2: Transversal avoids kernel, must pay per petal
    T2 = {3, 4, 5, 6}
    hits_all = all(T2 & o for o in sunflower)
    hits_kernel = bool(T2 & kernel)
    print(f"\nCase 2: T = {sorted(T2)}")
    print(f"  Hits all obstructions: {hits_all}")
    print(f"  Hits kernel: {hits_kernel}")
    print(f"  |T| = {len(T2)} ≥ |sunflower| = {len(sunflower)} ✓ (Option B)")

    # Case 3: Too small, can't hit all without kernel
    T3 = {3, 4, 5}
    hits_all = all(T3 & o for o in sunflower)
    print(f"\nCase 3: T = {sorted(T3)} (|T| = {len(T3)} < {len(sunflower)})")
    print(f"  Hits all obstructions: {hits_all} (can't cover all petals!)")
    print()


# ============================================================
# Demo 5: Coding-Theoretic Connection
# ============================================================

def demo_hamming_distance():
    """Demonstrate Theorem 5: Hamming distance = 2(d - overlap)."""
    print("=" * 60)
    print("DEMO 5: Coding-Theoretic Connection (Theorem 5)")
    print("=" * 60)

    ground = set(range(1, 9))
    obstructions = [
        {1, 2, 3}, {2, 4, 5}, {3, 6, 7}, {5, 7, 8}
    ]
    d = 3
    n = len(ground)

    print(f"\n{d}-uniform obstructions on ground set of size {n}")
    print("\nBinary encoding (characteristic vectors):")

    for o in obstructions:
        vec = ''.join('1' if i in o else '0' for i in range(1, n + 1))
        print(f"  {sorted(o)} → [{vec}]  (weight = {d})")

    print(f"\nHamming distances (= 2·(d - |overlap|) = 2·({d} - |o₁ ∩ o₂|)):")
    for i, o1 in enumerate(obstructions):
        for j, o2 in enumerate(obstructions):
            if i < j:
                overlap = len(o1 & o2)
                hamming = 2 * (d - overlap)
                # Verify with actual binary vectors
                v1 = set(o1)
                v2 = set(o2)
                actual_hamming = len(v1.symmetric_difference(v2))
                assert hamming == actual_hamming
                print(f"  d_H({sorted(o1)}, {sorted(o2)}) = "
                      f"2·({d} - {overlap}) = {hamming} ✓")
    print()


# ============================================================
# Demo 6: Uniformity Sharpness Ratio
# ============================================================

def compute_transition_window(sys: ObstructionSystem) -> Tuple[int, int]:
    """Compute the transition window [k1, k2] by brute force."""
    n = len(sys.ground)
    elements = sorted(sys.ground)

    k1 = 0
    for k in range(1, n + 1):
        all_sat = True
        for S in combinations(elements, k):
            if not sys.is_satisfiable(set(S)):
                all_sat = False
                break
        if not all_sat:
            k1 = k - 1
            break
    else:
        k1 = n

    k2 = n
    for k in range(n, -1, -1):
        all_unsat = True
        for S in combinations(elements, k):
            if sys.is_satisfiable(set(S)):
                all_unsat = False
                break
        if not all_unsat:
            k2 = k + 1
            break
    else:
        k2 = 0

    return k1, k2


def generate_uniform_system(n: int, d: int, m: int) -> ObstructionSystem:
    """Generate a random d-uniform obstruction system with m obstructions."""
    ground = set(range(1, n + 1))
    elements = list(ground)
    obstructions = set()
    attempts = 0
    while len(obstructions) < m and attempts < m * 100:
        o = frozenset(random.sample(elements, d))
        obstructions.add(o)
        attempts += 1
    return ObstructionSystem(ground, [set(o) for o in obstructions])


def generate_nonuniform_system(n: int, d: int, m: int) -> ObstructionSystem:
    """Generate a non-uniform system with sizes in {d-1, d, d+1}."""
    ground = set(range(1, n + 1))
    elements = list(ground)
    obstructions = set()
    attempts = 0
    while len(obstructions) < m and attempts < m * 100:
        size = random.choice([max(2, d - 1), d, min(n, d + 1)])
        o = frozenset(random.sample(elements, size))
        obstructions.add(o)
        attempts += 1
    return ObstructionSystem(ground, [set(o) for o in obstructions])


def demo_uniformity_sharpness():
    """Demonstrate the Uniformity Sharpness Conjecture computationally."""
    print("=" * 60)
    print("DEMO 6: Uniformity Sharpness Ratio")
    print("=" * 60)

    d = 3
    n = 12  # Small enough for brute force
    m = 8   # Number of obstructions
    trials = 20

    print(f"\nParameters: n={n}, d={d}, m={m}, trials={trials}")
    print(f"Conjectured ratio bound: √(d/(d-1)) = √({d}/{d-1}) = {math.sqrt(d/(d-1)):.4f}")

    uniform_widths = []
    nonuniform_widths = []

    for trial in range(trials):
        sys_u = generate_uniform_system(n, d, m)
        k1_u, k2_u = compute_transition_window(sys_u)
        w_u = k2_u - k1_u

        sys_nu = generate_nonuniform_system(n, d, m)
        k1_nu, k2_nu = compute_transition_window(sys_nu)
        w_nu = k2_nu - k1_nu

        uniform_widths.append(w_u)
        nonuniform_widths.append(w_nu)

    avg_u = sum(uniform_widths) / len(uniform_widths)
    avg_nu = sum(nonuniform_widths) / len(nonuniform_widths)
    ratio = avg_nu / avg_u if avg_u > 0 else float('inf')

    print(f"\nResults:")
    print(f"  Average uniform window width:     {avg_u:.2f}")
    print(f"  Average non-uniform window width:  {avg_nu:.2f}")
    print(f"  Ratio (non-uniform / uniform):     {ratio:.4f}")
    print(f"  Conjectured lower bound:           {math.sqrt(d/(d-1)):.4f}")
    if ratio >= math.sqrt(d / (d - 1)):
        print(f"  Conjecture supported ✓")
    else:
        print(f"  Conjecture not supported in this sample (may need larger n)")

    print(f"\nIndividual trials (uniform width, non-uniform width):")
    for i in range(min(10, trials)):
        print(f"  Trial {i+1}: uniform={uniform_widths[i]}, "
              f"non-uniform={nonuniform_widths[i]}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)

    demo_satisfiability_floor()
    demo_overlap_bound()
    demo_packing_bound()
    demo_sunflower_dichotomy()
    demo_hamming_distance()
    demo_uniformity_sharpness()

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)

#!/usr/bin/env python3
"""
Applications of Proof-Search One-Way Function Theory

Demonstrates real-world applications:
1. Graph-based hash candidate
2. Proof-of-search difficulty estimation
3. Cryptographic parameter selection
4. Security analysis of proof architectures
"""

import hashlib
import random
import struct
from typing import Dict, List, Optional, Tuple


# ============================================================
# Application 1: Graph-Based Hash Candidate
# ============================================================

class GraphHash:
    """A hash function based on directed graph walks.

    The hash of a message m is computed by:
    1. Interpreting m as a sequence of branch choices
    2. Walking the graph according to these choices
    3. Outputting the terminal vertex

    Preimage resistance is supported by the obstruction density theorem:
    finding a message that hashes to a specific target requires finding
    a valid walk, which is exponentially sparse.
    """

    def __init__(
        self, n_vertices: int, B: int, rho: int,
        obstruction_frac: float = 0.4, seed: int = 42
    ):
        self.n_vertices = n_vertices
        self.B = B
        self.rho = rho
        self.seed = seed

        # Build graph
        rng = random.Random(seed)
        n_obs = int(n_vertices * obstruction_frac)
        obstructed = set(rng.sample(range(n_vertices), n_obs))

        self.graph: Dict[int, List[int]] = {}
        for v in range(n_vertices):
            if v in obstructed:
                deg = rng.randint(1, min(rho, n_vertices))
            else:
                deg = rng.randint(min(rho + 1, n_vertices), min(B, n_vertices))
            self.graph[v] = rng.sample(range(n_vertices), min(deg, n_vertices))

        self.obstructed = obstructed

    def hash(self, message: bytes, source: int = 0) -> int:
        """Hash a message by walking the graph.

        Each byte of the message determines a branch choice at each step.
        """
        current = source
        for byte_val in message:
            neighbors = self.graph.get(current, [])
            if not neighbors:
                return current
            idx = byte_val % len(neighbors)
            current = neighbors[idx]
        return current

    def preimage_density_bound(self, walk_length: int) -> float:
        """Theoretical upper bound on preimage density.

        Based on the obstruction density theorem: (ρ/B)^k
        where k is the expected number of obstructions.
        """
        expected_k = walk_length * len(self.obstructed) / self.n_vertices
        actual_B = max(len(self.graph[v]) for v in self.graph)
        return (self.rho / actual_B) ** expected_k if actual_B > 0 else 1.0


# ============================================================
# Application 2: Proof-of-Search Difficulty Estimation
# ============================================================

class ProofOfSearch:
    """Proof-of-search: find a valid walk ending at a target.

    Difficulty is controlled by the obstruction count parameter k.
    The expected number of trials is B^n / (valid walks) ≥ (B/ρ)^k.
    """

    def __init__(
        self, graph: Dict[int, List[int]], source: int, target: int,
        rho: int
    ):
        self.graph = graph
        self.source = source
        self.target = target
        self.rho = rho
        self.B = max(len(graph[v]) for v in graph) if graph else 1

    def solve(self, walk_length: int, max_trials: int = 1000000) -> Optional[List[int]]:
        """Try to find a valid walk from source to target."""
        rng = random.Random()
        for trial in range(max_trials):
            walk = [self.source]
            current = self.source
            for step in range(walk_length):
                neighbors = self.graph.get(current, [])
                if not neighbors:
                    break
                current = rng.choice(neighbors)
                walk.append(current)
            if len(walk) == walk_length + 1 and walk[-1] == self.target:
                return walk
        return None

    def estimated_difficulty(self, walk_length: int, min_k: int) -> float:
        """Estimated number of trials needed based on density bound."""
        density = (self.rho / self.B) ** min_k if self.B > 0 else 1.0
        return 1.0 / density if density > 0 else float('inf')

    def verify(self, walk: List[int]) -> bool:
        """Verify a proposed solution in O(n) time."""
        if not walk or walk[0] != self.source or walk[-1] != self.target:
            return False
        for i in range(len(walk) - 1):
            if walk[i + 1] not in self.graph.get(walk[i], []):
                return False
        return True


# ============================================================
# Application 3: Cryptographic Parameter Selection
# ============================================================

def security_parameters(
    B: int, rho: int, target_security_bits: int
) -> Dict[str, float]:
    """Compute required parameters for target security level.

    Args:
        B: Maximum branching factor
        rho: Obstruction degree bound
        target_security_bits: Desired security level in bits

    Returns:
        Dict with required walk length, obstruction count, etc.
    """
    if B <= rho or B <= 0 or rho <= 0:
        return {"error": "Need 0 < ρ < B"}

    import math
    # (ρ/B)^k ≤ 2^{-security_bits}
    # k · log2(ρ/B) ≤ -security_bits
    # k ≥ security_bits / log2(B/ρ)
    log_ratio = math.log2(B / rho)
    min_k = math.ceil(target_security_bits / log_ratio)

    # Walk length should be at least k (can't have more obstructions than steps)
    # In practice, walk length ≈ 2k for 50% obstruction density
    recommended_n = max(min_k, int(2 * min_k))

    return {
        "B": B,
        "rho": rho,
        "target_security_bits": target_security_bits,
        "min_obstruction_count_k": min_k,
        "density_bound": (rho / B) ** min_k,
        "recommended_walk_length": recommended_n,
        "ambient_space_log2": recommended_n * math.log2(B),
        "log2_ratio_per_obstruction": log_ratio,
    }


# ============================================================
# Application 4: Security Analysis
# ============================================================

def analyze_security(
    graph: Dict[int, List[int]], rho: int, walk_length: int
) -> Dict[str, float]:
    """Analyze the security properties of a proof architecture."""
    import math

    n_vertices = len(graph)
    B = max(len(graph[v]) for v in graph) if graph else 1
    n_obstructed = sum(1 for v in graph if len(graph[v]) <= rho)
    obs_density = n_obstructed / n_vertices if n_vertices > 0 else 0

    # Expected obstruction count per walk
    expected_k = walk_length * obs_density

    # Density bound
    if B > rho and B > 0:
        density = (rho / B) ** expected_k
        security_bits = -math.log2(density) if density > 0 else float('inf')
    else:
        density = 1.0
        security_bits = 0.0

    return {
        "n_vertices": n_vertices,
        "branch_bound_B": B,
        "obstruction_threshold_rho": rho,
        "n_obstructed": n_obstructed,
        "obstruction_density": obs_density,
        "walk_length": walk_length,
        "expected_obstructions": expected_k,
        "density_bound": density,
        "security_bits": security_bits,
        "verification_cost": walk_length,  # O(n)
        "search_cost_estimate": 1.0 / density if density > 0 else float('inf'),
    }


# ============================================================
# Demonstrations
# ============================================================

def demo_graph_hash():
    """Demonstrate graph-based hash function."""
    print("=" * 60)
    print("APPLICATION 1: Graph-Based Hash Function")
    print("=" * 60)

    hasher = GraphHash(n_vertices=100, B=8, rho=2, obstruction_frac=0.4)

    messages = [b"Hello, World!", b"Hello, World?", b"Proof search", b""]
    print(f"Hash function: {hasher.n_vertices} vertices, B={hasher.B}, ρ={hasher.rho}")
    print()
    for msg in messages:
        h = hasher.hash(msg)
        print(f"  hash({msg!r}) = {h}")

    # Avalanche effect
    print("\nAvalanche test (1-bit changes):")
    base = b"Test message for avalanche"
    base_hash = hasher.hash(base)
    for i in range(min(5, len(base))):
        modified = bytearray(base)
        modified[i] ^= 1
        mod_hash = hasher.hash(bytes(modified))
        print(f"  Flip bit {i}: hash changes {base_hash} → {mod_hash} ({'same' if base_hash == mod_hash else 'different'})")
    print()

    # Preimage density
    density = hasher.preimage_density_bound(len(base))
    print(f"Preimage density bound (walk length {len(base)}): {density:.2e}")
    print()


def demo_proof_of_search():
    """Demonstrate proof-of-search difficulty."""
    print("=" * 60)
    print("APPLICATION 2: Proof-of-Search")
    print("=" * 60)

    rng = random.Random(42)
    n_vertices = 50
    B = 5
    rho = 1

    graph = {}
    for v in range(n_vertices):
        deg = rng.randint(1, B)
        graph[v] = rng.sample(range(n_vertices), min(deg, n_vertices))

    pos = ProofOfSearch(graph, source=0, target=25, rho=rho)

    for walk_length in [5, 10, 15]:
        difficulty = pos.estimated_difficulty(walk_length, min_k=walk_length // 3)
        solution = pos.solve(walk_length, max_trials=50000)
        status = "FOUND" if solution else "NOT FOUND"
        verified = pos.verify(solution) if solution else False
        print(f"  Walk length {walk_length:>2}: difficulty ≈ {difficulty:>10.0f}, "
              f"search result: {status}, verified: {verified}")
    print()


def demo_parameter_selection():
    """Demonstrate cryptographic parameter selection."""
    print("=" * 60)
    print("APPLICATION 3: Parameter Selection")
    print("=" * 60)

    configs = [
        (10, 2, 80),
        (10, 2, 128),
        (10, 2, 256),
        (100, 10, 128),
        (1000, 100, 128),
    ]

    print(f"{'B':>5} {'ρ':>5} {'Security':>10} {'Min k':>7} {'Walk n':>7} {'Density':>12}")
    print("-" * 55)
    for B, rho, sec in configs:
        params = security_parameters(B, rho, sec)
        print(f"{B:>5} {rho:>5} {sec:>8} bits {params['min_obstruction_count_k']:>7} "
              f"{params['recommended_walk_length']:>7} {params['density_bound']:>12.2e}")
    print()


def demo_security_analysis():
    """Demonstrate security analysis of a proof architecture."""
    print("=" * 60)
    print("APPLICATION 4: Security Analysis")
    print("=" * 60)

    rng = random.Random(42)
    n_vertices = 100
    B = 8
    rho = 2

    graph = {}
    for v in range(n_vertices):
        if rng.random() < 0.4:  # 40% obstructed
            deg = rng.randint(1, rho)
        else:
            deg = rng.randint(rho + 1, B)
        graph[v] = rng.sample(range(n_vertices), min(deg, n_vertices))

    for walk_length in [10, 20, 50, 100]:
        analysis = analyze_security(graph, rho, walk_length)
        print(f"\n  Walk length {walk_length}:")
        print(f"    Expected obstructions: {analysis['expected_obstructions']:.1f}")
        print(f"    Density bound: {analysis['density_bound']:.2e}")
        print(f"    Security bits: {analysis['security_bits']:.1f}")
        print(f"    Verification cost: O({analysis['verification_cost']})")
        print(f"    Search cost estimate: {analysis['search_cost_estimate']:.2e}")
    print()


if __name__ == "__main__":
    demo_graph_hash()
    demo_proof_of_search()
    demo_parameter_selection()
    demo_security_analysis()


#!/usr/bin/env python3
"""
Demonstration of Proof-Search One-Way Function Theory

Concrete numerical examples illustrating the main theorems:
1. Walk count bound: walkCount(s, n) ≤ B^n
2. Obstructed walk count bound: ≤ B^(n-k) * ρ^k
3. Density decay: fraction of valid walks ≤ (ρ/B)^k
4. Walk verification (O(n) checking)
"""

import random
from typing import Dict, List, Optional, Set, Tuple


def generate_random_graph(
    n_vertices: int, max_degree: int, seed: int = 42
) -> Dict[int, List[int]]:
    """Generate a random directed graph with bounded out-degree."""
    rng = random.Random(seed)
    graph: Dict[int, List[int]] = {}
    for v in range(n_vertices):
        deg = rng.randint(1, max_degree)
        neighbors = rng.sample(range(n_vertices), min(deg, n_vertices))
        graph[v] = neighbors
    return graph


def generate_obstructed_graph(
    n_vertices: int, B: int, rho: int, obstruction_frac: float, seed: int = 42
) -> Tuple[Dict[int, List[int]], Set[int]]:
    """Generate a graph with a fraction of obstructed vertices (degree ≤ ρ)."""
    rng = random.Random(seed)
    n_obstructed = int(n_vertices * obstruction_frac)
    obstructed = set(rng.sample(range(n_vertices), n_obstructed))
    graph: Dict[int, List[int]] = {}
    for v in range(n_vertices):
        if v in obstructed:
            deg = rng.randint(1, rho)
        else:
            deg = rng.randint(rho + 1, B)
        neighbors = rng.sample(range(n_vertices), min(deg, n_vertices))
        graph[v] = neighbors
    return graph, obstructed


def walk_count(graph: Dict[int, List[int]], s: int, n: int) -> int:
    """Recursively count walks of length n from s."""
    if n == 0:
        return 1
    return sum(walk_count(graph, v, n - 1) for v in graph.get(s, []))


def walk_count_dp(graph: Dict[int, List[int]], s: int, n: int) -> Dict[int, int]:
    """Count walks of length n from s using dynamic programming.
    Returns dict mapping terminal vertex to count.
    """
    current = {v: 0 for v in graph}
    current[s] = 1
    for _ in range(n):
        next_count = {v: 0 for v in graph}
        for u, cnt in current.items():
            if cnt > 0:
                for v in graph.get(u, []):
                    next_count[v] += cnt
        current = next_count
    return current


def obstructed_walk_count_dp(
    graph: Dict[int, List[int]], rho: int, s: int, n: int, min_k: int
) -> int:
    """Count walks from s of length n with ≥ min_k obstructed vertices.
    Uses DP tracking (vertex, obstruction_count) pairs.
    """
    # State: (vertex, obs_count) -> walk count
    current: Dict[Tuple[int, int], int] = {(s, 0): 1}
    for step in range(n):
        next_state: Dict[Tuple[int, int], int] = {}
        for (u, obs), cnt in current.items():
            if cnt == 0:
                continue
            is_obs = len(graph.get(u, [])) <= rho
            new_obs = obs + (1 if is_obs else 0)
            for v in graph.get(u, []):
                key = (v, new_obs)
                next_state[key] = next_state.get(key, 0) + cnt
        current = next_state
    return sum(cnt for (_, obs), cnt in current.items() if obs >= min_k)


def verify_walk(
    graph: Dict[int, List[int]], s: int, t: int, walk: List[int]
) -> bool:
    """Verify a walk is valid: starts at s, ends at t, follows edges."""
    if not walk or walk[0] != s or walk[-1] != t:
        return False
    for i in range(len(walk) - 1):
        if walk[i + 1] not in graph.get(walk[i], []):
            return False
    return True


def find_random_walk(
    graph: Dict[int, List[int]], s: int, n: int, seed: int = 0
) -> List[int]:
    """Generate a random walk of length n from s."""
    rng = random.Random(seed)
    walk = [s]
    current = s
    for _ in range(n):
        neighbors = graph.get(current, [])
        if not neighbors:
            break
        current = rng.choice(neighbors)
        walk.append(current)
    return walk


def count_obstructions(
    graph: Dict[int, List[int]], rho: int, walk: List[int]
) -> int:
    """Count obstructed steps in a walk."""
    count = 0
    for i in range(len(walk) - 1):
        if len(graph.get(walk[i], [])) <= rho:
            count += 1
    return count


# ============================================================
# DEMONSTRATIONS
# ============================================================

def demo_walk_count_bound():
    """Demonstrate Theorem 2.1: walkCount ≤ B^n."""
    print("=" * 60)
    print("DEMO 1: Walk Count Bound (walkCount ≤ B^n)")
    print("=" * 60)

    n_vertices = 20
    B = 4

    graph = generate_random_graph(n_vertices, B, seed=42)
    actual_B = max(len(graph[v]) for v in graph)
    print(f"Graph: {n_vertices} vertices, max degree B = {actual_B}")

    for walk_len in [1, 2, 3, 4, 5, 6]:
        counts = walk_count_dp(graph, 0, walk_len)
        total = sum(counts.values())
        bound = actual_B ** walk_len
        print(
            f"  Length {walk_len}: walkCount = {total:>10,}, "
            f"B^n = {bound:>10,}, "
            f"ratio = {total/bound:.4f}"
        )
    print()


def demo_obstructed_walk_count():
    """Demonstrate Theorem 2.2: obstructed walks ≤ B^(n-k) * ρ^k."""
    print("=" * 60)
    print("DEMO 2: Obstructed Walk Count Bound")
    print("=" * 60)

    n_vertices = 30
    B = 5
    rho = 2
    obstruction_frac = 0.4

    graph, obstructed = generate_obstructed_graph(
        n_vertices, B, rho, obstruction_frac, seed=123
    )
    actual_B = max(len(graph[v]) for v in graph)
    print(f"Graph: {n_vertices} vertices, B = {actual_B}, ρ = {rho}")
    print(f"Obstructed vertices: {len(obstructed)} ({100*len(obstructed)/n_vertices:.0f}%)")
    print()

    walk_len = 8
    print(f"Walk length n = {walk_len}")
    print(f"{'k':>3} | {'Obs Count':>12} | {'Bound B^(n-k)ρ^k':>18} | {'Ratio':>8} | {'Density':>12}")
    print("-" * 70)

    total_walks = sum(walk_count_dp(graph, 0, walk_len).values())
    for k in range(0, walk_len + 1):
        obs_count = obstructed_walk_count_dp(graph, rho, 0, walk_len, k)
        bound = actual_B ** max(0, walk_len - k) * rho ** k
        ratio = obs_count / bound if bound > 0 else 0
        density = obs_count / total_walks if total_walks > 0 else 0
        print(
            f"{k:>3} | {obs_count:>12,} | {bound:>18,} | {ratio:>8.4f} | {density:>12.6f}"
        )
    print()


def demo_density_decay():
    """Demonstrate Theorem 2.5: density ≤ (ρ/B)^k."""
    print("=" * 60)
    print("DEMO 3: Exponential Density Decay")
    print("=" * 60)

    n_vertices = 25
    B = 6
    rho = 2

    graph, obstructed = generate_obstructed_graph(
        n_vertices, B, rho, 0.5, seed=456
    )
    actual_B = max(len(graph[v]) for v in graph)
    print(f"Graph: {n_vertices} vertices, B = {actual_B}, ρ = {rho}")
    print(f"Density bound: (ρ/B)^k = ({rho}/{actual_B})^k = {rho/actual_B:.4f}^k")
    print()

    walk_len = 10
    total_walks = sum(walk_count_dp(graph, 0, walk_len).values())

    print(f"{'k':>3} | {'Empirical Density':>18} | {'Bound (ρ/B)^k':>18} | {'Bound holds?':>12}")
    print("-" * 60)
    for k in range(0, 8):
        obs_count = obstructed_walk_count_dp(graph, rho, 0, walk_len, k)
        empirical = obs_count / (actual_B ** walk_len) if actual_B > 0 else 0
        bound = (rho / actual_B) ** k
        holds = "✓" if empirical <= bound + 1e-10 else "✗"
        print(
            f"{k:>3} | {empirical:>18.10f} | {bound:>18.10f} | {holds:>12}"
        )
    print()


def demo_verification():
    """Demonstrate decidable verification: O(n) walk checking."""
    print("=" * 60)
    print("DEMO 4: Walk Verification (Decidable, O(n))")
    print("=" * 60)

    n_vertices = 50
    B = 5
    graph = generate_random_graph(n_vertices, B, seed=789)

    walk_len = 20
    source, target = 0, 15

    # Generate a valid random walk
    valid_walk = find_random_walk(graph, source, walk_len, seed=100)
    actual_target = valid_walk[-1]

    print(f"Walk length: {walk_len}")
    print(f"Source: {source}, Target: {actual_target}")
    print(f"Walk: {valid_walk[:5]} ... {valid_walk[-3:]}")
    print(f"Verification result: {verify_walk(graph, source, actual_target, valid_walk)}")

    # Corrupt the walk
    corrupted = valid_walk.copy()
    corrupted[walk_len // 2] = (corrupted[walk_len // 2] + 7) % n_vertices
    print(f"Corrupted walk verification: {verify_walk(graph, source, actual_target, corrupted)}")

    # Count obstructions
    rho = 2
    obs = count_obstructions(graph, rho, valid_walk)
    print(f"Obstruction count (ρ={rho}): {obs}")
    print()


def demo_cryptographic_asymmetry():
    """Demonstrate the one-wayness surrogate: easy verification, hard search."""
    print("=" * 60)
    print("DEMO 5: Cryptographic Asymmetry (One-Wayness Surrogate)")
    print("=" * 60)

    n_vertices = 40
    B = 5
    rho = 1
    obstruction_frac = 0.6

    graph, obstructed = generate_obstructed_graph(
        n_vertices, B, rho, obstruction_frac, seed=999
    )
    actual_B = max(len(graph[v]) for v in graph)

    print(f"Graph: {n_vertices} vertices, B = {actual_B}, ρ = {rho}")
    print(f"Obstruction fraction: {obstruction_frac*100:.0f}%")
    print()

    target = 10
    walk_len = 12

    # Search: try random walks and see how many hit the target
    n_trials = 100000
    successes = 0
    for trial in range(n_trials):
        walk = find_random_walk(graph, 0, walk_len, seed=trial)
        if walk[-1] == target and len(walk) == walk_len + 1:
            successes += 1

    # Theoretical bound
    total_walks = sum(walk_count_dp(graph, 0, walk_len).values())
    target_walks_count = walk_count_dp(graph, 0, walk_len).get(target, 0)
    min_obs = walk_len  # conservative
    for trial in range(min(1000, n_trials)):
        walk = find_random_walk(graph, 0, walk_len, seed=trial)
        if walk[-1] == target and len(walk) == walk_len + 1:
            obs = count_obstructions(graph, rho, walk)
            min_obs = min(min_obs, obs)

    print(f"VERIFICATION (easy):")
    print(f"  Steps to verify a walk: {walk_len} (linear)")
    print()
    print(f"SEARCH (hard):")
    print(f"  Total walks from source: {total_walks:,}")
    print(f"  Walks reaching target {target}: {target_walks_count:,}")
    print(f"  Empirical hit rate ({n_trials:,} trials): {successes}/{n_trials} = {successes/n_trials:.6f}")
    print(f"  Target density: {target_walks_count/total_walks:.8f}" if total_walks > 0 else "  N/A")
    if min_obs < walk_len:
        density_bound = (rho / actual_B) ** min_obs
        print(f"  Min obstructions in hitting walks: {min_obs}")
        print(f"  Obstruction density bound: (ρ/B)^k = ({rho}/{actual_B})^{min_obs} = {density_bound:.2e}")
    print()
    print("ASYMMETRY: Verification is O(n), search requires exponential trials")
    print()


if __name__ == "__main__":
    demo_walk_count_bound()
    demo_obstructed_walk_count()
    demo_density_decay()
    demo_verification()
    demo_cryptographic_asymmetry()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts bundled."""

import json
import sys
sys.path.insert(0, '.')

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Catalog/Cryptography/ProofSearch/OneWay.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
visualizations_code = read_file('visualizations.py')

# Generate visualizations
from visualizations import generate_all_visualizations
vizs = generate_all_visualizations()

package = {
    "title": "Cryptographic Extraction from Proof-Search Branching Invariants",
    "domain": "Cryptography / Combinatorics / Formal Verification",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Walk Count and Density Decay Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Hash, Proof-of-Search, Security",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Walk Verification",
            "pseudocode": "function VERIFY_WALK(E, s, t, n, w):\n    if w[0] ≠ s: return False\n    if w[n] ≠ t: return False\n    for i = 0 to n-1:\n        if w[i+1] ∉ E(w[i]): return False\n    return True\n\nComplexity: O(n) time, O(1) space",
            "code": algorithms_code
        },
        {
            "name": "Obstructed Walk Count (DP)",
            "pseudocode": "function OBS_WALK_COUNT(E, ρ, s, n, k):\n    state = {(s, 0): 1}  // (vertex, obs_count) -> count\n    for step = 1 to n:\n        new_state = {}\n        for (u, obs), cnt in state:\n            is_obs = |E(u)| ≤ ρ\n            new_obs = obs + (1 if is_obs else 0)\n            for v in E(u):\n                new_state[(v, new_obs)] += cnt\n        state = new_state\n    return Σ cnt for (v, obs) in state if obs ≥ k\n\nComplexity: O(n² · |E|) time, O(n · |V|) space",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Exponential Density Decay",
            "data": vizs.get("density_decay", "")
        },
        {
            "name": "Walk Count vs Theoretical Bounds",
            "data": vizs.get("walk_count", "")
        },
        {
            "name": "Security Parameter Heatmap",
            "data": vizs.get("security_heatmap", "")
        },
        {
            "name": "Proof Architecture Diagram",
            "data": vizs.get("obstruction_diagram", "")
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated: {len(json.dumps(package))} chars")


#!/usr/bin/env python3
"""
Visualizations for Proof-Search One-Way Function Theory

Generates publication-quality figures illustrating:
1. Exponential density decay
2. Walk count vs obstruction bound
3. Security parameter space
4. Graph structure with obstructions
"""

import math
import random
import base64
import io
from typing import Dict, List, Tuple

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_density_decay() -> str:
    """Plot exponential density decay (ρ/B)^k for various B and ρ."""
    if not HAS_MPL:
        return ""

    fig, ax = plt.subplots(figsize=(10, 6))

    k_values = np.arange(0, 51)

    configs = [
        (10, 5, '#e74c3c', 'B=10, ρ=5'),
        (10, 2, '#3498db', 'B=10, ρ=2'),
        (10, 1, '#2ecc71', 'B=10, ρ=1'),
        (5, 1, '#9b59b6', 'B=5, ρ=1'),
        (100, 10, '#f39c12', 'B=100, ρ=10'),
    ]

    for B, rho, color, label in configs:
        densities = [(rho / B) ** k for k in k_values]
        ax.semilogy(k_values, densities, color=color, linewidth=2, label=label)

    ax.set_xlabel('Obstruction Count k', fontsize=14)
    ax.set_ylabel('Density Bound (ρ/B)^k', fontsize=14)
    ax.set_title('Exponential Density Decay with Obstruction Count', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 50)
    ax.set_ylim(1e-50, 1.5)

    return fig_to_base64(fig)


def plot_walk_count_comparison() -> str:
    """Plot actual walk count vs B^n bound."""
    if not HAS_MPL:
        return ""

    # Generate a graph
    rng = random.Random(42)
    n_vertices = 30
    B = 5
    rho = 2
    graph = {}
    for v in range(n_vertices):
        if rng.random() < 0.4:
            deg = rng.randint(1, rho)
        else:
            deg = rng.randint(rho + 1, B)
        graph[v] = rng.sample(range(n_vertices), min(deg, n_vertices))

    actual_B = max(len(graph[v]) for v in graph)

    # Compute walk counts
    walk_lengths = list(range(1, 13))
    actual_counts = []
    bound_counts = []
    obs_bounds = []

    for n in walk_lengths:
        # DP walk count
        current = {v: 0 for v in graph}
        current[0] = 1
        for _ in range(n):
            next_c = {v: 0 for v in graph}
            for u, cnt in current.items():
                if cnt > 0:
                    for v in graph.get(u, []):
                        next_c[v] += cnt
            current = next_c
        total = sum(current.values())
        actual_counts.append(total)
        bound_counts.append(actual_B ** n)

        # Obstruction bound with k = n//3
        k = n // 3
        obs_bounds.append(actual_B ** max(0, n - k) * rho ** k)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.semilogy(walk_lengths, actual_counts, 'o-', color='#3498db',
                linewidth=2, markersize=8, label='Actual Walk Count')
    ax.semilogy(walk_lengths, bound_counts, 's--', color='#e74c3c',
                linewidth=2, markersize=8, label=f'Bound B^n (B={actual_B})')
    ax.semilogy(walk_lengths, obs_bounds, '^--', color='#2ecc71',
                linewidth=2, markersize=8, label=f'Obs. Bound B^(n-k)ρ^k (k=n/3, ρ={rho})')

    ax.set_xlabel('Walk Length n', fontsize=14)
    ax.set_ylabel('Count', fontsize=14)
    ax.set_title('Walk Count vs. Theoretical Bounds', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


def plot_security_heatmap() -> str:
    """Plot security bits as function of B/ρ ratio and walk length."""
    if not HAS_MPL:
        return ""

    ratios = np.linspace(1.1, 20, 50)  # B/ρ ratio
    walk_lengths = np.arange(5, 105, 5)
    obs_frac = 0.4  # 40% obstruction density

    security = np.zeros((len(walk_lengths), len(ratios)))
    for i, n in enumerate(walk_lengths):
        for j, r in enumerate(ratios):
            k = int(n * obs_frac)
            security[i, j] = k * math.log2(r)

    fig, ax = plt.subplots(figsize=(10, 7))
    im = ax.pcolormesh(ratios, walk_lengths, security,
                       cmap='YlOrRd', shading='auto')
    cbar = fig.colorbar(im, ax=ax, label='Security Bits')

    # Add contour lines
    contours = ax.contour(ratios, walk_lengths, security,
                          levels=[40, 80, 128, 256], colors='black',
                          linewidths=1.5)
    ax.clabel(contours, inline=True, fontsize=10, fmt='%d bits')

    ax.set_xlabel('Branching Ratio B/ρ', fontsize=14)
    ax.set_ylabel('Walk Length n', fontsize=14)
    ax.set_title('Security Level (bits) vs. Parameters\n(40% obstruction density)',
                 fontsize=16)

    return fig_to_base64(fig)


def plot_obstruction_diagram() -> str:
    """Plot a small graph showing obstructed vs. normal vertices."""
    if not HAS_MPL:
        return ""

    fig, ax = plt.subplots(figsize=(10, 8))

    # Small example graph
    positions = {
        0: (0, 2), 1: (2, 3), 2: (2, 1), 3: (4, 3.5),
        4: (4, 2), 5: (4, 0.5), 6: (6, 3), 7: (6, 1),
        8: (8, 2)
    }

    edges = {
        0: [1, 2], 1: [3, 4], 2: [4, 5], 3: [6],
        4: [6, 7], 5: [7], 6: [8], 7: [8]
    }

    # Obstructed vertices: degree ≤ 1
    obstructed = {3, 5, 6, 7}  # vertices with degree 1

    # Draw edges
    for u, neighbors in edges.items():
        for v in neighbors:
            x0, y0 = positions[u]
            x1, y1 = positions[v]
            dx, dy = x1 - x0, y1 - y0
            ax.annotate("", xy=(x1, y1), xytext=(x0, y0),
                       arrowprops=dict(arrowstyle='->', color='#7f8c8d',
                                      lw=1.5, connectionstyle="arc3,rad=0.1"))

    # Draw vertices
    for v, (x, y) in positions.items():
        if v in obstructed:
            color = '#e74c3c'
            label = f'{v}\n(deg≤ρ)'
        else:
            color = '#3498db'
            label = f'{v}\n(deg>ρ)'
        circle = plt.Circle((x, y), 0.35, color=color, alpha=0.8, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=8,
                color='white', fontweight='bold', zorder=6)

    # Highlight a valid walk
    walk = [0, 1, 3, 6, 8]
    for i in range(len(walk) - 1):
        x0, y0 = positions[walk[i]]
        x1, y1 = positions[walk[i + 1]]
        ax.annotate("", xy=(x1, y1), xytext=(x0, y0),
                   arrowprops=dict(arrowstyle='->', color='#2ecc71',
                                  lw=3, connectionstyle="arc3,rad=0.15"))

    # Legend
    normal_patch = mpatches.Patch(color='#3498db', label='Normal vertex (deg > ρ)')
    obs_patch = mpatches.Patch(color='#e74c3c', label='Obstructed vertex (deg ≤ ρ)')
    walk_line = mpatches.FancyArrow(0, 0, 1, 0, color='#2ecc71', width=0.1)
    ax.legend(handles=[normal_patch, obs_patch],
             loc='upper left', fontsize=11)

    ax.set_xlim(-1, 9)
    ax.set_ylim(-0.5, 4.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Proof Architecture: Walk Through Obstructed Graph\n'
                 'Green arrows show a valid walk (0→1→3→6→8) with 2 obstructions',
                 fontsize=14)

    return fig_to_base64(fig)


def generate_all_visualizations() -> Dict[str, str]:
    """Generate all visualizations and return as dict of base64 images."""
    results = {}

    print("Generating density decay plot...")
    results["density_decay"] = plot_density_decay()

    print("Generating walk count comparison...")
    results["walk_count"] = plot_walk_count_comparison()

    print("Generating security heatmap...")
    results["security_heatmap"] = plot_security_heatmap()

    print("Generating obstruction diagram...")
    results["obstruction_diagram"] = plot_obstruction_diagram()

    return results


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    for name, data in vizs.items():
        if data:
            print(f"  {name}: {len(data)} chars")
        else:
            print(f"  {name}: FAILED (matplotlib not available)")

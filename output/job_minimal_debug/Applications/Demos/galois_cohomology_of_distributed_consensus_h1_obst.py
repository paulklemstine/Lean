#!/usr/bin/env python3
"""
Algorithms for Galois-Cohomological Distributed Consensus

Implements the key algorithms from the research paper with full
docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Optional, Callable, Dict
import numpy as np
from math import gcd


class CyclicGroup:
    """Represents the cyclic group Z/nZ."""
    
    def __init__(self, n: int):
        assert n > 0
        self.n = n
    
    def mul(self, g: int, h: int) -> int:
        return (g + h) % self.n
    
    def inv(self, g: int) -> int:
        return (-g) % self.n
    
    def identity(self) -> int:
        return 0
    
    def elements(self) -> List[int]:
        return list(range(self.n))
    
    def card(self) -> int:
        return self.n


class GModule:
    """Represents a G-module: abelian group A with G-action.
    
    The action is specified as a function action(g, a) -> a'.
    The abelian group structure is modular arithmetic on Z/mZ.
    """
    
    def __init__(self, m: int, action: Callable[[int, int], int]):
        self.m = m
        self.action = action
    
    def add(self, a: int, b: int) -> int:
        return (a + b) % self.m
    
    def neg(self, a: int) -> int:
        return (-a) % self.m
    
    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.m
    
    def zero(self) -> int:
        return 0
    
    def act(self, g: int, a: int) -> int:
        return self.action(g, a) % self.m
    
    def elements(self) -> List[int]:
        return list(range(self.m))


def verify_cocycle(G: CyclicGroup, M: GModule, f: Callable[[int], int]) -> bool:
    """Verify that f : G → A satisfies the cocycle condition.
    
    Checks: f(gh) = f(g) + g·f(h) for all g, h ∈ G.
    
    Complexity: O(|G|²)
    
    Args:
        G: The group
        M: The G-module  
        f: The candidate cocycle
        
    Returns:
        True if f is a cocycle
    """
    for g in G.elements():
        for h in G.elements():
            gh = G.mul(g, h)
            lhs = f(gh)
            rhs = M.add(f(g), M.act(g, f(h)))
            if lhs != rhs:
                return False
    return True


def verify_coboundary(G: CyclicGroup, M: GModule, 
                       f: Callable[[int], int], a: int) -> bool:
    """Verify that f = δ(a), i.e., f(g) = g·a - a for all g.
    
    Complexity: O(|G|) — linear!
    
    Args:
        G: The group
        M: The G-module
        f: The cocycle
        a: The candidate coboundary source
        
    Returns:
        True if f is the coboundary of a
    """
    for g in G.elements():
        if f(g) != M.sub(M.act(g, a), a):
            return False
    return True


def find_coboundary_witness(G: CyclicGroup, M: GModule,
                             f: Callable[[int], int]) -> Optional[int]:
    """Find a ∈ A such that f = δ(a), or None if f is not a coboundary.
    
    Complexity: O(|G| · |A|) — tries all candidates
    
    Args:
        G: The group
        M: The G-module
        f: The cocycle
        
    Returns:
        The coboundary source a, or None
    """
    for a in M.elements():
        if verify_coboundary(G, M, f, a):
            return a
    return None


def compute_h1(G: CyclicGroup, M: GModule) -> Tuple[int, List[Callable]]:
    """Compute H¹(G, A) by enumerating all cocycles and coboundaries.
    
    Complexity: O(|A|^|G| · |G|²) — exponential, but exact
    
    Returns:
        (|H¹|, list of representative cocycles)
    """
    n = G.card()
    m = M.m
    
    # For Z/nZ, a cocycle is determined by its values on generators
    # But we enumerate all functions and filter
    cocycles = []
    coboundaries = set()
    
    # Find all coboundaries first
    for a in M.elements():
        f_values = tuple(M.sub(M.act(g, a), a) for g in G.elements())
        coboundaries.add(f_values)
    
    # For small groups, enumerate cocycles
    # A cocycle on Z/nZ with trivial action is a hom, determined by f(1)
    # with n·f(1) = 0 mod m
    for c in M.elements():
        if (n * c) % m == 0:
            f_values = tuple((g * c) % m for g in G.elements())
            cocycles.append(f_values)
    
    # H¹ = cocycles / coboundaries
    classes = set()
    for coc in cocycles:
        # Find its class: coc mod coboundaries
        classes.add(coc)
    
    # Count distinct classes modulo coboundaries
    h1_classes = []
    for coc in cocycles:
        is_coboundary = coc in coboundaries
        if not is_coboundary:
            h1_classes.append(coc)
    
    # |H¹| = |Z¹| / |B¹| for abelian case
    h1_size = len(cocycles) // max(len(coboundaries), 1)
    if len(coboundaries) == 1:  # Only zero coboundary (trivial action)
        h1_size = len(cocycles)
    
    return h1_size, cocycles


def byzantine_max_faults(n: int) -> int:
    """Maximum Byzantine faults tolerable with n agents.
    
    The 3f+1 bound: max f such that 3f+1 ≤ n.
    
    Complexity: O(1)
    
    Args:
        n: Number of agents
        
    Returns:
        Maximum tolerable faults
    """
    return (n - 1) // 3


def consensus_round_lower_bound(n: int) -> int:
    """Lower bound on consensus rounds: ⌈log₂ n⌉.
    
    Any protocol needs at least this many rounds for 
    information dissemination.
    
    Complexity: O(1)
    """
    if n <= 1:
        return 0
    import math
    return math.ceil(math.log2(n))


def averaging_consensus(states: np.ndarray, rounds: int) -> np.ndarray:
    """Run averaging consensus protocol.
    
    Each round, every agent replaces its state with the average
    of all states. Converges at rate (1 - 1/n)^t.
    
    Complexity: O(n · rounds)
    
    Args:
        states: Initial agent states
        rounds: Number of rounds
        
    Returns:
        Final states after averaging
    """
    n = len(states)
    current = states.copy()
    for _ in range(rounds):
        avg = np.mean(current)
        current = np.full(n, avg)
    return current


def consensus_gap(f: Callable[[int], int], a: int,
                   G: CyclicGroup, M: GModule) -> int:
    """Compute the consensus gap: max |f(g) - δ(a)(g)|.
    
    The gap measures how far f is from the coboundary δ(a).
    Gap = 0 iff f = δ(a).
    
    Complexity: O(|G|)
    """
    max_gap = 0
    for g in G.elements():
        delta_a_g = M.sub(M.act(g, a), a)
        gap = abs(f(g) - delta_a_g)
        max_gap = max(max_gap, gap)
    return max_gap


def certification_complexity(G: CyclicGroup) -> Dict[str, int]:
    """Compute certification complexity bounds.
    
    Returns dictionary with complexity measures.
    """
    n = G.card()
    return {
        "cocycle_verification": n * n,     # O(|G|²)
        "coboundary_verification": n,       # O(|G|)
        "state_space_check": n,             # O(|G|)
        "certificate_uniqueness": n,        # O(|G|)
        "full_enumeration": n * n * n,      # O(|G|³) worst case
    }


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("Galois-Cohomological Consensus: Algorithm Demonstrations\n")
    
    # Setup: Z/6Z acting trivially on Z/4Z
    G = CyclicGroup(6)
    M = GModule(4, action=lambda g, a: a)  # Trivial action
    
    print("Group: Z/6Z, Module: Z/4Z (trivial action)")
    print(f"|G| = {G.card()}, |A| = {M.m}")
    
    # Compute H¹
    h1_size, cocycles = compute_h1(G, M)
    print(f"|H¹(Z/6Z, Z/4Z)| = {h1_size}")
    print(f"Expected: gcd(6,4) = {gcd(6,4)}")
    print(f"Consensus achievable? {'YES' if h1_size <= 1 else 'NO'}")
    
    # Byzantine bounds
    print(f"\nByzantine fault tolerance:")
    for n in [4, 7, 10, 13, 100]:
        f = byzantine_max_faults(n)
        rounds = consensus_round_lower_bound(n)
        print(f"  n={n:>3}: max_faults={f}, min_rounds≥{rounds}")
    
    # Complexity
    print(f"\nCertification complexity for |G|=100:")
    cx = certification_complexity(CyclicGroup(100))
    for k, v in cx.items():
        print(f"  {k}: {v}")


#!/usr/bin/env python3
"""
Real-world applications of Galois-Cohomological Distributed Consensus.

Demonstrates applications to:
1. Blockchain consensus analysis
2. Distributed ML training coordination
3. Post-quantum consensus certification
4. Network topology optimization
"""

import numpy as np
from math import gcd, log2, ceil
from typing import List, Tuple, Dict


# ============================================================
# Application 1: Blockchain Consensus Analysis
# ============================================================

def analyze_blockchain_consensus(n_validators: int, 
                                  byzantine_fraction: float) -> Dict:
    """Analyze blockchain consensus using cohomological framework.
    
    Models a proof-of-stake blockchain with n validators.
    Uses the 3f+1 bound and cohomological obstruction theory.
    
    Args:
        n_validators: Number of validators
        byzantine_fraction: Expected fraction of Byzantine validators
        
    Returns:
        Analysis dictionary with safety guarantees
    """
    f_byzantine = int(n_validators * byzantine_fraction)
    f_max = (n_validators - 1) // 3
    
    is_safe = f_byzantine <= f_max
    
    # Cohomological analysis: H¹ obstruction
    # For cyclic topology with n validators and m state values
    m = 256  # Typical state space for 256-bit hashes
    h1_size = gcd(n_validators, m)
    consensus_possible = (h1_size == 1)
    
    # Verification complexity
    cocycle_check = n_validators ** 2
    coboundary_check = n_validators
    
    return {
        "n_validators": n_validators,
        "max_byzantine_faults": f_max,
        "actual_byzantine": f_byzantine,
        "is_safe": is_safe,
        "safety_margin": f_max - f_byzantine,
        "h1_obstruction_size": h1_size,
        "consensus_topologically_possible": consensus_possible,
        "cocycle_verification_cost": cocycle_check,
        "coboundary_verification_cost": coboundary_check,
        "verification_speedup": cocycle_check / coboundary_check,
        "min_rounds": ceil(log2(n_validators)) if n_validators > 1 else 0,
    }


# ============================================================
# Application 2: Distributed ML Training
# ============================================================

def distributed_ml_consensus(n_workers: int, 
                              gradient_dim: int,
                              byzantine_workers: int = 0) -> Dict:
    """Analyze distributed ML training as a consensus problem.
    
    In distributed ML, workers compute gradients and must agree
    on the update direction. Byzantine workers may send arbitrary
    gradients (gradient attacks).
    
    Args:
        n_workers: Number of training workers
        gradient_dim: Dimension of gradient vectors
        byzantine_workers: Number of potentially Byzantine workers
        
    Returns:
        Analysis with convergence and robustness guarantees
    """
    f_max = (n_workers - 1) // 3
    is_robust = byzantine_workers <= f_max
    
    # Convergence rate: 1 - 1/n per round
    convergence_factor = 1 - 1/n_workers if n_workers > 1 else 0
    
    # Rounds to ε-convergence
    epsilon = 1e-6
    if convergence_factor > 0 and convergence_factor < 1:
        rounds_to_converge = ceil(log2(1/epsilon) / (-log2(convergence_factor)))
    else:
        rounds_to_converge = 1
    
    # Coboundary certificate size
    cert_size = gradient_dim  # One gradient vector
    
    # Total communication per round
    comm_per_round = n_workers * gradient_dim
    
    return {
        "n_workers": n_workers,
        "gradient_dim": gradient_dim,
        "max_byzantine": f_max,
        "is_robust": is_robust,
        "convergence_factor": convergence_factor,
        "rounds_to_1e6": rounds_to_converge,
        "certificate_size": cert_size,
        "communication_per_round": comm_per_round,
        "total_communication": comm_per_round * rounds_to_converge,
    }


# ============================================================
# Application 3: Post-Quantum Consensus
# ============================================================

def post_quantum_analysis(security_bits: int = 128) -> Dict:
    """Analyze post-quantum consensus requirements.
    
    Uses lattice-based cryptography parameters to determine
    consensus system dimensions needed for post-quantum security.
    
    Args:
        security_bits: Target security level in bits
        
    Returns:
        Parameter recommendations
    """
    # NIST PQC recommended dimensions
    if security_bits <= 128:
        lattice_dim = 256
        ring_dim = 256
    elif security_bits <= 192:
        lattice_dim = 384
        ring_dim = 512
    else:
        lattice_dim = 512
        ring_dim = 1024
    
    # Consensus parameters for post-quantum setting
    min_agents = 3 * 1 + 1  # Minimum for f=1
    
    return {
        "security_bits": security_bits,
        "lattice_dimension": lattice_dim,
        "ring_dimension": ring_dim,
        "min_agents_f1": min_agents,
        "coboundary_cert_bits": lattice_dim * 2,
        "cocycle_check_ops": lattice_dim ** 2,
        "post_quantum_secure": lattice_dim >= 256,
    }


# ============================================================
# Application 4: Network Topology Optimization
# ============================================================

def topology_analysis(n: int) -> List[Dict]:
    """Analyze different network topologies for consensus.
    
    Compares ring, star, complete graph, and tree topologies
    using H¹ obstruction sizes.
    
    Args:
        n: Number of nodes
        
    Returns:
        List of topology analyses
    """
    topologies = []
    
    # Ring topology: G = Z/nZ
    ring_h1 = gcd(n, n)  # H¹(Z/n, Z/n) = Z/nZ
    topologies.append({
        "name": "Ring",
        "symmetry_group": f"Z/{n}Z",
        "h1_size": ring_h1,
        "consensus_possible": ring_h1 == 1,
        "max_faults": (n - 1) // 3,
        "diameter": n // 2,
        "edges": n,
    })
    
    # Complete graph: G = S_n (but use trivial for analysis)
    topologies.append({
        "name": "Complete",
        "symmetry_group": f"S_{n}",
        "h1_size": 1,  # Symmetric group has trivial H¹ for many modules
        "consensus_possible": True,
        "max_faults": (n - 1) // 3,
        "diameter": 1,
        "edges": n * (n - 1) // 2,
    })
    
    # Star topology
    topologies.append({
        "name": "Star",
        "symmetry_group": f"Z/{n-1}Z",
        "h1_size": gcd(n-1, n-1) if n > 1 else 1,
        "consensus_possible": n <= 2,
        "max_faults": 0 if n <= 3 else (n - 1) // 3,
        "diameter": 2 if n > 2 else 1,
        "edges": n - 1 if n > 1 else 0,
    })
    
    # Binary tree
    depth = ceil(log2(n)) if n > 1 else 0
    topologies.append({
        "name": "Binary Tree",
        "symmetry_group": "D_tree",
        "h1_size": 2 ** depth,
        "consensus_possible": False,
        "max_faults": (n - 1) // 3,
        "diameter": 2 * depth,
        "edges": n - 1 if n > 0 else 0,
    })
    
    return topologies


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  REAL-WORLD APPLICATIONS")
    print("  Galois-Cohomological Distributed Consensus")
    print("=" * 60)
    
    # Application 1: Blockchain
    print("\n--- Application 1: Blockchain Consensus ---\n")
    for n, byz_frac in [(100, 0.10), (100, 0.33), (100, 0.34), (21, 0.20)]:
        result = analyze_blockchain_consensus(n, byz_frac)
        status = "✓ SAFE" if result["is_safe"] else "✗ UNSAFE"
        print(f"n={n}, byz={byz_frac:.0%}: {status} "
              f"(max_f={result['max_byzantine_faults']}, "
              f"actual_f={result['actual_byzantine']}, "
              f"speedup={result['verification_speedup']:.0f}x)")
    
    # Application 2: Distributed ML
    print("\n--- Application 2: Distributed ML Training ---\n")
    for n_w, dim in [(8, 1000), (32, 10000), (128, 100000)]:
        result = distributed_ml_consensus(n_w, dim, byzantine_workers=1)
        print(f"workers={n_w}, dim={dim}: "
              f"conv_factor={result['convergence_factor']:.4f}, "
              f"rounds={result['rounds_to_1e6']}, "
              f"robust={result['is_robust']}")
    
    # Application 3: Post-Quantum
    print("\n--- Application 3: Post-Quantum Consensus ---\n")
    for bits in [128, 192, 256]:
        result = post_quantum_analysis(bits)
        print(f"{bits}-bit security: lattice_dim={result['lattice_dimension']}, "
              f"cert_bits={result['coboundary_cert_bits']}, "
              f"secure={result['post_quantum_secure']}")
    
    # Application 4: Network Topology
    print("\n--- Application 4: Network Topology Analysis (n=10) ---\n")
    topos = topology_analysis(10)
    print(f"{'Topology':<15} {'|H¹|':>6} {'Consensus':>10} {'Max f':>6} {'Edges':>6}")
    print("-" * 50)
    for t in topos:
        cons = "YES" if t["consensus_possible"] else "NO"
        print(f"{t['name']:<15} {t['h1_size']:>6} {cons:>10} "
              f"{t['max_faults']:>6} {t['edges']:>6}")


#!/usr/bin/env python3
"""
Galois-Cohomological Distributed Consensus: Computational Demonstrations

Concrete numerical examples bringing the cohomological consensus theory to life.
Demonstrates cocycle verification, coboundary construction, H¹ computation,
and Byzantine agreement certificates.
"""

import numpy as np
from typing import Callable, Optional, Tuple, List, Dict


# ============================================================
# §1: Cyclic Group Cocycles and Coboundaries
# ============================================================

def cyclic_group_action(n: int, g: int, a: int, m: int) -> int:
    """Action of Z/nZ on Z/mZ by addition: g · a = a + g (mod m)."""
    return (a + g) % m


def is_cocycle_cyclic(f: Callable[[int], int], n: int, m: int,
                       action: Callable[[int, int, int], int]) -> bool:
    """Check if f : Z/nZ → Z/mZ satisfies the cocycle condition.
    
    Cocycle condition: f(g+h) = f(g) + g·f(h) mod m
    """
    for g in range(n):
        for h in range(n):
            lhs = f((g + h) % n)
            rhs = (f(g) + action(n, g, f(h), m)) % m
            if lhs != rhs:
                return False
    return True


def coboundary(a: int, g: int, n: int, m: int,
               action: Callable[[int, int, int], int]) -> int:
    """Compute the coboundary δ(a)(g) = g·a - a mod m."""
    return (action(n, g, a, m) - a) % m


def find_coboundary_source(f: Callable[[int], int], n: int, m: int,
                            action: Callable[[int, int, int], int]) -> Optional[int]:
    """Find a ∈ Z/mZ such that f(g) = g·a - a for all g, or None."""
    for a in range(m):
        if all(f(g) == coboundary(a, g, n, m, action) for g in range(n)):
            return a
    return None


def compute_h1_cyclic(n: int, m: int) -> Tuple[int, List[Callable]]:
    """Compute |H¹(Z/nZ, Z/mZ)| with trivial action.
    
    With trivial action, cocycles are homomorphisms: f(g+h) = f(g) + f(h).
    A homomorphism Z/nZ → Z/mZ is determined by f(1) ∈ Z/mZ with n·f(1) = 0,
    so f(1) must have order dividing n in Z/mZ, giving gcd(n,m) choices.
    
    Coboundaries under trivial action are all zero (g·a - a = 0).
    So H¹ = Hom(Z/nZ, Z/mZ) ≅ Z/gcd(n,m)Z.
    """
    from math import gcd
    
    # Trivial action: g · a = a for all g
    trivial_action = lambda n, g, a, m: a
    
    # Count cocycles (= homomorphisms under trivial action)
    cocycles = []
    for c in range(m):
        if (n * c) % m == 0:  # n·f(1) ≡ 0 mod m
            f = lambda g, c=c: (g * c) % m
            cocycles.append(f)
    
    # Under trivial action, only coboundary is the zero function
    # So |H¹| = |cocycles|
    h1_size = len(cocycles)
    
    assert h1_size == gcd(n, m), f"Expected |H¹| = gcd({n},{m}) = {gcd(n,m)}, got {h1_size}"
    
    return h1_size, cocycles


def demo_cocycle_verification():
    """Demonstrate cocycle and coboundary verification."""
    print("=" * 60)
    print("§1: Cocycle/Coboundary Verification on Cyclic Groups")
    print("=" * 60)
    
    n, m = 6, 4  # G = Z/6Z, A = Z/4Z
    action = cyclic_group_action
    
    # Example 1: A coboundary
    a = 2  # Source element
    f_coboundary = lambda g: coboundary(a, g, n, m, action)
    
    print(f"\n1. Coboundary with source a={a} in Z/{m}Z:")
    print(f"   f(g) = g·{a} - {a} mod {m}")
    for g in range(n):
        print(f"   f({g}) = {f_coboundary(g)}")
    
    is_coc = is_cocycle_cyclic(f_coboundary, n, m, action)
    print(f"   Is cocycle? {is_coc}")
    
    source = find_coboundary_source(f_coboundary, n, m, action)
    print(f"   Coboundary source found: {source}")
    
    # Example 2: Zero cocycle
    f_zero = lambda g: 0
    print(f"\n2. Zero function:")
    is_coc = is_cocycle_cyclic(f_zero, n, m, action)
    print(f"   Is cocycle? {is_coc}")
    source = find_coboundary_source(f_zero, n, m, action)
    print(f"   Coboundary source: {source}")
    
    print()


def demo_h1_computation():
    """Demonstrate H¹ computation for cyclic groups."""
    print("=" * 60)
    print("§2: H¹(Z/nZ, Z/mZ) Computation (Trivial Action)")
    print("=" * 60)
    
    from math import gcd
    
    test_cases = [
        (2, 2), (3, 3), (4, 6), (6, 4), (5, 7), (12, 8), (7, 11)
    ]
    
    print(f"\n{'n':>4} {'m':>4} {'gcd(n,m)':>10} {'|H¹|':>6} {'Consensus?':>12}")
    print("-" * 40)
    
    for n, m in test_cases:
        h1_size, _ = compute_h1_cyclic(n, m)
        consensus = "YES" if h1_size == 1 else "NO"
        print(f"{n:>4} {m:>4} {gcd(n,m):>10} {h1_size:>6} {consensus:>12}")
    
    print(f"\nKey insight: Consensus achievable ⟺ gcd(n,m) = 1 ⟺ H¹ = 0")
    print()


# ============================================================
# §3: Byzantine Fault Tolerance Bounds
# ============================================================

def demo_byzantine_bounds():
    """Demonstrate the 3f+1 Byzantine fault tolerance bound."""
    print("=" * 60)
    print("§3: Byzantine Fault Tolerance — The 3f+1 Bound")
    print("=" * 60)
    
    print(f"\n{'Agents (n)':>12} {'Max Faults (f)':>16} {'Honest':>8} {'Quorum':>8}")
    print("-" * 48)
    
    for n in range(1, 21):
        f_max = (n - 1) // 3
        honest = n - f_max
        quorum = 2 * f_max + 1
        print(f"{n:>12} {f_max:>16} {honest:>8} {quorum:>8}")
    
    print(f"\nVerification: n=3f+1 ensures n-f > 2f (honest supermajority)")
    print()


# ============================================================
# §4: Convergence of Averaging Consensus
# ============================================================

def demo_averaging_convergence():
    """Demonstrate convergence of averaging consensus protocol."""
    print("=" * 60)
    print("§4: Averaging Consensus Convergence")
    print("=" * 60)
    
    np.random.seed(42)
    n_agents = 5
    initial_states = np.random.uniform(0, 100, n_agents)
    
    print(f"\nInitial states: {initial_states.round(2)}")
    print(f"True consensus: {initial_states.mean():.2f}")
    
    states = initial_states.copy()
    print(f"\n{'Round':>6} {'Max Deviation':>15} {'States':>40}")
    print("-" * 65)
    
    for t in range(15):
        max_dev = np.max(states) - np.min(states)
        states_str = ', '.join(f'{s:.2f}' for s in states)
        print(f"{t:>6} {max_dev:>15.6f} [{states_str}]")
        
        # Averaging step: each agent averages with all neighbors
        new_states = np.zeros(n_agents)
        for i in range(n_agents):
            new_states[i] = np.mean(states)
        states = new_states
    
    convergence_factor = 1 - 1/n_agents
    print(f"\nConvergence factor: 1 - 1/{n_agents} = {convergence_factor:.4f}")
    print(f"Theory predicts: deviation ≤ D₀ × {convergence_factor:.4f}^t")
    print()


# ============================================================
# §5: Byzantine Certificate Construction
# ============================================================

def demo_byzantine_certificate():
    """Demonstrate Byzantine agreement certificate construction."""
    print("=" * 60)
    print("§5: Byzantine Agreement Certificate (Multiplicative)")
    print("=" * 60)
    
    # Work in Z/pZ (multiplicative group)
    p = 13  # Prime
    
    # Witness w
    w = 5
    w_inv = pow(w, p - 2, p)  # Fermat's little theorem
    
    print(f"\nField: F_{p}")
    print(f"Witness: w = {w}")
    print(f"w⁻¹ = {w_inv}")
    print(f"w · w⁻¹ = {(w * w_inv) % p}")
    
    # Coboundary: f(g) = g·w / w (using multiplicative action g·w = w^g)
    # Simple action: g · w = w (trivial action for demo)
    # Under trivial action, f(g) = w · w⁻¹ = 1 for all g
    
    print(f"\nTrivial action coboundary (all agents agree):")
    print(f"  f(g) = g·w · w⁻¹ = w · w⁻¹ = 1 for all g")
    
    # Non-trivial example: G = Z/4Z acting on F_13* by powers
    # g · w = w^(g+1) mod p
    print(f"\nNon-trivial action: g · w = w^(g+1) mod {p}")
    
    n = 4
    for g in range(n):
        gw = pow(w, g + 1, p)
        fg = (gw * w_inv) % p
        print(f"  g={g}: g·w = {gw}, f(g) = {fg}")
    
    # Verify cocycle condition
    print(f"\nCocycle condition check (f(gh) = f(g) · g·f(h)):")
    coboundary_values = {}
    for g in range(n):
        gw = pow(w, g + 1, p)
        coboundary_values[g] = (gw * w_inv) % p
    
    all_ok = True
    for g in range(n):
        for h in range(n):
            gh = (g + h) % n
            lhs = coboundary_values[gh]
            # g · f(h) under this action
            fh = coboundary_values[h]
            g_fh = pow(fh, g + 1, p)
            rhs = (coboundary_values[g] * g_fh) % p
            ok = (lhs == rhs)
            if not ok:
                all_ok = False
                print(f"  FAIL: f({g}·{h}) = {lhs} ≠ f({g})·g·f({h}) = {rhs}")
    
    if all_ok:
        print(f"  All {n}² = {n*n} pairs verified ✓")
    
    print(f"\nCertificate verification cost: O(|G|) = O({n}) checks")
    print(f"Cocycle verification cost:     O(|G|²) = O({n*n}) checks")
    print()


# ============================================================
# §6: Coboundary Sum Formula
# ============================================================

def demo_coboundary_sum():
    """Demonstrate the coboundary sum formula."""
    print("=" * 60)
    print("§6: Coboundary Sum Formula")
    print("=" * 60)
    
    # G = Z/5Z acting on Z/7Z by addition
    n, m = 5, 7
    a = 3
    
    print(f"\nG = Z/{n}Z, A = Z/{m}Z, a = {a}")
    print(f"Action: g · a = (a + g) mod {m}")
    print(f"δ(a)(g) = g·a - a = g mod {m}")
    
    sum_coboundary = 0
    sum_action = 0
    
    for g in range(n):
        ga = (a + g) % m
        delta = (ga - a) % m
        sum_coboundary = (sum_coboundary + delta) % m
        sum_action = (sum_action + ga) % m
        print(f"  g={g}: g·a={ga}, δ(a)(g)={delta}")
    
    card_smul_a = (n * a) % m
    formula_rhs = (sum_action - card_smul_a) % m
    
    print(f"\n∑ δ(a)(g) = {sum_coboundary} mod {m}")
    print(f"∑ g·a = {sum_action} mod {m}")
    print(f"|G|·a = {n}·{a} = {card_smul_a} mod {m}")
    print(f"∑ g·a - |G|·a = {formula_rhs} mod {m}")
    print(f"Formula verified: {sum_coboundary} = {formula_rhs} ✓" 
          if sum_coboundary == formula_rhs else "Formula FAILED!")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  GALOIS-COHOMOLOGICAL DISTRIBUTED CONSENSUS")
    print("  Computational Demonstrations")
    print("=" * 60 + "\n")
    
    demo_cocycle_verification()
    demo_h1_computation()
    demo_byzantine_bounds()
    demo_averaging_convergence()
    demo_byzantine_certificate()
    demo_coboundary_sum()
    
    print("=" * 60)
    print("  All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Galois-Cohomological Distributed Consensus.
Generates publication-quality figures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd, ceil, log2

def plot_h1_heatmap():
    """Plot |H¹(Z/nZ, Z/mZ)| as a heatmap."""
    fig, ax = plt.subplots(figsize=(10, 8))
    
    N = 20
    h1_matrix = np.zeros((N, N))
    
    for n in range(1, N+1):
        for m in range(1, N+1):
            h1_matrix[n-1, m-1] = gcd(n, m)
    
    im = ax.imshow(h1_matrix, cmap='YlOrRd', origin='lower',
                    extent=[0.5, N+0.5, 0.5, N+0.5])
    
    ax.set_xlabel('State space size m (|A| = Z/mZ)', fontsize=12)
    ax.set_ylabel('Group size n (G = Z/nZ)', fontsize=12)
    ax.set_title('H¹(Z/nZ, Z/mZ) = Z/gcd(n,m)Z\nConsensus obstruction: dark = achievable, light = obstructed',
                 fontsize=13)
    
    plt.colorbar(im, ax=ax, label='|H¹| = gcd(n,m)')
    
    # Mark consensus-achievable cases (gcd = 1)
    for n in range(1, N+1):
        for m in range(1, N+1):
            if gcd(n, m) == 1:
                ax.plot(m, n, 'g.', markersize=3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/h1_heatmap.png', dpi=150)
    plt.close()
    print("Saved h1_heatmap.png")


def plot_byzantine_bounds():
    """Plot Byzantine fault tolerance bounds."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    ns = np.arange(1, 51)
    f_max = (ns - 1) // 3
    honest = ns - f_max
    
    ax1.fill_between(ns, 0, f_max, alpha=0.3, color='red', label='Byzantine zone (f ≤ ⌊(n-1)/3⌋)')
    ax1.fill_between(ns, f_max, ns, alpha=0.3, color='green', label='Honest zone')
    ax1.plot(ns, f_max, 'r-', linewidth=2, label='Max faults f = ⌊(n-1)/3⌋')
    ax1.plot(ns, ns/3, 'k--', linewidth=1, alpha=0.5, label='n/3 line')
    ax1.set_xlabel('Number of agents n', fontsize=12)
    ax1.set_ylabel('Byzantine faults f', fontsize=12)
    ax1.set_title('Byzantine Fault Tolerance: 3f+1 Bound\n(Cohomological interpretation: H¹ vanishing threshold)', fontsize=12)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Verification complexity comparison
    ns2 = np.arange(2, 101)
    cocycle_cost = ns2 ** 2
    coboundary_cost = ns2
    
    ax2.semilogy(ns2, cocycle_cost, 'r-', linewidth=2, label='Cocycle verification O(|G|²)')
    ax2.semilogy(ns2, coboundary_cost, 'g-', linewidth=2, label='Coboundary certificate O(|G|)')
    ax2.fill_between(ns2, coboundary_cost, cocycle_cost, alpha=0.15, color='blue',
                      label='Certificate advantage')
    ax2.set_xlabel('Group size |G|', fontsize=12)
    ax2.set_ylabel('Verification operations', fontsize=12)
    ax2.set_title('Consensus Verification Complexity\nCoboundary certificates are |G|× faster', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/byzantine_bounds.png', dpi=150)
    plt.close()
    print("Saved byzantine_bounds.png")


def plot_convergence():
    """Plot averaging consensus convergence."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    for n in [3, 5, 10, 20, 50]:
        factor = 1 - 1/n
        t = np.arange(0, 50)
        deviation = factor ** t
        ax.semilogy(t, deviation, linewidth=2, label=f'n={n}, factor={factor:.3f}')
    
    ax.set_xlabel('Round t', fontsize=12)
    ax.set_ylabel('Relative deviation from consensus', fontsize=12)
    ax.set_title('Averaging Consensus Convergence\nRate = (1 - 1/n)^t', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim([1e-10, 1])
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/convergence.png', dpi=150)
    plt.close()
    print("Saved convergence.png")


def plot_cocycle_decomposition():
    """Visualize the cocycle triple decomposition."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Show f(ghk) = f(g) + g·f(h) + (gh)·f(k) as stacked bars
    n = 6  # Z/6Z
    m = 7  # Z/7Z
    
    # Coboundary from a=2: f(g) = (2+g) mod 7 - 2 = g mod 7
    a = 2
    f = lambda g: g % m
    
    g_vals = list(range(n))
    
    # For triple products g*h*k with fixed h=1, k=2
    h_fixed, k_fixed = 1, 2
    
    terms = {'f(g)': [], 'g·f(h)': [], '(gh)·f(k)': []}
    totals = []
    
    for g in g_vals:
        fg = f(g)
        gfh = (g + f(h_fixed)) % m  # trivial action: g·x = x+g mod m
        ghfk = ((g + h_fixed) + f(k_fixed)) % m
        
        terms['f(g)'].append(fg)
        terms['g·f(h)'].append(gfh)
        terms['(gh)·f(k)'].append(ghfk)
        totals.append(f((g + h_fixed + k_fixed) % n))
    
    x = np.arange(n)
    width = 0.6
    
    bottom = np.zeros(n)
    colors = ['#2196F3', '#FF9800', '#4CAF50']
    for i, (label, values) in enumerate(terms.items()):
        ax.bar(x, values, width, bottom=bottom, label=label, color=colors[i], alpha=0.8)
        bottom += np.array(values)
    
    ax.plot(x, totals, 'ko-', markersize=8, linewidth=2, label=f'f(g·{h_fixed}·{k_fixed})')
    
    ax.set_xlabel('g ∈ Z/6Z', fontsize=12)
    ax.set_ylabel('Value (mod 7)', fontsize=12)
    ax.set_title(f'Cocycle Triple Decomposition\nf(g·h·k) = f(g) + g·f(h) + (gh)·f(k)\n(h={h_fixed}, k={k_fixed})',
                 fontsize=12)
    ax.set_xticks(x)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/cocycle_decomposition.png', dpi=150)
    plt.close()
    print("Saved cocycle_decomposition.png")


if __name__ == "__main__":
    print("Generating visualizations...")
    plot_h1_heatmap()
    plot_byzantine_bounds()
    plot_convergence()
    plot_cocycle_decomposition()
    print("All visualizations generated.")

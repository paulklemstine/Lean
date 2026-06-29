"""
Topos-Theoretic Machine Learning: Algorithms

Implements core algorithms for VC dimension computation, sample complexity
estimation, transfer learning bounds, and sieve lattice operations.
"""

import math
from dataclasses import dataclass
from typing import Set, FrozenSet, List, Optional, Callable, Dict
import itertools


@dataclass
class ConceptFamily:
    """A family of subsets representing a hypothesis class."""
    concepts: List[FrozenSet[int]]
    
    def shatters(self, S: FrozenSet[int]) -> bool:
        """Check if this concept family shatters S."""
        S_set = set(S)
        for r in range(len(S) + 1):
            for T_tuple in itertools.combinations(S, r):
                T = set(T_tuple)
                found = any(
                    set(c).intersection(S_set) == T 
                    for c in self.concepts
                )
                if not found:
                    return False
        return True
    
    def vc_dimension(self, universe: FrozenSet[int]) -> int:
        """Compute VC dimension by exhaustive search.
        
        Time complexity: O(|universe|^d * 2^d * |concepts|)
        Space complexity: O(|concepts|)
        
        Only feasible for small universes (|universe| ≤ 20).
        """
        max_d = 0
        for size in range(len(universe) + 1):
            found = False
            for S_tuple in itertools.combinations(universe, size):
                S = frozenset(S_tuple)
                if self.shatters(S):
                    found = True
                    max_d = size
                    break
            if not found:
                break
        return max_d
    
    def growth_function(self, S: FrozenSet[int]) -> int:
        """Count distinct restrictions of concepts to S.
        
        Returns |{c ∩ S : c ∈ concepts}|.
        """
        restrictions = set()
        S_set = set(S)
        for c in self.concepts:
            restriction = frozenset(set(c).intersection(S_set))
            restrictions.add(restriction)
        return len(restrictions)


@dataclass  
class TransferMorphism:
    """A structure-preserving map between concept families."""
    source: ConceptFamily
    target: ConceptFamily
    point_map: Callable[[int], int]
    lipschitz_const: float
    
    def transfer(self) -> ConceptFamily:
        """Apply transfer: pull back target concepts to source domain."""
        transferred = []
        for c in self.target.concepts:
            preimage = frozenset(
                x for x in range(100)  # universe bound
                if self.point_map(x) in c
            )
            transferred.append(preimage)
        return ConceptFamily(transferred)
    
    @staticmethod
    def compose(f: 'TransferMorphism', g: 'TransferMorphism') -> 'TransferMorphism':
        """Compose two transfer morphisms."""
        return TransferMorphism(
            source=f.source,
            target=g.target,
            point_map=lambda x: g.point_map(f.point_map(x)),
            lipschitz_const=f.lipschitz_const * g.lipschitz_const
        )


@dataclass
class Sieve:
    """A sieve on object d: downward-closed subset of ↓d."""
    carrier: FrozenSet[int]
    target: int  # d
    
    def __le__(self, other: 'Sieve') -> bool:
        return self.carrier.issubset(other.carrier)
    
    @staticmethod
    def empty(d: int) -> 'Sieve':
        return Sieve(frozenset(), d)
    
    @staticmethod
    def maximal(d: int, preorder: Dict[int, Set[int]]) -> 'Sieve':
        """Maximal sieve: all elements ≤ d."""
        below = {x for x in preorder if x in preorder.get(d, set()) or x == d}
        return Sieve(frozenset(below), d)
    
    def meet(self, other: 'Sieve') -> 'Sieve':
        """Sieve intersection."""
        return Sieve(self.carrier & other.carrier, self.target)
    
    def join(self, other: 'Sieve') -> 'Sieve':
        """Sieve union."""
        return Sieve(self.carrier | other.carrier, self.target)


def sauer_shelah_bound(m: int, d: int) -> int:
    """Sauer-Shelah bound: Σ_{i=0}^{d} C(m, i)."""
    return sum(math.comb(m, i) for i in range(d + 1))


def sample_complexity(d: int, epsilon: float, delta: float) -> float:
    """PAC learning sample complexity: 37d/ε² · log(1/δ)."""
    return 37 * d / epsilon**2 * math.log(1 / delta)


def transfer_sample_complexity(d: int, epsilon: float, delta: float,
                                lipschitz: float) -> float:
    """Sample complexity after L-Lipschitz transfer."""
    return lipschitz**2 * sample_complexity(d, epsilon, delta)


def chain_transfer_complexity(d: int, epsilon: float, delta: float,
                               lipschitz: float, n_hops: int) -> float:
    """Sample complexity after n-hop chain with constant L."""
    return lipschitz**(2 * n_hops) * sample_complexity(d, epsilon, delta)


def verify_frame_distributivity(s1: Sieve, s2: Sieve, s3: Sieve) -> bool:
    """Verify: s1 ∩ (s2 ∪ s3) = (s1 ∩ s2) ∪ (s1 ∩ s3)."""
    lhs = s1.meet(s2.join(s3))
    rhs = s1.meet(s2).join(s1.meet(s3))
    return lhs.carrier == rhs.carrier


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    # Create interval concept family on {0, 1, ..., 5}
    intervals = []
    for a in range(6):
        for b in range(a, 6):
            intervals.append(frozenset(range(a, b + 1)))
    intervals.append(frozenset())
    
    C = ConceptFamily(intervals)
    universe = frozenset(range(6))
    
    print(f"Interval concept family on {{0,...,5}}")
    print(f"  Number of concepts: {len(C.concepts)}")
    print(f"  VC dimension: {C.vc_dimension(universe)}")
    print()
    
    # Growth function
    for m in range(1, 7):
        for S_tuple in itertools.combinations(range(6), m):
            S = frozenset(S_tuple)
            gf = C.growth_function(S)
            sb = sauer_shelah_bound(m, 2)
            print(f"  |S|={m}: growth={gf}, Sauer-Shelah(m,2)={sb}, "
                  f"{'OK' if gf <= sb else 'VIOLATION!'}")
            break
    
    print()
    
    # Sieve frame distributivity
    s1 = Sieve(frozenset({0, 1, 2}), 5)
    s2 = Sieve(frozenset({1, 2, 3}), 5)
    s3 = Sieve(frozenset({2, 3, 4}), 5)
    
    print(f"Frame distributivity check:")
    print(f"  s1 = {set(s1.carrier)}")
    print(f"  s2 = {set(s2.carrier)}")
    print(f"  s3 = {set(s3.carrier)}")
    print(f"  Distributivity holds: {verify_frame_distributivity(s1, s2, s3)}")
    
    print()
    
    # Sample complexity
    for d in [1, 5, 10, 50]:
        sc = sample_complexity(d, 0.1, 0.05)
        print(f"  d={d:>3}: sample_complexity(ε=0.1, δ=0.05) = {sc:.0f}")
    
    print()
    
    # Transfer chain
    for n in range(6):
        tc = chain_transfer_complexity(10, 0.1, 0.05, 2.0, n)
        print(f"  {n} hops (L=2): inflation={4**n:>8}x, samples={tc:.0f}")


"""
Topos-Theoretic Machine Learning: Applications

Real-world applications of the topos-theoretic framework to:
1. ML: Certified robustness bounds for neural networks
2. Cryptography: Post-quantum security analysis
3. Transfer learning: Domain adaptation guarantees
"""

import math
from typing import List, Tuple


def certified_robustness_bound(vc_dim: int, epsilon: float, delta: float,
                                lipschitz_layers: List[float]) -> dict:
    """Compute certified robustness bound for a neural network.
    
    A neural network with L layers, each having Lipschitz constant L_i,
    has total Lipschitz constant L = ∏ L_i. Transfer through this network
    inflates sample complexity by L².
    
    Args:
        vc_dim: VC dimension of the concept class
        epsilon: Desired accuracy
        delta: Confidence parameter
        lipschitz_layers: Lipschitz constant of each layer
    
    Returns:
        Dictionary with bounds and analysis
    """
    total_lipschitz = math.prod(lipschitz_layers)
    base_complexity = 37 * vc_dim / epsilon**2 * math.log(1 / delta)
    transferred_complexity = total_lipschitz**2 * base_complexity
    
    return {
        "vc_dimension": vc_dim,
        "num_layers": len(lipschitz_layers),
        "layer_lipschitz": lipschitz_layers,
        "total_lipschitz": total_lipschitz,
        "base_sample_complexity": base_complexity,
        "certified_sample_complexity": transferred_complexity,
        "inflation_factor": total_lipschitz**2,
        "effective_epsilon": epsilon / total_lipschitz,
    }


def post_quantum_hardness_analysis(vc_dim: int, security_parameter: int) -> dict:
    """Analyze post-quantum cryptographic hardness from VC dimension.
    
    If a concept class has VC dimension d, then:
    - It requires Ω(d) samples to learn
    - Shattering d points gives 2^d possible labelings
    - This connects to lattice-based crypto with parameter n ≈ d
    
    Args:
        vc_dim: VC dimension (= compact subobject rank)
        security_parameter: Desired security level in bits
    
    Returns:
        Dictionary with hardness analysis
    """
    shattering_count = 2**vc_dim
    min_samples = vc_dim
    
    # LWE connection: security ≈ 2^(n/log(q)) where n ≈ vc_dim
    log_q = max(1, math.log2(vc_dim + 1))
    estimated_security = vc_dim / log_q
    
    return {
        "vc_dimension": vc_dim,
        "shattering_count": shattering_count,
        "min_samples_to_learn": min_samples,
        "estimated_security_bits": estimated_security,
        "target_security": security_parameter,
        "sufficient": estimated_security >= security_parameter,
        "recommended_vc_dim": int(security_parameter * log_q) + 1,
    }


def domain_adaptation_guarantee(source_vc: int, target_vc: int,
                                 lipschitz: float,
                                 epsilon: float, delta: float) -> dict:
    """Compute domain adaptation guarantees.
    
    Transfer from source domain to target domain through a geometric
    morphism with Lipschitz constant L.
    
    Args:
        source_vc: VC dimension of source concept class
        target_vc: VC dimension of target concept class
        lipschitz: Lipschitz constant of the domain morphism
        epsilon: Desired accuracy in target domain
        delta: Confidence parameter
    
    Returns:
        Dictionary with adaptation guarantees
    """
    source_complexity = 37 * source_vc / epsilon**2 * math.log(1 / delta)
    target_complexity = 37 * target_vc / (epsilon / lipschitz)**2 * math.log(1 / delta)
    
    return {
        "source_vc_dimension": source_vc,
        "target_vc_dimension": target_vc,
        "lipschitz_constant": lipschitz,
        "source_sample_complexity": source_complexity,
        "target_sample_complexity": target_complexity,
        "inflation_factor": lipschitz**2,
        "effective_target_epsilon": epsilon / lipschitz,
        "transfer_feasible": target_complexity < 1e9,
    }


# ============================================================
# Application 1: Neural Network Certified Robustness
# ============================================================
print("=" * 60)
print("APPLICATION 1: Neural Network Certified Robustness")
print("=" * 60)
print()

# 5-layer network with varying Lipschitz constants
for layers in [[1.5, 1.3, 1.2, 1.1, 1.0],
               [2.0, 2.0, 2.0],
               [1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1]]:
    result = certified_robustness_bound(
        vc_dim=20, epsilon=0.05, delta=0.01, lipschitz_layers=layers
    )
    print(f"Network: {len(layers)} layers, Lipschitz = {result['total_lipschitz']:.2f}")
    print(f"  Base samples:      {result['base_sample_complexity']:>12.0f}")
    print(f"  Certified samples: {result['certified_sample_complexity']:>12.0f}")
    print(f"  Inflation:         {result['inflation_factor']:>12.1f}x")
    print(f"  Effective ε:       {result['effective_epsilon']:.4f}")
    print()

# ============================================================
# Application 2: Post-Quantum Security Analysis
# ============================================================
print("=" * 60)
print("APPLICATION 2: Post-Quantum Security Analysis")
print("=" * 60)
print()

for sec_param in [128, 192, 256]:
    result = post_quantum_hardness_analysis(vc_dim=sec_param, security_parameter=sec_param)
    print(f"Target security: {sec_param} bits")
    print(f"  VC dimension:        {result['vc_dimension']}")
    print(f"  Shattering count:    2^{result['vc_dimension']}")
    print(f"  Estimated security:  {result['estimated_security_bits']:.1f} bits")
    print(f"  Recommended vc_dim:  {result['recommended_vc_dim']}")
    print()

# ============================================================
# Application 3: Domain Adaptation
# ============================================================
print("=" * 60)
print("APPLICATION 3: Domain Adaptation Guarantees")
print("=" * 60)
print()

scenarios = [
    ("Photos → X-rays", 15, 20, 2.5),
    ("English → French", 50, 45, 1.8),
    ("Simulation → Reality", 10, 10, 3.0),
    ("Day → Night (same domain)", 10, 10, 1.2),
]

for name, src_vc, tgt_vc, lip in scenarios:
    result = domain_adaptation_guarantee(
        source_vc=src_vc, target_vc=tgt_vc,
        lipschitz=lip, epsilon=0.1, delta=0.05
    )
    print(f"Transfer: {name}")
    print(f"  Source VC: {src_vc}, Target VC: {tgt_vc}, L: {lip}")
    print(f"  Source samples: {result['source_sample_complexity']:>10.0f}")
    print(f"  Target samples: {result['target_sample_complexity']:>10.0f}")
    print(f"  Inflation: {result['inflation_factor']:.1f}x")
    print(f"  Feasible: {result['transfer_feasible']}")
    print()

print("=" * 60)
print("All applications complete.")
print("=" * 60)


"""
Topos-Theoretic Machine Learning: Numerical Demonstrations

Demonstrates the key mathematical results connecting VC dimension,
sample complexity, transfer learning, and sieve structures.
"""

import math
from typing import List, Tuple
import itertools


def sauer_shelah_bound(m: int, d: int) -> int:
    """Compute the Sauer-Shelah bound: sum of C(m, i) for i = 0..d.
    
    This bounds the growth function of any concept family with VC dimension d.
    For d <= m, this is polynomial in m (degree d).
    """
    return sum(math.comb(m, i) for i in range(d + 1))


def sample_complexity_bound(d: int, epsilon: float, delta: float) -> float:
    """Compute the PAC learning sample complexity bound.
    
    m(ε, δ) = 37 * d / ε² * log(1/δ)
    
    Args:
        d: VC dimension
        epsilon: Error tolerance (0 < ε < 1)
        delta: Confidence parameter (0 < δ < 1)
    
    Returns:
        Upper bound on required sample size
    """
    if epsilon <= 0 or delta <= 0 or delta >= 1:
        raise ValueError("Need 0 < epsilon and 0 < delta < 1")
    return 37 * d / epsilon**2 * math.log(1 / delta)


def transfer_complexity(d: int, epsilon: float, delta: float, 
                        lipschitz: float) -> float:
    """Sample complexity after Lipschitz-L transfer.
    
    Transfers through a morphism with Lipschitz constant L,
    inflating sample complexity by L².
    
    m_transfer = L² * m_base
    """
    return lipschitz**2 * sample_complexity_bound(d, epsilon, delta)


def chain_transfer_complexity(d: int, epsilon: float, delta: float,
                              lipschitz: float, n_hops: int) -> float:
    """Sample complexity after n-hop transfer chain.
    
    Each hop has Lipschitz constant L, total inflation = L^(2n).
    """
    return lipschitz**(2 * n_hops) * sample_complexity_bound(d, epsilon, delta)


def is_shattered(concepts: List[set], S: set) -> bool:
    """Check if a concept family shatters a set S.
    
    S is shattered if every subset T ⊆ S can be realized as c ∩ S
    for some concept c in the family.
    """
    for subset in itertools.chain.from_iterable(
        itertools.combinations(S, r) for r in range(len(S) + 1)):
        T = set(subset)
        found = False
        for c in concepts:
            if c.intersection(S) == T:
                found = True
                break
        if not found:
            return False
    return True


def compute_vc_dimension(concepts: List[set], universe: set) -> int:
    """Compute the VC dimension of a concept family by exhaustive search.
    
    Finds the largest subset of universe that is shattered by concepts.
    Exponential time - only for small examples!
    """
    max_shattered = 0
    for size in range(len(universe) + 1):
        found = False
        for S in itertools.combinations(universe, size):
            if is_shattered(concepts, set(S)):
                found = True
                max_shattered = size
                break
        if not found and size > max_shattered:
            break
    return max_shattered


# ============================================================
# DEMO 1: Sauer-Shelah Growth Function
# ============================================================
print("=" * 60)
print("DEMO 1: Sauer-Shelah Growth Function")
print("=" * 60)
print()
print("The growth function Π(m, d) = Σ_{i=0}^{d} C(m, i)")
print("bounds the number of distinct labelings on m points")
print("for a concept family with VC dimension d.")
print()

print(f"{'m':>4} | {'d=0':>6} | {'d=1':>6} | {'d=2':>6} | {'d=3':>6} | {'d=4':>8} | {'2^m':>10}")
print("-" * 60)
for m in [3, 5, 8, 10, 15, 20]:
    row = f"{m:>4} |"
    for d in range(5):
        row += f" {sauer_shelah_bound(m, d):>6} |"
    row += f" {2**m:>10}"
    print(row)

print()
print("Key observation: for d << m, growth is polynomial O(m^d),")
print("much smaller than the exponential 2^m.")

# ============================================================
# DEMO 2: Sample Complexity Bounds
# ============================================================
print()
print("=" * 60)
print("DEMO 2: Sample Complexity Bounds")
print("=" * 60)
print()
print("m(ε, δ) = 37 * d / ε² * log(1/δ)")
print()

print(f"{'d':>4} | {'ε=0.1, δ=0.05':>16} | {'ε=0.05, δ=0.05':>16} | {'ε=0.01, δ=0.01':>16}")
print("-" * 60)
for d in [1, 2, 5, 10, 20, 50, 100]:
    m1 = sample_complexity_bound(d, 0.1, 0.05)
    m2 = sample_complexity_bound(d, 0.05, 0.05)
    m3 = sample_complexity_bound(d, 0.01, 0.01)
    print(f"{d:>4} | {m1:>16.0f} | {m2:>16.0f} | {m3:>16.0f}")

print()
print("Sample complexity grows linearly in d, quadratically in 1/ε.")

# ============================================================
# DEMO 3: Transfer Learning Inflation
# ============================================================
print()
print("=" * 60)
print("DEMO 3: Transfer Learning Inflation")
print("=" * 60)
print()
print("Transfer with Lipschitz constant L inflates by L².")
print("Base: d=10, ε=0.1, δ=0.05")
print()

base = sample_complexity_bound(10, 0.1, 0.05)
print(f"{'L':>6} | {'L²':>8} | {'Transferred':>14} | {'Base':>14}")
print("-" * 50)
for L in [1.0, 1.5, 2.0, 3.0, 5.0, 10.0]:
    transferred = transfer_complexity(10, 0.1, 0.05, L)
    print(f"{L:>6.1f} | {L**2:>8.1f} | {transferred:>14.0f} | {base:>14.0f}")

# ============================================================
# DEMO 4: Multi-Hop Transfer Chain
# ============================================================
print()
print("=" * 60)
print("DEMO 4: Multi-Hop Transfer Chain")
print("=" * 60)
print()
print("Chaining n hops with L=2 each: inflation = 2^(2n) = 4^n")
print("Base: d=10, ε=0.1, δ=0.05")
print()

print(f"{'n hops':>8} | {'4^n':>10} | {'Samples needed':>16}")
print("-" * 40)
for n in range(8):
    samples = chain_transfer_complexity(10, 0.1, 0.05, 2.0, n)
    print(f"{n:>8} | {4**n:>10} | {samples:>16.0f}")

print()
print("Exponential blowup: 7 transfers need 16,384x more samples!")

# ============================================================
# DEMO 5: VC Dimension Computation
# ============================================================
print()
print("=" * 60)
print("DEMO 5: VC Dimension Computation")
print("=" * 60)
print()

# Intervals on {1, 2, ..., 6}
universe = {1, 2, 3, 4, 5, 6}
intervals = []
for a in range(1, 7):
    for b in range(a, 7):
        intervals.append(set(range(a, b + 1)))
intervals.append(set())  # empty interval

print(f"Universe: {sorted(universe)}")
print(f"Concept family: intervals [a, b] on {{1,...,6}}")
print(f"Number of concepts: {len(intervals)}")
vc = compute_vc_dimension(intervals, universe)
print(f"VC dimension: {vc}")
print()

# Power set
powerset = [set(s) for r in range(len(universe) + 1) 
            for s in itertools.combinations(universe, r)]
print(f"Power set concept family: all subsets")
print(f"Number of concepts: {len(powerset)}")
vc_pow = compute_vc_dimension(powerset, universe)
print(f"VC dimension: {vc_pow} (= |universe| = {len(universe)})")
print()

# Singleton family
print("Singleton family (only ∅):")
vc_single = compute_vc_dimension([set()], universe)
print(f"VC dimension: {vc_single}")

# ============================================================
# DEMO 6: Entanglement / Shattering Count
# ============================================================
print()
print("=" * 60)
print("DEMO 6: Quantum Entanglement ↔ Shattering")
print("=" * 60)
print()
print("Shattering k points requires 2^k concept restrictions.")
print("This equals the number of basis states in k-qubit system.")
print()

print(f"{'k':>4} | {'2^k labelings':>14} | {'Basis states':>14}")
print("-" * 40)
for k in range(1, 11):
    print(f"{k:>4} | {2**k:>14} | {2**k:>14}")

print()
print("Shattering IS quantum entanglement, viewed through learning theory.")
print()
print("=" * 60)
print("All demos complete.")
print("=" * 60)


"""
Topos-Theoretic Machine Learning: Visualizations

Generates plots showing key mathematical structures:
1. Sauer-Shelah growth function
2. Sample complexity scaling
3. Transfer inflation
4. Sieve lattice structure
"""

import math
import os

# Use Agg backend for non-interactive plotting
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

output_dir = os.path.dirname(os.path.abspath(__file__))


def plot_sauer_shelah():
    """Plot Sauer-Shelah growth function for various d."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    ms = np.arange(1, 25)
    
    for d in [1, 2, 3, 4, 5]:
        vals = [sum(math.comb(int(m), i) for i in range(d + 1)) for m in ms]
        ax.plot(ms, vals, 'o-', label=f'd = {d}', markersize=3)
    
    ax.plot(ms, [2**int(m) for m in ms], 'k--', alpha=0.5, label='2^m (max)')
    
    ax.set_xlabel('m (sample size)', fontsize=12)
    ax.set_ylabel('Π(m, d) = Sauer-Shelah Bound', fontsize=12)
    ax.set_title('Sauer-Shelah Growth Function: Polynomial vs Exponential', fontsize=14)
    ax.set_yscale('log')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'sauer_shelah.png'), dpi=150)
    plt.close()
    print("Saved sauer_shelah.png")


def plot_sample_complexity():
    """Plot sample complexity as function of VC dimension and epsilon."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: vs VC dimension
    ds = np.arange(1, 101)
    for eps in [0.01, 0.05, 0.1, 0.2]:
        complexity = [37 * d / eps**2 * math.log(1/0.05) for d in ds]
        ax1.plot(ds, complexity, label=f'ε = {eps}')
    
    ax1.set_xlabel('VC Dimension (d)', fontsize=12)
    ax1.set_ylabel('Sample Complexity', fontsize=12)
    ax1.set_title('m(d, ε, δ=0.05) = 37d/ε² · log(1/δ)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_yscale('log')
    
    # Right: vs epsilon
    epsilons = np.linspace(0.01, 0.5, 100)
    for d in [1, 5, 10, 50]:
        complexity = [37 * d / e**2 * math.log(1/0.05) for e in epsilons]
        ax2.plot(epsilons, complexity, label=f'd = {d}')
    
    ax2.set_xlabel('ε (error tolerance)', fontsize=12)
    ax2.set_ylabel('Sample Complexity', fontsize=12)
    ax2.set_title('m vs ε for various VC dimensions (δ=0.05)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_yscale('log')
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'sample_complexity.png'), dpi=150)
    plt.close()
    print("Saved sample_complexity.png")


def plot_transfer_inflation():
    """Plot transfer learning sample complexity inflation."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: Single transfer
    Ls = np.linspace(1, 5, 100)
    base = 37 * 10 / 0.1**2 * math.log(1/0.05)
    
    ax1.fill_between(Ls, base, [base * L**2 for L in Ls], alpha=0.3, color='red',
                     label='Inflation region')
    ax1.plot(Ls, [base * L**2 for L in Ls], 'r-', linewidth=2, label='Transferred')
    ax1.axhline(y=base, color='blue', linestyle='--', label='Base')
    
    ax1.set_xlabel('Lipschitz Constant (L)', fontsize=12)
    ax1.set_ylabel('Sample Complexity', fontsize=12)
    ax1.set_title('Transfer Inflation: L² Factor', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Right: Chain transfer
    n_hops = np.arange(0, 8)
    for L in [1.5, 2.0, 3.0]:
        inflation = [L**(2*n) for n in n_hops]
        ax2.plot(n_hops, inflation, 'o-', label=f'L = {L}', markersize=6)
    
    ax2.set_xlabel('Number of Transfer Hops', fontsize=12)
    ax2.set_ylabel('Inflation Factor L^(2n)', fontsize=12)
    ax2.set_title('Chain Transfer: Exponential Growth', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_yscale('log')
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'transfer_inflation.png'), dpi=150)
    plt.close()
    print("Saved transfer_inflation.png")


def plot_sieve_lattice():
    """Plot a small sieve lattice (Hasse diagram)."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    
    # Sieve lattice for a 3-element preorder {0 ≤ 1 ≤ 2}
    # Sieves on 2: downward-closed subsets of {0, 1, 2}
    # ∅, {0}, {0,1}, {0,1,2}
    sieves = [
        (set(), "∅", 0),
        ({0}, "{0}", 1),
        ({0, 1}, "{0,1}", 2),
        ({0, 1, 2}, "{0,1,2}", 3),
    ]
    
    # Draw nodes
    for s, label, level in sieves:
        ax.plot(0, level, 'o', markersize=20, color='steelblue', zorder=5)
        ax.annotate(label, (0, level), textcoords="offset points",
                   xytext=(25, 0), fontsize=12, va='center')
    
    # Draw edges
    for i in range(len(sieves) - 1):
        ax.plot([0, 0], [sieves[i][2], sieves[i+1][2]], 'k-', linewidth=1.5)
    
    # Labels
    ax.annotate('⊥ (false)', (0, 0), textcoords="offset points",
               xytext=(-50, -20), fontsize=10, color='gray')
    ax.annotate('⊤ (true)', (0, 3), textcoords="offset points",
               xytext=(-50, 15), fontsize=10, color='gray')
    
    ax.set_xlim(-1, 2)
    ax.set_ylim(-0.5, 3.5)
    ax.set_title('Sieve Lattice on Linear Order 0 ≤ 1 ≤ 2\n'
                 '(Subobject Classifier Ω values)', fontsize=13)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'sieve_lattice.png'), dpi=150)
    plt.close()
    print("Saved sieve_lattice.png")


if __name__ == "__main__":
    print("Generating visualizations...")
    plot_sauer_shelah()
    plot_sample_complexity()
    plot_transfer_inflation()
    plot_sieve_lattice()
    print("All visualizations generated.")

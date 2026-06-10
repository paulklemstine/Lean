#!/usr/bin/env python3
"""
Tropical Scattering Recognition Duality — Applications

This module demonstrates real-world applications of tropical scattering
recognition duality across several domains:

1. Network Tomography: Recovering internal network structure from boundary measurements
2. Signal Processing: Piecewise-linear signal decomposition
3. Resource Allocation: Optimal bottleneck routing in logistics networks
4. Cryptographic Obfuscation Analysis: Tropical indistinguishability bounds
"""

import numpy as np
from typing import List, Dict, Tuple
from algorithms import (
    ScatteringRep, PhaseProfile, extract_profile,
    reconstruct_canonical, compute_domination_cells,
    check_minimality, verify_levinson_bound, find_tropical_isomorphism
)


# ─────────────────────────────────────────────────────────────────────
# Application 1: Network Tomography
# ─────────────────────────────────────────────────────────────────────

def network_tomography_demo():
    """
    Network Tomography: Recovering internal paths from boundary measurements.
    
    A network has source nodes and sink nodes connected by internal paths.
    We measure the maximum bandwidth (bottleneck capacity) from each source
    to each sink. The tropical scattering representation recovers the
    internal path structure.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Tomography")
    print("=" * 70)
    
    # Simulate a network with 3 internal paths and 6 source-sink pairs
    # Each path has a bottleneck capacity
    path_capacities = [10, 7, 15]  # 3 internal paths
    
    # Path usage matrix: which paths connect which source-sink pairs
    # Entry (q, i) = capacity of path i for source-sink pair q
    W = np.array([
        [10, 0, 15],   # Pair 0: uses paths 0 and 2
        [10, 7, 0],    # Pair 1: uses paths 0 and 1
        [0, 7, 15],    # Pair 2: uses paths 1 and 2
        [10, 0, 0],    # Pair 3: uses only path 0
        [0, 7, 0],     # Pair 4: uses only path 1
        [0, 0, 15],    # Pair 5: uses only path 2
    ], dtype=float)
    W[W == 0] = -np.inf  # Unused paths have -inf capacity
    
    network = ScatteringRep(W)
    measurements = extract_profile(network)
    
    print(f"\nNetwork has {network.n} internal paths, {network.m} measurement pairs")
    print(f"Measured bottleneck capacities: {measurements.values}")
    
    # Can we recover the number of internal paths?
    is_min, _ = check_minimality(network)
    print(f"\nNetwork representation is minimal: {is_min}")
    
    # Reconstruct minimal representation
    cells = compute_domination_cells(network)
    print(f"\nRecovered path structure (domination cells):")
    for path, pairs in cells.items():
        print(f"  Path {path} (capacity {path_capacities[path]}): "
              f"dominates measurement pairs {pairs}")
    
    # Verify Levinson bound
    _, explanation = verify_levinson_bound(network)
    print(f"\nLevinson bound: {explanation}")
    print("  → The number of internal paths ≤ number of measurements")


# ─────────────────────────────────────────────────────────────────────
# Application 2: Piecewise-Linear Signal Decomposition
# ─────────────────────────────────────────────────────────────────────

def signal_decomposition_demo():
    """
    Piecewise-Linear Signal Decomposition using tropical representations.
    
    A signal that is the pointwise maximum of several linear functions
    can be decomposed into its constituent components using the
    domination cell structure.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Piecewise-Linear Signal Decomposition")
    print("=" * 70)
    
    # Create a piecewise-linear signal as max of 4 affine functions
    t = np.linspace(0, 10, 50)
    
    # 4 component signals (affine functions)
    components = np.column_stack([
        2 * t + 1,           # Rising fast
        -t + 15,             # Falling
        0.5 * t + 5,         # Rising slow
        -0.3 * t + 12,       # Falling slow
    ])
    
    signal_rep = ScatteringRep(components)
    signal = extract_profile(signal_rep)
    
    print(f"\nSignal composed of {signal_rep.n} affine components over {signal_rep.m} time samples")
    
    # Decompose into cells
    cells = compute_domination_cells(signal_rep)
    print(f"\nDecomposition:")
    for comp, times in cells.items():
        if times:
            t_range = f"t ∈ [{t[min(times)]:.1f}, {t[max(times)]:.1f}]"
            print(f"  Component {comp}: dominates for {t_range} ({len(times)} samples)")
    
    # Check minimality
    is_min, redundant = check_minimality(signal_rep)
    if is_min:
        print(f"\nAll {signal_rep.n} components are essential (representation is minimal)")
    else:
        print(f"\nComponent {redundant} is redundant and can be removed")


# ─────────────────────────────────────────────────────────────────────
# Application 3: Bottleneck Routing Optimization
# ─────────────────────────────────────────────────────────────────────

def bottleneck_routing_demo():
    """
    Bottleneck Routing: Finding the widest paths through a network.
    
    In max-plus (tropical) algebra, the "shortest path" problem becomes
    the "widest path" problem. The scattering representation encodes
    all possible routing strategies, and the profile gives the optimal
    bottleneck capacity for each source-destination pair.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Bottleneck Routing Optimization")
    print("=" * 70)
    
    # 5 cities, 3 possible routing strategies
    cities = ["NYC", "LAX", "CHI", "MIA", "SEA"]
    
    # Strategy 0: Direct flights (high capacity main corridors)
    # Strategy 1: Hub-and-spoke through Chicago
    # Strategy 2: Coastal routes
    
    W = np.array([
        [100, 80, 90],   # NYC: good on all strategies
        [90, 70, 95],    # LAX: best on coastal
        [85, 100, 60],   # CHI: best on hub-spoke
        [75, 65, 85],    # MIA: best on coastal
        [80, 75, 100],   # SEA: best on coastal
    ], dtype=float)
    
    network = ScatteringRep(W)
    optimal_capacity = extract_profile(network)
    
    print(f"\nRouting network: {len(cities)} cities, {network.n} strategies")
    print(f"\nOptimal bottleneck capacities:")
    for i, city in enumerate(cities):
        dom = int(np.argmax(W[i]))
        strategies = ["Direct", "Hub-Spoke", "Coastal"]
        print(f"  {city}: capacity = {optimal_capacity.values[i]:.0f} "
              f"(best via {strategies[dom]})")
    
    cells = compute_domination_cells(network)
    print(f"\nStrategy regions:")
    strategies = ["Direct flights", "Hub-and-spoke", "Coastal routes"]
    for strat, city_indices in cells.items():
        city_names = [cities[i] for i in city_indices]
        print(f"  {strategies[strat]}: optimal for {city_names}")


# ─────────────────────────────────────────────────────────────────────
# Application 4: Tropical Obfuscation Analysis
# ─────────────────────────────────────────────────────────────────────

def obfuscation_analysis_demo():
    """
    Tropical Obfuscation Analysis: How much internal structure is
    revealed by external observations?
    
    The recognition duality theorem says that the phase profile
    COMPLETELY determines the minimal representation. This means
    that in the tropical setting, external observations fully
    reveal the essential internal structure — obfuscation is impossible
    for the minimal core.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Tropical Obfuscation Analysis")
    print("=" * 70)
    
    # Two networks with different internal structures but same measurements
    W1 = np.array([
        [10, 5, 3],
        [4, 8, 6],
        [7, 3, 9],
        [5, 10, 2],
    ], dtype=float)
    
    # Permuted version (isomorphic)
    perm = [2, 0, 1]
    W2 = W1[:, perm]
    
    # Different structure but same profile (via redundant generators)
    W3 = np.column_stack([W1, np.min(W1, axis=1)])  # Add redundant generator
    
    M1 = ScatteringRep(W1)
    M2 = ScatteringRep(W2)
    M3 = ScatteringRep(W3)
    
    phi1 = extract_profile(M1)
    phi2 = extract_profile(M2)
    phi3 = extract_profile(M3)
    
    print(f"\nNetwork 1: {M1.n} generators → profile: {phi1.values}")
    print(f"Network 2: {M2.n} generators → profile: {phi2.values}")
    print(f"Network 3: {M3.n} generators → profile: {phi3.values}")
    
    print(f"\nSame profile (1 vs 2): {np.allclose(phi1.values, phi2.values)}")
    print(f"Same profile (1 vs 3): {np.allclose(phi1.values, phi3.values)}")
    
    # Check isomorphism
    iso_12 = find_tropical_isomorphism(M1, M2)
    iso_13 = find_tropical_isomorphism(M1, M3)
    
    print(f"\nIsomorphic (1 ↔ 2): {iso_12 is not None}")
    if iso_12 is not None:
        print(f"  Isomorphism: {iso_12}")
    print(f"Isomorphic (1 ↔ 3): {iso_13 is not None}")
    
    # Check minimality
    is_min1, _ = check_minimality(M1)
    is_min3, redundant = check_minimality(M3)
    print(f"\nNetwork 1 minimal: {is_min1}")
    print(f"Network 3 minimal: {is_min3} (generator {redundant} is redundant)")
    
    print(f"\n→ Recognition Duality: The phase profile uniquely determines")
    print(f"  the minimal internal structure. Adding redundant generators")
    print(f"  does not change the observable profile, but minimization")
    print(f"  always recovers the essential structure.")


if __name__ == "__main__":
    network_tomography_demo()
    signal_decomposition_demo()
    bottleneck_routing_demo()
    obfuscation_analysis_demo()
    
    print("\n" + "=" * 70)
    print("All applications completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Scattering Recognition Duality — Interactive Demonstration

This module demonstrates the core theorems of tropical scattering recognition duality
with concrete numerical examples. We work over the max-plus (tropical) semiring and
show how phase profiles are extracted from scattering representations, how the canonical
reconstruction works, and how the Levinson bound constrains representation dimension.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional


class TropScatterRep:
    """
    A tropical scattering representation with n generators over m channels.
    
    Attributes:
        n: Number of generators (bound states)
        m: Number of channels
        weight: Weight matrix of shape (m, n) — weight[q][i] is the weight of generator i at channel q
    """
    
    def __init__(self, weight: np.ndarray):
        """Initialize from a weight matrix (channels × generators)."""
        self.weight = np.array(weight, dtype=float)
        self.m, self.n = self.weight.shape
    
    def profile(self) -> np.ndarray:
        """Compute the phase profile: max over generators at each channel."""
        if self.n == 0:
            return np.full(self.m, -np.inf)
        return np.max(self.weight, axis=1)
    
    def dominant_generator(self, q: int) -> int:
        """Return the index of the dominant generator at channel q."""
        return int(np.argmax(self.weight[q]))
    
    def strictly_dominates(self, i: int, q: int) -> bool:
        """Check if generator i strictly dominates at channel q."""
        val_i = self.weight[q, i]
        return all(self.weight[q, j] < val_i for j in range(self.n) if j != i)
    
    def is_minimal(self) -> bool:
        """Check if every generator strictly dominates at some channel."""
        for i in range(self.n):
            if not any(self.strictly_dominates(i, q) for q in range(self.m)):
                return False
        return True
    
    def is_causal_convex(self) -> bool:
        """Check if every generator weakly dominates at some channel."""
        for i in range(self.n):
            found = False
            for q in range(self.m):
                if all(self.weight[q, j] <= self.weight[q, i] for j in range(self.n)):
                    found = True
                    break
            if not found:
                return False
        return True
    
    def domination_cells(self) -> Dict[int, List[int]]:
        """Compute the domination cell decomposition: generator -> list of channels where it dominates."""
        cells = {i: [] for i in range(self.n)}
        for q in range(self.m):
            dom = self.dominant_generator(q)
            cells[dom].append(q)
        return cells
    
    def __repr__(self):
        return f"TropScatterRep(n={self.n}, m={self.m})"


def reconstruct_rep(phi: np.ndarray) -> TropScatterRep:
    """Canonical 1-generator reconstruction from a phase profile."""
    return TropScatterRep(phi.reshape(-1, 1))


class TropIso:
    """A tropical isomorphism between two representations."""
    
    def __init__(self, perm: np.ndarray):
        """Initialize with a permutation of generators."""
        self.perm = perm
    
    @staticmethod
    def check_iso(M1: TropScatterRep, M2: TropScatterRep) -> Optional['TropIso']:
        """Check if two representations are tropically isomorphic."""
        if M1.n != M2.n or M1.m != M2.m:
            return None
        
        from itertools import permutations
        for perm in permutations(range(M1.n)):
            if np.allclose(M1.weight, M2.weight[:, list(perm)]):
                return TropIso(np.array(perm))
        return None


def demo_basic_reconstruction():
    """Demonstrate basic profile extraction and reconstruction."""
    print("=" * 60)
    print("DEMO 1: Basic Profile Extraction and Reconstruction")
    print("=" * 60)
    
    # Create a 3-generator, 5-channel representation
    W = np.array([
        [3, 7, 2],   # Channel 0: generator 1 dominates (7)
        [5, 4, 6],   # Channel 1: generator 2 dominates (6)
        [8, 1, 3],   # Channel 2: generator 0 dominates (8)
        [2, 9, 4],   # Channel 3: generator 1 dominates (9)
        [1, 3, 10],  # Channel 4: generator 2 dominates (10)
    ], dtype=float)
    
    M = TropScatterRep(W)
    phi = M.profile()
    
    print(f"\nOriginal representation: {M.n} generators, {M.m} channels")
    print(f"Weight matrix:\n{M.weight}")
    print(f"\nPhase profile φ: {phi}")
    print(f"Minimal: {M.is_minimal()}")
    print(f"Causally convex: {M.is_causal_convex()}")
    
    # Reconstruct from profile
    M_recon = reconstruct_rep(phi)
    phi_recon = M_recon.profile()
    
    print(f"\nReconstructed rep: {M_recon.n} generator, {M_recon.m} channels")
    print(f"Reconstructed profile: {phi_recon}")
    print(f"Profile preserved: {np.allclose(phi, phi_recon)}")
    print(f"Reconstruction is minimal: {M_recon.is_minimal()}")
    
    # Show domination cells
    cells = M.domination_cells()
    print(f"\nDomination cells:")
    for gen, channels in cells.items():
        print(f"  Generator {gen} dominates at channels: {channels}")


def demo_levinson_bound():
    """Demonstrate the tropical Levinson bound: dim ≤ |channels|."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Levinson Bound")
    print("=" * 60)
    
    for m in [3, 5, 8]:
        print(f"\n--- {m} channels ---")
        
        # Create a minimal rep with exactly m generators (one per channel)
        W = np.eye(m) * 10  # Each generator dominates exactly one channel
        W += np.random.rand(m, m) * 2  # Add small noise
        # Make diagonal dominant
        for i in range(m):
            W[i, i] = np.max(W[i]) + 1
        
        M = TropScatterRep(W)
        print(f"  {M.n} generators, {M.m} channels")
        print(f"  Minimal: {M.is_minimal()}")
        print(f"  Levinson bound satisfied: {M.n} ≤ {m} = {M.n <= m}")
        
        # Try to create a rep with MORE generators than channels (must fail minimality)
        W_too_many = np.random.rand(m, m + 2) * 5
        M_big = TropScatterRep(W_too_many)
        print(f"  Rep with {M_big.n} > {m} generators: minimal = {M_big.is_minimal()}")


def demo_uniqueness():
    """Demonstrate uniqueness of minimal 1-generator representations."""
    print("\n" + "=" * 60)
    print("DEMO 3: Uniqueness (Isomorphism of 1-Generator Reps)")
    print("=" * 60)
    
    phi = np.array([3.0, 7.0, 2.0, 9.0, 5.0])
    
    M1 = reconstruct_rep(phi)
    M2 = reconstruct_rep(phi)
    
    iso = TropIso.check_iso(M1, M2)
    print(f"\nProfile: {phi}")
    print(f"M1 and M2 are both canonical reconstructions")
    print(f"Isomorphic: {iso is not None}")
    if iso:
        print(f"Isomorphism permutation: {iso.perm}")


def demo_stability():
    """Demonstrate stability under profile perturbation."""
    print("\n" + "=" * 60)
    print("DEMO 4: Stability Under Perturbation")
    print("=" * 60)
    
    phi = np.array([3.0, 7.0, 2.0, 9.0, 5.0])
    
    print(f"\nOriginal profile: {phi}")
    
    for eps in [0.0, 0.01, 0.1, 1.0]:
        phi_perturbed = phi + np.random.randn(5) * eps
        M1 = reconstruct_rep(phi)
        M2 = reconstruct_rep(phi_perturbed)
        
        # Check if profiles are the same (hence reps are isomorphic)
        same_profile = np.allclose(phi, phi_perturbed)
        iso = TropIso.check_iso(M1, M2)
        
        print(f"  ε = {eps:.2f}: profiles equal = {same_profile}, "
              f"isomorphic = {iso is not None}")


def demo_functoriality():
    """Demonstrate functoriality under channel maps."""
    print("\n" + "=" * 60)
    print("DEMO 5: Functoriality Under Channel Maps")
    print("=" * 60)
    
    W = np.array([
        [3, 7],
        [5, 4],
        [8, 1],
        [2, 9],
    ], dtype=float)
    
    M = TropScatterRep(W)
    phi = M.profile()
    
    # Channel map: select subset of channels
    f = [0, 2, 3]  # Map: Q' = {0,1,2} -> Q = {0,2,3}
    
    # Pullback
    W_pullback = W[f]
    M_pullback = TropScatterRep(W_pullback)
    phi_pullback = M_pullback.profile()
    
    # Compare with composed profile
    phi_composed = phi[f]
    
    print(f"\nOriginal profile: {phi}")
    print(f"Channel map f: {f}")
    print(f"Pullback profile: {phi_pullback}")
    print(f"Composed profile: {phi_composed}")
    print(f"Equal: {np.allclose(phi_pullback, phi_composed)}")


def demo_multi_generator():
    """Demonstrate multi-generator representations and cell decomposition."""
    print("\n" + "=" * 60)
    print("DEMO 6: Multi-Generator Cell Decomposition")
    print("=" * 60)
    
    # 3 generators, 10 channels
    # Create a piecewise-linear profile with 3 "pieces"
    channels = np.arange(10, dtype=float)
    
    # Generator 0: strong at low channels
    g0 = 10 - channels
    # Generator 1: strong at middle channels
    g1 = 8 - np.abs(channels - 5) * 1.5
    # Generator 2: strong at high channels
    g2 = channels
    
    W = np.column_stack([g0, g1, g2])
    M = TropScatterRep(W)
    
    phi = M.profile()
    cells = M.domination_cells()
    
    print(f"\nRepresentation: {M.n} generators, {M.m} channels")
    print(f"Minimal: {M.is_minimal()}")
    print(f"Causally convex: {M.is_causal_convex()}")
    print(f"\nProfile: {phi}")
    print(f"\nCell decomposition:")
    for gen, chans in cells.items():
        print(f"  Generator {gen} dominates at channels: {chans}")
    
    # Verify Levinson bound
    print(f"\nLevinson bound: {M.n} ≤ {M.m} ✓" if M.n <= M.m else "VIOLATION!")
    
    # Count "breakpoints" (where dominant generator changes)
    doms = [M.dominant_generator(q) for q in range(M.m)]
    breakpoints = sum(1 for i in range(len(doms)-1) if doms[i] != doms[i+1])
    print(f"Breakpoints (dominant generator changes): {breakpoints}")
    print(f"Number of contiguous cells: {breakpoints + 1}")


if __name__ == "__main__":
    np.random.seed(42)
    
    demo_basic_reconstruction()
    demo_levinson_bound()
    demo_uniqueness()
    demo_stability()
    demo_functoriality()
    demo_multi_generator()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for Tropical Scattering Recognition Duality."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io

def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()

def viz_profile_and_generators():
    """Visualize a tropical scattering representation with its profile and generators."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    t = np.linspace(0, 10, 100)
    
    # Generator weight functions
    g0 = 10 - t
    g1 = 8 - np.abs(t - 5) * 1.5
    g2 = t
    
    profile = np.maximum(np.maximum(g0, g1), g2)
    
    # Left panel: generators and profile
    ax = axes[0]
    ax.plot(t, g0, '--', color='#e74c3c', alpha=0.7, label='Generator 0')
    ax.plot(t, g1, '--', color='#2ecc71', alpha=0.7, label='Generator 1')
    ax.plot(t, g2, '--', color='#3498db', alpha=0.7, label='Generator 2')
    ax.plot(t, profile, 'k-', linewidth=2.5, label='Phase Profile φ')
    ax.set_xlabel('Channel q', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Tropical Scattering: Generators → Profile', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Right panel: domination cells
    ax = axes[1]
    colors = ['#e74c3c', '#2ecc71', '#3498db']
    for i, (g, label) in enumerate([(g0, 'Gen 0'), (g1, 'Gen 1'), (g2, 'Gen 2')]):
        mask = np.isclose(g, profile, atol=0.01)
        for j in range(len(t)-1):
            if mask[j]:
                ax.axvspan(t[j], t[j+1], alpha=0.3, color=colors[i])
    
    ax.plot(t, profile, 'k-', linewidth=2.5, label='Phase Profile φ')
    
    # Add cell labels
    ax.text(1.5, 2, 'Cell 0\n(Gen 0)', fontsize=11, ha='center', color='#c0392b', fontweight='bold')
    ax.text(5, 2, 'Cell 1\n(Gen 1)', fontsize=11, ha='center', color='#27ae60', fontweight='bold')
    ax.text(8.5, 2, 'Cell 2\n(Gen 2)', fontsize=11, ha='center', color='#2980b9', fontweight='bold')
    
    ax.set_xlabel('Channel q', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Domination Cell Decomposition', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    result = fig_to_base64(fig)
    plt.close(fig)
    return result

def viz_levinson_bound():
    """Visualize the tropical Levinson bound."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    np.random.seed(42)
    m_values = range(2, 16)
    
    for m in m_values:
        # Create random minimal reps and record their dimensions
        for trial in range(20):
            n = np.random.randint(1, m + 3)
            W = np.random.rand(m, n) * 10
            # Make it more likely to be minimal by boosting diagonal
            for i in range(min(n, m)):
                W[i, i] += 5
            
            # Check minimality
            is_minimal = True
            for i in range(n):
                has_strict = False
                for q in range(m):
                    vals = W[q].copy()
                    val_i = vals[i]
                    vals[i] = -np.inf
                    if val_i > np.max(vals):
                        has_strict = True
                        break
                if not has_strict:
                    is_minimal = False
                    break
            
            color = '#2ecc71' if is_minimal else '#e74c3c'
            marker = 'o' if is_minimal else 'x'
            alpha = 0.6 if is_minimal else 0.3
            ax.scatter(m, n, color=color, marker=marker, alpha=alpha, s=30)
    
    # Draw the bound line
    ax.plot([1, 16], [1, 16], 'k--', linewidth=2, label='Levinson Bound: n = m')
    ax.fill_between([1, 16], [1, 16], [20, 20], alpha=0.1, color='red', label='Forbidden region (n > m)')
    
    ax.scatter([], [], color='#2ecc71', marker='o', label='Minimal rep', s=50)
    ax.scatter([], [], color='#e74c3c', marker='x', label='Non-minimal rep', s=50)
    
    ax.set_xlabel('Number of Channels (m)', fontsize=12)
    ax.set_ylabel('Number of Generators (n)', fontsize=12)
    ax.set_title('Tropical Levinson Bound: n ≤ m for Minimal Representations', fontsize=13)
    ax.legend(fontsize=10, loc='upper left')
    ax.set_xlim(1, 16)
    ax.set_ylim(0, 18)
    ax.grid(True, alpha=0.3)
    
    result = fig_to_base64(fig)
    plt.close(fig)
    return result

def viz_reconstruction_pipeline():
    """Visualize the reconstruction pipeline."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Step 1: Original multi-generator rep
    t = np.arange(8)
    W = np.array([
        [9, 3, 1],
        [7, 6, 2],
        [5, 8, 4],
        [3, 7, 6],
        [2, 5, 8],
        [1, 3, 9],
        [3, 4, 7],
        [5, 2, 5],
    ], dtype=float)
    
    profile = np.max(W, axis=1)
    
    ax = axes[0]
    ax.bar(t - 0.25, W[:, 0], 0.25, color='#e74c3c', alpha=0.7, label='Gen 0')
    ax.bar(t, W[:, 1], 0.25, color='#2ecc71', alpha=0.7, label='Gen 1')
    ax.bar(t + 0.25, W[:, 2], 0.25, color='#3498db', alpha=0.7, label='Gen 2')
    ax.step(t, profile, 'k-', linewidth=2, where='mid', label='Profile')
    ax.set_title('Step 1: Original Rep (3 generators)', fontsize=12)
    ax.set_xlabel('Channel')
    ax.set_ylabel('Weight')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Step 2: Extract profile
    ax = axes[1]
    ax.bar(t, profile, color='#9b59b6', alpha=0.8)
    ax.set_title('Step 2: Extract Phase Profile', fontsize=12)
    ax.set_xlabel('Channel')
    ax.set_ylabel('Profile Value φ(q)')
    ax.grid(True, alpha=0.3)
    
    # Step 3: Canonical reconstruction
    ax = axes[2]
    ax.bar(t, profile, color='#f39c12', alpha=0.8, label='Single generator')
    ax.step(t, profile, 'k-', linewidth=2, where='mid', label='Profile (preserved)')
    ax.set_title('Step 3: Canonical Reconstruction (1 gen)', fontsize=12)
    ax.set_xlabel('Channel')
    ax.set_ylabel('Weight')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    plt.suptitle('Certified Reconstruction Pipeline', fontsize=14, fontweight='bold')
    plt.tight_layout()
    result = fig_to_base64(fig)
    plt.close(fig)
    return result

def viz_functoriality():
    """Visualize functoriality under channel maps."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    
    # Original profile
    phi = np.array([3, 7, 2, 9, 5, 4, 8, 1], dtype=float)
    t = np.arange(len(phi))
    
    ax = axes[0]
    ax.bar(t, phi, color='#3498db', alpha=0.8)
    ax.set_title('Original Profile φ over Q', fontsize=12)
    ax.set_xlabel('Channel q ∈ Q')
    ax.set_ylabel('φ(q)')
    ax.grid(True, alpha=0.3)
    
    # Channel map
    f = [0, 2, 4, 6]
    ax = axes[1]
    for i, j in enumerate(f):
        ax.annotate('', xy=(j, 0.6), xytext=(i, 0.4),
                    arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=2))
    ax.set_xlim(-0.5, 7.5)
    ax.set_ylim(0, 1)
    ax.set_title("Channel Map f: Q' → Q", fontsize=12)
    ax.text(1.5, 0.2, "Q' = {0,1,2,3}", fontsize=11, ha='center')
    ax.text(3.5, 0.8, "Q = {0,1,...,7}", fontsize=11, ha='center')
    ax.axis('off')
    
    # Pullback profile
    phi_pullback = phi[f]
    t2 = np.arange(len(f))
    
    ax = axes[2]
    ax.bar(t2, phi_pullback, color='#e74c3c', alpha=0.8)
    ax.set_title("Pullback Profile φ∘f over Q'", fontsize=12)
    ax.set_xlabel("Channel q' ∈ Q'")
    ax.set_ylabel("(φ∘f)(q')")
    ax.grid(True, alpha=0.3)
    
    plt.suptitle('Functoriality: profile(comap(M, f)) = profile(M) ∘ f', fontsize=13, fontweight='bold')
    plt.tight_layout()
    result = fig_to_base64(fig)
    plt.close(fig)
    return result

if __name__ == "__main__":
    print("Generating visualizations...")
    
    v1 = viz_profile_and_generators()
    print(f"  Profile & generators: {len(v1)} chars")
    
    v2 = viz_levinson_bound()
    print(f"  Levinson bound: {len(v2)} chars")
    
    v3 = viz_reconstruction_pipeline()
    print(f"  Reconstruction pipeline: {len(v3)} chars")
    
    v4 = viz_functoriality()
    print(f"  Functoriality: {len(v4)} chars")
    
    print("All visualizations generated successfully!")

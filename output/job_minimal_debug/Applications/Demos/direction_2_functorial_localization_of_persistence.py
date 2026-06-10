"""
Applications of Functorial Persistence Localization

Demonstrates real-world scenarios where prime localization
provides computational advantages for persistence analysis.
"""

import random
from typing import List, Dict, Tuple, Set
from algorithms import (
    FGAbGroup, PersistenceModule,
    hausdorff_distance, prime_decomposition_of_births,
    search_witness_improvement, random_persistence_module,
)


def application_spectral_filtering():
    """Application 1: Spectral Filtering of Persistence Signals

    Analogy: just as Fourier analysis decomposes a signal into frequencies,
    prime localization decomposes persistence torsion into prime channels.
    Each prime p acts as a frequency filter, isolating the p-primary signal.
    """
    print("=" * 60)
    print("APPLICATION 1: Spectral Filtering via Prime Localization")
    print("=" * 60)
    print()

    # Create a "noisy" persistence module with mixed torsion
    F = PersistenceModule(groups=[
        FGAbGroup(free_rank=3),
        FGAbGroup(free_rank=3, torsion_factors=[2]),       # 2-torsion at 1
        FGAbGroup(free_rank=3, torsion_factors=[2, 3]),    # 3-torsion at 2
        FGAbGroup(free_rank=3, torsion_factors=[2, 3, 5]), # 5-torsion at 3
        FGAbGroup(free_rank=3, torsion_factors=[2, 3, 5, 7]),
        FGAbGroup(free_rank=3, torsion_factors=[4, 9, 25, 7]),
    ])

    print("Original persistence module (mixed torsion):")
    for i, g in enumerate(F.groups):
        print(f"  F({i}) = {g}")
    print()

    print("Prime channels (spectral decomposition):")
    for p in [2, 3, 5, 7]:
        F_loc = F.localize_at(p)
        birth = F_loc.global_torsion_birth()
        print(f"\n  Channel p={p} (L_{p}(F)):")
        for i, g in enumerate(F_loc.groups):
            marker = " ← BIRTH" if i == birth else ""
            print(f"    L_{p}(F)({i}) = {g}{marker}")

    print()
    print("Key insight: each prime channel isolates independent torsion information.")
    print("Birth indices can differ across channels, enabling finer analysis.")
    print()


def application_denoising():
    """Application 2: Arithmetic Denoising

    If we know that the 'signal' torsion is at prime p but 'noise' torsion
    appears at other primes, localization at p removes the noise.
    """
    print("=" * 60)
    print("APPLICATION 2: Arithmetic Denoising")
    print("=" * 60)
    print()

    # Signal: 2-torsion appearing at index 3
    # Noise: random 3,5-torsion appearing earlier
    signal = PersistenceModule(groups=[
        FGAbGroup(free_rank=1, torsion_factors=[3, 5]),     # noise only
        FGAbGroup(free_rank=1, torsion_factors=[3, 5, 15]), # more noise
        FGAbGroup(free_rank=1, torsion_factors=[3, 5, 15]), # noise persists
        FGAbGroup(free_rank=1, torsion_factors=[3, 5, 15, 4]),  # signal appears!
        FGAbGroup(free_rank=1, torsion_factors=[3, 5, 15, 4]),
    ])

    print("Original module (signal + noise):")
    for i, g in enumerate(signal.groups):
        print(f"  F({i}) = {g}")
    print(f"  Global torsion birth: index {signal.global_torsion_birth()}")
    print(f"  (Noise masks the true signal birth at index 3)")
    print()

    # Localize at p=2 to isolate the signal
    denoised = signal.localize_at(2)
    print("After localization at p=2 (denoised):")
    for i, g in enumerate(denoised.groups):
        print(f"  L_2(F)({i}) = {g}")
    print(f"  Torsion birth: index {denoised.global_torsion_birth()}")
    print(f"  Signal recovered! The 2-torsion birth at index 3 is now visible.")
    print()


def application_comparison():
    """Application 3: Primewise Comparison of Persistence Modules

    Compare two modules channel by channel to find structural similarities
    and differences that global comparison would miss.
    """
    print("=" * 60)
    print("APPLICATION 3: Primewise Structural Comparison")
    print("=" * 60)
    print()

    F = PersistenceModule(groups=[
        FGAbGroup(free_rank=2),
        FGAbGroup(free_rank=2, torsion_factors=[6]),   # Z/6 at 1
        FGAbGroup(free_rank=2, torsion_factors=[6, 4]),
        FGAbGroup(free_rank=2, torsion_factors=[6, 4, 9]),
    ])

    G = PersistenceModule(groups=[
        FGAbGroup(free_rank=2),
        FGAbGroup(free_rank=2),
        FGAbGroup(free_rank=2, torsion_factors=[4]),   # Z/4 at 2
        FGAbGroup(free_rank=2, torsion_factors=[4, 3]),
    ])

    print("Module F:")
    for i, g in enumerate(F.groups):
        print(f"  F({i}) = {g}")
    print()

    print("Module G:")
    for i, g in enumerate(G.groups):
        print(f"  G({i}) = {g}")
    print()

    print("Primewise comparison:")
    for p in [2, 3]:
        F_loc = F.localize_at(p)
        G_loc = G.localize_at(p)
        fb = F_loc.global_torsion_birth()
        gb = G_loc.global_torsion_birth()
        dist = abs(fb - gb) if fb is not None and gb is not None else "∞" if fb is not None or gb is not None else 0
        print(f"  p={p}: F birth={fb}, G birth={gb}, distance={dist}")

    fb = F.global_torsion_birth()
    gb = G.global_torsion_birth()
    dist = abs(fb - gb) if fb is not None and gb is not None else "N/A"
    print(f"  Global: F birth={fb}, G birth={gb}, distance={dist}")
    print()
    print("Observation: p=2 channel shows distance 1, p=3 channel shows distance 2.")
    print("Global distance is 1, masking the larger discrepancy in the 3-channel.")
    print()


def application_statistics():
    """Application 4: Statistical Analysis of Localization Improvement

    Over many random examples, analyze how often localization provides
    strict improvement and by how much.
    """
    print("=" * 60)
    print("APPLICATION 4: Statistical Analysis of Improvement")
    print("=" * 60)
    print()

    random.seed(2025)
    improvements: Dict[int, List[int]] = {2: [], 3: [], 5: [], 7: []}

    for _ in range(1000):
        F = random_persistence_module(length=12, primes=(2, 3, 5, 7))
        G = random_persistence_module(length=12, primes=(2, 3, 5, 7))

        gb_F = F.global_torsion_birth()
        gb_G = G.global_torsion_birth()
        if gb_F is None or gb_G is None:
            continue
        global_dist = abs(gb_F - gb_G)

        for p in [2, 3, 5, 7]:
            F_loc = F.localize_at(p)
            G_loc = G.localize_at(p)
            fb = F_loc.global_torsion_birth()
            gb = G_loc.global_torsion_birth()
            if fb is None and gb is None:
                loc_dist = 0
            elif fb is not None and gb is not None:
                loc_dist = abs(fb - gb)
            else:
                continue

            if loc_dist < global_dist:
                improvements[p].append(global_dist - loc_dist)

    print("Results over 1000 random pairs (length 12):")
    print()
    for p in [2, 3, 5, 7]:
        imps = improvements[p]
        if imps:
            avg_imp = sum(imps) / len(imps)
            max_imp = max(imps)
            print(f"  Prime p={p}:")
            print(f"    Strict improvements: {len(imps)}")
            print(f"    Average improvement: {avg_imp:.2f}")
            print(f"    Maximum improvement: {max_imp}")
        else:
            print(f"  Prime p={p}: no improvements found")
    print()


if __name__ == "__main__":
    application_spectral_filtering()
    application_denoising()
    application_comparison()
    application_statistics()


#!/usr/bin/env python3
"""
Demo: Functorial Localization of Persistence Modules

Interactive demonstration of:
1. Birth set identification (Theorem 2)
2. Interleaving preservation under localization (Theorem 1)
3. Primewise stability via localization (Theorem 3)
4. Witness improvement search (Theorem 4)

Run: python demo.py
"""

import random
import sys
from algorithms import (
    FGAbGroup, PersistenceModule,
    verify_birth_set_identification,
    verify_interleaving_preservation,
    search_witness_improvement,
    prime_decomposition_of_births,
    hausdorff_distance,
    random_persistence_module,
)


def demo_birth_set_identification():
    """Demonstrate Theorem 2: PTorsionBirthSet(p, F) = TorsionBirthSet(L_p(F))."""
    print("=" * 70)
    print("THEOREM 2: Birth Set Identification")
    print("PTorsionBirthSet(p, F) = GlobalTorsionBirthSet(L_p(F))")
    print("=" * 70)
    print()

    # Handcrafted example
    F = PersistenceModule(groups=[
        FGAbGroup(free_rank=1),                          # Z
        FGAbGroup(free_rank=1, torsion_factors=[3]),     # Z ⊕ Z/3
        FGAbGroup(free_rank=1, torsion_factors=[3, 4]),  # Z ⊕ Z/3 ⊕ Z/4
        FGAbGroup(free_rank=1, torsion_factors=[6, 4]),  # Z ⊕ Z/4 ⊕ Z/6
    ])

    print("Persistence module F:")
    for i, g in enumerate(F.groups):
        print(f"  F({i}) = {g}")
    print()

    for p in [2, 3, 5, 7]:
        F_loc = F.localize_at(p)
        p_births = F.p_torsion_birth_set(p)
        loc_births = F_loc.global_torsion_birth_set()
        ok = verify_birth_set_identification(F, p)
        status = "✓ VERIFIED" if ok else "✗ FAILED"

        print(f"  Prime p = {p}:")
        print(f"    L_{p}(F): {[str(g) for g in F_loc.groups]}")
        print(f"    PTorsionBirthSet({p}, F) = {p_births}")
        print(f"    TorsionBirthSet(L_{p}(F)) = {loc_births}")
        print(f"    {status}")
        print()

    # Random verification
    print("Random verification (100 modules, primes 2,3,5,7):")
    random.seed(42)
    n_pass = 0
    n_total = 0
    for _ in range(100):
        F = random_persistence_module(length=8, primes=(2, 3, 5, 7))
        for p in [2, 3, 5, 7]:
            n_total += 1
            if verify_birth_set_identification(F, p):
                n_pass += 1

    print(f"  {n_pass}/{n_total} tests passed")
    print()


def demo_interleaving_preservation():
    """Demonstrate Theorem 1: Localization preserves interleavings."""
    print("=" * 70)
    print("THEOREM 1: Interleaving Preservation")
    print("If F ~ G (delta-interleaved), then L_p(F) ~ L_p(G) (same delta)")
    print("=" * 70)
    print()

    # Generate pairs and check delta-closeness is preserved
    random.seed(123)
    print("Testing delta-closeness preservation on 50 random pairs:")
    for delta in [0, 1, 2, 3]:
        n_consistent = 0
        n_total = 0
        for _ in range(50):
            F = random_persistence_module(length=10, primes=(2, 3, 5))
            G = random_persistence_module(length=10, primes=(2, 3, 5))
            for p in [2, 3, 5]:
                passed, msg = verify_interleaving_preservation(F, G, p, delta)
                n_total += 1
                if passed:
                    n_consistent += 1
        print(f"  delta={delta}: {n_consistent}/{n_total} consistent")
    print()


def demo_prime_decomposition():
    """Demonstrate the arithmetic decomposition of torsion births."""
    print("=" * 70)
    print("CROSS-DOMAIN THEOREM: Arithmetic Decomposition of Births")
    print("GlobalTorsionBirthSet ⊆ ⋃_p PTorsionBirthSet(p, F)")
    print("=" * 70)
    print()

    F = PersistenceModule(groups=[
        FGAbGroup(free_rank=2),
        FGAbGroup(free_rank=2),
        FGAbGroup(free_rank=2, torsion_factors=[30]),  # Z/30 = Z/2 ⊕ Z/3 ⊕ Z/5
        FGAbGroup(free_rank=2, torsion_factors=[30, 8]),
    ])

    print("F with Z/30 torsion appearing at index 2:")
    for i, g in enumerate(F.groups):
        print(f"  F({i}) = {g}")
    print()

    decomp = prime_decomposition_of_births(F)
    print("Prime decomposition of birth data:")
    for p, births in sorted(decomp.items()):
        print(f"  p={p}: births at {births}")

    global_births = F.global_torsion_birth_set()
    print(f"  Global births: {global_births}")

    all_prime_births = set()
    for births in decomp.values():
        all_prime_births |= births

    print(f"  Union of prime births: {all_prime_births}")
    print(f"  Global ⊆ Union: {global_births <= all_prime_births}")
    print()


def demo_witness_improvement():
    """Demonstrate Theorem 4: Localization can sharpen witnesses."""
    print("=" * 70)
    print("THEOREM 4: Witness Improvement via Localization")
    print("∃ F,G,p: interleavingDist(L_p(F), L_p(G)) < interleavingDist(F,G)")
    print("=" * 70)
    print()

    # Handcrafted example: F has mixed torsion, localizing kills some
    F = PersistenceModule(groups=[
        FGAbGroup(free_rank=1),
        FGAbGroup(free_rank=1),
        FGAbGroup(free_rank=1, torsion_factors=[6]),  # Z/6 at index 2
    ])

    G = PersistenceModule(groups=[
        FGAbGroup(free_rank=1),
        FGAbGroup(free_rank=1, torsion_factors=[15]),  # Z/15 at index 1
        FGAbGroup(free_rank=1, torsion_factors=[15]),
    ])

    print("F:", [str(g) for g in F.groups])
    print("G:", [str(g) for g in G.groups])
    print()

    for p in [2, 3, 5]:
        F_loc = F.localize_at(p)
        G_loc = G.localize_at(p)

        fb = F.global_torsion_birth()
        gb = G.global_torsion_birth()
        orig_dist = abs(fb - gb) if fb is not None and gb is not None else "∞"

        flb = F_loc.global_torsion_birth()
        glb = G_loc.global_torsion_birth()

        if flb is None and glb is None:
            loc_dist = 0
        elif flb is not None and glb is not None:
            loc_dist = abs(flb - glb)
        else:
            loc_dist = "∞"

        improved = "← IMPROVED!" if isinstance(loc_dist, int) and isinstance(orig_dist, int) and loc_dist < orig_dist else ""
        print(f"  p={p}: original dist = {orig_dist}, localized dist = {loc_dist} {improved}")

    print()

    # Systematic search
    print("Systematic search for strict improvements (500 trials):")
    random.seed(2025)
    results = search_witness_improvement(n_trials=500, primes=(2, 3, 5, 7), length=8)
    print(f"  Found {len(results)} strict improvements")

    if results:
        by_prime = {}
        for r in results:
            p = r['prime']
            by_prime[p] = by_prime.get(p, 0) + 1
        print(f"  By prime: {dict(sorted(by_prime.items()))}")

        # Show top 3
        results.sort(key=lambda r: -r['improvement'])
        print("\n  Top 3 improvements:")
        for r in results[:3]:
            print(f"    p={r['prime']}: dist {r['original_dist']} → {r['localized_dist']} "
                  f"(Δ = {r['improvement']})")
    print()


def demo_localization_computation():
    """Show the localization computation step by step."""
    print("=" * 70)
    print("LOCALIZATION COMPUTATION")
    print("A ⊗ Z_(p) → torsion part = A[p^∞]")
    print("=" * 70)
    print()

    # Z/60 = Z/4 ⊕ Z/3 ⊕ Z/5 (by CRT)
    G = FGAbGroup(free_rank=2, torsion_factors=[4, 3, 5, 9, 25])
    print(f"Group G = {G}")
    print(f"  Prime support: {G.prime_support()}")
    print()

    for p in sorted(G.prime_support()):
        loc = G.p_primary_component(p)
        print(f"  G[{p}^∞] = {loc}")
        if loc.is_trivial():
            print(f"    → trivial (no {p}-torsion)")
        else:
            print(f"    → nontrivial ({p}-torsion survives)")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  FUNCTORIAL LOCALIZATION OF PERSISTENCE MODULES — DEMO")
    print("=" * 70 + "\n")

    demo_localization_computation()
    demo_birth_set_identification()
    demo_interleaving_preservation()
    demo_prime_decomposition()
    demo_witness_improvement()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


"""
Visualization 3: Birth Set Identification Theorem

Verifies computationally that PTorsionBirthSet(p, F) = TorsionBirthSet(L_p(F))
across many random examples and visualizes the result.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
from dataclasses import dataclass, field
from typing import List, Set, Optional

# Inline all needed classes
@dataclass
class FGAbGroup:
    free_rank: int = 0
    torsion_factors: List[int] = field(default_factory=list)
    def __post_init__(self):
        self.torsion_factors = sorted([d for d in self.torsion_factors if d >= 2])
    def has_p_torsion(self, p: int) -> bool:
        return any(d % p == 0 for d in self.torsion_factors)
    def has_global_torsion(self) -> bool:
        return len(self.torsion_factors) > 0
    def p_primary_component(self, p: int) -> 'FGAbGroup':
        p_factors = []
        for d in self.torsion_factors:
            pk = 1; temp = d
            while temp % p == 0: pk *= p; temp //= p
            if pk > 1: p_factors.append(pk)
        return FGAbGroup(free_rank=0, torsion_factors=p_factors)

@dataclass
class PersistenceModule:
    groups: List[FGAbGroup]
    def p_torsion_birth(self, p: int) -> Optional[int]:
        for i, g in enumerate(self.groups):
            if g.has_p_torsion(p): return i
        return None
    def global_torsion_birth(self) -> Optional[int]:
        for i, g in enumerate(self.groups):
            if g.has_global_torsion(): return i
        return None
    def localize_at(self, p: int) -> 'PersistenceModule':
        return PersistenceModule([g.p_primary_component(p) for g in self.groups])

def random_persistence_module(length=10, primes=(2,3,5), max_power=2):
    groups = []; acc_torsion = []; cur_free = random.randint(0, 2)
    for i in range(length):
        if random.random() < 0.3:
            p = random.choice(primes); k = random.randint(1, max_power)
            acc_torsion.append(p ** k)
        if random.random() < 0.2: cur_free += 1
        groups.append(FGAbGroup(free_rank=cur_free, torsion_factors=list(acc_torsion)))
    return PersistenceModule(groups=groups)

# Run verification
random.seed(42)
primes = [2, 3, 5, 7]
n_modules = 500
n_verified = 0
n_total = 0

# Track birth index pairs for scatter plot
p_births_list = {p: [] for p in primes}
loc_births_list = {p: [] for p in primes}

for _ in range(n_modules):
    F = random_persistence_module(length=15, primes=(2, 3, 5, 7), max_power=3)
    for p in primes:
        n_total += 1
        pb = F.p_torsion_birth(p)
        F_loc = F.localize_at(p)
        lb = F_loc.global_torsion_birth()

        if pb == lb:
            n_verified += 1

        # Store for plotting (use -1 for None)
        p_births_list[p].append(pb if pb is not None else -1)
        loc_births_list[p].append(lb if lb is not None else -1)

# Create visualization
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

for idx, (ax, p) in enumerate(zip(axes.flat, primes)):
    pb = np.array(p_births_list[p])
    lb = np.array(loc_births_list[p])

    # Filter out -1 (None) vs -1 (None) — these are matching empty sets
    both_none = (pb == -1) & (lb == -1)
    both_some = (pb != -1) & (lb != -1)
    mismatch = ~both_none & ~both_some

    # Perfect agreement line
    ax.plot([-1, 15], [-1, 15], 'r--', linewidth=1, alpha=0.5, label='Perfect agreement')

    # Plot matching cases
    if both_some.any():
        ax.scatter(pb[both_some], lb[both_some], alpha=0.3, s=30,
                  c='#2196F3', label=f'Both detected ({both_some.sum()})')

    if both_none.any():
        ax.scatter([-0.5], [-0.5], alpha=0.7, s=100, c='#4CAF50', marker='s',
                  label=f'Both empty ({both_none.sum()})')

    if mismatch.any():
        ax.scatter(pb[mismatch], lb[mismatch], alpha=0.7, s=50,
                  c='#E91E63', marker='x', label=f'Mismatch ({mismatch.sum()})')

    ax.set_xlabel('PTorsionBirthSet(p, F)')
    ax.set_ylabel('TorsionBirthSet(L_p(F))')
    ax.set_title(f'p = {p}', fontsize=13, fontweight='bold')
    ax.legend(fontsize=8)
    ax.grid(alpha=0.3)
    ax.set_xlim(-1.5, 15)
    ax.set_ylim(-1.5, 15)
    ax.set_aspect('equal')

fig.suptitle(f'Birth Set Identification: PTorsionBirthSet(p, F) = TorsionBirthSet(L_p(F))\n'
             f'Verified: {n_verified}/{n_total} cases ({100*n_verified/n_total:.1f}%)',
             fontsize=14, fontweight='bold')

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('viz_birth_identification.png', dpi=150, bbox_inches='tight')
print(f"Saved viz_birth_identification.png ({n_verified}/{n_total} verified)")


"""
Visualization 1: Spectral Decomposition of Persistence Torsion

Shows how prime localization decomposes a persistence module's torsion
into independent prime channels, analogous to spectral analysis.
Each row shows a different prime channel, with color intensity indicating
the torsion rank at that index.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd
from dataclasses import dataclass, field
from typing import List, Set, Dict

# Inline all needed classes
@dataclass
class FGAbGroup:
    free_rank: int = 0
    torsion_factors: List[int] = field(default_factory=list)
    def __post_init__(self):
        self.torsion_factors = sorted([d for d in self.torsion_factors if d >= 2])
    def p_primary_component(self, p: int) -> 'FGAbGroup':
        p_factors = []
        for d in self.torsion_factors:
            pk = 1
            temp = d
            while temp % p == 0:
                pk *= p
                temp //= p
            if pk > 1:
                p_factors.append(pk)
        return FGAbGroup(free_rank=0, torsion_factors=p_factors)
    def prime_support(self) -> Set[int]:
        primes = set()
        for d in self.torsion_factors:
            temp = d
            for p in range(2, temp + 1):
                if p * p > temp:
                    if temp > 1: primes.add(temp)
                    break
                while temp % p == 0:
                    primes.add(p)
                    temp //= p
        return primes

# Build example persistence module
length = 15
groups = [
    FGAbGroup(free_rank=3),
    FGAbGroup(free_rank=3),
    FGAbGroup(free_rank=3, torsion_factors=[2]),
    FGAbGroup(free_rank=3, torsion_factors=[2, 3]),
    FGAbGroup(free_rank=3, torsion_factors=[4, 3]),
    FGAbGroup(free_rank=3, torsion_factors=[4, 3, 5]),
    FGAbGroup(free_rank=3, torsion_factors=[4, 9, 5]),
    FGAbGroup(free_rank=3, torsion_factors=[8, 9, 5, 7]),
    FGAbGroup(free_rank=3, torsion_factors=[8, 9, 25, 7]),
    FGAbGroup(free_rank=3, torsion_factors=[8, 27, 25, 7]),
    FGAbGroup(free_rank=3, torsion_factors=[16, 27, 25, 49]),
    FGAbGroup(free_rank=3, torsion_factors=[16, 27, 125, 49]),
    FGAbGroup(free_rank=3, torsion_factors=[32, 81, 125, 49]),
    FGAbGroup(free_rank=3, torsion_factors=[32, 81, 125, 343]),
    FGAbGroup(free_rank=3, torsion_factors=[64, 243, 625, 343]),
]

primes = [2, 3, 5, 7]
prime_labels = ['p=2', 'p=3', 'p=5', 'p=7']

# Compute torsion rank at each index for each prime channel
data = np.zeros((len(primes) + 1, length))

# Global torsion rank
for j in range(length):
    data[0, j] = len(groups[j].torsion_factors)

# Per-prime torsion rank
for i, p in enumerate(primes):
    for j in range(length):
        loc = groups[j].p_primary_component(p)
        data[i + 1, j] = len(loc.torsion_factors)

# Find birth indices
births = {}
for i, p in enumerate(primes):
    for j in range(length):
        loc = groups[j].p_primary_component(p)
        if len(loc.torsion_factors) > 0:
            births[p] = j
            break

fig, axes = plt.subplots(len(primes) + 1, 1, figsize=(12, 8), sharex=True)

colors = ['#2196F3', '#E91E63', '#4CAF50', '#FF9800', '#9C27B0']
row_labels = ['Global'] + prime_labels

for i, (ax, label, color) in enumerate(zip(axes, row_labels, colors)):
    bars = ax.bar(range(length), data[i], color=color, alpha=0.7, edgecolor='white')

    # Mark birth index
    if i > 0 and primes[i-1] in births:
        b = births[primes[i-1]]
        ax.axvline(x=b, color='red', linestyle='--', alpha=0.5, linewidth=2)
        ax.annotate(f'birth', (b, data[i, b]), textcoords="offset points",
                   xytext=(10, 5), fontsize=8, color='red', fontweight='bold')

    ax.set_ylabel(label, fontsize=11, fontweight='bold', rotation=0, labelpad=50)
    ax.set_ylim(0, max(data[i]) + 1 if max(data[i]) > 0 else 1)
    ax.set_yticks(range(int(max(data[i])) + 2))
    ax.grid(axis='y', alpha=0.3)

axes[-1].set_xlabel('Filtration Index', fontsize=12)
axes[-1].set_xticks(range(length))

fig.suptitle('Spectral Decomposition of Persistence Torsion\n'
             'Each prime channel isolates independent torsion information',
             fontsize=14, fontweight='bold', y=0.98)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_spectral_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_decomposition.png")


"""
Visualization 2: Witness Improvement via Localization

Shows the distribution of interleaving distance improvements
achieved by localizing at different primes. Demonstrates that
localization can strictly reduce the interleaving distance.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
from dataclasses import dataclass, field
from typing import List, Set, Optional, Dict, Tuple

# Inline all needed classes and functions
@dataclass
class FGAbGroup:
    free_rank: int = 0
    torsion_factors: List[int] = field(default_factory=list)
    def __post_init__(self):
        self.torsion_factors = sorted([d for d in self.torsion_factors if d >= 2])
    def has_p_torsion(self, p: int) -> bool:
        return any(d % p == 0 for d in self.torsion_factors)
    def has_global_torsion(self) -> bool:
        return len(self.torsion_factors) > 0
    def p_primary_component(self, p: int) -> 'FGAbGroup':
        p_factors = []
        for d in self.torsion_factors:
            pk = 1; temp = d
            while temp % p == 0: pk *= p; temp //= p
            if pk > 1: p_factors.append(pk)
        return FGAbGroup(free_rank=0, torsion_factors=p_factors)

@dataclass
class PersistenceModule:
    groups: List[FGAbGroup]
    def global_torsion_birth(self) -> Optional[int]:
        for i, g in enumerate(self.groups):
            if g.has_global_torsion(): return i
        return None
    def localize_at(self, p: int) -> 'PersistenceModule':
        return PersistenceModule([g.p_primary_component(p) for g in self.groups])

def random_persistence_module(length=10, primes=(2,3,5), max_power=2):
    groups = []; acc_torsion = []; cur_free = random.randint(0, 2)
    for i in range(length):
        if random.random() < 0.3:
            p = random.choice(primes); k = random.randint(1, max_power)
            acc_torsion.append(p ** k)
        if random.random() < 0.2: cur_free += 1
        groups.append(FGAbGroup(free_rank=cur_free, torsion_factors=list(acc_torsion)))
    return PersistenceModule(groups=groups)

# Run experiment
random.seed(2025)
n_trials = 2000
primes = [2, 3, 5, 7]
improvements: Dict[int, List[int]] = {p: [] for p in primes}
all_original_dists = []
all_best_localized = []

for _ in range(n_trials):
    F = random_persistence_module(length=12, primes=(2, 3, 5, 7))
    G = random_persistence_module(length=12, primes=(2, 3, 5, 7))
    gb_F = F.global_torsion_birth()
    gb_G = G.global_torsion_birth()
    if gb_F is None or gb_G is None: continue
    global_dist = abs(gb_F - gb_G)
    all_original_dists.append(global_dist)

    best_loc_dist = global_dist
    for p in primes:
        F_loc = F.localize_at(p); G_loc = G.localize_at(p)
        fb = F_loc.global_torsion_birth(); gb = G_loc.global_torsion_birth()
        if fb is None and gb is None: loc_dist = 0
        elif fb is not None and gb is not None: loc_dist = abs(fb - gb)
        else: continue
        if loc_dist < global_dist:
            improvements[p].append(global_dist - loc_dist)
        best_loc_dist = min(best_loc_dist, loc_dist)
    all_best_localized.append(best_loc_dist)

# Create visualization
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Improvement distribution by prime
ax1 = axes[0, 0]
colors = ['#E91E63', '#2196F3', '#4CAF50', '#FF9800']
positions = []
data_to_plot = []
for i, p in enumerate(primes):
    if improvements[p]:
        data_to_plot.append(improvements[p])
        positions.append(i)

bp = ax1.boxplot(data_to_plot, positions=positions, patch_artist=True, widths=0.6)
for patch, color in zip(bp['boxes'], colors[:len(data_to_plot)]):
    patch.set_facecolor(color)
    patch.set_alpha(0.6)
ax1.set_xticks(range(len(primes)))
ax1.set_xticklabels([f'p={p}' for p in primes])
ax1.set_ylabel('Distance Improvement')
ax1.set_title('Distribution of Improvements by Prime', fontweight='bold')
ax1.grid(axis='y', alpha=0.3)

# Plot 2: Number of improvements by prime
ax2 = axes[0, 1]
counts = [len(improvements[p]) for p in primes]
bars = ax2.bar([f'p={p}' for p in primes], counts, color=colors, alpha=0.7)
for bar, count in zip(bars, counts):
    ax2.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 5,
             str(count), ha='center', va='bottom', fontweight='bold')
ax2.set_ylabel('Number of Improvements')
ax2.set_title(f'Frequency of Strict Improvement ({n_trials} trials)', fontweight='bold')
ax2.grid(axis='y', alpha=0.3)

# Plot 3: Original vs best localized distance
ax3 = axes[1, 0]
max_dist = max(max(all_original_dists), max(all_best_localized)) + 1
ax3.scatter(all_original_dists, all_best_localized, alpha=0.1, s=10, c='#2196F3')
ax3.plot([0, max_dist], [0, max_dist], 'r--', linewidth=1, label='No improvement')
ax3.set_xlabel('Original Global Distance')
ax3.set_ylabel('Best Localized Distance')
ax3.set_title('Global vs Best Localized Distance', fontweight='bold')
ax3.legend()
ax3.grid(alpha=0.3)
ax3.set_xlim(-0.5, max_dist)
ax3.set_ylim(-0.5, max_dist)

# Plot 4: Histogram of improvement ratios
ax4 = axes[1, 1]
ratios = []
for orig, loc in zip(all_original_dists, all_best_localized):
    if orig > 0:
        ratios.append(1 - loc / orig)
if ratios:
    ax4.hist(ratios, bins=30, color='#9C27B0', alpha=0.7, edgecolor='white')
    mean_ratio = np.mean(ratios)
    ax4.axvline(mean_ratio, color='red', linestyle='--', linewidth=2,
                label=f'Mean: {mean_ratio:.2%}')
    ax4.legend()
ax4.set_xlabel('Relative Improvement (1 - localized/original)')
ax4.set_ylabel('Frequency')
ax4.set_title('Distribution of Relative Improvement', fontweight='bold')
ax4.grid(axis='y', alpha=0.3)

fig.suptitle('Witness Improvement via Prime Localization\n'
             'Localization can strictly reduce interleaving distances',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_witness_improvement.png', dpi=150, bbox_inches='tight')
print("Saved viz_witness_improvement.png")
